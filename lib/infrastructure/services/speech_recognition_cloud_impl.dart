import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sazones_semanales/core/config/platform_config.dart';
import 'package:sazones_semanales/domain/entities/comando_voz.dart';
import 'package:sazones_semanales/domain/services/speech_recognition_service.dart';
import 'package:sazones_semanales/infrastructure/services/permission_service.dart';

/// Implementación del servicio de reconocimiento de voz usando una API en la nube
class SpeechRecognitionCloudImpl implements SpeechRecognitionService {
  /// BuildContext para mostrar diálogos
  final BuildContext _context;

  /// Indica si el servicio está escuchando
  bool _isListening = false;

  /// Configuración de la plataforma
  final PlatformConfig _platformConfig = PlatformConfig();

  /// Constructor
  SpeechRecognitionCloudImpl(this._context);

  @override
  Future<bool> initialize() async {
    // Verificar permisos de micrófono
    bool hasPermission = await PermissionService.hasMicrophonePermission();
    if (!hasPermission) {
      hasPermission = await PermissionService.requestMicrophonePermission();
      if (!hasPermission) {
        _showPermissionDeniedDialog();
        return false;
      }
    }

    // Verificar si hay una clave de API configurada
    if (_platformConfig.cloudApiKey.isEmpty) {
      _showApiKeyMissingDialog();
      return false;
    }

    return true;
  }

