import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const GestorInventarioApp());
}

class GestorInventarioApp extends StatelessWidget {
  const GestorInventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers will be added as we implement the application layers
      ],
      child: MaterialApp(
        title: 'Gestor de Inventario de Alacena',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(
            child: Text(
              'Gestor de Inventario de Alacena\nConfiguración inicial completada',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}