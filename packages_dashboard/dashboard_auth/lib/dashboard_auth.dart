/// Firebase Authentication package for Flutter frontend in FIAP AI-Enhanced Learning Platform
///
/// This package provides Firebase Authentication functionality including:
/// - Firebase initialization for production and emulator environments
/// - Authentication service with email/password support
/// - Role-Based Access Control (RBAC) through custom claims
/// - User management operations
library dashboard_auth;

// Export models
export 'src/models/auth_user_model.dart';

// Export services
export 'src/services/firebase_init_service.dart';
export 'src/services/auth_service.dart';

// Re-export Firebase Auth types for convenience
export 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException, User;
export 'package:firebase_core/firebase_core.dart' show FirebaseApp, Firebase;
