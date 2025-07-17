import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Configuración general de la aplicación
class ConfiguracionApp extends Equatable {
  /// Configuración de notificaciones
  final ConfiguracionNotificaciones notificaciones;
  
  /// Configuración de reconocimiento de voz
  final ConfiguracionVoz voz;
  
  /// Configuración de modos especializados
  final ConfiguracionModos modos;
  
  /// Configuración de usuario
  final ConfiguracionUsuario usuario;
  
  /// Configuración de sugerencias de compras
  final ConfiguracionSugerencias sugerencias;

  const ConfiguracionApp({
    required this.notificaciones,
    required this.voz,
    required this.modos,
    required this.usuario,
    required this.sugerencias,
  });

  /// Crea una configuración por defecto
  factory ConfiguracionApp.porDefecto() {
    return ConfiguracionApp(
      notificaciones: ConfiguracionNotificaciones.porDefecto(),
      voz: ConfiguracionVoz.porDefecto(),
      modos: ConfiguracionModos.porDefecto(),
      usuario: ConfiguracionUsuario.porDefecto(),
      sugerencias: ConfiguracionSugerencias.porDefecto(),
    );
  }

  /// Crea una copia de la configuración con campos modificados
  ConfiguracionApp copyWith({
    ConfiguracionNotificaciones? notificaciones,
    ConfiguracionVoz? voz,
    ConfiguracionModos? modos,
    ConfiguracionUsuario? usuario,
    ConfiguracionSugerencias? sugerencias,
  }) {
    return ConfiguracionApp(
      notificaciones: notificaciones ?? this.notificaciones,
      voz: voz ?? this.voz,
      modos: modos ?? this.modos,
      usuario: usuario ?? this.usuario,
      sugerencias: sugerencias ?? this.sugerencias,
    );
  }

  @override
  List<Object?> get props => [
        notificaciones,
        voz,
        modos,
        usuario,
        sugerencias,
      ];
}

/// Configuración de notificaciones
class ConfiguracionNotificaciones extends Equatable {
  /// Indica si las notificaciones están habilitadas
  final bool habilitadas;
  
  /// Horario de inicio para notificaciones
  final TimeOfDay horaInicio;
  
  /// Horario de fin para notificaciones
  final TimeOfDay horaFin;
  
  /// Configuración específica por tipo de perecibilidad
  final Map<TipoPerecibilidad, ConfiguracionNotificacionTipo> configuracionPorTipo;
  
  /// Días de la semana para notificaciones
  final List<int> diasSemana; // 1 = Lunes, 7 = Domingo

  const ConfiguracionNotificaciones({
    required this.habilitadas,
    required this.horaInicio,
    required this.horaFin,
    required this.configuracionPorTipo,
    required this.diasSemana,
  });

  /// Crea una configuración por defecto
  factory ConfiguracionNotificaciones.porDefecto() {
    return ConfiguracionNotificaciones(
      habilitadas: true,
      horaInicio: const TimeOfDay(hour: 8, minute: 0),
      horaFin: const TimeOfDay(hour: 20, minute: 0),
      configuracionPorTipo: {
        TipoPerecibilidad.perecedero: ConfiguracionNotificacionTipo.porDefecto(TipoPerecibilidad.perecedero),
        TipoPerecibilidad.semiPerecedero: ConfiguracionNotificacionTipo.porDefecto(TipoPerecibilidad.semiPerecedero),
        TipoPerecibilidad.pocoPerecedero: ConfiguracionNotificacionTipo.porDefecto(TipoPerecibilidad.pocoPerecedero),
        TipoPerecibilidad.noPerecedero: ConfiguracionNotificacionTipo.porDefecto(TipoPerecibilidad.noPerecedero),
      },
      diasSemana: [1, 2, 3, 4, 5, 6, 7], // Todos los días
    );
  }

  /// Verifica si las notificaciones están activas en un momento dado
  bool estaActivaEn(DateTime momento) {
    if (!habilitadas) return false;
    
    final diaSemana = momento.weekday;
    if (!diasSemana.contains(diaSemana)) return false;
    
    final hora = TimeOfDay.fromDateTime(momento);
    return _estaEnRangoHorario(hora);
  }

  bool _estaEnRangoHorario(TimeOfDay hora) {
    final minutosDia = hora.hour * 60 + hora.minute;
    final minutosInicio = horaInicio.hour * 60 + horaInicio.minute;
    final minutosFin = horaFin.hour * 60 + horaFin.minute;
    
    if (minutosInicio <= minutosFin) {
      // Rango normal (ej: 8:00 - 20:00)
      return minutosDia >= minutosInicio && minutosDia <= minutosFin;
    } else {
      // Rango que cruza medianoche (ej: 20:00 - 8:00)
      return minutosDia >= minutosInicio || minutosDia <= minutosFin;
    }
  }

  @override
  List<Object?> get props => [
        habilitadas,
        horaInicio,
        horaFin,
        configuracionPorTipo,
        diasSemana,
      ];
}

/// Configuración de notificaciones por tipo de perecibilidad
class ConfiguracionNotificacionTipo extends Equatable {
  /// Tipo de perecibilidad
  final TipoPerecibilidad tipo;
  
