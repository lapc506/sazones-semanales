import '../../../domain/repositories/existencia_repository.dart';
import '../../../domain/repositories/proveedor_repository.dart';

/// Resultado de la comparación de precios entre proveedores
class ComparacionPreciosProveedoresResultado {
  /// Nombre del producto analizado
  final String nombreProducto;
  
  /// Mapa de proveedores con sus precios promedio
  /// La clave es el ID del proveedor y el valor es el precio promedio
  final Map<String, double> preciosPromedioPorProveedor;
  
  /// Mapa de nombres de proveedores
  /// La clave es el ID del proveedor y el valor es el nombre del proveedor
  final Map<String, String> nombresProveedores;
  
  /// ID del proveedor con el precio más bajo
  final String? proveedorMasBarato;
  
  /// ID del proveedor con el precio más alto
  final String? proveedorMasCaro;
  
  /// Diferencia porcentual entre el precio más alto y el más bajo
  final double? diferenciaProcentual;

  ComparacionPreciosProveedoresResultado({
    required this.nombreProducto,
    required this.preciosPromedioPorProveedor,
    required this.nombresProveedores,
    this.proveedorMasBarato,
    this.proveedorMasCaro,
    this.diferenciaProcentual,
  });
}

/// Caso de uso para comparar precios de productos entre diferentes proveedores
class CompararPreciosProveedoresUseCase {
  final ExistenciaRepository _existenciaRepository;
  final ProveedorRepository _proveedorRepository;

  CompararPreciosProveedoresUseCase(
    this._existenciaRepository,
    this._proveedorRepository,
  );

  /// Ejecuta el caso de uso para comparar precios de un producto entre proveedores
  /// 
  /// [nombreProducto] es el nombre del producto a analizar
  /// 
  /// Retorna un [ComparacionPreciosProveedoresResultado] con los datos calculados
  Future<ComparacionPreciosProveedoresResultado> execute(String nombreProducto) async {
    // Obtener historial de precios del producto
    final historialPrecios = await _existenciaRepository.obtenerHistorialPrecios(nombreProducto);
    
    // Agrupar por proveedor y calcular promedios
    final preciosPorProveedor = <String, List<double>>{};
    for (final registro in historialPrecios) {
      final proveedorId = registro['proveedorId'] as String;
      final precio = registro['precio'] as double;
      
      if (!preciosPorProveedor.containsKey(proveedorId)) {
        preciosPorProveedor[proveedorId] = [];
      }
      
      preciosPorProveedor[proveedorId]!.add(precio);
    }
    
    // Calcular precios promedio por proveedor
    final preciosPromedio = <String, double>{};
    for (final entry in preciosPorProveedor.entries) {
      final proveedorId = entry.key;
      final precios = entry.value;
      
      final promedio = precios.reduce((a, b) => a + b) / precios.length;
      preciosPromedio[proveedorId] = promedio;
    }
    
    // Obtener nombres de proveedores
    final nombresProveedores = <String, String>{};
    for (final proveedorId in preciosPromedio.keys) {
      final proveedor = await _proveedorRepository.obtenerProveedorPorId(proveedorId);
      if (proveedor != null) {
        nombresProveedores[proveedorId] = proveedor.nombre;
      }
    }
    
    // Encontrar proveedor más barato y más caro
    String? proveedorMasBarato;
    String? proveedorMasCaro;
    double? precioMinimo;
    double? precioMaximo;
    
    for (final entry in preciosPromedio.entries) {
      final proveedorId = entry.key;
      final precio = entry.value;
      
      if (precioMinimo == null || precio < precioMinimo) {
        precioMinimo = precio;
        proveedorMasBarato = proveedorId;
      }
      
      if (precioMaximo == null || precio > precioMaximo) {
        precioMaximo = precio;
        proveedorMasCaro = proveedorId;
      }
    }
    
    // Calcular diferencia porcentual
    double? diferenciaProcentual;
    if (precioMinimo != null && precioMaximo != null && precioMinimo > 0) {
      diferenciaProcentual = ((precioMaximo - precioMinimo) / precioMinimo) * 100;
    }
    
    return ComparacionPreciosProveedoresResultado(
      nombreProducto: nombreProducto,
      preciosPromedioPorProveedor: preciosPromedio,
      nombresProveedores: nombresProveedores,
      proveedorMasBarato: proveedorMasBarato,
      proveedorMasCaro: proveedorMasCaro,
      diferenciaProcentual: diferenciaProcentual,
    );
  }

  /// Ejecuta el caso de uso para comparar precios de múltiples productos entre proveedores
  /// 
  /// [nombresProductos] es la lista de nombres de productos a analizar
  /// 
  /// Retorna un mapa donde la clave es el nombre del producto y el valor es un [ComparacionPreciosProveedoresResultado]
  Future<Map<String, ComparacionPreciosProveedoresResultado>> executeMultiple(
    List<String> nombresProductos,
  ) async {
    final resultados = <String, ComparacionPreciosProveedoresResultado>{};
    
    for (final nombreProducto in nombresProductos) {
      final resultado = await execute(nombreProducto);
      resultados[nombreProducto] = resultado;
    }
    
    return resultados;
  }
}