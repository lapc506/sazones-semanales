import '../../../domain/entities/existencia.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/repositories/existencia_repository.dart';

/// Filtros para buscar existencias
class FiltrosBusquedaExistencias {
  final String? nombreProducto;
  final String? categoria;
  final String? proveedorId;
  final EstadoExistencia? estado;
  final TipoPerecibilidad? perecibilidad;
  final DateTime? fechaCompraInicio;
  final DateTime? fechaCompraFin;
  final DateTime? fechaCaducidadInicio;
  final DateTime? fechaCaducidadFin;
  final double? precioMinimo;
  final double? precioMaximo;
  final int limite;

  FiltrosBusquedaExistencias({
    this.nombreProducto,
    this.categoria,
    this.proveedorId,
    this.estado,
    this.perecibilidad,
    this.fechaCompraInicio,
    this.fechaCompraFin,
    this.fechaCaducidadInicio,
    this.fechaCaducidadFin,
    this.precioMinimo,
    this.precioMaximo,
    this.limite = 50,
  });

  /// Verifica si hay algún filtro aplicado
  bool get tieneAlgunFiltro =>
      nombreProducto != null ||
      categoria != null ||
      proveedorId != null ||
      estado != null ||
      perecibilidad != null ||
      fechaCompraInicio != null ||
      fechaCompraFin != null ||
      fechaCaducidadInicio != null ||
      fechaCaducidadFin != null ||
      precioMinimo != null ||
      precioMaximo != null;
}

/// Caso de uso para buscar existencias con filtros
class BuscarExistenciasUseCase {
  final ExistenciaRepository _existenciaRepository;

  BuscarExistenciasUseCase(this._existenciaRepository);

  /// Ejecuta el caso de uso para buscar existencias con filtros
  /// 
  /// [filtros] contiene los criterios de búsqueda
  /// 
  /// Retorna una lista de existencias que cumplen con los filtros
  Future<List<Existencia>> execute(FiltrosBusquedaExistencias filtros) async {
    // Si no hay filtros, retornar existencias activas por defecto
    if (!filtros.tieneAlgunFiltro && filtros.estado == null) {
      return await _existenciaRepository.obtenerExistenciasActivas();
    }

    // Buscar con los filtros proporcionados
    return await _existenciaRepository.buscarExistenciasConFiltros(
      nombreProducto: filtros.nombreProducto,
      categoria: filtros.categoria,
      proveedorId: filtros.proveedorId,
      estado: filtros.estado,
      perecibilidad: filtros.perecibilidad,
      fechaCompraInicio: filtros.fechaCompraInicio,
      fechaCompraFin: filtros.fechaCompraFin,
      fechaCaducidadInicio: filtros.fechaCaducidadInicio,
      fechaCaducidadFin: filtros.fechaCaducidadFin,
      precioMinimo: filtros.precioMinimo,
      precioMaximo: filtros.precioMaximo,
      limite: filtros.limite,
    );
  }

  /// Busca existencias por código de barras
  Future<List<Existencia>> buscarPorCodigoBarras(String codigoBarras) async {
    return await _existenciaRepository.buscarPorCodigoBarras(codigoBarras);
  }

  /// Busca existencias por nombre de producto
  Future<List<Existencia>> buscarPorNombreProducto(String nombre) async {
    return await _existenciaRepository.buscarPorNombreProducto(nombre);
  }

  /// Obtiene existencias próximas a caducar
  Future<List<Existencia>> obtenerProximasACaducar() async {
    return await _existenciaRepository.obtenerExistenciasProximasACaducar();
  }

  /// Obtiene existencias por categoría
  Future<List<Existencia>> obtenerPorCategoria(String categoria) async {
    return await _existenciaRepository.obtenerExistenciasPorCategoria(categoria);
  }

  /// Obtiene existencias por proveedor
  Future<List<Existencia>> obtenerPorProveedor(String proveedorId) async {
    return await _existenciaRepository.obtenerExistenciasPorProveedor(proveedorId);
  }

  /// Obtiene existencias por estado
  Future<List<Existencia>> obtenerPorEstado(EstadoExistencia estado) async {
    return await _existenciaRepository.obtenerExistenciasPorEstado(estado);
  }
}