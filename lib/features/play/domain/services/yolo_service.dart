import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Normalization strategies supported during preprocessing.
enum YoloNormalization {
  /// Pixel values scaled to the `[0, 1]` range.
  zeroToOne,

  /// Pixel values scaled to the `[-1, 1]` range.
  negativeOneToOne,

  /// Raw 0-255 values (no normalization).
  none,
}

/// Immutable configuration for [YoloService].
@immutable
class YoloOptions {
  const YoloOptions({
    this.confidenceThreshold = 0.3,
    this.nmsThreshold = 0.45,
    this.maxDetections = 10,
    this.normalization = YoloNormalization.zeroToOne,
    this.enableLetterbox = true,
    this.letterboxFillColor = 0xFF000000,
    this.enableWarmUp = false,
  }) : assert(confidenceThreshold >= 0 && confidenceThreshold <= 1),
       assert(nmsThreshold >= 0 && nmsThreshold <= 1),
       assert(maxDetections > 0);

  /// Minimum confidence (objectness * class probability) required to keep a detection.
  final double confidenceThreshold;

  /// IoU threshold used by non-max suppression.
  final double nmsThreshold;

  /// Maximum number of detections returned after NMS.
  final int maxDetections;

  /// Input normalization strategy.
  final YoloNormalization normalization;

  /// Whether to maintain aspect ratio with padding (letterbox resize).
  final bool enableLetterbox;

  /// Fill color for letterboxing (ARGB).
  final int letterboxFillColor;

  /// Perform a single warm-up inference after initialization.
  final bool enableWarmUp;

  YoloOptions copyWith({
    double? confidenceThreshold,
    double? nmsThreshold,
    int? maxDetections,
    YoloNormalization? normalization,
    bool? enableLetterbox,
    int? letterboxFillColor,
    bool? enableWarmUp,
  }) {
    return YoloOptions(
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      nmsThreshold: nmsThreshold ?? this.nmsThreshold,
      maxDetections: maxDetections ?? this.maxDetections,
      normalization: normalization ?? this.normalization,
      enableLetterbox: enableLetterbox ?? this.enableLetterbox,
      letterboxFillColor: letterboxFillColor ?? this.letterboxFillColor,
      enableWarmUp: enableWarmUp ?? this.enableWarmUp,
    );
  }
}

class DetectionBoundingBox {
  const DetectionBoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

class DetectionResult {
  const DetectionResult({
    required this.gestureLabel,
    required this.confidence,
    this.boundingBox,
    this.isFallback = false,
  });

  final String gestureLabel;
  final double confidence;
  final DetectionBoundingBox? boundingBox;
  final bool isFallback;

  factory DetectionResult.fallback() => const DetectionResult(
    gestureLabel: 'Detected Gesture',
    confidence: 0,
    boundingBox: null,
    isFallback: true,
  );
}

/// YOLOv12 compatible service built on top of the `tflite_flutter` plugin.
///
/// Pipeline summary:
///  * Image preprocessing performs optional letterbox resize, normalization, and
///    packs the tensor as `[1, height, width, 3]` floats.
///  * Inference supports both YOLOv5-style single outputs and YOLOv12-style
///    multi-output tensors (`boxes` + `scores` + optional `objectness`).
///  * Post-processing chooses the best class per anchor, applies confidence
///    filtering, then removes overlaps with Non-Max Suppression.
///  * `predictAll` exposes the full detection list; `predict` keeps the most
///    confident detection for backwards compatibility.
///
/// Example:
/// ```dart
/// final service = YoloService(options: const YoloOptions(enableWarmUp: true));
/// await service.init();
/// final detections = await service.predictAll('assets/test/sample.jpg');
/// for (final detection in detections) {
///   debugPrint('${detection.gestureLabel}: ${detection.confidence}');
/// }
/// ```
class YoloService {
  YoloService._internal() : _options = const YoloOptions();

  static final YoloService _instance = YoloService._internal();

  factory YoloService({YoloOptions? options}) {
    if (options != null) {
      _instance._options = options;
    }
    return _instance;
  }

