import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';

/// CameraPage
/// Handles:
///  - Requesting camera permission (runtime)
///  - Distinguishing between denied vs permanently denied
///  - Initializing the first available camera (prefers back)
///  - Displaying a live preview
///  - Offering actions: retry permission, open settings, capture frame (stub)
///  - Graceful cleanup on dispose & lifecycle resume
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

enum _PermissionStatusState { checking, denied, permanentlyDenied, granted }

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  _PermissionStatusState _permState = _PermissionStatusState.checking;
  CameraController? _controller;
  Future<void>? _initFuture;
  CameraDescription? _selectedCamera;
  String? _errorMessage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle hot reload / app switching to keep camera stable
    if (_selectedCamera == null) return;
    if (state == AppLifecycleState.inactive) {
      unawaited(_disposeController());
    } else if (state == AppLifecycleState.resumed &&
        _permState == _PermissionStatusState.granted) {
      unawaited(_initializeCamera(_selectedCamera!));
    }
  }

  Future<void> _checkAndRequestPermission() async {
    setState(() => _permState = _PermissionStatusState.checking);
    final status = await Permission.camera.status;

    if (status.isGranted) {
      setState(() => _permState = _PermissionStatusState.granted);
      await _prepareCamera();
      return;
    }

    if (status.isDenied) {
      final req = await Permission.camera.request();
      if (req.isGranted) {
        setState(() => _permState = _PermissionStatusState.granted);
        await _prepareCamera();
      } else if (req.isPermanentlyDenied) {
        setState(() => _permState = _PermissionStatusState.permanentlyDenied);
      } else {
        setState(() => _permState = _PermissionStatusState.denied);
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      setState(() => _permState = _PermissionStatusState.permanentlyDenied);
      return;
    }

    // Fallback
    setState(() => _permState = _PermissionStatusState.denied);
  }

  Future<void> _prepareCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No cameras found on this device');
        return;
      }
      // Prefer back camera if available
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _selectedCamera = back;
      await _initializeCamera(back);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to enumerate cameras: $e');
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    _initFuture = null;
    try {
      await controller?.dispose();
    } catch (_) {}
  }

  Future<void> _initializeCamera(CameraDescription description) async {
    await _disposeController();
    if (!mounted) return;
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    final initFuture = controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {});
        })
        .catchError((e) {
          if (!mounted) return;
          setState(() => _errorMessage = 'Camera init error: $e');
        });

    if (mounted) {
      setState(() {
        _controller = controller;
        _initFuture = initFuture;
        _errorMessage = null;
      });
    }
  }

  Future<void> _capture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);
    try {
      final file = await _controller!.takePicture();
      if (!mounted) return;
      // Pop with path result so caller can use the image
      Navigator.of(context).pop(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: 'Gagal mengambil gambar: $e',
              type: CustomTextType.body,
              color: Colors.white,
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Widget _buildPermissionDenied({required bool permanently}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: AppColors.accent),
            const SizedBox(height: 16),
            CustomText(
              text: permanently
                  ? 'Camera permission permanently denied.'
                  : 'Camera permission is required to continue.',
              type: CustomTextType.body,
              color: AppColors.text,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: permanently
                  ? () => openAppSettings()
                  : _checkAndRequestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(permanently ? 'Open Settings' : 'Allow Camera'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          CustomText(
            text: label,
            type: CustomTextType.body,
            color: AppColors.text,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_errorMessage != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 16),
              CustomText(
                text: _errorMessage!,
                type: CustomTextType.body,
                color: AppColors.text,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _prepareCamera,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else {
      switch (_permState) {
        case _PermissionStatusState.checking:
          body = _buildLoading('Checking permission...');
          break;
        case _PermissionStatusState.denied:
          body = _buildPermissionDenied(permanently: false);
          break;
        case _PermissionStatusState.permanentlyDenied:
          body = _buildPermissionDenied(permanently: true);
          break;
        case _PermissionStatusState.granted:
          if (_controller == null || _initFuture == null) {
            body = _buildLoading('Initializing camera...');
          } else {
            body = FutureBuilder(
              future: _initFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return _buildLoading('Starting camera...');
                }
                if (!_controller!.value.isInitialized) {
                  return _buildLoading('Waiting camera...');
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_controller!),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isCapturing ? null : _capture,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            icon: _isCapturing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt),
                            label: Text(
                              _isCapturing ? 'Capturing...' : 'Capture',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
          break;
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.black,
      ),
      body: body,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }
}
