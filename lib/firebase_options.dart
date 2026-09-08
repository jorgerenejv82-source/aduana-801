// File generated for Aduanas 801 Enterprise
// Firebase project: aduana-801
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
            'DefaultFirebaseOptions have not been configured for macOS.');
      case TargetPlatform.windows:
        throw UnsupportedError(
            'DefaultFirebaseOptions have not been configured for Windows.');
      case TargetPlatform.linux:
        throw UnsupportedError(
            'DefaultFirebaseOptions have not been configured for Linux.');
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAQYGDT-gGVONwcCDlcaYoY5WfqgNwWP00',
    appId: '1:245622344505:web:703841c95a307a153936e8',
    messagingSenderId: '245622344505',
    projectId: 'aduana-801',
    authDomain: 'aduana-801.firebaseapp.com',
    storageBucket: 'aduana-801.firebasestorage.app',
    measurementId: 'G-VWHJCRFQQ1',
  );

  // Android: register your app in Firebase Console and replace appId
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQYGDT-gGVONwcCDlcaYoY5WfqgNwWP00',
    appId: '1:245622344505:android:REPLACE_WITH_ANDROID_APP_ID',
    messagingSenderId: '245622344505',
    projectId: 'aduana-801',
    storageBucket: 'aduana-801.firebasestorage.app',
  );

  // iOS: register your app in Firebase Console and replace appId + bundleId
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQYGDT-gGVONwcCDlcaYoY5WfqgNwWP00',
    appId: '1:245622344505:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '245622344505',
    projectId: 'aduana-801',
    storageBucket: 'aduana-801.firebasestorage.app',
    iosBundleId: 'com.aduana801.enterprise',
  );
}