  static const _modelAssetPath = 'assets/models/sibi.tflite';
  static const _labelsAssetPath = 'assets/models/labels.txt';

  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  GpuDelegateV2? _gpuDelegate;
  List<String> _labels = <String>[];
  List<int>? _inputShape;
  YoloOptions _options;

  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  /// Update runtime options without rebuilding the singleton.
  void updateOptions(YoloOptions options) {
    _options = options;
  }

  /// Initialize the interpreter, load labels, and optionally warm up.
  Future<void> init() async {
    if (_isInitialized) return;
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return;
    }

    final completer = Completer<void>();
    _initCompleter = completer;

    try {
      _labels = await _loadLabels();
      await _createInterpreter();
      if (_options.enableWarmUp) {
        await _performWarmUp();
      }
      _isInitialized = _interpreter != null && _labels.isNotEmpty;
      completer.complete();
    } catch (error, stackTrace) {
      debugPrint('YOLO init failed: $error\n$stackTrace');
      _isInitialized = false;
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    } finally {
      _initCompleter = null;
    }
  }

  /// Convenience wrapper returning only the most confident detection.
  Future<DetectionResult> predict(String imagePath) async {
    final detections = await predictAll(imagePath);
    if (detections.isEmpty) {
      return DetectionResult.fallback();
    }
    return detections.first;
  }

