import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

import 'package:provider/provider.dart';
import 'core/providers/dashboard_provider.dart';
import 'core/providers/network_provider.dart';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'core/security/security_shield_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicialización de RASP (Detección de Root, Jailbreak, Emuladores)
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firestore persistence already enabled or failed: $e');
  }

  await SecurityShieldService.initialize();

  // Inicialización de Firebase App Check (Ciberseguridad)
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'), // Reemplazar con clave real
  );
  
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://example@sentry.io/1234567'; // TODO: Replace with real DSN
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ChangeNotifierProvider(create: (_) => NetworkProvider()),
        ],
        child: const Aduana801App(),
      ),
    ),
  );
}

class Aduana801App extends StatelessWidget {
  const Aduana801App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aduanas 801 Enterprise',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
