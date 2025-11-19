import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for different platforms
class FirebaseConfig {
  // Firebase configuration for web platform
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'demo-api-key'),
    appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '1:123456789:web:abc123'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '123456789'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'demo-project'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: 'demo-project.firebaseapp.com'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'demo-project.appspot.com'),
  );

  // Firebase configuration for Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'demo-api-key'),
    appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '1:123456789:android:abc123'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '123456789'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'demo-project'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'demo-project.appspot.com'),
  );

  // Firebase configuration for iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'demo-api-key'),
    appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '1:123456789:ios:abc123'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '123456789'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'demo-project'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'demo-project.appspot.com'),
    iosBundleId: String.fromEnvironment('IOS_BUNDLE_ID', defaultValue: 'com.fiap.dashboard'),
  );

  /// Get platform-specific Firebase options
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }
  
  /// Check if using emulator
  static bool get useEmulator {
    return const bool.fromEnvironment('USE_EMULATOR', defaultValue: true);
  }
  
  /// Emulator host
  static String get emulatorHost {
    return const String.fromEnvironment('EMULATOR_HOST', defaultValue: 'localhost');
  }
}
