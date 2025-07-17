import 'package:equatable/equatable.dart';

/// Representa un comando de voz procesado para consumo de productos
class ComandoVoz extends Equatable {
  /// Texto original del comando de voz
  final String textoOriginal;
  
  /// Lista de productos mencionados en el comando
  final List<ProductoMencionado> productos;
  
  /// Nivel de confianza del reconocimiento (0.0 - 1.0)
  final double confianza;
  
  /// Indica si el comando fue reconocido correctamente
  final bool reconocidoCorrectamente;
  
  /// Timestamp del comando
  final DateTime timestamp;

  const ComandoVoz({
    required this.textoOriginal,
    required this.productos,
    required this.confianza,
    required this.reconocidoCorrectamente,
    required this.timestamp,
  });

  /// Crea una copia del comando con campos modificados
  ComandoVoz copyWith({
    String? textoOriginal,
    List<ProductoMencionado>? productos,
    double? confianza,
    bool? reconocidoCorrectamente,
    DateTime? timestamp,
  }) {
    return ComandoVoz(
      textoOriginal: textoOriginal ?? this.textoOriginal,
      productos: productos ?? this.productos,
      confianza: confianza ?? this.confianza,
      reconocidoCorrectamente: reconocidoCorrectamente ?? this.reconocidoCorrectamente,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Verifica si el comando tiene productos válidos
  bool get tieneProductosValidos => productos.isNotEmpty;

  /// Obtiene la cantidad total de productos mencionados
  int get cantidadTotalProductos {
    return productos.fold(0, (sum, producto) => sum + producto.cantidad);
  }

  @override
  List<Object?> get props => [
        textoOriginal,
        productos,
        confianza,
        reconocidoCorrectamente,
        timestamp,
      ];

  @override
  String toString() {
    return 'ComandoVoz(texto: "$textoOriginal", productos: ${productos.length}, confianza: $confianza)';
  }
}

/// Representa un producto mencionado en un comando de voz
class ProductoMencionado extends Equatable {
  /// Nombre del producto mencionado
  final String nombre;
  
  /// Cantidad mencionada (por defecto 1)
  final int cantidad;
  
  /// Unidad mencionada (opcional)
  final String? unidad;
  
  /// Nivel de confianza de este producto específico (0.0 - 1.0)
  final double confianza;
  
  /// Posición en el texto original donde se encontró
  final int posicionInicio;
  
  /// Posición final en el texto original
  final int posicionFin;

  const ProductoMencionado({
    required this.nombre,
    this.cantidad = 1,
    this.unidad,
    required this.confianza,
    required this.posicionInicio,
    required this.posicionFin,
  });

  /// Crea una copia del producto mencionado con campos modificados
  ProductoMencionado copyWith({
    String? nombre,
    int? cantidad,
    String? unidad,
    double? confianza,
    int? posicionInicio,
    int? posicionFin,
  }) {
    return ProductoMencionado(
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      unidad: unidad ?? this.unidad,
      confianza: confianza ?? this.confianza,
      posicionInicio: posicionInicio ?? this.posicionInicio,
      posicionFin: posicionFin ?? this.posicionFin,
    );
  }

  /// Verifica si el producto tiene una confianza aceptable
  bool get esConfiable => confianza >= 0.7;

  /// Obtiene la descripción completa del producto
  String get descripcionCompleta {
    final buffer = StringBuffer();
    
    if (cantidad > 1) {
      buffer.write('$cantidad ');
    }
    
    if (unidad != null) {
      buffer.write('$unidad de ');
    }
    
    buffer.write(nombre);
    
    return buffer.toString();
  }

  @override
  List<Object?> get props => [
        nombre,
        cantidad,
        unidad,
        confianza,
        posicionInicio,
        posicionFin,
      ];

  @override
  String toString() {
    return 'ProductoMencionado(nombre: $nombre, cantidad: $cantidad, confianza: $confianza)';
  }
}

/// Tipos de comandos de voz reconocidos
enum TipoComandoVoz {
  /// Comando para consumir productos
  consumir,
  
  /// Comando para buscar productos
  buscar,
  
  /// Comando para agregar productos
  agregar,
  
  /// Comando no reconocido
  desconocido,
}

/// Configuración para el reconocimiento de voz de comandos
class ConfiguracionComandoVoz extends Equatable {
  /// Idioma para el reconocimiento de voz
  final String idioma;
  
  /// Nivel mínimo de confianza aceptable (0.0 - 1.0)
  final double confianzaMinima;
  
  /// Tiempo máximo de escucha en segundos
  final int tiempoMaximoEscucha;
  
  /// Indica si debe usar reconocimiento continuo
  final bool reconocimientoContinuo;
  
  /// Palabras clave para activar comandos
  final List<String> palabrasClave;
  
  /// Sinónimos para productos comunes
  final Map<String, List<String>> sinonimos;

  const ConfiguracionComandoVoz({
    this.idioma = 'es-ES',
    this.confianzaMinima = 0.7,
    this.tiempoMaximoEscucha = 10,
    this.reconocimientoContinuo = false,
    this.palabrasClave = const ['consumir', 'gastar', 'usar', 'tomar'],
    this.sinonimos = const {},
  });

  /// Crea una copia de la configuración con campos modificados
  ConfiguracionComandoVoz copyWith({
    String? idioma,
    double? confianzaMinima,
    int? tiempoMaximoEscucha,
    bool? reconocimientoContinuo,
    List<String>? palabrasClave,
    Map<String, List<String>>? sinonimos,
  }) {
    return ConfiguracionComandoVoz(
      idioma: idioma ?? this.idioma,
      confianzaMinima: confianzaMinima ?? this.confianzaMinima,
      tiempoMaximoEscucha: tiempoMaximoEscucha ?? this.tiempoMaximoEscucha,
      reconocimientoContinuo: reconocimientoContinuo ?? this.reconocimientoContinuo,
      palabrasClave: palabrasClave ?? this.palabrasClave,
      sinonimos: sinonimos ?? this.sinonimos,
    );
  }

  /// Verifica si una palabra es una palabra clave
  bool esPalabraClave(String palabra) {
    return palabrasClave.any((clave) => 
      palabra.toLowerCase().contains(clave.toLowerCase()));
  }

  /// Obtiene sinónimos para un producto
  List<String> obtenerSinonimos(String producto) {
    return sinonimos[producto.toLowerCase()] ?? [];
  }

  @override
  List<Object?> get props => [
        idioma,
        confianzaMinima,
        tiempoMaximoEscucha,
        reconocimientoContinuo,
        palabrasClave,
        sinonimos,
      ];

  @override
  String toString() {
    return 'ConfiguracionComandoVoz(idioma: $idioma, confianza: $confianzaMinima, tiempo: ${tiempoMaximoEscucha}s)';
  }
}