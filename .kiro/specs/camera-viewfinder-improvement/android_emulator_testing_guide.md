# Guía de Pruebas con Emulador Android

Esta guía proporciona instrucciones para probar la funcionalidad del visor de cámara utilizando un emulador de Android con acceso a la webcam de tu laptop.

## Configuración del Emulador

### 1. Crear un Emulador con Soporte de Webcam

1. Abre Android Studio
2. Ve a "Tools" > "Device Manager" o "AVD Manager"
3. Haz clic en "Create Virtual Device"
4. Selecciona un dispositivo (por ejemplo, Pixel 4)
5. Selecciona una imagen de sistema (Android 11 o superior recomendado)
6. En la pantalla de configuración avanzada, asegúrate de que:
   - La opción "Camera" esté configurada como "Webcam0" para la cámara trasera
   - La opción "Camera" esté configurada como "Webcam0" para la cámara frontal
7. Finaliza la creación del emulador

### 2. Verificar Permisos de Webcam

1. Asegúrate de que tu sistema operativo permita que Android Studio/emulador acceda a tu webcam
2. En Windows, es posible que necesites confirmar un diálogo de permisos la primera vez
3. En macOS, asegúrate de que Android Studio tenga permisos de cámara en Preferencias del Sistema > Seguridad y Privacidad

## Pruebas Funcionales

### 1. Iniciar el Emulador

1. Inicia el emulador desde Android Studio
2. Verifica que la webcam esté funcionando correctamente:
   - Abre la aplicación de cámara predeterminada del emulador
   - Confirma que puedes ver la transmisión de video de tu webcam

### 2. Ejecutar la Aplicación

1. Ejecuta la aplicación en el emulador con el comando:
   ```
   flutter run -d emulator-5554  # Reemplaza con el ID de tu emulador
   ```
2. Navega a una pantalla que utilice el widget `ImageCaptureWidget`

### 3. Probar el Visor de Cámara

1. Toca el botón "Agregar imagen"
2. Selecciona "Tomar foto" en el menú
3. Verifica que:
   - Se muestre la pantalla del visor de cámara
   - Puedas ver la transmisión en vivo de tu webcam
   - El botón de captura funcione correctamente
   - La animación y el efecto visual de captura se muestren correctamente

### 4. Probar la Confirmación de Imagen

1. Después de capturar una foto, verifica que:
   - Se muestre la pantalla de confirmación
   - La imagen capturada se vea correctamente
   - Los botones "Retomar" y "Confirmar" funcionen como se espera

## Consejos para Pruebas en Emulador

1. **Rendimiento**: El rendimiento de la cámara en el emulador puede ser más lento que en un dispositivo real. Considera esto al evaluar los tiempos de carga.

2. **Calidad de Imagen**: La calidad de la imagen dependerá de tu webcam. No esperes la misma calidad que tendrías en un dispositivo real.

3. **Orientación**: La orientación de la cámara puede ser diferente en el emulador. Verifica que la imagen se muestre correctamente.

4. **Permisos**: Si los permisos de cámara no funcionan correctamente en el emulador, intenta:
   - Reiniciar el emulador
   - Verificar los permisos de la aplicación manualmente en Configuración > Aplicaciones
   - Asegurarte de que el AndroidManifest.xml tenga los permisos correctos

5. **Depuración**: Utiliza los logs de depuración para identificar problemas:
   ```
   flutter run -d emulator-5554 --verbose
   ```

## Problemas Comunes y Soluciones

### La webcam no funciona en el emulador

- **Solución 1**: Verifica que ninguna otra aplicación esté usando la webcam
- **Solución 2**: Reinicia el emulador y Android Studio
- **Solución 3**: En la configuración del emulador, cambia la cámara a "VirtualScene" y luego de nuevo a "Webcam0"

### La aplicación se cierra al acceder a la cámara

- **Solución**: Verifica los logs de error para identificar el problema específico
- Asegúrate de que los permisos estén correctamente configurados en el AndroidManifest.xml

### La vista previa de la cámara se ve distorsionada

- **Solución**: Verifica la implementación del AspectRatio en el widget CameraViewfinderScreen
- Prueba con diferentes resoluciones en el método _getOptimalResolution()

## Verificación Final

- [ ] El visor de cámara se inicializa correctamente en el emulador
- [ ] La transmisión en vivo de la webcam se muestra correctamente
- [ ] La captura de fotos funciona correctamente
- [ ] La confirmación de imagen funciona correctamente
- [ ] Los permisos se manejan adecuadamente
- [ ] La relación de aspecto y calidad de imagen son aceptables para pruebas