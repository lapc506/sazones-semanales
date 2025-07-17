import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Representa una existencia individual de un producto en el inventario
/// Cada existencia tiene su propio código de barras y datos específicos
class Existencia extends Equatable {
  /// Identificador único de la existencia
  final String id;
  
  /// Código de barras específico de esta existencia
  final String codigoBarras;
  
  /// Nombre del producto
  final String nombreProducto;
  
  /// Categoría del producto
  final String categoria;
  
  /// Fecha en que se compró el producto
  final DateTime fechaCompra;
  
  /// Fecha de caducidad específica de esta existencia
  final DateTime? fechaCaducidad;
  
  /// Precio pagado por esta existencia específica
  final double precio;
  
  /// ID del proveedor donde se compró
  final String proveedorId;
  
  /// Tipo de perecibilidad del producto
  final TipoPerecibilidad perecibilidad;
  
  /// Estado actual de la existencia
  final EstadoExistencia estado;
  
  /// Metadatos adicionales para modos especializados
  final Map<String, dynamic> metadatos;
  
  /// Fecha de creación del registro
  final DateTime createdAt;
  
  /// Fecha de última actualización
  final DateTime updatedAt;

  const Existencia({
    required this.id,
    required this.codigoBarras,
    required this.nombreProducto,
    required this.categoria,
    required this.fechaCompra,
    this.fechaCaducidad,
    required this.precio,
    required this.proveedorId,
    required this.perecibilidad,
    this.estado = EstadoExistencia.disponible,
    this.metadatos = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia de la existencia con campos modificados
  Existencia copyWith({
    String? id,
    String? codigoBarras,
    String? nombreProducto,
    String? categoria,
    DateTime? fechaCompra,
    DateTime? fechaCaducidad,
    double? precio,
    String? proveedorId,
    TipoPerecibilidad? perecibilidad,
    EstadoExistencia? estado,
    Map<String, dynamic>? metadatos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Existencia(
      id: id ?? this.id,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      categoria: categoria ?? this.categoria,
      fechaCompra: fechaCompra ?? this.fechaCompra,
      fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
      precio: precio ?? this.precio,
      proveedorId: proveedorId ?? this.proveedorId,
      perecibilidad: perecibilidad ?? this.perecibilidad,
      estado: estado ?? this.estado,
      metadatos: metadatos ?? this.metadatos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Marca la existencia como consumida
  Existencia marcarComoConsumida() {
    return copyWith(
      estado: EstadoExistencia.consumida,
      updatedAt: DateTime.now(),
    );
  }

  /// Marca la existencia como caducada
  Existencia marcarComoCaducada() {
    return copyWith(
      estado: EstadoExistencia.caducada,
      updatedAt: DateTime.now(),
    );
  }

  /// Verifica si la existencia está próxima a caducar
  bool get estaProximaACaducar {
    if (fechaCaducidad == null) return false;
    
    final ahora = DateTime.now();
    final diferencia = fechaCaducidad!.difference(ahora).inDays;
    
    switch (perecibilidad) {
      case TipoPerecibilidad.perecedero:
        return diferencia <= 2;
      case TipoPerecibilidad.semiPerecedero:
        return diferencia <= 5;
      case TipoPerecibilidad.pocoPerecedero:
        return diferencia <= 15;
      case TipoPerecibilidad.noPerecedero:
        return diferencia <= 90;
    }
  }

  /// Verifica si la existencia ya caducó
  bool get haCaducado {
    if (fechaCaducidad == null) return false;
    return DateTime.now().isAfter(fechaCaducidad!);
  }

  /// Verifica si la existencia está disponible para consumo
  bool get estaDisponible {
    return estado == EstadoExistencia.disponible && !haCaducado;
  }

  @override
  List<Object?> get props => [
        id,
        codigoBarras,
        nombreProducto,
        categoria,
        fechaCompra,
        fechaCaducidad,
        precio,
        proveedorId,
        perecibilidad,
        estado,
        metadatos,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Existencia(id: $id, nombreProducto: $nombreProducto, estado: $estado, fechaCaducidad: $fechaCaducidad)';
  }
}

