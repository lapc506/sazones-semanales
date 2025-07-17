import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sazones_semanales/domain/entities/producto_base.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/infrastructure/database/database_helper.dart';
import 'package:sazones_semanales/infrastructure/repositories/producto_repository_impl.dart';

void main() {
  late ProductoRepositoryImpl repository;
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for unit testing
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseHelper = DatabaseHelper();
    repository = ProductoRepositoryImpl(databaseHelper);
    
    // Clean database for each test
    await databaseHelper.deleteDatabase();
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  group('ProductoRepositoryImpl', () {
    test('should save and retrieve producto by codigo de barras', () async {
      // Arrange
      final producto = ProductoBase(
        codigoBarras: '1234567890',
        nombre: 'Test Product',
        categoria: 'Test Category',
        perecibilidadDefault: TipoPerecibilidad.perecedero,
        restriccionesAlimentarias: ['gluten', 'lactosa'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await repository.guardarProductoBase(producto);
      final retrieved = await repository.buscarPorCodigoBarras('1234567890');

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.codigoBarras, equals('1234567890'));
      expect(retrieved.nombre, equals('Test Product'));
      expect(retrieved.restriccionesAlimentarias, contains('gluten'));
    });

    test('should get all productos', () async {
      // Arrange
      final producto1 = ProductoBase(
        codigoBarras: '1234567890',
        nombre: 'Product A',
        categoria: 'Category 1',
        perecibilidadDefault: TipoPerecibilidad.perecedero,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final producto2 = ProductoBase(
        codigoBarras: '1234567891',
        nombre: 'Product B',
        categoria: 'Category 2',
        perecibilidadDefault: TipoPerecibilidad.noPerecedero,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProductoBase(producto1);
      await repository.guardarProductoBase(producto2);

      // Act
      final productos = await repository.obtenerTodosLosProductos();

      // Assert
      expect(productos.length, equals(2));
    });

    test('should search productos by name', () async {
      // Arrange
      final producto = ProductoBase(
        codigoBarras: '1234567890',
        nombre: 'Leche Entera',
        categoria: 'Lácteos',
        perecibilidadDefault: TipoPerecibilidad.perecedero,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProductoBase(producto);

      // Act
      final results = await repository.buscarPorNombre('Leche');

      // Assert
      expect(results.length, equals(1));
      expect(results.first.nombre, contains('Leche'));
    });

    test('should get autocomplete suggestions', () async {
      // Arrange
      final productos = [
        ProductoBase(
          codigoBarras: '1234567890',
          nombre: 'Leche Entera',
          categoria: 'Lácteos',
          perecibilidadDefault: TipoPerecibilidad.perecedero,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ProductoBase(
          codigoBarras: '1234567891',
          nombre: 'Leche Descremada',
          categoria: 'Lácteos',
          perecibilidadDefault: TipoPerecibilidad.perecedero,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ProductoBase(
          codigoBarras: '1234567892',
          nombre: 'Pan Integral',
          categoria: 'Panadería',
          perecibilidadDefault: TipoPerecibilidad.perecedero,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final producto in productos) {
        await repository.guardarProductoBase(producto);
      }

      // Act
      final suggestions = await repository.obtenerSugerenciasAutocompletado('Leche');

      // Assert
      expect(suggestions.length, equals(2));
      expect(suggestions, contains('Leche Entera'));
      expect(suggestions, contains('Leche Descremada'));
    });

    test('should get productos by category', () async {
      // Arrange
      final producto1 = ProductoBase(
        codigoBarras: '1234567890',
        nombre: 'Leche',
        categoria: 'Lácteos',
        perecibilidadDefault: TipoPerecibilidad.perecedero,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final producto2 = ProductoBase(
        codigoBarras: '1234567891',
        nombre: 'Pan',
        categoria: 'Panadería',
        perecibilidadDefault: TipoPerecibilidad.perecedero,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProductoBase(producto1);
      await repository.guardarProductoBase(producto2);

      // Act
      final lacteos = await repository.obtenerProductosPorCategoria('Lácteos');

      // Assert
      expect(lacteos.length, equals(1));
      expect(lacteos.first.categoria, equals('Lácteos'));
    });

    test('should check if producto exists', () async {
      // Arrange
      final producto = ProductoBase(
        codigoBarras: '1234567890',
        nombre: 'Test Product',
        categoria: 'Test Category',
        perecibilidadDefault: TipoPerecibilidad.perecedero,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProductoBase(producto);

      // Act & Assert
      expect(await repository.existeProducto('1234567890'), isTrue);
      expect(await repository.existeProducto('9999999999'), isFalse);
    });
  });
}