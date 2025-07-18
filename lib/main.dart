import 'package:flutter/material.dart';
import 'package:sazones_semanales/presentation/screens/barcode_scanner_demo_screen.dart';
import 'package:sazones_semanales/presentation/screens/consumo_por_voz_screen.dart';
import 'package:sazones_semanales/presentation/screens/existencias_screen.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sazones_semanales/core/constants/app_constants.dart';

void main() {
  // Inicializar sqflite para desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const GestorInventarioApp());
}

class GestorInventarioApp extends StatelessWidget {
  const GestorInventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Crear un tema con la fuente Montserrat de Google Fonts
    // Si no hay conexión a internet, se usará la fuente predeterminada
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        // Aplicar la fuente Montserrat a todo el tema de la aplicación
        textTheme:
            GoogleFonts.getTextTheme(AppConstants.primaryFont, textTheme),
        // También aplicar la fuente a los componentes de Material
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeAppBarTitle,
            fontWeight: FontWeight.bold,
            color: AppConstants.appBarForegroundColor,
          ),
        ),
        // Aplicar la fuente a los botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.getFont(AppConstants.primaryFont,
                fontSize: AppConstants.fontSizeButton),
          ),
        ),
      ),
      home: const HomeScreen(), // Cambiado a HomeScreen como pantalla inicial
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final screenSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppConstants.appBarBackgroundColor,
        foregroundColor: AppConstants.appBarForegroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withAlpha(77), // ~0.3 opacity
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Título principal con estilo mejorado
                Text(
                  'Inventario Doméstico Integral',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    AppConstants.primaryFont,
                    fontSize: AppConstants.fontSizeHeading,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestiona tu alacena de forma inteligente',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    AppConstants.primaryFont,
                    fontSize: AppConstants.fontSizeSubheading,
                    fontWeight: AppConstants
                        .fontWeightMedium, // Medium weight para mejor legibilidad
                    color: colorScheme.onSurface.withAlpha(179), // ~0.7 opacity
                  ),
                ),
                const SizedBox(height: 40),

                // Botón principal - Mi Despensa
                _buildFeatureButton(
                  context: context,
                  icon: Icons.inventory_2_rounded,
                  title: 'Mi Despensa',
                  description: 'Gestiona tus productos y existencias',
                  color: colorScheme.primary,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ExistenciasScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Botones secundarios en fila
                Row(
                  children: [
                    // Botón de Escáner
                    Expanded(
                      child: _buildFeatureButton(
                        context: context,
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'Escáner',
                        description: 'Escanea códigos de barras',
                        color: colorScheme.secondary,
                        isSmall: true,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BarcodeScannerDemoScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Botón de Reconocimiento de Voz
                    Expanded(
                      child: _buildFeatureButton(
                        context: context,
                        icon: Icons.mic_rounded,
                        title: 'Voz',
                        description: 'Comandos por voz',
                        color: colorScheme.tertiary,
                        isSmall: true,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ConsumoPorVozScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const Spacer(),
                Text(
                  'Desarrollado por: ${AppConstants.appAuthors}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    AppConstants.primaryFont,
                    fontSize: AppConstants.fontSizeCaption,
                    fontWeight: AppConstants.fontWeightMedium,
                    color: colorScheme.onSurface.withAlpha(128), // ~0.5 opacity
                  ),
                ),
                Text(
                  'v0.0.1',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    AppConstants.primaryFont,
                    fontSize: AppConstants.fontSizeCaption,
                    fontWeight: AppConstants.fontWeightMedium,
                    color: colorScheme.onSurface.withAlpha(128), // ~0.5 opacity
                  ),
                ),
                Text(
                  '© Todos los derechos reservados. - 2025',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    AppConstants.primaryFont,
                    fontSize: AppConstants.fontSizeCaption,
                    fontWeight: AppConstants.fontWeightMedium,
                    color: colorScheme.onSurface.withAlpha(128), // ~0.5 opacity
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool isSmall = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shadowColor: color.withAlpha(102), // ~0.4 opacity
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // Aplicar color de fondo según el tipo de botón
      color: !isSmall
          ? colorScheme
              .surfaceContainerHighest // Color opaco para el botón principal
          : color.withAlpha(
              40), // Color secundario con baja opacidad para botones pequeños
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 16.0 : 24.0),
          height: isSmall ? 160 : 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Centrar contenido
            children: [
              Icon(
                icon,
                size: isSmall ? 40 : 48,
                color: color,
              ),
              SizedBox(height: isSmall ? 12 : 16),
              Text(
                title,
                textAlign: TextAlign.center, // Centrar texto
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: isSmall ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: isSmall ? 4 : 8),
              Text(
                description,
                textAlign: TextAlign.center, // Centrar texto
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: isSmall
                      ? AppConstants.fontSizeCaption
                      : AppConstants.fontSizeBody,
                  fontWeight: AppConstants
                      .fontWeightMedium, // Medium weight para mejor legibilidad
                  color: colorScheme.onSurface.withAlpha(179), // ~0.7 opacity
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
