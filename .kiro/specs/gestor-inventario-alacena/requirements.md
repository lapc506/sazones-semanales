# Documento de Requisitos

## Introducción

Esta aplicación está diseñada para gestionar eficientemente el inventario de la alacena personal, permitiendo actualizar las existencias de productos después de cada compra en el supermercado. La aplicación se enfoca en facilitar el registro y seguimiento de productos para una persona que vive sola, con gustos y restricciones alimentarias bien definidos.

## Requisitos

### Requisito 1

**Historia de Usuario:** Como usuario que vive solo, quiero registrar rápidamente cada producto individual que compré en el supermercado, para mantener actualizado el inventario de mi alacena sin perder tiempo.

#### Criterios de Aceptación

1. CUANDO el usuario abra la aplicación después de ir de compras ENTONCES el sistema DEBERÁ mostrar una interfaz de registro rápido de productos con escáner de códigos de barras
2. CUANDO el usuario escanee o ingrese un producto ENTONCES el sistema DEBERÁ crear una nueva existencia individual con fecha de compra, fecha de caducidad específica y precio pagado
3. CUANDO el usuario registre múltiples unidades del mismo producto ENTONCES el sistema DEBERÁ crear existencias separadas para cada código de barras escaneado
4. CUANDO el usuario complete el registro de compras ENTONCES el sistema DEBERÁ guardar todas las existencias individuales automáticamente

### Requisito 2

**Historia de Usuario:** Como usuario con gustos y restricciones alimentarias definidos, quiero categorizar mis productos según mis preferencias personales, para organizar mejor mi inventario.

#### Criterios de Aceptación

1. CUANDO el usuario registre un producto ENTONCES el sistema DEBERÁ permitir asignar categorías personalizadas
2. CUANDO el usuario configure sus restricciones alimentarias ENTONCES el sistema DEBERÁ marcar automáticamente productos incompatibles
3. CUANDO el usuario visualice su inventario ENTONCES el sistema DEBERÁ mostrar productos agrupados por categorías
4. SI un producto tiene restricciones alimentarias ENTONCES el sistema DEBERÁ mostrar una advertencia visual clara

### Requisito 3

**Historia de Usuario:** Como usuario que gestiona su alacena, quiero recibir notificaciones oportunas sobre productos próximos a caducar, para consumirlos antes de que se echen a perder según su tipo de perecibilidad.

#### Criterios de Aceptación

1. CUANDO el usuario acceda al inventario ENTONCES el sistema DEBERÁ mostrar todas las existencias individuales con sus fechas de caducidad específicas
2. CUANDO el usuario registre un producto ENTONCES el sistema DEBERÁ permitir clasificarlo por perecibilidad (altamente perecedero, medianamente perecedero, poco perecedero, no perecedero) y especificar fecha de caducidad
3. CUANDO un producto altamente perecedero tenga 2 días o menos para caducar ENTONCES el sistema DEBERÁ enviar notificación push crítica
4. CUANDO un producto medianamente perecedero tenga 5 días o menos para caducar ENTONCES el sistema DEBERÁ enviar notificación push de advertencia
5. CUANDO un producto poco perecedero tenga 15 días o menos para caducar ENTONCES el sistema DEBERÁ enviar notificación push de precaución
6. CUANDO un producto haya caducado ENTONCES el sistema DEBERÁ enviar notificación push inmediata y marcarlo para eliminación
7. CUANDO el usuario consuma un producto ENTONCES el sistema DEBERÁ permitir marcar existencias específicas como consumidas
8. CUANDO el usuario configure las notificaciones ENTONCES el sistema DEBERÁ permitir personalizar horarios y tipos de alerta

### Requisito 4

**Historia de Usuario:** Como usuario que quiere optimizar sus compras, quiero llevar un historial de mis compras y consumo de existencias individuales, para identificar patrones en mis hábitos alimentarios.

#### Criterios de Aceptación

