import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'camera_service.dart';
import 'camera_preview_service.dart';

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
    _updateState(CameraInitializationState.initializing);

    try {
      final result = await _initializeCamera();
      if (result) {
        _updateState(CameraInitializationState.ready);
      } else {
        _updateState(CameraInitializationState.error);
      }
    } catch (e) {
      debugPrint('Error en inicialización proactiva: $e');
      _updateState(CameraInitializationState.error);
    }
  }

  /// Inicializa la cámara intentando usar la API real primero, fallback a mock
  Future<bool> _initializeCamera() async {
    if (_initialized &&
        (_realCameraController != null || _mockCameraController != null)) {
      return true;
    }

    try {
      // Intentar usar la API real de camera primero
      debugPrint('Intentando usar API real de cámara en Windows...');
      _realCameras = await availableCameras();

      if (_realCameras != null && _realCameras!.isNotEmpty) {
        debugPrint('Cámaras reales encontradas: ${_realCameras!.length}');

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
        debugPrint('Cámara real inicializada exitosamente');
        return true;
      } else {
        debugPrint('No se encontraron cámaras reales, usando mock');
        return await _initializeMockCamera();
      }
    } catch (e) {
      // Si falla la API real (MissingPluginException, UnimplementedError, etc.)
      debugPrint('API real no disponible, usando mock: $e');
      return await _initializeMockCamera();
    }
  }

  /// Inicializa la cámara mock como fallback
  Future<bool> _initializeMockCamera() async {
    try {
      _mockCameras = await mockAvailableCameras();

      if (_mockCameras == null || _mockCameras!.isEmpty) {
        debugPrint('No se encontraron cámaras mock en Windows');
        return false;
      }

      // Crear un MockCameraController
      _mockCameraController = MockCameraController(_mockCameras![0]);

      // Inicializar el controlador mock
      await _mockCameraController!.initialize();
      _initialized = true;
      _usingRealCamera = false;
      debugPrint('Cámara mock inicializada exitosamente');
      return true;
    } catch (e) {
      debugPrint('Error al inicializar la cámara mock en Windows: $e');
      _mockCameraController = null;
      _initialized = false;
      return false;
    }
  }

  @override
  Future<bool> isCameraAvailable() async {
    try {
      // Intentar inicializar la cámara mock para verificar si está disponible
      final result = await _initializeCamera();

      // Si no pudimos inicializar, liberar recursos
      if (!result) {
        if (_usingRealCamera && _realCameraController != null) {
          await _realCameraController!.dispose();
          _realCameraController = null;
        } else if (!_usingRealCamera && _mockCameraController != null) {
          await _mockCameraController!.dispose();
          _mockCameraController = null;
        }
        _initialized = false;
      }

      return result;
    } catch (e) {
      debugPrint(
          'Error al verificar disponibilidad de cámara mock en Windows: $e');
      return false;
    }
  }

  @override
  Future<File?> takePicture({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
  }) async {
    try {
      // Intentar inicializar la cámara mock
      final initialized = await _initializeCamera();
      if (!initialized || _cameraController == null) {
        debugPrint('No se pudo inicializar la cámara en Windows');
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
          xFile = await _realCameraController!.takePicture();
        } else {
          xFile = await _mockCameraController!.takePicture();
        }

        // Crear un File a partir del XFile (real o mock)
        final File file = File(xFile.path);

        // Verificar si el archivo existe
        if (await file.exists()) {
          return file;
        }
      } catch (e) {
        debugPrint('Error al tomar foto con mock en Windows: $e');
        // Si hay un error al tomar la foto, redirigir a la selección de archivo
        return await pickImageFromGallery(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error general al tomar foto con mock en Windows: $e');
      // En caso de error, redirigir a la selección de archivo
      return await pickImageFromGallery(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
    } finally {
      // Liberar recursos de la cámara después de tomar la foto
      if (_initialized) {
        try {
          if (_usingRealCamera && _realCameraController != null) {
            await _realCameraController!.dispose();
            _realCameraController = null;
          } else if (!_usingRealCamera && _mockCameraController != null) {
            await _mockCameraController!.dispose();
            _mockCameraController = null;
          }
          _initialized = false;
        } catch (e) {
          debugPrint('Error al liberar recursos de la cámara: $e');
        }
      }
    }
  }

  @override
  Future<CaptureResult> takePictureWithPreview({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
    required BuildContext context,
  }) async {
    try {
      // Intentar inicializar la cámara
      final initialized = await _initializeCamera();
      if (!initialized || _cameraController == null) {
        debugPrint('No se pudo inicializar la cámara en Windows');
        // Si no podemos usar la cámara, redirigir a la selección de archivo
        final file = await pickImageFromGallery(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );

        if (file != null) {
          // En Windows, cuando usamos FilePicker, asumimos que el usuario ya confirmó la selección
          return CaptureResult(imageFile: file, wasConfirmed: true);
        } else {
          return CaptureResult(); // Cancelado
        }
      }

      try {
        // Tomar la foto usando el controlador activo (real o mock)
        dynamic xFile;
        if (_usingRealCamera) {
          xFile = await _realCameraController!.takePicture();
        } else {
          xFile = await _mockCameraController!.takePicture();
        }

        // Crear un File a partir del XFile (real o mock)
        final File file = File(xFile.path);

        // Verificar si el archivo existe
        if (await file.exists()) {
          // Mostrar la vista previa para confirmación
          final action =
              await CameraPreviewService.showPreviewConfirmation(
            context: context,
            imageFile: file,
          );
          
          // Si el usuario quiere retomar la foto, indicarlo en el resultado
          if (action == PreviewAction.retake) {
            return CaptureResult(
              imageFile: null,
              wasConfirmed: false,
              errorMessage: "RETAKE_REQUESTED", // Código especial para indicar retomar
            );
          }

          return CaptureResult(
            imageFile: file,
            wasConfirmed: action == PreviewAction.confirm,
          );
        } else {
          return CaptureResult(
              errorMessage: 'El archivo de imagen no se pudo crear');
        }
      } catch (e) {
        debugPrint('Error al tomar foto con vista previa en Windows: $e');
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
      debugPrint('Error general al tomar foto con vista previa en Windows: $e');
      return CaptureResult(errorMessage: 'Error general: $e');
    } finally {
      // Liberar recursos de la cámara después de tomar la foto
      if (_initialized) {
        try {
          if (_usingRealCamera && _realCameraController != null) {
            await _realCameraController!.dispose();
            _realCameraController = null;
          } else if (!_usingRealCamera && _mockCameraController != null) {
            await _mockCameraController!.dispose();
            _mockCameraController = null;
          }
          _initialized = false;
        } catch (e) {
          debugPrint('Error al liberar recursos de la cámara: $e');
        }
      }
    }
  }

  @override
  Future<File?> pickImageFromGallery({
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          return File(path);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error al seleccionar imagen en Windows: $e');
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      // Liberar recursos de la cámara
      if (_usingRealCamera && _realCameraController != null) {
        await _realCameraController!.dispose();
        _realCameraController = null;
      } else if (!_usingRealCamera && _mockCameraController != null) {
        await _mockCameraController!.dispose();
        _mockCameraController = null;
      }

      _initialized = false;
      _usingRealCamera = false;

      // Cerrar el stream controller
      await _stateController.close();

      debugPrint('Recursos de CameraServiceWindows liberados');
    } catch (e) {
      debugPrint('Error al liberar recursos de CameraServiceWindows: $e');
    }
  }
}
