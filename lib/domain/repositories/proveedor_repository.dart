import '../entities/proveedor.dart';

/// Repositorio abstracto para gestionar proveedores
abstract class ProveedorRepository {
  /// Obtiene todos los proveedores activos
  Future<List<Proveedor>> obtenerProveedoresActivos();
  
  /// Obtiene todos los proveedores (activos e inactivos)
  Future<List<Proveedor>> obtenerTodosLosProveedores();
  
  /// Obtiene un proveedor específico por ID
  Future<Proveedor?> obtenerProveedorPorId(String id);
  
  /// Busca proveedores por nombre
  Future<List<Proveedor>> buscarPorNombre(String nombre);
  
  /// Obtiene proveedores por tipo
  Future<List<Proveedor>> obtenerProveedoresPorTipo(TipoProveedor tipo);
  
  /// Guarda un nuevo proveedor
  Future<void> guardarProveedor(Proveedor proveedor);
  
  /// Actualiza un proveedor existente
  Future<void> actualizarProveedor(Proveedor proveedor);
  
  /// Desactiva un proveedor
  Future<void> desactivarProveedor(String proveedorId);
  
  /// Activa un proveedor
  Future<void> activarProveedor(String proveedorId);
  
  /// Elimina un proveedor (solo si no tiene existencias asociadas)
  Future<void> eliminarProveedor(String proveedorId);
  
  /// Verifica si un proveedor tiene existencias asociadas
  Future<bool> tieneExistenciasAsociadas(String proveedorId);
  
  /// Obtiene estadísticas de compras por proveedor
  Future<Map<String, dynamic>> obtenerEstadisticasProveedor(String proveedorId);
  
  /// Obtiene el historial de compras de un proveedor
  Future<List<Map<String, dynamic>>> obtenerHistorialCompras(String proveedorId);
  
  /// Obtiene proveedores más utilizados
  Future<List<Map<String, dynamic>>> obtenerProveedoresMasUtilizados({int limite = 10});
  
  /// Obtiene todos los tipos de proveedor únicos en uso
  Future<List<TipoProveedor>> obtenerTiposEnUso();
  
  /// Cuenta proveedores por tipo
  Future<Map<TipoProveedor, int>> contarProveedoresPorTipo();
  
  /// Busca proveedores con filtros múltiples
  Future<List<Proveedor>> buscarProveedoresConFiltros({
    String? nombre,
    TipoProveedor? tipo,
    bool? activo,
    String? direccion,
    int limite = 50,
  });
  
  /// Obtiene proveedores con paginación
  Future<List<Proveedor>> obtenerProveedoresConPaginacion({
    int pagina = 0,
    int tamanoPagina = 50,
    TipoProveedor? tipo,
    bool? soloActivos = true,
  });
  
  /// Verifica si existe un proveedor con el mismo nombre
  Future<bool> existeProveedorConNombre(String nombre, {String? excluyendoId});
  
  /// Obtiene sugerencias de nombres para autocompletado
  Future<List<String>> obtenerSugerenciasNombres(String query, {int limite = 10});
  
  /// Exporta proveedores a formato JSON
  Future<List<Map<String, dynamic>>> exportarProveedores();
  
  /// Importa proveedores desde una lista
  Future<void> importarProveedores(List<Proveedor> proveedores);
}