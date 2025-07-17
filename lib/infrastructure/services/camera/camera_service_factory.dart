import 'dart:io';
import 'camera_service.dart';
import 'camera_service_mobile.dart';
import 'camera_service_windows.dart';

/// Factory para crear la implementación adecuada de CameraService según la plataforma
class CameraServiceFactory {
  /// Obtiene la implementación de CameraService adecuada para la plataforma actual
  static CameraService getCameraService() {
    if (Platform.isWindows) {
      return CameraServiceWindows();
    } else {
      return CameraServiceMobile();
    }
  }
}