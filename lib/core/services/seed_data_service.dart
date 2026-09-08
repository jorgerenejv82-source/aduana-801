import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/firestore_collections.dart';

class SeedDataService {
  SeedDataService._();
  static final SeedDataService instance = SeedDataService._();

  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeeded = prefs.getBool('seed_data_created') ?? false;

    if (hasSeeded) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    // A) IMMEX Inventario
    final immexColl = db.collection(FirestoreCollections.immexInventario);

    // Saldo 1 - OK
    batch.set(immexColl.doc(), {
      'pedimentoImportacion': '24  48  3001234',
      'fraccion': '8471.30.01',
      'cantidadInicial': 500.0,
      'cantidadRestante': 320.0,
      'fechaEntrada':
          DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      'fechaVencimiento':
          DateTime.now().add(const Duration(days: 450)).toIso8601String(),
      'historial': <dynamic>[],
      'uid': uid,
      'esDemoData': true,
    });

    // Saldo 2 - En Riesgo
    batch.set(immexColl.doc(), {
      'pedimentoImportacion': '24  48  3001235',
      'fraccion': '8523.49.01',
      'cantidadInicial': 200.0,
      'cantidadRestante': 45.0,
      'fechaEntrada':
          DateTime.now().subtract(const Duration(days: 510)).toIso8601String(),
      'fechaVencimiento':
          DateTime.now().add(const Duration(days: 20)).toIso8601String(),
      'historial': <dynamic>[],
      'uid': uid,
      'esDemoData': true,
    });

    // Saldo 3 - Vencido
    batch.set(immexColl.doc(), {
      'pedimentoImportacion': '24  48  3001230',
      'fraccion': '3926.90.99',
      'cantidadInicial': 1000.0,
      'cantidadRestante': 150.0,
      'fechaEntrada':
          DateTime.now().subtract(const Duration(days: 600)).toIso8601String(),
      'fechaVencimiento':
          DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      'historial': <dynamic>[],
      'uid': uid,
      'esDemoData': true,
    });

    // B) Notificaciones
    final notifColl = db.collection(FirestoreCollections.notificaciones);

    batch.set(notifColl.doc(), {
      'uid': uid,
      'titulo': '⚠️ IMMEX próximo a vencer',
      'mensaje':
          'La fracción 8523.49.01 del pedimento 24 48 3001235 vence en 20 días.',
      'tipo': 'immex_vencimiento',
      'read': false,
      'createdAt': Timestamp.now(),
    });

    batch.set(notifColl.doc(), {
      'uid': uid,
      'titulo': '🔴 IMMEX Vencido',
      'mensaje':
          'La fracción 3926.90.99 del pedimento 24 48 3001230 venció hace 60 días. Regulariza ante el SAT.',
      'tipo': 'immex_vencido',
      'read': false,
      'createdAt': Timestamp.now(),
    });

    batch.set(notifColl.doc(), {
      'uid': uid,
      'titulo': '✅ Bienvenido a Aduanas 801',
      'mensaje':
          'Tu cuenta está lista. Estos son datos de ejemplo para que explores la app.',
      'tipo': 'bienvenida',
      'read': false,
      'createdAt': Timestamp.now(),
    });

    // C) CRM Clients
    final crmColl = db.collection(FirestoreCollections.clientesCrm);
    batch.set(crmColl.doc(), {
      'uid': uid,
      'nombre': 'Importadora de Tecnología SA de CV',
      'rfc': 'ITE123456789',
      'contacto': 'Ana Pérez',
      'email': 'ana@importec.com',
      'esDemoData': true,
      'createdAt': Timestamp.now(),
    });

    batch.set(crmColl.doc(), {
      'uid': uid,
      'nombre': 'Maquiladora Frontera Norte S. de R.L.',
      'rfc': 'MFN987654321',
      'contacto': 'Carlos Gómez',
      'email': 'cgomez@frontera.com',
      'esDemoData': true,
      'createdAt': Timestamp.now(),
    });

    await batch.commit();
    await prefs.setBool('seed_data_created', true);
  }
}
