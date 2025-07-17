import 'package:sqflite/sqflite.dart';
import '../../domain/entities/existencia.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/existencia_repository.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import '../database/database_utils.dart';

/// Implementación concreta del repositorio de existencias usando SQLite
class ExistenciaRepositoryImpl implements ExistenciaRepository {
  final DatabaseHelper _databaseHelper;
  
  ExistenciaRepositoryImpl(this._databaseHelper);
  
  @override
  Future<List<Existencia>> obtenerExistenciasActivas() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: '${DatabaseConstants.existenciasEstado} = ?',
      whereArgs: [EstadoExistencia.disponible.index],
      orderBy: '${DatabaseConstants.existenciasFechaCaducidad} ASC',
    );
    
    return maps.map((map) => _mapToExistencia(map)).toList();
  }
  
  @override
  Future<List<Existencia>> obtenerExistenciasArchivadas() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: '${DatabaseConstants.existenciasEstado} IN (?, ?)',
      whereArgs: [EstadoExistencia.consumida.index, EstadoExistencia.caducada.index],
      orderBy: '${DatabaseConstants.existenciasUpdatedAt} DESC',
    );
    
    return maps.map((map) => _mapToExistencia(map)).toList();
  }
  
  @override
  Future<List<Existencia>> obtenerExistenciasPorEstado(EstadoExistencia estado) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: '${DatabaseConstants.existenciasEstado} = ?',
      whereArgs: [estado.index],
      orderBy: '${DatabaseConstants.existenciasFechaCaducidad} ASC',
    );
    
    return maps.map((map) => _mapToExistencia(map)).toList();
  }
  
  @override
  Future<List<Existencia>> obtenerExistenciasProximasACaducar() async {
    final db = await _databaseHelper.database;
    
    // Obtener existencias activas con fecha de caducidad
    final maps = await db.rawQuery('''
      SELECT * FROM ${DatabaseConstants.tableExistencias}
      WHERE ${DatabaseConstants.existenciasEstado} = ?
      AND ${DatabaseConstants.existenciasFechaCaducidad} IS NOT NULL
      ORDER BY ${DatabaseConstants.existenciasFechaCaducidad} ASC
    ''', [EstadoExistencia.disponible.index]);
    
    final existencias = maps.map((map) => _mapToExistencia(map)).toList();
    
    // Filtrar por proximidad según tipo de perecibilidad
    return existencias.where((existencia) => existencia.estaProximaACaducar).toList();
  }
  
  @override
  Future<List<Existencia>> obtenerExistenciasCaducadas() async {
    final db = await _databaseHelper.database;
    final ahora = DateTime.now().toIso8601String();
    
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: '''
        ${DatabaseConstants.existenciasEstado} = ? 
        AND ${DatabaseConstants.existenciasFechaCaducidad} IS NOT NULL 
        AND ${DatabaseConstants.existenciasFechaCaducidad} < ?
      ''',
      whereArgs: [EstadoExistencia.disponible.index, ahora],
      orderBy: '${DatabaseConstants.existenciasFechaCaducidad} ASC',
    );
    
    return maps.map((map) => _mapToExistencia(map)).toList();
  }
  
  @override
  Future<List<Existencia>> buscarPorCodigoBarras(String codigoBarras) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: '${DatabaseConstants.existenciasCodigoBarras} = ?',
      whereArgs: [codigoBarras],
      orderBy: '${DatabaseConstants.existenciasFechaCompra} DESC',
    );
    
    return maps.map((map) => _mapToExistencia(map)).toList();
  }
  
  @override
  Future<List<Existencia>> buscarPorNombreProducto(String nombre) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: '${DatabaseConstants.existenciasNombreProducto} LIKE ?',
      whereArgs: [DatabaseUtils.createLikeCondition(nombre)],
      orderBy: '${DatabaseConstants.existenciasFechaCompra} DESC',
    );
    
    return maps.map((map) => _mapToExistencia(map)).toList();
  }
  
  @override
  Future<List<Existencia>> obtenerExistenciasPorProveedor(String proveedorId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: '${DatabaseConstants.existenciasProveedorId} = ?',
      whereArgs: [proveedorId],
      orderBy: '${DatabaseConstants.existenciasFechaCompra} DESC',
    );
    
    return maps.map((map) => _mapToExistencia(map)).toList();
  }
  
  @override
  Future<List<Existencia>> obtenerExistenciasPorCategoria(String categoria) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: '${DatabaseConstants.existenciasCategoria} = ?',
      whereArgs: [categoria],
      orderBy: '${DatabaseConstants.existenciasFechaCompra} DESC',
    );
    
    return maps.map((map) => _mapToExistencia(map)).toList();
  }
  
  @override
  Future<List<Existencia>> obtenerExistenciasPorRangoFechas(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: '''
        ${DatabaseConstants.existenciasFechaCompra} >= ? 
        AND ${DatabaseConstants.existenciasFechaCompra} <= ?
      ''',
      whereArgs: [
        DatabaseUtils.dateTimeToString(fechaInicio),
        DatabaseUtils.dateTimeToString(fechaFin),
      ],
      orderBy: '${DatabaseConstants.existenciasFechaCompra} DESC',
    );
    
    return maps.map((map) => _mapToExistencia(map)).toList();
  }
  
  @override
  Future<Existencia?> obtenerExistenciaPorId(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: '${DatabaseConstants.existenciasId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return _mapToExistencia(maps.first);
  }
  
  @override
  Future<void> guardarExistencia(Existencia existencia) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseConstants.tableExistencias,
      _existenciaToMap(existencia),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  @override
  Future<void> actualizarExistencia(Existencia existencia) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseConstants.tableExistencias,
      _existenciaToMap(existencia),
      where: '${DatabaseConstants.existenciasId} = ?',
      whereArgs: [existencia.id],
    );
  }
  
  @override
  Future<void> marcarComoConsumida(String existenciaId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseConstants.tableExistencias,
      {
        DatabaseConstants.existenciasEstado: EstadoExistencia.consumida.index,
        DatabaseConstants.existenciasUpdatedAt: DatabaseUtils.currentTimestamp(),
      },
      where: '${DatabaseConstants.existenciasId} = ?',
      whereArgs: [existenciaId],
    );
  }
  
  @override
  Future<void> marcarComoCaducada(String existenciaId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseConstants.tableExistencias,
      {
        DatabaseConstants.existenciasEstado: EstadoExistencia.caducada.index,
        DatabaseConstants.existenciasUpdatedAt: DatabaseUtils.currentTimestamp(),
      },
      where: '${DatabaseConstants.existenciasId} = ?',
      whereArgs: [existenciaId],
    );
  }
  
  @override
  Future<void> marcarMultiplesComoConsumidas(List<String> existenciaIds) async {
    if (existenciaIds.isEmpty) return;
    
    final db = await _databaseHelper.database;
    final batch = db.batch();
    
    for (final id in existenciaIds) {
      batch.update(
        DatabaseConstants.tableExistencias,
        {
          DatabaseConstants.existenciasEstado: EstadoExistencia.consumida.index,
          DatabaseConstants.existenciasUpdatedAt: DatabaseUtils.currentTimestamp(),
        },
        where: '${DatabaseConstants.existenciasId} = ?',
        whereArgs: [id],
      );
    }
    
    await batch.commit();
  }
  
  @override
  Future<void> eliminarExistencia(String existenciaId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseConstants.tableExistencias,
      where: '${DatabaseConstants.existenciasId} = ?',
      whereArgs: [existenciaId],
    );
  }
  
  @override
  Future<Map<String, dynamic>> obtenerEstadisticasPrecios(String nombreProducto) async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery(DatabaseConstants.queryEstadisticasPrecios, [nombreProducto]);
    
    if (maps.isEmpty) {
      return {
        'precio_promedio': 0.0,
        'precio_minimo': 0.0,
        'precio_maximo': 0.0,
        'cantidad_compras': 0,
      };
    }
    
    return maps.first;
  }
  
  @override
  Future<List<Map<String, dynamic>>> obtenerGastosPorCategoria(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery(
      DatabaseConstants.queryGastosPorCategoria,
      [
        DatabaseUtils.dateTimeToString(fechaInicio),
        DatabaseUtils.dateTimeToString(fechaFin),
      ],
    );
  }
  
  @override
  Future<List<Map<String, dynamic>>> obtenerGastosPorProveedor(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery(
      DatabaseConstants.queryGastosPorProveedor,
      [
        DatabaseUtils.dateTimeToString(fechaInicio),
        DatabaseUtils.dateTimeToString(fechaFin),
      ],
    );
  }
  
  @override
  Future<List<Map<String, dynamic>>> obtenerHistorialPrecios(String nombreProducto) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        ${DatabaseConstants.existenciasPrecio},
        ${DatabaseConstants.existenciasFechaCompra},
        p.${DatabaseConstants.proveedoresNombre} as proveedor_nombre
      FROM ${DatabaseConstants.tableExistencias} e
      JOIN ${DatabaseConstants.tableProveedores} p ON e.${DatabaseConstants.existenciasProveedorId} = p.${DatabaseConstants.proveedoresId}
      WHERE e.${DatabaseConstants.existenciasNombreProducto} = ?
      ORDER BY e.${DatabaseConstants.existenciasFechaCompra} DESC
    ''', [nombreProducto]);
  }
  
  @override
  Future<List<Map<String, dynamic>>> obtenerProductosMasComprados({int limite = 10}) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        ${DatabaseConstants.existenciasNombreProducto},
        COUNT(*) as cantidad_compras,
        SUM(${DatabaseConstants.existenciasPrecio}) as total_gastado,
        AVG(${DatabaseConstants.existenciasPrecio}) as precio_promedio
      FROM ${DatabaseConstants.tableExistencias}
      GROUP BY ${DatabaseConstants.existenciasNombreProducto}
      ORDER BY cantidad_compras DESC
      LIMIT ?
    ''', [limite]);
  }
  
  @override
  Future<List<Map<String, dynamic>>> obtenerPatronesConsumo(String nombreProducto) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', ${DatabaseConstants.existenciasFechaCompra}) as mes,
        COUNT(*) as cantidad_comprada,
        COUNT(CASE WHEN ${DatabaseConstants.existenciasEstado} = ? THEN 1 END) as cantidad_consumida,
        AVG(${DatabaseConstants.existenciasPrecio}) as precio_promedio
      FROM ${DatabaseConstants.tableExistencias}
      WHERE ${DatabaseConstants.existenciasNombreProducto} = ?
      GROUP BY strftime('%Y-%m', ${DatabaseConstants.existenciasFechaCompra})
      ORDER BY mes DESC
    ''', [EstadoExistencia.consumida.index, nombreProducto]);
  }
  
  @override
  Future<Map<EstadoExistencia, int>> contarExistenciasPorEstado() async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT 
        ${DatabaseConstants.existenciasEstado},
        COUNT(*) as cantidad
      FROM ${DatabaseConstants.tableExistencias}
      GROUP BY ${DatabaseConstants.existenciasEstado}
    ''');
    
    final resultado = <EstadoExistencia, int>{};
    for (final map in maps) {
      final estado = DatabaseUtils.intToEstadoExistencia(map[DatabaseConstants.existenciasEstado] as int);
      resultado[estado] = map['cantidad'] as int;
    }
    
    return resultado;
  }
  
  @override
  Future<List<Existencia>> obtenerExistenciasConPaginacion({
    int pagina = 0,
    int tamanoPagina = 50,
    EstadoExistencia? estado,
    String? categoria,
    String? proveedorId,
  }) async {
    DatabaseUtils.validatePaginationParams(pagina, tamanoPagina);
    
    final db = await _databaseHelper.database;
    final conditions = <String, dynamic>{};
    
    if (estado != null) {
      conditions[DatabaseConstants.existenciasEstado] = estado.index;
    }
    if (categoria != null) {
      conditions[DatabaseConstants.existenciasCategoria] = categoria;
    }
    if (proveedorId != null) {
      conditions[DatabaseConstants.existenciasProveedorId] = proveedorId;
    }
    
    final whereClause = DatabaseUtils.buildWhereClause(conditions);
    final offset = pagina * tamanoPagina;
    
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: whereClause.isNotEmpty ? whereClause.clause : null,
      whereArgs: whereClause.isNotEmpty ? whereClause.args : null,
      orderBy: '${DatabaseConstants.existenciasFechaCaducidad} ASC',
      limit: tamanoPagina,
      offset: offset,
    );
    
    return maps.map((map) => _mapToExistencia(map)).toList();
  }
  
  @override
  Future<List<Existencia>> buscarExistenciasConFiltros({
    String? nombreProducto,
    String? categoria,
    String? proveedorId,
    EstadoExistencia? estado,
    TipoPerecibilidad? perecibilidad,
    DateTime? fechaCompraInicio,
    DateTime? fechaCompraFin,
    DateTime? fechaCaducidadInicio,
    DateTime? fechaCaducidadFin,
    double? precioMinimo,
    double? precioMaximo,
    int limite = 50,
  }) async {
    final db = await _databaseHelper.database;
    final conditions = <String>[];
    final args = <dynamic>[];
    
    if (nombreProducto != null) {
      conditions.add('${DatabaseConstants.existenciasNombreProducto} LIKE ?');
      args.add(DatabaseUtils.createLikeCondition(nombreProducto));
    }
    
    if (categoria != null) {
      conditions.add('${DatabaseConstants.existenciasCategoria} = ?');
      args.add(categoria);
    }
    
    if (proveedorId != null) {
      conditions.add('${DatabaseConstants.existenciasProveedorId} = ?');
      args.add(proveedorId);
    }
    
    if (estado != null) {
      conditions.add('${DatabaseConstants.existenciasEstado} = ?');
      args.add(estado.index);
    }
    
    if (perecibilidad != null) {
      conditions.add('${DatabaseConstants.existenciasPerecibilidad} = ?');
      args.add(perecibilidad.index);
    }
    
    if (fechaCompraInicio != null) {
      conditions.add('${DatabaseConstants.existenciasFechaCompra} >= ?');
      args.add(DatabaseUtils.dateTimeToString(fechaCompraInicio));
    }
    
    if (fechaCompraFin != null) {
      conditions.add('${DatabaseConstants.existenciasFechaCompra} <= ?');
      args.add(DatabaseUtils.dateTimeToString(fechaCompraFin));
    }
    
    if (fechaCaducidadInicio != null) {
      conditions.add('${DatabaseConstants.existenciasFechaCaducidad} >= ?');
      args.add(DatabaseUtils.dateTimeToString(fechaCaducidadInicio));
    }
    
    if (fechaCaducidadFin != null) {
      conditions.add('${DatabaseConstants.existenciasFechaCaducidad} <= ?');
      args.add(DatabaseUtils.dateTimeToString(fechaCaducidadFin));
    }
    
    if (precioMinimo != null) {
      conditions.add('${DatabaseConstants.existenciasPrecio} >= ?');
      args.add(precioMinimo);
    }
    
    if (precioMaximo != null) {
      conditions.add('${DatabaseConstants.existenciasPrecio} <= ?');
      args.add(precioMaximo);
    }
    
    final whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      where: whereClause,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: '${DatabaseConstants.existenciasFechaCaducidad} ASC',
      limit: limite,
    );
    
    return maps.map((map) => _mapToExistencia(map)).toList();
  }
  
  /// Convierte un Map de la base de datos a una entidad Existencia
  Existencia _mapToExistencia(Map<String, dynamic> map) {
    return Existencia(
      id: map[DatabaseConstants.existenciasId] as String,
      codigoBarras: map[DatabaseConstants.existenciasCodigoBarras] as String,
      nombreProducto: map[DatabaseConstants.existenciasNombreProducto] as String,
      categoria: map[DatabaseConstants.existenciasCategoria] as String,
      fechaCompra: DatabaseUtils.stringToDateTime(map[DatabaseConstants.existenciasFechaCompra] as String)!,
      fechaCaducidad: DatabaseUtils.stringToDateTime(map[DatabaseConstants.existenciasFechaCaducidad] as String?),
      precio: (map[DatabaseConstants.existenciasPrecio] as num).toDouble(),
      proveedorId: map[DatabaseConstants.existenciasProveedorId] as String,
      perecibilidad: DatabaseUtils.intToTipoPerecibilidad(map[DatabaseConstants.existenciasPerecibilidad] as int),
      estado: DatabaseUtils.intToEstadoExistencia(map[DatabaseConstants.existenciasEstado] as int),
      metadatos: DatabaseUtils.jsonStringToMap(map[DatabaseConstants.existenciasMetadatosJson] as String?),
      createdAt: DatabaseUtils.stringToDateTime(map[DatabaseConstants.existenciasCreatedAt] as String)!,
      updatedAt: DatabaseUtils.stringToDateTime(map[DatabaseConstants.existenciasUpdatedAt] as String)!,
    );
  }
  
  /// Convierte una entidad Existencia a un Map para la base de datos
  Map<String, dynamic> _existenciaToMap(Existencia existencia) {
    return {
      DatabaseConstants.existenciasId: existencia.id,
      DatabaseConstants.existenciasCodigoBarras: existencia.codigoBarras,
      DatabaseConstants.existenciasNombreProducto: existencia.nombreProducto,
      DatabaseConstants.existenciasCategoria: existencia.categoria,
      DatabaseConstants.existenciasFechaCompra: DatabaseUtils.dateTimeToString(existencia.fechaCompra),
      DatabaseConstants.existenciasFechaCaducidad: existencia.fechaCaducidad != null 
          ? DatabaseUtils.dateTimeToString(existencia.fechaCaducidad!) 
          : null,
      DatabaseConstants.existenciasPrecio: existencia.precio,
      DatabaseConstants.existenciasProveedorId: existencia.proveedorId,
      DatabaseConstants.existenciasPerecibilidad: existencia.perecibilidad.index,
      DatabaseConstants.existenciasEstado: existencia.estado.index,
      DatabaseConstants.existenciasMetadatosJson: DatabaseUtils.mapToJsonString(existencia.metadatos),
      DatabaseConstants.existenciasCreatedAt: DatabaseUtils.dateTimeToString(existencia.createdAt),
      DatabaseConstants.existenciasUpdatedAt: DatabaseUtils.dateTimeToString(existencia.updatedAt),
    };
  }
}