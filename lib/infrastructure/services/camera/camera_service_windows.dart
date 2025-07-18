import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'camera_service.dart';
import 'camera_preview_service.dart';
import 'package:sazones_semanales/presentation/screens/windows_camera_viewfinder_screen.dart';

/// Mock de CameraDescription para Windows
class MockCameraDescription {
  final String name;
  final int id;

  const MockCameraDescription({
    required this.name,
    required this.id,
  });
}

/// Mock de XFile para Windows
class MockXFile {
  final String path;

  MockXFile(this.path);
}

/// Mock de CameraController para Windows
class MockCameraController {
  final MockCameraDescription description;
  bool _isInitialized = false;
  bool _isDisposed = false;

  MockCameraController(this.description);

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isDisposed) {
      throw Exception('Controller has been disposed');
    }

    // Simular inicialización
    await Future.delayed(const Duration(milliseconds: 100));
    _isInitialized = true;
  }

  Future<MockXFile> takePicture() async {
    if (!_isInitialized) {
      throw Exception('Controller not initialized');
    }
    if (_isDisposed) {
      throw Exception('Controller has been disposed');
    }

    // En lugar de tomar una foto real, usar FilePicker
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null &&
        result.files.isNotEmpty &&
        result.files.first.path != null) {
      return MockXFile(result.files.first.path!);
    } else {
      throw Exception('No image selected');
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    _isInitialized = false;
  }
}

/// Función mock para availableCameras
Future<List<MockCameraDescription>> mockAvailableCameras() async {
  // Simular que hay una cámara disponible en Windows
  return [
    const MockCameraDescription(
      name: 'Windows Mock Camera',
      id: 0,
    ),
  ];
}

/// Implementación del servicio de cámara para Windows con fallback a mock
class CameraServiceWindows implements CameraService {
  CameraController? _realCameraController;
  MockCameraController? _mockCameraController;
  bool _initialized = false;
  bool _usingRealCamera = false;
  List<CameraDescription>? _realCameras;
  List<MockCameraDescription>? _mockCameras;

  // Stream controller para el estado de inicialización
  final StreamController<CameraInitializationState> _stateController =
      StreamController<CameraInitializationState>.broadcast();
  CameraInitializationState _currentState =
      CameraInitializationState.notInitialized;

  /// Getter que retorna el controlador activo (real o mock)
  dynamic get _cameraController {
    return _usingRealCamera ? _realCameraController : _mockCameraController;
  }

  @override
  Stream<CameraInitializationState> get initializationStateStream =>
      _stateController.stream;

  @override
  CameraInitializationState get currentState => _currentState;

