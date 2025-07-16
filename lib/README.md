# Gestor de Inventario de Alacena - Arquitectura

Este proyecto sigue los principios de Clean Architecture para garantizar escalabilidad y mantenibilidad.

## Estructura de Carpetas

### Domain Layer (`lib/domain/`)
- **entities/**: Entidades del dominio (Existencia, ProductoBase, Proveedor, etc.)
- **repositories/**: Interfaces abstractas de repositorios
- **services/**: Servicios de dominio para reglas de negocio

### Application Layer (`lib/application/`)
- **use_cases/**: Casos de uso de la aplicación
- **services/**: Servicios de aplicación

### Infrastructure Layer (`lib/infrastructure/`)
- **repositories/**: Implementaciones concretas de repositorios
- **services/**: Implementaciones de servicios externos
- **database/**: Configuración y helpers de base de datos

### Presentation Layer (`lib/presentation/`)
- **pages/**: Pantallas principales de la aplicación
- **widgets/**: Widgets reutilizables
- **providers/**: Gestores de estado (Provider/Riverpod)

## Dependencias Principales

- **sqflite**: Base de datos SQLite local
- **provider**: Gestión de estado
- **camera**: Escáner de códigos de barras
- **speech_to_text**: Reconocimiento de voz
- **flutter_local_notifications**: Notificaciones locales
- **permission_handler**: Gestión de permisos

## Permisos Configurados

### Android
- Cámara para escáner de códigos de barras
- Micrófono para comandos de voz
- Notificaciones para alertas de caducidad
- Almacenamiento para base de datos local

### iOS
- NSCameraUsageDescription
- NSMicrophoneUsageDescription
- NSPhotoLibraryUsageDescription
- Background modes para notificaciones