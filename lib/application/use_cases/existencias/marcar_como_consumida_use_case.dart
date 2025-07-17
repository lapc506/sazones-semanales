import '../../../domain/repositories/existencia_repository.dart';

/// Caso de uso para marcar una existencia como consumida
class MarcarComoConsumidaUseCase {
  final ExistenciaRepository _existenciaRepository;

  MarcarComoConsumidaUseCase(this._existenciaRepository);

  /// Ejecuta el caso de uso para marcar una existencia como consumida
  /// 
  /// [existenciaId] es el ID de la existencia a marcar como consumida
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` si la existencia no existe
  Future<bool> execute(String existenciaId) async {
    try {
      // Verificar que la existencia exista
      final existencia = await _existenciaRepository.obtenerExistenciaPorId(existenciaId);
      if (existencia == null) {
        return false;
      }

      // Marcar como consumida
      await _existenciaRepository.marcarComoConsumida(existenciaId);
      return true;
    } catch (e) {
      // En caso de error, retornar false
      return false;
    }
  }

  /// Marca múltiples existencias como consumidas
  /// 
  /// [existenciaIds] es la lista de IDs de existencias a marcar como consumidas
  /// 
  /// Retorna la cantidad de existencias marcadas exitosamente
  Future<int> executeMultiple(List<String> existenciaIds) async {
    if (existenciaIds.isEmpty) {
      return 0;
    }

    try {
      await _existenciaRepository.marcarMultiplesComoConsumidas(existenciaIds);
      return existenciaIds.length;
    } catch (e) {
      // En caso de error, intentar marcar una por una para maximizar éxito
      int exitosas = 0;
      for (final id in existenciaIds) {
        final resultado = await execute(id);
        if (resultado) {
          exitosas++;
        }
      }
      return exitosas;
    }
  }
}