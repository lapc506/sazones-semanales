// import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late String environment;

  static Future<void> init() async {
    environment = const String.fromEnvironment('ENVIRONMENT',
        defaultValue: 'development');

    final postgresEnvPath = 'lib/src/sql/postgres_config/.env.$environment';
    final unsplashEnvPath = 'lib/src/api/unsplash/.env.$environment';

    await dotenv.load(fileName: postgresEnvPath);
    await dotenv.load(fileName: unsplashEnvPath, mergeWith: dotenv.env);
  }

  static const String flutterAppName = 'Sazones Semanales';

  static String databaseHostUrl = dotenv.env['POSTGRES_HOST'] ?? '';
  static String databaseName = dotenv.env['POSTGRES_DB'] ?? '';
  static int databasePort = int.parse(dotenv.env['POSTGRES_PORT']!);
  static String databaseAuthUser = dotenv.env['POSTGRES_AUTH_USER'] ?? '';
  static String databaseAuthPassword =
      dotenv.env['POSTGRES_AUTH_PASSWORD'] ?? '';

  static String get unsplashApiKey => dotenv.env['UNSPLASH_API_KEY'] ?? '';
}
