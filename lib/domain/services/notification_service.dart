import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';

/// Servicio para gestionar notificaciones locales
abstract class NotificationService {
  /// Inicializa el servicio de notificaciones
  Future<void> initialize();
  
  /// Programa una notificación para una existencia próxima a caducar
  /// 
  /// [existencia] La existencia para la que se programa la notificación
  /// [tipo] El tipo de notificación a programar
  Future<void> programarNotificacionCaducidad(Existencia existencia, TipoNotificacion tipo);
  
  /// Programa notificaciones para todas las existencias activas
  /// 
  /// Este método debe ser llamado después de cada cambio en el inventario
  /// o periódicamente para asegurar que las notificaciones estén actualizadas
  Future<void> programarNotificacionesParaTodasLasExistencias(List<Existencia> existencias);
  
  /// Envía una notificación inmediata
  /// 
  /// [titulo] El título de la notificación
  /// [mensaje] El mensaje de la notificación
  /// [tipo] El tipo de notificación
  Future<void> enviarNotificacionInmediata(String titulo, String mensaje, TipoNotificacion tipo);
  
  /// Cancela todas las notificaciones programadas
  Future<void> cancelarTodasLasNotificaciones();
  
  /// Cancela una notificación específica
  /// 
  /// [id] El ID de la notificación a cancelar
  Future<void> cancelarNotificacion(int id);
  
  /// Verifica si las notificaciones están habilitadas
  Future<bool> verificarPermisoNotificaciones();
  
  /// Solicita permiso para enviar notificaciones
  Future<bool> solicitarPermisoNotificaciones();
}