  @override
  Future<bool> startListening({
    required Function(String text) onResult,
    required Function(String error) onError,
    String? localeId,
  }) async {
    if (_isListening) {
      await stopListening();
    }

    final initialized = await initialize();
    if (!initialized) {
      onError('No se pudo inicializar el reconocimiento de voz');
      return false;
    }

    try {
      _isListening = true;

      // Mostrar un diálogo de progreso mientras se graba
      if (_context.mounted) {
        showDialog(
          context: _context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.mic, color: Colors.purple),
                const SizedBox(width: 8),
                const Text('Grabando...'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Hable ahora. Diga algo como:'),
                const SizedBox(height: 8),
                const Text('"Voy a usar 2 manzanas y 1 limón"',
                    style: TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    stopListening();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Detener grabación'),
                ),
              ],
            ),
          ),
        );
      }

      // Crear un archivo temporal para la grabación
      final tempDir = await getTemporaryDirectory();
      final audioFile = path.join(tempDir.path, 'recording.wav');

      // Grabar audio (usando un proceso externo o un plugin de Flutter)
      final recordingResult = await _recordAudio(audioFile);

      // Cerrar el diálogo de grabación
      if (_context.mounted) {
        Navigator.of(_context).pop();

        // Mostrar diálogo de procesamiento
        showDialog(
          context: _context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            title: Row(
              children: [
                Icon(Icons.cloud, color: Colors.blue),
                SizedBox(width: 8),
                Text('Procesando audio en la nube...'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(),
                SizedBox(height: 16),
                Text('Enviando audio a la API...'),
              ],
            ),
          ),
        );
      }

      if (!recordingResult) {
        if (_context.mounted) {
          Navigator.of(_context).pop();
        }
        _isListening = false;
        onError('Error al grabar audio');
        return false;
      }

      // Procesar el audio con la API en la nube
      final recognizedText =
          await _processAudioWithCloudApi(audioFile, localeId ?? 'es');

      // Cerrar el diálogo de procesamiento
      if (_context.mounted) {
        Navigator.of(_context).pop();
      }

      _isListening = false;

      if (recognizedText.isEmpty) {
        onError('No se reconoció ningún texto');
        return false;
      }

      // Llamar al callback con el resultado
      onResult(recognizedText);
      return true;
    } catch (e) {
      // Cerrar diálogos si están abiertos
      if (_context.mounted) {
        Navigator.of(_context, rootNavigator: true).pop();
      }

      _isListening = false;
      onError('Error en el reconocimiento de voz: $e');
      return false;
    }
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;

    // Cerrar el diálogo si está abierto
    if (_context.mounted) {
      Navigator.of(_context, rootNavigator: true).pop();
    }
  }

  @override
  bool get isListening => _isListening;

  @override
  Future<List<String>> getAvailableLocales() async {
    // La API de OpenAI soporta varios idiomas
    return ['es', 'en', 'fr', 'de', 'it', 'pt', 'nl', 'ru', 'zh', 'ja', 'ko'];
  }

  @override
  Map<String, int> parseConsumptionCommand(String command) {
    // Usar la misma implementación de análisis de comandos
    final comandoVoz = ComandoVoz.fromText(command);
    return comandoVoz.productos;
  }

  /// Graba audio usando un proceso externo o un plugin de Flutter
  Future<bool> _recordAudio(String outputFile) async {
    try {
      // En Windows, podemos usar ffmpeg para grabar audio
      if (Platform.isWindows) {
        // Verificar si ffmpeg está disponible
        final ffmpegPath =
            path.join(_platformConfig.baseDir!, 'bin', 'ffmpeg.exe');
        final ffmpegExists = await File(ffmpegPath).exists();

        if (!ffmpegExists) {
          debugPrint('ffmpeg no encontrado en: $ffmpegPath');
          return false;
        }

        // Grabar audio durante 5 segundos
        final process = await Process.run(
          ffmpegPath,
          [
            '-f',
            'dshow',
            '-i',
            'audio=@device_cm_{33D9A762-90C8-11D0-BD43-00A0C911CE86}\\wave_{DFCF0D2D-ABDE-4FD9-A55B-1B3F4EFC8144}',
            '-t',
            '5',
            '-ar',
            '16000',
            '-ac',
            '1',
            '-c:a',
            'pcm_s16le',
            outputFile,
            '-y'
          ],
          runInShell: true,
        );

        if (process.exitCode != 0) {
          debugPrint('Error al grabar audio: ${process.stderr}');
          return false;
        }

        return true;
      } else {
        // Para otras plataformas, implementar usando plugins de Flutter
        // como record o flutter_sound
        return false;
      }
    } catch (e) {
      debugPrint('Error al grabar audio: $e');
      return false;
    }
  }

  /// Procesa el audio con la API en la nube
  Future<String> _processAudioWithCloudApi(
      String audioFile, String language) async {
    try {
      // Crear una solicitud multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(PlatformConfig.cloudSttApiUrl),
      );

      // Agregar encabezados de autorización
      request.headers.addAll({
        'Authorization': 'Bearer ${_platformConfig.cloudApiKey}',
      });

      // Agregar el archivo de audio
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile,
        ),
      );

      // Agregar parámetros
      request.fields.addAll({
        'model': 'whisper-1',
        'language': language,
      });

      // Enviar la solicitud
      final response = await request.send();

      if (response.statusCode == 200) {
        // Procesar la respuesta
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        return jsonResponse['text'] ?? '';
      } else {
        debugPrint('Error en la API: ${response.statusCode}');
        debugPrint('Respuesta: ${await response.stream.bytesToString()}');
        return '';
      }
    } catch (e) {
      debugPrint('Error al procesar audio con la API en la nube: $e');
      return '';
    }
  }

  /// Muestra un diálogo cuando se deniega el permiso del micrófono
  void _showPermissionDeniedDialog() {
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de micrófono requerido'),
        content: const Text(
            'Para reconocer comandos de voz, necesitamos acceso al micrófono. '
            'Por favor, otorga el permiso en la configuración de la aplicación.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openSettings();
            },
            child: const Text('Abrir configuración'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo cuando falta la clave de API
  void _showApiKeyMissingDialog() {
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        title: const Text('Clave de API no configurada'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para usar el reconocimiento de voz en la nube, necesitas configurar una clave de API.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '1. Obtén una clave de API de OpenAI en https://platform.openai.com/api-keys',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '2. Configura la clave en la pantalla de configuración de la aplicación',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
