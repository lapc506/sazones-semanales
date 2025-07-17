import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sazones_semanales/application/use_cases/precios/calcular_promedios_precios_use_case.dart';
import 'package:sazones_semanales/domain/repositories/existencia_repository.dart';

import 'calcular_promedios_precios_use_case_test.mocks.dart';

@GenerateMocks([ExistenciaRepository])
void main() {
  late MockExistenciaRepository mockRepository;
  late CalcularPromediosPreciosUseCase useCase;

  setUp(() {
    mockRepository = MockExistenciaRepository();
    useCase = CalcularPromediosPreciosUseCase(mockRepository);
  });

  group('CalcularPromediosPreciosUseCase', () {
    test('debería calcular promedios de precios correctamente', () async {
      // Arrange
      final estadisticas = {
        'precioPromedio': 25.5,
        'precioMinimo': 20.0,
        'precioMaximo': 30.0,
        'tendencia': 0.5,
        'cantidadRegistros': 10,
        'fechaUltimoRegistro': DateTime(2025, 7, 15),
      };

      when(mockRepository.obtenerEstadisticasPrecios('Leche'))
          .thenAnswer((_) async => estadisticas);

      // Act
      final resultado = await useCase.execute('Leche');

      // Assert
      expect(resultado.precioPromedio, 25.5);
      expect(resultado.precioMinimo, 20.0);
      expect(resultado.precioMaximo, 30.0);
      expect(resultado.tendencia, 0.5);
      expect(resultado.cantidadRegistros, 10);
      expect(resultado.fechaUltimoRegistro, DateTime(2025, 7, 15));
      verify(mockRepository.obtenerEstadisticasPrecios('Leche')).called(1);
    });

    test('debería calcular promedios para productos más comprados', () async {
      // Arrange
      final productosMasComprados = [
        {'nombreProducto': 'Leche'},
        {'nombreProducto': 'Pan'},
      ];

      final estadisticasLeche = {
        'precioPromedio': 25.5,
        'precioMinimo': 20.0,
        'precioMaximo': 30.0,
        'tendencia': 0.5,
        'cantidadRegistros': 10,
        'fechaUltimoRegistro': DateTime(2025, 7, 15),
      };

      final estadisticasPan = {
        'precioPromedio': 15.0,
        'precioMinimo': 12.0,
        'precioMaximo': 18.0,
        'tendencia': -0.2,
        'cantidadRegistros': 8,
        'fechaUltimoRegistro': DateTime(2025, 7, 14),
      };

      when(mockRepository.obtenerProductosMasComprados(limite: 5))
          .thenAnswer((_) async => productosMasComprados);
      when(mockRepository.obtenerEstadisticasPrecios('Leche'))
          .thenAnswer((_) async => estadisticasLeche);
      when(mockRepository.obtenerEstadisticasPrecios('Pan'))
          .thenAnswer((_) async => estadisticasPan);

      // Act
      final resultado = await useCase.executeParaProductosMasComprados(limite: 5);

      // Assert
      expect(resultado.length, 2);
      expect(resultado['Leche']!.precioPromedio, 25.5);
      expect(resultado['Pan']!.precioPromedio, 15.0);
      verify(mockRepository.obtenerProductosMasComprados(limite: 5)).called(1);
      verify(mockRepository.obtenerEstadisticasPrecios('Leche')).called(1);
      verify(mockRepository.obtenerEstadisticasPrecios('Pan')).called(1);
    });
  });
}