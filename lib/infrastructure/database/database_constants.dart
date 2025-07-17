/// Constantes para la base de datos
class DatabaseConstants {
  // Información de la base de datos
  static const String databaseName = 'inventario_alacena.db';
  static const int databaseVersion = 1;
  
  // Nombres de tablas
  static const String tableExistencias = 'existencias';
  static const String tableProductosBase = 'productos_base';
  static const String tableProveedores = 'proveedores';
  static const String tableConfiguracionUsuario = 'configuracion_usuario';
  static const String tableModosActivos = 'modos_activos';
  static const String tableHistorialComandosVoz = 'historial_comandos_voz';
  static const String tableNotificacionesProgramadas = 'notificaciones_programadas';
  static const String tableSchemaMigrations = 'schema_migrations';
  
  // Columnas de existencias
  static const String existenciasId = 'id';
  static const String existenciasCodigoBarras = 'codigo_barras';
  static const String existenciasNombreProducto = 'nombre_producto';
  static const String existenciasCategoria = 'categoria';
  static const String existenciasFechaCompra = 'fecha_compra';
  static const String existenciasFechaCaducidad = 'fecha_caducidad';
  static const String existenciasPrecio = 'precio';
  static const String existenciasProveedorId = 'proveedor_id';
  static const String existenciasPerecibilidad = 'perecibilidad';
  static const String existenciasEstado = 'estado';
  static const String existenciasMetadatosJson = 'metadatos_json';
  static const String existenciasCreatedAt = 'created_at';
  static const String existenciasUpdatedAt = 'updated_at';
  
  // Columnas de productos base
  static const String productosBaseCodigoBarras = 'codigo_barras';
  static const String productosBaseNombre = 'nombre';
  static const String productosBaseCategoria = 'categoria';
  static const String productosBasePerecibilidadDefault = 'perecibilidad_default';
  static const String productosBaseRestriccionesAlimentarias = 'restricciones_alimentarias';
  static const String productosBaseInfoNutricional = 'info_nutricional';
  static const String productosBaseCreatedAt = 'created_at';
  static const String productosBaseUpdatedAt = 'updated_at';
  
  // Columnas de proveedores
  static const String proveedoresId = 'id';
  static const String proveedoresNombre = 'nombre';
  static const String proveedoresTipo = 'tipo';
  static const String proveedoresActivo = 'activo';
  static const String proveedoresDireccion = 'direccion';
  static const String proveedoresTelefono = 'telefono';
  static const String proveedoresHorarios = 'horarios';
  static const String proveedoresNotas = 'notas';
  static const String proveedoresCreatedAt = 'created_at';
  static const String proveedoresUpdatedAt = 'updated_at';
  
  // Columnas de configuración
  static const String configuracionClave = 'clave';
  static const String configuracionValor = 'valor';
  static const String configuracionTipo = 'tipo';
  static const String configuracionUpdatedAt = 'updated_at';
  
  // Columnas de modos activos
  static const String modosActivosModo = 'modo';
  static const String modosActivosActivo = 'activo';
  static const String modosActivosConfiguracion = 'configuracion';
  static const String modosActivosCreatedAt = 'created_at';
  static const String modosActivosUpdatedAt = 'updated_at';
  
  // Columnas de historial comandos voz
  static const String historialVozId = 'id';
  static const String historialVozTextoOriginal = 'texto_original';
  static const String historialVozProductosJson = 'productos_json';
  static const String historialVozConfianza = 'confianza';
  static const String historialVozReconocidoCorrectamente = 'reconocido_correctamente';
  static const String historialVozTimestamp = 'timestamp';
  
  // Columnas de notificaciones programadas
  static const String notificacionesId = 'id';
  static const String notificacionesExistenciaId = 'existencia_id';
  static const String notificacionesTipoNotificacion = 'tipo_notificacion';
  static const String notificacionesFechaProgramada = 'fecha_programada';
  static const String notificacionesEnviada = 'enviada';
  static const String notificacionesMensaje = 'mensaje';
  static const String notificacionesCreatedAt = 'created_at';
  
