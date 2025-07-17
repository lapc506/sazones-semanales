import 'package:flutter/material.dart';
import 'package:sazones_semanales/application/providers/notification_manager_provider.dart';
import 'package:sazones_semanales/application/services/notification_manager_service.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';

/// Caso de uso para programar notificaciones de caducidad
class ProgramarNotificacionesUseCase {
  final NotificationManagerService _notificationManagerService;
  
  /// Constructor del caso de uso
  ProgramarNotificacionesUseCase(BuildContext context)
      : _notificationManagerService = NotificationManagerProvider.getService(context);
  
  /// Programa notificaciones para todas las existencias activas
  Future<void> programarNotificacionesParaTodasLasExistencias() async {
    await _notificationManagerService.actualizarTodasLasNotificaciones();
  }
  
  /// Programa una notificación para una existencia específica
  Future<void> programarNotificacionParaExistencia(Existencia existencia) async {
    await _notificationManagerService.programarNotificacionParaExistencia(existencia);
  }
  
  /// Inicializa el servicio de notificaciones
  Future<void> inicializarServicioNotificaciones() async {
    await _notificationManagerService.initialize();
  }
  
  /// Cancela todas las notificaciones programadas
  Future<void> cancelarTodasLasNotificaciones() async {
    await _notificationManagerService.cancelarTodasLasNotificaciones();
  }
}