1. CUANDO el usuario registre una compra ENTONCES el sistema DEBERÁ guardar fecha, existencias individuales y códigos de barras en el historial
2. CUANDO el usuario consuma existencias específicas ENTONCES el sistema DEBERÁ registrar la fecha y existencia consumida con su código de barras
3. CUANDO el usuario solicite ver estadísticas ENTONCES el sistema DEBERÁ mostrar productos más comprados, frecuencia de compra y patrones de consumo por lote
4. CUANDO el usuario revise el historial ENTONCES el sistema DEBERÁ permitir filtrar por fechas, categorías y códigos de barras específicos

### Requisito 5

**Historia de Usuario:** Como usuario que usa la aplicación regularmente, quiero una interfaz simple e intuitiva, para poder actualizar mi inventario rápidamente sin complicaciones.

#### Criterios de Aceptación

1. CUANDO el usuario abra la aplicación ENTONCES el sistema DEBERÁ cargar en menos de 3 segundos
2. CUANDO el usuario registre productos ENTONCES el sistema DEBERÁ ofrecer autocompletado basado en compras anteriores
3. CUANDO el usuario navegue por la aplicación ENTONCES el sistema DEBERÁ mantener una interfaz consistente y clara
4. CUANDO el usuario realice acciones frecuentes ENTONCES el sistema DEBERÁ requerir máximo 2 toques/clics para completarlas

### Requisito 6

**Historia de Usuario:** Como usuario que registra productos con diferentes lotes y códigos de barras, quiero escanear cada producto individualmente, para mantener un registro único de cada existencia con su información específica de lote y caducidad.

#### Criterios de Aceptación

1. CUANDO el usuario registre un producto ENTONCES el sistema DEBERÁ permitir escanear el código de barras usando la cámara del dispositivo
2. CUANDO el sistema escanee un código de barras ENTONCES el sistema DEBERÁ crear una instancia única del producto con su código específico
3. CUANDO el usuario registre productos del mismo tipo pero diferentes lotes ENTONCES el sistema DEBERÁ tratarlos como existencias separadas e independientes
4. CUANDO el usuario visualice su inventario ENTONCES el sistema DEBERÁ mostrar cada existencia individual con su código de barras y información de lote
5. CUANDO el usuario consuma un producto específico ENTONCES el sistema DEBERÁ permitir seleccionar la existencia exacta por código de barras
6. CUANDO el sistema no pueda escanear un código ENTONCES el sistema DEBERÁ permitir ingreso manual del código de barras
7. CUANDO el usuario tenga múltiples existencias del mismo producto ENTONCES el sistema DEBERÁ agruparlas visualmente pero mantener su individualidad en los datos

### Requisito 7

**Historia de Usuario:** Como usuario que compra en diferentes supermercados y tiendas, quiero registrar de qué proveedor compré cada existencia específica, para llevar un seguimiento de dónde adquiero mis productos y optimizar mis decisiones de compra.

#### Criterios de Aceptación

1. CUANDO el usuario configure su perfil ENTONCES el sistema DEBERÁ permitir crear y gestionar una lista personalizada de proveedores (supermercados, tiendas, etc.)
2. CUANDO el usuario abra la aplicación para registrar compras ENTONCES el sistema DEBERÁ preguntar primero "¿De cuál proveedor vienes llegando de hacer las compras?" mostrando las opciones guardadas
3. CUANDO el usuario seleccione un proveedor ENTONCES el sistema DEBERÁ asociar automáticamente todas las existencias registradas en esa sesión con ese proveedor específico
4. CUANDO el usuario registre una existencia individual ENTONCES el sistema DEBERÁ guardar la información del proveedor junto con el código de barras y demás datos
5. CUANDO el usuario visualice su inventario ENTONCES el sistema DEBERÁ mostrar de qué proveedor proviene cada existencia
6. CUANDO el usuario revise estadísticas ENTONCES el sistema DEBERÁ mostrar análisis por proveedor (frecuencia de compra, productos más comprados por tienda, etc.)
7. CUANDO el usuario gestione proveedores ENTONCES el sistema DEBERÁ permitir agregar, editar y eliminar proveedores de su lista personal

### Requisito 8

**Historia de Usuario:** Como usuario que está cocinando, quiero poder decir por voz qué productos voy a consumir, para marcar rápidamente las existencias como consumidas sin tener que tocar la pantalla con las manos sucias.