  /// Run inference and return every detection that survived filtering & NMS.
  Future<List<DetectionResult>> predictAll(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return const <DetectionResult>[];
      }
      final bytes = await file.readAsBytes();
      return predictAllFromBytes(bytes);
    } catch (error, stackTrace) {
      debugPrint('YOLO predictAll error: $error\n$stackTrace');
      return const <DetectionResult>[];
    }
  }

  /// Testing helper: run inference directly from image bytes (useful for unit tests).
  @visibleForTesting
  Future<List<DetectionResult>> predictAllFromBytes(Uint8List bytes) async {
    try {
      return await _runModelWithBytes(bytes);
    } catch (error, stackTrace) {
      debugPrint('YOLO predictAllFromBytes error: $error\n$stackTrace');
      return const <DetectionResult>[];
    }
  }

  Future<List<DetectionResult>> _runModelWithBytes(Uint8List bytes) async {
    try {
      await init();
    } catch (error, stackTrace) {
      debugPrint('YOLO predict init error: $error\n$stackTrace');
      return const <DetectionResult>[];
    }

    if (!_isInitialized ||
        _interpreter == null ||
        _isolateInterpreter == null) {
      return const <DetectionResult>[];
    }

    final inputShape = _inputShape;
    if (inputShape == null || inputShape.length < 4) {
      return const <DetectionResult>[];
    }

    Map<String, dynamic> preprocessing;
    try {
      preprocessing = await compute<Map<String, dynamic>, Map<String, dynamic>>(
        _preprocessImageOnIsolate,
        <String, dynamic>{
          'bytes': bytes,
          'targetWidth': inputShape[2],
          'targetHeight': inputShape[1],
          'normalization': _options.normalization.index,
          'enableLetterbox': _options.enableLetterbox,
          'letterboxFill': _options.letterboxFillColor,
        },
      );
    } catch (error, stackTrace) {
      debugPrint('YOLO preprocess failed: $error\n$stackTrace');
      return const <DetectionResult>[];
    }

    final dynamic processedInputData = preprocessing['input'];
    final originalWidth = preprocessing['originalWidth'] as int? ?? 0;
    final originalHeight = preprocessing['originalHeight'] as int? ?? 0;
    final metadataMap =
        preprocessing['metadata'] as Map<String, dynamic>? ??
        const <String, dynamic>{};

    if (processedInputData is! List ||
        originalWidth == 0 ||
        originalHeight == 0) {
      return const <DetectionResult>[];
    }

    final metadata = _ImageMetadata.fromPreprocess(
      originalWidth: originalWidth,
      originalHeight: originalHeight,
      inputShape: inputShape,
      metadata: metadataMap,
    );

    try {
      final outputData = _allocateOutputTensors();

      await _isolateInterpreter!.runForMultipleInputs(<Object>[
        processedInputData,
      ], outputData.map);

      return _postProcess(outputData.data, metadata);
    } catch (error, stackTrace) {
      debugPrint('YOLO inference failed: $error\n$stackTrace');
      return const <DetectionResult>[];
    }
  }

  Future<void> dispose() async {
    try {
      await _isolateInterpreter?.close();
    } catch (error) {
      debugPrint('YOLO isolate close error: $error');
    }
    _isolateInterpreter = null;

    try {
      _interpreter?.close();
    } catch (error) {
      debugPrint('YOLO interpreter close error: $error');
    }
    _interpreter = null;

    try {
      _gpuDelegate?.delete();
    } catch (error) {
      debugPrint('YOLO GPU delegate close error: $error');
    }
    _gpuDelegate = null;

    _isInitialized = false;
  }

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString(_labelsAssetPath);
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  Future<void> _createInterpreter() async {
    Interpreter? interpreterForCleanup;
    late final Interpreter interpreterInstance;
    GpuDelegateV2? gpuDelegate;

    try {
      final options = InterpreterOptions();
      try {
        gpuDelegate = GpuDelegateV2();
        options.addDelegate(gpuDelegate);
      } catch (error) {
        debugPrint('GPU delegate unavailable, falling back to CPU: $error');
        gpuDelegate = null;
      }

      try {
        interpreterInstance = await Interpreter.fromAsset(
          _modelAssetPath,
          options: options,
        );
        interpreterForCleanup = interpreterInstance;
        _gpuDelegate = gpuDelegate;
      } catch (error) {
        debugPrint('Failed to create interpreter with GPU: $error');
        gpuDelegate?.delete();
        gpuDelegate = null;

        final cpuOptions = InterpreterOptions();
        interpreterInstance = await Interpreter.fromAsset(
          _modelAssetPath,
          options: cpuOptions,
        );
        interpreterForCleanup = interpreterInstance;
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize interpreter: $error\n$stackTrace');
      interpreterForCleanup?.close();
      gpuDelegate?.delete();
      rethrow;
    }

    _interpreter = interpreterInstance;
    _inputShape = interpreterInstance.getInputTensor(0).shape;
    _isolateInterpreter = await IsolateInterpreter.create(
      address: interpreterInstance.address,
    );
  }

  Future<void> _performWarmUp() async {
    final interpreter = _isolateInterpreter;
    final inputShape = _inputShape;
    if (interpreter == null || inputShape == null) {
      return;
    }

    try {
      final zeroInput = _createEmptyTensor(inputShape);
      final outputs = _allocateOutputTensors();
      await interpreter.runForMultipleInputs(<Object>[zeroInput], outputs.map);
    } catch (error) {
      debugPrint('YOLO warm-up failed: $error');
    }
  }

  _OutputAllocation _allocateOutputTensors() {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('Interpreter not initialized');
    }

    final outputTensors = interpreter.getOutputTensors();
    final data = <dynamic>[];
    final map = <int, Object>{};

    for (var i = 0; i < outputTensors.length; i++) {
      final shape = outputTensors[i].shape;
      final buffer = _createEmptyTensor(shape);
      data.add(buffer);
      map[i] = buffer;
    }

    return _OutputAllocation(data: data, map: map);
  }

  List<DetectionResult> _postProcess(
    List<dynamic> outputs,
    _ImageMetadata metadata,
  ) {
    if (outputs.isEmpty) {
      return const <DetectionResult>[];
    }

    // Modern YOLO models often have an output shape like [1, 84, 8400]
    // which corresponds to [batch, channels, proposals].
    // The channels are [cx, cy, w, h, class_1, class_2, ...].
    // We need to transpose this to [proposals, channels] for easier iteration.
    final rawOutput = _flattenBatch(outputs.first);
    if (rawOutput == null || rawOutput.isEmpty) {
      return const <DetectionResult>[];
    }

    // Assuming rawOutput is List<List<dynamic>> with shape [channels, proposals]
    final proposals = rawOutput.first.length as int;
    final channels = rawOutput.length as int;
    if (proposals == 0 || channels < 5) {
      return const <DetectionResult>[];
    }
    
    final transposedOutput = List.generate(
      proposals,
      (i) => List.generate(channels, (j) => rawOutput[j][i] as double),
    );

    final candidates = <_CandidateDetection>[];
    final classCount = channels - 4; // 4 for box coords

    for (final proposal in transposedOutput) {
      // Find the best class score for this proposal.
      // Class scores start at index 4.
      var bestClassIndex = -1;
      var bestClassScore = 0.0;

      for (var i = 0; i < classCount; i++) {
        final score = proposal[4 + i];
        if (score > bestClassScore) {
          bestClassScore = score;
          bestClassIndex = i;
        }
      }

      // Filter based on confidence threshold.
      if (bestClassScore < _options.confidenceThreshold) {
        continue;
      }
      
      // The highest class score is the confidence.
      final confidence = bestClassScore;

      // Extract bounding box, already in [centerX, centerY, width, height] format.
      final boxData = proposal.sublist(0, 4);
      final boundingBox = _convertBox(boxData, metadata);
      if (boundingBox == null) {
        continue;
      }

      candidates.add(
        _CandidateDetection(
          label: _labelForIndex(bestClassIndex),
          confidence: confidence,
          box: boundingBox,
        ),
      );
    }
    
    if (candidates.isEmpty) {
      return const <DetectionResult>[];
    }

    final pruned = _applyNms(candidates);
    if (pruned.isEmpty) {
      return const <DetectionResult>[];
    }

    return pruned
        .map(
          (candidate) => DetectionResult(
            gestureLabel: candidate.label,
            confidence: math.min(1.0, candidate.confidence),
            boundingBox: candidate.box,
          ),
        )
        .toList(growable: false);
  }

  List<_CandidateDetection> _applyNms(List<_CandidateDetection> candidates) {
    if (candidates.isEmpty) {
      return candidates;
    }

    final sorted = List<_CandidateDetection>.from(candidates)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    final selected = <_CandidateDetection>[];
    for (final candidate in sorted) {
      var shouldSelect = true;
      for (final kept in selected) {
        final iou = _computeIoU(candidate.box, kept.box);
        if (iou > _options.nmsThreshold) {
          shouldSelect = false;
          break;
        }
      }

      if (shouldSelect) {
        selected.add(candidate);
        if (selected.length >= _options.maxDetections) {
          break;
        }
      }
    }

    return selected;
  }

  String _labelForIndex(int index) {
    if (index >= 0 && index < _labels.length) {
      return _labels[index];
    }
    return 'class_$index';
  }

  DetectionBoundingBox? _convertBox(List<double> box, _ImageMetadata metadata) {
    if (box.length < 4 ||
        metadata.inputWidth <= 0 ||
        metadata.inputHeight <= 0) {
      return null;
    }

    final centerX = box[0] * metadata.inputWidth;
    final centerY = box[1] * metadata.inputHeight;
    final widthInput = box[2] * metadata.inputWidth;
    final heightInput = box[3] * metadata.inputHeight;

    if (widthInput <= 0 || heightInput <= 0) {
      return null;
    }

    var left = centerX - widthInput / 2;
    var top = centerY - heightInput / 2;

    left -= metadata.padX;
    top -= metadata.padY;

    if (metadata.scaleX <= 0 || metadata.scaleY <= 0) {
      return null;
    }

    left /= metadata.scaleX;
    top /= metadata.scaleY;

    var width = widthInput / metadata.scaleX;
    var height = heightInput / metadata.scaleY;

    left = left.clamp(0.0, metadata.originalWidth.toDouble()) as double;
    top = top.clamp(0.0, metadata.originalHeight.toDouble()) as double;
    width = width.clamp(0.0, metadata.originalWidth - left) as double;
    height = height.clamp(0.0, metadata.originalHeight - top) as double;

    if (width <= 0 || height <= 0) {
      return null;
    }

    return DetectionBoundingBox(
      left: left,
      top: top,
      width: width,
      height: height,
    );
  }

  double _computeIoU(DetectionBoundingBox a, DetectionBoundingBox b) {
    final ax1 = a.left;
    final ay1 = a.top;
    final ax2 = a.left + a.width;
    final ay2 = a.top + a.height;

    final bx1 = b.left;
    final by1 = b.top;
    final bx2 = b.left + b.width;
    final by2 = b.top + b.height;

    final interWidth = math.max(0.0, math.min(ax2, bx2) - math.max(ax1, bx1));
    final interHeight = math.max(0.0, math.min(ay2, by2) - math.max(ay1, by1));
    final interArea = interWidth * interHeight;
    if (interArea <= 0) {
      return 0;
    }

    final areaA = a.width * a.height;
    final areaB = b.width * b.height;
    final union = areaA + areaB - interArea;
    if (union <= 0) {
      return 0;
    }

    return interArea / union;
  }

  List<double> _asDoubleList(dynamic source) {
    if (source is List) {
      return List<double>.generate(source.length, (index) {
        final value = source[index];
        if (value is num) {
          return value.toDouble();
        }
        return 0.0;
      }, growable: false);
    }
    return const <double>[];
  }

  List<dynamic>? _flattenBatch(dynamic tensor) {
    if (tensor is! List) {
      return null;
    }

    dynamic current = tensor;
    while (current is List && current.length == 1 && current.first is List) {
      current = current.first;
    }

    return current is List ? current : null;
  }

  dynamic _createEmptyTensor(List<int> shape, [int dimension = 0]) {
    final length = shape[dimension];
    if (dimension == shape.length - 1) {
      return Float32List(length);
    }

    return List<dynamic>.generate(
      length,
      (_) => _createEmptyTensor(shape, dimension + 1),
      growable: false,
    );
  }
}

