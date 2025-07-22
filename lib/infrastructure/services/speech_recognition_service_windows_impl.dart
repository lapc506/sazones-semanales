import 'package:flutter/material.dart';
import 'package:sazones_semanales/domain/entities/comando_voz.dart';
import 'package:sazones_semanales/domain/services/speech_recognition_service.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Implementación del servicio de reconocimiento de voz para Windows
class SpeechRecognitionServiceWindowsImpl implements SpeechRecognitionService {
  /// BuildContext para mostrar diálogos
  final BuildContext _context;

  /// Indica si el servicio está escuchando
  bool _isListening = false;

  /// Instancia del reconocedor de voz de Windows
  Pointer<COMObject>? _recognizer;

  /// Instancia del contexto de reconocimiento
  Pointer<COMObject>? _context_win;

  /// Instancia del motor de gramática
  Pointer<COMObject>? _grammar;

  /// Constructor
  SpeechRecognitionServiceWindowsImpl(this._context);

  @override
  Future<bool> initialize() async {
    try {
      // Inicializar COM
      final hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
      if (FAILED(hr)) {
        debugPrint('Error al inicializar COM: $hr');
        return false;
      }

      // Crear reconocedor de voz
      final recognizerPtr = calloc<Pointer<COMObject>>();
      final hr2 = CoCreateInstance(
        CLSIDFromString(TEXT("SAPI.SpInprocRecognizer")),
        nullptr,
        CLSCTX_ALL,
        IIDFromString(TEXT(
            "{41B89B6B-9399-11D2-9623-00C04F8EE628}")), // IID_ISpRecognizer
        recognizerPtr.cast(),
      );

      if (FAILED(hr2)) {
        calloc.free(recognizerPtr);
        debugPrint('Error al crear reconocedor: $hr2');
        return false;
      }

      _recognizer = recognizerPtr.value;
      calloc.free(recognizerPtr);

      // Configurar el reconocedor con el audio del micrófono
      final audioInputPtr = calloc<Pointer<COMObject>>();
      final hr3 = CoCreateInstance(
        CLSIDFromString(TEXT("SAPI.SpMMAudioIn")),
        nullptr,
        CLSCTX_ALL,
        IIDFromString(TEXT(
            "{6C44DF74-72B9-4992-A1EC-EF996E0422D4}")), // IID_ISpMMSysAudioIn
        audioInputPtr.cast(),
      );

      if (FAILED(hr3)) {
        calloc.free(audioInputPtr);
        debugPrint('Error al crear entrada de audio: $hr3');
        return false;
      }

      final audioInput = audioInputPtr.value;
      calloc.free(audioInputPtr);

      // Crear contexto de reconocimiento
      final contextPtr = calloc<Pointer<COMObject>>();
      final hr4 = CoCreateInstance(
        CLSIDFromString(TEXT("SAPI.SpInProcRecoContext")),
        nullptr,
        CLSCTX_ALL,
        IIDFromString(TEXT(
            "{73AD6842-ACE0-45E8-A4DD-8795881A2C2A}")), // IID_ISpRecoContext
        contextPtr.cast(),
      );

      if (FAILED(hr4)) {
        calloc.free(contextPtr);
        debugPrint('Error al crear contexto de reconocimiento: $hr4');
        return false;
      }

      _context_win = contextPtr.value;
      calloc.free(contextPtr);

      // Crear gramática
      final grammarPtr = calloc<Pointer<COMObject>>();
      final hr5 = CoCreateInstance(
        CLSIDFromString(TEXT("SAPI.SpGrammarCompiler")),
        nullptr,
        CLSCTX_ALL,
        IIDFromString(TEXT(
            "{B9AC5783-FCD0-4B21-B119-B4F8DA8FD2C3}")), // IID_ISpGrammarCompiler
        grammarPtr.cast(),
      );

      if (FAILED(hr5)) {
        calloc.free(grammarPtr);
        debugPrint('Error al crear gramática: $hr5');
        return false;
      }

      _grammar = grammarPtr.value;
      calloc.free(grammarPtr);

      // Configurar gramática para reconocimiento de comandos de voz en español
      // Este es un ejemplo simplificado, en una implementación real
      // necesitarías definir una gramática XML completa para SAPI

      return true;
    } catch (e) {
      debugPrint('Error al inicializar el reconocimiento de voz: $e');
      return false;
    }
  }

  @override
  Future<bool> startListening({
    required Function(String text) onResult,
    required Function(String error) onError,
    String? localeId,
  }) async {
    if (_recognizer == null) {
      final initialized = await initialize();
      if (!initialized) {
        onError('No se pudo inicializar el reconocimiento de voz');
        return false;
      }
    }

    try {
      _isListening = true;

      // Mostrar un diálogo de progreso mientras se escucha
      if (_context.mounted) {
        showDialog(
          context: _context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.mic, color: Colors.purple),
                const SizedBox(width: 8),
                const Text('Escuchando...'),
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
              ],
            ),
          ),
        );
      }

      // En una implementación real, aquí configurarías un evento para capturar
      // el resultado del reconocimiento. Por ahora, simularemos un resultado después de un tiempo
      await Future.delayed(const Duration(seconds: 3));

      // Simular un resultado de reconocimiento
      final result = "Voy a usar 2 manzanas y 1 limón";

      // Cerrar el diálogo de progreso
      if (_context.mounted) {
        Navigator.of(_context).pop();
      }

      // Llamar al callback con el resultado
      onResult(result);

      _isListening = false;
      return true;
    } catch (e) {
      _isListening = false;

      // Cerrar el diálogo de progreso si está abierto
      if (_context.mounted) {
        Navigator.of(_context).pop();
      }

      onError('Error en el reconocimiento de voz: $e');
      return false;
    }
  }

  @override
  Future<void> stopListening() async {
    // Detener el reconocimiento
    _isListening = false;

    // Cerrar el diálogo de progreso si está abierto
    if (_context.mounted) {
      Navigator.of(_context, rootNavigator: true).pop();
    }
  }

  @override
  bool get isListening => _isListening;

  @override
  Future<List<String>> getAvailableLocales() async {
    // En una implementación real, consultarías las locales disponibles en Windows
    return ['es-ES', 'en-US', 'es-MX', 'fr-FR', 'de-DE'];
  }

  @override
  Map<String, int> parseConsumptionCommand(String command) {
    // Usar la misma implementación de análisis de comandos
    final comandoVoz = ComandoVoz.fromText(command);
    return comandoVoz.productos;
  }

  /// Liberar recursos
  void dispose() {
    if (_grammar != null) {
      final grammar = _grammar!;
      final unknown = grammar.toInterface(IUnknown.fromPtr);
      unknown.Release();
      _grammar = null;
    }

    if (_context_win != null) {
      final context = _context_win!;
      final unknown = context.toInterface(IUnknown.fromPtr);
      unknown.Release();
      _context_win = null;
    }

    if (_recognizer != null) {
      final recognizer = _recognizer!;
      final unknown = recognizer.toInterface(IUnknown.fromPtr);
      unknown.Release();
      _recognizer = null;
    }

    CoUninitialize();
  }
}
