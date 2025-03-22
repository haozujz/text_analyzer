import 'package:camera/camera.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_flutter/Services/logger_service.dart';
import '../Services/camera_service.dart';

final cameraServiceProvider = Provider((ref) => CameraService());

final cameraViewModelProvider =
    StateNotifierProvider<CameraViewModel, CameraState>((ref) {
      final cameraService = ref.read(cameraServiceProvider);
      return CameraViewModel(cameraService);
    });

class CameraState {
  final bool isCameraInitialized;
  final String? cameraError;
  final String imagePath;
  final bool isTakingPicture;

  CameraState({
    this.isCameraInitialized = false,
    this.cameraError,
    this.imagePath = '',
    this.isTakingPicture = false,
  });

  CameraState copyWith({
    bool? isCameraInitialized,
    String? cameraError,
    String? imagePath,
    bool? isTakingPicture,
  }) {
    return CameraState(
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      cameraError: cameraError ?? this.cameraError,
      imagePath: imagePath ?? this.imagePath,
      isTakingPicture: isTakingPicture ?? this.isTakingPicture,
    );
  }
}

class CameraViewModel extends StateNotifier<CameraState> {
  final CameraService _cameraService;

  CameraViewModel(this._cameraService) : super(CameraState());

  Future<void> initializeCamera() async {
    try {
      await _cameraService.initializeCamera();
      state = state.copyWith(isCameraInitialized: true);
    } catch (e) {
      state = state.copyWith(cameraError: e.toString());
    }
  }

  Future<void> takePicture() async {
    try {
      state = state.copyWith(isTakingPicture: true);
      final imagePath = await _cameraService.takePicture();

      if (imagePath != null) {
        state = state.copyWith(imagePath: imagePath);
        LoggerService().info('Picture taken: $imagePath');
      }
    } catch (e) {
      state = state.copyWith(cameraError: 'Failed to take picture: $e');
    } finally {
      state = state.copyWith(isTakingPicture: false);
    }
  }

  void resetImage() {
    state = state.copyWith(imagePath: '');
  }

  CameraController? getCameraController() {
    return _cameraService.controller;
  }

  // Set image according to Image Picker
  void setImageFromPicker(String imagePath) {
    state = state.copyWith(imagePath: imagePath);
    LoggerService().info('Image path set to picked image: ${state.imagePath}');
  }

  void stopCamera() {
    _cameraService.stop();
    state = state.copyWith(isCameraInitialized: false);
  }

  // void resumeCamera() {
  //   _cameraService.resume();
  // }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}
