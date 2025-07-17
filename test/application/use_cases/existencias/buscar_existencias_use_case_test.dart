import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sazones_semanales/application/use_cases/existencias/buscar_existencias_use_case.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/repositories/existencia_repository.dart';

import 'buscar_existencias_use_case_test.mocks.dart';

@GenerateMocks([ExistenciaRepository])
void main() {
  late MockExistenciaRepository mockRepository;
  late BuscarExistenciasUseCase useCase;

  setUp(() {
    mockRepository = MockExistenciaRepository();
    useCase = BuscarExistenciasUseCase(mockRepository);
  });

  group('BuscarExistenciasUseCase', () {
    final existencias = [
      Existencia(
        id: 'existencia-1',
        codigoBarras: '12345678',
        nombreProducto: 'Leche',
        categoria: 'Lácteos',
        fechaCompra: DateTime.now(),
        fechaCaducidad: DateTime.now().add(const Duration(days: 7)),
        precio: 25.50,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Existencia(
        id: 'existencia-2',
        codigoBarras: '87654321',
        nombreProducto: 'Pan',
        categoria: 'Panadería',
        fechaCompra: DateTime.now(),
        fechaCaducidad: DateTime.now().add(const Duration(days: 3)),
        precio: 15.00,
        proveedorId: 'proveedor-2',
        perecibilidad: TipoPerecibilidad.perecedero,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test('debería retornar existencias activas cuando no hay filtros', () async {
      // Arrange
      when(mockRepository.obtenerExistenciasActivas())
          .thenAnswer((_) async => existencias);

      // Act
      final resultado = await useCase.execute(FiltrosBusquedaExistencias());

      // Assert
      expect(resultado, equals(existencias));
      verify(mockRepository.obtenerExistenciasActivas()).called(1);
      verifyNever(mockRepository.buscarExistenciasConFiltros());
    });

    test('debería buscar existencias con filtros cuando se proporcionan', () async {
      // Arrange
      final filtros = FiltrosBusquedaExistencias(
        nombreProducto: 'Leche',
        categoria: 'Lácteos',
        estado: EstadoExistencia.disponible,
      );

      when(mockRepository.buscarExistenciasConFiltros(
        nombreProducto: 'Leche',
        categoria: 'Lácteos',
        estado: EstadoExistencia.disponible,
        limite: 50,
      )).thenAnswer((_) async => [existencias[0]]);

      // Act
      final resultado = await useCase.execute(filtros);

      // Assert
      expect(resultado, equals([existencias[0]]));
      verify(mockRepository.buscarExistenciasConFiltros(
        nombreProducto: 'Leche',
        categoria: 'Lácteos',
        estado: EstadoExistencia.disponible,
        limite: 50,
      )).called(1);
      verifyNever(mockRepository.obtenerExistenciasActivas());
    });

    test('debería buscar por código de barras', () async {
      // Arrange
      when(mockRepository.buscarPorCodigoBarras('12345678'))
          .thenAnswer((_) async => [existencias[0]]);

      // Act
      final resultado = await useCase.buscarPorCodigoBarras('12345678');

      // Assert
      expect(resultado, equals([existencias[0]]));
      verify(mockRepository.buscarPorCodigoBarras('12345678')).called(1);
    });

    test('debería buscar por nombre de producto', () async {
      // Arrange
      when(mockRepository.buscarPorNombreProducto('Leche'))
          .thenAnswer((_) async => [existencias[0]]);

      // Act
      final resultado = await useCase.buscarPorNombreProducto('Leche');

      // Assert
      expect(resultado, equals([existencias[0]]));
      verify(mockRepository.buscarPorNombreProducto('Leche')).called(1);
    });

    test('debería obtener existencias próximas a caducar', () async {
      // Arrange
      when(mockRepository.obtenerExistenciasProximasACaducar())
          .thenAnswer((_) async => existencias);

      // Act
      final resultado = await useCase.obtenerProximasACaducar();

      // Assert
      expect(resultado, equals(existencias));
      verify(mockRepository.obtenerExistenciasProximasACaducar()).called(1);
    });

    test('debería obtener existencias por categoría', () async {
      // Arrange
      when(mockRepository.obtenerExistenciasPorCategoria('Lácteos'))
          .thenAnswer((_) async => [existencias[0]]);

      // Act
      final resultado = await useCase.obtenerPorCategoria('Lácteos');

      // Assert
      expect(resultado, equals([existencias[0]]));
      verify(mockRepository.obtenerExistenciasPorCategoria('Lácteos')).called(1);
    });

    test('debería obtener existencias por proveedor', () async {
      // Arrange
      when(mockRepository.obtenerExistenciasPorProveedor('proveedor-1'))
          .thenAnswer((_) async => [existencias[0]]);

      // Act
      final resultado = await useCase.obtenerPorProveedor('proveedor-1');

      // Assert
      expect(resultado, equals([existencias[0]]));
      verify(mockRepository.obtenerExistenciasPorProveedor('proveedor-1')).called(1);
    });

    test('debería obtener existencias por estado', () async {
      // Arrange
      when(mockRepository.obtenerExistenciasPorEstado(EstadoExistencia.disponible))
          .thenAnswer((_) async => existencias);

      // Act
      final resultado = await useCase.obtenerPorEstado(EstadoExistencia.disponible);

      // Assert
      expect(resultado, equals(existencias));
      verify(mockRepository.obtenerExistenciasPorEstado(EstadoExistencia.disponible)).called(1);
    });
  });
}