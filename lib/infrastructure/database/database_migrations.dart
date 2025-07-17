import 'package:sqflite/sqflite.dart';

/// Gestiona las migraciones de la base de datos
class DatabaseMigrations {
  /// Ejecuta todas las migraciones necesarias
  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _executeVersionMigration(db, version);
    }
  }
  
  /// Ejecuta la migración para una versión específica
  static Future<void> _executeVersionMigration(Database db, int version) async {
    switch (version) {
      case 1:
        // Versión inicial - no requiere migración
        break;
        
      case 2:
        await _migrateToV2(db);
        break;
        
      case 3:
        await _migrateToV3(db);
        break;
        
      // Agregar más versiones según sea necesario
      default:
        throw Exception('Migración no implementada para la versión $version');
    }
  }
  
  /// Migración a versión 2 - Ejemplo de agregar columnas
  static Future<void> _migrateToV2(Database db) async {
    // Ejemplo: Agregar columna de ubicación a existencias
    await db.execute('''
      ALTER TABLE existencias 
      ADD COLUMN ubicacion TEXT DEFAULT 'alacena'
    ''');
    
    // Actualizar índices si es necesario
    await db.execute('''
      CREATE INDEX idx_existencias_ubicacion 
      ON existencias(ubicacion)
    ''');
  }
  
  /// Migración a versión 3 - Ejemplo de modificar estructura
  static Future<void> _migrateToV3(Database db) async {
    // Ejemplo: Agregar tabla de categorías personalizadas
    await db.execute('''
      CREATE TABLE categorias_personalizadas (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL UNIQUE,
        color TEXT,
        icono TEXT,
        activa INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE INDEX idx_categorias_activa 
      ON categorias_personalizadas(activa)
    ''');
  }
  
  /// Verifica si una migración específica ya fue aplicada
  static Future<bool> isMigrationApplied(Database db, String migrationName) async {
    try {
      final result = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', migrationName],
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Crea una tabla de control de migraciones (para uso futuro)
  static Future<void> createMigrationTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version INTEGER PRIMARY KEY,
        applied_at TEXT NOT NULL,
        description TEXT
      )
    ''');
  }
  
  /// Registra una migración aplicada
  static Future<void> recordMigration(
    Database db, 
    int version, 
    String description
  ) async {
    await db.insert('schema_migrations', {
      'version': version,
      'applied_at': DateTime.now().toIso8601String(),
      'description': description,
    });
  }
  
  /// Obtiene el historial de migraciones aplicadas
  static Future<List<Map<String, dynamic>>> getMigrationHistory(Database db) async {
    try {
      return await db.query(
        'schema_migrations',
        orderBy: 'version ASC',
      );
    } catch (e) {
      // La tabla no existe, retornar lista vacía
      return [];
    }
  }
}