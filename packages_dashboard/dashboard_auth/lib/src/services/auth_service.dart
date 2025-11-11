import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_user_model.dart';

/// Service for Firebase Authentication operations
///
/// Provides methods for user authentication, registration, and management.
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  /// Get the current authenticated user
  User? get currentFirebaseUser => _auth.currentUser;

  /// Check if a user is currently signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get the current authenticated user as AuthUserModel
  Future<AuthUserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Get ID token to access custom claims
    final tokenResult = await user.getIdTokenResult();
    return AuthUserModel.fromFirebaseUser(user, tokenResult.claims);
  }

  /// Sign in with email and password
  ///
  /// Returns an [AuthUserModel] on success.
  /// Throws [FirebaseAuthException] on failure.
  Future<AuthUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found after sign in',
      );
    }

    final tokenResult = await user.getIdTokenResult();
    return AuthUserModel.fromFirebaseUser(user, tokenResult.claims);
  }

  /// Create a new user with email and password
  ///
  /// Returns an [AuthUserModel] on success.
  /// Throws [FirebaseAuthException] on failure.
  Future<AuthUserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-creation-failed',
        message: 'No user found after registration',
      );
    }

    // Update display name if provided
    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }

    final tokenResult = await user.getIdTokenResult();
    return AuthUserModel.fromFirebaseUser(user, tokenResult.claims);
  }

  /// Sign in with a custom token
  ///
  /// Useful for signing in after server-side authentication.
  Future<AuthUserModel> signInWithCustomToken(String token) async {
    final credential = await _auth.signInWithCustomToken(token);

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found after custom token sign in',
      );
    }

    final tokenResult = await user.getIdTokenResult();
    return AuthUserModel.fromFirebaseUser(user, tokenResult.claims);
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in',
      );
    }

    await user.sendEmailVerification();
  }

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in',
      );
    }

    await user.updateDisplayName(displayName);
    await user.reload();
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in',
      );
    }

    await user.verifyBeforeUpdateEmail(newEmail);
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in',
      );
    }

    await user.updatePassword(newPassword);
  }

  /// Reauthenticate user with email and password
  ///
  /// Required before sensitive operations like changing email or password.
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  /// Delete the current user account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in',
      );
    }

    await user.delete();
  }

  /// Reload the current user to get fresh data
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in',
      );
    }

    await user.reload();
  }

  /// Get the current user's ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return await user.getIdToken(forceRefresh);
  }

  /// Get the current user's ID token result with claims
  Future<IdTokenResult?> getIdTokenResult({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return await user.getIdTokenResult(forceRefresh);
  }
}