  /// Indica si está habilitada para este tipo
  final bool habilitada;
  
  /// Días de anticipación para la notificación
  final int diasAnticipacion;
  
  /// Mensaje personalizado (opcional)
  final String? mensajePersonalizado;

  const ConfiguracionNotificacionTipo({
    required this.tipo,
    required this.habilitada,
    required this.diasAnticipacion,
    this.mensajePersonalizado,
  });

  /// Crea una configuración por defecto para un tipo
  factory ConfiguracionNotificacionTipo.porDefecto(TipoPerecibilidad tipo) {
    return ConfiguracionNotificacionTipo(
      tipo: tipo,
      habilitada: true,
      diasAnticipacion: tipo.diasAlerta,
    );
  }

  @override
  List<Object?> get props => [
        tipo,
        habilitada,
        diasAnticipacion,
        mensajePersonalizado,
      ];
}

/// Configuración de reconocimiento de voz
class ConfiguracionVoz extends Equatable {
  /// Indica si el reconocimiento de voz está habilitado
  final bool habilitado;
  
  /// Idioma para el reconocimiento
  final String idioma;
  
  /// Nivel mínimo de confianza
  final double confianzaMinima;
  
  /// Tiempo máximo de escucha en segundos
  final int tiempoMaximoEscucha;
  
  /// Palabras clave para activar comandos
  final List<String> palabrasClave;

  const ConfiguracionVoz({
    required this.habilitado,
    required this.idioma,
    required this.confianzaMinima,
    required this.tiempoMaximoEscucha,
    required this.palabrasClave,
  });

  /// Crea una configuración por defecto
  factory ConfiguracionVoz.porDefecto() {
    return const ConfiguracionVoz(
      habilitado: true,
      idioma: 'es-ES',
      confianzaMinima: 0.7,
      tiempoMaximoEscucha: 10,
      palabrasClave: ['consumir', 'gastar', 'usar', 'tomar'],
    );
  }

  @override
  List<Object?> get props => [
        habilitado,
        idioma,
        confianzaMinima,
        tiempoMaximoEscucha,
        palabrasClave,
      ];
}

/// Configuración de modos especializados
class ConfiguracionModos extends Equatable {
  /// Modos activos
  final List<String> modosActivos;
  
  /// Configuración específica por modo
  final Map<String, Map<String, dynamic>> configuracionPorModo;

  const ConfiguracionModos({
    required this.modosActivos,
    required this.configuracionPorModo,
  });

  /// Crea una configuración por defecto
  factory ConfiguracionModos.porDefecto() {
    return const ConfiguracionModos(
      modosActivos: [],
      configuracionPorModo: {},
    );
  }

  /// Verifica si un modo está activo
  bool estaActivo(String modo) {
    return modosActivos.contains(modo);
  }

  /// Obtiene la configuración de un modo específico
  Map<String, dynamic> obtenerConfiguracion(String modo) {
    return configuracionPorModo[modo] ?? {};
  }

  @override
  List<Object?> get props => [
        modosActivos,
        configuracionPorModo,
      ];
}

/// Configuración de usuario
class ConfiguracionUsuario extends Equatable {
  /// Restricciones alimentarias del usuario
  final List<String> restriccionesAlimentarias;
  
  /// Categorías personalizadas
  final List<String> categoriasPersonalizadas;
  
  /// Preferencias de la aplicación
  final Map<String, dynamic> preferencias;

  const ConfiguracionUsuario({
    required this.restriccionesAlimentarias,
    required this.categoriasPersonalizadas,
    required this.preferencias,
  });

  /// Crea una configuración por defecto
  factory ConfiguracionUsuario.porDefecto() {
    return const ConfiguracionUsuario(
      restriccionesAlimentarias: [],
      categoriasPersonalizadas: [],
      preferencias: {},
    );
  }

  @override
  List<Object?> get props => [
        restriccionesAlimentarias,
        categoriasPersonalizadas,
        preferencias,
      ];
}

/// Configuración de sugerencias de compras
class ConfiguracionSugerencias extends Equatable {
  /// Indica si las sugerencias están habilitadas
  final bool habilitadas;
  
  /// Frecuencia de sugerencias en días
  final int frecuenciaDias;
  
  /// Día del mes para sugerencias (para usuarios con pago mensual)
  final int? diaMesSugerencia;
  
  /// Considera patrones históricos
  final bool considerarPatrones;

  const ConfiguracionSugerencias({
    required this.habilitadas,
    required this.frecuenciaDias,
    this.diaMesSugerencia,
    required this.considerarPatrones,
  });

  /// Crea una configuración por defecto
  factory ConfiguracionSugerencias.porDefecto() {
    return const ConfiguracionSugerencias(
      habilitadas: true,
      frecuenciaDias: 15,
      considerarPatrones: true,
    );
  }

  @override
  List<Object?> get props => [
        habilitadas,
        frecuenciaDias,
        diaMesSugerencia,
        considerarPatrones,
      ];
}

/// Clase auxiliar para representar hora del día
class TimeOfDay extends Equatable {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  @override
  List<Object?> get props => [hour, minute];

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}