#### Criterios de Aceptación

1. CUANDO el usuario active el comando de voz ENTONCES el sistema DEBERÁ permitir reconocimiento de voz para especificar productos a consumir
2. CUANDO el usuario diga una frase como "Voy a gastar 2 paquetes de espagueti y una lata de salsa de tomate" ENTONCES el sistema DEBERÁ interpretar los productos y cantidades mencionados
3. CUANDO el sistema procese el comando de voz ENTONCES el sistema DEBERÁ mostrar existencias sugeridas que coincidan con los productos mencionados
4. CUANDO el sistema muestre las sugerencias ENTONCES el sistema DEBERÁ priorizar existencias próximas a caducar y permitir selección con botón "Consumir"
5. CUANDO el usuario confirme el consumo ENTONCES el sistema DEBERÁ marcar las existencias específicas como consumidas y actualizar el inventario
6. CUANDO el usuario busque una receta ENTONCES el sistema DEBERÁ permitir usar comandos de voz para especificar qué ingredientes consumir de la receta
7. CUANDO el sistema no reconozca claramente el comando ENTONCES el sistema DEBERÁ pedir confirmación o repetición del comando de voz
8. CUANDO el usuario use comandos de voz ENTONCES el sistema DEBERÁ funcionar sin requerir interacción táctil para confirmar consumos

### Requisito 9

**Historia de Usuario:** Como usuario que planifica sus compras mensualmente según mis fechas de pago, quiero recibir sugerencias automáticas de lista de compras, para evitar quedarme sin productos esenciales y optimizar mis visitas al supermercado.

#### Criterios de Aceptación

1. CUANDO el usuario configure su perfil ENTONCES el sistema DEBERÁ permitir establecer la frecuencia de sugerencias de compras (cada 15 o 30 días según fechas de pago)
2. CUANDO llegue la fecha programada ENTONCES el sistema DEBERÁ generar automáticamente una lista de compras sugerida basada en existencias próximas a agotarse
3. CUANDO el sistema genere la lista sugerida ENTONCES el sistema DEBERÁ considerar patrones de consumo histórico y fechas de caducidad próximas
4. CUANDO el usuario reciba la sugerencia ENTONCES el sistema DEBERÁ permitir editar, agregar o eliminar productos de la lista antes de ir de compras
5. CUANDO el usuario quiera importar su lista habitual ENTONCES el sistema DEBERÁ permitir cargar una hoja de cálculo con productos del diario
6. CUANDO el sistema importe la hoja de cálculo ENTONCES el sistema DEBERÁ analizar qué productos faltan en el inventario actual y sugerirlos para compra
7. CUANDO el usuario vaya de compras con la lista ENTONCES el sistema DEBERÁ permitir marcar productos como "comprados" y facilitar el registro posterior
8. CUANDO el usuario complete las compras ENTONCES el sistema DEBERÁ actualizar los patrones de consumo para mejorar futuras sugerencias

### Requisito 10

**Historia de Usuario:** Como usuario que quiere analizar la fluctuación de precios y mantener trazabilidad completa, quiero que cada existencia registre su precio de compra y que los productos consumidos se archiven en lugar de eliminarse, para poder analizar tendencias de precios y patrones de consumo históricos.

#### Criterios de Aceptación

