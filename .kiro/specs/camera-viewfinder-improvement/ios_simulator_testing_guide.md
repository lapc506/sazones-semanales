# Guía de Pruebas con Simulador iOS

Esta guía proporciona instrucciones para probar la funcionalidad del visor de cámara utilizando un simulador de iOS.

## Limitaciones del Simulador iOS

Es importante tener en cuenta que el simulador de iOS tiene limitaciones significativas para probar funcionalidades de cámara:

1. **Sin acceso a cámara real**: A diferencia del emulador de Android, el simulador de iOS **no puede acceder a la webcam** de tu computadora.

2. **Cámara simulada**: El simulador proporciona una cámara simulada que muestra imágenes estáticas predefinidas, no una transmisión en vivo.

3. **Pruebas limitadas**: Solo podrás probar la interfaz de usuario y el flujo de navegación, pero no la funcionalidad real de la cámara.

Debido a estas limitaciones, **se recomienda realizar pruebas completas en dispositivos iOS físicos**. Sin embargo, el simulador sigue siendo útil para pruebas básicas de UI y navegación.

## Configuración del Simulador

1. Abre Xcode
2. Ve a "Xcode" > "Open Developer Tool" > "Simulator"
3. Selecciona el dispositivo iOS que deseas simular (por ejemplo, iPhone 13)

## Pruebas Posibles en el Simulador

### 1. Pruebas de Interfaz de Usuario

1. Ejecuta la aplicación en el simulador:
   ```
   flutter run -d <id-del-simulador>
   ```
2. Navega a una pantalla que utilice el widget `ImageCaptureWidget`
3. Verifica que:
   - El diseño de la interfaz se vea correctamente
   - Los botones estén correctamente posicionados
   - Los textos sean legibles

### 2. Pruebas de Navegación

1. Toca el botón "Agregar imagen"
2. Selecciona "Tomar foto" en el menú
3. Verifica que:
   - La aplicación intente mostrar la pantalla del visor de cámara
   - La navegación entre pantallas funcione correctamente

### 3. Pruebas de Manejo de Errores

1. Cuando la aplicación intente acceder a la cámara en el simulador, debería:
   - Manejar adecuadamente la falta de acceso a la cámara
   - Mostrar un mensaje de error apropiado
   - Ofrecer la opción de seleccionar una imagen de la galería

### 4. Pruebas de Selección de Galería

1. Cuando selecciones "Seleccionar de la galería", verifica que:
   - Se abra el selector de imágenes del simulador
   - Puedas seleccionar una imagen de las imágenes de muestra
   - La imagen seleccionada se muestre correctamente en la aplicación

## Alternativas para Pruebas Completas

### 1. Dispositivo iOS Físico

La mejor opción para pruebas completas es utilizar un dispositivo iOS físico:

1. Conecta tu dispositivo iOS a tu computadora
2. Asegúrate de que tu dispositivo esté configurado para desarrollo
3. Ejecuta la aplicación en el dispositivo:
   ```
   flutter run -d <id-del-dispositivo>
   ```

### 2. Pruebas Unitarias y de Widget

Implementa pruebas unitarias y de widget que simulen los componentes de la cámara:

```dart
testWidgets('CameraViewfinderScreen muestra UI correctamente cuando la cámara está lista',
    (WidgetTester tester) async {
  // Simular que la cámara está lista
  // Verificar que la UI se muestre correctamente
});
```

### 3. Pruebas de Integración con Mocks

Utiliza mocks para simular la funcionalidad de la cámara en pruebas de integración:

```dart
class MockCameraController extends Mock implements CameraController {}
```

## Verificación en Simulador

- [ ] La interfaz de usuario se muestra correctamente
- [ ] La navegación entre pantallas funciona correctamente
- [ ] Los errores de cámara se manejan adecuadamente
- [ ] La selección de galería funciona correctamente

## Recordatorio

Recuerda que las pruebas en el simulador de iOS son limitadas para funcionalidades de cámara. **Siempre verifica la funcionalidad completa en un dispositivo iOS físico antes de lanzar a producción.**