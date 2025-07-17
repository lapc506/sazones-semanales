import 'package:flutter/material.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/services/notification_service.dart';
import 'package:sazones_semanales/infrastructure/services/service_providers.dart';

/// Widget de ejemplo para demostrar el uso del servicio de notificaciones
class NotificationExampleWidget extends StatefulWidget {
  const NotificationExampleWidget({super.key});

  @override
  State<NotificationExampleWidget> createState() => _NotificationExampleWidgetState();
}

class _NotificationExampleWidgetState extends State<NotificationExampleWidget> {
  late final NotificationService _notificationService;
  bool _isInitialized = false;
  String _statusMessage = 'Inicializando...';

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationServiceProvider.getService();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
      final bool hasPermission = await _notificationService.verificarPermisoNotificaciones();
      
      setState(() {
        _isInitialized = true;
        _statusMessage = hasPermission 
            ? 'Servicio de notificaciones inicializado correctamente'
            : 'Permisos de notificaciones no concedidos';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al inicializar notificaciones: $e';
      });
    }
  }

  Future<void> _solicitarPermisos() async {
    try {
      final bool result = await _notificationService.solicitarPermisoNotificaciones();
      setState(() {
        _statusMessage = result 
            ? 'Permisos concedidos'
            : 'Permisos denegados';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al solicitar permisos: $e';
      });
    }
  }

  Future<void> _enviarNotificacionInmediata() async {
    try {
      await _notificationService.enviarNotificacionInmediata(
        'Notificación de prueba',
        'Esta es una notificación de prueba enviada desde la aplicación',
        TipoNotificacion.informativa,
      );
      setState(() {
        _statusMessage = 'Notificación enviada';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al enviar notificación: $e';
      });
    }
  }

  Future<void> _programarNotificacionCaducidad() async {
    try {
      // Crear una existencia de ejemplo
      final now = DateTime.now();
      final existencia = Existencia(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        codigoBarras: '123456789',
        nombreProducto: 'Producto de prueba',
        categoria: 'Prueba',
        fechaCompra: now,
        fechaCaducidad: now.add(const Duration(seconds: 30)), // Caducará en 30 segundos
        precio: 100.0,
        proveedorId: 'proveedor_test',
        perecibilidad: TipoPerecibilidad.perecedero,
        createdAt: now,
        updatedAt: now,
      );
      
      await _notificationService.programarNotificacionCaducidad(
        existencia,
        TipoNotificacion.critica,
      );
      
      setState(() {
        _statusMessage = 'Notificación programada para 30 segundos después';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al programar notificación: $e';
      });
    }
  }

  Future<void> _cancelarTodasLasNotificaciones() async {
    try {
      await _notificationService.cancelarTodasLasNotificaciones();
      setState(() {
        _statusMessage = 'Todas las notificaciones canceladas';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al cancelar notificaciones: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo de Notificaciones'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isInitialized ? _solicitarPermisos : null,
                child: const Text('Solicitar Permisos'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _enviarNotificacionInmediata : null,
                child: const Text('Enviar Notificación Inmediata'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _programarNotificacionCaducidad : null,
                child: const Text('Programar Notificación (30s)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _cancelarTodasLasNotificaciones : null,
                child: const Text('Cancelar Todas las Notificaciones'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}