1. CUANDO el usuario registre una existencia ENTONCES el sistema DEBERÁ requerir y guardar el precio pagado por esa existencia específica
2. CUANDO el usuario marque una existencia como consumida ENTONCES el sistema DEBERÁ archivarla en lugar de eliminarla, manteniendo todos sus datos
3. CUANDO el usuario acceda al historial de precios ENTONCES el sistema DEBERÁ mostrar la fluctuación de precios por producto a lo largo del tiempo
4. CUANDO el usuario consulte estadísticas de costos ENTONCES el sistema DEBERÁ mostrar análisis de gasto por categoría, proveedor y período de tiempo
5. CUANDO el usuario compare precios ENTONCES el sistema DEBERÁ mostrar diferencias de precio del mismo producto entre diferentes proveedores
6. CUANDO el usuario revise existencias archivadas ENTONCES el sistema DEBERÁ permitir filtrar y buscar productos consumidos por fecha, precio y proveedor
7. CUANDO el sistema genere reportes ENTONCES el sistema DEBERÁ incluir análisis de costo-beneficio y tendencias de precios para optimizar futuras compras
8. CUANDO el usuario visualice un producto ENTONCES el sistema DEBERÁ mostrar el historial completo de precios pagados por ese tipo de producto
9. CUANDO el sistema analice patrones de consumo ENTONCES el sistema DEBERÁ identificar posibles correlaciones entre productos consumidos y síntomas o restricciones alimentarias
10. CUANDO el sistema detecte patrones sospechosos ENTONCES el sistema DEBERÁ sugerir consultar con un nutriólogo y ofrecer reportes detallados para la consulta
11. CUANDO el usuario configure restricciones alimentarias conocidas ENTONCES el sistema DEBERÁ monitorear el consumo de productos relacionados y alertar sobre posibles intolerancias emergentes
12. CUANDO el usuario genere reportes para nutriólogo ENTONCES el sistema DEBERÁ incluir historial de consumo, frecuencias, fechas y posibles correlaciones con síntomas registrados

### Requisito 11

**Historia de Usuario:** Como usuario avanzado que sigue una estrategia nutricional específica, quiero activar un "Modo Experto" que me permita alinear mis compras con mi plan alimentario y hacer seguimiento nutricional detallado, para mantener consistencia con mis objetivos nutricionales sin abrumar a usuarios principiantes.

#### Criterios de Aceptación

1. CUANDO el usuario configure su perfil ENTONCES el sistema DEBERÁ ofrecer activar el "Modo Experto" como funcionalidad opcional
2. CUANDO el usuario active el Modo Experto ENTONCES el sistema DEBERÁ permitir seleccionar una estrategia nutricional (ketogénica, mediterránea, vegana, paleo, etc.)
3. CUANDO el sistema genere sugerencias de compra en Modo Experto ENTONCES el sistema DEBERÁ evaluar cada producto sugerido contra la estrategia nutricional seleccionada
4. CUANDO el sistema muestre la lista de compras en Modo Experto ENTONCES el sistema DEBERÁ mostrar etiquetas visuales indicando el nivel de alineación (altamente recomendado, compatible, neutral, no recomendado)
5. CUANDO el usuario registre productos en Modo Experto ENTONCES el sistema DEBERÁ permitir ingresar opcionalmente información nutricional (calorías, grasas, azúcares, proteínas, carbohidratos, etc.)
6. CUANDO el usuario ingrese datos nutricionales ENTONCES el sistema DEBERÁ calcular automáticamente totales nutricionales por día, semana o mes
7. CUANDO el usuario visualice estadísticas en Modo Experto ENTONCES el sistema DEBERÁ mostrar análisis nutricional detallado y adherencia a la estrategia seleccionada
8. CUANDO el usuario desactive el Modo Experto ENTONCES el sistema DEBERÁ ocultar todas las funcionalidades avanzadas pero mantener los datos guardados
9. CUANDO el usuario no tenga Modo Experto activado ENTONCES el sistema DEBERÁ mostrar solo funcionalidades básicas de inventario sin complejidad nutricional

### Requisito 12

**Historia de Usuario:** Como usuario que gestiona artículos de limpieza e higiene personal, quiero activar un "Modo Higiene y Aseo" para organizar y hacer seguimiento de productos de limpieza del hogar y aseo personal, para mantener un inventario completo de estos productos esenciales.

#### Criterios de Aceptación

1. CUANDO el usuario configure su perfil ENTONCES el sistema DEBERÁ ofrecer activar el "Modo Higiene y Aseo" como funcionalidad opcional
2. CUANDO el usuario active el Modo Higiene y Aseo ENTONCES el sistema DEBERÁ permitir categorizar productos en limpieza del hogar y aseo personal
3. CUANDO el usuario registre productos de higiene ENTONCES el sistema DEBERÁ permitir especificar ubicación de almacenamiento (baño, cocina, lavandería, etc.)
4. CUANDO el sistema genere sugerencias de compra ENTONCES el sistema DEBERÁ incluir productos de higiene próximos a agotarse
5. CUANDO el usuario visualice inventario en este modo ENTONCES el sistema DEBERÁ mostrar productos agrupados por categoría y ubicación
6. CUANDO el usuario configure alertas ENTONCES el sistema DEBERÁ permitir notificaciones específicas para productos de higiene críticos
7. CUANDO el usuario desactive el Modo Higiene y Aseo ENTONCES el sistema DEBERÁ ocultar estas funcionalidades pero mantener los datos guardados

