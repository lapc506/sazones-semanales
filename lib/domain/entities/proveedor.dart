import 'package:equatable/equatable.dart';

/// Representa un proveedor donde se pueden comprar productos
/// Incluye supermercados, farmacias, ferreterías, etc.
class Proveedor extends Equatable {
  /// Identificador único del proveedor
  final String id;
  
  /// Nombre del proveedor
  final String nombre;
  
  /// Tipo de establecimiento
  final TipoProveedor tipo;
  
  /// Indica si el proveedor está activo
  final bool activo;
  
  /// Dirección del proveedor (opcional)
  final String? direccion;
  
  /// Teléfono del proveedor (opcional)
  final String? telefono;
  
  /// Horarios de atención (opcional)
  final String? horarios;
  
  /// Notas adicionales sobre el proveedor
  final String? notas;
  
  /// Fecha de creación del registro
  final DateTime createdAt;
  
  /// Fecha de última actualización
  final DateTime updatedAt;

  const Proveedor({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.activo = true,
    this.direccion,
    this.telefono,
    this.horarios,
    this.notas,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia del proveedor con campos modificados
  Proveedor copyWith({
    String? id,
    String? nombre,
    TipoProveedor? tipo,
    bool? activo,
    String? direccion,
    String? telefono,
    String? horarios,
    String? notas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Proveedor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      activo: activo ?? this.activo,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      horarios: horarios ?? this.horarios,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Desactiva el proveedor
  Proveedor desactivar() {
    return copyWith(
      activo: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Activa el proveedor
  Proveedor activar() {
    return copyWith(
      activo: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Obtiene el nombre del tipo de proveedor
  String get tipoNombre => tipo.nombre;

  /// Verifica si el proveedor maneja productos alimentarios
  bool get manejaAlimentos {
    return tipo == TipoProveedor.supermercado ||
           tipo == TipoProveedor.minimarket ||
           tipo == TipoProveedor.carniceria ||
           tipo == TipoProveedor.panaderia ||
           tipo == TipoProveedor.verduleria;
  }

  /// Verifica si el proveedor maneja productos de salud
  bool get manejaSalud {
    return tipo == TipoProveedor.farmacia ||
           tipo == TipoProveedor.veterinaria;
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        tipo,
        activo,
        direccion,
        telefono,
        horarios,
        notas,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Proveedor(id: $id, nombre: $nombre, tipo: ${tipo.nombre}, activo: $activo)';
  }
}

/// Tipos de proveedores disponibles
enum TipoProveedor {
  /// Supermercado general
  supermercado,
  
  /// Minimarket o tienda de conveniencia
  minimarket,
  
  /// Farmacia
  farmacia,
  
  /// Ferretería
  ferreteria,
  
  /// Veterinaria
  veterinaria,
  
  /// Vivero o tienda de jardinería
  vivero,
  
  /// Carnicería
  carniceria,
  
  /// Panadería
  panaderia,
  
  /// Verdulería
  verduleria,
  
  /// Tienda de suplementos
  suplementos,
  
  /// Tienda online
  online,
  
  /// Otro tipo de establecimiento
  otro,
}

/// Extensión para obtener nombres legibles de los tipos de proveedor
extension TipoProveedorExtension on TipoProveedor {
  /// Nombre legible del tipo de proveedor
  String get nombre {
    switch (this) {
      case TipoProveedor.supermercado:
        return 'Supermercado';
      case TipoProveedor.minimarket:
        return 'Minimarket';
      case TipoProveedor.farmacia:
        return 'Farmacia';
      case TipoProveedor.ferreteria:
        return 'Ferretería';
      case TipoProveedor.veterinaria:
        return 'Veterinaria';
      case TipoProveedor.vivero:
        return 'Vivero';
      case TipoProveedor.carniceria:
        return 'Carnicería';
      case TipoProveedor.panaderia:
        return 'Panadería';
      case TipoProveedor.verduleria:
        return 'Verdulería';
      case TipoProveedor.suplementos:
        return 'Tienda de Suplementos';
      case TipoProveedor.online:
        return 'Tienda Online';
      case TipoProveedor.otro:
        return 'Otro';
    }
  }

  /// Icono sugerido para el tipo de proveedor
  String get icono {
    switch (this) {
      case TipoProveedor.supermercado:
        return '🛒';
      case TipoProveedor.minimarket:
        return '🏪';
      case TipoProveedor.farmacia:
        return '💊';
      case TipoProveedor.ferreteria:
        return '🔧';
      case TipoProveedor.veterinaria:
        return '🐕';
      case TipoProveedor.vivero:
        return '🌱';
      case TipoProveedor.carniceria:
        return '🥩';
      case TipoProveedor.panaderia:
        return '🍞';
      case TipoProveedor.verduleria:
        return '🥬';
      case TipoProveedor.suplementos:
        return '💪';
      case TipoProveedor.online:
        return '💻';
      case TipoProveedor.otro:
        return '🏢';
    }
  }

  /// Categorías de productos típicas para este tipo de proveedor
  List<String> get categoriasComunes {
    switch (this) {
      case TipoProveedor.supermercado:
        return ['Alimentos', 'Bebidas', 'Limpieza', 'Higiene Personal'];
      case TipoProveedor.minimarket:
        return ['Alimentos', 'Bebidas', 'Snacks'];
      case TipoProveedor.farmacia:
        return ['Medicamentos', 'Vitaminas', 'Higiene Personal', 'Primeros Auxilios'];
      case TipoProveedor.ferreteria:
        return ['Herramientas', 'Materiales', 'Tornillería', 'Pintura'];
      case TipoProveedor.veterinaria:
        return ['Alimento Mascotas', 'Medicamentos Veterinarios', 'Accesorios'];
      case TipoProveedor.vivero:
        return ['Plantas', 'Fertilizantes', 'Herramientas Jardinería', 'Macetas'];
      case TipoProveedor.carniceria:
        return ['Carnes', 'Embutidos', 'Aves'];
      case TipoProveedor.panaderia:
        return ['Pan', 'Pasteles', 'Repostería'];
      case TipoProveedor.verduleria:
        return ['Frutas', 'Verduras', 'Hortalizas'];
      case TipoProveedor.suplementos:
        return ['Proteínas', 'Vitaminas', 'Suplementos Deportivos'];
      case TipoProveedor.online:
        return ['Varios'];
      case TipoProveedor.otro:
        return ['Varios'];
    }
  }
}