import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firestore_collections.dart';

enum DashboardState { initial, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  DashboardState _state = DashboardState.initial;
  DashboardState get state => _state;

  int _embarquesActivos = 0;
  int get embarquesActivos => _embarquesActivos;

  int _expedientesPendientes = 0;
  int get expedientesPendientes => _expedientesPendientes;

  final int _alertasDia = 3; // Mock value as in original
  int get alertasDia => _alertasDia;

  int _immexAlertsCount = 0;
  int get immexAlertsCount => _immexAlertsCount;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  StreamSubscription<QuerySnapshot>? _pedimentosSub;
  StreamSubscription<QuerySnapshot>? _immexSub;

  DashboardProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _startListening(user.uid);
      } else {
        _stopListening();
      }
    });
  }

  void _startListening(String uid) {
    if (_state == DashboardState.loading) return;
    _state = DashboardState.loading;
    notifyListeners();

    _pedimentosSub?.cancel();
    _pedimentosSub = FirebaseFirestore.instance
        .collection('pedimentos')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots(includeMetadataChanges: true) // For offline capability
        .listen((snapshot) {
      _expedientesPendientes = snapshot.docs.length;
      _embarquesActivos = snapshot.docs.where((doc) {
        final data = doc.data();
        return (data['status']?.toString().toLowerCase() ?? '') != 'liberado';
      }).length;

      _state = DashboardState.loaded;
      notifyListeners();
    }, onError: (Object error) {
      _state = DashboardState.error;
      _errorMsg = error.toString();
      notifyListeners();
    });

    _immexSub?.cancel();
    _immexSub = FirebaseFirestore.instance
        .collection(FirestoreCollections.clientesCrm)
        .where('uid', isEqualTo: uid)
        .where('hasImmex', isEqualTo: true)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      int alertCount = 0;
      final now = DateTime.now();
      final limit = now.add(const Duration(days: 60));
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final vigStr = data['immexVigencia'] as String?;
        if (vigStr != null) {
          final vig = DateTime.tryParse(vigStr);
          if (vig != null && vig.isBefore(limit)) {
            alertCount++;
          }
        }
      }
      _immexAlertsCount = alertCount;
      notifyListeners();
    });
  }

  void _stopListening() {
    _pedimentosSub?.cancel();
    _pedimentosSub = null;
    _immexSub?.cancel();
    _immexSub = null;

    _embarquesActivos = 0;
    _expedientesPendientes = 0;
    _immexAlertsCount = 0;
    _state = DashboardState.initial;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}
