# Aduana 801 - Manual Maestro de Producto, Funcionalidad y UI/UX

Este documento detalla a cabalidad las especificaciones funcionales, estéticas y modulares de la Super-App **Aduana 801**, sirviendo como guía definitiva para el equipo de desarrollo, diseño y cualquier Agente IA futuro.

---

## 1. Diseño Estético y UI/UX (Design System)

La aplicación sigue una línea estética **"Dark Premium / Cyber-Logistics"**, diseñada para evitar fatiga visual en usuarios que pasan largas horas frente a pedimentos aduanales, y para transmitir una sensación corporativa, financiera y de alta seguridad.

### 1.1 Paleta de Colores (`AppColors`)
- **Fondo Principal (`bg`):** `#060D1A` (Azul Noche muy profundo, casi negro).
- **Tarjetas y Superficies (`card`):** `#0D1A2E` (Azul Marino oscuro, genera profundidad usando sombras ligeras).
- **Bordes y Divisores (`border`):** `#1E3050` (Gris-Azulado tenue).
- **Texto Principal (`text`):** `#E2E8F0` (Blanco/Gris pálido).
- **Texto Secundario/Deshabilitado (`sub`):** `#8A9BB5` (Gris azulado medio).
- **Color de Acento Premium (`gold`):** `#DCA311` (Dorado/Mostaza, usado en llamadas a la acción, títulos de módulos IA y elementos Premium).
- **Estados:** 
  - **Error/Riesgo Alto (`red`):** `#EF4444`
  - **Éxito/Seguro (`green`):** `#10B981`
  - **Información/Acento Secundario (`blue`):** `#38BDF8`

### 1.2 Tipografía y Espaciado
- Tipografía limpia, sin serifa (generalmente Roboto/Inter por defecto en Flutter).
- Espaciado generoso (múltiplos de 8: 16px, 24px) para separar visualmente zonas densas de datos.
- Las tarjetas utilizan esquinas redondeadas (`BorderRadius.circular(16)`) para un look moderno (Glassmorphism ligero en algunas superposiciones).

---

## 2. Flujo de Navegación (Onboarding y Landing)

1. **`LandingScreen`:** Página de aterrizaje promocional. Vende el valor del sistema a nivel Enterprise.
2. **`PersonaSelectionScreen`:** Cuestionario interactivo donde el usuario elige su rol ("Empezando", "Importador", "Profesional/Agente Aduanal", "Exportador"). Configura el entorno mediante telemetría (`AnalyticsService`).
3. **`GuidedOnboardingScreen`:** Tour paso a paso por las funciones habilitadas según la *persona* elegida.
4. **`HomeScreen`:** El Dashboard maestro. Contiene accesos directos dinámicos, el buscador global (`SearchScreen`) y el rastreador de rutas recientes (`RecentRoutesTracker`).

---

## 3. Módulos y Funcionalidades por Dominio

La aplicación está dividida en submódulos especializados para cubrir cada eslabón de la cadena logística y aduanal en México.

### 3.1 Auditoría, Compliance e Inteligencia Artificial (Titan Tier)
- **`SwarmAiScreen` (Auditoría Forense IA):** Permite subir archivos XML de pedimentos VUCEM. El backend (Vertex AI) lee las partidas, detecta anomalías semánticas, fracciones arancelarias incorrectas y calcula multas potenciales esquivadas (en USD). 
- **`RoiDashboardScreen`:** Panel financiero que tabula en tiempo real cuánto dinero le ha ahorrado la IA a la empresa. Muestra tarjetas con "Multas Prevenidas", "Pedimentos Auditados" e historial de alertas críticas.
- **`InvoiceVsPedimentoScreen`:** Herramienta de auditoría cruzada o *cross-match*. Compara un CFDI de factura comercial contra un pedimento para buscar descuadres de valor en aduana.

### 3.2 Operación Aduanera (Regulatory & Despacho)
- **`DespachoHubScreen` / `DespachoScreen`:** Control de estatus de despacho (Previo, Clasificación, Captura, Validación, Pago, Semáforo).
- **`TurnosGaritaScreen`:** Monitorea y proyecta el tiempo en fila/garita de los camiones usando datos en tiempo real.
- **`PreGlosaScreen` / `ValidadorXmlScreen`:** Validación sintáctica de archivos de comercio exterior antes del pago de pedimento.
- **`ComparadorIncotermsScreen`:** Herramienta visual que desglosa las responsabilidades de riesgo y costos entre comprador y vendedor según Incoterms 2020.
- **`M3ForensicsScreen` / `PreValidadorM3Screen`:** Análisis avanzado de los registros M3 (SAAI).
- **`ImmexScreen` / `OeaSeciitScreen`:** Control de saldos, temporalidades y descargos para maquiladoras y empresas certificadas OEA.

### 3.3 Logística, Transporte y Cadena de Suministro
- **`ShipmentTrackerHubScreen` / `NuevoEmbarqueScreen`:** Rastreo de contenedores y guías (marítimas, terrestres, aéreas).
- **`KanbanScreen`:** Tablero ágil para que los ejecutivos muevan sus despachos entre columnas (To Do, In Progress, Done).
- **`SupplierScorecardScreen`:** Califica a los proveedores extranjeros y transportistas según tiempos de entrega, calidad y errores en documentación.
- **`TcoComparatorScreen`:** Calculadora de *Total Cost of Ownership* para comparar si es más barato traer por Long Beach, CA o por Manzanillo, Colima.
- **`DemurrageScreen`:** Calculadora financiera de Demoras de Contenedor y Almacenajes portuarios (evita costos ciegos).

### 3.4 Bóveda de Seguridad SAT / Criptografía
- **`BovedaFielScreen`:** Pantalla hiper-segura para resguardar la FIEL (e.firma) del SAT (.cer, .key, contraseña). Permite firmar documentos aduaneros (VUCEM) desde el celular o web.

### 3.5 Herramientas y Misceláneos
- **`CentroAlertasScreen`:** Panel centralizado de notificaciones (alertas de semáforo rojo, multas inminentes, contenedores detenidos).
- **`CotizadorServiciosScreen` / `UtilidadNetaScreen`:** Calculadoras rápidas para estimar costos de importación antes de hacer la compra en Alibaba/Proveedores.
- **`GlosarioScreen`:** Diccionario de comercio exterior (DTA, PRV, IGI, IVA, IEPS).
- **`SatRadarScreen`:** Monitoreo de listas negras del SAT (EFOS/EDOS) para proteger a la empresa importadora.

---

## 4. Comportamientos UX/UI Especiales

1. **Respuestas Táctiles y Visuales:** Los botones principales (`FilledButton`) cambian su estado a desactivado y muestran `CircularProgressIndicator` del color `gold` cuando hay procesamiento asíncrono (ej. subida de XML).
2. **Manejo Offline (Modo Garita):** Si la app detecta pérdida de red, no muestra pantallas de error feas ("Dinosaurio de Chrome"). La UI sigue funcionando a 60FPS leyendo de la caché local de Firestore, y operaciones en la nube como Swarm AI se deshabilitan elegantemente mostrando un `SnackBar` avisando al usuario.
3. **Manejo de Errores Silenciosos:** Fallas en telemetría o canales nativos están encapsuladas para nunca interrumpir el flujo (navegación o transacciones) del usuario.
