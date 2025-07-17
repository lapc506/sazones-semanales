import '../../../domain/entities/existencia.dart';
import '../../../domain/entities/proveedor.dart';
import '../../../domain/repositories/existencia_repository.dart';
import '../../../domain/repositories/proveedor_repository.dart';

/// Resultado del historial de un proveedor
class HistorialProveedorResultado {
  /// Proveedor consultado
  final Proveedor proveedor;
  
  /// Existencias compradas en este proveedor
  final List<Existencia> existencias;
  
  /// Estadísticas del proveedor
  final Map<String, dynamic> estadisticas;
  
  /// Historial de compras agrupado por fecha
  final List<Map<String, dynamic>> historialCompras;
  
  /// Productos más comprados en este proveedor
  final List<Map<String, dynamic>> productosMasComprados;

  HistorialProveedorResultado({
    required this.proveedor,
    required this.existencias,
    required this.estadisticas,
    required this.historialCompras,
    required this.productosMasComprados,
  });
}

/// Caso de uso para obtener el historial de un proveedor
class ObtenerHistorialProveedorUseCase {
  final ProveedorRepository _proveedorRepository;
  final ExistenciaRepository _existenciaRepository;

  ObtenerHistorialProveedorUseCase(
    this._proveedorRepository,
    this._existenciaRepository,
  );

  /// Ejecuta el caso de uso para obtener el historial de un proveedor
  /// 
  /// [proveedorId] es el ID del proveedor a consultar
  /// [limite] es la cantidad máxima de existencias a retornar
  /// 
  /// Retorna un [HistorialProveedorResultado] con los datos del historial
  /// o null si el proveedor no existe
  Future<HistorialProveedorResultado?> execute({
    required String proveedorId,
    int limite = 50,
  }) async {
    // Verificar que el proveedor exista
    final proveedor = await _proveedorRepository.obtenerProveedorPorId(proveedorId);
    if (proveedor == null) {
      return null;
    }

    // Obtener existencias del proveedor
    final existencias = await _existenciaRepository.obtenerExistenciasPorProveedor(proveedorId);
    
    // Obtener estadísticas del proveedor
    final estadisticas = await _proveedorRepository.obtenerEstadisticasProveedor(proveedorId);
    
    // Obtener historial de compras
    final historialCompras = await _proveedorRepository.obtenerHistorialCompras(proveedorId);
    
    // Calcular productos más comprados en este proveedor
    final productosMasComprados = _calcularProductosMasComprados(existencias);
    
    return HistorialProveedorResultado(
      proveedor: proveedor,
      existencias: existencias.take(limite).toList(),
      estadisticas: estadisticas,
      historialCompras: historialCompras,
      productosMasComprados: productosMasComprados,
    );
  }

  /// Calcula los productos más comprados en un proveedor
  List<Map<String, dynamic>> _calcularProductosMasComprados(List<Existencia> existencias) {
    // Agrupar por nombre de producto
    final contadorProductos = <String, int>{};
    final precioPromedio = <String, double>{};
    final totalGastado = <String, double>{};
    
    for (final existencia in existencias) {
      final nombreProducto = existencia.nombreProducto;
      
      // Incrementar contador
      contadorProductos[nombreProducto] = (contadorProductos[nombreProducto] ?? 0) + 1;
      
      // Sumar al gasto total
      totalGastado[nombreProducto] = (totalGastado[nombreProducto] ?? 0) + existencia.precio;
    }
    
    // Calcular precio promedio
    for (final nombre in contadorProductos.keys) {
      final cantidad = contadorProductos[nombre]!;
      final total = totalGastado[nombre]!;
      
      precioPromedio[nombre] = total / cantidad;
    }
    
    // Convertir a lista de mapas y ordenar por cantidad
    final resultado = contadorProductos.entries.map((entry) {
      final nombre = entry.key;
      final cantidad = entry.value;
      
      return {
        'nombreProducto': nombre,
        'cantidad': cantidad,
        'precioPromedio': precioPromedio[nombre],
        'totalGastado': totalGastado[nombre],
      };
    }).toList();
    
    // Ordenar por cantidad (descendente)
    resultado.sort((a, b) => (b['cantidad'] as int).compareTo(a['cantidad'] as int));
    
    return resultado;
  }

  /// Obtiene el historial de múltiples proveedores
  /// 
  /// [proveedorIds] es la lista de IDs de proveedores a consultar
  /// 
  /// Retorna un mapa donde la clave es el ID del proveedor y el valor es un [HistorialProveedorResultado]
  Future<Map<String, HistorialProveedorResultado>> executeMultiple(
    List<String> proveedorIds,
  ) async {
    final resultados = <String, HistorialProveedorResultado>{};
    
    for (final proveedorId in proveedorIds) {
      final resultado = await execute(proveedorId: proveedorId);
      if (resultado != null) {
        resultados[proveedorId] = resultado;
      }
    }
    
    return resultados;
  }
}