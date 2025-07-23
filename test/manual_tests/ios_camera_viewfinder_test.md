# Pruebas Manuales para CameraViewfinder en iOS

Este documento describe los pasos para probar manualmente la funcionalidad del visor de cámara en dispositivos iOS.

## Requisitos Previos

- Dispositivo iOS físico (iPhone o iPad)
- Aplicación instalada en el dispositivo
- Permisos de cámara configurados en Info.plist (ya verificado)

## Pasos de Prueba

### 1. Verificar Permisos de Cámara

- **Objetivo**: Confirmar que la aplicación solicita permisos de cámara correctamente.
- **Pasos**:
  1. Instalar la aplicación en un dispositivo iOS
  2. Abrir la aplicación y navegar a una pantalla que utilice la cámara
  3. Verificar que aparece el diálogo de solicitud de permisos con el texto: "Esta aplicación necesita acceso a la cámara para escanear códigos de barras de productos."
  4. Aceptar los permisos

### 2. Verificar Inicialización de la Cámara

- **Objetivo**: Confirmar que la cámara se inicializa correctamente.
- **Pasos**:
  1. Navegar a una pantalla que utilice el visor de cámara
  2. Verificar que aparece el indicador de carga durante la inicialización
  3. Verificar que después de la inicialización se muestra la vista previa de la cámara
  4. Comprobar que la vista previa es fluida y responde correctamente

### 3. Verificar Captura de Fotos

- **Objetivo**: Confirmar que la captura de fotos funciona correctamente.
- **Pasos**:
  1. En la pantalla del visor de cámara, presionar el botón de captura
  2. Verificar que se muestra el efecto visual (flash) al capturar
  3. Verificar que después de la captura se muestra la pantalla de confirmación
  4. Confirmar que la imagen capturada se muestra correctamente

### 4. Verificar Botón de Retroceso

- **Objetivo**: Confirmar que el botón de retroceso funciona correctamente.
- **Pasos**:
  1. En la pantalla del visor de cámara, presionar el botón de retroceso
  2. Verificar que se cierra la pantalla del visor y se vuelve a la pantalla anterior

### 5. Verificar Relación de Aspecto

- **Objetivo**: Confirmar que la relación de aspecto se mantiene correctamente.
- **Pasos**:
  1. Abrir el visor de cámara
  2. Verificar que la vista previa mantiene la relación de aspecto correcta
  3. Verificar que no hay distorsión en la imagen
  4. Rotar el dispositivo y verificar que la vista previa se ajusta correctamente

### 6. Verificar Rendimiento

- **Objetivo**: Confirmar que el visor de cámara tiene un buen rendimiento.
- **Pasos**:
  1. Abrir el visor de cámara
  2. Mover la cámara rápidamente en diferentes direcciones
  3. Verificar que la vista previa se mantiene fluida
  4. Verificar que no hay retrasos significativos en la respuesta

## Resultados Esperados

- La aplicación solicita permisos de cámara correctamente
- La cámara se inicializa correctamente y muestra la vista previa
- La captura de fotos funciona correctamente y muestra la pantalla de confirmación
- El botón de retroceso cierra la pantalla del visor
- La relación de aspecto se mantiene correctamente en diferentes orientaciones
- El visor de cámara tiene un buen rendimiento y responde de manera fluida

## Notas Adicionales

- En iOS, es importante verificar el comportamiento en diferentes modelos de dispositivos (iPhone y iPad)
- Verificar el comportamiento cuando los permisos de cámara son denegados
- Comprobar que se ofrece la opción de seleccionar una imagen de la galería como alternativa