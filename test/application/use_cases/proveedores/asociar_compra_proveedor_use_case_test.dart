import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sazones_semanales/application/use_cases/proveedores/asociar_compra_proveedor_use_case.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/entities/proveedor.dart';
import 'package:sazones_semanales/domain/repositories/existencia_repository.dart';
import 'package:sazones_semanales/domain/repositories/proveedor_repository.dart';

import 'asociar_compra_proveedor_use_case_test.mocks.dart';

@GenerateMocks([ExistenciaRepository, ProveedorRepository])
void main() {
  late MockExistenciaRepository mockExistenciaRepository;
  late MockProveedorRepository mockProveedorRepository;
  late AsociarCompraProveedorUseCase useCase;

  setUp(() {
    mockExistenciaRepository = MockExistenciaRepository();
    mockProveedorRepository = MockProveedorRepository();
    useCase = AsociarCompraProveedorUseCase(
      mockExistenciaRepository,
      mockProveedorRepository,
    );
  });

  group('AsociarCompraProveedorUseCase', () {
    final ahora = DateTime.now();
    final proveedor = Proveedor(
      id: 'proveedor-1',
      nombre: 'Supermercado A',
      tipo: TipoProveedor.supermercado,
      activo: true,
      createdAt: ahora,
      updatedAt: ahora,
    );

    final proveedorInactivo = Proveedor(
      id: 'proveedor-2',
      nombre: 'Supermercado B',
      tipo: TipoProveedor.supermercado,
      activo: false,
      createdAt: ahora,
      updatedAt: ahora,
    );

    final existencia1 = Existencia(
      id: 'existencia-1',
      codigoBarras: '12345678',
      nombreProducto: 'Leche',
      categoria: 'Lácteos',
      fechaCompra: ahora,
      precio: 25.50,
      proveedorId: 'proveedor-viejo',
      perecibilidad: TipoPerecibilidad.perecedero,
      createdAt: ahora,
      updatedAt: ahora,
    );

    final existencia2 = Existencia(
      id: 'existencia-2',
      codigoBarras: '87654321',
      nombreProducto: 'Pan',
      categoria: 'Panadería',
      fechaCompra: ahora,
      precio: 15.00,
      proveedorId: 'proveedor-viejo',
      perecibilidad: TipoPerecibilidad.perecedero,
      createdAt: ahora,
      updatedAt: ahora,
    );

    test('debería asociar existencias a un proveedor correctamente', () async {
      // Arrange
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-1'))
          .thenAnswer((_) async => proveedor);
      when(mockExistenciaRepository.obtenerExistenciaPorId('existencia-1'))
          .thenAnswer((_) async => existencia1);
      when(mockExistenciaRepository.obtenerExistenciaPorId('existencia-2'))
          .thenAnswer((_) async => existencia2);
      when(mockExistenciaRepository.actualizarExistencia(any))
          .thenAnswer((_) async {});

      // Act
      final resultado = await useCase.execute(
        proveedorId: 'proveedor-1',
        existenciaIds: ['existencia-1', 'existencia-2'],
      );

      // Assert
      expect(resultado.exito, true);
      expect(resultado.existenciasActualizadas.length, 2);
      expect(resultado.existenciasActualizadas, contains('existencia-1'));
      expect(resultado.existenciasActualizadas, contains('existencia-2'));
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-1')).called(1);
      verify(mockExistenciaRepository.obtenerExistenciaPorId('existencia-1')).called(1);
      verify(mockExistenciaRepository.obtenerExistenciaPorId('existencia-2')).called(1);
      verify(mockExistenciaRepository.actualizarExistencia(any)).called(2);
    });

    test('debería fallar si el proveedor no existe', () async {
      // Arrange
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-no-existe'))
          .thenAnswer((_) async => null);

      // Act
      final resultado = await useCase.execute(
        proveedorId: 'proveedor-no-existe',
        existenciaIds: ['existencia-1', 'existencia-2'],
      );

      // Assert
      expect(resultado.exito, false);
      expect(resultado.mensaje, 'El proveedor no existe');
      expect(resultado.existenciasActualizadas, isEmpty);
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-no-existe')).called(1);
      verifyNever(mockExistenciaRepository.obtenerExistenciaPorId(any));
      verifyNever(mockExistenciaRepository.actualizarExistencia(any));
    });

    test('debería fallar si el proveedor está inactivo', () async {
      // Arrange
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-2'))
          .thenAnswer((_) async => proveedorInactivo);

      // Act
      final resultado = await useCase.execute(
        proveedorId: 'proveedor-2',
        existenciaIds: ['existencia-1', 'existencia-2'],
      );

      // Assert
      expect(resultado.exito, false);
      expect(resultado.mensaje, 'El proveedor no está activo');
      expect(resultado.existenciasActualizadas, isEmpty);
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-2')).called(1);
      verifyNever(mockExistenciaRepository.obtenerExistenciaPorId(any));
      verifyNever(mockExistenciaRepository.actualizarExistencia(any));
    });

    test('debería fallar si la lista de existencias está vacía', () async {
      // Arrange
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-1'))
          .thenAnswer((_) async => proveedor);

      // Act
      final resultado = await useCase.execute(
        proveedorId: 'proveedor-1',
        existenciaIds: [],
      );

      // Assert
      expect(resultado.exito, false);
      expect(resultado.mensaje, 'No hay existencias para asociar');
      expect(resultado.existenciasActualizadas, isEmpty);
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-1')).called(1);
      verifyNever(mockExistenciaRepository.obtenerExistenciaPorId(any));
      verifyNever(mockExistenciaRepository.actualizarExistencia(any));
    });

    test('debería manejar existencias no encontradas', () async {
      // Arrange
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-1'))
          .thenAnswer((_) async => proveedor);
      when(mockExistenciaRepository.obtenerExistenciaPorId('existencia-1'))
          .thenAnswer((_) async => existencia1);
      when(mockExistenciaRepository.obtenerExistenciaPorId('existencia-no-existe'))
          .thenAnswer((_) async => null);
      when(mockExistenciaRepository.actualizarExistencia(any))
          .thenAnswer((_) async {});

      // Act
      final resultado = await useCase.execute(
        proveedorId: 'proveedor-1',
        existenciaIds: ['existencia-1', 'existencia-no-existe'],
      );

      // Assert
      expect(resultado.exito, true);
      expect(resultado.existenciasActualizadas.length, 1);
      expect(resultado.existenciasActualizadas, contains('existencia-1'));
      expect(resultado.mensaje, 'Se actualizaron 1 de 2 existencias');
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-1')).called(1);
      verify(mockExistenciaRepository.obtenerExistenciaPorId('existencia-1')).called(1);
      verify(mockExistenciaRepository.obtenerExistenciaPorId('existencia-no-existe')).called(1);
      verify(mockExistenciaRepository.actualizarExistencia(any)).called(1);
    });

    test('debería asociar existencias por fecha correctamente', () async {
      // Arrange
      final fechaCompra = DateTime(2025, 7, 15);
      final fechaInicio = DateTime(2025, 7, 15);
      final fechaFin = fechaInicio.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
      
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-1'))
          .thenAnswer((_) async => proveedor);
      when(mockExistenciaRepository.obtenerExistenciasPorRangoFechas(fechaInicio, fechaFin))
          .thenAnswer((_) async => [existencia1, existencia2]);
      when(mockExistenciaRepository.obtenerExistenciaPorId('existencia-1'))
          .thenAnswer((_) async => existencia1);
      when(mockExistenciaRepository.obtenerExistenciaPorId('existencia-2'))
          .thenAnswer((_) async => existencia2);
      when(mockExistenciaRepository.actualizarExistencia(any))
          .thenAnswer((_) async {});

      // Act
      final resultado = await useCase.executePorFecha(
        proveedorId: 'proveedor-1',
        fechaCompra: fechaCompra,
      );

      // Assert
      expect(resultado.exito, true);
      expect(resultado.existenciasActualizadas.length, 2);
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-1')).called(2);
      verify(mockExistenciaRepository.obtenerExistenciasPorRangoFechas(fechaInicio, fechaFin)).called(1);
      verify(mockExistenciaRepository.obtenerExistenciaPorId('existencia-1')).called(1);
      verify(mockExistenciaRepository.obtenerExistenciaPorId('existencia-2')).called(1);
      verify(mockExistenciaRepository.actualizarExistencia(any)).called(2);
    });

    test('debería fallar si no hay existencias para la fecha seleccionada', () async {
      // Arrange
      final fechaCompra = DateTime(2025, 7, 15);
      final fechaInicio = DateTime(2025, 7, 15);
      final fechaFin = fechaInicio.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
      
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-1'))
          .thenAnswer((_) async => proveedor);
      when(mockExistenciaRepository.obtenerExistenciasPorRangoFechas(fechaInicio, fechaFin))
          .thenAnswer((_) async => []);

      // Act
      final resultado = await useCase.executePorFecha(
        proveedorId: 'proveedor-1',
        fechaCompra: fechaCompra,
      );

      // Assert
      expect(resultado.exito, false);
      expect(resultado.mensaje, 'No hay existencias para la fecha seleccionada');
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-1')).called(1);
      verify(mockExistenciaRepository.obtenerExistenciasPorRangoFechas(fechaInicio, fechaFin)).called(1);
      verifyNever(mockExistenciaRepository.obtenerExistenciaPorId(any));
      verifyNever(mockExistenciaRepository.actualizarExistencia(any));
    });
  });
}