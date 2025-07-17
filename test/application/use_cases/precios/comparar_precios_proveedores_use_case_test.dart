import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sazones_semanales/application/use_cases/precios/comparar_precios_proveedores_use_case.dart';
import 'package:sazones_semanales/domain/entities/proveedor.dart';
import 'package:sazones_semanales/domain/repositories/existencia_repository.dart';
import 'package:sazones_semanales/domain/repositories/proveedor_repository.dart';

import 'comparar_precios_proveedores_use_case_test.mocks.dart';

@GenerateMocks([ExistenciaRepository, ProveedorRepository])
void main() {
  late MockExistenciaRepository mockExistenciaRepository;
  late MockProveedorRepository mockProveedorRepository;
  late CompararPreciosProveedoresUseCase useCase;

  setUp(() {
    mockExistenciaRepository = MockExistenciaRepository();
    mockProveedorRepository = MockProveedorRepository();
    useCase = CompararPreciosProveedoresUseCase(
      mockExistenciaRepository,
      mockProveedorRepository,
    );
  });

  group('CompararPreciosProveedoresUseCase', () {
    test('debería comparar precios entre proveedores correctamente', () async {
      // Arrange
      final historialPrecios = [
        {'proveedorId': 'proveedor-1', 'precio': 25.0},
        {'proveedorId': 'proveedor-1', 'precio': 27.0},
        {'proveedorId': 'proveedor-2', 'precio': 22.0},
        {'proveedorId': 'proveedor-2', 'precio': 24.0},
        {'proveedorId': 'proveedor-3', 'precio': 30.0},
      ];

      final ahora = DateTime.now();
      final proveedor1 = Proveedor(
        id: 'proveedor-1',
        nombre: 'Supermercado A',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: ahora,
        updatedAt: ahora,
      );

      final proveedor2 = Proveedor(
        id: 'proveedor-2',
        nombre: 'Supermercado B',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: ahora,
        updatedAt: ahora,
      );

      final proveedor3 = Proveedor(
        id: 'proveedor-3',
        nombre: 'Tienda C',
        tipo: TipoProveedor.minimarket,
        activo: true,
        createdAt: ahora,
        updatedAt: ahora,
      );

      when(mockExistenciaRepository.obtenerHistorialPrecios('Leche'))
          .thenAnswer((_) async => historialPrecios);
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-1'))
          .thenAnswer((_) async => proveedor1);
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-2'))
          .thenAnswer((_) async => proveedor2);
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-3'))
          .thenAnswer((_) async => proveedor3);

      // Act
      final resultado = await useCase.execute('Leche');

      // Assert
      expect(resultado.nombreProducto, 'Leche');
      expect(resultado.preciosPromedioPorProveedor.length, 3);
      expect(resultado.preciosPromedioPorProveedor['proveedor-1'], 26.0);
      expect(resultado.preciosPromedioPorProveedor['proveedor-2'], 23.0);
      expect(resultado.preciosPromedioPorProveedor['proveedor-3'], 30.0);
      expect(resultado.nombresProveedores['proveedor-1'], 'Supermercado A');
      expect(resultado.nombresProveedores['proveedor-2'], 'Supermercado B');
      expect(resultado.nombresProveedores['proveedor-3'], 'Tienda C');
      expect(resultado.proveedorMasBarato, 'proveedor-2');
      expect(resultado.proveedorMasCaro, 'proveedor-3');
      expect(resultado.diferenciaProcentual, closeTo(30.43, 0.01)); // (30-23)/23*100 = 30.43%
      verify(mockExistenciaRepository.obtenerHistorialPrecios('Leche')).called(1);
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-1')).called(1);
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-2')).called(1);
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-3')).called(1);
    });

    test('debería comparar precios para múltiples productos', () async {
      // Arrange
      final historialPreciosLeche = [
        {'proveedorId': 'proveedor-1', 'precio': 25.0},
        {'proveedorId': 'proveedor-2', 'precio': 22.0},
      ];

      final historialPreciosPan = [
        {'proveedorId': 'proveedor-1', 'precio': 15.0},
        {'proveedorId': 'proveedor-2', 'precio': 18.0},
      ];

      final ahora = DateTime.now();
      final proveedor1 = Proveedor(
        id: 'proveedor-1',
        nombre: 'Supermercado A',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: ahora,
        updatedAt: ahora,
      );

      final proveedor2 = Proveedor(
        id: 'proveedor-2',
        nombre: 'Supermercado B',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: ahora,
        updatedAt: ahora,
      );

      when(mockExistenciaRepository.obtenerHistorialPrecios('Leche'))
          .thenAnswer((_) async => historialPreciosLeche);
      when(mockExistenciaRepository.obtenerHistorialPrecios('Pan'))
          .thenAnswer((_) async => historialPreciosPan);
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-1'))
          .thenAnswer((_) async => proveedor1);
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-2'))
          .thenAnswer((_) async => proveedor2);

      // Act
      final resultado = await useCase.executeMultiple(['Leche', 'Pan']);

      // Assert
      expect(resultado.length, 2);
      expect(resultado['Leche']!.nombreProducto, 'Leche');
      expect(resultado['Leche']!.proveedorMasBarato, 'proveedor-2');
      expect(resultado['Pan']!.nombreProducto, 'Pan');
      expect(resultado['Pan']!.proveedorMasBarato, 'proveedor-1');
      verify(mockExistenciaRepository.obtenerHistorialPrecios('Leche')).called(1);
      verify(mockExistenciaRepository.obtenerHistorialPrecios('Pan')).called(1);
    });
  });
}