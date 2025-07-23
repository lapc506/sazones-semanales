import 'package:flutter/material.dart';
import 'package:sazones_semanales/core/config/platform_config.dart';
import 'package:sazones_semanales/domain/services/speech_recognition_service.dart';
import 'package:sazones_semanales/infrastructure/services/speech_recognition_service_impl.dart';
import 'package:sazones_semanales/infrastructure/services/speech_recognition_service_mock.dart';
import 'package:sazones_semanales/infrastructure/services/speech_recognition_whisper_impl.dart';
import 'package:sazones_semanales/infrastructure/services/speech_recognition_cloud_impl.dart';
// Eliminada la importación de Windows Speech Recognition
import 'dart:io' show Platform;

/// Tipo de implementación de reconocimiento de voz
enum SpeechRecognitionImplementation {
  /// Implementación nativa para móviles (Android/iOS)
  mobile,

  /// Implementación de whisper.cpp
  whisper,

  /// Implementación en la nube (OpenAI API)
  cloud,

  /// Implementación simulada
  mock
}

/// Fábrica para crear instancias del servicio de reconocimiento de voz
class SpeechRecognitionServiceFactory {
  /// Implementación actual
  static SpeechRecognitionImplementation _currentImplementation =
      _getDefaultImplementation();

  /// Obtiene la implementación predeterminada según la plataforma
  static SpeechRecognitionImplementation _getDefaultImplementation() {
    if (Platform.isAndroid || Platform.isIOS) {
      return SpeechRecognitionImplementation.mobile;
    } else if (Platform.isWindows) {
      return SpeechRecognitionImplementation
          .whisper; // Cambiado a whisper por defecto
    } else {
      return SpeechRecognitionImplementation.mock;
    }
  }

  /// Establece la implementación actual
  static void setImplementation(
      SpeechRecognitionImplementation implementation) {
    _currentImplementation = implementation;
  }

  /// Obtiene la implementación actual
  static SpeechRecognitionImplementation getImplementation() {
    return _currentImplementation;
  }

  /// Crea una instancia del servicio de reconocimiento de voz según la implementación actual
  static SpeechRecognitionService create(BuildContext context) {
    // Obtener la configuración de la plataforma

    // Verificar si se debe usar whisper.cpp y si los archivos están disponibles
    if (_currentImplementation == SpeechRecognitionImplementation.whisper) {
      // Verificar si los archivos están disponibles de forma asíncrona
      // y usar el fallback si es necesario
      _checkWhisperFilesAndFallback(context);
    }

    switch (_currentImplementation) {
      case SpeechRecognitionImplementation.mobile:
        if (Platform.isAndroid || Platform.isIOS) {
          return SpeechRecognitionServiceImpl(context);
        } else {
          // Fallback para plataformas no móviles
          return SpeechRecognitionServiceMock(context);
        }

      case SpeechRecognitionImplementation.whisper:
        // Whisper.cpp puede funcionar en cualquier plataforma de escritorio
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          return SpeechRecognitionWhisperImpl(context);
        } else {
          // Fallback para plataformas móviles o web
          return SpeechRecognitionServiceMock(context);
        }

      case SpeechRecognitionImplementation.cloud:
        // La API en la nube puede funcionar en cualquier plataforma
        return SpeechRecognitionCloudImpl(context);

      case SpeechRecognitionImplementation.mock:
        return SpeechRecognitionServiceMock(context);
    }
  }

  /// Verifica si los archivos de whisper.cpp están disponibles y usa el fallback si es necesario
  static Future<void> _checkWhisperFilesAndFallback(
      BuildContext context) async {
    final platformConfig = PlatformConfig();

    // Verificar si los archivos están disponibles
    final modelAvailable = await platformConfig.isWhisperModelAvailable();
    final binaryAvailable = await platformConfig.isWhisperBinaryAvailable();

    // Si los archivos no están disponibles y se ha configurado el fallback
    if ((!modelAvailable || !binaryAvailable) &&
        platformConfig.useCloudFallback) {
      // Cambiar a la implementación en la nube
      _currentImplementation = SpeechRecognitionImplementation.cloud;
    }
  }
}
