import 'package:flutter/material.dart';
import 'package:sazones_semanales/presentation/screens/barcode_scanner_demo_screen.dart';
import 'package:sazones_semanales/presentation/screens/speech_recognition_demo_screen.dart';

void main() {
  runApp(const GestorInventarioApp());
}

class GestorInventarioApp extends StatelessWidget {
  const GestorInventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Inventario de Alacena',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Inventario de Alacena'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Gestor de Inventario de Alacena\nConfiguración inicial completada',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerDemoScreen(),
                  ),
                );
              },
              child: const Text('Probar Escáner de Códigos de Barras'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SpeechRecognitionDemoScreen(),
                  ),
                );
              },
              child: const Text('Probar Reconocimiento de Voz'),
            ),
          ],
        ),
      ),
    );
  }
}
