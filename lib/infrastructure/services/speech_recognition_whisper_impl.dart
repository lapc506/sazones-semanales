import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sazones_semanales/core/config/platform_config.dart';
import 'package:sazones_semanales/domain/entities/comando_voz.dart';
import 'package:sazones_semanales/domain/services/speech_recognition_service.dart';
import 'package:sazones_semanales/infrastructure/services/permission_service.dart';
import 'package:sazones_semanales/infrastructure/services/speech_recognition_service_factory.dart';

/// Implementación del servicio de reconocimiento de voz usando whisper.cpp
class SpeechRecognitionWhisperImpl implements SpeechRecognitionService {
  /// BuildContext para mostrar diálogos
  final BuildContext _context;

  /// Indica si el servicio está escuchando
  bool _isListening = false;

  /// Proceso de whisper.cpp
  Process? _whisperProcess;

  /// Configuración de la plataforma
  final PlatformConfig _platformConfig = PlatformConfig();

  /// Constructor
  SpeechRecognitionWhisperImpl(this._context);

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

    // Verificar si el modelo y el binario están disponibles
    await _platformConfig.initialize();

    final modelAvailable = await _platformConfig.isWhisperModelAvailable();
    final binaryAvailable = await _platformConfig.isWhisperBinaryAvailable();

    if (!modelAvailable || !binaryAvailable) {
      _showMissingFilesDialog(modelAvailable, binaryAvailable);
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
                Icon(Icons.settings, color: Colors.purple),
                SizedBox(width: 8),
                Text('Procesando audio...'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(),
                SizedBox(height: 16),
                Text('Convirtiendo audio a texto...'),
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

      // Procesar el audio con whisper.cpp
      final recognizedText =
          await _processAudioWithWhisper(audioFile, localeId ?? 'es');

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

    // Detener la grabación
    // (implementación específica según el método de grabación)

    // Detener el proceso de whisper.cpp si está en ejecución
    if (_whisperProcess != null) {
      _whisperProcess!.kill();
      _whisperProcess = null;
    }

    // Cerrar el diálogo si está abierto
    if (_context.mounted) {
      Navigator.of(_context, rootNavigator: true).pop();
    }
  }

  @override
  bool get isListening => _isListening;

  @override
  Future<List<String>> getAvailableLocales() async {
    // Whisper soporta varios idiomas
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

  /// Procesa el audio con whisper.cpp
  Future<String> _processAudioWithWhisper(
      String audioFile, String language) async {
    try {
      final whisperPath = _platformConfig.whisperBinaryPath!;
      final modelPath = _platformConfig.whisperModelPath!;

      // Ejecutar whisper.cpp
      _whisperProcess = await Process.start(
        whisperPath,
        [
          '-m',
          modelPath,
          '-f',
          audioFile,
          '-l',
          language,
          '--output-txt',
        ],
        runInShell: true,
      );

      // Capturar la salida
      final stdout =
          await _whisperProcess!.stdout.transform(utf8.decoder).join();
      final stderr =
          await _whisperProcess!.stderr.transform(utf8.decoder).join();

      final exitCode = await _whisperProcess!.exitCode;
      _whisperProcess = null;

      if (exitCode != 0) {
        debugPrint('Error al procesar audio con whisper.cpp: $stderr');
        return '';
      }

      // Extraer el texto reconocido
      final outputFile = audioFile.replaceAll('.wav', '.txt');
      if (await File(outputFile).exists()) {
        final text = await File(outputFile).readAsString();
        await File(outputFile).delete();
        return text.trim();
      }

      // Si no se generó un archivo de texto, intentar extraer el texto de la salida estándar
      final regex = RegExp(
          r'\[(\d{2}:\d{2}:\d{2}\.\d{3}) --> \d{2}:\d{2}:\d{2}\.\d{3})\]\s+(.+)');
      final matches = regex.allMatches(stdout);

      if (matches.isNotEmpty) {
        return matches.map((match) => match.group(2)).join(' ').trim();
      }

      return '';
    } catch (e) {
      debugPrint('Error al procesar audio con whisper.cpp: $e');
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

  /// Muestra un diálogo cuando faltan archivos necesarios
  void _showMissingFilesDialog(bool modelAvailable, bool binaryAvailable) {
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        title: const Text('Archivos necesarios no encontrados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Para usar el reconocimiento de voz con whisper.cpp, necesitas los siguientes archivos:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  modelAvailable ? Icons.check_circle : Icons.error,
                  color: modelAvailable ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Modelo: ${_platformConfig.whisperModelPath ?? "No configurado"}',
                    style: TextStyle(
                      color: modelAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  binaryAvailable ? Icons.check_circle : Icons.error,
                  color: binaryAvailable ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Binario: ${_platformConfig.whisperBinaryPath ?? "No configurado"}',
                    style: TextStyle(
                      color: binaryAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Por favor, descarga los archivos necesarios y colócalos en las rutas indicadas.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (_platformConfig.useCloudFallback) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Usar la API en la nube como fallback
                _useFallbackService(context);
              },
              child: const Text('Usar API en la nube'),
            ),
          ],
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Abrir la pantalla de configuración
              _openConfigScreen(context);
            },
            child: const Text('Configurar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Abrir la URL para descargar los archivos
              _openDownloadUrl(context, !modelAvailable);
            },
            child: const Text('Descargar archivos'),
          ),
        ],
      ),
    );
  }

  /// Abre la URL para descargar los archivos
  void _openDownloadUrl(BuildContext context, bool downloadModel) {
    final url = downloadModel
        ? PlatformConfig.whisperModelUrl
        : PlatformConfig.whisperBinaryUrl;

    // Aquí deberías usar url_launcher para abrir la URL
    // Por ahora, mostramos un diálogo con la URL
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descargar archivos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Por favor, descarga los archivos necesarios desde la siguiente URL:',
            ),
            const SizedBox(height: 16),
            SelectableText(
              url,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Una vez descargados, configura las rutas en la pantalla de configuración.',
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

  /// Abre la pantalla de configuración
  void _openConfigScreen(BuildContext context) {
    // Navegar a la pantalla de configuración
    Navigator.of(context).pushNamed('/speech_recognition_config');
  }

  /// Usa el servicio de fallback
  void _useFallbackService(BuildContext context) {
    // Cambiar a la implementación en la nube
    SpeechRecognitionServiceFactory.setImplementation(
        SpeechRecognitionImplementation.cloud);

    // Mostrar un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usando la API en la nube como fallback'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
