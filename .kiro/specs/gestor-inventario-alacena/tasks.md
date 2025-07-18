# Plan de Implementación - Gestor de Inventario de Alacena

- [x] 1. Configurar estructura del proyecto y dependencias básicas

  - Crear estructura de carpetas siguiendo Clean Architecture (domain, application, infrastructure, presentation)
  - Configurar dependencias en pubspec.yaml (sqflite, provider, camera, speech_to_text, flutter_local_notifications)
  - Configurar permisos en Android e iOS para cámara, micrófono y notificaciones
  - _Requerimientos: 1.1, 1.2_

- [x] 2. Implementar entidades del dominio y modelos de datos

  - [x] 2.1 Crear entidades principales (Existencia, ProductoBase, Proveedor)

    - Implementar clase Existencia con todos los campos requeridos
    - Implementar clase ProductoBase para autocompletado
    - Implementar clase Proveedor con tipos de establecimiento
    - _Requerimientos: 1.1, 1.2, 2.1, 2.2_

  - [x] 2.2 Crear enums y tipos auxiliares

    - Implementar TipoPerecibilidad (PERECEDERO, SEMI_PERECEDERO, NO_PERECEDERO)
    - Implementar EstadoExistencia (DISPONIBLE, CONSUMIDA, CADUCADA)
    - Crear tipos para comandos de voz y configuraciones
    - _Requerimientos: 3.1, 3.2, 3.3, 4.1_

- [x] 3. Implementar capa de infraestructura - Base de datos

  - [x] 3.1 Configurar SQLite y crear esquema de base de datos


    - Implementar DatabaseHelper con creación de tablas
    - Crear índices para optimización de consultas
    - Implementar migraciones de base de datos
    - _Requerimientos: 1.1, 1.2, 2.1, 2.2_

  - [x] 3.2 Implementar repositorios concretos

    - Implementar ExistenciaRepositoryImpl con operaciones CRUD
    - Implementar ProductoRepositoryImpl con búsqueda y autocompletado
    - Implementar ProveedorRepositoryImpl
    - Crear tests unitarios para repositorios
    - _Requerimientos: 1.1, 1.2, 2.1, 2.2, 6.1_

- [x] 4. Implementar servicios de dispositivo

  - [x] 4.1 Implementar servicio de escáner de códigos de barras

    - Configurar cámara para escaneo de códigos de barras
    - Implementar validación de formatos de códigos de barras
    - Crear fallback para entrada manual de códigos
    - _Requerimientos: 1.1, 1.2_


  - [x] 4.2 Implementar servicio de reconocimiento de voz

    - Configurar speech_to_text para comandos de consumo
    - Implementar parser de comandos de voz en español
    - Crear lógica de búsqueda por nombre de producto
    - _Requerimientos: 4.1, 4.2_

  - [x] 4.3 Implementar servicio de notificaciones locales

    - Configurar flutter_local_notifications
    - Implementar programación de notificaciones por fecha de caducidad
    - Crear diferentes tipos de notificaciones según perecibilidad
    - _Requerimientos: 3.1, 3.2, 3.3_

- [x] 5. Implementar casos de uso de la aplicación

  - [x] 5.1 Casos de uso para gestión de existencias
    - Implementar AgregarExistenciaUseCase con validaciones
    - Implementar MarcarComoConsumidaUseCase
    - Implementar BuscarExistenciasUseCase con filtros
    - Crear tests unitarios para casos de uso
    - _Requerimientos: 1.1, 1.2, 4.1, 4.2_


  - [x] 5.2 Casos de uso para análisis de precios

    - Implementar CalcularPromediosPreciosUseCase
    - Implementar CompararPreciosProveedoresUseCase
    - Implementar GenerarReporteGastosUseCase
    - _Requerimientos: 6.1, 6.2_


  - [x] 5.3 Casos de uso para gestión de proveedores


    - Implementar AgregarProveedorUseCase
    - Implementar AsociarCompraProveedorUseCase
    - Implementar ObtenerHistorialProveedorUseCase
    - _Requerimientos: 2.1, 2.2, 6.1_

- [ ] 6. Implementar interfaz de usuario básica

  - [x] 6.1 Crear pantalla principal con lista de existencias
    - Implementar ListView con existencias activas
    - Crear filtros por categoría y estado
    - Implementar búsqueda por nombre de producto
    - Mostrar indicadores visuales de caducidad próxima
    - _Requerimientos: 1.1, 1.2, 3.1, 3.2, 3.3_

  - [x] 6.2 Crear pantalla de agregar existencia
    - Implementar formulario de captura de datos
    - Integrar escáner de códigos de barras
    - Implementar autocompletado de nombres de productos
    - Crear selector de proveedor y fecha de caducidad
    - Implementar captura de foto del producto o selección desde galería como primer paso
    - _Requerimientos: 1.1, 1.2, 1.3, 2.1, 2.2_

  - [ ] 6.3 Crear pantalla de consumo por voz






    - Implementar botón de grabación de comandos de voz
    - Mostrar resultados de búsqueda por comando
    - Crear confirmación visual antes de marcar como consumida
    - _Requerimientos: 4.1, 4.2_

  - [x] 6.4 Mejorar experiencia de usuario de la cámara

    - Implementar inicialización proactiva de la cámara para mostrar opciones inmediatamente
    - Crear pantalla de vista previa de foto capturada con opciones de confirmar/retomar
    - Implementar indicadores de carga durante inicialización de cámara
    - Agregar transiciones suaves entre estados de cámara (inicializando, lista, capturando)
    - Crear manejo de errores amigable con opciones de reintentar o usar galería
    - _Requerimientos: 1.2, 1.3_

