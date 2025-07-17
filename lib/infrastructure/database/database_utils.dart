// ignore_for_file: unintended_html_in_doc_comment

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/proveedor.dart';

/// Utilidades para operaciones comunes de base de datos
class DatabaseUtils {
  /// Convierte un DateTime a string ISO para almacenamiento
  static String dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
  
  /// Convierte un string ISO a DateTime
  static DateTime? stringToDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Convierte un enum a int para almacenamiento
  static int enumToInt<T extends Enum>(T enumValue) {
    return enumValue.index;
  }
  
  /// Convierte un int a enum
  static T intToEnum<T extends Enum>(int value, List<T> enumValues) {
    if (value < 0 || value >= enumValues.length) {
      throw ArgumentError('Valor de enum inválido: $value');
    }
    return enumValues[value];
  }
  
  /// Convierte TipoPerecibilidad de int
  static TipoPerecibilidad intToTipoPerecibilidad(int value) {
    return intToEnum(value, TipoPerecibilidad.values);
  }
  
  /// Convierte EstadoExistencia de int
  static EstadoExistencia intToEstadoExistencia(int value) {
    return intToEnum(value, EstadoExistencia.values);
  }
  
  /// Convierte TipoNotificacion de int
  static TipoNotificacion intToTipoNotificacion(int value) {
    return intToEnum(value, TipoNotificacion.values);
  }
  
  /// Convierte TipoProveedor de int
  static TipoProveedor intToTipoProveedor(int value) {
    return intToEnum(value, TipoProveedor.values);
  }
  
  /// Convierte un Map a JSON string para almacenamiento
  static String? mapToJsonString(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return null;
    try {
      return jsonEncode(map);
    } catch (e) {
      return null;
    }
  }
  
  /// Convierte un JSON string a Map
  static Map<String, dynamic> jsonStringToMap(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return {};
    try {
      final decoded = jsonDecode(jsonString);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (e) {
      return {};
    }
  }
  
  /// Convierte una List a JSON string para almacenamiento
  static String? listToJsonString(List<dynamic>? list) {
    if (list == null || list.isEmpty) return null;
    try {
      return jsonEncode(list);
    } catch (e) {
      return null;
    }
  }
  
  /// Convierte un JSON string a List
  static List<dynamic> jsonStringToList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonString);
      return decoded is List ? decoded : [];
    } catch (e) {
      return [];
    }
  }
  
  /// Convierte List<String> a JSON string
  static String? stringListToJsonString(List<String>? list) {
    return listToJsonString(list);
  }
  
  /// Convierte JSON string a List<String>
  static List<String> jsonStringToStringList(String? jsonString) {
    final list = jsonStringToList(jsonString);
    return list.map((item) => item.toString()).toList();
  }
  
  /// Sanitiza un string para búsqueda LIKE
  static String sanitizeForLike(String input) {
    return input
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_')
        .replaceAll("'", "''");
  }
  
  /// Crea una condición LIKE para búsqueda
  static String createLikeCondition(String value) {
    return '%${sanitizeForLike(value)}%';
  }
  
  /// Valida que un ID sea válido (no nulo, no vacío)
  static bool isValidId(String? id) {
    return id != null && id.trim().isNotEmpty;
  }
  
  /// Genera un timestamp actual como string
  static String currentTimestamp() {
    return DateTime.now().toIso8601String();
  }
  
  /// Convierte un boolean a int para SQLite
  static int boolToInt(bool value) {
    return value ? 1 : 0;
  }
  
  /// Convierte un int a boolean desde SQLite
  static bool intToBool(int? value) {
    return value == 1;
  }
  
  /// Ejecuta una transacción de forma segura
  static Future<T> executeTransaction<T>(
    Database db,
    Future<T> Function(Transaction txn) action,
  ) async {
    return await db.transaction<T>((txn) async {
      try {
        return await action(txn);
      } catch (e) {
        // La transacción se revierte automáticamente en caso de error
        rethrow;
      }
    });
  }
  
  /// Ejecuta múltiples operaciones en batch
  static Future<List<dynamic>> executeBatch(
    Database db,
    List<BatchOperation> operations,
  ) async {
    final batch = db.batch();
    
    for (final operation in operations) {
      switch (operation.type) {
        case BatchOperationType.insert:
          batch.insert(operation.table, operation.values!);
          break;
        case BatchOperationType.update:
          batch.update(
            operation.table,
            operation.values!,
            where: operation.where,
            whereArgs: operation.whereArgs,
          );
          break;
        case BatchOperationType.delete:
          batch.delete(
            operation.table,
            where: operation.where,
            whereArgs: operation.whereArgs,
          );
          break;
        case BatchOperationType.rawInsert:
          batch.rawInsert(operation.sql!, operation.arguments);
          break;
        case BatchOperationType.rawUpdate:
          batch.rawUpdate(operation.sql!, operation.arguments);
          break;
        case BatchOperationType.rawDelete:
          batch.rawDelete(operation.sql!, operation.arguments);
          break;
      }
    }
    
    return await batch.commit();
  }
  
  /// Construye una cláusula WHERE con múltiples condiciones
  static WhereClause buildWhereClause(Map<String, dynamic> conditions) {
    if (conditions.isEmpty) {
      return WhereClause('', []);
    }
    
    final whereParts = <String>[];
    final whereArgs = <dynamic>[];
    
    conditions.forEach((column, value) {
      if (value == null) {
        whereParts.add('$column IS NULL');
      } else if (value is List) {
        final placeholders = List.filled(value.length, '?').join(', ');
        whereParts.add('$column IN ($placeholders)');
        whereArgs.addAll(value);
      } else {
        whereParts.add('$column = ?');
        whereArgs.add(value);
      }
    });
    
    return WhereClause(whereParts.join(' AND '), whereArgs);
  }
  
  /// Construye una consulta de paginación
  static String buildPaginationQuery(
    String baseQuery,
    int page,
    int pageSize,
  ) {
    final offset = page * pageSize;
    return '$baseQuery LIMIT $pageSize OFFSET $offset';
  }
  
  /// Valida que los parámetros de paginación sean válidos
  static void validatePaginationParams(int page, int pageSize) {
    if (page < 0) {
      throw ArgumentError('La página debe ser mayor o igual a 0');
    }
    if (pageSize <= 0) {
      throw ArgumentError('El tamaño de página debe ser mayor a 0');
    }
    if (pageSize > 1000) {
      throw ArgumentError('El tamaño de página no puede ser mayor a 1000');
    }
  }
}

