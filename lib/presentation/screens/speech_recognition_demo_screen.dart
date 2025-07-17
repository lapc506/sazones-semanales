import 'package:flutter/material.dart';
import 'package:sazones_semanales/presentation/widgets/speech_recognition_button.dart';
import 'package:sazones_semanales/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: Text(
          'Reconocimiento de Voz',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeAppBarTitle,
            fontWeight: AppConstants.fontWeightBold,
            color: AppConstants.appBarForegroundColor,
          ),
        ),
        backgroundColor: AppConstants.appBarBackgroundColor,
        foregroundColor: AppConstants.appBarForegroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instrucciones:',
              style: GoogleFonts.getFont(
                AppConstants.primaryFont,
                fontSize: AppConstants.fontSizeSubheading,
                fontWeight: AppConstants.fontWeightBold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Presiona el botón y di algo como:\n'
              '- "Voy a usar 2 manzanas y 1 limón"\n'
              '- "Consumiré 3 huevos y 2 tomates"\n'
              '- "Gastaré 1 paquete de pasta"',
              style: GoogleFonts.getFont(
                AppConstants.primaryFont,
                fontSize: AppConstants.fontSizeBody,
                fontWeight: AppConstants.fontWeightMedium,
              ),
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
              Text(
                'Texto reconocido:',
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: AppConstants.fontSizeSubheading,
                  fontWeight: AppConstants.fontWeightBold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _lastRecognizedText!,
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: AppConstants.fontSizeBody,
                  fontWeight: AppConstants.fontWeightMedium,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Productos reconocidos:',
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: AppConstants.fontSizeSubheading,
                  fontWeight: AppConstants.fontWeightBold,
                ),
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