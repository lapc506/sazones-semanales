import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sazones_semanales/infrastructure/services/camera/camera_service.dart';
import 'package:sazones_semanales/infrastructure/services/camera/camera_service_factory.dart';

class ImageCaptureWidget extends StatefulWidget {
  final Function(File) onImageSelected;
  final String? initialImagePath;

  const ImageCaptureWidget({
    super.key,
    required this.onImageSelected,
    this.initialImagePath,
  });

  @override
  State<ImageCaptureWidget> createState() => _ImageCaptureWidgetState();
}

class _ImageCaptureWidgetState extends State<ImageCaptureWidget> {
  File? _selectedImage;
  late final CameraService _cameraService;
  bool _isCameraAvailable = false;
  
  @override
  void initState() {
    super.initState();
    // Inicializar el servicio de cámara apropiado para la plataforma
    _cameraService = CameraServiceFactory.getCameraService();
    
    if (widget.initialImagePath != null) {
      _selectedImage = File(widget.initialImagePath!);
    }
    
    // Verificar si la cámara está disponible e inicializarla proactivamente
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    // Verificar disponibilidad de la cámara
    _isCameraAvailable = await _cameraService.isCameraAvailable();
    
    if (_isCameraAvailable) {
      // Inicializar la cámara proactivamente para que esté lista cuando el usuario quiera usarla
      await _cameraService.initializeProactively();
    }
    
    // Actualizar el estado si el widget sigue montado
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _takePicture() async {
    try {
      // Verificar nuevamente si la cámara está disponible
      final cameraAvailable = await _cameraService.isCameraAvailable();
      
      if (!cameraAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La cámara no está disponible. Seleccionando desde archivos...'),
              duration: Duration(seconds: 3),
            ),
          );
          // Si la cámara no está disponible, redirigir a la selección de archivo
          await _pickImage();
        }
        return;
      }
      
      // Usar el nuevo método con vista previa
      if (mounted) {
        bool shouldRetake = true;
        
        // Bucle para permitir retomar la foto múltiples veces
        while (shouldRetake && mounted) {
          final CaptureResult result = await _cameraService.takePictureWithPreview(
            maxWidth: 1200,
            maxHeight: 1200,
            imageQuality: 85,
            context: context,
          );
          
          // Verificar si la captura fue exitosa y confirmada
          if (result.isSuccess && mounted) {
            setState(() {
              _selectedImage = result.imageFile;
            });
            widget.onImageSelected(_selectedImage!);
            shouldRetake = false; // Salir del bucle
          } 
          // Verificar si el usuario quiere retomar la foto
          else if (result.hasError && result.errorMessage == "RETAKE_REQUESTED") {
            // Continuar en el bucle para tomar otra foto
            continue;
          }
          // Verificar si hay un error real
          else if (result.hasError && mounted) {
            // Mostrar error y redirigir a selección de archivo
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${result.errorMessage}')),
            );
            await _pickImage();
            shouldRetake = false; // Salir del bucle
          }
          // Si result.isCancelled, no hacemos nada (el usuario canceló)
          else {
            shouldRetake = false; // Salir del bucle
          }
        }
      }
    } catch (e) {
      debugPrint('Error al tomar la foto: $e');
      // Manejar errores generales
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al tomar la foto: $e')),
        );
        // En caso de error, intentar seleccionar una imagen
        await _pickImage();
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final File? image = await _cameraService.pickImageFromGallery(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
        });
        widget.onImageSelected(_selectedImage!);
      }
    } catch (e) {
      debugPrint('Error al seleccionar la imagen: $e');
      // Manejar errores de selección de imagen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar la imagen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_selectedImage != null)
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 250, // Altura inicial un poco mayor
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.contain, // Usar contain para mostrar toda la imagen
                          width: double.infinity,
                          height: 250,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 128),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.zoom_in, color: Colors.white),
                              onPressed: () => _mostrarImagenCompleta(context),
                              tooltip: 'Ver imagen completa',
                              iconSize: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 128),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: _showImageOptions,
                              tooltip: 'Cambiar imagen',
                              iconSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Información de la imagen
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Imagen seleccionada',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo,
                  size: 64,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'Toma o selecciona una foto del producto',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showImageOptions,
                  child: const Text('Agregar imagen'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // Solo mostrar la opción de tomar foto si la cámara está disponible
            if (_isCameraAvailable)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePicture();
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de la galería'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _mostrarImagenCompleta(BuildContext context) {
    if (_selectedImage == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Vista previa de la imagen'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(_selectedImage!),
            ),
          ),
        ),
      ),
    );
  }
}