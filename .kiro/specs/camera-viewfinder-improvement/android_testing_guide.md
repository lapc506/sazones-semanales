# Guía de Pruebas para Visor de Cámara en Android

Esta guía proporciona instrucciones para probar manualmente la funcionalidad del visor de cámara en dispositivos Android.

## Requisitos Previos

- Dispositivo Android con cámara funcional
- Aplicación instalada con la última versión del código
- Permisos de cámara configurados correctamente

## Pruebas Funcionales

### 1. Inicialización de la Cámara

- **Objetivo**: Verificar que la cámara se inicialice correctamente
- **Pasos**:
  1. Abrir la aplicación
  2. Navegar a una pantalla que utilice el widget `ImageCaptureWidget`
  3. Tocar el botón "Agregar imagen"
  4. Seleccionar "Tomar foto" en el menú
- **Resultado Esperado**:
  - Debe mostrarse la pantalla del visor de cámara
  - Durante la inicialización, debe verse un indicador de carga
  - Después de la inicialización, debe mostrarse la vista previa en vivo de la cámara

### 2. Captura de Fotos

- **Objetivo**: Verificar que la captura de fotos funcione correctamente
- **Pasos**:
  1. En la pantalla del visor de cámara, encuadrar la imagen deseada
  2. Presionar el botón de captura (círculo blanco en la parte inferior)
- **Resultado Esperado**:
  - Debe mostrarse un efecto visual (flash) al capturar la foto
  - El botón de captura debe animarse brevemente
  - Después de la captura, debe mostrarse la pantalla de confirmación con la foto tomada

### 3. Confirmación de Imagen

- **Objetivo**: Verificar que la confirmación de imagen funcione correctamente
- **Pasos**:
  1. Después de capturar una foto, observar la pantalla de confirmación
  2. Probar el botón "Retomar" y verificar que vuelva al visor de cámara
  3. Capturar otra foto y probar el botón "Confirmar"
- **Resultado Esperado**:
  - La pantalla de confirmación debe mostrar claramente la imagen capturada
  - Al presionar "Retomar", debe volver al visor de cámara
  - Al presionar "Confirmar", debe volver a la pantalla anterior con la imagen seleccionada

### 4. Manejo de Permisos

- **Objetivo**: Verificar que los permisos de cámara se manejen correctamente
- **Pasos**:
  1. En la configuración del dispositivo, revocar los permisos de cámara para la aplicación
  2. Abrir la aplicación e intentar usar la cámara
- **Resultado Esperado**:
  - La aplicación debe solicitar permisos de cámara
  - Si los permisos son denegados, debe mostrar un mensaje apropiado
  - Debe ofrecer la opción de seleccionar una imagen de la galería como alternativa

### 5. Relación de Aspecto y Calidad de Imagen

- **Objetivo**: Verificar que la relación de aspecto y la calidad de imagen sean correctas
- **Pasos**:
  1. Abrir el visor de cámara
  2. Observar la vista previa de la cámara
  3. Capturar una foto y verificar la calidad
- **Resultado Esperado**:
  - La vista previa debe mantener la relación de aspecto correcta sin distorsión
  - La imagen capturada debe tener buena calidad y resolución
  - La imagen debe verse igual en la vista previa y en la pantalla de confirmación

### 6. Rendimiento

- **Objetivo**: Verificar el rendimiento del visor de cámara
- **Pasos**:
  1. Abrir el visor de cámara varias veces consecutivas
  2. Mantener el visor abierto durante al menos 2 minutos
  3. Cambiar entre diferentes aplicaciones y volver al visor
- **Resultado Esperado**:
  - El visor debe inicializarse rápidamente (menos de 3 segundos)
  - No debe haber retrasos notables en la vista previa
  - La aplicación no debe cerrarse inesperadamente
  - Los recursos de la cámara deben liberarse correctamente al salir

## Registro de Problemas

Si se encuentra algún problema durante las pruebas, registrar la siguiente información:

1. Modelo del dispositivo y versión de Android
2. Descripción detallada del problema
3. Pasos para reproducir el problema
4. Capturas de pantalla o videos si es posible
5. Mensajes de error mostrados (si los hay)

## Verificación Final

- [ ] La cámara se inicializa correctamente
- [ ] La captura de fotos funciona correctamente
- [ ] La confirmación de imagen funciona correctamente
- [ ] Los permisos se manejan adecuadamente
- [ ] La relación de aspecto y calidad de imagen son correctas
- [ ] El rendimiento es satisfactorio