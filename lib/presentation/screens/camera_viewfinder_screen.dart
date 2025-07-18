import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sazones_semanales/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Pantalla que muestra un visor de cámara en vivo para tomar fotos
class CameraViewfinderScreen extends StatefulWidget {
  /// Función que se llama cuando se toma una foto exitosamente
  final Function(File) onPhotoTaken;

  /// Función que se llama cuando se cancela la captura
  final Function() onCancel;

  const CameraViewfinderScreen({
    super.key,
    required this.onPhotoTaken,
    required this.onCancel,
  });

  @override
  State<CameraViewfinderScreen> createState() => _CameraViewfinderScreenState();
}

class _CameraViewfinderScreenState extends State<CameraViewfinderScreen>
    with WidgetsBindingObserver {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // Manejar cambios en el ciclo de vida de la app
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeController(cameraController.description);
    }
  }

  /// Inicializa la cámara y el controlador
  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      // Obtener la lista de cámaras disponibles
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'No se encontraron cámaras disponibles';
        });
        return;
      }

      // Usar la cámara trasera por defecto
      final CameraDescription camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      // Inicializar el controlador
      await _initializeController(camera);
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Error al inicializar la cámara: $e';
      });
      debugPrint('Error al inicializar la cámara: $e');
    }
  }

  /// Inicializa el controlador de la cámara
  Future<void> _initializeController(CameraDescription camera) async {
    try {
      // Determinar la resolución óptima basada en el dispositivo
      // Usar medium en lugar de high para dispositivos de gama baja o media
      // para mejorar el rendimiento
      final ResolutionPreset resolution = _getOptimalResolution();

      // Crear un nuevo controlador
      final CameraController controller = CameraController(
        camera,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Inicializar el controlador
      await controller.initialize();

      // Configurar exposición automática y balance de blancos
      if (controller.value.isInitialized) {
        await controller.setExposureMode(ExposureMode.auto);
        await controller.setFocusMode(FocusMode.auto);
      }

      // Actualizar el estado
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitializing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Error al inicializar el controlador: $e';
      });
      debugPrint('Error al inicializar el controlador: $e');
    }
  }

  /// Determina la resolución óptima basada en las características del dispositivo
  ResolutionPreset _getOptimalResolution() {
    // Obtener información sobre el dispositivo
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final Size screenSize = MediaQuery.of(context).size;
    final double screenArea = screenSize.width * screenSize.height;

    // Dispositivos de alta gama (pantallas grandes o alta densidad de píxeles)
    if (devicePixelRatio >= 2.5 || screenArea > 1000000) {
      return ResolutionPreset.high;
    }
    // Dispositivos de gama media
    else if (devicePixelRatio >= 1.5 || screenArea > 500000) {
      return ResolutionPreset.medium;
    }
    // Dispositivos de gama baja
    else {
      return ResolutionPreset.low;
    }
  }

  /// Toma una foto con la cámara
  Future<void> _takePicture() async {
    final CameraController? controller = _controller;

    // Verificar si el controlador está inicializado
    if (controller == null || !controller.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cámara no está inicializada')),
      );
      return;
    }

    // Evitar múltiples capturas simultáneas
    if (_isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      // Mostrar feedback visual (flash de pantalla)
      await _showCaptureEffect();

      // Tomar la foto
      final XFile image = await controller.takePicture();

      // Crear un archivo temporal para la imagen
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = path.join(
          tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      final File imageFile = File(filePath);

      // Copiar la imagen al archivo temporal
      await File(image.path).copy(filePath);

      // Llamar al callback con la imagen capturada
      if (mounted) {
        widget.onPhotoTaken(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al tomar la foto: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  /// Muestra un efecto visual al tomar la foto
  Future<void> _showCaptureEffect() async {
    if (!mounted) return;

    // Crear un overlay blanco que se desvanece
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );

    // Mostrar el overlay
    Overlay.of(context).insert(overlayEntry);

    // Esperar un momento y luego remover el overlay
    await Future.delayed(const Duration(milliseconds: 200));
    overlayEntry.remove();
  }

  /// Anima el botón de captura para dar feedback visual
  void _animateCaptureButton() {
    // Cambiar el estado para activar la animación
    setState(() {
      _isCapturing = true;
    });

    // Después de un breve momento, restaurar el estado
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Tomar Foto',
          style: GoogleFonts.getFont(
            AppConstants.primaryFont,
            fontSize: AppConstants.fontSizeAppBarTitle,
            fontWeight: AppConstants.fontWeightBold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
      ),
      body: _buildBody(),
    );
  }

  /// Construye el cuerpo de la pantalla según el estado
  Widget _buildBody() {
    // Mostrar indicador de carga durante la inicialización
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Inicializando cámara...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    // Mostrar mensaje de error si hay alguno
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onCancel,
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    }

    // Mostrar vista previa de la cámara
    return Column(
      children: [
        // Vista previa de la cámara
        Expanded(
          child: _controller != null
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                )
              : const Center(
                  child: Text(
                    'No se pudo inicializar la cámara',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
        ),

        // Controles de la cámara
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón de captura con animación
              GestureDetector(
                onTap: _isCapturing
                    ? null
                    : () {
                        // Animar el botón al presionar
                        _animateCaptureButton();
                        // Tomar la foto
                        _takePicture();
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isCapturing ? 65 : 72,
                  height: _isCapturing ? 65 : 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _isCapturing ? Colors.grey : Colors.white,
                        width: 4),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isCapturing ? 55 : 60,
                      height: _isCapturing ? 55 : 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _isCapturing ? Colors.grey.shade300 : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
