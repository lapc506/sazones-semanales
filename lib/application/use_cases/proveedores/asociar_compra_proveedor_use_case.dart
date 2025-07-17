import '../../../domain/repositories/existencia_repository.dart';
import '../../../domain/repositories/proveedor_repository.dart';

/// Resultado de la asociación de compra a proveedor
class AsociacionCompraProveedorResultado {
  final bool exito;
  final String? mensaje;
  final List<String> existenciasActualizadas;

  AsociacionCompraProveedorResultado({
    required this.exito,
    this.mensaje,
    this.existenciasActualizadas = const [],
  });

  factory AsociacionCompraProveedorResultado.exitoso(List<String> existenciasActualizadas) {
    return AsociacionCompraProveedorResultado(
      exito: true,
      existenciasActualizadas: existenciasActualizadas,
      mensaje: 'Compra asociada correctamente al proveedor',
    );
  }

  factory AsociacionCompraProveedorResultado.fallido(String mensaje) {
    return AsociacionCompraProveedorResultado(
      exito: false,
      mensaje: mensaje,
    );
  }
}

/// Caso de uso para asociar una compra a un proveedor
class AsociarCompraProveedorUseCase {
  final ExistenciaRepository _existenciaRepository;
  final ProveedorRepository _proveedorRepository;

  AsociarCompraProveedorUseCase(
    this._existenciaRepository,
    this._proveedorRepository,
  );

  /// Ejecuta el caso de uso para asociar una compra a un proveedor
  /// 
  /// [proveedorId] es el ID del proveedor al que se asociará la compra
  /// [existenciaIds] es la lista de IDs de existencias a asociar
  /// 
  /// Retorna un [AsociacionCompraProveedorResultado] que indica si la operación fue exitosa
  Future<AsociacionCompraProveedorResultado> execute({
    required String proveedorId,
    required List<String> existenciaIds,
  }) async {
    // Verificar que el proveedor exista
    final proveedor = await _proveedorRepository.obtenerProveedorPorId(proveedorId);
    if (proveedor == null) {
      return AsociacionCompraProveedorResultado.fallido('El proveedor no existe');
    }

    // Verificar que el proveedor esté activo
    if (!proveedor.activo) {
      return AsociacionCompraProveedorResultado.fallido('El proveedor no está activo');
    }

    // Verificar que haya existencias para asociar
    if (existenciaIds.isEmpty) {
      return AsociacionCompraProveedorResultado.fallido('No hay existencias para asociar');
    }

    // Obtener las existencias y actualizarlas
    final existenciasActualizadas = <String>[];
    for (final existenciaId in existenciaIds) {
      final existencia = await _existenciaRepository.obtenerExistenciaPorId(existenciaId);
      if (existencia != null) {
        // Actualizar el proveedor de la existencia
        final existenciaActualizada = existencia.copyWith(
          proveedorId: proveedorId,
          updatedAt: DateTime.now(),
        );
        
        await _existenciaRepository.actualizarExistencia(existenciaActualizada);
        existenciasActualizadas.add(existenciaId);
      }
    }

    // Verificar si se actualizaron todas las existencias
    if (existenciasActualizadas.isEmpty) {
      return AsociacionCompraProveedorResultado.fallido('No se encontraron existencias para actualizar');
    }

    if (existenciasActualizadas.length < existenciaIds.length) {
      return AsociacionCompraProveedorResultado(
        exito: true,
        mensaje: 'Se actualizaron ${existenciasActualizadas.length} de ${existenciaIds.length} existencias',
        existenciasActualizadas: existenciasActualizadas,
      );
    }

    return AsociacionCompraProveedorResultado.exitoso(existenciasActualizadas);
  }

  /// Asocia todas las existencias de una fecha específica a un proveedor
  /// 
  /// [proveedorId] es el ID del proveedor al que se asociarán las existencias
  /// [fechaCompra] es la fecha de compra de las existencias a asociar
  /// 
  /// Retorna un [AsociacionCompraProveedorResultado] que indica si la operación fue exitosa
  Future<AsociacionCompraProveedorResultado> executePorFecha({
    required String proveedorId,
    required DateTime fechaCompra,
  }) async {
    // Verificar que el proveedor exista
    final proveedor = await _proveedorRepository.obtenerProveedorPorId(proveedorId);
    if (proveedor == null) {
      return AsociacionCompraProveedorResultado.fallido('El proveedor no existe');
    }

    // Verificar que el proveedor esté activo
    if (!proveedor.activo) {
      return AsociacionCompraProveedorResultado.fallido('El proveedor no está activo');
    }

    // Obtener existencias por fecha de compra
    final fechaInicio = DateTime(fechaCompra.year, fechaCompra.month, fechaCompra.day);
    final fechaFin = fechaInicio.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
    
    final existencias = await _existenciaRepository.obtenerExistenciasPorRangoFechas(
      fechaInicio,
      fechaFin,
    );

    if (existencias.isEmpty) {
      return AsociacionCompraProveedorResultado.fallido('No hay existencias para la fecha seleccionada');
    }

    // Extraer IDs de existencias
    final existenciaIds = existencias.map((e) => e.id).toList();
    
    // Usar el método principal para asociar las existencias
    return execute(
      proveedorId: proveedorId,
      existenciaIds: existenciaIds,
    );
  }
}