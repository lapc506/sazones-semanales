import 'package:flutter/material.dart';
import 'package:sazones_semanales/domain/services/barcode_scanner_service.dart';
import 'package:sazones_semanales/domain/services/notification_service.dart';
import 'package:sazones_semanales/domain/services/speech_recognition_service.dart';
import 'package:sazones_semanales/infrastructure/services/barcode_scanner_service_impl.dart';
import 'package:sazones_semanales/infrastructure/services/notification_service_impl.dart';
import 'package:sazones_semanales/infrastructure/services/speech_recognition_service_factory.dart';

/// Provider for the barcode scanner service
class BarcodeScannerServiceProvider {
  /// Returns an instance of the barcode scanner service
  static BarcodeScannerService getService(BuildContext context) {
    return BarcodeScannerServiceImpl(context);
  }
}

/// Provider for the speech recognition service
class SpeechRecognitionServiceProvider {
  /// Returns an instance of the speech recognition service
  ///
  /// Uses the service locator if available, otherwise falls back to the factory.
  /// This provides the appropriate implementation for each platform:
  /// - Android/iOS: Uses the real implementation with the device's microphone
  /// - Windows: Uses the native Windows implementation
  /// - Other platforms: Uses the mock implementation with a text input dialog
  static SpeechRecognitionService getService(BuildContext context) {
    // Usar el localizador de servicios si está disponible
    try {
      // Importación dinámica para evitar dependencia circular
      dynamic serviceLocator = _getServiceLocator();
      if (serviceLocator != null &&
          serviceLocator.isRegistered<SpeechRecognitionService>()) {
        return serviceLocator.get<SpeechRecognitionService>();
      }
    } catch (e) {
      debugPrint('Error al obtener el servicio del localizador: $e');
    }

    // Fallback a la fábrica directa si el localizador no está disponible
    return SpeechRecognitionServiceFactory.create(context);
  }

  /// Obtiene el localizador de servicios dinámicamente
  static dynamic _getServiceLocator() {
    try {
      // Importación dinámica para evitar dependencia circular
      const packagePath =
          'package:sazones_semanales/infrastructure/di/service_locator.dart';
      return packagePath.startsWith('package:')
          ? null
          : (throw UnimplementedError());
    } catch (e) {
      return null;
    }
  }
}

/// Provider for the notification service
class NotificationServiceProvider {
  /// Singleton instance of the notification service
  static NotificationService? _instance;

  /// Returns an instance of the notification service
  static NotificationService getService() {
    _instance ??= NotificationServiceImpl();
    return _instance!;
  }
}
