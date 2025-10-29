import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Normalization strategies supported during preprocessing.
enum ClassifierNormalization {
  /// Pixel values scaled to the `[0, 1]` range.
  zeroToOne,

  /// Pixel values scaled to the `[-1, 1]` range.
  negativeOneToOne,

  /// Raw 0-255 values (no normalization).
  none,
}

/// Immutable configuration for [ClassifierService].
@immutable
class ClassifierOptions {
  const ClassifierOptions({
    this.confidenceThreshold = 0.3,
    this.normalization = ClassifierNormalization.zeroToOne,
    this.enableWarmUp = false,
  }) : assert(confidenceThreshold >= 0 && confidenceThreshold <= 1);

  /// Minimum confidence required to accept a prediction.
  final double confidenceThreshold;

  /// Input normalization strategy.
  final ClassifierNormalization normalization;

  /// Perform a single warm-up inference after initialization.
  final bool enableWarmUp;

  ClassifierOptions copyWith({
    double? confidenceThreshold,
    ClassifierNormalization? normalization,
    bool? enableWarmUp,
  }) {
    return ClassifierOptions(
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      normalization: normalization ?? this.normalization,
      enableWarmUp: enableWarmUp ?? this.enableWarmUp,
    );
  }
}

/// Prediction result produced by [ClassifierService].
class ClassificationResult {
  const ClassificationResult({
    required this.label,
    required this.confidence,
  });

  final String label;
  final double confidence;

  factory ClassificationResult.fallback() =>
      const ClassificationResult(label: 'Unknown', confidence: 0);

  bool get isFallback => confidence <= 0 || label.isEmpty;
}

/// YOLOv8s classification service backed by `tflite_flutter`.
///
/// Pipeline summary:
///  * Image preprocessing resizes to 224x224 and normalizes pixel values.
///  * Inference runs on an isolate to avoid blocking the UI thread.
///  * The highest confidence score maps to the predicted SIBI label.
class ClassifierService {
  ClassifierService._internal() : _options = const ClassifierOptions();

  static final ClassifierService _instance = ClassifierService._internal();

  factory ClassifierService({ClassifierOptions? options}) {
    if (options != null) {
      _instance._options = options;
    }
    return _instance;
  }

