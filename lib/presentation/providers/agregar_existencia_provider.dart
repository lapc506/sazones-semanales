import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sazones_semanales/application/use_cases/existencias/agregar_existencia_use_case.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/domain/entities/producto_base.dart';
import 'package:sazones_semanales/domain/entities/proveedor.dart';
import 'package:sazones_semanales/domain/repositories/producto_repository.dart';
import 'package:sazones_semanales/domain/repositories/proveedor_repository.dart';
import 'package:sazones_semanales/infrastructure/repositories/repository_providers.dart';

/// Provider para gestionar el estado de la pantalla de agregar existencia
class AgregarExistenciaProvider extends ChangeNotifier {
  final ProductoRepository _productoRepository;
  final ProveedorRepository _proveedorRepository;
  final AgregarExistenciaUseCase _agregarExistenciaUseCase;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String _errorMensaje = '';
  String get errorMensaje => _errorMensaje;

  List<Proveedor> _proveedores = [];
  List<Proveedor> get proveedores => _proveedores;

  String? _proveedorSeleccionadoId;
  String? get proveedorSeleccionadoId => _proveedorSeleccionadoId;

  ProductoBase? _productoSeleccionado;
  ProductoBase? get productoSeleccionado => _productoSeleccionado;

  List<String> _categorias = [];
  List<String> get categorias => _categorias;

  File? _imagenProducto;
  File? get imagenProducto => _imagenProducto;
  bool get tieneImagen => _imagenProducto != null;

  /// Establece la imagen del producto
  void setImagenProducto(File imagen) {
    _imagenProducto = imagen;
    notifyListeners();
  }

  /// Guarda la imagen en el almacenamiento permanente y devuelve la ruta
  Future<String?> _guardarImagen() async {
    if (_imagenProducto == null) return null;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'producto_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage =
          await _imagenProducto!.copy('${appDir.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      debugPrint('Error al guardar la imagen: $e');
      return null;
    }
  }

  List<String> _sugerenciasNombre = [];

  AgregarExistenciaProvider(BuildContext context)
      : _productoRepository =
            RepositoryProviders.getProductoRepository(context),
        _proveedorRepository =
            RepositoryProviders.getProveedorRepository(context),
        _agregarExistenciaUseCase = AgregarExistenciaUseCase(
            RepositoryProviders.getExistenciaRepository(context)) {
    _inicializar();
  }

  /// Inicializa el provider cargando datos necesarios
  Future<void> _inicializar() async {
    try {
      await Future.wait([
        _cargarProveedores(),
        _cargarCategorias(),
      ]);

      // Si hay proveedores, seleccionar el primero por defecto
      if (_proveedores.isNotEmpty) {
        _proveedorSeleccionadoId = _proveedores.first.id;
      }
    } catch (e) {
      _errorMensaje = 'Error al cargar datos iniciales: $e';
      debugPrint(_errorMensaje);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga la lista de proveedores activos
  Future<void> _cargarProveedores() async {
    try {
      _proveedores = await _proveedorRepository.obtenerProveedoresActivos();
    } catch (e) {
      debugPrint('Error al cargar proveedores: $e');
      _proveedores = [];
    }
  }

  /// Carga las categorías disponibles
  Future<void> _cargarCategorias() async {
    try {
      _categorias = await _productoRepository.obtenerCategorias();
    } catch (e) {
      debugPrint('Error al cargar categorías: $e');
      _categorias = [];
    }
  }

  /// Selecciona un proveedor por su ID
  void seleccionarProveedor(String proveedorId) {
    _proveedorSeleccionadoId = proveedorId;
    notifyListeners();
  }

  /// Busca un producto por su código de barras
  Future<void> buscarProductoPorCodigoBarras(String codigoBarras) async {
    if (codigoBarras.length < 8) return;

    try {
      final producto =
          await _productoRepository.buscarPorCodigoBarras(codigoBarras);
      if (producto != null) {
        _productoSeleccionado = producto;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al buscar producto por código de barras: $e');
    }
  }

  /// Busca un producto por su nombre
  Future<void> buscarProductoPorNombre(String nombre) async {
    if (nombre.length < 3) return;

    try {
      final productos = await _productoRepository.buscarPorNombre(nombre);
      if (productos.isNotEmpty) {
        _productoSeleccionado = productos.first;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al buscar producto por nombre: $e');
    }
  }

  /// Obtiene sugerencias de nombres de productos
  Future<List<String>> obtenerSugerenciasNombre(String query) async {
    if (query.length < 2) return [];

    try {
      _sugerenciasNombre =
          await _productoRepository.obtenerSugerenciasAutocompletado(query);
      return _sugerenciasNombre;
    } catch (e) {
      debugPrint('Error al obtener sugerencias de nombres: $e');
      return [];
    }
  }

  /// Guarda una nueva existencia
  Future<bool> guardarExistencia({
    required String codigoBarras,
    required String nombreProducto,
    required String categoria,
    required DateTime fechaCompra,
    DateTime? fechaCaducidad,
    required double precio,
    required TipoPerecibilidad perecibilidad,
  }) async {
    if (_proveedorSeleccionadoId == null) {
      _errorMensaje = 'Debes seleccionar un proveedor';
      notifyListeners();
      return false;
    }

    if (_imagenProducto == null) {
      _errorMensaje = 'Debes tomar o seleccionar una foto del producto';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMensaje = '';
    notifyListeners();

    try {
      // Guardar la imagen y obtener la ruta
      final imagenPath = await _guardarImagen();

      final resultado = await _agregarExistenciaUseCase.execute(
        codigoBarras: codigoBarras,
        nombreProducto: nombreProducto,
        categoria: categoria,
        fechaCompra: fechaCompra,
        fechaCaducidad: fechaCaducidad,
        precio: precio,
        proveedorId: _proveedorSeleccionadoId!,
        perecibilidad: perecibilidad,
        imagenPath: imagenPath,
      );

      if (!resultado.esValido) {
        _errorMensaje = resultado.errores.join('\n');
        notifyListeners();
        return false;
      }

      // Si el producto no existe en la base de datos, guardarlo
      if (_productoSeleccionado == null ||
          _productoSeleccionado!.codigoBarras != codigoBarras) {
        await _guardarProductoBase(
          codigoBarras: codigoBarras,
          nombre: nombreProducto,
          categoria: categoria,
          perecibilidadDefault: perecibilidad,
        );
      }

      return true;
    } catch (e) {
      _errorMensaje = 'Error al guardar la existencia: $e';
      debugPrint(_errorMensaje);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Guarda un nuevo producto base
  Future<void> _guardarProductoBase({
    required String codigoBarras,
    required String nombre,
    required String categoria,
    required TipoPerecibilidad perecibilidadDefault,
  }) async {
    try {
      final existe = await _productoRepository.existeProducto(codigoBarras);
      if (!existe) {
        final ahora = DateTime.now();
        final productoBase = ProductoBase(
          codigoBarras: codigoBarras,
          nombre: nombre,
          categoria: categoria,
          perecibilidadDefault: perecibilidadDefault,
          createdAt: ahora,
          updatedAt: ahora,
        );

        await _productoRepository.guardarProductoBase(productoBase);
      }
    } catch (e) {
      debugPrint('Error al guardar producto base: $e');
    }
  }
}
