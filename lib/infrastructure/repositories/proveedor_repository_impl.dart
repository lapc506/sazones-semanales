import 'package:sqflite/sqflite.dart';
import '../../domain/entities/proveedor.dart';
import '../../domain/repositories/proveedor_repository.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import '../database/database_utils.dart';

/// Implementación concreta del repositorio de proveedores usando SQLite
class ProveedorRepositoryImpl implements ProveedorRepository {
  final DatabaseHelper _databaseHelper;
  
  ProveedorRepositoryImpl(this._databaseHelper);
  
  @override
  Future<List<Proveedor>> obtenerProveedoresActivos() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProveedores,
      where: '${DatabaseConstants.proveedoresActivo} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseConstants.proveedoresNombre} ASC',
    );
    
    return maps.map((map) => _mapToProveedor(map)).toList();
  }
  
  @override
  Future<List<Proveedor>> obtenerTodosLosProveedores() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProveedores,
      orderBy: '${DatabaseConstants.proveedoresNombre} ASC',
    );
    
    return maps.map((map) => _mapToProveedor(map)).toList();
  }
  
  @override
  Future<Proveedor?> obtenerProveedorPorId(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProveedores,
      where: '${DatabaseConstants.proveedoresId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return _mapToProveedor(maps.first);
  }
  
  @override
  Future<List<Proveedor>> buscarPorNombre(String nombre) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProveedores,
      where: '${DatabaseConstants.proveedoresNombre} LIKE ?',
      whereArgs: [DatabaseUtils.createLikeCondition(nombre)],
      orderBy: '${DatabaseConstants.proveedoresNombre} ASC',
    );
    
    return maps.map((map) => _mapToProveedor(map)).toList();
  }
  
  @override
  Future<List<Proveedor>> obtenerProveedoresPorTipo(TipoProveedor tipo) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProveedores,
      where: '${DatabaseConstants.proveedoresTipo} = ?',
      whereArgs: [tipo.index],
      orderBy: '${DatabaseConstants.proveedoresNombre} ASC',
    );
    
    return maps.map((map) => _mapToProveedor(map)).toList();
  }
  
  @override
  Future<void> guardarProveedor(Proveedor proveedor) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseConstants.tableProveedores,
      _proveedorToMap(proveedor),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  @override
  Future<void> actualizarProveedor(Proveedor proveedor) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseConstants.tableProveedores,
      _proveedorToMap(proveedor),
      where: '${DatabaseConstants.proveedoresId} = ?',
      whereArgs: [proveedor.id],
    );
  }
  
  @override
  Future<void> desactivarProveedor(String proveedorId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseConstants.tableProveedores,
      {
        DatabaseConstants.proveedoresActivo: 0,
        DatabaseConstants.proveedoresUpdatedAt: DatabaseUtils.currentTimestamp(),
      },
      where: '${DatabaseConstants.proveedoresId} = ?',
      whereArgs: [proveedorId],
    );
  }
  
  @override
  Future<void> activarProveedor(String proveedorId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseConstants.tableProveedores,
      {
        DatabaseConstants.proveedoresActivo: 1,
        DatabaseConstants.proveedoresUpdatedAt: DatabaseUtils.currentTimestamp(),
      },
      where: '${DatabaseConstants.proveedoresId} = ?',
      whereArgs: [proveedorId],
    );
  }
  
  @override
  Future<void> eliminarProveedor(String proveedorId) async {
    // Verificar que no tenga existencias asociadas
    final tieneExistencias = await tieneExistenciasAsociadas(proveedorId);
    if (tieneExistencias) {
      throw Exception('No se puede eliminar el proveedor porque tiene existencias asociadas');
    }
    
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseConstants.tableProveedores,
      where: '${DatabaseConstants.proveedoresId} = ?',
      whereArgs: [proveedorId],
    );
  }
  
  @override
  Future<bool> tieneExistenciasAsociadas(String proveedorId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableExistencias,
      columns: [DatabaseConstants.existenciasId],
      where: '${DatabaseConstants.existenciasProveedorId} = ?',
      whereArgs: [proveedorId],
      limit: 1,
    );
    
    return maps.isNotEmpty;
  }
  
  @override
  Future<Map<String, dynamic>> obtenerEstadisticasProveedor(String proveedorId) async {
    final db = await _databaseHelper.database;
    
    // Estadísticas básicas
    final estadisticasBasicas = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_compras,
        SUM(${DatabaseConstants.existenciasPrecio}) as total_gastado,
        AVG(${DatabaseConstants.existenciasPrecio}) as precio_promedio,
        MIN(${DatabaseConstants.existenciasFechaCompra}) as primera_compra,
        MAX(${DatabaseConstants.existenciasFechaCompra}) as ultima_compra
      FROM ${DatabaseConstants.tableExistencias}
      WHERE ${DatabaseConstants.existenciasProveedorId} = ?
    ''', [proveedorId]);
    
    // Productos más comprados
    final productosMasComprados = await db.rawQuery('''
      SELECT 
        ${DatabaseConstants.existenciasNombreProducto},
        COUNT(*) as cantidad_compras,
        SUM(${DatabaseConstants.existenciasPrecio}) as total_gastado
      FROM ${DatabaseConstants.tableExistencias}
      WHERE ${DatabaseConstants.existenciasProveedorId} = ?
      GROUP BY ${DatabaseConstants.existenciasNombreProducto}
      ORDER BY cantidad_compras DESC
      LIMIT 5
    ''', [proveedorId]);
    
    // Gastos por mes
    final gastosPorMes = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', ${DatabaseConstants.existenciasFechaCompra}) as mes,
        COUNT(*) as cantidad_compras,
        SUM(${DatabaseConstants.existenciasPrecio}) as total_gastado
      FROM ${DatabaseConstants.tableExistencias}
      WHERE ${DatabaseConstants.existenciasProveedorId} = ?
      GROUP BY strftime('%Y-%m', ${DatabaseConstants.existenciasFechaCompra})
      ORDER BY mes DESC
      LIMIT 12
    ''', [proveedorId]);
    
    return {
      'estadisticas_basicas': estadisticasBasicas.isNotEmpty ? estadisticasBasicas.first : {},
      'productos_mas_comprados': productosMasComprados,
      'gastos_por_mes': gastosPorMes,
    };
  }
  
  @override
  Future<List<Map<String, dynamic>>> obtenerHistorialCompras(String proveedorId) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        ${DatabaseConstants.existenciasId},
        ${DatabaseConstants.existenciasNombreProducto},
        ${DatabaseConstants.existenciasPrecio},
        ${DatabaseConstants.existenciasFechaCompra},
        ${DatabaseConstants.existenciasEstado}
      FROM ${DatabaseConstants.tableExistencias}
      WHERE ${DatabaseConstants.existenciasProveedorId} = ?
      ORDER BY ${DatabaseConstants.existenciasFechaCompra} DESC
    ''', [proveedorId]);
  }
  
  @override
  Future<List<Map<String, dynamic>>> obtenerProveedoresMasUtilizados({int limite = 10}) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        p.${DatabaseConstants.proveedoresId},
        p.${DatabaseConstants.proveedoresNombre},
        p.${DatabaseConstants.proveedoresTipo},
        COUNT(e.${DatabaseConstants.existenciasId}) as total_compras,
        SUM(e.${DatabaseConstants.existenciasPrecio}) as total_gastado,
        AVG(e.${DatabaseConstants.existenciasPrecio}) as precio_promedio,
        MAX(e.${DatabaseConstants.existenciasFechaCompra}) as ultima_compra
      FROM ${DatabaseConstants.tableProveedores} p
      LEFT JOIN ${DatabaseConstants.tableExistencias} e ON p.${DatabaseConstants.proveedoresId} = e.${DatabaseConstants.existenciasProveedorId}
      WHERE p.${DatabaseConstants.proveedoresActivo} = 1
      GROUP BY p.${DatabaseConstants.proveedoresId}
      ORDER BY total_compras DESC, total_gastado DESC
      LIMIT ?
    ''', [limite]);
  }
  
  @override
  Future<List<TipoProveedor>> obtenerTiposEnUso() async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT ${DatabaseConstants.proveedoresTipo}
      FROM ${DatabaseConstants.tableProveedores}
      WHERE ${DatabaseConstants.proveedoresActivo} = 1
      ORDER BY ${DatabaseConstants.proveedoresTipo} ASC
    ''');
    
    return maps.map((map) => 
      DatabaseUtils.intToTipoProveedor(map[DatabaseConstants.proveedoresTipo] as int)
    ).toList();
  }
  
  @override
  Future<Map<TipoProveedor, int>> contarProveedoresPorTipo() async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT 
        ${DatabaseConstants.proveedoresTipo},
        COUNT(*) as cantidad
      FROM ${DatabaseConstants.tableProveedores}
      WHERE ${DatabaseConstants.proveedoresActivo} = 1
      GROUP BY ${DatabaseConstants.proveedoresTipo}
    ''');
    
    final resultado = <TipoProveedor, int>{};
    for (final map in maps) {
      final tipo = DatabaseUtils.intToTipoProveedor(map[DatabaseConstants.proveedoresTipo] as int);
      resultado[tipo] = map['cantidad'] as int;
    }
    
    return resultado;
  }
  
  @override
  Future<List<Proveedor>> buscarProveedoresConFiltros({
    String? nombre,
    TipoProveedor? tipo,
    bool? activo,
    String? direccion,
    int limite = 50,
  }) async {
    final db = await _databaseHelper.database;
    final conditions = <String>[];
    final args = <dynamic>[];
    
    if (nombre != null) {
      conditions.add('${DatabaseConstants.proveedoresNombre} LIKE ?');
      args.add(DatabaseUtils.createLikeCondition(nombre));
    }
    
    if (tipo != null) {
      conditions.add('${DatabaseConstants.proveedoresTipo} = ?');
      args.add(tipo.index);
    }
    
    if (activo != null) {
      conditions.add('${DatabaseConstants.proveedoresActivo} = ?');
      args.add(activo ? 1 : 0);
    }
    
    if (direccion != null) {
      conditions.add('${DatabaseConstants.proveedoresDireccion} LIKE ?');
      args.add(DatabaseUtils.createLikeCondition(direccion));
    }
    
    final whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    
    final maps = await db.query(
      DatabaseConstants.tableProveedores,
      where: whereClause,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: '${DatabaseConstants.proveedoresNombre} ASC',
      limit: limite,
    );
    
    return maps.map((map) => _mapToProveedor(map)).toList();
  }
  
  @override
  Future<List<Proveedor>> obtenerProveedoresConPaginacion({
    int pagina = 0,
    int tamanoPagina = 50,
    TipoProveedor? tipo,
    bool? soloActivos = true,
  }) async {
    DatabaseUtils.validatePaginationParams(pagina, tamanoPagina);
    
    final db = await _databaseHelper.database;
    final conditions = <String, dynamic>{};
    
    if (tipo != null) {
      conditions[DatabaseConstants.proveedoresTipo] = tipo.index;
    }
    if (soloActivos == true) {
      conditions[DatabaseConstants.proveedoresActivo] = 1;
    }
    
    final whereClause = DatabaseUtils.buildWhereClause(conditions);
    final offset = pagina * tamanoPagina;
    
    final maps = await db.query(
      DatabaseConstants.tableProveedores,
      where: whereClause.isNotEmpty ? whereClause.clause : null,
      whereArgs: whereClause.isNotEmpty ? whereClause.args : null,
      orderBy: '${DatabaseConstants.proveedoresNombre} ASC',
      limit: tamanoPagina,
      offset: offset,
    );
    
    return maps.map((map) => _mapToProveedor(map)).toList();
  }
  
  @override
  Future<bool> existeProveedorConNombre(String nombre, {String? excluyendoId}) async {
    final db = await _databaseHelper.database;
    
    String whereClause = '${DatabaseConstants.proveedoresNombre} = ?';
    List<dynamic> whereArgs = [nombre];
    
    if (excluyendoId != null) {
      whereClause += ' AND ${DatabaseConstants.proveedoresId} != ?';
      whereArgs.add(excluyendoId);
    }
    
    final maps = await db.query(
      DatabaseConstants.tableProveedores,
      columns: [DatabaseConstants.proveedoresId],
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );
    
    return maps.isNotEmpty;
  }
  
  @override
  Future<List<String>> obtenerSugerenciasNombres(String query, {int limite = 10}) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableProveedores,
      columns: [DatabaseConstants.proveedoresNombre],
      where: '${DatabaseConstants.proveedoresNombre} LIKE ? AND ${DatabaseConstants.proveedoresActivo} = ?',
      whereArgs: [DatabaseUtils.createLikeCondition(query), 1],
      orderBy: '${DatabaseConstants.proveedoresNombre} ASC',
      limit: limite,
    );
    
    return maps.map((map) => map[DatabaseConstants.proveedoresNombre] as String).toList();
  }
  
  @override
  Future<List<Map<String, dynamic>>> exportarProveedores() async {
    final db = await _databaseHelper.database;
    return await db.query(
      DatabaseConstants.tableProveedores,
      orderBy: '${DatabaseConstants.proveedoresNombre} ASC',
    );
  }
  
  @override
  Future<void> importarProveedores(List<Proveedor> proveedores) async {
    if (proveedores.isEmpty) return;
    
    final db = await _databaseHelper.database;
    final batch = db.batch();
    
    for (final proveedor in proveedores) {
      batch.insert(
        DatabaseConstants.tableProveedores,
        _proveedorToMap(proveedor),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit();
  }
  
  /// Convierte un Map de la base de datos a una entidad Proveedor
  Proveedor _mapToProveedor(Map<String, dynamic> map) {
    return Proveedor(
      id: map[DatabaseConstants.proveedoresId] as String,
      nombre: map[DatabaseConstants.proveedoresNombre] as String,
      tipo: DatabaseUtils.intToTipoProveedor(map[DatabaseConstants.proveedoresTipo] as int),
      activo: (map[DatabaseConstants.proveedoresActivo] as int) == 1,
      direccion: map[DatabaseConstants.proveedoresDireccion] as String?,
      telefono: map[DatabaseConstants.proveedoresTelefono] as String?,
      horarios: map[DatabaseConstants.proveedoresHorarios] as String?,
      notas: map[DatabaseConstants.proveedoresNotas] as String?,
      createdAt: DatabaseUtils.stringToDateTime(map[DatabaseConstants.proveedoresCreatedAt] as String)!,
      updatedAt: DatabaseUtils.stringToDateTime(map[DatabaseConstants.proveedoresUpdatedAt] as String)!,
    );
  }
  
  /// Convierte una entidad Proveedor a un Map para la base de datos
  Map<String, dynamic> _proveedorToMap(Proveedor proveedor) {
    return {
      DatabaseConstants.proveedoresId: proveedor.id,
      DatabaseConstants.proveedoresNombre: proveedor.nombre,
      DatabaseConstants.proveedoresTipo: proveedor.tipo.index,
      DatabaseConstants.proveedoresActivo: proveedor.activo ? 1 : 0,
      DatabaseConstants.proveedoresDireccion: proveedor.direccion,
      DatabaseConstants.proveedoresTelefono: proveedor.telefono,
      DatabaseConstants.proveedoresHorarios: proveedor.horarios,
      DatabaseConstants.proveedoresNotas: proveedor.notas,
      DatabaseConstants.proveedoresCreatedAt: DatabaseUtils.dateTimeToString(proveedor.createdAt),
      DatabaseConstants.proveedoresUpdatedAt: DatabaseUtils.dateTimeToString(proveedor.updatedAt),
    };
  }
}