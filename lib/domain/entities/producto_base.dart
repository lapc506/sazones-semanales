import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Representa la información base de un producto para autocompletado y datos compartidos
/// Esta entidad almacena información común que se reutiliza entre existencias
class ProductoBase extends Equatable {
  /// Código de barras del producto (clave primaria)
  final String codigoBarras;
  
  /// Nombre del producto
  final String nombre;
  
  /// Categoría por defecto del producto
  final String categoria;
  
  /// Tipo de perecibilidad por defecto
  final TipoPerecibilidad perecibilidadDefault;
  
  /// Lista de restricciones alimentarias asociadas
  final List<String> restriccionesAlimentarias;
  
  /// Información nutricional (para modo experto)
  final InformacionNutricional? infoNutricional;
  
  /// Fecha de creación del registro
  final DateTime createdAt;
  
  /// Fecha de última actualización
  final DateTime updatedAt;

  const ProductoBase({
    required this.codigoBarras,
    required this.nombre,
    required this.categoria,
    required this.perecibilidadDefault,
    this.restriccionesAlimentarias = const [],
    this.infoNutricional,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia del producto base con campos modificados
  ProductoBase copyWith({
    String? codigoBarras,
    String? nombre,
    String? categoria,
    TipoPerecibilidad? perecibilidadDefault,
    List<String>? restriccionesAlimentarias,
    InformacionNutricional? infoNutricional,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductoBase(
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      perecibilidadDefault: perecibilidadDefault ?? this.perecibilidadDefault,
      restriccionesAlimentarias: restriccionesAlimentarias ?? this.restriccionesAlimentarias,
      infoNutricional: infoNutricional ?? this.infoNutricional,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica si el producto tiene restricciones alimentarias
  bool get tieneRestricciones => restriccionesAlimentarias.isNotEmpty;

  /// Verifica si el producto es compatible con una restricción específica
  bool esCompatibleCon(String restriccion) {
    return !restriccionesAlimentarias.contains(restriccion);
  }

  /// Verifica si el producto es compatible con una lista de restricciones
  bool esCompatibleConRestricciones(List<String> restricciones) {
    return restricciones.every((restriccion) => esCompatibleCon(restriccion));
  }

  @override
  List<Object?> get props => [
        codigoBarras,
        nombre,
        categoria,
        perecibilidadDefault,
        restriccionesAlimentarias,
        infoNutricional,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'ProductoBase(codigoBarras: $codigoBarras, nombre: $nombre, categoria: $categoria)';
  }
}

/// Información nutricional de un producto (para modo experto)
class InformacionNutricional extends Equatable {
  /// Calorías por 100g o por porción
  final double? calorias;
  
  /// Grasa total en gramos
  final double? grasas;
  
  /// Grasa saturada en gramos
  final double? grasasSaturadas;
  
  /// Carbohidratos totales en gramos
  final double? carbohidratos;
  
  /// Azúcares en gramos
  final double? azucares;
  
  /// Fibra en gramos
  final double? fibra;
  
  /// Proteínas en gramos
  final double? proteinas;
  
  /// Sodio en miligramos
  final double? sodio;
  
  /// Tamaño de la porción de referencia
  final String? porcionReferencia;
  
  /// Información adicional nutricional
  final Map<String, dynamic> otrosNutrientes;

  const InformacionNutricional({
    this.calorias,
    this.grasas,
    this.grasasSaturadas,
    this.carbohidratos,
    this.azucares,
    this.fibra,
    this.proteinas,
    this.sodio,
    this.porcionReferencia,
    this.otrosNutrientes = const {},
  });

  /// Crea una copia de la información nutricional con campos modificados
  InformacionNutricional copyWith({
    double? calorias,
    double? grasas,
    double? grasasSaturadas,
    double? carbohidratos,
    double? azucares,
    double? fibra,
    double? proteinas,
    double? sodio,
    String? porcionReferencia,
    Map<String, dynamic>? otrosNutrientes,
  }) {
    return InformacionNutricional(
      calorias: calorias ?? this.calorias,
      grasas: grasas ?? this.grasas,
      grasasSaturadas: grasasSaturadas ?? this.grasasSaturadas,
      carbohidratos: carbohidratos ?? this.carbohidratos,
      azucares: azucares ?? this.azucares,
      fibra: fibra ?? this.fibra,
      proteinas: proteinas ?? this.proteinas,
      sodio: sodio ?? this.sodio,
      porcionReferencia: porcionReferencia ?? this.porcionReferencia,
      otrosNutrientes: otrosNutrientes ?? this.otrosNutrientes,
    );
  }

  /// Verifica si tiene información nutricional básica
  bool get tieneInformacionBasica {
    return calorias != null || carbohidratos != null || proteinas != null || grasas != null;
  }

  @override
  List<Object?> get props => [
        calorias,
        grasas,
        grasasSaturadas,
        carbohidratos,
        azucares,
        fibra,
        proteinas,
        sodio,
        porcionReferencia,
        otrosNutrientes,
      ];

  @override
  String toString() {
    return 'InformacionNutricional(calorias: $calorias, proteinas: $proteinas, carbohidratos: $carbohidratos, grasas: $grasas)';
  }
}