### Requisito 13

**Historia de Usuario:** Como usuario que necesita gestionar medicamentos del hogar, quiero activar un "Modo Botiquín" para hacer seguimiento de medicamentos de venta libre y con receta médica, para asegurar disponibilidad de medicamentos esenciales y controlar fechas de vencimiento.

#### Criterios de Aceptación

1. CUANDO el usuario configure su perfil ENTONCES el sistema DEBERÁ ofrecer activar el "Modo Botiquín" como funcionalidad opcional
2. CUANDO el usuario active el Modo Botiquín ENTONCES el sistema DEBERÁ permitir categorizar medicamentos (venta libre, receta médica, vitaminas, primeros auxilios)
3. CUANDO el usuario registre medicamentos ENTONCES el sistema DEBERÁ permitir especificar dosis, frecuencia de uso y prescriptor (para medicamentos con receta)
4. CUANDO el sistema detecte medicamentos próximos a vencer ENTONCES el sistema DEBERÁ enviar alertas críticas con mayor anticipación que productos alimentarios
5. CUANDO el usuario configure alertas médicas ENTONCES el sistema DEBERÁ permitir notificaciones para renovación de recetas médicas
6. CUANDO el usuario visualice el botiquín ENTONCES el sistema DEBERÁ mostrar medicamentos agrupados por tipo y urgencia de renovación
7. CUANDO el usuario genere reportes médicos ENTONCES el sistema DEBERÁ permitir exportar historial de medicamentos para consultas médicas

### Requisito 14

**Historia de Usuario:** Como usuario que tiene mascotas, quiero activar un "Modo Mascotas" para gestionar alimento y medicamentos de mis perros o gatos, para asegurar que mis mascotas tengan siempre los productos necesarios para su bienestar.

#### Criterios de Aceptación

1. CUANDO el usuario configure su perfil ENTONCES el sistema DEBERÁ ofrecer activar el "Modo Mascotas" como funcionalidad opcional
2. CUANDO el usuario active el Modo Mascotas ENTONCES el sistema DEBERÁ permitir registrar información de mascotas (nombre, tipo, edad, peso)
3. CUANDO el usuario registre productos para mascotas ENTONCES el sistema DEBERÁ permitir categorizar por tipo (alimento, medicamentos, accesorios, higiene)
4. CUANDO el sistema calcule consumo de alimento ENTONCES el sistema DEBERÁ considerar el peso y edad de la mascota para estimar duración
5. CUANDO el usuario registre medicamentos veterinarios ENTONCES el sistema DEBERÁ permitir especificar dosis por peso y frecuencia de administración
6. CUANDO el sistema genere sugerencias de compra ENTONCES el sistema DEBERÁ incluir productos para mascotas próximos a agotarse
7. CUANDO el usuario visualice inventario de mascotas ENTONCES el sistema DEBERÁ mostrar productos agrupados por mascota y tipo de producto
8. CUANDO el usuario genere reportes veterinarios ENTONCES el sistema DEBERÁ permitir exportar historial de medicamentos y alimentación para consultas veterinarias

### Requisito 15

**Historia de Usuario:** Como usuario que consume suplementos nutricionales, quiero activar un "Modo Suplementos" para gestionar proteínas, creatina, colágeno y otros suplementos, para mantener un seguimiento adecuado de mi suplementación tanto si soy deportista como adulto mayor con necesidades específicas.

#### Criterios de Aceptación

