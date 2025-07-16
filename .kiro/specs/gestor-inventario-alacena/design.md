# Documento de Diseño - Gestor de Inventario de Alacena

## Visión General

El sistema será una aplicación móvil multiplataforma (Flutter) que permite gestionar eficientemente el inventario personal de alacena, con funcionalidades extensibles a través de modos especializados. La arquitectura se basa en el patrón Clean Architecture para garantizar escalabilidad y mantenibilidad.

### Principios de Diseño

- **Simplicidad por defecto**: La interfaz básica debe ser intuitiva para usuarios principiantes
- **Extensibilidad modular**: Los modos especializados se activan opcionalmente sin afectar la experiencia básica
- **Trazabilidad completa**: Cada existencia individual mantiene su identidad única a través de códigos de barras
- **Offline-first**: La aplicación debe funcionar sin conexión a internet

## Arquitectura

### Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
├─────────────────────────────────────────────────────────────┤
│                    Application Layer                         │
├─────────────────────────────────────────────────────────────┤
│                     Domain Layer                            │
├─────────────────────────────────────────────────────────────┤
│                 Infrastructure Layer                        │
└─────────────────────────────────────────────────────────────┘
```

### Capas de la Arquitectura

**Presentation Layer**
- Widgets de Flutter organizados por funcionalidad
- Gestores de estado usando Provider/Riverpod
- Controladores de entrada de voz y escáner

**Application Layer**
- Casos de uso específicos para cada funcionalidad
- Servicios de aplicación para lógica de negocio compleja
- Coordinadores de modos especializados

**Domain Layer**
- Entidades del dominio (Producto, Existencia, Proveedor, etc.)
- Repositorios abstractos
- Servicios de dominio para reglas de negocio

**Infrastructure Layer**
- Implementaciones de repositorios (SQLite local)
- Servicios externos (escáner, reconocimiento de voz, notificaciones)
- Adaptadores de datos

## Componentes y Interfaces

### Entidades Principales

#### Existencia (Stock Item)
```dart
class Existencia {
  String id;
  String codigoBarras;
  String nombreProducto;
  String categoria;
  DateTime fechaCompra;
  DateTime fechaCaducidad;
  double precio;
  String proveedorId;
  TipoPerecibilidad perecibilidad;
  EstadoExistencia estado; // DISPONIBLE, CONSUMIDA, CADUCADA
  Map<String, dynamic> metadatos; // Para modos especializados
}
```

#### Producto Base
```dart
class ProductoBase {
  String codigoBarras;
  String nombre;
  String categoria;
  TipoPerecibilidad perecibilidadDefault;
  List<String> restriccionesAlimentarias;
  InformacionNutricional? infoNutricional; // Para modo experto
}
```

#### Proveedor
```dart
class Proveedor {
  String id;
  String nombre;
  String tipo; // SUPERMERCADO, FARMACIA, FERRETERIA, etc.
  bool activo;
}
```

### Interfaces de Repositorio

```dart
abstract class ExistenciaRepository {
  Future<List<Existencia>> obtenerExistenciasActivas();
  Future<List<Existencia>> obtenerExistenciasArchivadas();
  Future<void> guardarExistencia(Existencia existencia);
  Future<void> marcarComoConsumida(String existenciaId);
  Future<List<Existencia>> buscarPorCodigoBarras(String codigo);
}

