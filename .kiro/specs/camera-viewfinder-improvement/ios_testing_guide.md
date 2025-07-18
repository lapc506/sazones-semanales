# Guía de Pruebas para Visor de Cámara en iOS

Esta guía proporciona instrucciones para probar manualmente la funcionalidad del visor de cámara en dispositivos iOS.

## Requisitos Previos

- Dispositivo iOS con cámara funcional
- Aplicación instalada con la última versión del código
- Info.plist configurado correctamente con los permisos de cámara

## Pruebas Funcionales

### 1. Inicialización de la Cámara

- **Objetivo**: Verificar que la cámara se inicialice correctamente
- **Pasos**:
  1. Abrir la aplicación
  2. Navegar a una pantalla que utilice el widget `ImageCaptureWidget`
  3. Tocar el botón "Agregar imagen"
  4. Seleccionar "Tomar foto" en el menú
- **Resultado Esperado**:
  - Debe aparecer el diálogo de solicitud de permisos de cámara (primera vez)
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
  - La aplicación debe mostrar un mensaje indicando que los permisos de cámara están denegados
  - Debe ofrecer la opción de ir a la configuración o seleccionar una imagen de la galería
  - Si el usuario va a la configuración, debe poder habilitar los permisos y volver a la aplicación

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

### 6. Rendimiento y Gestión de Memoria

- **Objetivo**: Verificar el rendimiento y la gestión de memoria
- **Pasos**:
  1. Abrir el visor de cámara varias veces consecutivas
  2. Mantener el visor abierto durante al menos 2 minutos
  3. Cambiar entre diferentes aplicaciones y volver al visor
  4. Verificar el uso de memoria en el Xcode Instruments (si es posible)
- **Resultado Esperado**:
  - El visor debe inicializarse rápidamente (menos de 3 segundos)
  - No debe haber retrasos notables en la vista previa
  - La aplicación no debe cerrarse inesperadamente
  - No debe haber fugas de memoria significativas
  - Los recursos de la cámara deben liberarse correctamente al salir

### 7. Compatibilidad con Diferentes Dispositivos iOS

- **Objetivo**: Verificar la compatibilidad con diferentes dispositivos iOS
- **Pasos**:
  1. Probar en diferentes modelos de iPhone si es posible (especialmente modelos más antiguos)
  2. Probar en iPad si es posible
- **Resultado Esperado**:
  - La funcionalidad debe ser consistente en todos los dispositivos
  - La interfaz debe adaptarse correctamente a diferentes tamaños de pantalla
  - El rendimiento debe ser aceptable incluso en dispositivos más antiguos

## Registro de Problemas

Si se encuentra algún problema durante las pruebas, registrar la siguiente información:

1. Modelo del dispositivo y versión de iOS
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
- [ ] La aplicación funciona bien en diferentes dispositivos iOS