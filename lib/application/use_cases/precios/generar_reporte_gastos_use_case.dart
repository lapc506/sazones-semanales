import '../../../domain/repositories/existencia_repository.dart';

/// Tipo de agrupación para el reporte de gastos
enum TipoAgrupacionReporte {
  /// Agrupar por categoría de producto
  categoria,
  
  /// Agrupar por proveedor
  proveedor,
  
  /// Agrupar por mes
  mes,
  
  /// Agrupar por semana
  semana,
}

/// Resultado del reporte de gastos
class ReporteGastosResultado {
  /// Fecha de inicio del período analizado
  final DateTime fechaInicio;
  
  /// Fecha de fin del período analizado
  final DateTime fechaFin;
  
  /// Gasto total en el período
  final double gastoTotal;
  
  /// Tipo de agrupación utilizada
  final TipoAgrupacionReporte tipoAgrupacion;
  
  /// Datos agrupados según el tipo de agrupación
  /// La clave es el nombre del grupo (categoría, proveedor, mes, semana)
  /// El valor es el gasto total en ese grupo
  final Map<String, double> gastosAgrupados;
  
  /// Porcentaje de cada grupo respecto al total
  /// La clave es el nombre del grupo
  /// El valor es el porcentaje (0-100) que representa del total
  final Map<String, double> porcentajesPorGrupo;

  ReporteGastosResultado({
    required this.fechaInicio,
    required this.fechaFin,
    required this.gastoTotal,
    required this.tipoAgrupacion,
    required this.gastosAgrupados,
    required this.porcentajesPorGrupo,
  });
}

/// Caso de uso para generar reportes de gastos
class GenerarReporteGastosUseCase {
  final ExistenciaRepository _existenciaRepository;

  GenerarReporteGastosUseCase(this._existenciaRepository);

  /// Ejecuta el caso de uso para generar un reporte de gastos
  /// 
  /// [fechaInicio] es la fecha de inicio del período a analizar
  /// [fechaFin] es la fecha de fin del período a analizar
  /// [tipoAgrupacion] es el tipo de agrupación a utilizar
  /// 
  /// Retorna un [ReporteGastosResultado] con los datos calculados
  Future<ReporteGastosResultado> execute({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required TipoAgrupacionReporte tipoAgrupacion,
  }) async {
    // Obtener datos según el tipo de agrupación
    List<Map<String, dynamic>> datosAgrupados;
    
    switch (tipoAgrupacion) {
      case TipoAgrupacionReporte.categoria:
        datosAgrupados = await _existenciaRepository.obtenerGastosPorCategoria(
          fechaInicio,
          fechaFin,
        );
        break;
      case TipoAgrupacionReporte.proveedor:
        datosAgrupados = await _existenciaRepository.obtenerGastosPorProveedor(
          fechaInicio,
          fechaFin,
        );
        break;
      case TipoAgrupacionReporte.mes:
        // Implementar lógica para agrupar por mes
        datosAgrupados = await _agruparPorMes(fechaInicio, fechaFin);
        break;
      case TipoAgrupacionReporte.semana:
        // Implementar lógica para agrupar por semana
        datosAgrupados = await _agruparPorSemana(fechaInicio, fechaFin);
        break;
    }
    
    // Calcular gasto total
    double gastoTotal = 0;
    final gastosAgrupados = <String, double>{};
    
    for (final dato in datosAgrupados) {
      final nombre = dato['nombre'] as String;
      final gasto = dato['gasto'] as double;
      
      gastosAgrupados[nombre] = gasto;
      gastoTotal += gasto;
    }
    
    // Calcular porcentajes
    final porcentajesPorGrupo = <String, double>{};
    for (final entry in gastosAgrupados.entries) {
      final nombre = entry.key;
      final gasto = entry.value;
      
      final porcentaje = gastoTotal > 0 ? (gasto / gastoTotal) * 100 : 0 as double;
      porcentajesPorGrupo[nombre] = porcentaje;
    }
    
    return ReporteGastosResultado(
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      gastoTotal: gastoTotal,
      tipoAgrupacion: tipoAgrupacion,
      gastosAgrupados: gastosAgrupados,
      porcentajesPorGrupo: porcentajesPorGrupo,
    );
  }

  /// Agrupa los gastos por mes
  Future<List<Map<String, dynamic>>> _agruparPorMes(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    // Obtener todas las existencias en el rango de fechas
    final existencias = await _existenciaRepository.obtenerExistenciasPorRangoFechas(
      fechaInicio,
      fechaFin,
    );
    
    // Agrupar por mes
    final gastosPorMes = <String, double>{};
    for (final existencia in existencias) {
      final mes = '${existencia.fechaCompra.year}-${existencia.fechaCompra.month.toString().padLeft(2, '0')}';
      
      if (!gastosPorMes.containsKey(mes)) {
        gastosPorMes[mes] = 0;
      }
      
      gastosPorMes[mes] = gastosPorMes[mes]! + existencia.precio;
    }
    
    // Convertir a formato esperado
    return gastosPorMes.entries
        .map((e) => {'nombre': e.key, 'gasto': e.value})
        .toList();
  }

  /// Agrupa los gastos por semana
  Future<List<Map<String, dynamic>>> _agruparPorSemana(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    // Obtener todas las existencias en el rango de fechas
    final existencias = await _existenciaRepository.obtenerExistenciasPorRangoFechas(
      fechaInicio,
      fechaFin,
    );
    
    // Agrupar por semana
    final gastosPorSemana = <String, double>{};
    for (final existencia in existencias) {
      // Calcular número de semana (1-53)
      final primerDiaDelAnio = DateTime(existencia.fechaCompra.year, 1, 1);
      final diferenciaDias = existencia.fechaCompra.difference(primerDiaDelAnio).inDays;
      final numeroSemana = ((diferenciaDias + primerDiaDelAnio.weekday - 1) / 7).ceil();
      
      final semana = '${existencia.fechaCompra.year}-W${numeroSemana.toString().padLeft(2, '0')}';
      
      if (!gastosPorSemana.containsKey(semana)) {
        gastosPorSemana[semana] = 0;
      }
      
      gastosPorSemana[semana] = gastosPorSemana[semana]! + existencia.precio;
    }
    
    // Convertir a formato esperado
    return gastosPorSemana.entries
        .map((e) => {'nombre': e.key, 'gasto': e.value})
        .toList();
  }
}