class _CandidateDetection {
  const _CandidateDetection({
    required this.label,
    required this.confidence,
    required this.box,
  });

  final String label;
  final double confidence;
  final DetectionBoundingBox box;
}

class _ImageMetadata {
  const _ImageMetadata({
    required this.originalWidth,
    required this.originalHeight,
    required this.inputWidth,
    required this.inputHeight,
    required this.scaleX,
    required this.scaleY,
    required this.padX,
    required this.padY,
  });

  factory _ImageMetadata.fromPreprocess({
    required int originalWidth,
    required int originalHeight,
    required List<int> inputShape,
    required Map<String, dynamic> metadata,
  }) {
    final inputWidth =
        (metadata['inputWidth'] as num?)?.toDouble() ??
        inputShape[2].toDouble();
    final inputHeight =
        (metadata['inputHeight'] as num?)?.toDouble() ??
        inputShape[1].toDouble();
    final scaleX =
        (metadata['scaleX'] as num?)?.toDouble() ?? inputWidth / originalWidth;
    final scaleY =
        (metadata['scaleY'] as num?)?.toDouble() ??
        inputHeight / originalHeight;
    final padX = (metadata['padX'] as num?)?.toDouble() ?? 0.0;
    final padY = (metadata['padY'] as num?)?.toDouble() ?? 0.0;

    return _ImageMetadata(
      originalWidth: originalWidth,
      originalHeight: originalHeight,
      inputWidth: inputWidth,
      inputHeight: inputHeight,
      scaleX: scaleX,
      scaleY: scaleY,
      padX: padX,
      padY: padY,
    );
  }

