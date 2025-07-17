import 'package:flutter/material.dart';
import 'package:sazones_semanales/application/use_cases/existencias/buscar_existencias_use_case.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/infrastructure/repositories/repository_providers.dart';

/// Provider para gestionar el estado de las existencias en la UI
class ExistenciasProvider extends ChangeNotifier {
  final BuildContext _context;
  late final BuscarExistenciasUseCase _buscarExistenciasUseCase;
  
  List<Existencia> _existencias = [];
  List<Existencia> get existencias => _existencias;
  
  List<String> _categorias = [];
  List<String> get categorias => _categorias;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _filtroCategoria;
  String? get filtroCategoria => _filtroCategoria;
  
  EstadoExistencia? _filtroEstado;
  EstadoExistencia? get filtroEstado => _filtroEstado;
  
  String _textoBusqueda = '';
  String get textoBusqueda => _textoBusqueda;
  
  ExistenciasProvider(this._context) {
    _buscarExistenciasUseCase = BuscarExistenciasUseCase(
      RepositoryProviders.getExistenciaRepository(_context)
    );
    _cargarExistencias();
  }
  
  /// Carga las existencias iniciales
  Future<void> _cargarExistencias() async {
    _setLoading(true);
    
    try {
      // Aplicar filtros si existen
      final filtros = FiltrosBusquedaExistencias(
        categoria: _filtroCategoria,
        estado: _filtroEstado ?? EstadoExistencia.disponible,
        nombreProducto: _textoBusqueda.isNotEmpty ? _textoBusqueda : null,
      );
      
      _existencias = await _buscarExistenciasUseCase.execute(filtros);
      _actualizarCategorias();
    } catch (e) {
      debugPrint('Error al cargar existencias: $e');
      _existencias = [];
    } finally {
      _setLoading(false);
    }
  }
  
  /// Actualiza la lista de categorías disponibles
  void _actualizarCategorias() {
    final categoriasSet = <String>{};
    for (final existencia in _existencias) {
      if (existencia.categoria.isNotEmpty) {
        categoriasSet.add(existencia.categoria);
      }
    }
    _categorias = categoriasSet.toList()..sort();
  }
  
  /// Establece el estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Filtra las existencias por categoría
  void filtrarPorCategoria(String? categoria) {
    if (_filtroCategoria == categoria) return;
    
    _filtroCategoria = categoria;
    _cargarExistencias();
  }
  
  /// Filtra las existencias por estado
  void filtrarPorEstado(EstadoExistencia? estado) {
    if (_filtroEstado == estado) return;
    
    _filtroEstado = estado;
    _cargarExistencias();
  }
  
  /// Busca existencias por nombre de producto
  void buscarPorNombre(String texto) {
    if (_textoBusqueda == texto) return;
    
    _textoBusqueda = texto;
    _cargarExistencias();
  }
  
  /// Limpia todos los filtros
  void limpiarFiltros() {
    _filtroCategoria = null;
    _filtroEstado = EstadoExistencia.disponible;
    _textoBusqueda = '';
    _cargarExistencias();
  }
  
  /// Recarga las existencias
  Future<void> recargarExistencias() async {
    await _cargarExistencias();
  }
  
  /// Marca una existencia como consumida
  Future<void> marcarComoConsumida(String existenciaId) async {
    _setLoading(true);
    
    try {
      final repository = RepositoryProviders.getExistenciaRepository(_context);
      await repository.marcarComoConsumida(existenciaId);
      await _cargarExistencias();
    } catch (e) {
      debugPrint('Error al marcar como consumida: $e');
    } finally {
      _setLoading(false);
    }
  }
}