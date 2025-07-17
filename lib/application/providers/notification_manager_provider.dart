import 'package:flutter/material.dart';
import 'package:sazones_semanales/application/services/notification_manager_service.dart';
import 'package:sazones_semanales/domain/repositories/existencia_repository.dart';
import 'package:sazones_semanales/infrastructure/repositories/repository_providers.dart';

/// Provider para el servicio de gestión de notificaciones
class NotificationManagerProvider {
  static NotificationManagerService? _instance;
  
  /// Obtiene una instancia del servicio de gestión de notificaciones
  static NotificationManagerService getService(BuildContext context) {
    if (_instance == null) {
      final ExistenciaRepository existenciaRepository = 
          RepositoryProviders.getExistenciaRepository(context);
      
      _instance = NotificationManagerService(existenciaRepository);
    }
    
    return _instance!;
  }
}