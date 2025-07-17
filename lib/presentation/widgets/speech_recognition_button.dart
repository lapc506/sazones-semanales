import 'package:flutter/material.dart';
import 'package:sazones_semanales/infrastructure/services/service_providers.dart';

/// A button widget that triggers speech recognition
class SpeechRecognitionButton extends StatefulWidget {
  /// Callback function that receives the recognized text
  final void Function(String) onTextRecognized;
  
  /// Callback function that receives the parsed products and quantities
  final void Function(Map<String, int>) onProductsRecognized;
  
  /// Optional label for the button
  final String? label;
  
  /// Constructor
  const SpeechRecognitionButton({
    super.key,
    required this.onTextRecognized,
    required this.onProductsRecognized,
    this.label,
  });
  
  @override
  State<SpeechRecognitionButton> createState() => SpeechRecognitionButtonState();
}

class SpeechRecognitionButtonState extends State<SpeechRecognitionButton> {
  bool _isListening = false;
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
      label: Text(widget.label ?? (_isListening ? 'Escuchando...' : 'Reconocer voz')),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isListening ? Colors.red : null,
        foregroundColor: _isListening ? Colors.white : null,
      ),
      onPressed: _toggleListening,
    );
  }
  
  /// Toggles the listening state
  void _toggleListening() async {
    final service = SpeechRecognitionServiceProvider.getService(context);
    
    if (_isListening) {
      // Stop listening
      await service.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      // Start listening
      setState(() {
        _isListening = true;
      });
      
      final success = await service.startListening(
        onResult: (text) {
          // Call the callback with the recognized text
          widget.onTextRecognized(text);
          
          // Parse the command and call the callback with the products
          final products = service.parseConsumptionCommand(text);
          widget.onProductsRecognized(products);
          
          // Update the state
          setState(() {
            _isListening = false;
          });
        },
        onError: (error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
            ),
          );
          
          // Update the state
          setState(() {
            _isListening = false;
          });
        },
      );
      
      if (!success) {
        // Update the state if starting listening failed
        setState(() {
          _isListening = false;
        });
      }
    }
  }
}