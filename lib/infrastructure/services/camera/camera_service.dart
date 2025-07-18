import 'dart:io';
import 'package:flutter/material.dart';

/// Estados de inicialización de la cámara
enum CameraInitializationState {
  notInitialized,
  initializing,
  ready,
  error,
}

/// Resultado de captura de foto con metadatos adicionales
class CaptureResult {
  final File? imageFile;
  final bool wasConfirmed;
  final String? errorMessage;

  CaptureResult({
    this.imageFile,
    this.wasConfirmed = false,
    this.errorMessage,
  });

  bool get isSuccess => imageFile != null && wasConfirmed;
  bool get isCancelled => imageFile == null && errorMessage == null;
  bool get hasError => errorMessage != null;
}

/// Interfaz abstracta para servicios de cámara en diferentes plataformas
abstract class CameraService {
  /// Stream que emite el estado actual de inicialización de la cámara
  Stream<CameraInitializationState> get initializationStateStream;

  /// Estado actual de inicialización de la cámara
  CameraInitializationState get currentState;

  /// Inicializa la cámara de forma proactiva
  ///
  /// Esto permite que la UI muestre el estado de carga y prepare la cámara
  /// antes de que el usuario intente tomar una foto
  Future<void> initializeProactively();

  /// Toma una foto usando la cámara del dispositivo con vista previa
  ///
  /// Retorna un [CaptureResult] que incluye la imagen y si fue confirmada
  /// El usuario verá una vista previa y podrá confirmar o retomar la foto
  Future<CaptureResult> takePictureWithPreview({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
    required BuildContext context,
  });

  /// Muestra un visor de cámara en vivo para tomar fotos
  ///
  /// Permite al usuario ver lo que la cámara está enfocando antes de tomar la foto
  /// Retorna un [CaptureResult] que incluye la imagen y si fue confirmada
  Future<CaptureResult> showLiveCameraViewfinder({
    required BuildContext context,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  });

  /// Toma una foto usando la cámara del dispositivo (método legacy)
  ///
  /// Retorna un [File] con la imagen capturada o null si se cancela
  Future<File?> takePicture({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
  });

  /// Selecciona una imagen de la galería o sistema de archivos
  ///
  /// Retorna un [File] con la imagen seleccionada o null si se cancela
  Future<File?> pickImageFromGallery({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
  });

  /// Verifica si la cámara está disponible en el dispositivo
  Future<bool> isCameraAvailable();

  /// Libera los recursos de la cámara
  Future<void> dispose();
}
