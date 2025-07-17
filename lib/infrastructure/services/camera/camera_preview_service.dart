import 'dart:io';
import 'package:flutter/material.dart';

/// Resultado de la vista previa de la imagen
enum PreviewAction {
  confirm,   // Usuario confirmó la imagen
  retake,    // Usuario quiere retomar la foto
  cancel     // Usuario canceló (cerró el diálogo)
}

/// Servicio para mostrar la vista previa de la cámara
class CameraPreviewService {
  /// Muestra un diálogo flotante de confirmación para la imagen capturada
  /// 
  /// Retorna un PreviewAction indicando la acción del usuario:
  /// - confirm: El usuario confirmó la imagen
  /// - retake: El usuario quiere retomar la foto
  /// - cancel: El usuario canceló (cerró el diálogo)
  static Future<PreviewAction> showPreviewConfirmation({
    required BuildContext context,
    required File imageFile,
  }) async {
    final result = await showDialog<PreviewAction>(
      context: context,
      barrierDismissible: false, // Evita cerrar al tocar fuera del diálogo
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vista Previa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(PreviewAction.cancel),
                      ),
                    ],
                  ),
                ),
                
                // Imagen
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                // Botones
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón Retomar
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(PreviewAction.retake),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Retomar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      
                      // Botón Confirmar
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(PreviewAction.confirm),
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    // Si el usuario cierra el diálogo sin elegir, consideramos como cancelado
    return result ?? PreviewAction.cancel;
  }
}