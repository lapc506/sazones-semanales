import '../entities/existencia.dart';
import '../entities/enums.dart';

/// Repositorio abstracto para gestionar existencias
abstract class ExistenciaRepository {
  /// Obtiene todas las existencias activas (disponibles)
  Future<List<Existencia>> obtenerExistenciasActivas();
  
  /// Obtiene todas las existencias archivadas (consumidas/caducadas)
  Future<List<Existencia>> obtenerExistenciasArchivadas();
  
  /// Obtiene existencias por estado específico
  Future<List<Existencia>> obtenerExistenciasPorEstado(EstadoExistencia estado);
  
  /// Obtiene existencias próximas a caducar según su tipo de perecibilidad
  Future<List<Existencia>> obtenerExistenciasProximasACaducar();
  
  /// Obtiene existencias que ya caducaron
  Future<List<Existencia>> obtenerExistenciasCaducadas();
  
  /// Busca existencias por código de barras
  Future<List<Existencia>> buscarPorCodigoBarras(String codigoBarras);
  
  /// Busca existencias por nombre de producto
  Future<List<Existencia>> buscarPorNombreProducto(String nombre);
  
  /// Obtiene existencias por proveedor
  Future<List<Existencia>> obtenerExistenciasPorProveedor(String proveedorId);
  
  /// Obtiene existencias por categoría
  Future<List<Existencia>> obtenerExistenciasPorCategoria(String categoria);
  
  /// Obtiene existencias por rango de fechas de compra
  Future<List<Existencia>> obtenerExistenciasPorRangoFechas(
    DateTime fechaInicio,
    DateTime fechaFin,
  );
  
  /// Obtiene una existencia específica por ID
  Future<Existencia?> obtenerExistenciaPorId(String id);
  
  /// Guarda una nueva existencia
  Future<void> guardarExistencia(Existencia existencia);
  
  /// Actualiza una existencia existente
  Future<void> actualizarExistencia(Existencia existencia);
  
  /// Marca una existencia como consumida
  Future<void> marcarComoConsumida(String existenciaId);
  
  /// Marca una existencia como caducada
  Future<void> marcarComoCaducada(String existenciaId);
  
  /// Marca múltiples existencias como consumidas
  Future<void> marcarMultiplesComoConsumidas(List<String> existenciaIds);
  
  /// Elimina una existencia (solo para casos excepcionales)
  Future<void> eliminarExistencia(String existenciaId);
  
  /// Obtiene estadísticas de precios por producto
  Future<Map<String, dynamic>> obtenerEstadisticasPrecios(String nombreProducto);
  
  /// Obtiene gastos por categoría en un rango de fechas
  Future<List<Map<String, dynamic>>> obtenerGastosPorCategoria(
    DateTime fechaInicio,
    DateTime fechaFin,
  );
  
  /// Obtiene gastos por proveedor en un rango de fechas
  Future<List<Map<String, dynamic>>> obtenerGastosPorProveedor(
    DateTime fechaInicio,
    DateTime fechaFin,
  );
  
  /// Obtiene el historial de precios de un producto
  Future<List<Map<String, dynamic>>> obtenerHistorialPrecios(String nombreProducto);
  
  /// Obtiene productos más comprados
  Future<List<Map<String, dynamic>>> obtenerProductosMasComprados({int limite = 10});
  
  /// Obtiene patrones de consumo por producto
  Future<List<Map<String, dynamic>>> obtenerPatronesConsumo(String nombreProducto);
  
  /// Cuenta existencias por estado
  Future<Map<EstadoExistencia, int>> contarExistenciasPorEstado();
  
  /// Obtiene existencias con paginación
  Future<List<Existencia>> obtenerExistenciasConPaginacion({
    int pagina = 0,
    int tamanoPagina = 50,
    EstadoExistencia? estado,
    String? categoria,
    String? proveedorId,
  });
  
  /// Busca existencias con filtros múltiples
  Future<List<Existencia>> buscarExistenciasConFiltros({
    String? nombreProducto,
    String? categoria,
    String? proveedorId,
    EstadoExistencia? estado,
    TipoPerecibilidad? perecibilidad,
    DateTime? fechaCompraInicio,
    DateTime? fechaCompraFin,
    DateTime? fechaCaducidadInicio,
    DateTime? fechaCaducidadFin,
    double? precioMinimo,
    double? precioMaximo,
    int limite = 50,
  });
}