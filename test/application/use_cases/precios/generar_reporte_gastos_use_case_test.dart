import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sazones_semanales/application/use_cases/precios/generar_reporte_gastos_use_case.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/repositories/existencia_repository.dart';

import 'generar_reporte_gastos_use_case_test.mocks.dart';

@GenerateMocks([ExistenciaRepository])
void main() {
  late MockExistenciaRepository mockRepository;
  late GenerarReporteGastosUseCase useCase;

  setUp(() {
    mockRepository = MockExistenciaRepository();
    useCase = GenerarReporteGastosUseCase(mockRepository);
  });

  group('GenerarReporteGastosUseCase', () {
    final fechaInicio = DateTime(2025, 1, 1);
    final fechaFin = DateTime(2025, 3, 31);

    test('debería generar reporte por categoría correctamente', () async {
      // Arrange
      final gastosPorCategoria = [
        {'nombre': 'Lácteos', 'gasto': 500.0},
        {'nombre': 'Panadería', 'gasto': 300.0},
        {'nombre': 'Frutas', 'gasto': 200.0},
      ];

      when(mockRepository.obtenerGastosPorCategoria(fechaInicio, fechaFin))
          .thenAnswer((_) async => gastosPorCategoria);

      // Act
      final resultado = await useCase.execute(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        tipoAgrupacion: TipoAgrupacionReporte.categoria,
      );

      // Assert
      expect(resultado.fechaInicio, fechaInicio);
      expect(resultado.fechaFin, fechaFin);
      expect(resultado.gastoTotal, 1000.0);
      expect(resultado.tipoAgrupacion, TipoAgrupacionReporte.categoria);
      expect(resultado.gastosAgrupados.length, 3);
      expect(resultado.gastosAgrupados['Lácteos'], 500.0);
      expect(resultado.gastosAgrupados['Panadería'], 300.0);
      expect(resultado.gastosAgrupados['Frutas'], 200.0);
      expect(resultado.porcentajesPorGrupo['Lácteos'], 50.0);
      expect(resultado.porcentajesPorGrupo['Panadería'], 30.0);
      expect(resultado.porcentajesPorGrupo['Frutas'], 20.0);
      verify(mockRepository.obtenerGastosPorCategoria(fechaInicio, fechaFin)).called(1);
    });

    test('debería generar reporte por proveedor correctamente', () async {
      // Arrange
      final gastosPorProveedor = [
        {'nombre': 'Supermercado A', 'gasto': 600.0},
        {'nombre': 'Supermercado B', 'gasto': 400.0},
      ];

      when(mockRepository.obtenerGastosPorProveedor(fechaInicio, fechaFin))
          .thenAnswer((_) async => gastosPorProveedor);

      // Act
      final resultado = await useCase.execute(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        tipoAgrupacion: TipoAgrupacionReporte.proveedor,
      );

      // Assert
      expect(resultado.gastoTotal, 1000.0);
      expect(resultado.tipoAgrupacion, TipoAgrupacionReporte.proveedor);
      expect(resultado.gastosAgrupados.length, 2);
      expect(resultado.gastosAgrupados['Supermercado A'], 600.0);
      expect(resultado.gastosAgrupados['Supermercado B'], 400.0);
      expect(resultado.porcentajesPorGrupo['Supermercado A'], 60.0);
      expect(resultado.porcentajesPorGrupo['Supermercado B'], 40.0);
      verify(mockRepository.obtenerGastosPorProveedor(fechaInicio, fechaFin)).called(1);
    });

    test('debería generar reporte por mes correctamente', () async {
      // Arrange
      final existencias = [
        Existencia(
          id: 'existencia-1',
          codigoBarras: '12345678',
          nombreProducto: 'Leche',
          categoria: 'Lácteos',
          fechaCompra: DateTime(2025, 1, 15),
          precio: 300.0,
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
          fechaCompra: DateTime(2025, 2, 10),
          precio: 200.0,
          proveedorId: 'proveedor-2',
          perecibilidad: TipoPerecibilidad.perecedero,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Existencia(
          id: 'existencia-3',
          codigoBarras: '11223344',
          nombreProducto: 'Manzanas',
          categoria: 'Frutas',
          fechaCompra: DateTime(2025, 3, 5),
          precio: 150.0,
          proveedorId: 'proveedor-1',
          perecibilidad: TipoPerecibilidad.perecedero,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.obtenerExistenciasPorRangoFechas(fechaInicio, fechaFin))
          .thenAnswer((_) async => existencias);

      // Act
      final resultado = await useCase.execute(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        tipoAgrupacion: TipoAgrupacionReporte.mes,
      );

      // Assert
      expect(resultado.gastoTotal, 650.0);
      expect(resultado.tipoAgrupacion, TipoAgrupacionReporte.mes);
      expect(resultado.gastosAgrupados.length, 3);
      expect(resultado.gastosAgrupados['2025-01'], 300.0);
      expect(resultado.gastosAgrupados['2025-02'], 200.0);
      expect(resultado.gastosAgrupados['2025-03'], 150.0);
      expect(resultado.porcentajesPorGrupo['2025-01'], closeTo(46.15, 0.01));
      expect(resultado.porcentajesPorGrupo['2025-02'], closeTo(30.77, 0.01));
      expect(resultado.porcentajesPorGrupo['2025-03'], closeTo(23.08, 0.01));
      verify(mockRepository.obtenerExistenciasPorRangoFechas(fechaInicio, fechaFin)).called(1);
    });

    test('debería generar reporte por semana correctamente', () async {
      // Arrange
      final existencias = [
        Existencia(
          id: 'existencia-1',
          codigoBarras: '12345678',
          nombreProducto: 'Leche',
          categoria: 'Lácteos',
          fechaCompra: DateTime(2025, 1, 5), // Semana 1
          precio: 300.0,
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
          fechaCompra: DateTime(2025, 1, 12), // Semana 2
          precio: 200.0,
          proveedorId: 'proveedor-2',
          perecibilidad: TipoPerecibilidad.perecedero,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Existencia(
          id: 'existencia-3',
          codigoBarras: '11223344',
          nombreProducto: 'Manzanas',
          categoria: 'Frutas',
          fechaCompra: DateTime(2025, 1, 19), // Semana 3
          precio: 150.0,
          proveedorId: 'proveedor-1',
          perecibilidad: TipoPerecibilidad.perecedero,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.obtenerExistenciasPorRangoFechas(fechaInicio, fechaFin))
          .thenAnswer((_) async => existencias);

      // Act
      final resultado = await useCase.execute(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        tipoAgrupacion: TipoAgrupacionReporte.semana,
      );

      // Assert
      expect(resultado.gastoTotal, 650.0);
      expect(resultado.tipoAgrupacion, TipoAgrupacionReporte.semana);
      expect(resultado.gastosAgrupados.length, 3);
      // No verificamos los nombres exactos de las semanas porque dependen del cálculo interno
      expect(resultado.gastosAgrupados.values.toList()..sort(), [150.0, 200.0, 300.0]);
      verify(mockRepository.obtenerExistenciasPorRangoFechas(fechaInicio, fechaFin)).called(1);
    });
  });
}