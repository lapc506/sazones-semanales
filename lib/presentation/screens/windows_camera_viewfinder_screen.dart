import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sazones_semanales/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Pantalla que muestra un visor de cámara en vivo para Windows
///
/// Esta pantalla utiliza la API de cámara de Flutter para mostrar
/// un visor en vivo de la webcam en Windows
class WindowsCameraViewfinderScreen extends StatefulWidget {
  /// Función que se llama cuando se toma una foto exitosamente
  final Function(File) onPhotoTaken;

  /// Función que se llama cuando se cancela la captura
  final Function() onCancel;

  const WindowsCameraViewfinderScreen({
    super.key,
    required this.onPhotoTaken,
    required this.onCancel,
  });

  @override
  State<WindowsCameraViewfinderScreen> createState() =>
      _WindowsCameraViewfinderScreenState();
}

class _WindowsCameraViewfinderScreenState
    extends State<WindowsCameraViewfinderScreen> with WidgetsBindingObserver {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isButtonAnimating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint(
        '📸 [WindowsCameraViewfinderScreen.initState] Inicializando widget');
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    debugPrint('📸 [WindowsCameraViewfinderScreen.dispose] Liberando recursos');
    WidgetsBinding.instance.removeObserver(this);
    if (_controller != null) {
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen.dispose] Liberando controlador de cámara');
      _controller!.dispose();
      _controller = null;
    }
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
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen.didChangeAppLifecycleState] App inactiva, liberando cámara');
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen.didChangeAppLifecycleState] App resumida, reinicializando cámara');
      _initializeController(cameraController.description);
    }
  }

  /// Inicializa la cámara y el controlador
  Future<void> _initializeCamera() async {
    debugPrint(
        '📸 [WindowsCameraViewfinderScreen._initializeCamera] Iniciando inicialización de cámara');
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      // Obtener la lista de cámaras disponibles
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._initializeCamera] Obteniendo lista de cámaras disponibles');
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint(
            '📸 [WindowsCameraViewfinderScreen._initializeCamera] No se encontraron cámaras disponibles');
        setState(() {
          _isInitializing = false;
          _errorMessage = 'No se encontraron cámaras disponibles';
        });
        return;
      }

      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._initializeCamera] Cámaras encontradas: ${_cameras!.length}');

      // Usar la primera cámara disponible
      final CameraDescription camera = _cameras!.first;
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._initializeCamera] Usando cámara: ${camera.name}');

      // Inicializar el controlador
      await _initializeController(camera);
    } catch (e) {
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._initializeCamera] Error al inicializar la cámara: $e');
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Error al inicializar la cámara: $e';
      });
    }
  }

  /// Inicializa el controlador de la cámara
  Future<void> _initializeController(CameraDescription camera) async {
    debugPrint(
        '📸 [WindowsCameraViewfinderScreen._initializeController] Iniciando inicialización del controlador');
    try {
      // Asegurarse de que cualquier controlador anterior sea liberado
      if (_controller != null) {
        debugPrint(
            '📸 [WindowsCameraViewfinderScreen._initializeController] Liberando controlador existente');
        await _controller!.dispose();
        _controller = null;
      }

      // Crear un nuevo controlador
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._initializeController] Creando nuevo controlador para cámara: ${camera.name}');
      final CameraController controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Inicializar el controlador
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._initializeController] Inicializando controlador...');
      await controller.initialize();
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._initializeController] Controlador inicializado exitosamente');

      // Actualizar el estado
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitializing = false;
        });
        debugPrint(
            '📸 [WindowsCameraViewfinderScreen._initializeController] Estado actualizado');
      }
    } catch (e) {
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._initializeController] Error al inicializar el controlador: $e');
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Error al inicializar el controlador: $e';
      });
    }
  }

  /// Toma una foto con la cámara
  Future<void> _takePicture() async {
    debugPrint(
        '📸 [WindowsCameraViewfinderScreen._takePicture] Iniciando captura de foto');
    final CameraController? controller = _controller;

    // Verificar si el controlador está inicializado
    if (controller == null || !controller.value.isInitialized) {
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._takePicture] La cámara no está inicializada');
      _showErrorMessage('La cámara no está inicializada');
      return;
    }

    // Evitar múltiples capturas simultáneas
    if (_isCapturing) {
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._takePicture] Ya hay una captura en progreso');
      _showErrorMessage('Ya hay una captura en progreso, por favor espere');
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      // Mostrar feedback visual (flash de pantalla)
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._takePicture] Mostrando efecto de captura');
      await _showCaptureEffect();

      // Tomar la foto con timeout para evitar que se quede colgado
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._takePicture] Tomando foto...');

      XFile? image;
      try {
        // Usar un timeout para evitar que la captura se quede colgada
        image = await Future.any([
          controller.takePicture(),
          Future.delayed(const Duration(seconds: 5)).then((_) =>
              throw TimeoutException('La captura de imagen tardó demasiado')),
        ]);
      } on TimeoutException catch (_) {
        if (mounted) {
          _showErrorMessage(
              'La captura de imagen tardó demasiado. Intente nuevamente.');
          setState(() {
            _isCapturing = false;
          });
          return;
        }
      }

      if (image == null) {
        throw Exception('No se pudo capturar la imagen');
      }

      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._takePicture] Foto tomada: ${image.path}');

      // Crear un archivo temporal para la imagen
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = path.join(
          tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      final File imageFile = File(filePath);

      // Copiar la imagen al archivo temporal
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._takePicture] Copiando imagen a archivo temporal: $filePath');
      await File(image.path).copy(filePath);

      // Verificar que el archivo existe y tiene tamaño
      if (!await imageFile.exists() || await imageFile.length() == 0) {
        throw Exception('El archivo de imagen está vacío o no se pudo crear');
      }

      // Llamar al callback con la imagen capturada
      if (mounted) {
        debugPrint(
            '📸 [WindowsCameraViewfinderScreen._takePicture] Llamando a onPhotoTaken con la imagen capturada');
        widget.onPhotoTaken(imageFile);
      }
    } catch (e) {
      debugPrint(
          '📸 [WindowsCameraViewfinderScreen._takePicture] Error al tomar la foto: $e');
      if (mounted) {
        _showErrorMessage(
            'Error al tomar la foto: ${e.toString().split('\n').first}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  /// Muestra un mensaje de error al usuario
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Muestra un efecto visual al tomar la foto
  Future<void> _showCaptureEffect() async {
    if (!mounted) return;

    // Crear un overlay blanco que se desvanece
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.white.withValues(alpha: 180),
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
    debugPrint(
        '📸 [WindowsCameraViewfinderScreen._animateCaptureButton] Animando botón de captura');
    // Cambiar el estado para activar la animación
    setState(() {
      _isButtonAnimating = true;
    });

    // Después de un breve momento, restaurar el estado
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isButtonAnimating = false;
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
        // Botón de retroceso más visible
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white, // Forzar color blanco
            size: 28, // Tamaño más grande
          ),
          onPressed: () {
            debugPrint(
                '📸 [WindowsCameraViewfinderScreen] Botón de cancelar presionado');
            widget.onCancel();
          },
        ),
        // Añadir un botón de cancelar explícito en la barra de acciones
        actions: [
          TextButton(
            onPressed: () {
              debugPrint(
                  '📸 [WindowsCameraViewfinderScreen] Botón de cancelar (texto) presionado');
              widget.onCancel();
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vista previa de la cámara
              _controller != null
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    )
                  : const Center(
                      child: Text(
                        'No se pudo inicializar la cámara',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

              // Indicador de captura en progreso
              if (_isCapturing)
                Container(
                  color: Colors.black.withValues(
                      alpha:
                          77), // 0.3 opacity is approximately 77 in alpha (0.3 * 255 ≈ 77)
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Capturando...',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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
                        debugPrint(
                            '📸 [WindowsCameraViewfinderScreen] Botón de captura presionado');
                        // Animar el botón al presionar
                        _animateCaptureButton();
                        // Tomar la foto
                        _takePicture();
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isButtonAnimating ? 65 : 72,
                  height: _isButtonAnimating ? 65 : 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _isButtonAnimating ? Colors.grey : Colors.white,
                        width: 4),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isButtonAnimating ? 55 : 60,
                      height: _isButtonAnimating ? 55 : 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isButtonAnimating
                            ? Colors.grey.shade300
                            : Colors.white,
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