  final int originalWidth;
  final int originalHeight;
  final double inputWidth;
  final double inputHeight;
  final double scaleX;
  final double scaleY;
  final double padX;
  final double padY;
}

class _OutputAllocation {
  _OutputAllocation({required this.data, required this.map});

  final List<dynamic> data;
  final Map<int, Object> map;
}

/// Preprocess image bytes inside an isolate to keep the UI thread responsive.
///
/// The returned map contains:
///  * `input`: Tensor data shaped as `[1, height, width, 3]` floats.
///  * `originalWidth` / `originalHeight`: Source image dimensions.
///  * `metadata`: Scaling + padding data for reverse mapping boxes.
Map<String, dynamic> _preprocessImageOnIsolate(Map<String, dynamic> message) {
  final bytes = message['bytes'] as Uint8List?;
  final targetWidth = message['targetWidth'] as int?;
  final targetHeight = message['targetHeight'] as int?;
  final normalizationIndex = message['normalization'] as int? ?? 0;
  final enableLetterbox = message['enableLetterbox'] as bool? ?? false;
  final letterboxFill = message['letterboxFill'] as int? ?? 0xFF000000;

  if (bytes == null || targetWidth == null || targetHeight == null) {
    return const <String, dynamic>{};
  }

  final decodedImage = img.decodeImage(bytes);
  if (decodedImage == null) {
    return const <String, dynamic>{};
  }

  final normalization = YoloNormalization.values[normalizationIndex];

  img.Image processedImage;
  double scaleX;
  double scaleY;
  double padX = 0;
  double padY = 0;

  if (enableLetterbox) {
    final scale = math.min(
      targetWidth / decodedImage.width,
      targetHeight / decodedImage.height,
    );
    final resizedWidth = math.max(1, (decodedImage.width * scale).round());
    final resizedHeight = math.max(1, (decodedImage.height * scale).round());

    final resized = img.copyResize(
      decodedImage,
      width: resizedWidth,
      height: resizedHeight,
      interpolation: img.Interpolation.linear,
    );

    final base = img.Image(width: targetWidth, height: targetHeight);
    final fillR = (letterboxFill >> 16) & 0xFF;
    final fillG = (letterboxFill >> 8) & 0xFF;
    final fillB = letterboxFill & 0xFF;
    _fillImage(base, fillR, fillG, fillB);

    final dx = ((targetWidth - resizedWidth) / 2).floor();
    final dy = ((targetHeight - resizedHeight) / 2).floor();
    _blitImage(base, resized, dx, dy);

    processedImage = base;
    padX = (targetWidth - resizedWidth) / 2.0;
    padY = (targetHeight - resizedHeight) / 2.0;
    scaleX = resizedWidth / decodedImage.width;
    scaleY = resizedHeight / decodedImage.height;
  } else {
    processedImage = img.copyResize(
      decodedImage,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );
    scaleX = targetWidth / decodedImage.width;
    scaleY = targetHeight / decodedImage.height;
  }

  final input = List<List<List<Float32List>>>.generate(1, (_) {
    return List<List<Float32List>>.generate(targetHeight, (int y) {
      return List<Float32List>.generate(targetWidth, (int x) {
        final pixel = processedImage.getPixel(x, y);
        double r;
        double g;
        double b;

        switch (normalization) {
          case YoloNormalization.zeroToOne:
            r = pixel.rNormalized.toDouble();
            g = pixel.gNormalized.toDouble();
            b = pixel.bNormalized.toDouble();
            break;
          case YoloNormalization.negativeOneToOne:
            r = pixel.rNormalized.toDouble() * 2.0 - 1.0;
            g = pixel.gNormalized.toDouble() * 2.0 - 1.0;
            b = pixel.bNormalized.toDouble() * 2.0 - 1.0;
            break;
          case YoloNormalization.none:
            r = pixel.r.toDouble();
            g = pixel.g.toDouble();
            b = pixel.b.toDouble();
            break;
        }

        final channels = Float32List(3);
        channels[0] = r;
        channels[1] = g;
        channels[2] = b;
        return channels;
      }, growable: false);
    }, growable: false);
  }, growable: false);

  return <String, dynamic>{
    'input': input,
    'originalWidth': decodedImage.width,
    'originalHeight': decodedImage.height,
    'metadata': <String, dynamic>{
      'inputWidth': targetWidth,
      'inputHeight': targetHeight,
      'scaleX': scaleX,
      'scaleY': scaleY,
      'padX': padX,
      'padY': padY,
    },
  };
}

void _fillImage(img.Image image, int r, int g, int b) {
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }
}

void _blitImage(img.Image dst, img.Image src, int dx, int dy) {
  final pixelCache = src.getPixel(0, 0);
  for (var y = 0; y < src.height; y++) {
    final destY = dy + y;
    if (destY < 0 || destY >= dst.height) {
      continue;
    }
    for (var x = 0; x < src.width; x++) {
      final destX = dx + x;
      if (destX < 0 || destX >= dst.width) {
        continue;
      }
      final pixel = src.getPixel(x, y, pixelCache);
      dst.setPixel(destX, destY, pixel);
    }
  }
}
