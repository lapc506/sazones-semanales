/// Tipos de perecibilidad de los productos
enum TipoPerecibilidad {
  /// Productos altamente perecederos (2 días de alerta)
  perecedero,
  
  /// Productos medianamente perecederos (5 días de alerta)
  semiPerecedero,
  
  /// Productos poco perecederos (15 días de alerta)
  pocoPerecedero,
  
  /// Productos no perecederos (90 días de alerta)
  noPerecedero,
}

/// Estados posibles de una existencia
enum EstadoExistencia {
  /// Existencia disponible para consumo
  disponible,
  
  /// Existencia ya consumida (archivada)
  consumida,
  
  /// Existencia caducada
  caducada,
}

/// Tipos de notificaciones del sistema
enum TipoNotificacion {
  /// Notificación crítica para productos próximos a caducar (2 días o menos)
  critica,
  
  /// Notificación de advertencia para productos próximos a caducar (5 días o menos)
  advertencia,
  
  /// Notificación de precaución para productos próximos a caducar (15 días o menos)
  precaucion,
  
  /// Notificación informativa
  informativa,
  
  /// Notificación de producto caducado
  caducado,
  
  /// Notificación de sugerencia de compras
  sugerenciaCompras,
}

/// Extensiones para TipoPerecibilidad
extension TipoPerecibilidadExtension on TipoPerecibilidad {
  /// Nombre legible del tipo de perecibilidad
  String get nombre {
    switch (this) {
      case TipoPerecibilidad.perecedero:
        return 'Altamente Perecedero';
      case TipoPerecibilidad.semiPerecedero:
        return 'Medianamente Perecedero';
      case TipoPerecibilidad.pocoPerecedero:
        return 'Poco Perecedero';
      case TipoPerecibilidad.noPerecedero:
        return 'No Perecedero';
    }
  }

  /// Días de alerta antes de la caducidad
  int get diasAlerta {
    switch (this) {
      case TipoPerecibilidad.perecedero:
        return 2;
      case TipoPerecibilidad.semiPerecedero:
        return 5;
      case TipoPerecibilidad.pocoPerecedero:
        return 15;
      case TipoPerecibilidad.noPerecedero:
        return 90;
    }
  }

  /// Color sugerido para la UI
  String get colorHex {
    switch (this) {
      case TipoPerecibilidad.perecedero:
        return '#FF5252'; // Rojo
      case TipoPerecibilidad.semiPerecedero:
        return '#FF9800'; // Naranja
      case TipoPerecibilidad.pocoPerecedero:
        return '#FFC107'; // Amarillo
      case TipoPerecibilidad.noPerecedero:
        return '#4CAF50'; // Verde
    }
  }
}

/// Extensiones para EstadoExistencia
extension EstadoExistenciaExtension on EstadoExistencia {
  /// Nombre legible del estado
  String get nombre {
    switch (this) {
      case EstadoExistencia.disponible:
        return 'Disponible';
      case EstadoExistencia.consumida:
        return 'Consumida';
      case EstadoExistencia.caducada:
        return 'Caducada';
    }
  }

  /// Icono sugerido para el estado
  String get icono {
    switch (this) {
      case EstadoExistencia.disponible:
        return '✅';
      case EstadoExistencia.consumida:
        return '🍽️';
      case EstadoExistencia.caducada:
        return '❌';
    }
  }
}

/// Extensiones para TipoNotificacion
extension TipoNotificacionExtension on TipoNotificacion {
  /// Nombre legible del tipo de notificación
  String get nombre {
    switch (this) {
      case TipoNotificacion.critica:
        return 'Crítica';
      case TipoNotificacion.advertencia:
        return 'Advertencia';
      case TipoNotificacion.precaucion:
        return 'Precaución';
      case TipoNotificacion.informativa:
        return 'Informativa';
      case TipoNotificacion.caducado:
        return 'Producto Caducado';
      case TipoNotificacion.sugerenciaCompras:
        return 'Sugerencia de Compras';
    }
  }

  /// Prioridad de la notificación (1 = más alta, 5 = más baja)
  int get prioridad {
    switch (this) {
      case TipoNotificacion.critica:
        return 1;
      case TipoNotificacion.caducado:
        return 1;
      case TipoNotificacion.advertencia:
        return 2;
      case TipoNotificacion.precaucion:
        return 3;
      case TipoNotificacion.sugerenciaCompras:
        return 4;
      case TipoNotificacion.informativa:
        return 5;
    }
  }
}