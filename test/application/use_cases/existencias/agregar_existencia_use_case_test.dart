import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sazones_semanales/application/use_cases/existencias/agregar_existencia_use_case.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/domain/repositories/existencia_repository.dart';

import 'agregar_existencia_use_case_test.mocks.dart';

@GenerateMocks([ExistenciaRepository])
void main() {
  late MockExistenciaRepository mockRepository;
  late AgregarExistenciaUseCase useCase;

  setUp(() {
    mockRepository = MockExistenciaRepository();
    useCase = AgregarExistenciaUseCase(mockRepository);
  });

  group('AgregarExistenciaUseCase', () {
    test('debería agregar una existencia válida', () async {
      // Arrange
      when(mockRepository.guardarExistencia(any)).thenAnswer((_) async {});

      // Act
      final resultado = await useCase.execute(
        codigoBarras: '12345678',
        nombreProducto: 'Leche',
        categoria: 'Lácteos',
        fechaCompra: DateTime.now(),
        fechaCaducidad: DateTime.now().add(const Duration(days: 7)),
        precio: 25.50,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
      );

      // Assert
      expect(resultado.esValido, true);
      expect(resultado.errores, isEmpty);
      verify(mockRepository.guardarExistencia(any)).called(1);
    });

    test('debería rechazar una existencia con código de barras vacío', () async {
      // Act
      final resultado = await useCase.execute(
        codigoBarras: '',
        nombreProducto: 'Leche',
        categoria: 'Lácteos',
        fechaCompra: DateTime.now(),
        fechaCaducidad: DateTime.now().add(const Duration(days: 7)),
        precio: 25.50,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
      );

      // Assert
      expect(resultado.esValido, false);
      expect(resultado.errores, contains('El código de barras no puede estar vacío'));
      verifyNever(mockRepository.guardarExistencia(any));
    });

    test('debería rechazar una existencia con nombre de producto vacío', () async {
      // Act
      final resultado = await useCase.execute(
        codigoBarras: '12345678',
        nombreProducto: '',
        categoria: 'Lácteos',
        fechaCompra: DateTime.now(),
        fechaCaducidad: DateTime.now().add(const Duration(days: 7)),
        precio: 25.50,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
      );

      // Assert
      expect(resultado.esValido, false);
      expect(resultado.errores, contains('El nombre del producto no puede estar vacío'));
      verifyNever(mockRepository.guardarExistencia(any));
    });

    test('debería rechazar una existencia con precio negativo', () async {
      // Act
      final resultado = await useCase.execute(
        codigoBarras: '12345678',
        nombreProducto: 'Leche',
        categoria: 'Lácteos',
        fechaCompra: DateTime.now(),
        fechaCaducidad: DateTime.now().add(const Duration(days: 7)),
        precio: -10.0,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
      );

      // Assert
      expect(resultado.esValido, false);
      expect(resultado.errores, contains('El precio debe ser mayor que cero'));
      verifyNever(mockRepository.guardarExistencia(any));
    });

    test('debería rechazar una existencia con fecha de caducidad anterior a la fecha de compra', () async {
      // Arrange
      final fechaCompra = DateTime.now();
      final fechaCaducidad = fechaCompra.subtract(const Duration(days: 1));

      // Act
      final resultado = await useCase.execute(
        codigoBarras: '12345678',
        nombreProducto: 'Leche',
        categoria: 'Lácteos',
        fechaCompra: fechaCompra,
        fechaCaducidad: fechaCaducidad,
        precio: 25.50,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
      );

      // Assert
      expect(resultado.esValido, false);
      expect(resultado.errores, contains('La fecha de caducidad no puede ser anterior a la fecha de compra'));
      verifyNever(mockRepository.guardarExistencia(any));
    });

    test('debería rechazar una existencia con fecha de compra futura', () async {
      // Arrange
      final fechaCompra = DateTime.now().add(const Duration(days: 1));

      // Act
      final resultado = await useCase.execute(
        codigoBarras: '12345678',
        nombreProducto: 'Leche',
        categoria: 'Lácteos',
        fechaCompra: fechaCompra,
        fechaCaducidad: fechaCompra.add(const Duration(days: 7)),
        precio: 25.50,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
      );

      // Assert
      expect(resultado.esValido, false);
      expect(resultado.errores, contains('La fecha de compra no puede ser futura'));
      verifyNever(mockRepository.guardarExistencia(any));
    });
  });
}