abstract class ProductoRepository {
  Future<ProductoBase?> buscarPorCodigoBarras(String codigo);
  Future<void> guardarProductoBase(ProductoBase producto);
  Future<List<String>> obtenerSugerenciasAutocompletado(String query);
}
```

### Servicios de Dominio

#### Servicio de Notificaciones
```dart
class ServicioNotificaciones {
  Future<void> programarNotificacionesCaducidad();
  Future<void> enviarNotificacionInmediata(TipoNotificacion tipo, String mensaje);
  Future<void> configurarHorariosPersonalizados(ConfiguracionNotificaciones config);
}
```

#### Servicio de Reconocimiento de Voz
```dart
class ServicioReconocimientoVoz {
  Future<ComandoVoz> procesarComandoConsumo(String audioInput);
  Future<List<Existencia>> buscarExistenciasPorComando(ComandoVoz comando);
}
```

## Modelos de Datos

### Esquema de Base de Datos (SQLite)

```sql
-- Tabla principal de existencias individuales
CREATE TABLE existencias (
    id TEXT PRIMARY KEY,
    codigo_barras TEXT NOT NULL,
    nombre_producto TEXT NOT NULL,
    categoria TEXT,
    fecha_compra DATE NOT NULL,
    fecha_caducidad DATE,
    precio REAL NOT NULL,
    proveedor_id TEXT,
    perecibilidad INTEGER NOT NULL,
    estado INTEGER NOT NULL DEFAULT 0,
    metadatos_json TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de productos base (para autocompletado y datos compartidos)
CREATE TABLE productos_base (
    codigo_barras TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    categoria TEXT,
    perecibilidad_default INTEGER,
    restricciones_alimentarias TEXT, -- JSON array
    info_nutricional TEXT -- JSON object
);

-- Tabla de proveedores
CREATE TABLE proveedores (
    id TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    tipo TEXT NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de configuración de usuario
CREATE TABLE configuracion_usuario (
    clave TEXT PRIMARY KEY,
    valor TEXT NOT NULL
);

-- Tabla de modos activos
CREATE TABLE modos_activos (
    modo TEXT PRIMARY KEY,
    configuracion TEXT -- JSON object
);
```

### Índices para Optimización

```sql
CREATE INDEX idx_existencias_estado ON existencias(estado);
CREATE INDEX idx_existencias_fecha_caducidad ON existencias(fecha_caducidad);
CREATE INDEX idx_existencias_codigo_barras ON existencias(codigo_barras);
CREATE INDEX idx_existencias_proveedor ON existencias(proveedor_id);
```

## Gestión de Errores

### Estrategia de Manejo de Errores

**Errores de Conectividad**
- La aplicación funciona completamente offline
- Sincronización opcional con servicios externos (futuro)

**Errores de Escáner**
- Fallback a entrada manual de código de barras
- Validación de formato de código de barras

**Errores de Reconocimiento de Voz**
- Solicitud de repetición del comando
- Fallback a interfaz táctil

**Errores de Datos**
- Validación en múltiples capas
- Recuperación automática de datos corruptos

### Códigos de Error Estándar

```dart
enum TipoError {
  CODIGO_BARRAS_INVALIDO,
  PRODUCTO_NO_ENCONTRADO,
  EXISTENCIA_YA_CONSUMIDA,
  COMANDO_VOZ_NO_RECONOCIDO,
  ERROR_BASE_DATOS,
  ERROR_CAMARA,
  ERROR_MICROFONO
}
```

## Estrategia de Pruebas

### Pirámide de Pruebas

**Pruebas Unitarias (70%)**
- Lógica de dominio
- Casos de uso
- Servicios de aplicación
- Validaciones

**Pruebas de Integración (20%)**
- Repositorios con base de datos
- Servicios externos (cámara, micrófono)
- Flujos completos de casos de uso

**Pruebas de UI (10%)**
- Flujos críticos de usuario
- Navegación entre pantallas
- Funcionalidad de escáner y voz

### Herramientas de Prueba

- **Flutter Test**: Pruebas unitarias y de widgets
- **Integration Test**: Pruebas end-to-end
- **Mockito**: Mocking de dependencias
- **Golden Tests**: Pruebas de regresión visual

## Arquitectura de Modos Especializados

### Patrón de Diseño para Modos

Cada modo especializado implementa una interfaz común que extiende la funcionalidad base:

```dart
abstract class ModoEspecializado {
  String get nombre;
  List<CategoriaPersonalizada> get categoriasAdicionales;
  List<CampoPersonalizado> get camposAdicionales;
  Widget buildConfiguracionWidget();
  List<Validacion> get validacionesAdicionales;
}
```

### Implementación de Modos

**Modo Experto Nutricional**
- Campos adicionales: información nutricional, estrategia alimentaria
- Validaciones: compatibilidad con estrategia seleccionada
- UI adicional: análisis nutricional, etiquetas de compatibilidad

**Modo Higiene y Aseo**
- Campos adicionales: ubicación de almacenamiento
- Categorías: limpieza hogar, aseo personal
- Lógica especial: alertas por ubicación

**Modo Botiquín**
- Campos adicionales: dosis, frecuencia, prescriptor
- Validaciones: fechas de vencimiento críticas
- Alertas especiales: renovación de recetas

**Modo Mascotas**
- Campos adicionales: tipo de mascota, peso recomendado, edad objetivo
- Categorías: alimento seco, húmedo, snacks, medicamentos veterinarios
- Validaciones: compatibilidad por especie y edad

**Modo Suplementos**
- Campos adicionales: dosis diaria, horario de toma, objetivo nutricional
- Categorías: vitaminas, minerales, proteínas, pre/post entreno
- Alertas especiales: recordatorios de toma y reabastecimiento

**Modo Jardinería**
- Campos adicionales: temporada de uso, tipo de planta objetivo
- Categorías: fertilizantes, pesticidas, semillas, herramientas
- Validaciones: fechas de aplicación estacional

**Modo Huerta Urbana**
- Campos adicionales: ciclo de cultivo, época de siembra/cosecha
- Categorías: semillas, plantines, sustratos, nutrientes orgánicos
- Lógica especial: calendario de siembra y cosecha

**Modo Ferretería**
- Campos adicionales: proyecto asociado, cantidad por unidad
- Categorías: tornillería, herramientas, materiales de construcción
- Validaciones: compatibilidad de materiales y herramientas

### Registro y Activación de Modos

```dart
class RegistroModos {
  static final Map<String, ModoEspecializado> _modos = {
    'experto': ModoExpertoNutricional(),
    'higiene': ModoHigieneAseo(),
    'botiquin': ModoBotiquin(),
    'mascotas': ModoMascotas(),
    'suplementos': ModoSuplemetos(),
    'jardineria': ModoJardineria(),
    'huerta': ModoHuertaUrbana(),
    'ferreteria': ModoFerreteria(),
  };
  
  static List<ModoEspecializado> get modosDisponibles => _modos.values.toList();
  static ModoEspecializado? obtenerModo(String nombre) => _modos[nombre];
}
```

## Decisiones de Diseño y Justificaciones

### 1. Arquitectura Clean Architecture
**Decisión**: Implementar Clean Architecture con separación clara de capas
**Justificación**: Permite escalabilidad para múltiples modos especializados y facilita testing

### 2. SQLite Local como Almacenamiento Principal
**Decisión**: Usar SQLite como almacenamiento principal con arquitectura preparada para sincronización futura
**Justificación**: Garantiza privacidad de datos alimentarios y funcionalidad offline completa, con capacidad de evolucionar hacia sincronización en la nube usando Firestore (NoSQL) o combinación PostgreSQL/MongoDB

### 3. Existencias Individuales vs Agrupadas
**Decisión**: Cada código de barras escaneado crea una existencia única
**Justificación**: Permite trazabilidad completa de lotes y fechas de caducidad específicas

### 4. Patrón de Modos Especializados
**Decisión**: Sistema modular de modos que se activan opcionalmente
**Justificación**: Mantiene simplicidad para usuarios básicos mientras permite funcionalidad avanzada

### 5. Archivado vs Eliminación
**Decisión**: Archivar existencias consumidas en lugar de eliminarlas
**Justificación**: Permite análisis histórico de precios y patrones de consumo

### 6. Reconocimiento de Voz Local
**Decisión**: Usar reconocimiento de voz del dispositivo sin servicios externos
**Justificación**: Mantiene privacidad y funciona offline

### 7. Notificaciones Push Locales
**Decisión**: Usar notificaciones locales programadas
**Justificación**: No requiere servidor backend y garantiza funcionamiento offline

### 8. Flutter como Framework
**Decisión**: Desarrollar en Flutter para multiplataforma
**Justificación**: Permite deployment en iOS y Android con una sola base de código

## Consideraciones de Rendimiento

### Optimizaciones de Base de Datos
- Índices en campos de búsqueda frecuente
- Paginación para listas grandes
- Consultas lazy para datos relacionados

### Gestión de Memoria
- Lazy loading de imágenes de productos
- Caché inteligente de datos frecuentemente accedidos
- Limpieza automática de datos temporales

### Optimización de UI
- Virtualización de listas largas
- Debouncing en campos de búsqueda
- Carga asíncrona de componentes pesados

## Seguridad y Privacidad

### Protección de Datos
- Todos los datos se almacenan localmente
- No se envían datos a servidores externos
- Encriptación opcional de base de datos local

### Permisos de Dispositivo
- Cámara: Solo para escáner de códigos de barras
- Micrófono: Solo para comandos de voz
- Notificaciones: Para alertas de caducidad
- Almacenamiento: Para base de datos local

### Cumplimiento de Regulaciones
- Diseño compatible con GDPR (datos locales)
- Transparencia en uso de permisos
- Opción de exportar/eliminar todos los datos