import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sazones_semanales/application/use_cases/existencias/marcar_como_consumida_use_case.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/repositories/existencia_repository.dart';

import 'marcar_como_consumida_use_case_test.mocks.dart';

@GenerateMocks([ExistenciaRepository])
void main() {
  late MockExistenciaRepository mockRepository;
  late MarcarComoConsumidaUseCase useCase;

  setUp(() {
    mockRepository = MockExistenciaRepository();
    useCase = MarcarComoConsumidaUseCase(mockRepository);
  });

  group('MarcarComoConsumidaUseCase', () {
    final existencia = Existencia(
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
    );

    test('debería marcar una existencia como consumida exitosamente', () async {
      // Arrange
      when(mockRepository.obtenerExistenciaPorId('existencia-1'))
          .thenAnswer((_) async => existencia);
      when(mockRepository.marcarComoConsumida('existencia-1'))
          .thenAnswer((_) async {});

      // Act
      final resultado = await useCase.execute('existencia-1');

      // Assert
      expect(resultado, true);
      verify(mockRepository.obtenerExistenciaPorId('existencia-1')).called(1);
      verify(mockRepository.marcarComoConsumida('existencia-1')).called(1);
    });

    test('debería retornar false si la existencia no existe', () async {
      // Arrange
      when(mockRepository.obtenerExistenciaPorId('existencia-no-existe'))
          .thenAnswer((_) async => null);

      // Act
      final resultado = await useCase.execute('existencia-no-existe');

      // Assert
      expect(resultado, false);
      verify(mockRepository.obtenerExistenciaPorId('existencia-no-existe')).called(1);
      verifyNever(mockRepository.marcarComoConsumida(any));
    });

    test('debería retornar false si ocurre un error', () async {
      // Arrange
      when(mockRepository.obtenerExistenciaPorId('existencia-1'))
          .thenThrow(Exception('Error de base de datos'));

      // Act
      final resultado = await useCase.execute('existencia-1');

      // Assert
      expect(resultado, false);
      verify(mockRepository.obtenerExistenciaPorId('existencia-1')).called(1);
      verifyNever(mockRepository.marcarComoConsumida(any));
    });

    test('debería marcar múltiples existencias como consumidas', () async {
      // Arrange
      final ids = ['existencia-1', 'existencia-2', 'existencia-3'];
      when(mockRepository.marcarMultiplesComoConsumidas(ids))
          .thenAnswer((_) async {});

      // Act
      final resultado = await useCase.executeMultiple(ids);

      // Assert
      expect(resultado, 3);
      verify(mockRepository.marcarMultiplesComoConsumidas(ids)).called(1);
    });

    test('debería manejar errores al marcar múltiples existencias', () async {
      // Arrange
      final ids = ['existencia-1', 'existencia-2', 'existencia-3'];
      when(mockRepository.marcarMultiplesComoConsumidas(ids))
          .thenThrow(Exception('Error de base de datos'));
      
      // Configurar comportamiento individual para cada ID
      when(mockRepository.obtenerExistenciaPorId('existencia-1'))
          .thenAnswer((_) async => existencia);
      when(mockRepository.marcarComoConsumida('existencia-1'))
          .thenAnswer((_) async {});
          
      when(mockRepository.obtenerExistenciaPorId('existencia-2'))
          .thenAnswer((_) async => null);
          
      when(mockRepository.obtenerExistenciaPorId('existencia-3'))
          .thenAnswer((_) async => existencia);
      when(mockRepository.marcarComoConsumida('existencia-3'))
          .thenAnswer((_) async {});

      // Act
      final resultado = await useCase.executeMultiple(ids);

      // Assert
      expect(resultado, 2); // Solo 2 existencias se marcaron exitosamente
      verify(mockRepository.marcarMultiplesComoConsumidas(ids)).called(1);
      verify(mockRepository.obtenerExistenciaPorId('existencia-1')).called(1);
      verify(mockRepository.marcarComoConsumida('existencia-1')).called(1);
      verify(mockRepository.obtenerExistenciaPorId('existencia-2')).called(1);
      verify(mockRepository.obtenerExistenciaPorId('existencia-3')).called(1);
      verify(mockRepository.marcarComoConsumida('existencia-3')).called(1);
    });

    test('debería retornar 0 si la lista de IDs está vacía', () async {
      // Act
      final resultado = await useCase.executeMultiple([]);

      // Assert
      expect(resultado, 0);
      verifyNever(mockRepository.marcarMultiplesComoConsumidas(any));
    });
  });
}