1. CUANDO el usuario configure su perfil ENTONCES el sistema DEBERÁ ofrecer activar el "Modo Suplementos" como funcionalidad opcional
2. CUANDO el usuario active el Modo Suplementos ENTONCES el sistema DEBERÁ permitir categorizar suplementos (proteínas, aminoácidos, vitaminas, minerales, otros)
3. CUANDO el usuario registre suplementos ENTONCES el sistema DEBERÁ permitir especificar dosis recomendada, frecuencia de consumo y objetivo (deportivo, salud general, deficiencias específicas)
4. CUANDO el usuario configure su perfil de suplementación ENTONCES el sistema DEBERÁ permitir especificar si es para uso deportivo, adulto mayor, o necesidades médicas específicas
5. CUANDO el sistema calcule duración de suplementos ENTONCES el sistema DEBERÁ considerar la dosis diaria y cantidad del producto para estimar cuándo se agotará
6. CUANDO el usuario visualice inventario de suplementos ENTONCES el sistema DEBERÁ mostrar productos agrupados por categoría y días restantes de suministro
7. CUANDO el sistema genere sugerencias de compra ENTONCES el sistema DEBERÁ incluir suplementos próximos a agotarse considerando tiempo de entrega
8. CUANDO el usuario genere reportes de suplementación ENTONCES el sistema DEBERÁ permitir exportar historial para consultas médicas o nutricionales
9. CUANDO el usuario registre efectos o resultados ENTONCES el sistema DEBERÁ permitir hacer seguimiento opcional de la efectividad de los suplementos

### Requisito 16

**Historia de Usuario:** Como usuario que cuida plantas ornamentales, quiero activar un "Modo Jardinería" para gestionar suministros de cuidado de plantas decorativas, para mantener un inventario adecuado de productos necesarios para el mantenimiento de mi jardín ornamental.

#### Criterios de Aceptación

1. CUANDO el usuario configure su perfil ENTONCES el sistema DEBERÁ ofrecer activar el "Modo Jardinería" como funcionalidad opcional
2. CUANDO el usuario active el Modo Jardinería ENTONCES el sistema DEBERÁ permitir categorizar suministros (fertilizantes, pesticidas, herramientas, macetas, tierra, decoración)
3. CUANDO el usuario registre productos de jardinería ENTONCES el sistema DEBERÁ permitir especificar tipo de planta objetivo y frecuencia de uso recomendada
4. CUANDO el sistema calcule consumo de productos ENTONCES el sistema DEBERÁ considerar la cantidad de plantas y frecuencia de aplicación
5. CUANDO el usuario visualice inventario de jardinería ENTONCES el sistema DEBERÁ mostrar productos agrupados por categoría y estación del año apropiada
6. CUANDO el sistema genere sugerencias de compra ENTONCES el sistema DEBERÁ considerar temporadas de jardinería y productos estacionales
7. CUANDO el usuario configure alertas ENTONCES el sistema DEBERÁ permitir notificaciones basadas en ciclos de cuidado de plantas

### Requisito 17

**Historia de Usuario:** Como usuario que cultiva una huerta urbana, quiero activar un "Modo Huerta Urbana" para gestionar semillas, fertilizantes y suministros de cultivo, para mantener un inventario completo de productos necesarios para mi huerta interior o exterior.

#### Criterios de Aceptación

1. CUANDO el usuario configure su perfil ENTONCES el sistema DEBERÁ ofrecer activar el "Modo Huerta Urbana" como funcionalidad opcional
2. CUANDO el usuario active el Modo Huerta Urbana ENTONCES el sistema DEBERÁ permitir categorizar suministros (semillas, fertilizantes orgánicos, sustratos, herramientas, sistemas de riego)
3. CUANDO el usuario registre semillas ENTONCES el sistema DEBERÁ permitir especificar fechas de siembra recomendadas y tiempo de germinación
4. CUANDO el usuario registre fertilizantes ENTONCES el sistema DEBERÁ permitir especificar tipo de cultivo objetivo y frecuencia de aplicación
5. CUANDO el sistema genere sugerencias de compra ENTONCES el sistema DEBERÁ considerar calendarios de siembra y ciclos de cultivo
6. CUANDO el usuario visualice inventario de huerta ENTONCES el sistema DEBERÁ mostrar productos agrupados por tipo y época de uso apropiada
7. CUANDO el usuario configure su huerta ENTONCES el sistema DEBERÁ permitir especificar si es interior, exterior, o ambos para personalizar sugerencias

