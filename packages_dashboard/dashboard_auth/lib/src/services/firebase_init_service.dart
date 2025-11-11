import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for initializing Firebase in Flutter applications
///
/// This service handles Firebase initialization and provides methods
/// to configure Firebase for both production and emulator environments.
class FirebaseInitService {
  static bool _isInitialized = false;
  static bool _isEmulatorConfigured = false;

  /// Check if Firebase has been initialized
  static bool get isInitialized => _isInitialized;

  /// Check if emulator is configured
  static bool get isEmulatorConfigured => _isEmulatorConfigured;

  /// Initialize Firebase with custom configuration
  ///
  /// Example:
  /// ```dart
  /// await FirebaseInitService.initialize(
  ///   apiKey: 'YOUR_API_KEY',
  ///   authDomain: 'your-project.firebaseapp.com',
  ///   projectId: 'your-project-id',
  ///   storageBucket: 'your-project.appspot.com',
  ///   messagingSenderId: '123456789',
  ///   appId: '1:123456789:web:abcdef',
  /// );
  /// ```
  static Future<FirebaseApp> initialize({
    required String apiKey,
    required String authDomain,
    required String projectId,
    required String storageBucket,
    required String messagingSenderId,
    required String appId,
    String? measurementId,
  }) async {
    if (_isInitialized) {
      return Firebase.app();
    }

    final app = await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        authDomain: authDomain,
        projectId: projectId,
        storageBucket: storageBucket,
        messagingSenderId: messagingSenderId,
        appId: appId,
        measurementId: measurementId,
      ),
    );

    _isInitialized = true;
    return app;
  }

  /// Initialize Firebase with default options (for platforms that support it)
  ///
  /// This method uses the default Firebase configuration embedded in the app
  /// (e.g., google-services.json for Android, GoogleService-Info.plist for iOS)
  static Future<FirebaseApp> initializeDefault() async {
    if (_isInitialized) {
      return Firebase.app();
    }

    final app = await Firebase.initializeApp();
    _isInitialized = true;
    return app;
  }

  /// Configure Firebase Auth to use the emulator
  ///
  /// This should be called after Firebase initialization and before any auth operations.
  /// Only use this for local development and testing.
  ///
  /// Example:
  /// ```dart
  /// await FirebaseInitService.initializeDefault();
  /// FirebaseInitService.useAuthEmulator('localhost', 9099);
  /// ```
  ///
  /// Parameters:
  /// - [host]: Emulator host (e.g., 'localhost' or '127.0.0.1')
  /// - [port]: Emulator port (default is 9099 for Auth Emulator)
  static void useAuthEmulator(String host, int port) {
    if (!_isInitialized) {
      throw StateError(
        'Firebase must be initialized before configuring emulator',
      );
    }

    if (_isEmulatorConfigured) {
      // Already configured
      return;
    }

    FirebaseAuth.instance.useAuthEmulator(host, port);
    _isEmulatorConfigured = true;
  }

  /// Initialize Firebase with emulator configuration
  ///
  /// This is a convenience method that combines initialization and emulator setup.
  ///
  /// Example:
  /// ```dart
  /// await FirebaseInitService.initializeWithEmulator(
  ///   projectId: 'demo-test-project',
  ///   emulatorHost: 'localhost',
  ///   emulatorPort: 9099,
  /// );
  /// ```
  static Future<FirebaseApp> initializeWithEmulator({
    required String projectId,
    String emulatorHost = 'localhost',
    int emulatorPort = 9099,
    String apiKey = 'fake-api-key',
    String appId = 'fake-app-id',
  }) async {
    // Initialize with minimal config for emulator
    final app = await initialize(
      apiKey: apiKey,
      authDomain: '$projectId.firebaseapp.com',
      projectId: projectId,
      storageBucket: '$projectId.appspot.com',
      messagingSenderId: '123456789',
      appId: appId,
    );

    // Configure emulator
    useAuthEmulator(emulatorHost, emulatorPort);

    return app;
  }

  /// Reset initialization state (useful for testing)
  static void reset() {
    _isInitialized = false;
    _isEmulatorConfigured = false;
  }
}
