import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:sazones_semanales/domain/entities/comando_voz.dart';
import 'package:sazones_semanales/domain/services/speech_recognition_service.dart';
import 'package:sazones_semanales/infrastructure/services/permission_service.dart';

/// Implementation of the speech recognition service using speech_to_text package
class SpeechRecognitionServiceImpl implements SpeechRecognitionService {
  /// Instance of the speech_to_text package
  final SpeechToText _speech = SpeechToText();

  /// BuildContext to use for dialogs
  final BuildContext _context;

  /// Flag to track if the service is initialized
  bool _isInitialized = false;

  /// Constructor that requires a BuildContext
  SpeechRecognitionServiceImpl(this._context);

  @override
  Future<bool> initialize() async {
    // Check microphone permission first
    bool hasPermission = await PermissionService.hasMicrophonePermission();
    if (!hasPermission) {
      hasPermission = await PermissionService.requestMicrophonePermission();
      if (!hasPermission) {
        // Show dialog to inform the user that microphone permission is required
        _showPermissionDeniedDialog();
        return false;
      }
    }

    // Initialize the speech recognition service
    _isInitialized = await _speech.initialize(
      onError: (error) => debugPrint('Speech recognition error: $error'),
      onStatus: (status) => debugPrint('Speech recognition status: $status'),
    );

    return _isInitialized;
  }

  @override
  Future<bool> startListening({
    required Function(String text) onResult,
    required Function(String error) onError,
    String? localeId,
  }) async {
    // Initialize if not already initialized
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError('No se pudo inicializar el reconocimiento de voz');
        return false;
      }
    }

    // Start listening
    return await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: localeId ?? 'es-ES', // Default to Spanish
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: false, // Only return final results
      ),
      listenFor: const Duration(seconds: 30), // Listen for up to 30 seconds
      pauseFor: const Duration(seconds: 3), // Auto-stop after 3 seconds of silence
      onSoundLevelChange: (level) => debugPrint('Sound level: $level'),
    );
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
  }

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<List<String>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }

    final locales = await _speech.locales();
    return locales.map((locale) => locale.localeId).toList();
  }

  @override
  Map<String, int> parseConsumptionCommand(String command) {
    final comandoVoz = ComandoVoz.fromText(command);
    return comandoVoz.productos;
  }

  /// Shows a dialog when microphone permission is denied
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
}
