import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sazones_semanales/domain/services/barcode_scanner_service.dart';
import 'package:sazones_semanales/infrastructure/services/permission_service.dart';

/// Implementation of the barcode scanner service using mobile_scanner package
class BarcodeScannerServiceImpl implements BarcodeScannerService {
  /// Regular expressions for validating different barcode formats
  static final Map<String, RegExp> _barcodeRegexes = {
    'EAN-13': RegExp(r'^[0-9]{13}$'),
    'UPC-A': RegExp(r'^[0-9]{12}$'),
    'EAN-8': RegExp(r'^[0-9]{8}$'),
    'UPC-E': RegExp(r'^[0-9]{8}$'),
    'CODE-39': RegExp(r'^[A-Z0-9\-\.\s\$\/\+\%]+$'),
    'CODE-128': RegExp(r'^[\x00-\x7F]+$'),
    'QR': RegExp(r'.+'), // QR codes can contain any text
  };

  /// Constructor with no parameters
  BarcodeScannerServiceImpl([BuildContext? context]);

  @override
  Future<String?> scanBarcode() async {
    // This method needs to be called from a widget that provides a BuildContext
    throw UnsupportedError(
        'Use scanBarcodeWithContext instead, providing a valid BuildContext');
  }

  /// Scans a barcode using the provided BuildContext for navigation
  /// This method should be called directly instead of scanBarcode()
  /// The context should come from a State object that can check if it's still mounted
  Future<String?> scanBarcodeWithContext(
      BuildContext context, bool Function() isMounted) async {
    // Store the permission result before any async operations
    bool hasPermission = await PermissionService.hasCameraPermission();

    // If we don't have permission, request it
    if (!hasPermission) {
      hasPermission = await PermissionService.requestCameraPermission();
    }

    // If we still don't have permission after requesting it
    if (!hasPermission) {
      return null; // Return null without using the context
    }

    // Check if the widget is still mounted before navigating
    if (!isMounted()) {
      return null; // Widget is no longer mounted, don't use the context
    }

    // Since we've verified the widget is still mounted, it's safe to use the context
    // immediately (synchronously) after the check
    // ignore: use_build_context_synchronously
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => _BarcodeScannerScreen(),
      ),
    );
  }

  /// Shows a permission denied dialog - this should be called directly from a widget
  /// that has a fresh BuildContext, not after an async gap
  void showPermissionDeniedDialog(BuildContext context) {
    _showPermissionDeniedDialog(context);
  }

  /// Shows a dialog when camera permission is denied
  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Permiso de cámara requerido'),
        content: const Text(
            'Para escanear códigos de barras, necesitamos acceso a la cámara. '
            'Por favor, otorga el permiso en la configuración de la aplicación.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              PermissionService.openSettings();
            },
            child: const Text('Abrir configuración'),
          ),
        ],
      ),
    );
  }

  @override
  bool isValidBarcode(String barcode) {
    // Check if the barcode matches any of the supported formats
    return _barcodeRegexes.values.any((regex) => regex.hasMatch(barcode));
  }

  @override
  String? getBarcodeType(String barcode) {
    // Check which format the barcode matches
    for (final entry in _barcodeRegexes.entries) {
      if (entry.value.hasMatch(barcode)) {
        return entry.key;
      }
    }
    return null;
  }
}

/// Screen widget for barcode scanning
class _BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  /// Scanner controller for the mobile scanner
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear código de barras'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<TorchState>(
              valueListenable: ValueNotifier<TorchState>(
                  _controller.torchEnabled ? TorchState.on : TorchState.off),
              builder: (context, state, child) {
                return Icon(
                    state == TorchState.on ? Icons.flash_on : Icons.flash_off);
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes[0].rawValue != null) {
                  final String code = barcodes[0].rawValue!;
                  // Close the scanner and return the result
                  Navigator.of(context).pop(code);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Show dialog for manual entry
                _showManualEntryDialog(context);
              },
              child: const Text('Ingresar código manualmente'),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog for manual barcode entry
  void _showManualEntryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final service = BarcodeScannerServiceImpl(); // Updated constructor call

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ingresar código de barras'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ej: 7501234567890',
            labelText: 'Código de barras',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                // Validate the barcode format
                if (service.isValidBarcode(code)) {
                  // Return the manually entered barcode
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop(code);
                } else {
                  // Show error message for invalid format
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Formato de código de barras inválido'),
                    ),
                  );
                }
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
