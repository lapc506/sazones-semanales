import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sazones_semanales/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraPreviewScreen extends StatelessWidget {
  final File imageFile;
  final VoidCallback? onConfirm;
  final VoidCallback? onRetake;

  const CameraPreviewScreen({
    super.key,
    required this.imageFile,
    this.onConfirm,
    this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Vista Previa',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeAppBarTitle,
            fontWeight: AppConstants.fontWeightBold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Imagen en pantalla completa
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Botones de acción
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón Retomar
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Retornar false = retomar
                    onRetake?.call();
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    'Retomar',
                    style: GoogleFonts.getFont(
                      AppConstants.primaryFont,
                      fontSize: AppConstants.fontSizeButton,
                      fontWeight: AppConstants.fontWeightMedium,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                
                // Botón Confirmar
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Retornar true = confirmar
                    onConfirm?.call();
                  },
                  icon: const Icon(Icons.check),
                  label: Text(
                    'Confirmar',
                    style: GoogleFonts.getFont(
                      AppConstants.primaryFont,
                      fontSize: AppConstants.fontSizeButton,
                      fontWeight: AppConstants.fontWeightMedium,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}