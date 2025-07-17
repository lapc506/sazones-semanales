import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sazones_semanales/application/use_cases/proveedores/agregar_proveedor_use_case.dart';
import 'package:sazones_semanales/domain/entities/proveedor.dart';
import 'package:sazones_semanales/domain/repositories/proveedor_repository.dart';

import 'agregar_proveedor_use_case_test.mocks.dart';

@GenerateMocks([ProveedorRepository])
void main() {
  late MockProveedorRepository mockRepository;
  late AgregarProveedorUseCase useCase;

  setUp(() {
    mockRepository = MockProveedorRepository();
    useCase = AgregarProveedorUseCase(mockRepository);
  });

  group('AgregarProveedorUseCase', () {
    test('debería agregar un proveedor válido', () async {
      // Arrange
      when(mockRepository.existeProveedorConNombre('Supermercado A'))
          .thenAnswer((_) async => false);
      when(mockRepository.guardarProveedor(any)).thenAnswer((_) async {});

      // Act
      final resultado = await useCase.execute(
        nombre: 'Supermercado A',
        tipo: TipoProveedor.supermercado,
        direccion: 'Calle Principal 123',
        telefono: '555-1234',
        horarios: 'Lun-Vie 9-18h',
        notas: 'Buen servicio',
      );

      // Assert
      expect(resultado.esValido, true);
      expect(resultado.errores, isEmpty);
      verify(mockRepository.existeProveedorConNombre('Supermercado A')).called(1);
      verify(mockRepository.guardarProveedor(any)).called(1);
    });

    test('debería rechazar un proveedor con nombre vacío', () async {
      // Act
      final resultado = await useCase.execute(
        nombre: '',
        tipo: TipoProveedor.supermercado,
      );

      // Assert
      expect(resultado.esValido, false);
      expect(resultado.errores, contains('El nombre del proveedor no puede estar vacío'));
      verifyNever(mockRepository.guardarProveedor(any));
    });

    test('debería rechazar un proveedor con nombre muy corto', () async {
      // Act
      final resultado = await useCase.execute(
        nombre: 'AB',
        tipo: TipoProveedor.supermercado,
      );

      // Assert
      expect(resultado.esValido, false);
      expect(resultado.errores, contains('El nombre del proveedor debe tener al menos 3 caracteres'));
      verifyNever(mockRepository.guardarProveedor(any));
    });

    test('debería rechazar un proveedor con nombre duplicado', () async {
      // Arrange
      when(mockRepository.existeProveedorConNombre('Supermercado A'))
          .thenAnswer((_) async => true);

      // Act
      final resultado = await useCase.execute(
        nombre: 'Supermercado A',
        tipo: TipoProveedor.supermercado,
      );

      // Assert
      expect(resultado.esValido, false);
      expect(resultado.errores, contains('Ya existe un proveedor con el nombre "Supermercado A"'));
      verify(mockRepository.existeProveedorConNombre('Supermercado A')).called(1);
      verifyNever(mockRepository.guardarProveedor(any));
    });

    test('debería rechazar un proveedor con teléfono inválido', () async {
      // Arrange
      when(mockRepository.existeProveedorConNombre('Supermercado A'))
          .thenAnswer((_) async => false);

      // Act
      final resultado = await useCase.execute(
        nombre: 'Supermercado A',
        tipo: TipoProveedor.supermercado,
        telefono: 'abc-123',
      );

      // Assert
      expect(resultado.esValido, false);
      expect(resultado.errores, contains('El teléfono debe contener solo dígitos, espacios o guiones'));
      verify(mockRepository.existeProveedorConNombre('Supermercado A')).called(1);
      verifyNever(mockRepository.guardarProveedor(any));
    });

    test('debería rechazar un proveedor con teléfono muy corto', () async {
      // Arrange
      when(mockRepository.existeProveedorConNombre('Supermercado A'))
          .thenAnswer((_) async => false);

      // Act
      final resultado = await useCase.execute(
        nombre: 'Supermercado A',
        tipo: TipoProveedor.supermercado,
        telefono: '123456',
      );

      // Assert
      expect(resultado.esValido, false);
      expect(resultado.errores, contains('El teléfono debe tener al menos 7 dígitos'));
      verify(mockRepository.existeProveedorConNombre('Supermercado A')).called(1);
      verifyNever(mockRepository.guardarProveedor(any));
    });

    test('debería aceptar un proveedor con teléfono válido con formato', () async {
      // Arrange
      when(mockRepository.existeProveedorConNombre('Supermercado A'))
          .thenAnswer((_) async => false);
      when(mockRepository.guardarProveedor(any)).thenAnswer((_) async {});

      // Act
      final resultado = await useCase.execute(
        nombre: 'Supermercado A',
        tipo: TipoProveedor.supermercado,
        telefono: '555-123-4567',
      );

      // Assert
      expect(resultado.esValido, true);
      expect(resultado.errores, isEmpty);
      verify(mockRepository.existeProveedorConNombre('Supermercado A')).called(1);
      verify(mockRepository.guardarProveedor(any)).called(1);
    });
  });
}