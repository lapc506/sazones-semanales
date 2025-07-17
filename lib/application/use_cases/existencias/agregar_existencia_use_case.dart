import 'package:uuid/uuid.dart';
import '../../../domain/entities/existencia.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/repositories/existencia_repository.dart';

/// Resultado de la validación de una existencia
class ValidacionExistenciaResultado {
  final bool esValido;
  final List<String> errores;

  ValidacionExistenciaResultado({
    required this.esValido,
    this.errores = const [],
  });

  factory ValidacionExistenciaResultado.valido() {
    return ValidacionExistenciaResultado(esValido: true);
  }

  factory ValidacionExistenciaResultado.invalido(List<String> errores) {
    return ValidacionExistenciaResultado(
      esValido: false,
      errores: errores,
    );
  }
}

/// Caso de uso para agregar una nueva existencia al inventario
class AgregarExistenciaUseCase {
  final ExistenciaRepository _existenciaRepository;
  final Uuid _uuid;

  AgregarExistenciaUseCase(this._existenciaRepository) : _uuid = const Uuid();

  /// Ejecuta el caso de uso para agregar una nueva existencia
  /// 
  /// Retorna un [ValidacionExistenciaResultado] que indica si la operación fue exitosa
  /// y contiene errores en caso de que la validación falle
  Future<ValidacionExistenciaResultado> execute({
    required String codigoBarras,
    required String nombreProducto,
    required String categoria,
    required DateTime fechaCompra,
    DateTime? fechaCaducidad,
    required double precio,
    required String proveedorId,
    required TipoPerecibilidad perecibilidad,
    Map<String, dynamic> metadatos = const {},
  }) async {
    // Validar datos de entrada
    final validacion = _validarDatos(
      codigoBarras: codigoBarras,
      nombreProducto: nombreProducto,
      categoria: categoria,
      fechaCompra: fechaCompra,
      fechaCaducidad: fechaCaducidad,
      precio: precio,
      proveedorId: proveedorId,
    );

    if (!validacion.esValido) {
      return validacion;
    }

    // Crear nueva existencia
    final ahora = DateTime.now();
    final existencia = Existencia(
      id: _uuid.v4(),
      codigoBarras: codigoBarras,
      nombreProducto: nombreProducto,
      categoria: categoria,
      fechaCompra: fechaCompra,
      fechaCaducidad: fechaCaducidad,
      precio: precio,
      proveedorId: proveedorId,
      perecibilidad: perecibilidad,
      estado: EstadoExistencia.disponible,
      metadatos: metadatos,
      createdAt: ahora,
      updatedAt: ahora,
    );

    // Guardar en el repositorio
    await _existenciaRepository.guardarExistencia(existencia);
    
    return ValidacionExistenciaResultado.valido();
  }

  /// Valida los datos de entrada para crear una existencia
  ValidacionExistenciaResultado _validarDatos({
    required String codigoBarras,
    required String nombreProducto,
    required String categoria,
    required DateTime fechaCompra,
    DateTime? fechaCaducidad,
    required double precio,
    required String proveedorId,
  }) {
    final errores = <String>[];

    // Validar código de barras
    if (codigoBarras.isEmpty) {
      errores.add('El código de barras no puede estar vacío');
    } else if (codigoBarras.length < 8) {
      errores.add('El código de barras debe tener al menos 8 caracteres');
    }

    // Validar nombre del producto
    if (nombreProducto.isEmpty) {
      errores.add('El nombre del producto no puede estar vacío');
    } else if (nombreProducto.length < 3) {
      errores.add('El nombre del producto debe tener al menos 3 caracteres');
    }

    // Validar categoría
    if (categoria.isEmpty) {
      errores.add('La categoría no puede estar vacía');
    }

    // Validar fecha de compra
    final ahora = DateTime.now();
    if (fechaCompra.isAfter(ahora)) {
      errores.add('La fecha de compra no puede ser futura');
    }

    // Validar fecha de caducidad si existe
    if (fechaCaducidad != null) {
      if (fechaCaducidad.isBefore(fechaCompra)) {
        errores.add('La fecha de caducidad no puede ser anterior a la fecha de compra');
      }
    }

    // Validar precio
    if (precio <= 0) {
      errores.add('El precio debe ser mayor que cero');
    }

    // Validar proveedor
    if (proveedorId.isEmpty) {
      errores.add('Debe seleccionar un proveedor');
    }

    return errores.isEmpty
        ? ValidacionExistenciaResultado.valido()
        : ValidacionExistenciaResultado.invalido(errores);
  }
}