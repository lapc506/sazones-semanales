import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Configuración específica para cada plataforma
class PlatformConfig {
  /// Singleton instance
  static final PlatformConfig _instance = PlatformConfig._internal();

  /// Factory constructor
  factory PlatformConfig() => _instance;

  /// Internal constructor
  PlatformConfig._internal();

  /// Directorio base para archivos de la aplicación
  String? _baseDir;

  /// Directorio para modelos de ML
  String? _modelsDir;

  /// Ruta al modelo de whisper.cpp
  String? _whisperModelPath;

  /// Ruta al binario de whisper.cpp
  String? _whisperBinaryPath;

  /// URL para descargar el modelo de whisper.cpp
  static const String whisperModelUrl =
      'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin';

  /// URL para descargar el binario de whisper.cpp
  static const String whisperBinaryUrl =
      'https://github.com/ggml-org/whisper.cpp/releases/tag/v1.7.6';

  /// URL de la API en la nube para STT (fallback)
  static const String cloudSttApiUrl =
      'https://api.openai.com/v1/audio/transcriptions';

  /// Indica si se debe usar la API en la nube como fallback
  bool _useCloudFallback = false;

  /// Clave de API para el servicio en la nube
  String _cloudApiKey = '';

  /// Inicializa la configuración
  Future<void> initialize() async {
    await _initPaths();
    await _createDirectories();
    await loadConfig(); // Intentar cargar la configuración guardada
    await _setDefaultModelPaths(); // Establecer rutas predeterminadas si no se cargaron
  }

  /// Inicializa las rutas base según la plataforma
  Future<void> _initPaths() async {
    if (Platform.isWindows) {
      final appDocDir = await getApplicationDocumentsDirectory();
      _baseDir = path.join(appDocDir.path, 'SazonesSemanales');
      _modelsDir = path.join(_baseDir!, 'models');
    } else if (Platform.isAndroid || Platform.isIOS) {
      final appDocDir = await getApplicationDocumentsDirectory();
      _baseDir = appDocDir.path;
      _modelsDir = path.join(_baseDir!, 'models');
    } else if (Platform.isMacOS || Platform.isLinux) {
      final appSupportDir = await getApplicationSupportDirectory();
      _baseDir = appSupportDir.path;
      _modelsDir = path.join(_baseDir!, 'models');
    } else {
      // Web u otras plataformas no soportadas
      _baseDir = '';
      _modelsDir = '';
    }
  }

