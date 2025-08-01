import 'package:flutter/material.dart';
import 'package:sazones_semanales/domain/repositories/existencia_repository.dart';
import 'package:sazones_semanales/domain/repositories/producto_repository.dart';
import 'package:sazones_semanales/domain/repositories/proveedor_repository.dart';
import 'package:sazones_semanales/infrastructure/database/database_helper.dart';
import 'package:sazones_semanales/infrastructure/repositories/existencia_repository_impl.dart';
import 'package:sazones_semanales/infrastructure/repositories/producto_repository_impl.dart';
import 'package:sazones_semanales/infrastructure/repositories/proveedor_repository_impl.dart';

/// Clase que proporciona instancias de los repositorios
class RepositoryProviders {
  // Instancias singleton de los repositorios
  static ExistenciaRepository? _existenciaRepository;
  static ProductoRepository? _productoRepository;
  static ProveedorRepository? _proveedorRepository;
  static DatabaseHelper? _databaseHelper;

  /// Obtiene una instancia del helper de base de datos
  static DatabaseHelper _getDatabaseHelper() {
    _databaseHelper ??= DatabaseHelper();
    return _databaseHelper!;
  }

  /// Obtiene una instancia del repositorio de existencias
  static ExistenciaRepository getExistenciaRepository(BuildContext context) {
    _existenciaRepository ??= ExistenciaRepositoryImpl(_getDatabaseHelper());
    return _existenciaRepository!;
  }

  /// Obtiene una instancia del repositorio de productos
  static ProductoRepository getProductoRepository(BuildContext context) {
    _productoRepository ??= ProductoRepositoryImpl(_getDatabaseHelper());
    return _productoRepository!;
  }

  /// Obtiene una instancia del repositorio de proveedores
  static ProveedorRepository getProveedorRepository(BuildContext context) {
    _proveedorRepository ??= ProveedorRepositoryImpl(_getDatabaseHelper());
    return _proveedorRepository!;
  }
}
