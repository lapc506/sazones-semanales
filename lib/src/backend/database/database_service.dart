import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart';

class DatabaseService {
  static late final Connection _connection;

  // Inicializar la conexión
  static Future<void> init() async {
    _connection = await Connection.open(
      Endpoint(
        host: dotenv.env['POSTGRES_HOST']!,
        database: dotenv.env['POSTGRES_DB']!,
        username: dotenv.env['POSTGRES_USER']!,
        password: dotenv.env['POSTGRES_PASSWORD']!,
        port: int.parse(dotenv.env['POSTGRES_PORT']!),
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  // Método para acceder a la conexión
  static Connection get connection => _connection;
}