  static const _modelAssetPath = 'assets/models/sibi-c.tflite';
  static const _labelsAssetPath = 'assets/models/labels.txt';

  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  GpuDelegateV2? _gpuDelegate;
  List<String> _labels = <String>[];
  List<int>? _inputShape;
  ClassifierOptions _options;

  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  /// Update runtime options without rebuilding the singleton.
  void updateOptions(ClassifierOptions options) {
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
      debugPrint('Classifier init failed: $error\n$stackTrace');
      _isInitialized = false;
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    } finally {
      _initCompleter = null;
    }
  }

  /// Run inference against the image located at [imagePath].
  Future<ClassificationResult> predict(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return ClassificationResult.fallback();
      }
      final bytes = await file.readAsBytes();
      return predictFromBytes(bytes);
    } catch (error, stackTrace) {
      debugPrint('Classifier predict error: $error\n$stackTrace');
      return ClassificationResult.fallback();
    }
  }

  /// Run inference from raw image bytes (useful for tests).
  Future<ClassificationResult> predictFromBytes(Uint8List bytes) async {
    try {
      return await _runModelWithBytes(bytes);
    } catch (error, stackTrace) {
      debugPrint('Classifier predictFromBytes error: $error\n$stackTrace');
      return ClassificationResult.fallback();
    }
  }

  Future<ClassificationResult> _runModelWithBytes(Uint8List bytes) async {
    try {
      await init();
    } catch (error, stackTrace) {
      debugPrint('Classifier init during predict failed: $error\n$stackTrace');
      return ClassificationResult.fallback();
    }

    if (!_isInitialized || _interpreter == null || _isolateInterpreter == null) {
      return ClassificationResult.fallback();
    }

    final inputShape = _inputShape;
    if (inputShape == null || inputShape.length < 4) {
      return ClassificationResult.fallback();
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
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Classifier preprocess failed: $error\n$stackTrace');
      return ClassificationResult.fallback();
    }

    final dynamic processedInputData = preprocessing['input'];
    if (processedInputData is! List) {
      return ClassificationResult.fallback();
    }

    final outputs = _allocateOutputTensors();
    final start = DateTime.now();
    try {
      await _isolateInterpreter!.runForMultipleInputs(
        <Object>[processedInputData],
        outputs.map,
      );
    } catch (error, stackTrace) {
      debugPrint('Classifier inference failed: $error\n$stackTrace');
      return ClassificationResult.fallback();
    }
    final elapsed = DateTime.now().difference(start);
    debugPrint('Classifier inference: ${elapsed.inMilliseconds} ms');

    final scores = _extractScores(outputs.data);
    if (scores.isEmpty) {
      return ClassificationResult.fallback();
    }

    var bestIndex = 0;
    var bestScore = scores[0];
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }

    if (bestScore.isNaN || bestScore.isInfinite) {
      return ClassificationResult.fallback();
    }

    if (bestScore < _options.confidenceThreshold) {
      return ClassificationResult.fallback();
    }

    final label = _labelForIndex(bestIndex).trim();
    return ClassificationResult(
      label: label.isEmpty ? 'Unknown' : label,
      confidence: math.min(1.0, bestScore),
    );
  }

  Future<void> dispose() async {
    try {
      await _isolateInterpreter?.close();
    } catch (error) {
      debugPrint('Classifier isolate close error: $error');
    }
    _isolateInterpreter = null;

    try {
      _interpreter?.close();
    } catch (error) {
      debugPrint('Classifier interpreter close error: $error');
    }
    _interpreter = null;

    try {
      _gpuDelegate?.delete();
    } catch (error) {
      debugPrint('Classifier GPU delegate close error: $error');
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
      debugPrint('Classifier warm-up failed: $error');
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

  List<double> _extractScores(List<dynamic> outputs) {
    if (outputs.isEmpty) {
      return const <double>[];
    }

    final flattened = _flattenTensor(outputs.first);
    if (flattened.isEmpty) {
      return const <double>[];
    }

    return flattened;
  }

  List<double> _flattenTensor(dynamic tensor) {
    if (tensor is Float32List) {
      return tensor.toList(growable: false);
    }

    if (tensor is List) {
      final result = <double>[];
      for (final element in tensor) {
        result.addAll(_flattenTensor(element));
      }
      return result;
    }

    if (tensor is num) {
      return <double>[tensor.toDouble()];
    }

    return const <double>[];
  }

  String _labelForIndex(int index) {
    if (index >= 0 && index < _labels.length) {
      return _labels[index];
    }
    return 'class_$index';
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

class _OutputAllocation {
  _OutputAllocation({required this.data, required this.map});

  final List<dynamic> data;
  final Map<int, Object> map;
}

/// Preprocess image bytes inside an isolate to keep the UI thread responsive.
///
/// The returned map contains the tensor-ready `[1, height, width, 3]` float data
/// plus the original image dimensions for logging or future use.
Map<String, dynamic> _preprocessImageOnIsolate(Map<String, dynamic> message) {
  final bytes = message['bytes'] as Uint8List?;
  final targetWidth = message['targetWidth'] as int?;
  final targetHeight = message['targetHeight'] as int?;
  final normalizationIndex = message['normalization'] as int? ?? 0;

  if (bytes == null || targetWidth == null || targetHeight == null) {
    return const <String, dynamic>{};
  }

  final decodedImage = img.decodeImage(bytes);
  if (decodedImage == null) {
    return const <String, dynamic>{};
  }

  final normalization = ClassifierNormalization.values[normalizationIndex];

  final resized = img.copyResize(
    decodedImage,
    width: targetWidth,
    height: targetHeight,
    interpolation: img.Interpolation.linear,
  );

  final input = List<List<List<Float32List>>>.generate(1, (_) {
    return List<List<Float32List>>.generate(targetHeight, (int y) {
      return List<Float32List>.generate(targetWidth, (int x) {
        final pixel = resized.getPixel(x, y);
        double r;
        double g;
        double b;

        switch (normalization) {
          case ClassifierNormalization.zeroToOne:
            r = pixel.rNormalized.toDouble();
            g = pixel.gNormalized.toDouble();
            b = pixel.bNormalized.toDouble();
            break;
          case ClassifierNormalization.negativeOneToOne:
            r = pixel.rNormalized.toDouble() * 2.0 - 1.0;
            g = pixel.gNormalized.toDouble() * 2.0 - 1.0;
            b = pixel.bNormalized.toDouble() * 2.0 - 1.0;
            break;
          case ClassifierNormalization.none:
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
  };
}
