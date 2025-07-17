import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sazones_semanales/application/use_cases/proveedores/obtener_historial_proveedor_use_case.dart';
import 'package:sazones_semanales/domain/entities/enums.dart';
import 'package:sazones_semanales/domain/entities/existencia.dart';
import 'package:sazones_semanales/domain/entities/proveedor.dart';
import 'package:sazones_semanales/domain/repositories/existencia_repository.dart';
import 'package:sazones_semanales/domain/repositories/proveedor_repository.dart';

import 'obtener_historial_proveedor_use_case_test.mocks.dart';

@GenerateMocks([ExistenciaRepository, ProveedorRepository])
void main() {
  late MockExistenciaRepository mockExistenciaRepository;
  late MockProveedorRepository mockProveedorRepository;
  late ObtenerHistorialProveedorUseCase useCase;

  setUp(() {
    mockExistenciaRepository = MockExistenciaRepository();
    mockProveedorRepository = MockProveedorRepository();
    useCase = ObtenerHistorialProveedorUseCase(
      mockProveedorRepository,
      mockExistenciaRepository,
    );
  });

  group('ObtenerHistorialProveedorUseCase', () {
    final ahora = DateTime.now();
    final proveedor = Proveedor(
      id: 'proveedor-1',
      nombre: 'Supermercado A',
      tipo: TipoProveedor.supermercado,
      activo: true,
      createdAt: ahora,
      updatedAt: ahora,
    );

    final existencias = [
      Existencia(
        id: 'existencia-1',
        codigoBarras: '12345678',
        nombreProducto: 'Leche',
        categoria: 'Lácteos',
        fechaCompra: ahora,
        precio: 25.50,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
        createdAt: ahora,
        updatedAt: ahora,
      ),
      Existencia(
        id: 'existencia-2',
        codigoBarras: '87654321',
        nombreProducto: 'Pan',
        categoria: 'Panadería',
        fechaCompra: ahora,
        precio: 15.00,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
        createdAt: ahora,
        updatedAt: ahora,
      ),
      Existencia(
        id: 'existencia-3',
        codigoBarras: '12345678',
        nombreProducto: 'Leche',
        categoria: 'Lácteos',
        fechaCompra: ahora.subtract(const Duration(days: 7)),
        precio: 24.00,
        proveedorId: 'proveedor-1',
        perecibilidad: TipoPerecibilidad.perecedero,
        createdAt: ahora.subtract(const Duration(days: 7)),
        updatedAt: ahora.subtract(const Duration(days: 7)),
      ),
    ];

    final estadisticas = {
      'totalCompras': 3,
      'gastoTotal': 64.50,
      'precioPromedio': 21.50,
      'ultimaCompra': ahora,
      'categoriasMasCompradas': ['Lácteos', 'Panadería'],
    };

    final historialCompras = [
      {
        'fecha': ahora,
        'cantidadProductos': 2,
        'total': 40.50,
      },
      {
        'fecha': ahora.subtract(const Duration(days: 7)),
        'cantidadProductos': 1,
        'total': 24.00,
      },
    ];

    test('debería obtener el historial de un proveedor correctamente', () async {
      // Arrange
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-1'))
          .thenAnswer((_) async => proveedor);
      when(mockExistenciaRepository.obtenerExistenciasPorProveedor('proveedor-1'))
          .thenAnswer((_) async => existencias);
      when(mockProveedorRepository.obtenerEstadisticasProveedor('proveedor-1'))
          .thenAnswer((_) async => estadisticas);
      when(mockProveedorRepository.obtenerHistorialCompras('proveedor-1'))
          .thenAnswer((_) async => historialCompras);

      // Act
      final resultado = await useCase.execute(proveedorId: 'proveedor-1');

      // Assert
      expect(resultado, isNotNull);
      expect(resultado!.proveedor, equals(proveedor));
      expect(resultado.existencias, equals(existencias));
      expect(resultado.estadisticas, equals(estadisticas));
      expect(resultado.historialCompras, equals(historialCompras));
      expect(resultado.productosMasComprados.length, 2);
      
      // Verificar que Leche aparece como el producto más comprado (2 veces)
      expect(resultado.productosMasComprados[0]['nombreProducto'], 'Leche');
      expect(resultado.productosMasComprados[0]['cantidad'], 2);
      
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-1')).called(1);
      verify(mockExistenciaRepository.obtenerExistenciasPorProveedor('proveedor-1')).called(1);
      verify(mockProveedorRepository.obtenerEstadisticasProveedor('proveedor-1')).called(1);
      verify(mockProveedorRepository.obtenerHistorialCompras('proveedor-1')).called(1);
    });

    test('debería retornar null si el proveedor no existe', () async {
      // Arrange
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-no-existe'))
          .thenAnswer((_) async => null);

      // Act
      final resultado = await useCase.execute(proveedorId: 'proveedor-no-existe');

      // Assert
      expect(resultado, isNull);
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-no-existe')).called(1);
      verifyNever(mockExistenciaRepository.obtenerExistenciasPorProveedor(any));
      verifyNever(mockProveedorRepository.obtenerEstadisticasProveedor(any));
      verifyNever(mockProveedorRepository.obtenerHistorialCompras(any));
    });

    test('debería limitar la cantidad de existencias retornadas', () async {
      // Arrange
      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-1'))
          .thenAnswer((_) async => proveedor);
      when(mockExistenciaRepository.obtenerExistenciasPorProveedor('proveedor-1'))
          .thenAnswer((_) async => existencias);
      when(mockProveedorRepository.obtenerEstadisticasProveedor('proveedor-1'))
          .thenAnswer((_) async => estadisticas);
      when(mockProveedorRepository.obtenerHistorialCompras('proveedor-1'))
          .thenAnswer((_) async => historialCompras);

      // Act
      final resultado = await useCase.execute(proveedorId: 'proveedor-1', limite: 2);

      // Assert
      expect(resultado, isNotNull);
      expect(resultado!.existencias.length, 2);
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-1')).called(1);
      verify(mockExistenciaRepository.obtenerExistenciasPorProveedor('proveedor-1')).called(1);
    });

    test('debería obtener historial de múltiples proveedores', () async {
      // Arrange
      final proveedor2 = Proveedor(
        id: 'proveedor-2',
        nombre: 'Supermercado B',
        tipo: TipoProveedor.supermercado,
        activo: true,
        createdAt: ahora,
        updatedAt: ahora,
      );

      final existenciasProveedor2 = [
        Existencia(
          id: 'existencia-4',
          codigoBarras: '11223344',
          nombreProducto: 'Huevos',
          categoria: 'Lácteos',
          fechaCompra: ahora,
          precio: 30.00,
          proveedorId: 'proveedor-2',
          perecibilidad: TipoPerecibilidad.perecedero,
          createdAt: ahora,
          updatedAt: ahora,
        ),
      ];

      final estadisticasProveedor2 = {
        'totalCompras': 1,
        'gastoTotal': 30.00,
        'precioPromedio': 30.00,
        'ultimaCompra': ahora,
        'categoriasMasCompradas': ['Lácteos'],
      };

      final historialComprasProveedor2 = [
        {
          'fecha': ahora,
          'cantidadProductos': 1,
          'total': 30.00,
        },
      ];

      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-1'))
          .thenAnswer((_) async => proveedor);
      when(mockExistenciaRepository.obtenerExistenciasPorProveedor('proveedor-1'))
          .thenAnswer((_) async => existencias);
      when(mockProveedorRepository.obtenerEstadisticasProveedor('proveedor-1'))
          .thenAnswer((_) async => estadisticas);
      when(mockProveedorRepository.obtenerHistorialCompras('proveedor-1'))
          .thenAnswer((_) async => historialCompras);

      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-2'))
          .thenAnswer((_) async => proveedor2);
      when(mockExistenciaRepository.obtenerExistenciasPorProveedor('proveedor-2'))
          .thenAnswer((_) async => existenciasProveedor2);
      when(mockProveedorRepository.obtenerEstadisticasProveedor('proveedor-2'))
          .thenAnswer((_) async => estadisticasProveedor2);
      when(mockProveedorRepository.obtenerHistorialCompras('proveedor-2'))
          .thenAnswer((_) async => historialComprasProveedor2);

      when(mockProveedorRepository.obtenerProveedorPorId('proveedor-no-existe'))
          .thenAnswer((_) async => null);

      // Act
      final resultados = await useCase.executeMultiple([
        'proveedor-1',
        'proveedor-2',
        'proveedor-no-existe',
      ]);

      // Assert
      expect(resultados.length, 2);
      expect(resultados.containsKey('proveedor-1'), true);
      expect(resultados.containsKey('proveedor-2'), true);
      expect(resultados.containsKey('proveedor-no-existe'), false);
      
      expect(resultados['proveedor-1']!.proveedor, equals(proveedor));
      expect(resultados['proveedor-2']!.proveedor, equals(proveedor2));
      
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-1')).called(1);
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-2')).called(1);
      verify(mockProveedorRepository.obtenerProveedorPorId('proveedor-no-existe')).called(1);
    });
  });
}