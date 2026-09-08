import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/constants/firestore_collections.dart';
import 'alert_model.dart';

class AlertsEngine {
  static final AlertsEngine _instance = AlertsEngine._internal();
  factory AlertsEngine() => _instance;
  AlertsEngine._internal();

  bool _initialized = false;

  /// Call this once from home_screen.dart initState
  Future<void> initialize(BuildContext context, String userPersona) async {
    if (_initialized) return;
    _initialized = true;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Run all checks
    await Future.wait([
      _checkFielVigencia(context, uid),
      _checkNomVigencias(uid),
      _checkPoRetrasadas(uid),
      _checkEmbarquesVencidos(uid),
      if (userPersona == 'agente' || userPersona == 'exportador')
        _checkImmexClientes(uid),
    ]);
  }

  // --------------------------------------------------------
  // 1. FIEL / e.firma vigencia
  // --------------------------------------------------------
  Future<void> _checkFielVigencia(BuildContext context, String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateStr = prefs.getString('fiel_vigencia_date');
      if (dateStr == null) return;

      final vigencia = DateTime.tryParse(dateStr);
      if (vigencia == null) return;

      final days = vigencia.difference(DateTime.now()).inDays;

      String? title;
      String? body;
      AlertSeverity severity = AlertSeverity.warning;

      if (days < 0) {
        title = '⚠️ e.firma/FIEL VENCIDA';
        body =
            'Tu e.firma venció hace ${-days} días. Renueva urgentemente en el SAT para evitar problemas en despachos.';
        severity = AlertSeverity.critical;
      } else if (days <= 7) {
        title = '🚨 e.firma vence en $days días';
        body =
            'Renueva tu e.firma/FIEL antes del ${_formatDate(vigencia)}. Sin ella no puedes firmar pedimentos.';
        severity = AlertSeverity.critical;
      } else if (days <= 30) {
        title = '⏰ e.firma vence en $days días';
        body =
            'Agenda tu renovación en el SAT. Vigencia hasta: ${_formatDate(vigencia)}';
        severity = AlertSeverity.warning;
      } else {
        return; // No alert needed
      }

      await _saveAlert(
          uid,
          AlertModel(
            id: '',
            uid: uid,
            title: title,
            body: body,
            severity: severity,
            category: AlertCategory.fiel,
            route: '/home',
            createdAt: DateTime.now(),
            dedupeKey: 'fiel_$days',
          ));

      // Show critical toast in-app
      if (!context.mounted) return;
      if (severity == AlertSeverity.critical) {
        AppToast.warning(context, title);
      }
    } catch (_) {}
  }

  // --------------------------------------------------------
  // 2. NOMs por vencer
  // --------------------------------------------------------
  Future<void> _checkNomVigencias(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.nomVigencias)
          .where('uid', isEqualTo: uid)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        DateTime? vigencia;

        // Handle both Timestamp and String formats
        final rawDate = data['fechaVigencia'];
        if (rawDate is Timestamp) {
          vigencia = rawDate.toDate();
        } else if (rawDate is String) {
          vigencia = DateTime.tryParse(rawDate);
        }

        if (vigencia == null) continue;

        final days = vigencia.difference(DateTime.now()).inDays;
        final nom = data['nom'] ?? 'NOM desconocida';
        final producto = data['producto'] ?? '';

        if (days < 0) {
          await _saveAlert(
              uid,
              AlertModel(
                id: '',
                uid: uid,
                title: '🔴 NOM Vencida: $nom',
                body:
                    'La NOM para $producto venció hace ${-days} días. Renueva antes de tu próxima importación.',
                severity: AlertSeverity.critical,
                category: AlertCategory.nom,
                route: '/nom_calendar',
                createdAt: DateTime.now(),
                dedupeKey: 'nom_${doc.id}_vencida',
              ));
        } else if (days <= 30) {
          await _saveAlert(
              uid,
              AlertModel(
                id: '',
                uid: uid,
                title: '🟡 NOM vence en $days días: $nom',
                body:
                    '$producto · Vigencia hasta ${_formatDate(vigencia)}. Inicia el trámite de renovación.',
                severity: AlertSeverity.warning,
                category: AlertCategory.nom,
                route: '/nom_calendar',
                createdAt: DateTime.now(),
                dedupeKey: 'nom_${doc.id}_$days',
              ));
        } else if (days <= 90) {
          await _saveAlert(
              uid,
              AlertModel(
                id: '',
                uid: uid,
                title: 'ℹ️ NOM vence en $days días: $nom',
                body:
                    'Programa la renovación de $nom para $producto antes de ${_formatDate(vigencia)}.',
                severity: AlertSeverity.info,
                category: AlertCategory.nom,
                route: '/nom_calendar',
                createdAt: DateTime.now(),
                dedupeKey: 'nom_${doc.id}_90d',
              ));
        }
      }
    } catch (_) {}
  }

  // --------------------------------------------------------
  // 3. POs retrasadas
  // --------------------------------------------------------
  Future<void> _checkPoRetrasadas(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.purchaseOrders)
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: 'PENDING')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawDate = data['expectedDelivery'];
        if (rawDate == null) continue;

        DateTime? expected;
        if (rawDate is Timestamp) {
          expected = rawDate.toDate();
        } else if (rawDate is String) {
          expected = DateTime.tryParse(rawDate);
        }
        if (expected == null) continue;

        final daysLate = DateTime.now().difference(expected).inDays;
        if (daysLate <= 0) continue; // not late

        final poNumber = data['poNumber'] ?? doc.id;
        final supplier = data['supplierName'] ?? 'Proveedor desconocido';

        await _saveAlert(
            uid,
            AlertModel(
              id: '',
              uid: uid,
              title: '📦 PO Retrasada: $poNumber',
              body:
                  '$supplier lleva $daysLate días de retraso. Contacta al proveedor para actualizar el estatus.',
              severity: daysLate > 14
                  ? AlertSeverity.critical
                  : AlertSeverity.warning,
              category: AlertCategory.po,
              route: '/supply_chain/po',
              createdAt: DateTime.now(),
              dedupeKey: 'po_${doc.id}_late_${DateTime.now().day}',
            ));
      }
    } catch (_) {}
  }

  // --------------------------------------------------------
  // 4. Embarques con ETA vencida
  // --------------------------------------------------------
  Future<void> _checkEmbarquesVencidos(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.embarques)
          .where('uid', isEqualTo: uid)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? data['estado'] ?? '';
        if (status == 'liberado' || status == 'entregado') continue;

        final rawEta = data['eta'] ?? data['etaFecha'];
        if (rawEta == null) continue;

        DateTime? eta;
        if (rawEta is Timestamp) {
          eta = rawEta.toDate();
        } else if (rawEta is String) {
          eta = DateTime.tryParse(rawEta);
        }
        if (eta == null) continue;

        final daysLate = DateTime.now().difference(eta).inDays;
        if (daysLate <= 0) continue;

        final container =
            data['containerNumber'] ?? data['contenedor'] ?? doc.id;

        await _saveAlert(
            uid,
            AlertModel(
              id: '',
              uid: uid,
              title: '🚢 Embarque con ETA vencida: $container',
              body:
                  'ETA venció hace $daysLate días. Contacta a tu agente de carga para actualizar la información.',
              severity: AlertSeverity.warning,
              category: AlertCategory.embarque,
              route: '/shipment_tracker',
              createdAt: DateTime.now(),
              dedupeKey: 'embarque_${doc.id}_eta_${DateTime.now().day}',
            ));
      }
    } catch (_) {}
  }

  // --------------------------------------------------------
  // 5. Clientes con IMMEX por vencer (agente only)
  // --------------------------------------------------------
  Future<void> _checkImmexClientes(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.clientesCrm)
          .where('uid', isEqualTo: uid)
          .where('hasImmex', isEqualTo: true)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawDate = data['immexVigencia'];
        if (rawDate == null) continue;

        DateTime? vigencia;
        if (rawDate is Timestamp) {
          vigencia = rawDate.toDate();
        } else if (rawDate is String) {
          vigencia = DateTime.tryParse(rawDate);
        }
        if (vigencia == null) continue;

        final days = vigencia.difference(DateTime.now()).inDays;
        final clientName = data['nombre'] ?? 'Cliente';

        if (days < 0) {
          await _saveAlert(
              uid,
              AlertModel(
                id: '',
                uid: uid,
                title: '🚨 IMMEX Vencido: $clientName',
                body:
                    'El programa IMMEX de $clientName venció hace ${-days} días. Suspende importaciones temporales urgentemente.',
                severity: AlertSeverity.critical,
                category: AlertCategory.immex,
                route: '/clientes',
                createdAt: DateTime.now(),
                dedupeKey: 'immex_${doc.id}_vencido',
              ));
        } else if (days <= 90) {
          await _saveAlert(
              uid,
              AlertModel(
                id: '',
                uid: uid,
                title: '⏰ IMMEX vence en $days días: $clientName',
                body:
                    'Inicia el proceso de renovación de IMMEX para $clientName antes del ${_formatDate(vigencia)}.',
                severity:
                    days <= 30 ? AlertSeverity.critical : AlertSeverity.warning,
                category: AlertCategory.immex,
                route: '/clientes',
                createdAt: DateTime.now(),
                dedupeKey: 'immex_${doc.id}_${days ~/ 30}months',
              ));
        }
      }
    } catch (_) {}
  }

  // --------------------------------------------------------
  // Helpers
  // --------------------------------------------------------

  /// Save alert to Firestore with deduplication (only once per day per dedupeKey)
  Future<void> _saveAlert(String uid, AlertModel alert) async {
    try {
      // Check if same alert already exists today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final existing = await FirebaseFirestore.instance
          .collection(FirestoreCollections.notificaciones)
          .where('uid', isEqualTo: uid)
          .where('dedupeKey', isEqualTo: alert.dedupeKey)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) return; // already exists today

      await FirebaseFirestore.instance
          .collection(FirestoreCollections.notificaciones)
          .add(alert.toMap());
    } catch (_) {}
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Call this to reset initialization (e.g., on logout)
  void reset() => _initialized = false;
}
