import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sazones_semanales/domain/entities/proveedor.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/infrastructure/database/database_helper.dart';
import 'package:sazones_semanales/infrastructure/repositories/proveedor_repository_impl.dart';
import 'package:sazones_semanales/infrastructure/repositories/existencia_repository_impl.dart';

void main() {
  late ProveedorRepositoryImpl repository;
  late ExistenciaRepositoryImpl existenciaRepository;
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for unit testing
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseHelper = DatabaseHelper();
    repository = ProveedorRepositoryImpl(databaseHelper);
    existenciaRepository = ExistenciaRepositoryImpl(databaseHelper);
    
    // Clean database for each test
    await databaseHelper.deleteDatabase();
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  group('ProveedorRepositoryImpl', () {
    test('should save and retrieve proveedor', () async {
      // Arrange
      final proveedor = Proveedor(
        id: 'test-id',
        nombre: 'Test Proveedor',
        tipo: TipoProveedor.supermercado,
        activo: true,
        direccion: 'Test Address',
        telefono: '123456789',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await repository.guardarProveedor(proveedor);
      final retrieved = await repository.obtenerProveedorPorId('test-id');

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-id'));
      expect(retrieved.nombre, equals('Test Proveedor'));
      expect(retrieved.tipo, equals(TipoProveedor.supermercado));
      expect(retrieved.activo, isTrue);
    });

    test('should get active proveedores', () async {
      // Arrange
      final proveedor1 = Proveedor(
        id: 'test-id-1',
        nombre: 'Active Proveedor',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final proveedor2 = Proveedor(
        id: 'test-id-2',
        nombre: 'Inactive Proveedor',
        tipo: TipoProveedor.farmacia,
        activo: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProveedor(proveedor1);
      await repository.guardarProveedor(proveedor2);

      // Act
      final activeProveedores = await repository.obtenerProveedoresActivos();
      final allProveedores = await repository.obtenerTodosLosProveedores();

      // Assert
      expect(activeProveedores.length, equals(1));
      expect(activeProveedores.first.activo, isTrue);
      expect(allProveedores.length, equals(2));
    });

    test('should search proveedores by name', () async {
      // Arrange
      final proveedor = Proveedor(
        id: 'test-id',
        nombre: 'Supermercado XYZ',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProveedor(proveedor);

      // Act
      final results = await repository.buscarPorNombre('XYZ');

      // Assert
      expect(results.length, equals(1));
      expect(results.first.nombre, contains('XYZ'));
    });

    test('should get proveedores by tipo', () async {
      // Arrange
      final proveedor1 = Proveedor(
        id: 'test-id-1',
        nombre: 'Supermercado A',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final proveedor2 = Proveedor(
        id: 'test-id-2',
        nombre: 'Farmacia B',
        tipo: TipoProveedor.farmacia,
        activo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProveedor(proveedor1);
      await repository.guardarProveedor(proveedor2);

      // Act
      final supermercados = await repository.obtenerProveedoresPorTipo(TipoProveedor.supermercado);
      final farmacias = await repository.obtenerProveedoresPorTipo(TipoProveedor.farmacia);

      // Assert
      expect(supermercados.length, equals(1));
      expect(supermercados.first.tipo, equals(TipoProveedor.supermercado));
      expect(farmacias.length, equals(1));
      expect(farmacias.first.tipo, equals(TipoProveedor.farmacia));
    });

    test('should activate and deactivate proveedor', () async {
      // Arrange
      final proveedor = Proveedor(
        id: 'test-id',
        nombre: 'Test Proveedor',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProveedor(proveedor);

      // Act - Deactivate
      await repository.desactivarProveedor('test-id');
      final deactivated = await repository.obtenerProveedorPorId('test-id');

      // Assert
      expect(deactivated!.activo, isFalse);

      // Act - Activate
      await repository.activarProveedor('test-id');
      final activated = await repository.obtenerProveedorPorId('test-id');

      // Assert
      expect(activated!.activo, isTrue);
    });

    test('should check if proveedor has existencias', () async {
      // Arrange
      final proveedor = Proveedor(
        id: 'test-id',
        nombre: 'Test Proveedor',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final existencia = Existencia(
        id: 'existencia-id',
        codigoBarras: '1234567890',
        nombreProducto: 'Test Product',
        categoria: 'Test Category',
        fechaCompra: DateTime.now(),
        precio: 10.50,
        proveedorId: 'test-id',
        perecibilidad: TipoPerecibilidad.perecedero,
        estado: EstadoExistencia.disponible,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProveedor(proveedor);
      await existenciaRepository.guardarExistencia(existencia);

      // Act
      final hasExistencias = await repository.tieneExistenciasAsociadas('test-id');
      final noExistencias = await repository.tieneExistenciasAsociadas('non-existent-id');

      // Assert
      expect(hasExistencias, isTrue);
      expect(noExistencias, isFalse);
    });

    test('should not delete proveedor with existencias', () async {
      // Arrange
      final proveedor = Proveedor(
        id: 'test-id',
        nombre: 'Test Proveedor',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final existencia = Existencia(
        id: 'existencia-id',
        codigoBarras: '1234567890',
        nombreProducto: 'Test Product',
        categoria: 'Test Category',
        fechaCompra: DateTime.now(),
        precio: 10.50,
        proveedorId: 'test-id',
        perecibilidad: TipoPerecibilidad.perecedero,
        estado: EstadoExistencia.disponible,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProveedor(proveedor);
      await existenciaRepository.guardarExistencia(existencia);

      // Act & Assert
      expect(() => repository.eliminarProveedor('test-id'), throwsException);
    });

    test('should delete proveedor without existencias', () async {
      // Arrange
      final proveedor = Proveedor(
        id: 'test-id',
        nombre: 'Test Proveedor',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProveedor(proveedor);

      // Act
      await repository.eliminarProveedor('test-id');
      final deleted = await repository.obtenerProveedorPorId('test-id');

      // Assert
      expect(deleted, isNull);
    });

    test('should check if proveedor with name exists', () async {
      // Arrange
      final proveedor = Proveedor(
        id: 'test-id',
        nombre: 'Unique Name',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.guardarProveedor(proveedor);

      // Act & Assert
      expect(await repository.existeProveedorConNombre('Unique Name'), isTrue);
      expect(await repository.existeProveedorConNombre('Different Name'), isFalse);
      expect(await repository.existeProveedorConNombre('Unique Name', excluyendoId: 'test-id'), isFalse);
    });

    test('should get name suggestions', () async {
      // Arrange
      final proveedores = [
        Proveedor(
          id: 'test-id-1',
          nombre: 'Supermercado ABC',
          tipo: TipoProveedor.supermercado,
          activo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Proveedor(
          id: 'test-id-2',
          nombre: 'Supermercado XYZ',
          tipo: TipoProveedor.supermercado,
          activo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Proveedor(
          id: 'test-id-3',
          nombre: 'Farmacia ABC',
          tipo: TipoProveedor.farmacia,
          activo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final proveedor in proveedores) {
        await repository.guardarProveedor(proveedor);
      }

      // Act
      final suggestions = await repository.obtenerSugerenciasNombres('Super');

      // Assert
      expect(suggestions.length, equals(2));
      expect(suggestions, contains('Supermercado ABC'));
      expect(suggestions, contains('Supermercado XYZ'));
    });

    test('should get tipos en uso', () async {
      // Arrange
      final proveedores = [
        Proveedor(
          id: 'test-id-1',
          nombre: 'Supermercado A',
          tipo: TipoProveedor.supermercado,
          activo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Proveedor(
          id: 'test-id-2',
          nombre: 'Farmacia B',
          tipo: TipoProveedor.farmacia,
          activo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Proveedor(
          id: 'test-id-3',
          nombre: 'Ferretería C',
          tipo: TipoProveedor.ferreteria,
          activo: false, // Inactive
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final proveedor in proveedores) {
        await repository.guardarProveedor(proveedor);
      }

      // Act
      final tiposEnUso = await repository.obtenerTiposEnUso();

      // Assert
      expect(tiposEnUso.length, equals(2));
      expect(tiposEnUso, contains(TipoProveedor.supermercado));
      expect(tiposEnUso, contains(TipoProveedor.farmacia));
      expect(tiposEnUso, isNot(contains(TipoProveedor.ferreteria)));
    });

    test('should count proveedores by tipo', () async {
      // Arrange
      final proveedores = [
        Proveedor(
          id: 'test-id-1',
          nombre: 'Supermercado A',
          tipo: TipoProveedor.supermercado,
          activo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Proveedor(
          id: 'test-id-2',
          nombre: 'Supermercado B',
          tipo: TipoProveedor.supermercado,
          activo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Proveedor(
          id: 'test-id-3',
          nombre: 'Farmacia C',
          tipo: TipoProveedor.farmacia,
          activo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final proveedor in proveedores) {
        await repository.guardarProveedor(proveedor);
      }

      // Act
      final conteo = await repository.contarProveedoresPorTipo();

      // Assert
      expect(conteo[TipoProveedor.supermercado], equals(2));
      expect(conteo[TipoProveedor.farmacia], equals(1));
    });

    test('should search proveedores with filters', () async {
      // Arrange
      final proveedores = [
        Proveedor(
          id: 'test-id-1',
          nombre: 'Supermercado Centro',
          tipo: TipoProveedor.supermercado,
          activo: true,
          direccion: 'Calle Principal 123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Proveedor(
          id: 'test-id-2',
          nombre: 'Supermercado Norte',
          tipo: TipoProveedor.supermercado,
          activo: false,
          direccion: 'Avenida Norte 456',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Proveedor(
          id: 'test-id-3',
          nombre: 'Farmacia Centro',
          tipo: TipoProveedor.farmacia,
          activo: true,
          direccion: 'Calle Principal 789',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final proveedor in proveedores) {
        await repository.guardarProveedor(proveedor);
      }

      // Act & Assert
      final porNombre = await repository.buscarProveedoresConFiltros(nombre: 'Centro');
      expect(porNombre.length, equals(2));

      final porTipo = await repository.buscarProveedoresConFiltros(tipo: TipoProveedor.supermercado);
      expect(porTipo.length, equals(2));

      final porActivo = await repository.buscarProveedoresConFiltros(activo: true);
      expect(porActivo.length, equals(2));

      final porDireccion = await repository.buscarProveedoresConFiltros(direccion: 'Principal');
      expect(porDireccion.length, equals(2));

      final combinados = await repository.buscarProveedoresConFiltros(
        tipo: TipoProveedor.supermercado,
        activo: true,
      );
      expect(combinados.length, equals(1));
      expect(combinados.first.nombre, equals('Supermercado Centro'));
    });

    test('should get proveedores with pagination', () async {
      // Arrange
      final proveedores = List.generate(10, (i) => Proveedor(
        id: 'test-id-$i',
        nombre: 'Proveedor $i',
        tipo: i % 2 == 0 ? TipoProveedor.supermercado : TipoProveedor.farmacia,
        activo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      for (final proveedor in proveedores) {
        await repository.guardarProveedor(proveedor);
      }

      // Act
      final page1 = await repository.obtenerProveedoresConPaginacion(
        pagina: 0,
        tamanoPagina: 5,
      );
      
      final page2 = await repository.obtenerProveedoresConPaginacion(
        pagina: 1,
        tamanoPagina: 5,
      );
      
      final supermercados = await repository.obtenerProveedoresConPaginacion(
        tipo: TipoProveedor.supermercado,
      );

      // Assert
      expect(page1.length, equals(5));
      expect(page2.length, equals(5));
      expect(supermercados.length, equals(5)); // 5 supermercados (even indices)
    });
  });
}