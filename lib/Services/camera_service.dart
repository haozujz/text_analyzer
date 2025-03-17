import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw 'No cameras available';
      }

      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      await _controller!.initialize();
    } catch (e) {
      _controller = null;
      throw 'Camera initialization failed: $e';
    }
  }

  Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw 'Camera not initialized';
    }
    final image = await _controller!.takePicture();
    return image.path;
  }

  CameraController? get controller => _controller;

  void stop() {
    _controller?.dispose();
    _controller = null;
  }

  // Future<void> resume() async {
  //   if (_controller == null) {
  //     await initializeCamera(); // Reinitialize the camera if it's stopped
  //   } else if (!_controller!.value.isInitialized) {
  //     await _controller!
  //         .initialize(); // Initialize if the controller exists but is not initialized
  //   }
  // }

  void dispose() {
    _controller?.dispose();
  }
}
