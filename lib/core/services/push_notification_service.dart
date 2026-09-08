import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PushNotificationService {
  static PushNotificationService? _instance;
  static PushNotificationService get instance =>
      _instance ??= PushNotificationService._();
  PushNotificationService._();

  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token and save to Firestore
        final token = await _messaging.getToken(
          vapidKey:
              'YOUR_VAPID_KEY_HERE', // Replace with actual VAPID key from Firebase Console
        );
        if (token != null) await _saveToken(token);

        // Listen for token refresh
        _messaging.onTokenRefresh.listen(_saveToken);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      }
    } catch (_) {}
  }

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {'fcm_token': token, 'fcm_updated': FieldValue.serverTimestamp()},
          SetOptions(merge: true));
    } catch (_) {}
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // In a real app, show in-app notification banner
    // For now, just print
  }

  Future<void> showPermissionDialogIfNeeded(context) async {
    // Only ask once
    final settings = await _messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      await initialize();
    }
  }
}
