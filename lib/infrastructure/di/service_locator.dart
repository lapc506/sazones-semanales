import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:sazones_semanales/domain/services/speech_recognition_service.dart';
import 'package:sazones_semanales/infrastructure/services/speech_recognition_service_factory.dart';
import 'package:sazones_semanales/domain/services/barcode_scanner_service.dart';
import 'package:sazones_semanales/domain/services/notification_service.dart';
import 'package:sazones_semanales/infrastructure/services/barcode_scanner_service_impl.dart';
import 'package:sazones_semanales/infrastructure/services/notification_service_impl.dart';

/// Localizador de servicios para inyección de dependencias
class ServiceLocator {
  static final GetIt _instance = GetIt.instance;

  /// Inicializa todos los servicios
  static void init() {
    // Registrar servicios que no dependen del contexto
    _registerSingletons();
  }

  /// Registra servicios que dependen del contexto
  static void registerContextDependentServices(BuildContext context) {
    // Registrar el servicio de reconocimiento de voz
    if (_instance.isRegistered<SpeechRecognitionService>()) {
      _instance.unregister<SpeechRecognitionService>();
    }

    _instance.registerFactory<SpeechRecognitionService>(
      () => SpeechRecognitionServiceFactory.create(context),
    );

    // Registrar el servicio de escáner de códigos de barras
    if (_instance.isRegistered<BarcodeScannerService>()) {
      _instance.unregister<BarcodeScannerService>();
    }

    _instance.registerFactory<BarcodeScannerService>(
      () => BarcodeScannerServiceImpl(context),
    );
  }

  /// Registra servicios singleton
  static void _registerSingletons() {
    // Registrar el servicio de notificaciones como singleton
    if (!_instance.isRegistered<NotificationService>()) {
      _instance.registerLazySingleton<NotificationService>(
        () => NotificationServiceImpl(),
      );
    }

    // Otros servicios singleton
  }

  /// Obtiene una instancia de un servicio registrado
  static T get<T extends Object>() => _instance.get<T>();

  /// Comprueba si un servicio está registrado
  static bool isRegistered<T extends Object>() => _instance.isRegistered<T>();

  /// Reinicia todos los servicios registrados
  static void reset() {
    _instance.reset();
  }
}
