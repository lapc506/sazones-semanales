import 'package:postgres/postgres.dart';
import 'package:sazones_semanales/src/backend/config/config.dart';

class DatabaseService {
  static late final Connection _connection;

  // Inicializar la conexión
  static Future<void> init() async {
    _connection = await Connection.open(
      Endpoint(
        host: AppConfig.databaseHostUrl,
        database: AppConfig.databaseName,
        username: AppConfig.databaseAuthUser,
        password: AppConfig.databaseAuthPassword,
        port: AppConfig.databasePort,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  // Método para acceder a la conexión
  static Connection get connection => _connection;
}
