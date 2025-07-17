import 'package:flutter/material.dart';
import 'package:sazones_semanales/infrastructure/services/service_providers.dart';
import 'package:sazones_semanales/presentation/widgets/barcode_scanner_button.dart';

/// A demo screen for the barcode scanner
class BarcodeScannerDemoScreen extends StatefulWidget {
  /// Constructor
  const BarcodeScannerDemoScreen({super.key});

  @override
  BarcodeScannerDemoScreenState createState() =>
      BarcodeScannerDemoScreenState();
}

class BarcodeScannerDemoScreenState extends State<BarcodeScannerDemoScreen> {
  /// The last scanned barcode
  String? _lastScannedBarcode;

  /// The type of the last scanned barcode
  String? _barcodeType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner de Códigos de Barras'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BarcodeScannerButton(
              onBarcodeScanned: (barcode) {
                // Get the barcode type
                final scannerService =
                    BarcodeScannerServiceProvider.getService(context);
                final type = scannerService.getBarcodeType(barcode);

                // Update the state
                setState(() {
                  _lastScannedBarcode = barcode;
                  _barcodeType = type;
                });
              },
            ),
            const SizedBox(height: 32),
            if (_lastScannedBarcode != null) ...[
              const Text(
                'Último código escaneado:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _lastScannedBarcode!,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              if (_barcodeType != null) ...[
                Text(
                  'Tipo de código: $_barcodeType',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ] else ...[
              const Text(
                'Escanea un código de barras para ver el resultado',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
