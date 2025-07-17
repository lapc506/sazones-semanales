import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'camera_service.dart';
import 'camera_preview_service.dart';

/// Implementación del servicio de cámara para plataformas móviles (Android/iOS)
class CameraServiceMobile implements CameraService {
  final ImagePicker _picker = ImagePicker();
  
  // Stream controller para el estado de inicialización
  final StreamController<CameraInitializationState> _stateController = 
      StreamController<CameraInitializationState>.broadcast();
  CameraInitializationState _currentState = CameraInitializationState.ready; // En móviles, siempre está listo
  
  @override
  Future<File?> takePicture({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
  }) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      
      return photo != null ? File(photo.path) : null;
    } catch (e) {
      debugPrint('Error al tomar foto en móvil: $e');
      return null;
    }
  }
  
  @override
  Future<File?> pickImageFromGallery({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Error al seleccionar imagen en móvil: $e');
      return null;
    }
  }
  
  @override
  Stream<CameraInitializationState> get initializationStateStream => _stateController.stream;

  @override
  CameraInitializationState get currentState => _currentState;

  @override
  Future<void> initializeProactively() async {
    // En móviles, la cámara siempre está lista, no necesita inicialización especial
    _currentState = CameraInitializationState.ready;
    _stateController.add(_currentState);
  }

  @override
  Future<CaptureResult> takePictureWithPreview({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
    required BuildContext context,
  }) async {
    try {
      // Tomar la foto usando ImagePicker
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      
      if (photo == null) {
        return CaptureResult(); // Usuario canceló
      }
      
      final File imageFile = File(photo.path);
      
      // Verificar si el contexto sigue montado antes de usarlo
      if (!context.mounted) {
        return CaptureResult(errorMessage: 'El contexto ya no está disponible');
      }
      
      // Mostrar la vista previa para confirmación
      final action = await CameraPreviewService.showPreviewConfirmation(
        context: context,
        imageFile: imageFile,
      );
      
      // Si el usuario quiere retomar la foto, indicarlo en el resultado
      if (action == PreviewAction.retake) {
        return CaptureResult(
          imageFile: null,
          wasConfirmed: false,
          errorMessage: "RETAKE_REQUESTED", // Código especial para indicar retomar
        );
      }
      
      return CaptureResult(
        imageFile: imageFile,
        wasConfirmed: action == PreviewAction.confirm,
      );
      
    } catch (e) {
      debugPrint('Error al tomar foto con vista previa en móvil: $e');
      return CaptureResult(errorMessage: 'Error al capturar imagen: $e');
    }
  }

  @override
  Future<bool> isCameraAvailable() async {
    try {
      // En plataformas móviles, asumimos que la cámara está disponible
      // pero podríamos implementar una verificación más robusta si es necesario
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _stateController.close();
      debugPrint('Recursos de CameraServiceMobile liberados');
    } catch (e) {
      debugPrint('Error al liberar recursos de CameraServiceMobile: $e');
    }
  }
}