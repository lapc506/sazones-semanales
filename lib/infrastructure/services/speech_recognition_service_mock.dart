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
      builder: (context) => AlertDialog(
        title: const Text('Simulación de reconocimiento de voz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el texto que deseas simular como reconocimiento de voz:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Ej: Voy a usar 2 manzanas y 1 limón',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}