  /// Actualiza el estado de inicialización y notifica a los listeners
  void _updateState(CameraInitializationState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  @override
  Future<void> initializeProactively() async {
    debugPrint(
        '📸 [CameraServiceWindows.initializeProactively] Iniciando inicialización proactiva');
    _updateState(CameraInitializationState.initializing);

    try {
      final result = await _initializeCamera();
      if (result) {
        debugPrint(
            '📸 [CameraServiceWindows.initializeProactively] Inicialización proactiva exitosa');
        _updateState(CameraInitializationState.ready);
      } else {
        debugPrint(
            '📸 [CameraServiceWindows.initializeProactively] Error en inicialización proactiva');
        _updateState(CameraInitializationState.error);
      }
    } catch (e) {
      debugPrint(
          '📸 [CameraServiceWindows.initializeProactively] Error en inicialización proactiva: $e');
      _updateState(CameraInitializationState.error);
    }
  }

  /// Inicializa la cámara intentando usar la API real primero, fallback a mock
  Future<bool> _initializeCamera() async {
    debugPrint(
        '📸 [CameraServiceWindows._initializeCamera] Iniciando inicialización de cámara');

    if (_initialized &&
        (_realCameraController != null || _mockCameraController != null)) {
      debugPrint(
          '📸 [CameraServiceWindows._initializeCamera] Cámara ya inicializada, retornando');
      return true;
    }

    try {
      // Intentar usar la API real de camera primero
      debugPrint(
          '📸 [CameraServiceWindows._initializeCamera] Intentando usar API real de cámara en Windows...');
      _realCameras = await availableCameras();

      if (_realCameras != null && _realCameras!.isNotEmpty) {
        debugPrint(
            '📸 [CameraServiceWindows._initializeCamera] Cámaras reales encontradas: ${_realCameras!.length}');

        // Crear un CameraController real
        _realCameraController = CameraController(
          _realCameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        // Inicializar el controlador real
        await _realCameraController!.initialize();
        _initialized = true;
        _usingRealCamera = true;
        debugPrint(
            '📸 [CameraServiceWindows._initializeCamera] Cámara real inicializada exitosamente');
        return true;
      } else {
        debugPrint(
            '📸 [CameraServiceWindows._initializeCamera] No se encontraron cámaras reales, usando mock');
        return await _initializeMockCamera();
      }
    } catch (e) {
      // Si falla la API real (MissingPluginException, UnimplementedError, etc.)
      debugPrint(
          '📸 [CameraServiceWindows._initializeCamera] API real no disponible, usando mock: $e');
      return await _initializeMockCamera();
    }
  }

  /// Inicializa la cámara mock como fallback
  Future<bool> _initializeMockCamera() async {
    debugPrint(
        '📸 [CameraServiceWindows._initializeMockCamera] Iniciando inicialización de cámara mock');
    try {
      _mockCameras = await mockAvailableCameras();

      if (_mockCameras == null || _mockCameras!.isEmpty) {
        debugPrint(
            '📸 [CameraServiceWindows._initializeMockCamera] No se encontraron cámaras mock en Windows');
        return false;
      }

      // Crear un MockCameraController
      _mockCameraController = MockCameraController(_mockCameras![0]);

      // Inicializar el controlador mock
      await _mockCameraController!.initialize();
      _initialized = true;
      _usingRealCamera = false;
      debugPrint(
          '📸 [CameraServiceWindows._initializeMockCamera] Cámara mock inicializada exitosamente');
      return true;
    } catch (e) {
      debugPrint(
          '📸 [CameraServiceWindows._initializeMockCamera] Error al inicializar la cámara mock en Windows: $e');
      _mockCameraController = null;
      _initialized = false;
      return false;
    }
  }

  /// Libera los recursos de la cámara
  Future<void> _releaseCamera() async {
    debugPrint(
        '📸 [CameraServiceWindows._releaseCamera] Liberando recursos de la cámara');
    try {
      if (_usingRealCamera && _realCameraController != null) {
        debugPrint(
            '📸 [CameraServiceWindows._releaseCamera] Liberando cámara real');
        await _realCameraController!.dispose();
        _realCameraController = null;
      } else if (!_usingRealCamera && _mockCameraController != null) {
        debugPrint(
            '📸 [CameraServiceWindows._releaseCamera] Liberando cámara mock');
        await _mockCameraController!.dispose();
        _mockCameraController = null;
      }
      _initialized = false;
      _usingRealCamera = false;
      debugPrint(
          '📸 [CameraServiceWindows._releaseCamera] Recursos liberados exitosamente');
    } catch (e) {
      debugPrint(
          '📸 [CameraServiceWindows._releaseCamera] Error al liberar recursos de la cámara: $e');
    }
  }

  @override
  Future<bool> isCameraAvailable() async {
    debugPrint(
        '📸 [CameraServiceWindows.isCameraAvailable] Verificando disponibilidad de cámara');
    try {
      // Intentar inicializar la cámara mock para verificar si está disponible
      final result = await _initializeCamera();

      // Si no pudimos inicializar, liberar recursos
      if (!result) {
        debugPrint(
            '📸 [CameraServiceWindows.isCameraAvailable] No se pudo inicializar la cámara, liberando recursos');
        await _releaseCamera();
      }

      debugPrint(
          '📸 [CameraServiceWindows.isCameraAvailable] Resultado: $result');
      return result;
    } catch (e) {
      debugPrint(
          '📸 [CameraServiceWindows.isCameraAvailable] Error al verificar disponibilidad de cámara: $e');
      return false;
    }
  }

  @override
  Future<File?> takePicture({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
  }) async {
    debugPrint(
        '📸 [CameraServiceWindows.takePicture] Iniciando captura de foto');
    try {
      // Intentar inicializar la cámara mock
      final initialized = await _initializeCamera();
      if (!initialized || _cameraController == null) {
        debugPrint(
            '📸 [CameraServiceWindows.takePicture] No se pudo inicializar la cámara en Windows');
        // Si no podemos usar la cámara, redirigir a la selección de archivo
        return await pickImageFromGallery(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      }

      try {
        // Tomar la foto usando el controlador activo (real o mock)
        dynamic xFile;
        if (_usingRealCamera) {
          debugPrint(
              '📸 [CameraServiceWindows.takePicture] Tomando foto con cámara real');
          xFile = await _realCameraController!.takePicture();
        } else {
          debugPrint(
              '📸 [CameraServiceWindows.takePicture] Tomando foto con cámara mock');
          xFile = await _mockCameraController!.takePicture();
        }

        // Crear un File a partir del XFile (real o mock)
        final File file = File(xFile.path);

        // Verificar si el archivo existe
        if (await file.exists()) {
          debugPrint(
              '📸 [CameraServiceWindows.takePicture] Foto capturada exitosamente: ${file.path}');
          return file;
        }
      } catch (e) {
        debugPrint(
            '📸 [CameraServiceWindows.takePicture] Error al tomar foto: $e');
        // Si hay un error al tomar la foto, redirigir a la selección de archivo
        return await pickImageFromGallery(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      }

      return null;
    } catch (e) {
      debugPrint(
          '📸 [CameraServiceWindows.takePicture] Error general al tomar foto: $e');
      // En caso de error, redirigir a la selección de archivo
      return await pickImageFromGallery(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
    } finally {
      // Liberar recursos de la cámara después de tomar la foto
      debugPrint(
          '📸 [CameraServiceWindows.takePicture] Liberando recursos después de tomar foto');
      await _releaseCamera();
    }
  }

  @override
  Future<CaptureResult> takePictureWithPreview({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
    required BuildContext context,
  }) async {
    debugPrint(
        '📸 [CameraServiceWindows.takePictureWithPreview] Iniciando captura con vista previa');
    try {
      // Intentar inicializar la cámara
      final initialized = await _initializeCamera();
      if (!initialized || _cameraController == null) {
        debugPrint(
            '📸 [CameraServiceWindows.takePictureWithPreview] No se pudo inicializar la cámara en Windows');
        // Si no podemos usar la cámara, redirigir a la selección de archivo
        final file = await pickImageFromGallery(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );

        if (file != null) {
          debugPrint(
              '📸 [CameraServiceWindows.takePictureWithPreview] Imagen seleccionada de galería: ${file.path}');
          // En Windows, cuando usamos FilePicker, asumimos que el usuario ya confirmó la selección
          return CaptureResult(imageFile: file, wasConfirmed: true);
        } else {
          debugPrint(
              '📸 [CameraServiceWindows.takePictureWithPreview] Selección de imagen cancelada');
          return CaptureResult(); // Cancelado
        }
      }

      try {
        // Tomar la foto usando el controlador activo (real o mock)
        dynamic xFile;
        if (_usingRealCamera) {
          debugPrint(
              '📸 [CameraServiceWindows.takePictureWithPreview] Tomando foto con cámara real');
          xFile = await _realCameraController!.takePicture();
        } else {
          debugPrint(
              '📸 [CameraServiceWindows.takePictureWithPreview] Tomando foto con cámara mock');
          xFile = await _mockCameraController!.takePicture();
        }

        // Crear un File a partir del XFile (real o mock)
        final File file = File(xFile.path);

        // Verificar si el archivo existe
        if (await file.exists()) {
          debugPrint(
              '📸 [CameraServiceWindows.takePictureWithPreview] Foto capturada exitosamente: ${file.path}');

          // Mostrar la vista previa para confirmación
          debugPrint(
              '📸 [CameraServiceWindows.takePictureWithPreview] Mostrando vista previa para confirmación');
          final action = await CameraPreviewService.showPreviewConfirmation(
            context: context,
            imageFile: file,
          );

          // Si el usuario quiere retomar la foto, indicarlo en el resultado
          if (action == PreviewAction.retake) {
            debugPrint(
                '📸 [CameraServiceWindows.takePictureWithPreview] Usuario solicitó retomar la foto');
            return CaptureResult(
              imageFile: null,
              wasConfirmed: false,
              errorMessage:
                  "RETAKE_REQUESTED", // Código especial para indicar retomar
            );
          }

          debugPrint(
              '📸 [CameraServiceWindows.takePictureWithPreview] Usuario ${action == PreviewAction.confirm ? "confirmó" : "canceló"} la foto');
          return CaptureResult(
            imageFile: file,
            wasConfirmed: action == PreviewAction.confirm,
          );
        } else {
          debugPrint(
              '📸 [CameraServiceWindows.takePictureWithPreview] El archivo de imagen no se pudo crear');
          return CaptureResult(
              errorMessage: 'El archivo de imagen no se pudo crear');
        }
      } catch (e) {
        debugPrint(
            '📸 [CameraServiceWindows.takePictureWithPreview] Error al tomar foto con vista previa: $e');
        // Si hay un error al tomar la foto, redirigir a la selección de archivo
        final file = await pickImageFromGallery(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );

        if (file != null) {
          return CaptureResult(imageFile: file, wasConfirmed: true);
        } else {
          return CaptureResult(errorMessage: 'Error al capturar imagen: $e');
        }
      }
    } catch (e) {
      debugPrint(
          '📸 [CameraServiceWindows.takePictureWithPreview] Error general al tomar foto con vista previa: $e');
      return CaptureResult(errorMessage: 'Error general: $e');
    } finally {
      // Liberar recursos de la cámara después de tomar la foto
      debugPrint(
          '📸 [CameraServiceWindows.takePictureWithPreview] Liberando recursos después de tomar foto');
      await _releaseCamera();
    }
  }

  @override
  Future<File?> pickImageFromGallery({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
  }) async {
    debugPrint(
        '📸 [CameraServiceWindows.pickImageFromGallery] Seleccionando imagen de galería');
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          debugPrint(
              '📸 [CameraServiceWindows.pickImageFromGallery] Imagen seleccionada: $path');
          return File(path);
        }
      }
      debugPrint(
          '📸 [CameraServiceWindows.pickImageFromGallery] Selección cancelada');
      return null;
    } catch (e) {
      debugPrint(
          '📸 [CameraServiceWindows.pickImageFromGallery] Error al seleccionar imagen: $e');
      return null;
    }
  }

  @override
  Future<CaptureResult> showLiveCameraViewfinder({
    required BuildContext context,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    debugPrint(
        '📸 [CameraServiceWindows.showLiveCameraViewfinder] Iniciando visor de cámara en vivo');
    try {
      // Verificar si el contexto está disponible
      if (!context.mounted) {
        debugPrint(
            '📸 [CameraServiceWindows.showLiveCameraViewfinder] Contexto no disponible');
        return CaptureResult(errorMessage: 'El contexto ya no está disponible');
      }

      // Asegurarse de liberar cualquier recurso de cámara existente
      debugPrint(
          '📸 [CameraServiceWindows.showLiveCameraViewfinder] Liberando recursos de cámara existentes');
      await _releaseCamera();

      // Intentar inicializar la cámara para verificar si está disponible
      debugPrint(
          '📸 [CameraServiceWindows.showLiveCameraViewfinder] Verificando disponibilidad de cámara');
      final bool cameraAvailable = await isCameraAvailable();
      debugPrint(
          '📸 [CameraServiceWindows.showLiveCameraViewfinder] Cámara disponible: $cameraAvailable');

      // Si la cámara no está disponible, usar el método existente como fallback
      if (!cameraAvailable) {
        debugPrint(
            '📸 [CameraServiceWindows.showLiveCameraViewfinder] Cámara no disponible, usando FilePicker como fallback');

        // Usar los valores predeterminados si no se proporcionan
        final double effectiveMaxWidth = maxWidth ?? 1200;
        final double effectiveMaxHeight = maxHeight ?? 1200;
        final int effectiveImageQuality = imageQuality ?? 85;

        // Usar el método existente como fallback
        return await takePictureWithPreview(
          maxWidth: effectiveMaxWidth,
          maxHeight: effectiveMaxHeight,
          imageQuality: effectiveImageQuality,
          context: context,
        );
      }

      // Liberar recursos nuevamente antes de mostrar la pantalla del visor
      debugPrint(
          '📸 [CameraServiceWindows.showLiveCameraViewfinder] Liberando recursos antes de mostrar el visor');
      await _releaseCamera();

      // Mostrar la pantalla del visor de cámara en vivo para Windows
      debugPrint(
          '📸 [CameraServiceWindows.showLiveCameraViewfinder] Mostrando pantalla del visor de cámara');
      final File? imageFile = await Navigator.of(context).push<File?>(
        MaterialPageRoute(
          builder: (context) => WindowsCameraViewfinderScreen(
            onPhotoTaken: (file) {
              debugPrint(
                  '📸 [CameraServiceWindows.showLiveCameraViewfinder] Foto tomada: ${file.path}');
              return Navigator.of(context).pop(file);
            },
            onCancel: () {
              debugPrint(
                  '📸 [CameraServiceWindows.showLiveCameraViewfinder] Captura cancelada');
              return Navigator.of(context).pop(null);
            },
          ),
        ),
      );

      // Si el usuario canceló o no se capturó ninguna imagen
      if (imageFile == null) {
        debugPrint(
            '📸 [CameraServiceWindows.showLiveCameraViewfinder] Usuario canceló o no se capturó imagen');
        return CaptureResult(); // Usuario canceló
      }

      // Verificar si el contexto sigue montado antes de mostrar la vista previa
      if (!context.mounted) {
        debugPrint(
            '📸 [CameraServiceWindows.showLiveCameraViewfinder] Contexto no disponible para vista previa');
        return CaptureResult(
          imageFile: imageFile,
          wasConfirmed:
              true, // Asumimos confirmación si no podemos mostrar la vista previa
        );
      }

      // Mostrar la vista previa para confirmación usando el servicio existente
      debugPrint(
          '📸 [CameraServiceWindows.showLiveCameraViewfinder] Mostrando vista previa para confirmación');
      final action = await CameraPreviewService.showPreviewConfirmation(
        context: context,
        imageFile: imageFile,
      );

      // Si el usuario quiere retomar la foto, indicarlo en el resultado
      if (action == PreviewAction.retake) {
        debugPrint(
            '📸 [CameraServiceWindows.showLiveCameraViewfinder] Usuario solicitó retomar la foto');
        return CaptureResult(
          imageFile: null,
          wasConfirmed: false,
          errorMessage:
              "RETAKE_REQUESTED", // Código especial para indicar retomar
        );
      }

      // Retornar el resultado final
      debugPrint(
          '📸 [CameraServiceWindows.showLiveCameraViewfinder] Usuario ${action == PreviewAction.confirm ? "confirmó" : "canceló"} la foto');
      return CaptureResult(
        imageFile: imageFile,
        wasConfirmed: action == PreviewAction.confirm,
      );
    } catch (e) {
      debugPrint(
          '📸 [CameraServiceWindows.showLiveCameraViewfinder] Error en el visor de cámara en vivo: $e');
      return CaptureResult(errorMessage: 'Error al capturar imagen: $e');
    }
  }

  @override
  Future<void> dispose() async {
    debugPrint('📸 [CameraServiceWindows.dispose] Liberando recursos');
    try {
      await _releaseCamera();

      // Cerrar el stream controller
      await _stateController.close();

      debugPrint(
          '📸 [CameraServiceWindows.dispose] Recursos liberados exitosamente');
    } catch (e) {
      debugPrint(
          '📸 [CameraServiceWindows.dispose] Error al liberar recursos: $e');
    }
  }
}
