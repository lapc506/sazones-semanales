import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/producto_base.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/producto_repository.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import '../database/database_utils.dart';

/// Implementación concreta del repositorio de productos base usando SQLite
class ProductoRepositoryImpl implements ProductoRepository {
  final DatabaseHelper _databaseHelper;
  
  ProductoRepositoryImpl(this._databaseHelper);
  
  @override
  Future<ProductoBase?> buscarPorCodigoBarras(String codigoBarras) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProductosBase,
      where: '${DatabaseConstants.productosBaseCodigoBarras} = ?',
      whereArgs: [codigoBarras],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return _mapToProductoBase(maps.first);
  }
  
  @override
  Future<List<ProductoBase>> obtenerTodosLosProductos() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProductosBase,
      orderBy: '${DatabaseConstants.productosBaseNombre} ASC',
    );
    
    return maps.map((map) => _mapToProductoBase(map)).toList();
  }
  
  @override
  Future<List<String>> obtenerSugerenciasAutocompletado(String query, {int limite = 10}) async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery(
      DatabaseConstants.queryProductosAutocompletado,
      [DatabaseUtils.createLikeCondition(query), limite],
    );
    
    return maps.map((map) => map[DatabaseConstants.productosBaseNombre] as String).toList();
  }
  
  @override
  Future<List<ProductoBase>> buscarPorNombre(String nombre) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProductosBase,
      where: '${DatabaseConstants.productosBaseNombre} LIKE ?',
      whereArgs: [DatabaseUtils.createLikeCondition(nombre)],
      orderBy: '${DatabaseConstants.productosBaseNombre} ASC',
    );
    
    return maps.map((map) => _mapToProductoBase(map)).toList();
  }
  
  @override
  Future<List<ProductoBase>> obtenerProductosPorCategoria(String categoria) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProductosBase,
      where: '${DatabaseConstants.productosBaseCategoria} = ?',
      whereArgs: [categoria],
      orderBy: '${DatabaseConstants.productosBaseNombre} ASC',
    );
    
    return maps.map((map) => _mapToProductoBase(map)).toList();
  }
  
  @override
  Future<List<ProductoBase>> obtenerProductosPorPerecibilidad(TipoPerecibilidad perecibilidad) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProductosBase,
      where: '${DatabaseConstants.productosBasePerecibilidadDefault} = ?',
      whereArgs: [perecibilidad.index],
      orderBy: '${DatabaseConstants.productosBaseNombre} ASC',
    );
    
    return maps.map((map) => _mapToProductoBase(map)).toList();
  }
  
  @override
  Future<List<ProductoBase>> obtenerProductosConRestricciones(List<String> restricciones) async {
    if (restricciones.isEmpty) return [];
    
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProductosBase,
      where: '${DatabaseConstants.productosBaseRestriccionesAlimentarias} IS NOT NULL',
      orderBy: '${DatabaseConstants.productosBaseNombre} ASC',
    );
    
    final productos = maps.map((map) => _mapToProductoBase(map)).toList();
    
    // Filtrar productos que contengan alguna de las restricciones especificadas
    return productos.where((producto) {
      return restricciones.any((restriccion) => 
        producto.restriccionesAlimentarias.contains(restriccion));
    }).toList();
  }
  
  @override
  Future<List<ProductoBase>> obtenerProductosCompatibles(List<String> restriccionesUsuario) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProductosBase,
      orderBy: '${DatabaseConstants.productosBaseNombre} ASC',
    );
    
    final productos = maps.map((map) => _mapToProductoBase(map)).toList();
    
    // Filtrar productos compatibles con las restricciones del usuario
    return productos.where((producto) => 
      producto.esCompatibleConRestricciones(restriccionesUsuario)).toList();
  }
  
  @override
  Future<void> guardarProductoBase(ProductoBase producto) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseConstants.tableProductosBase,
      _productoBaseToMap(producto),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  @override
  Future<void> actualizarProductoBase(ProductoBase producto) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseConstants.tableProductosBase,
      _productoBaseToMap(producto),
      where: '${DatabaseConstants.productosBaseCodigoBarras} = ?',
      whereArgs: [producto.codigoBarras],
    );
  }
  
  @override
  Future<void> eliminarProductoBase(String codigoBarras) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseConstants.tableProductosBase,
      where: '${DatabaseConstants.productosBaseCodigoBarras} = ?',
      whereArgs: [codigoBarras],
    );
  }
  
  @override
  Future<List<String>> obtenerCategorias() async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT ${DatabaseConstants.productosBaseCategoria}
      FROM ${DatabaseConstants.tableProductosBase}
      WHERE ${DatabaseConstants.productosBaseCategoria} IS NOT NULL
      ORDER BY ${DatabaseConstants.productosBaseCategoria} ASC
    ''');
    
    return maps.map((map) => map[DatabaseConstants.productosBaseCategoria] as String).toList();
  }
  
  @override
  Future<List<String>> obtenerRestriccionesAlimentarias() async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT ${DatabaseConstants.productosBaseRestriccionesAlimentarias}
      FROM ${DatabaseConstants.tableProductosBase}
      WHERE ${DatabaseConstants.productosBaseRestriccionesAlimentarias} IS NOT NULL
    ''');
    
    final restriccionesSet = <String>{};
    for (final map in maps) {
      final restriccionesJson = map[DatabaseConstants.productosBaseRestriccionesAlimentarias] as String?;
      if (restriccionesJson != null) {
        final restricciones = DatabaseUtils.jsonStringToStringList(restriccionesJson);
        restriccionesSet.addAll(restricciones);
      }
    }
    
    final restriccionesList = restriccionesSet.toList();
    restriccionesList.sort();
    return restriccionesList;
  }
  
  @override
  Future<bool> existeProducto(String codigoBarras) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProductosBase,
      columns: [DatabaseConstants.productosBaseCodigoBarras],
      where: '${DatabaseConstants.productosBaseCodigoBarras} = ?',
      whereArgs: [codigoBarras],
      limit: 1,
    );
    
    return maps.isNotEmpty;
  }
  
  @override
  Future<List<ProductoBase>> obtenerProductosMasUtilizados({int limite = 10}) async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT 
        pb.*,
        COUNT(e.${DatabaseConstants.existenciasId}) as uso_count
      FROM ${DatabaseConstants.tableProductosBase} pb
      LEFT JOIN ${DatabaseConstants.tableExistencias} e ON pb.${DatabaseConstants.productosBaseCodigoBarras} = e.${DatabaseConstants.existenciasCodigoBarras}
      GROUP BY pb.${DatabaseConstants.productosBaseCodigoBarras}
      ORDER BY uso_count DESC, pb.${DatabaseConstants.productosBaseNombre} ASC
      LIMIT ?
    ''', [limite]);
    
    return maps.map((map) => _mapToProductoBase(map)).toList();
  }
  
  @override
  Future<List<ProductoBase>> obtenerProductosConInfoNutricional() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProductosBase,
      where: '${DatabaseConstants.productosBaseInfoNutricional} IS NOT NULL',
      orderBy: '${DatabaseConstants.productosBaseNombre} ASC',
    );
    
    return maps.map((map) => _mapToProductoBase(map)).toList();
  }
  
  @override
  Future<List<ProductoBase>> buscarProductosConFiltros({
    String? nombre,
    String? categoria,
    TipoPerecibilidad? perecibilidad,
    List<String>? restriccionesAlimentarias,
    bool? tieneInfoNutricional,
    int limite = 50,
  }) async {
    final db = await _databaseHelper.database;
    final conditions = <String>[];
    final args = <dynamic>[];
    
    if (nombre != null) {
      conditions.add('${DatabaseConstants.productosBaseNombre} LIKE ?');
      args.add(DatabaseUtils.createLikeCondition(nombre));
    }
    
    if (categoria != null) {
      conditions.add('${DatabaseConstants.productosBaseCategoria} = ?');
      args.add(categoria);
    }
    
    if (perecibilidad != null) {
      conditions.add('${DatabaseConstants.productosBasePerecibilidadDefault} = ?');
      args.add(perecibilidad.index);
    }
    
    if (tieneInfoNutricional != null) {
      if (tieneInfoNutricional) {
        conditions.add('${DatabaseConstants.productosBaseInfoNutricional} IS NOT NULL');
      } else {
        conditions.add('${DatabaseConstants.productosBaseInfoNutricional} IS NULL');
      }
    }
    
    final whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    
    final maps = await db.query(
      DatabaseConstants.tableProductosBase,
      where: whereClause,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: '${DatabaseConstants.productosBaseNombre} ASC',
      limit: limite,
    );
    
    var productos = maps.map((map) => _mapToProductoBase(map)).toList();
    
    // Filtrar por restricciones alimentarias si se especificaron
    if (restriccionesAlimentarias != null && restriccionesAlimentarias.isNotEmpty) {
      productos = productos.where((producto) {
        return restriccionesAlimentarias.any((restriccion) => 
          producto.restriccionesAlimentarias.contains(restriccion));
      }).toList();
    }
    
    return productos;
  }
  
  @override
  Future<Map<String, dynamic>> obtenerEstadisticasProductos() async {
    final db = await _databaseHelper.database;
    
    final totalProductos = await db.rawQuery('''
      SELECT COUNT(*) as total FROM ${DatabaseConstants.tableProductosBase}
    ''');
    
    final productosPorCategoria = await db.rawQuery('''
      SELECT 
        ${DatabaseConstants.productosBaseCategoria},
        COUNT(*) as cantidad
      FROM ${DatabaseConstants.tableProductosBase}
      GROUP BY ${DatabaseConstants.productosBaseCategoria}
      ORDER BY cantidad DESC
    ''');
    
    final productosPorPerecibilidad = await db.rawQuery('''
      SELECT 
        ${DatabaseConstants.productosBasePerecibilidadDefault},
        COUNT(*) as cantidad
      FROM ${DatabaseConstants.tableProductosBase}
      GROUP BY ${DatabaseConstants.productosBasePerecibilidadDefault}
    ''');
    
    final productosConInfoNutricional = await db.rawQuery('''
      SELECT COUNT(*) as total 
      FROM ${DatabaseConstants.tableProductosBase}
      WHERE ${DatabaseConstants.productosBaseInfoNutricional} IS NOT NULL
    ''');
    
    return {
      'total_productos': totalProductos.first['total'],
      'productos_por_categoria': productosPorCategoria,
      'productos_por_perecibilidad': productosPorPerecibilidad,
      'productos_con_info_nutricional': productosConInfoNutricional.first['total'],
    };
  }
  
  @override
  Future<void> importarProductos(List<ProductoBase> productos) async {
    if (productos.isEmpty) return;
    
    final db = await _databaseHelper.database;
    final batch = db.batch();
    
    for (final producto in productos) {
      batch.insert(
        DatabaseConstants.tableProductosBase,
        _productoBaseToMap(producto),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit();
  }
  
  @override
  Future<List<Map<String, dynamic>>> exportarProductos() async {
    final db = await _databaseHelper.database;
    return await db.query(
      DatabaseConstants.tableProductosBase,
      orderBy: '${DatabaseConstants.productosBaseNombre} ASC',
    );
  }
  
  @override
  Future<void> sincronizarProductos() async {
    // Implementar sincronización con base de datos externa si es necesario
    // Por ahora, esta funcionalidad está pendiente de implementación
    throw UnimplementedError('Sincronización de productos no implementada');
  }
  
  @override
  Future<List<ProductoBase>> obtenerProductosConPaginacion({
    int pagina = 0,
    int tamanoPagina = 50,
    String? categoria,
    TipoPerecibilidad? perecibilidad,
  }) async {
    DatabaseUtils.validatePaginationParams(pagina, tamanoPagina);
    
    final db = await _databaseHelper.database;
    final conditions = <String, dynamic>{};
    
    if (categoria != null) {
      conditions[DatabaseConstants.productosBaseCategoria] = categoria;
    }
    if (perecibilidad != null) {
      conditions[DatabaseConstants.productosBasePerecibilidadDefault] = perecibilidad.index;
    }
    
    final whereClause = DatabaseUtils.buildWhereClause(conditions);
    final offset = pagina * tamanoPagina;
    
    final maps = await db.query(
      DatabaseConstants.tableProductosBase,
      where: whereClause.isNotEmpty ? whereClause.clause : null,
      whereArgs: whereClause.isNotEmpty ? whereClause.args : null,
      orderBy: '${DatabaseConstants.productosBaseNombre} ASC',
      limit: tamanoPagina,
      offset: offset,
    );
    
    return maps.map((map) => _mapToProductoBase(map)).toList();
  }
  
  /// Convierte un Map de la base de datos a una entidad ProductoBase
  ProductoBase _mapToProductoBase(Map<String, dynamic> map) {
    return ProductoBase(
      codigoBarras: map[DatabaseConstants.productosBaseCodigoBarras] as String,
      nombre: map[DatabaseConstants.productosBaseNombre] as String,
      categoria: map[DatabaseConstants.productosBaseCategoria] as String,
      perecibilidadDefault: DatabaseUtils.intToTipoPerecibilidad(
        map[DatabaseConstants.productosBasePerecibilidadDefault] as int
      ),
      restriccionesAlimentarias: DatabaseUtils.jsonStringToStringList(
        map[DatabaseConstants.productosBaseRestriccionesAlimentarias] as String?
      ),
      infoNutricional: _mapToInformacionNutricional(
        map[DatabaseConstants.productosBaseInfoNutricional] as String?
      ),
      createdAt: DatabaseUtils.stringToDateTime(
        map[DatabaseConstants.productosBaseCreatedAt] as String
      )!,
      updatedAt: DatabaseUtils.stringToDateTime(
        map[DatabaseConstants.productosBaseUpdatedAt] as String
      )!,
    );
  }
  
  /// Convierte una entidad ProductoBase a un Map para la base de datos
  Map<String, dynamic> _productoBaseToMap(ProductoBase producto) {
    return {
      DatabaseConstants.productosBaseCodigoBarras: producto.codigoBarras,
      DatabaseConstants.productosBaseNombre: producto.nombre,
      DatabaseConstants.productosBaseCategoria: producto.categoria,
      DatabaseConstants.productosBasePerecibilidadDefault: producto.perecibilidadDefault.index,
      DatabaseConstants.productosBaseRestriccionesAlimentarias: 
          DatabaseUtils.stringListToJsonString(producto.restriccionesAlimentarias),
      DatabaseConstants.productosBaseInfoNutricional: 
          _informacionNutricionalToJson(producto.infoNutricional),
      DatabaseConstants.productosBaseCreatedAt: DatabaseUtils.dateTimeToString(producto.createdAt),
      DatabaseConstants.productosBaseUpdatedAt: DatabaseUtils.dateTimeToString(producto.updatedAt),
    };
  }
  
  /// Convierte JSON string a InformacionNutricional
  InformacionNutricional? _mapToInformacionNutricional(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return InformacionNutricional(
        calorias: map['calorias']?.toDouble(),
        grasas: map['grasas']?.toDouble(),
        grasasSaturadas: map['grasas_saturadas']?.toDouble(),
        carbohidratos: map['carbohidratos']?.toDouble(),
        azucares: map['azucares']?.toDouble(),
        fibra: map['fibra']?.toDouble(),
        proteinas: map['proteinas']?.toDouble(),
        sodio: map['sodio']?.toDouble(),
        porcionReferencia: map['porcion_referencia'] as String?,
        otrosNutrientes: Map<String, dynamic>.from(map['otros_nutrientes'] ?? {}),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Convierte InformacionNutricional a JSON string
  String? _informacionNutricionalToJson(InformacionNutricional? info) {
    if (info == null) return null;
    
    try {
      final map = {
        'calorias': info.calorias,
        'grasas': info.grasas,
        'grasas_saturadas': info.grasasSaturadas,
        'carbohidratos': info.carbohidratos,
        'azucares': info.azucares,
        'fibra': info.fibra,
        'proteinas': info.proteinas,
        'sodio': info.sodio,
        'porcion_referencia': info.porcionReferencia,
        'otros_nutrientes': info.otrosNutrientes,
      };
      
      return jsonEncode(map);
    } catch (e) {
      return null;
    }
  }
}