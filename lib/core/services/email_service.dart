import 'package:cloud_firestore/cloud_firestore.dart';

class EmailService {
  static EmailService? _instance;
  static EmailService get instance => _instance ??= EmailService._();
  EmailService._();

  final _db = FirebaseFirestore.instance;

  /// Send welcome email after registration
  /// Requires 'Trigger Email from Firestore' Firebase Extension
  Future<void> sendWelcomeEmail({
    required String email,
    required String displayName,
    required String persona,
  }) async {
    try {
      final personaLabel = _getPersonaLabel(persona);
      await _db.collection('mail').add({
        'to': email,
        'template': {
          'name': 'welcome',
          'data': {
            'name': displayName.isNotEmpty ? displayName : 'Importador',
            'persona': personaLabel,
            'app_url': 'https://aduana-801.web.app',
          },
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// Send alert notification email
  Future<void> sendAlertEmail({
    required String email,
    required String alertTitle,
    required String alertBody,
  }) async {
    try {
      await _db.collection('mail').add({
        'to': email,
        'message': {
          'subject': 'Alerta: $alertTitle — Aduanas 801',
          'html': '''
<div style="font-family:sans-serif;max-width:600px;margin:0 auto;background:#0F172A;color:#E2E8F0;padding:32px;border-radius:12px">
  <div style="text-align:center;margin-bottom:24px">
    <span style="font-size:32px">🛡️</span>
    <h1 style="color:#F59E0B;margin:8px 0">Aduanas 801</h1>
  </div>
  <h2 style="color:#F59E0B">Alerta: $alertTitle</h2>
  <p style="color:#94A3B8;line-height:1.6">$alertBody</p>
  <div style="text-align:center;margin-top:32px">
    <a href="https://aduana-801.web.app" style="background:#F59E0B;color:#000;padding:12px 32px;border-radius:8px;text-decoration:none;font-weight:bold">Ver en Aduanas 801</a>
  </div>
</div>
          ''',
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  String _getPersonaLabel(String persona) {
    switch (persona) {
      case 'importador':
        return 'Importador';
      case 'exportador':
        return 'Exportador';
      case 'agente':
        return 'Agente Aduanal';
      default:
        return 'Empezando';
    }
  }
}