  /// Crea los directorios necesarios
  Future<void> _createDirectories() async {
    if (_baseDir!.isNotEmpty) {
      final baseDir = Directory(_baseDir!);
      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }

      final modelsDir = Directory(_modelsDir!);
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }
    }
  }

  /// Establece las rutas predeterminadas para los modelos
  Future<void> _setDefaultModelPaths() async {
    // Definir las ubicaciones posibles para el modelo y el binario
    final List<String> possibleModelLocations = [];
    final List<String> possibleBinaryLocations = [];

    // Ubicación raíz del proyecto (directorio de trabajo actual)
    final String rootDir = Directory.current.path;

    if (Platform.isWindows) {
      // Buscar el modelo en varias ubicaciones en orden de preferencia
      possibleModelLocations.addAll([
        path.join(rootDir, 'ggml-large-v3.bin'), // Raíz del proyecto
        path.join(rootDir, 'models',
            'ggml-large-v3.bin'), // Carpeta models en la raíz
        path.join(
            _baseDir!, 'ggml-large-v3.bin'), // Directorio de la aplicación
        path.join(_modelsDir!,
            'ggml-large-v3.bin'), // Carpeta models en el directorio de la aplicación
        path.join(path.dirname(Platform.resolvedExecutable),
            'ggml-large-v3.bin'), // Junto al ejecutable
      ]);

      // Buscar el binario en varias ubicaciones en orden de preferencia
      possibleBinaryLocations.addAll([
        path.join(rootDir, 'whisper.exe'), // Raíz del proyecto
        path.join(rootDir, 'bin', 'whisper.exe'), // Carpeta bin en la raíz
        path.join(_baseDir!, 'whisper.exe'), // Directorio de la aplicación
        path.join(_baseDir!, 'bin',
            'whisper.exe'), // Carpeta bin en el directorio de la aplicación
        path.join(path.dirname(Platform.resolvedExecutable),
            'whisper.exe'), // Junto al ejecutable
      ]);
    } else if (Platform.isMacOS) {
      // Buscar el modelo en varias ubicaciones en orden de preferencia
      final bundlePath =
          path.dirname(path.dirname(Platform.resolvedExecutable));
      final resourcesPath = path.join(bundlePath, 'Resources');

      possibleModelLocations.addAll([
        path.join(rootDir, 'ggml-large-v3.bin'), // Raíz del proyecto
        path.join(rootDir, 'models',
            'ggml-large-v3.bin'), // Carpeta models en la raíz
        path.join(
            _baseDir!, 'ggml-large-v3.bin'), // Directorio de la aplicación
        path.join(_modelsDir!,
            'ggml-large-v3.bin'), // Carpeta models en el directorio de la aplicación
        path.join(
            resourcesPath, 'ggml-large-v3.bin'), // Recursos de la aplicación
        path.join(resourcesPath, 'models',
            'ggml-large-v3.bin'), // Carpeta models en recursos
      ]);

      // Buscar el binario en varias ubicaciones en orden de preferencia
      possibleBinaryLocations.addAll([
        path.join(rootDir, 'whisper'), // Raíz del proyecto
        path.join(rootDir, 'bin', 'whisper'), // Carpeta bin en la raíz
        path.join(_baseDir!, 'whisper'), // Directorio de la aplicación
        path.join(_baseDir!, 'bin',
            'whisper'), // Carpeta bin en el directorio de la aplicación
        path.join(resourcesPath, 'whisper'), // Recursos de la aplicación
        path.join(resourcesPath, 'bin', 'whisper'), // Carpeta bin en recursos
      ]);
    } else if (Platform.isLinux) {
      // Buscar el modelo en varias ubicaciones en orden de preferencia
      possibleModelLocations.addAll([
        path.join(rootDir, 'ggml-large-v3.bin'), // Raíz del proyecto
        path.join(rootDir, 'models',
            'ggml-large-v3.bin'), // Carpeta models en la raíz
        path.join(
            _baseDir!, 'ggml-large-v3.bin'), // Directorio de la aplicación
        path.join(_modelsDir!,
            'ggml-large-v3.bin'), // Carpeta models en el directorio de la aplicación
        path.join(path.dirname(Platform.resolvedExecutable),
            'ggml-large-v3.bin'), // Junto al ejecutable
      ]);

      // Buscar el binario en varias ubicaciones en orden de preferencia
      possibleBinaryLocations.addAll([
        path.join(rootDir, 'whisper'), // Raíz del proyecto
        path.join(rootDir, 'bin', 'whisper'), // Carpeta bin en la raíz
        path.join(_baseDir!, 'whisper'), // Directorio de la aplicación
        path.join(_baseDir!, 'bin',
            'whisper'), // Carpeta bin en el directorio de la aplicación
        path.join(path.dirname(Platform.resolvedExecutable),
            'whisper'), // Junto al ejecutable
        '/usr/local/bin/whisper', // Instalación global en Linux
      ]);
    } else if (Platform.isAndroid || Platform.isIOS) {
      // En dispositivos móviles, usamos un modelo más pequeño
      possibleModelLocations.addAll([
        path.join(_modelsDir!, 'ggml-tiny.bin'),
        path.join(_baseDir!, 'ggml-tiny.bin'),
      ]);

      _whisperBinaryPath = ''; // No aplicable en móviles
    }

    // Buscar el modelo en las ubicaciones posibles
    for (final location in possibleModelLocations) {
      if (await File(location).exists()) {
        _whisperModelPath = location;
        break;
      }
    }

    // Si no se encontró el modelo, establecer una ubicación predeterminada
    if (_whisperModelPath == null || _whisperModelPath!.isEmpty) {
      if (Platform.isAndroid || Platform.isIOS) {
        _whisperModelPath = path.join(_modelsDir!, 'ggml-tiny.bin');
      } else {
        _whisperModelPath = path.join(rootDir, 'ggml-large-v3.bin');
      }
    }

    // Buscar el binario en las ubicaciones posibles (solo para plataformas de escritorio)
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      for (final location in possibleBinaryLocations) {
        if (await File(location).exists()) {
          _whisperBinaryPath = location;
          break;
        }
      }

      // Si no se encontró el binario, establecer una ubicación predeterminada
      if (_whisperBinaryPath == null || _whisperBinaryPath!.isEmpty) {
        if (Platform.isWindows) {
          _whisperBinaryPath = path.join(rootDir, 'whisper.exe');
        } else {
          _whisperBinaryPath = path.join(rootDir, 'whisper');
        }
      }
    }
  }

  /// Obtiene la ruta al modelo de whisper.cpp
  String? get whisperModelPath => _whisperModelPath;

  /// Establece la ruta al modelo de whisper.cpp
  set whisperModelPath(String? value) {
    _whisperModelPath = value;
  }

  /// Obtiene la ruta al binario de whisper.cpp
  String? get whisperBinaryPath => _whisperBinaryPath;

  /// Establece la ruta al binario de whisper.cpp
  set whisperBinaryPath(String? value) {
    _whisperBinaryPath = value;
  }

  /// Obtiene el directorio base para archivos de la aplicación
  String? get baseDir => _baseDir;

  /// Obtiene el directorio para modelos de ML
  String? get modelsDir => _modelsDir;

  /// Verifica si el modelo de whisper.cpp está disponible
  Future<bool> isWhisperModelAvailable() async {
    if (_whisperModelPath == null || _whisperModelPath!.isEmpty) {
      return false;
    }
    return await File(_whisperModelPath!).exists();
  }

  /// Verifica si el binario de whisper.cpp está disponible
  Future<bool> isWhisperBinaryAvailable() async {
    if (_whisperBinaryPath == null || _whisperBinaryPath!.isEmpty) {
      return false;
    }
    return await File(_whisperBinaryPath!).exists();
  }

  /// Indica si se debe usar la API en la nube como fallback
  bool get useCloudFallback => _useCloudFallback;

  /// Establece si se debe usar la API en la nube como fallback
  set useCloudFallback(bool value) {
    _useCloudFallback = value;
  }

  /// Obtiene la clave de API para el servicio en la nube
  String get cloudApiKey => _cloudApiKey;

  /// Establece la clave de API para el servicio en la nube
  set cloudApiKey(String value) {
    _cloudApiKey = value;
  }

  /// Guarda la configuración en un archivo
  Future<void> saveConfig() async {
    try {
      final configFile = File(path.join(_baseDir!, 'whisper_config.json'));
      final configData = {
        'whisperModelPath': _whisperModelPath,
        'whisperBinaryPath': _whisperBinaryPath,
        'useCloudFallback': _useCloudFallback,
        'cloudApiKey': _cloudApiKey,
      };

      await configFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(configData),
      );
    } catch (e) {
      debugPrint('Error al guardar la configuración: $e');
    }
  }

  /// Carga la configuración desde un archivo
  Future<void> loadConfig() async {
    try {
      final configFile = File(path.join(_baseDir!, 'whisper_config.json'));

      if (await configFile.exists()) {
        final configData = jsonDecode(await configFile.readAsString());

        _whisperModelPath = configData['whisperModelPath'];
        _whisperBinaryPath = configData['whisperBinaryPath'];
        _useCloudFallback = configData['useCloudFallback'] ?? false;
        _cloudApiKey = configData['cloudApiKey'] ?? '';
      }
    } catch (e) {
      debugPrint('Error al cargar la configuración: $e');
    }
  }
}
