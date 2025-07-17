import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/infrastructure/database/database_helper.dart';
import 'package:sazones_semanales/infrastructure/repositories/existencia_repository_impl.dart';

void main() {
  late ExistenciaRepositoryImpl repository;
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for unit testing
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseHelper = DatabaseHelper();
    repository = ExistenciaRepositoryImpl(databaseHelper);
    
    // Clean database for each test
    await databaseHelper.deleteDatabase();
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  group('ExistenciaRepositoryImpl', () {
    test('should save and retrieve existencia', () async {
      // Arrange
      final existencia = Existencia(
        id: 'test-id',
        codigoBarras: '1234567890',
        nombreProducto: 'Test Product',
        categoria: 'Test Category',
        fechaCompra: DateTime.now(),
        fechaCaducidad: DateTime.now().add(Duration(days: 30)),
        precio: 10.50,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
        estado: EstadoExistencia.disponible,
        metadatos: {'test': 'value'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await repository.guardarExistencia(existencia);
      final retrieved = await repository.obtenerExistenciaPorId('test-id');

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-id'));
      expect(retrieved.nombreProducto, equals('Test Product'));
      expect(retrieved.precio, equals(10.50));
    });

    test('should get active existencias', () async {
      // Arrange
      final existencia1 = Existencia(
        id: 'test-id-1',
        codigoBarras: '1234567890',
        nombreProducto: 'Active Product',
        categoria: 'Test Category',
        fechaCompra: DateTime.now(),
        precio: 10.50,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
        estado: EstadoExistencia.disponible,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final existencia2 = Existencia(
        id: 'test-id-2',
        codigoBarras: '1234567891',
        nombreProducto: 'Consumed Product',
        categoria: 'Test Category',
        fechaCompra: DateTime.now(),
        precio: 15.75,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
        estado: EstadoExistencia.consumida,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarExistencia(existencia1);
      await repository.guardarExistencia(existencia2);

      // Act
      final activeExistencias = await repository.obtenerExistenciasActivas();

      // Assert
      expect(activeExistencias.length, equals(1));
      expect(activeExistencias.first.estado, equals(EstadoExistencia.disponible));
    });

    test('should search existencias by product name', () async {
      // Arrange
      final existencia = Existencia(
        id: 'test-id',
        codigoBarras: '1234567890',
        nombreProducto: 'Leche Entera',
        categoria: 'Lácteos',
        fechaCompra: DateTime.now(),
        precio: 3.50,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
        estado: EstadoExistencia.disponible,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarExistencia(existencia);

      // Act
      final results = await repository.buscarPorNombreProducto('Leche');

      // Assert
      expect(results.length, equals(1));
      expect(results.first.nombreProducto, contains('Leche'));
    });

    test('should mark existencia as consumed', () async {
      // Arrange
      final existencia = Existencia(
        id: 'test-id',
        codigoBarras: '1234567890',
        nombreProducto: 'Test Product',
        categoria: 'Test Category',
        fechaCompra: DateTime.now(),
        precio: 10.50,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
        estado: EstadoExistencia.disponible,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarExistencia(existencia);

      // Act
      await repository.marcarComoConsumida('test-id');
      final updated = await repository.obtenerExistenciaPorId('test-id');

      // Assert
      expect(updated!.estado, equals(EstadoExistencia.consumida));
    });
  });
}