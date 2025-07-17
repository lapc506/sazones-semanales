import 'package:flutter/material.dart';
import 'package:sazones_semanales/presentation/widgets/speech_recognition_button.dart';

/// A demo screen for the speech recognition service
class SpeechRecognitionDemoScreen extends StatefulWidget {
  /// Constructor
  const SpeechRecognitionDemoScreen({super.key});
  
  @override
  State<SpeechRecognitionDemoScreen> createState() => SpeechRecognitionDemoScreenState();
}

class SpeechRecognitionDemoScreenState extends State<SpeechRecognitionDemoScreen> {
  /// The last recognized text
  String? _lastRecognizedText;
  
  /// The parsed products and quantities
  Map<String, int> _recognizedProducts = {};
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconocimiento de Voz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instrucciones:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Presiona el botón y di algo como:\n'
              '- "Voy a usar 2 manzanas y 1 limón"\n'
              '- "Consumiré 3 huevos y 2 tomates"\n'
              '- "Gastaré 1 paquete de pasta"',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Center(
              child: SpeechRecognitionButton(
                onTextRecognized: (text) {
                  setState(() {
                    _lastRecognizedText = text;
                  });
                },
                onProductsRecognized: (products) {
                  setState(() {
                    _recognizedProducts = products;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            if (_lastRecognizedText != null) ...[
              const Text(
                'Texto reconocido:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _lastRecognizedText!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Productos reconocidos:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_recognizedProducts.isEmpty)
                const Text(
                  'No se reconocieron productos',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _recognizedProducts.length,
                  itemBuilder: (context, index) {
                    final entry = _recognizedProducts.entries.elementAt(index);
                    return ListTile(
                      leading: const Icon(Icons.check_circle),
                      title: Text(entry.key),
                      trailing: Text(
                        '${entry.value}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}