import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sazones_semanales/domain/entities/comando_voz.dart';
import 'package:sazones_semanales/domain/services/speech_recognition_service.dart';

/// Mock implementation of the speech recognition service for testing and development
class SpeechRecognitionServiceMock implements SpeechRecognitionService {
  /// BuildContext to use for dialogs
  final BuildContext _context;

  /// Flag to track if the service is listening
  bool _isListening = false;

  /// Constructor that requires a BuildContext
  SpeechRecognitionServiceMock(this._context);

  @override
  Future<bool> initialize() async {
    // Mock implementation always initializes successfully
    return true;
  }

  @override
  Future<bool> startListening({
    required Function(String text) onResult,
    required Function(String error) onError,
    String? localeId,
  }) async {
    // Set listening state
    _isListening = true;

    // Show a dialog to simulate speech input
    final result = await _showSpeechInputDialog();

    // Reset listening state
    _isListening = false;

    // If the user entered text, call the result callback
    if (result != null && result.isNotEmpty) {
      onResult(result);
      return true;
    } else {
      onError('No se reconoció ningún texto');
      return false;
    }
  }

  @override
  Future<void> stopListening() async {
    // Reset listening state
    _isListening = false;
  }

  @override
  bool get isListening => _isListening;

  @override
  Future<List<String>> getAvailableLocales() async {
    // Mock implementation returns a list of common locales
    return ['es-ES', 'en-US', 'fr-FR', 'de-DE', 'it-IT'];
  }

  @override
  Map<String, int> parseConsumptionCommand(String command) {
    // Use the real ComandoVoz implementation for parsing
    final comandoVoz = ComandoVoz.fromText(command);
    return comandoVoz.productos;
  }

  /// Shows a dialog to simulate speech input
  Future<String?> _showSpeechInputDialog() async {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: _context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.mic, color: Colors.purple),
            const SizedBox(width: 8),
            const Text('Reconocimiento de voz (simulado)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estás usando la versión simulada del reconocimiento de voz porque:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Estás en una plataforma de escritorio (Windows/macOS/Linux)',
              style: TextStyle(fontSize: 13),
            ),
            const Text(
              '• El reconocimiento de voz real solo funciona en dispositivos móviles',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ingresa el texto que deseas simular como reconocimiento de voz:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Ej: Voy a usar 2 manzanas y 1 limón',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.keyboard),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ejemplos de comandos válidos:',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const Text(
              '• "Voy a usar 2 manzanas y 1 limón"\n• "Consumiré 3 huevos"\n• "Gastaré 1 paquete de pasta"',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.cancel),
            label: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Aceptar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(controller.text),
          ),
        ],
      ),
    );
  }
}
