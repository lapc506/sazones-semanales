import 'package:uuid/uuid.dart';
import '../../../domain/entities/proveedor.dart';
import '../../../domain/repositories/proveedor_repository.dart';

/// Resultado de la validación de un proveedor
class ValidacionProveedorResultado {
  final bool esValido;
  final List<String> errores;

  ValidacionProveedorResultado({
    required this.esValido,
    this.errores = const [],
  });

  factory ValidacionProveedorResultado.valido() {
    return ValidacionProveedorResultado(esValido: true);
  }

  factory ValidacionProveedorResultado.invalido(List<String> errores) {
    return ValidacionProveedorResultado(
      esValido: false,
      errores: errores,
    );
  }
}

/// Caso de uso para agregar un nuevo proveedor
class AgregarProveedorUseCase {
  final ProveedorRepository _proveedorRepository;
  final Uuid _uuid;

  AgregarProveedorUseCase(this._proveedorRepository) : _uuid = const Uuid();

  /// Ejecuta el caso de uso para agregar un nuevo proveedor
  /// 
  /// Retorna un [ValidacionProveedorResultado] que indica si la operación fue exitosa
  /// y contiene errores en caso de que la validación falle
  Future<ValidacionProveedorResultado> execute({
    required String nombre,
    required TipoProveedor tipo,
    bool activo = true,
    String? direccion,
    String? telefono,
    String? horarios,
    String? notas,
  }) async {
    // Validar datos de entrada
    final validacion = await _validarDatos(
      nombre: nombre,
      tipo: tipo,
      direccion: direccion,
      telefono: telefono,
    );

    if (!validacion.esValido) {
      return validacion;
    }

    // Crear nuevo proveedor
    final ahora = DateTime.now();
    final proveedor = Proveedor(
      id: _uuid.v4(),
      nombre: nombre,
      tipo: tipo,
      activo: activo,
      direccion: direccion,
      telefono: telefono,
      horarios: horarios,
      notas: notas,
      createdAt: ahora,
      updatedAt: ahora,
    );

    // Guardar en el repositorio
    await _proveedorRepository.guardarProveedor(proveedor);
    
    return ValidacionProveedorResultado.valido();
  }

  /// Valida los datos de entrada para crear un proveedor
  Future<ValidacionProveedorResultado> _validarDatos({
    required String nombre,
    required TipoProveedor tipo,
    String? direccion,
    String? telefono,
  }) async {
    final errores = <String>[];

    // Validar nombre
    if (nombre.isEmpty) {
      errores.add('El nombre del proveedor no puede estar vacío');
    } else if (nombre.length < 3) {
      errores.add('El nombre del proveedor debe tener al menos 3 caracteres');
    } else {
      // Verificar si ya existe un proveedor con el mismo nombre
      final existeNombre = await _proveedorRepository.existeProveedorConNombre(nombre);
      if (existeNombre) {
        errores.add('Ya existe un proveedor con el nombre "$nombre"');
      }
    }

    // Validar teléfono si se proporciona
    if (telefono != null && telefono.isNotEmpty) {
      // Eliminar espacios y guiones para validar
      final telefonoLimpio = telefono.replaceAll(RegExp(r'[\s-]'), '');
      
      // Verificar que solo contenga dígitos
      if (!RegExp(r'^\d+$').hasMatch(telefonoLimpio)) {
        errores.add('El teléfono debe contener solo dígitos, espacios o guiones');
      }
      
      // Verificar longitud mínima
      if (telefonoLimpio.length < 7) {
        errores.add('El teléfono debe tener al menos 7 dígitos');
      }
    }

    return errores.isEmpty
        ? ValidacionProveedorResultado.valido()
        : ValidacionProveedorResultado.invalido(errores);
  }
}