### Requisito 18

**Historia de Usuario:** Como usuario que realiza reparaciones domésticas, quiero activar un "Modo Ferretería" para gestionar insumos de reparación y mantenimiento del hogar, para tener siempre disponibles los materiales básicos necesarios para reparaciones menores.

#### Criterios de Aceptación

1. CUANDO el usuario configure su perfil ENTONCES el sistema DEBERÁ ofrecer activar el "Modo Ferretería" como funcionalidad opcional
2. CUANDO el usuario active el Modo Ferretería ENTONCES el sistema DEBERÁ permitir categorizar insumos (eléctrico, fontanería, carpintería, pintura, herramientas, fijaciones)
3. CUANDO el usuario registre productos de ferretería ENTONCES el sistema DEBERÁ permitir especificar ubicación de almacenamiento y proyecto asociado
4. CUANDO el usuario visualice inventario de ferretería ENTONCES el sistema DEBERÁ mostrar productos agrupados por categoría y ubicación de almacenamiento
5. CUANDO el sistema genere sugerencias de compra ENTONCES el sistema DEBERÁ incluir productos básicos de emergencia (bombillas, fusibles, clavos, tornillos)
6. CUANDO el usuario registre un proyecto de reparación ENTONCES el sistema DEBERÁ permitir asociar materiales específicos y hacer seguimiento de consumo por proyecto
7. CUANDO el usuario configure alertas ENTONCES el sistema DEBERÁ permitir notificaciones para mantener stock mínimo de productos esenciales de emergencia

### Requisito 19

**Historia de Usuario:** Como usuario que planifica comidas semanales y busca optimizar mi meal prep, quiero activar un "Modo Chef Personal" que me genere recetas basadas en mis existencias actuales y me conecte con chefs privados para servicios especializados, para maximizar el uso de mis ingredientes disponibles y acceder a servicios culinarios profesionales cuando lo necesite.

#### Criterios de Aceptación

1. CUANDO el usuario configure su perfil ENTONCES el sistema DEBERÁ ofrecer activar el "Modo Chef Personal" como funcionalidad opcional
2. CUANDO el usuario active el Modo Chef Personal ENTONCES el sistema DEBERÁ analizar las existencias actuales del inventario para generar sugerencias de recetas
3. CUANDO el sistema genere sugerencias de recetas ENTONCES el sistema DEBERÁ priorizar recetas que utilicen ingredientes próximos a caducar
4. CUANDO el usuario seleccione una receta ENTONCES el sistema DEBERÁ mostrar qué existencias específicas del inventario se pueden usar y cuáles faltan
5. CUANDO el usuario confirme cocinar una receta ENTONCES el sistema DEBERÁ permitir marcar automáticamente las existencias utilizadas como consumidas
6. CUANDO el usuario busque servicios de chef privado ENTONCES el sistema DEBERÁ mostrar chefs disponibles para meal prep semanal en su área
7. CUANDO el usuario contrate un chef privado ENTONCES el sistema DEBERÁ permitir compartir su inventario actual y restricciones alimentarias con el chef
8. CUANDO el chef planifique el meal prep ENTONCES el sistema DEBERÁ generar una lista de compras complementaria basada en el inventario existente
9. CUANDO el usuario complete una sesión de meal prep ENTONCES el sistema DEBERÁ actualizar el inventario con las comidas preparadas y sus fechas de consumo recomendadas
10. CUANDO el usuario visualize su planificación semanal ENTONCES el sistema DEBERÁ mostrar comidas preparadas, ingredientes disponibles y sugerencias de recetas
11. CUANDO el usuario configure preferencias culinarias ENTONCES el sistema DEBERÁ permitir especificar tipos de cocina preferidos, nivel de dificultad y tiempo de preparación
12. CUANDO el sistema detecte ingredientes subutilizados ENTONCES el sistema DEBERÁ sugerir recetas específicas para aprovechar esos productos antes de que caduquen