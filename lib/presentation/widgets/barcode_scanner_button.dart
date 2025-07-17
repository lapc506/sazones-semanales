import 'package:flutter/material.dart';
import 'package:sazones_semanales/infrastructure/services/service_providers.dart';

/// A button widget that triggers the barcode scanner
class BarcodeScannerButton extends StatelessWidget {
  /// Callback function that receives the scanned barcode
  final void Function(String) onBarcodeScanned;
  
  /// Optional label for the button
  final String? label;
  
  /// Constructor
  const BarcodeScannerButton({
    super.key,
    required this.onBarcodeScanned,
    this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.qr_code_scanner),
      label: Text(label ?? 'Escanear código de barras'),
      onPressed: () async {
        // Get the barcode scanner service
        final scannerService = BarcodeScannerServiceProvider.getService(context);
        
        // Scan the barcode
        final barcode = await scannerService.scanBarcode();
        
        // If a barcode was scanned, call the callback
        if (barcode != null) {
          onBarcodeScanned(barcode);
        }
      },
    );
  }
}