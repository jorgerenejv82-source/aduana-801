# Aduana 801 - Documento de Arquitectura y Hand-Off (Titan Tier)

> [!IMPORTANT]
> **Instrucción para el Agente Receptor:** Lee este documento en su totalidad antes de realizar modificaciones. Este proyecto tiene una arquitectura estricta (Titan Tier) con análisis de tipos forzado y patrones de seguridad de grado bancario.

## 1. Visión General del Proyecto
**Aduana 801** es un Sistema Inteligente de Gestión Aduanera y Logística para México. Está diseñado para correr en la Web (CanvasKit) y dispositivos móviles, ofreciendo herramientas de cálculo de impuestos (M3, Demoras), auditoría predictiva (Swarm AI) y visibilidad de cadena de suministro.

## 2. Stack Tecnológico
- **Framework:** Flutter (Canal Stable).
- **Lenguaje:** Dart con Linting Estricto (`strict-casts`, `strict-inference`, `strict-raw-types`).
- **Base de Datos & Backend:** Firebase (Firestore, Auth, Hosting, Analytics).
- **Inteligencia Artificial:** Firebase Vertex AI (Gemini Flash).
- **Gestión del Estado:** `provider` (MultiProvider en `main.dart`).
- **Enrutamiento:** `go_router` (`lib/core/router/app_router.dart`).

## 3. Arquitectura de Seguridad (Ciberseguridad)
El proyecto cuenta con un blindaje avanzado (Layer 3):
- **FreeRASP (Talsec):** Implementado en `SecurityShieldService`. Detecta si el dispositivo está rooteado, tiene Jailbreak, corre en emuladores o si hay *hooking* de memoria. Si detecta amenazas, crashea la app intencionalmente.
- **Firebase App Check:** Implementado para evitar peticiones de bots a Firestore.
- **Reglas Multi-Tenant (Firestore):** El archivo `firestore.rules` contiene un comodín de seguridad `match /{collection}/{docId}` que exige que `request.resource.data.userId == request.auth.uid`. Ningún usuario puede leer/escribir datos que no le pertenezcan.
- **Ofuscación:** Se utiliza `flutter build web --release --web-renderer canvaskit` con ofuscación en el entorno de CI/CD.

## 4. Modo Garita (Arquitectura Offline-First)
Dado que las aduanas carecen de buena señal:
- **Caché Ilimitada:** Firestore está configurado en `main.dart` con `persistenceEnabled: true` y `cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED`.
- **NetworkProvider:** Se inyecta `connectivity_plus` vía un Provider global para escuchar cambios de red.
- **Bloqueo Inteligente:** La IA (Vertex AI) no puede correr offline. La pantalla `SwarmAiScreen` intercepta el intento de análisis si el usuario está offline, protegiendo a la app de excepciones.

## 5. Módulo Swarm AI (Auditoría Forense)
- **Implementación:** `AIAuditorService`.
- **Determinismo:** Utiliza `Schema.object` y Tipos Estructurados para forzar a Gemini a devolver un JSON estricto (`AuditReport`). La `temperature` está clavada en `0.1` para evitar alucinaciones.
- **Fallback:** En caso de que el modelo primario falle, existe una ruta de rescate hacia un `_fallbackModel`.
- **Telemetría Inteligente:** Cada vez que la IA emite un dictamen con ahorros financieros, el `_SwarmAiScreenState` guarda un registro silencioso en la colección `ai_metrics` de Firestore.

## 6. Dashboard ROI Financiero
- **Ubicación:** `lib/features/dashboard/roi_dashboard_screen.dart`.
- **Funcionamiento:** Escucha la colección `ai_metrics` en tiempo real (vía `StreamBuilder`) filtrando por el `uid` del agente.
- **Métricas:** Calcula la suma total de dinero salvado (`potentialFinesUSD`), cuenta los pedimentos con Riesgo Alto, y muestra un historial de las alertas semánticas detectadas por Swarm AI.

## 7. Pipeline CI/CD (Integración y Despliegue Continuo)
- **GitHub Actions:** En `.github/workflows/deploy_production.yml`.
- **Gatillo:** Se ejecuta con cada `push` a la rama `main`.
- **Compuerta de Calidad:** Corre `flutter analyze`. Si hay un solo error o advertencia, el pipeline aborta para proteger producción.
- **Deploy:** Usa `FirebaseExtended/action-hosting-deploy` leyendo la llave `FIREBASE_SERVICE_ACCOUNT` de los Secrets del repo.
- **Configuraciones:** `firebase.json` está configurado con caché agresiva (`max-age=31536000`) para recursos estáticos y enruta a `build/web`.

## 8. Telemetría a Prueba de Fallos
- **Servicio:** `AnalyticsService`.
- **Patrón Fire-and-Forget:** Debido a inestabilidades del SDK web de Firebase Analytics (`PlatformException`), **todos** los métodos de telemetría están envueltos en un método privado `_safeLog(() => ...)`. Este método intercepta excepciones y las imprime como `debugPrint`, evitando que la app crashee o congele botones de navegación si un evento falla en enviarse.

## 9. Convenciones Clave para Futuros Desarrollos
- **No uses `dynamic`:** Debido a la configuración estricta, mapea siempre los datos de Firestore. Usa `.toString()`, `(x as num).toDouble()`, etc.
- **Manejo de Contexto:** Usa `if (!mounted) return;` siempre después de un bloque `await` si vas a utilizar el `BuildContext` o hacer `setState`.
- **Widgets:** Siempre prefiere declarar los constructores con `const` (el linter te lo exigirá).
- **Rutas:** Toda pantalla nueva debe registrarse en `app_router.dart` de `go_router`.
