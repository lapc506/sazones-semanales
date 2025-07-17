import '../../../domain/repositories/existencia_repository.dart';

/// Resultado del cálculo de promedios de precios
class PromediosPreciosResultado {
  /// Precio promedio general del producto
  final double precioPromedio;
  
  /// Precio mínimo registrado
  final double precioMinimo;
  
  /// Precio máximo registrado
  final double precioMaximo;
  
  /// Tendencia de precios (positiva si está subiendo, negativa si está bajando)
  final double tendencia;
  
  /// Cantidad de registros analizados
  final int cantidadRegistros;
  
  /// Fecha del último registro analizado
  final DateTime? fechaUltimoRegistro;

  PromediosPreciosResultado({
    required this.precioPromedio,
    required this.precioMinimo,
    required this.precioMaximo,
    required this.tendencia,
    required this.cantidadRegistros,
    this.fechaUltimoRegistro,
  });
}

/// Caso de uso para calcular promedios de precios de productos
class CalcularPromediosPreciosUseCase {
  final ExistenciaRepository _existenciaRepository;

  CalcularPromediosPreciosUseCase(this._existenciaRepository);

  /// Ejecuta el caso de uso para calcular promedios de precios de un producto específico
  /// 
  /// [nombreProducto] es el nombre del producto a analizar
  /// 
  /// Retorna un [PromediosPreciosResultado] con los datos calculados
  Future<PromediosPreciosResultado> execute(String nombreProducto) async {
    // Obtener estadísticas de precios del repositorio
    final estadisticas = await _existenciaRepository.obtenerEstadisticasPrecios(nombreProducto);
    
    return PromediosPreciosResultado(
      precioPromedio: estadisticas['precioPromedio'] as double,
      precioMinimo: estadisticas['precioMinimo'] as double,
      precioMaximo: estadisticas['precioMaximo'] as double,
      tendencia: estadisticas['tendencia'] as double,
      cantidadRegistros: estadisticas['cantidadRegistros'] as int,
      fechaUltimoRegistro: estadisticas['fechaUltimoRegistro'] as DateTime?,
    );
  }

  /// Calcula promedios de precios para los productos más comprados
  /// 
  /// [limite] es la cantidad máxima de productos a analizar
  /// 
  /// Retorna un mapa donde la clave es el nombre del producto y el valor es un [PromediosPreciosResultado]
  Future<Map<String, PromediosPreciosResultado>> executeParaProductosMasComprados({int limite = 10}) async {
    // Obtener productos más comprados
    final productosMasComprados = await _existenciaRepository.obtenerProductosMasComprados(limite: limite);
    
    // Calcular promedios para cada producto
    final resultado = <String, PromediosPreciosResultado>{};
    for (final producto in productosMasComprados) {
      final nombreProducto = producto['nombreProducto'] as String;
      final promedios = await execute(nombreProducto);
      resultado[nombreProducto] = promedios;
    }
    
    return resultado;
  }
}