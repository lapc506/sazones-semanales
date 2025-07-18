# Documento de Diseño: Mejora del Visor de Cámara

## Visión General

Este documento de diseño describe el enfoque de implementación para añadir un visor de cámara en vivo al flujo de captura de fotos de la aplicación. Actualmente, cuando los usuarios seleccionan "Tomar foto", la aplicación captura inmediatamente una foto sin mostrar una vista previa en vivo. El nuevo diseño introducirá una pantalla de visor de cámara que muestra una transmisión de cámara en tiempo real, permitiendo a los usuarios encuadrar sus tomas antes de capturar.

## Arquitectura

La implementación aprovechará los componentes existentes y seguirá el patrón de arquitectura actual de la aplicación. Haremos lo siguiente:

1. Crear un nuevo widget `CameraViewfinderScreen` que mostrará la transmisión de cámara en vivo
2. Extender la funcionalidad de `CameraService` para soportar el visor en vivo
3. Mantener el flujo de confirmación de vista previa existente después de la captura
4. Asegurar el manejo adecuado de permisos de cámara y alternativas de respaldo

## Componentes e Interfaces

### 1. CameraViewfinderScreen

Un nuevo componente de pantalla que:
- Mostrará una transmisión de cámara en vivo usando el plugin `camera`
- Proporcionará botones de captura y retroceso
- Manejará la inicialización de la cámara y los permisos
- Capturará fotos cuando se solicite

```dart
class CameraViewfinderScreen extends StatefulWidget {
  final Function(File) onPhotoTaken;
  final Function() onCancel;
  
  const CameraViewfinderScreen({
    super.key,
    required this.onPhotoTaken,
    required this.onCancel,
  });
  
  @override
  State<CameraViewfinderScreen> createState() => _CameraViewfinderScreenState();
}
```

### 2. Extensión de CameraService

Extenderemos la interfaz `CameraService` existente con un nuevo método:

```dart
abstract class CameraService {
  // Métodos existentes
  Future<bool> isCameraAvailable();
  Future<void> initializeProactively();
  Future<CaptureResult> takePictureWithPreview({...});
  Future<File?> pickImageFromGallery({...});
  
  // Nuevo método
  Future<CaptureResult> showLiveCameraViewfinder({
    required BuildContext context,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  });
}
```

### 3. Implementación en CameraServiceMobile

Implementaremos el nuevo método en la clase `CameraServiceMobile`:

```dart
@override
Future<CaptureResult> showLiveCameraViewfinder({
  required BuildContext context,
  double? maxWidth,
  double? maxHeight,
  int? imageQuality,
}) async {
  try {
    // Mostrar pantalla de visor de cámara en vivo
    final result = await Navigator.of(context).push<File?>(
      MaterialPageRoute(
        builder: (context) => CameraViewfinderScreen(
          onPhotoTaken: (file) => Navigator.of(context).pop(file),
          onCancel: () => Navigator.of(context).pop(null),
        ),
      ),
    );
    
    if (result == null) {
      return CaptureResult(); // Usuario canceló
    }
    
    // Mostrar la vista previa para confirmación usando el servicio existente
    final action = await CameraPreviewService.showPreviewConfirmation(
      context: context,
      imageFile: result,
    );
    
    // Si el usuario quiere retomar la foto, volver al visor
    if (action == PreviewAction.retake) {
      return CaptureResult(
        imageFile: null,
        wasConfirmed: false,
        errorMessage: "RETAKE_REQUESTED",
      );
    }
    
    return CaptureResult(
      imageFile: result,
      wasConfirmed: action == PreviewAction.confirm,
    );
  } catch (e) {
    debugPrint('Error en el visor de cámara en vivo: $e');
    return CaptureResult(errorMessage: 'Error al capturar imagen: $e');
  }
}
```

### 4. Modificación de ImageCaptureWidget

El método `_takePicture()` en `ImageCaptureWidget` se modificará para usar el nuevo visor en vivo:

