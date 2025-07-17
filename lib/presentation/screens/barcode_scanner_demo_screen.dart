import 'package:flutter/material.dart';
import 'package:sazones_semanales/infrastructure/services/service_providers.dart';
import 'package:sazones_semanales/presentation/widgets/barcode_scanner_button.dart';
import 'package:sazones_semanales/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: Text(
          'Escáner de Códigos de Barras',
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
              Text(
                'Último código escaneado:',
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: AppConstants.fontSizeSubheading,
                  fontWeight: AppConstants.fontWeightBold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _lastScannedBarcode!,
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: AppConstants.fontSizeHeading,
                  fontWeight: AppConstants.fontWeightMedium,
                ),
              ),
              const SizedBox(height: 16),
              if (_barcodeType != null) ...[
                Text(
                  'Tipo de código: $_barcodeType',
                  style: GoogleFonts.getFont(
                    AppConstants.primaryFont,
                    fontSize: AppConstants.fontSizeBody,
                    fontWeight: AppConstants.fontWeightMedium,
                  ),
                ),
              ],
            ] else ...[
              Text(
                'Escanea un código de barras para ver el resultado',
                style: GoogleFonts.getFont(
                  AppConstants.primaryFont,
                  fontSize: AppConstants.fontSizeBody,
                  fontWeight: AppConstants.fontWeightMedium,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
