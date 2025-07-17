import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Implementación del servicio de notificaciones usando flutter_local_notifications
class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  
  /// Constructor del servicio de notificaciones
  NotificationServiceImpl() : _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  @override
  Future<void> initialize() async {
    // Inicializar timezone
    tz.initializeTimeZones();
    
    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuración para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    // Configuración general
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    // Inicializar el plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  /// Maneja el tap en una notificación
  void _onNotificationTapped(NotificationResponse response) {
    // Aquí se puede implementar la navegación a la pantalla correspondiente
    // cuando el usuario toca una notificación
    debugPrint('Notificación tocada: ${response.payload}');
  }
  
  @override
  Future<void> programarNotificacionCaducidad(Existencia existencia, TipoNotificacion tipo) async {
    if (existencia.fechaCaducidad == null) return;
    
    // Generar un ID único para la notificación basado en el ID de la existencia
    final int notificationId = existencia.id.hashCode;
    
    // Determinar la fecha de la notificación según el tipo de perecibilidad
    final DateTime fechaNotificacion = _calcularFechaNotificacion(existencia);
    
    // Si la fecha de notificación ya pasó, no programar
    if (fechaNotificacion.isBefore(DateTime.now())) return;
    
    // Configurar detalles según el tipo de notificación
    final NotificationDetails detalles = _obtenerDetallesNotificacion(tipo);
    
    // Título y mensaje de la notificación
    final String titulo = _obtenerTituloNotificacion(tipo);
    final String mensaje = _obtenerMensajeNotificacion(existencia, tipo);
    
    // Programar la notificación
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      titulo,
      mensaje,
      tz.TZDateTime.from(fechaNotificacion, tz.local),
      detalles,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: existencia.id,
    );
    
    debugPrint('Notificación programada para ${existencia.nombreProducto} el ${fechaNotificacion.toString()}');
  }
  
  @override
  Future<void> programarNotificacionesParaTodasLasExistencias(List<Existencia> existencias) async {
    // Primero cancelamos todas las notificaciones existentes
    await cancelarTodasLasNotificaciones();
    
    // Programamos nuevas notificaciones para cada existencia disponible
    for (final existencia in existencias) {
      if (existencia.estado != EstadoExistencia.disponible) continue;
      if (existencia.fechaCaducidad == null) continue;
      
      // Determinar el tipo de notificación según la perecibilidad y días restantes
      final TipoNotificacion tipo = _determinarTipoNotificacion(existencia);
      
      // Programar la notificación
      await programarNotificacionCaducidad(existencia, tipo);
    }
  }
  
  @override
  Future<void> enviarNotificacionInmediata(String titulo, String mensaje, TipoNotificacion tipo) async {
    final NotificationDetails detalles = _obtenerDetallesNotificacion(tipo);
    
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      titulo,
      mensaje,
      detalles,
    );
  }
  
  @override
  Future<void> cancelarTodasLasNotificaciones() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
  
  @override
  Future<void> cancelarNotificacion(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
  
  @override
  Future<bool> verificarPermisoNotificaciones() async {
    // En Android, los permisos se otorgan automáticamente
    // En iOS, necesitamos verificar
    final bool? result = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    return result ?? true;
  }
  
  @override
  Future<bool> solicitarPermisoNotificaciones() async {
    // En Android, los permisos se otorgan automáticamente
    // En iOS, necesitamos solicitarlos
    final bool? result = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    return result ?? true;
  }
  
  /// Calcula la fecha en que se debe enviar la notificación
  DateTime _calcularFechaNotificacion(Existencia existencia) {
    if (existencia.fechaCaducidad == null) {
      return DateTime.now();
    }
    
    // Si ya caducó, no programar notificación
    if (existencia.haCaducado) {
      return DateTime.now();
    }
    
    // Calcular días de alerta según perecibilidad
    final int diasAlerta = existencia.perecibilidad.diasAlerta;
    
    // Calcular fecha de notificación
    final DateTime fechaNotificacion = existencia.fechaCaducidad!.subtract(Duration(days: diasAlerta));
    
    // Si la fecha de notificación ya pasó, programar para ahora
    if (fechaNotificacion.isBefore(DateTime.now())) {
      return DateTime.now();
    }
    
    return fechaNotificacion;
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
    
    final int diasRestantes = existencia.fechaCaducidad!.difference(DateTime.now()).inDays;
    
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
  
  /// Obtiene los detalles de la notificación según el tipo
  NotificationDetails _obtenerDetallesNotificacion(TipoNotificacion tipo) {
    // Configuración para Android
    AndroidNotificationDetails androidDetails;
    
    switch (tipo) {
      case TipoNotificacion.critica:
        androidDetails = const AndroidNotificationDetails(
          'caducidad_critica',
          'Caducidad Crítica',
          channelDescription: 'Notificaciones para productos que caducan en 2 días o menos',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFFFF5252),
          category: AndroidNotificationCategory.alarm,
        );
        break;
      case TipoNotificacion.advertencia:
        androidDetails = const AndroidNotificationDetails(
          'caducidad_advertencia',
          'Caducidad Advertencia',
          channelDescription: 'Notificaciones para productos que caducan en 5 días o menos',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFFFF9800),
          category: AndroidNotificationCategory.reminder,
        );
        break;
      case TipoNotificacion.precaucion:
        androidDetails = const AndroidNotificationDetails(
          'caducidad_precaucion',
          'Caducidad Precaución',
          channelDescription: 'Notificaciones para productos que caducan en 15 días o menos',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          color: Color(0xFFFFC107),
          category: AndroidNotificationCategory.reminder,
        );
        break;
      case TipoNotificacion.caducado:
        androidDetails = const AndroidNotificationDetails(
          'caducidad_caducado',
          'Producto Caducado',
          channelDescription: 'Notificaciones para productos que ya han caducado',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF000000),
          category: AndroidNotificationCategory.alarm,
        );
        break;
      case TipoNotificacion.informativa:
      case TipoNotificacion.sugerenciaCompras:
      default:
        androidDetails = const AndroidNotificationDetails(
          'general',
          'General',
          channelDescription: 'Notificaciones generales',
          importance: Importance.low,
          priority: Priority.low,
          color: Color(0xFF4CAF50),
          category: AndroidNotificationCategory.reminder,
        );
        break;
    }
    
    // Configuración para iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }
  
  /// Obtiene el título de la notificación según el tipo
  String _obtenerTituloNotificacion(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.critica:
        return '¡Atención! Producto próximo a caducar';
      case TipoNotificacion.advertencia:
        return 'Advertencia: Producto próximo a caducar';
      case TipoNotificacion.precaucion:
        return 'Precaución: Producto caducará pronto';
      case TipoNotificacion.caducado:
        return '¡Producto caducado!';
      case TipoNotificacion.sugerenciaCompras:
        return 'Sugerencia de compras';
      case TipoNotificacion.informativa:
      default:
        return 'Información de inventario';
    }
  }
  
  /// Obtiene el mensaje de la notificación según el tipo y la existencia
  String _obtenerMensajeNotificacion(Existencia existencia, TipoNotificacion tipo) {
    if (existencia.fechaCaducidad == null) {
      return 'El producto ${existencia.nombreProducto} no tiene fecha de caducidad registrada.';
    }
    
    final int diasRestantes = existencia.fechaCaducidad!.difference(DateTime.now()).inDays;
    
    switch (tipo) {
      case TipoNotificacion.critica:
        return '${existencia.nombreProducto} caducará en $diasRestantes días. ¡Consúmelo pronto!';
      case TipoNotificacion.advertencia:
        return '${existencia.nombreProducto} caducará en $diasRestantes días. Planifica su consumo.';
      case TipoNotificacion.precaucion:
        return '${existencia.nombreProducto} caducará en $diasRestantes días.';
      case TipoNotificacion.caducado:
        return '${existencia.nombreProducto} ha caducado. Revisa si aún es apto para consumo o deséchalo.';
      case TipoNotificacion.informativa:
      case TipoNotificacion.sugerenciaCompras:
      default:
        return '${existencia.nombreProducto} caducará el ${existencia.fechaCaducidad!.day}/${existencia.fechaCaducidad!.month}/${existencia.fechaCaducidad!.year}.';
    }
  }
}