/// Representa una operación de batch
class BatchOperation {
  final BatchOperationType type;
  final String table;
  final Map<String, dynamic>? values;
  final String? where;
  final List<dynamic>? whereArgs;
  final String? sql;
  final List<dynamic>? arguments;
  
  BatchOperation.insert(this.table, this.values)
      : type = BatchOperationType.insert,
        where = null,
        whereArgs = null,
        sql = null,
        arguments = null;
  
  BatchOperation.update(this.table, this.values, {this.where, this.whereArgs})
      : type = BatchOperationType.update,
        sql = null,
        arguments = null;
  
  BatchOperation.delete(this.table, {this.where, this.whereArgs})
      : type = BatchOperationType.delete,
        values = null,
        sql = null,
        arguments = null;
  
  BatchOperation.rawInsert(this.sql, [this.arguments])
      : type = BatchOperationType.rawInsert,
        table = '',
        values = null,
        where = null,
        whereArgs = null;
  
  BatchOperation.rawUpdate(this.sql, [this.arguments])
      : type = BatchOperationType.rawUpdate,
        table = '',
        values = null,
        where = null,
        whereArgs = null;
  
  BatchOperation.rawDelete(this.sql, [this.arguments])
      : type = BatchOperationType.rawDelete,
        table = '',
        values = null,
        where = null,
        whereArgs = null;
}

/// Tipos de operaciones de batch
enum BatchOperationType {
  insert,
  update,
  delete,
  rawInsert,
  rawUpdate,
  rawDelete,
}

/// Representa una cláusula WHERE construida
class WhereClause {
  final String clause;
  final List<dynamic> args;
  
  WhereClause(this.clause, this.args);
  
  bool get isEmpty => clause.isEmpty;
  bool get isNotEmpty => clause.isNotEmpty;
}