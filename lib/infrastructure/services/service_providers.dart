import 'package:flutter/material.dart';
import 'package:sazones_semanales/domain/services/barcode_scanner_service.dart';
import 'package:sazones_semanales/domain/services/notification_service.dart';
import 'package:sazones_semanales/domain/services/speech_recognition_service.dart';
import 'package:sazones_semanales/infrastructure/services/barcode_scanner_service_impl.dart';
import 'package:sazones_semanales/infrastructure/services/notification_service_impl.dart';
import 'package:sazones_semanales/infrastructure/services/speech_recognition_service_mock.dart';

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
  /// IMPORTANT: We're currently using the mock implementation instead of the real
  /// speech_to_text package implementation due to the following issues:
  ///
  /// 1. There are compatibility issues with the speech_to_text package and our current
  ///    Flutter/Dart environment. Despite being listed in pubspec.yaml, the package
  ///    is not being properly installed or recognized.
  ///
  /// 2. The mock implementation allows development and testing to continue without
  ///    being blocked by these package installation issues.
  ///
  /// 3. The mock simulates speech recognition by showing a text input dialog,
  ///    which is then processed by the same parsing logic that would handle
  ///    actual speech recognition results.
  ///
  /// TODO:
  /// When the speech_to_text package installation issues are resolved,
  /// replace this with the real implementation (SpeechRecognitionServiceImpl).
  /// This will require:
  /// - Ensuring the package is properly installed
  /// - Updating this provider to return SpeechRecognitionServiceImpl
  /// - Testing with actual microphone input
  static SpeechRecognitionService getService(BuildContext context) {
    return SpeechRecognitionServiceMock(context);
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
