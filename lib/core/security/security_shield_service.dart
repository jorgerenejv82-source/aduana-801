import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SecurityShieldService {
  static Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      final config = TalsecConfig(
        androidConfig: AndroidConfig(
          packageName: 'com.aduana801.app',
          signingCertHashes: ['AK213'], 
        ),
        iosConfig: IOSConfig(
          bundleIds: ['com.aduana801.app'],
          teamId: 'YOUR_TEAM_ID', 
        ),
        watcherMail: 'security@aduana801.com',
      );

      final callback = ThreatCallback(
        onAppIntegrity: () => _handleThreat('App Integrity Compromised'),
        onObfuscationIssues: () => _handleThreat('Obfuscation Issues'),
        onDebug: () => _handleThreat('Debugging Detected'),
        onDeviceBinding: () => _handleThreat('Device Binding Failed'),
        onDeviceID: () => _handleThreat('Device ID Altered'),
        onHooks: () => _handleThreat('Hooking Framework Detected'),
        onPrivilegedAccess: () => _handleThreat('Privileged Access (Root/Jailbreak)'),
        onSecureHardwareNotAvailable: () => log('Secure Hardware Not Available'),
        onSimulator: () => _handleThreat('Running on Simulator'),
        onUnofficialStore: () => _handleThreat('Installed from Unofficial Store'),
      );

      await Talsec.instance.attachListener(callback);
      await Talsec.instance.start(config);
      log('Shield Security initialized');
    } catch (e, stackTrace) {
      log('Failed to initialize Talsec: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  static void _handleThreat(String threat) {
    log('CRITICAL THREAT DETECTED: $threat');
    Sentry.captureMessage('SECURITY THREAT: $threat', level: SentryLevel.fatal);
    exit(0); 
  }
}