  // Consultas comunes
  static const String queryExistenciasActivas = '''
    SELECT * FROM $tableExistencias 
    WHERE $existenciasEstado = 0 
    ORDER BY $existenciasFechaCaducidad ASC
  ''';
  
  static const String queryExistenciasProximasACaducar = '''
    SELECT * FROM $tableExistencias 
    WHERE $existenciasEstado = 0 
    AND $existenciasFechaCaducidad IS NOT NULL
    AND date($existenciasFechaCaducidad) <= date('now', '+? days')
    ORDER BY $existenciasFechaCaducidad ASC
  ''';
  
  static const String queryExistenciasPorProveedor = '''
    SELECT e.*, p.nombre as proveedor_nombre 
    FROM $tableExistencias e
    JOIN $tableProveedores p ON e.$existenciasProveedorId = p.$proveedoresId
    WHERE e.$existenciasProveedorId = ?
    ORDER BY e.$existenciasFechaCompra DESC
  ''';
  
  static const String queryProductosAutocompletado = '''
    SELECT DISTINCT $productosBaseNombre, $productosBaseCategoria
    FROM $tableProductosBase 
    WHERE $productosBaseNombre LIKE ?
    ORDER BY $productosBaseNombre ASC
    LIMIT 10
  ''';
  
  static const String queryEstadisticasPrecios = '''
    SELECT 
      $existenciasNombreProducto,
      AVG($existenciasPrecio) as precio_promedio,
      MIN($existenciasPrecio) as precio_minimo,
      MAX($existenciasPrecio) as precio_maximo,
      COUNT(*) as cantidad_compras
    FROM $tableExistencias
    WHERE $existenciasNombreProducto = ?
    GROUP BY $existenciasNombreProducto
  ''';
  
  static const String queryGastosPorCategoria = '''
    SELECT 
      $existenciasCategoria,
      SUM($existenciasPrecio) as total_gastado,
      COUNT(*) as cantidad_productos,
      AVG($existenciasPrecio) as precio_promedio
    FROM $tableExistencias
    WHERE date($existenciasFechaCompra) BETWEEN ? AND ?
    GROUP BY $existenciasCategoria
    ORDER BY total_gastado DESC
  ''';
  
  static const String queryGastosPorProveedor = '''
    SELECT 
      p.$proveedoresNombre,
      SUM(e.$existenciasPrecio) as total_gastado,
      COUNT(*) as cantidad_productos,
      AVG(e.$existenciasPrecio) as precio_promedio
    FROM $tableExistencias e
    JOIN $tableProveedores p ON e.$existenciasProveedorId = p.$proveedoresId
    WHERE date(e.$existenciasFechaCompra) BETWEEN ? AND ?
    GROUP BY p.$proveedoresId, p.$proveedoresNombre
    ORDER BY total_gastado DESC
  ''';
  
  // Configuraciones por defecto
  static const Map<String, dynamic> defaultConfiguration = {
    'notificaciones_habilitadas': true,
    'hora_inicio_notificaciones': '08:00',
    'hora_fin_notificaciones': '20:00',
    'idioma_voz': 'es-ES',
    'confianza_minima_voz': 0.7,
    'frecuencia_sugerencias_dias': 15,
    'considerar_patrones_historicos': true,
  };
  
  // Categorías por defecto
  static const List<String> defaultCategories = [
    'Alimentos',
    'Bebidas',
    'Limpieza',
    'Higiene Personal',
    'Medicamentos',
    'Mascotas',
    'Jardinería',
    'Ferretería',
    'Suplementos',
    'Otros',
  ];
  
  // Límites de consulta
  static const int defaultQueryLimit = 50;
  static const int maxQueryLimit = 500;
  static const int autocompletadoLimit = 10;
  
  // Configuración de limpieza de datos
  static const int defaultDataRetentionDays = 365;
  static const int commandHistoryRetentionDays = 90;
  static const int notificationHistoryRetentionDays = 30;
}