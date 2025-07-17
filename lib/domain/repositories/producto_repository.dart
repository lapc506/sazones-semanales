import '../entities/producto_base.dart';
import '../entities/enums.dart';

/// Repositorio abstracto para gestionar productos base
abstract class ProductoRepository {
  /// Busca un producto base por código de barras
  Future<ProductoBase?> buscarPorCodigoBarras(String codigoBarras);
  
  /// Obtiene todos los productos base
  Future<List<ProductoBase>> obtenerTodosLosProductos();
  
  /// Busca productos por nombre (para autocompletado)
  Future<List<String>> obtenerSugerenciasAutocompletado(String query, {int limite = 10});
  
  /// Busca productos base por nombre
  Future<List<ProductoBase>> buscarPorNombre(String nombre);
  
  /// Obtiene productos por categoría
  Future<List<ProductoBase>> obtenerProductosPorCategoria(String categoria);
  
  /// Obtiene productos por tipo de perecibilidad
  Future<List<ProductoBase>> obtenerProductosPorPerecibilidad(TipoPerecibilidad perecibilidad);
  
  /// Obtiene productos con restricciones alimentarias específicas
  Future<List<ProductoBase>> obtenerProductosConRestricciones(List<String> restricciones);
  
  /// Obtiene productos compatibles con restricciones alimentarias
  Future<List<ProductoBase>> obtenerProductosCompatibles(List<String> restriccionesUsuario);
  
  /// Guarda un nuevo producto base
  Future<void> guardarProductoBase(ProductoBase producto);
  
  /// Actualiza un producto base existente
  Future<void> actualizarProductoBase(ProductoBase producto);
  
  /// Elimina un producto base
  Future<void> eliminarProductoBase(String codigoBarras);
  
  /// Obtiene todas las categorías únicas
  Future<List<String>> obtenerCategorias();
  
  /// Obtiene todas las restricciones alimentarias únicas
  Future<List<String>> obtenerRestriccionesAlimentarias();
  
  /// Verifica si un producto existe
  Future<bool> existeProducto(String codigoBarras);
  
  /// Obtiene productos más utilizados (basado en existencias)
  Future<List<ProductoBase>> obtenerProductosMasUtilizados({int limite = 10});
  
  /// Busca productos con información nutricional
  Future<List<ProductoBase>> obtenerProductosConInfoNutricional();
  
  /// Busca productos por múltiples criterios
  Future<List<ProductoBase>> buscarProductosConFiltros({
    String? nombre,
    String? categoria,
    TipoPerecibilidad? perecibilidad,
    List<String>? restriccionesAlimentarias,
    bool? tieneInfoNutricional,
    int limite = 50,
  });
  
  /// Obtiene estadísticas de productos
  Future<Map<String, dynamic>> obtenerEstadisticasProductos();
  
  /// Importa productos desde una fuente externa
  Future<void> importarProductos(List<ProductoBase> productos);
  
  /// Exporta productos a formato JSON
  Future<List<Map<String, dynamic>>> exportarProductos();
  
  /// Sincroniza productos con una base de datos externa
  Future<void> sincronizarProductos();
  
  /// Obtiene productos con paginación
  Future<List<ProductoBase>> obtenerProductosConPaginacion({
    int pagina = 0,
    int tamanoPagina = 50,
    String? categoria,
    TipoPerecibilidad? perecibilidad,
  });
}