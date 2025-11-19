import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_auth/dashboard_auth.dart';

/// Provider to control whether to skip authentication
/// Can be overridden at app startup based on environment variable
final skipAuthProvider = Provider<bool>((ref) => false);

/// Provider for the authentication service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for current authenticated user
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final skipAuth = ref.watch(skipAuthProvider);
  
  // If skip auth is enabled, always return true
  if (skipAuth) {
    return true;
  }
  
  // Otherwise, check actual auth state
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for auth user model with custom claims
final authUserProvider = FutureProvider<AuthUserModel?>((ref) async {
  final skipAuth = ref.watch(skipAuthProvider);
  
  // If skip auth is enabled, return a mock user
  if (skipAuth) {
    return AuthUserModel(
      uid: 'demo-user-id',
      email: 'demo@fiap.edu.br',
      displayName: 'Demo User',
      emailVerified: true,
      role: 'coordinator', // Default role for demo
    );
  }
  
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  
  // Get ID token to fetch custom claims
  final idTokenResult = await user.getIdTokenResult();
  
  return AuthUserModel(
    uid: user.uid,
    email: user.email ?? '',
    displayName: user.displayName,
    photoURL: user.photoURL,
    emailVerified: user.emailVerified,
    role: (idTokenResult.claims?['role'] as String?) ?? 'user',
    tenantId: idTokenResult.claims?['tenant_id'] as String?,
  );
});
