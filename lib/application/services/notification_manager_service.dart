import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/repositories/existencia_repository.dart';
import 'package:sazones_semanales/domain/services/notification_service.dart';
import 'package:sazones_semanales/infrastructure/services/service_providers.dart';

/// Servicio de aplicación para gestionar notificaciones de caducidad
class NotificationManagerService {
  final NotificationService _notificationService;
  final ExistenciaRepository _existenciaRepository;

  /// Constructor del servicio de gestión de notificaciones
  NotificationManagerService(this._existenciaRepository)
      : _notificationService = NotificationServiceProvider.getService();

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    await _notificationService.initialize();
    await _notificationService.verificarPermisoNotificaciones();
  }

  /// Actualiza todas las notificaciones programadas
  ///
  /// Este método debe ser llamado después de cada cambio en el inventario
  /// o periódicamente para asegurar que las notificaciones estén actualizadas
  Future<void> actualizarTodasLasNotificaciones() async {
    // Obtener todas las existencias activas
    final existencias = await _existenciaRepository.obtenerExistenciasActivas();

    // Programar notificaciones para todas las existencias
    await _notificationService
        .programarNotificacionesParaTodasLasExistencias(existencias);
  }

  /// Programa una notificación para una existencia específica
  ///
  /// Este método debe ser llamado cuando se agrega una nueva existencia
  Future<void> programarNotificacionParaExistencia(
      Existencia existencia) async {
    // Determinar el tipo de notificación según la perecibilidad
    if (existencia.fechaCaducidad == null) return;

    // Programar la notificación
    await _notificationService.programarNotificacionCaducidad(
      existencia,
      _determinarTipoNotificacion(existencia),
    );
  }

  /// Cancela todas las notificaciones programadas
  Future<void> cancelarTodasLasNotificaciones() async {
    await _notificationService.cancelarTodasLasNotificaciones();
  }

  /// Determina el tipo de notificación según la perecibilidad y días restantes
  TipoNotificacion _determinarTipoNotificacion(Existencia existencia) {
    if (existencia.fechaCaducidad == null) {
      return TipoNotificacion.informativa;
    }

    // Si ya caducó
    if (existencia.haCaducado) {
      return TipoNotificacion.caducado;
    }

    final int diasRestantes =
        existencia.fechaCaducidad!.difference(DateTime.now()).inDays;

    // Determinar tipo según perecibilidad
    switch (existencia.perecibilidad) {
      case TipoPerecibilidad.perecedero:
        if (diasRestantes <= 2) return TipoNotificacion.critica;
        break;
      case TipoPerecibilidad.semiPerecedero:
        if (diasRestantes <= 5) return TipoNotificacion.advertencia;
        break;
      case TipoPerecibilidad.pocoPerecedero:
        if (diasRestantes <= 15) return TipoNotificacion.precaucion;
        break;
      case TipoPerecibilidad.noPerecedero:
        if (diasRestantes <= 90) return TipoNotificacion.informativa;
        break;
    }

    return TipoNotificacion.informativa;
  }
}