```dart
Future<void> _takePicture() async {
  try {
    // Verificar disponibilidad de la cámara
    final cameraAvailable = await _cameraService.isCameraAvailable();
    
    if (!cameraAvailable) {
      // Fallback a selección de galería (código existente)
      return;
    }
    
    // Usar el nuevo visor de cámara en vivo
    if (mounted) {
      bool shouldRetake = true;
      
      // Bucle para permitir retomar la foto múltiples veces
      while (shouldRetake && mounted) {
        final CaptureResult result = await _cameraService.showLiveCameraViewfinder(
          context: context,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
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
    // Manejo de errores (código existente)
  }
}
```

## Reutilización de Componentes Existentes

Aprovecharemos los siguientes componentes existentes:

1. **CameraPreviewService**: Seguiremos usando este servicio para mostrar la vista previa de confirmación después de capturar la foto.

2. **CaptureResult**: Continuaremos usando este modelo para manejar los resultados de la captura.

3. **CameraService**: Extenderemos esta interfaz sin romper la compatibilidad con implementaciones existentes.

## Dependencias Adicionales

Necesitaremos añadir el plugin `camera` de Flutter para acceder a la funcionalidad de cámara en vivo:

```yaml
dependencies:
  camera: ^0.10.5+5  # Usar la versión más reciente compatible
```

## Manejo de Errores

1. Errores de Inicialización de Cámara:
   - Mostrar mensajes de error apropiados cuando la cámara falla al inicializar
   - Proporcionar alternativa de selección de galería
   - Registrar errores detallados para depuración

2. Manejo de Permisos:
   - Solicitar permisos de cámara cuando sea necesario
   - Manejar la denegación de permisos con elegancia
   - Proporcionar instrucciones claras para habilitar permisos

3. Compatibilidad de Dispositivos:
   - Manejar diferentes configuraciones de cámara en distintos dispositivos
   - Mantener proporciones de aspecto adecuadas
   - Recurrir a implementación más simple en dispositivos no compatibles

## Estrategia de Pruebas

1. Pruebas Unitarias:
   - Probar extensiones del servicio de cámara
   - Probar manejo de errores y mecanismos de respaldo
   - Simular interacciones de cámara para pruebas confiables

2. Pruebas de Widgets:
   - Probar componentes UI de `CameraViewfinderScreen`
   - Verificar funcionalidad adecuada de botones
   - Probar estados de carga y visualizaciones de error

3. Pruebas de Integración:
   - Probar el flujo completo de captura de fotos
   - Verificar navegación adecuada entre pantallas
   - Probar inicialización de cámara y captura

4. Pruebas Manuales:
   - Probar en múltiples tipos de dispositivos y versiones de SO
   - Verificar rendimiento y capacidad de respuesta
   - Probar casos extremos como pulsaciones rápidas de botones y cambios de permisos

## Consideraciones Específicas de Plataforma

### Android
- Usar el plugin Flutter `camera` para acceder a la cámara
- Manejar permisos en tiempo de ejecución para acceso a la cámara
- Considerar diferentes capacidades de hardware de cámara

### iOS
- Asegurar permisos de cámara adecuados en Info.plist
- Manejar inicialización de cámara específica de iOS
- Probar en diferentes versiones de iOS para compatibilidad

## Diseño de UI

La pantalla del visor de cámara seguirá estos principios de diseño:

1. Vista previa de cámara a pantalla completa con elementos UI mínimos
2. Botón de captura grande y centrado en la parte inferior
3. Botón de retroceso/cancelar en la esquina superior izquierda
4. Indicador de carga durante la inicialización de la cámara
5. Mantener el lenguaje de diseño y esquema de colores existente de la aplicación
6. Diseño responsivo que funcione en diferentes tamaños de pantalla

## Consideraciones de Rendimiento

1. La inicialización de la cámara se optimizará para minimizar el retraso
2. Considerar usar resolución más baja para el visor para mejorar el rendimiento
3. Implementar limpieza adecuada de recursos cuando se cierre el visor
4. Usar configuraciones de calidad de imagen apropiadas para la captura final