- [ ] 7. Implementar sistema de modos especializados
  - [ ] 7.1 Crear arquitectura base para modos especializados
    - Implementar interfaz ModoEspecializado
    - Crear RegistroModos para gestión de modos activos
    - Implementar sistema de campos y categorías personalizadas
    - _Requerimientos: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8_

  - [ ] 7.2 Implementar Modo Experto Nutricional
    - Crear campos adicionales para información nutricional
    - Implementar validaciones de estrategias alimentarias
    - Crear UI especializada para análisis nutricional
    - _Requerimientos: 5.1_

  - [ ] 7.3 Implementar Modo Botiquín
    - Crear campos para dosis, frecuencia y prescriptor
    - Implementar alertas críticas para medicamentos
    - Crear recordatorios de renovación de recetas
    - _Requerimientos: 5.3_

- [ ] 8. Implementar modos especializados adicionales
  - [ ] 8.1 Implementar Modo Higiene y Aseo
    - Crear categorías específicas y campos de ubicación
    - Implementar alertas por ubicación de almacenamiento
    - _Requerimientos: 5.2_

  - [ ] 8.2 Implementar Modo Mascotas
    - Crear campos para tipo de mascota y peso recomendado
    - Implementar validaciones por especie y edad
    - _Requerimientos: 5.4_

  - [ ] 8.3 Implementar Modo Suplementos
    - Crear campos para dosis diaria y horario de toma
    - Implementar recordatorios de toma y reabastecimiento
    - _Requerimientos: 5.5_

- [ ] 9. Implementar modos especializados de jardinería
  - [ ] 9.1 Implementar Modo Jardinería
    - Crear campos para temporada de uso y tipo de planta
    - Implementar validaciones de fechas de aplicación estacional
    - _Requerimientos: 5.6_

  - [ ] 9.2 Implementar Modo Huerta Urbana
    - Crear campos para ciclo de cultivo y época de siembra
    - Implementar calendario de siembra y cosecha
    - _Requerimientos: 5.7_

  - [ ] 9.3 Implementar Modo Ferretería
    - Crear campos para proyecto asociado y cantidad por unidad
    - Implementar validaciones de compatibilidad de materiales
    - _Requerimientos: 5.8_

  - [ ] 9.4 Implementar Modo Chef Personal
    - Refactorizar código existente de meal prep para integrarlo como modo especializado
    - Crear generador de recetas basado en inventario actual
    - Implementar análisis de ingredientes próximos a caducar para sugerencias de recetas
    - Integrar funcionalidad de marketplace de chefs privados existente
    - Crear sistema de planificación de meal prep semanal
    - _Requerimientos: 19_

- [ ] 10. Implementar pantallas de configuración y análisis
  - [ ] 10.1 Crear pantalla de configuración de modos
    - Implementar activación/desactivación de modos especializados
    - Crear configuración de parámetros por modo
    - Implementar validación de configuraciones
    - _Requerimientos: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8_

  - [ ] 10.2 Crear pantalla de análisis de precios
    - Implementar gráficos de evolución de precios
    - Mostrar comparativas entre proveedores
    - Crear reportes de gastos por categoría
    - _Requerimientos: 6.1, 6.2_

  - [ ] 10.3 Crear pantalla de historial archivado
    - Implementar vista de existencias consumidas
    - Crear filtros por fecha y proveedor
    - Mostrar estadísticas de consumo
    - _Requerimientos: 1.2, 6.1, 6.2_

- [ ] 11. Implementar sistema de notificaciones completo
  - [ ] 11.1 Configurar notificaciones por tipo de perecibilidad
    - Implementar notificaciones 7 días antes para perecederos
    - Implementar notificaciones 30 días antes para semi-perecederos
    - Implementar notificaciones 90 días antes para no perecederos
    - _Requerimientos: 3.1, 3.2, 3.3_

  - [ ] 11.2 Implementar configuración personalizada de notificaciones
    - Crear pantalla de configuración de horarios
    - Implementar activación/desactivación por tipo
    - Permitir personalización de mensajes
    - _Requerimientos: 3.1, 3.2, 3.3_

- [ ] 12. Implementar tests de integración y end-to-end
  - [ ] 12.1 Crear tests de integración para flujos principales
    - Test de agregar existencia completo (escáner + formulario)
    - Test de consumo por voz end-to-end
    - Test de notificaciones programadas
    - _Requerimientos: 1.1, 1.2, 3.1, 4.1, 4.2_

  - [ ] 12.2 Crear tests end-to-end para modos especializados
    - Test de activación y configuración de modos
    - Test de funcionalidades específicas por modo
    - Test de validaciones especializadas
    - _Requerimientos: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8_

- [ ] 13. Optimización y pulido final
  - [ ] 13.1 Optimizar rendimiento de la aplicación
    - Implementar lazy loading en listas largas
    - Optimizar consultas de base de datos
    - Implementar caché inteligente de datos
    - _Requerimientos: 1.1, 1.2, 6.1_

  - [ ] 13.2 Implementar manejo robusto de errores
    - Crear manejo de errores para todos los servicios de dispositivo
    - Implementar recuperación automática de errores de base de datos
    - Crear mensajes de error amigables para el usuario
    - _Requerimientos: 1.1, 1.2, 3.1, 4.1, 4.2_

  - [ ] 13.3 Crear documentación y guías de usuario
    - Implementar tutorial inicial para nuevos usuarios
    - Crear ayuda contextual en pantallas complejas
    - Documentar funcionalidades de cada modo especializado
    - _Requerimientos: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8_