import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/enums.dart';

/// Helper para gestionar la base de datos SQLite local
/// Implementa el patrón Singleton para garantizar una sola instancia
class DatabaseHelper {
  static const String _databaseName = 'inventario_alacena.db';
  static const int _databaseVersion = 1;
  
  // Singleton
  static DatabaseHelper? _instance;
  static Database? _database;
  
  DatabaseHelper._internal();
  
  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }
  
  /// Obtiene la instancia de la base de datos
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }
  
  /// Configuración inicial de la base de datos
  Future<void> _onConfigure(Database db) async {
    // Habilitar claves foráneas
    await db.execute('PRAGMA foreign_keys = ON');
  }
  
  /// Crea las tablas iniciales
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndices(db);
    await _insertDefaultData(db);
  }
  
  /// Maneja las migraciones de la base de datos
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementar migraciones futuras aquí
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _migrateToVersion(db, version);
    }
  }
  
  /// Crea todas las tablas de la base de datos
  Future<void> _createTables(Database db) async {
    // Tabla de proveedores
    await db.execute('''
      CREATE TABLE proveedores (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        tipo INTEGER NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        direccion TEXT,
        telefono TEXT,
        horarios TEXT,
        notas TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Tabla de productos base (para autocompletado y datos compartidos)
    await db.execute('''
      CREATE TABLE productos_base (
        codigo_barras TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        categoria TEXT NOT NULL,
        perecibilidad_default INTEGER NOT NULL,
        restricciones_alimentarias TEXT, -- JSON array
        info_nutricional TEXT, -- JSON object
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Tabla principal de existencias individuales
    await db.execute('''
      CREATE TABLE existencias (
        id TEXT PRIMARY KEY,
        codigo_barras TEXT NOT NULL,
        nombre_producto TEXT NOT NULL,
        categoria TEXT NOT NULL,
        fecha_compra TEXT NOT NULL,
        fecha_caducidad TEXT,
        precio REAL NOT NULL,
        proveedor_id TEXT NOT NULL,
        perecibilidad INTEGER NOT NULL,
        estado INTEGER NOT NULL DEFAULT 0,
        metadatos_json TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (proveedor_id) REFERENCES proveedores (id),
        FOREIGN KEY (codigo_barras) REFERENCES productos_base (codigo_barras)
      )
    ''');
    
    // Tabla de configuración de usuario
    await db.execute('''
      CREATE TABLE configuracion_usuario (
        clave TEXT PRIMARY KEY,
        valor TEXT NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'string',
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Tabla de modos activos
    await db.execute('''
      CREATE TABLE modos_activos (
        modo TEXT PRIMARY KEY,
        activo INTEGER NOT NULL DEFAULT 1,
        configuracion TEXT, -- JSON object
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Tabla de historial de comandos de voz (para análisis y mejora)
    await db.execute('''
      CREATE TABLE historial_comandos_voz (
        id TEXT PRIMARY KEY,
        texto_original TEXT NOT NULL,
        productos_json TEXT NOT NULL, -- JSON array de ProductoMencionado
        confianza REAL NOT NULL,
        reconocido_correctamente INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
    
    // Tabla de notificaciones programadas
    await db.execute('''
      CREATE TABLE notificaciones_programadas (
        id TEXT PRIMARY KEY,
        existencia_id TEXT NOT NULL,
        tipo_notificacion INTEGER NOT NULL,
        fecha_programada TEXT NOT NULL,
        enviada INTEGER NOT NULL DEFAULT 0,
        mensaje TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (existencia_id) REFERENCES existencias (id)
      )
    ''');
  }
  
  /// Crea índices para optimización de consultas
  Future<void> _createIndices(Database db) async {
    // Índices para existencias
    await db.execute('CREATE INDEX idx_existencias_estado ON existencias(estado)');
    await db.execute('CREATE INDEX idx_existencias_fecha_caducidad ON existencias(fecha_caducidad)');
    await db.execute('CREATE INDEX idx_existencias_codigo_barras ON existencias(codigo_barras)');
    await db.execute('CREATE INDEX idx_existencias_proveedor ON existencias(proveedor_id)');
    await db.execute('CREATE INDEX idx_existencias_categoria ON existencias(categoria)');
    await db.execute('CREATE INDEX idx_existencias_perecibilidad ON existencias(perecibilidad)');
    await db.execute('CREATE INDEX idx_existencias_fecha_compra ON existencias(fecha_compra)');
    
    // Índices para productos base
    await db.execute('CREATE INDEX idx_productos_base_nombre ON productos_base(nombre)');
    await db.execute('CREATE INDEX idx_productos_base_categoria ON productos_base(categoria)');
    
    // Índices para proveedores
    await db.execute('CREATE INDEX idx_proveedores_tipo ON proveedores(tipo)');
    await db.execute('CREATE INDEX idx_proveedores_activo ON proveedores(activo)');
    
    // Índices para notificaciones
    await db.execute('CREATE INDEX idx_notificaciones_fecha ON notificaciones_programadas(fecha_programada)');
    await db.execute('CREATE INDEX idx_notificaciones_enviada ON notificaciones_programadas(enviada)');
    await db.execute('CREATE INDEX idx_notificaciones_existencia ON notificaciones_programadas(existencia_id)');
    
    // Índice compuesto para búsquedas frecuentes
    await db.execute('CREATE INDEX idx_existencias_estado_fecha ON existencias(estado, fecha_caducidad)');
    await db.execute('CREATE INDEX idx_existencias_proveedor_fecha ON existencias(proveedor_id, fecha_compra)');
  }
  
  /// Inserta datos por defecto
  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // Configuración por defecto
    await db.insert('configuracion_usuario', {
      'clave': 'notificaciones_habilitadas',
      'valor': 'true',
      'tipo': 'boolean',
      'updated_at': now,
    });
    
    await db.insert('configuracion_usuario', {
      'clave': 'hora_inicio_notificaciones',
      'valor': '08:00',
      'tipo': 'time',
      'updated_at': now,
    });
    
    await db.insert('configuracion_usuario', {
      'clave': 'hora_fin_notificaciones',
      'valor': '20:00',
      'tipo': 'time',
      'updated_at': now,
    });
    
    await db.insert('configuracion_usuario', {
      'clave': 'idioma_voz',
      'valor': 'es-ES',
      'tipo': 'string',
      'updated_at': now,
    });
    
    await db.insert('configuracion_usuario', {
      'clave': 'confianza_minima_voz',
      'valor': '0.7',
      'tipo': 'double',
      'updated_at': now,
    });
    
    // Categorías por defecto
    final categorias = [
      'Alimentos',
      'Bebidas',
      'Limpieza',
      'Higiene Personal',
      'Medicamentos',
      'Mascotas',
      'Otros'
    ];
    
    await db.insert('configuracion_usuario', {
      'clave': 'categorias_personalizadas',
      'valor': jsonEncode(categorias),
      'tipo': 'json',
      'updated_at': now,
    });
  }
  
  /// Ejecuta migraciones específicas por versión
  Future<void> _migrateToVersion(Database db, int version) async {
    switch (version) {
      case 2:
        // Ejemplo de migración futura
        // await db.execute('ALTER TABLE existencias ADD COLUMN nueva_columna TEXT');
        break;
      // Agregar más migraciones según sea necesario
    }
  }
  
  /// Obtiene información sobre el esquema de la base de datos
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    
    // Obtener información de tablas
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    );
    
    // Obtener información de índices
    final indices = await db.rawQuery(
      "SELECT name, tbl_name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'"
    );
    
    return {
      'database_name': _databaseName,
      'version': _databaseVersion,
      'tables': tables,
      'indices': indices,
    };
  }
  
  /// Ejecuta una consulta de diagnóstico para verificar integridad
  Future<bool> checkDatabaseIntegrity() async {
    final db = await database;
    
    try {
      final result = await db.rawQuery('PRAGMA integrity_check');
      return result.isNotEmpty && result.first['integrity_check'] == 'ok';
    } catch (e) {
      return false;
    }
  }
  
  /// Obtiene estadísticas de uso de la base de datos
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;
    
    final existenciasActivas = await db.rawQuery(
      'SELECT COUNT(*) as count FROM existencias WHERE estado = ?',
      [EstadoExistencia.disponible.index]
    );
    
    final existenciasConsumidas = await db.rawQuery(
      'SELECT COUNT(*) as count FROM existencias WHERE estado = ?',
      [EstadoExistencia.consumida.index]
    );
    
    final existenciasCaducadas = await db.rawQuery(
      'SELECT COUNT(*) as count FROM existencias WHERE estado = ?',
      [EstadoExistencia.caducada.index]
    );
    
    final proveedoresActivos = await db.rawQuery(
      'SELECT COUNT(*) as count FROM proveedores WHERE activo = 1'
    );
    
    final productosBase = await db.rawQuery(
      'SELECT COUNT(*) as count FROM productos_base'
    );
    
    return {
      'existencias_activas': existenciasActivas.first['count'] as int,
      'existencias_consumidas': existenciasConsumidas.first['count'] as int,
      'existencias_caducadas': existenciasCaducadas.first['count'] as int,
      'proveedores_activos': proveedoresActivos.first['count'] as int,
      'productos_base': productosBase.first['count'] as int,
    };
  }
  
  /// Limpia datos antiguos para optimizar el rendimiento
  Future<void> cleanupOldData({int daysToKeep = 365}) async {
    final db = await database;
    final cutoffDate = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .toIso8601String();
    
    // Limpiar comandos de voz antiguos
    await db.delete(
      'historial_comandos_voz',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate],
    );
    
    // Limpiar notificaciones enviadas antiguas
    await db.delete(
      'notificaciones_programadas',
      where: 'enviada = 1 AND created_at < ?',
      whereArgs: [cutoffDate],
    );
  }
  
  /// Cierra la conexión a la base de datos
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
  
  /// Elimina completamente la base de datos (para testing o reset completo)
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    
    await close();
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}