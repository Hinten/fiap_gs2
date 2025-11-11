import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dashboard_auth/dashboard_auth.dart';

/// Tests for Firebase Auth using Firebase Emulator
///
/// These tests run against the Firebase Auth Emulator and validate:
/// - User registration and login
/// - Token-based authentication
/// - User management operations
/// - Custom claims handling
///
/// Requirements:
/// - Firebase Auth Emulator must be running on localhost:9099
/// - Start with: firebase emulators:start --only auth --project demo-test-project
///
/// Run tests with:
/// ```bash
/// flutter test test/auth_emulator_test.dart
/// ```

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Firebase with emulator configuration
    await FirebaseInitService.initializeWithEmulator(
      projectId: 'demo-test-project',
      emulatorHost: 'localhost',
      emulatorPort: 9099,
    );
  });

  group('FirebaseInitService', () {
    test('should initialize Firebase for emulator', () {
      expect(FirebaseInitService.isInitialized, true);
      expect(FirebaseInitService.isEmulatorConfigured, true);
    });

    test('should have Firebase app instance', () {
      final app = Firebase.app();
      expect(app, isNotNull);
      expect(app.options.projectId, 'demo-test-project');
    });
  });

  group('AuthService - User Creation and Authentication', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    tearDown(() async {
      // Sign out after each test
      if (authService.isSignedIn) {
        await authService.signOut();
      }
    });

    test('should create a new user with email and password', () async {
      final email = 'test-${DateTime.now().millisecondsSinceEpoch}@example.com';
      final password = 'testPassword123';

      final user = await authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: 'Test User',
      );

      expect(user, isNotNull);
      expect(user.email, email);
      expect(user.displayName, 'Test User');
      expect(user.uid, isNotEmpty);

      // Cleanup
      await authService.deleteAccount();
    });

    test('should sign in with email and password', () async {
      final email = 'signin-${DateTime.now().millisecondsSinceEpoch}@example.com';
      final password = 'signinPassword123';

      // Create user
      await authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sign out
      await authService.signOut();
      expect(authService.isSignedIn, false);

      // Sign in
      final user = await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      expect(user, isNotNull);
      expect(user.email, email);
      expect(authService.isSignedIn, true);

      // Cleanup
      await authService.deleteAccount();
    });

    test('should throw error for invalid credentials', () async {
      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'nonexistent@example.com',
          password: 'wrongPassword',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('should check if user is signed in', () async {
      expect(authService.isSignedIn, false);

      final email = 'check-${DateTime.now().millisecondsSinceEpoch}@example.com';
      await authService.createUserWithEmailAndPassword(
        email: email,
        password: 'password123',
      );

      expect(authService.isSignedIn, true);

      await authService.signOut();
      expect(authService.isSignedIn, false);
    });
  });

  group('AuthService - User Management', () {
    late AuthService authService;
    late String testEmail;

    setUp(() async {
      authService = AuthService();
      testEmail = 'manage-${DateTime.now().millisecondsSinceEpoch}@example.com';

      // Create a test user
      await authService.createUserWithEmailAndPassword(
        email: testEmail,
        password: 'password123',
      );
    });

    tearDown(() async {
      if (authService.isSignedIn) {
        await authService.deleteAccount();
      }
    });

    test('should get current user', () async {
      final user = await authService.getCurrentUser();

      expect(user, isNotNull);
      expect(user!.email, testEmail);
      expect(user.uid, isNotEmpty);
    });

    test('should update display name', () async {
      await authService.updateDisplayName('Updated Name');
      await authService.reloadUser();

      final user = await authService.getCurrentUser();
      expect(user!.displayName, 'Updated Name');
    });

    test('should send email verification', () async {
      // This should not throw an error in emulator
      await authService.sendEmailVerification();

      // In emulator, we can't actually verify the email was sent
      // but we can verify the method completes successfully
      expect(true, true);
    });

    test('should get ID token', () async {
      final token = await authService.getIdToken();

      expect(token, isNotNull);
      expect(token, isNotEmpty);
    });

    test('should get ID token result with claims', () async {
      final tokenResult = await authService.getIdTokenResult();

      expect(tokenResult, isNotNull);
      expect(tokenResult!.claims, isNotNull);
    });

    test('should sign out user', () async {
      expect(authService.isSignedIn, true);

      await authService.signOut();

      expect(authService.isSignedIn, false);
    });
  });

  group('AuthUserModel', () {
    test('should create from Firebase user', () {
      // This is a simplified test since we can't easily mock Firebase User
      final user = AuthUserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        role: 'user',
      );

      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.role, 'user');
    });

    test('should check roles correctly', () {
      final userUser = AuthUserModel(
        uid: 'test-uid',
        email: 'user@example.com',
        role: 'user',
      );

      final adminUser = AuthUserModel(
        uid: 'admin-uid',
        email: 'admin@example.com',
        role: 'admin',
      );

      expect(userUser.hasRole('user'), true);
      expect(userUser.hasRole('admin'), false);

      expect(adminUser.hasRole('user'), true); // Admins have all roles
      expect(adminUser.hasRole('admin'), true);
    });

    test('should check multiple roles', () {
      final teacherUser = AuthUserModel(
        uid: 'teacher-uid',
        email: 'teacher@example.com',
        role: 'teacher',
      );

      expect(teacherUser.hasAnyRole(['teacher', 'admin']), true);
      expect(teacherUser.hasAnyRole(['student', 'admin']), false);
    });

    test('should convert to and from JSON', () {
      final user = AuthUserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        role: 'user',
        tenantId: 'tenant-123',
      );

      final json = user.toJson();
      final fromJson = AuthUserModel.fromJson(json);

      expect(fromJson.uid, user.uid);
      expect(fromJson.email, user.email);
      expect(fromJson.displayName, user.displayName);
      expect(fromJson.role, user.role);
      expect(fromJson.tenantId, user.tenantId);
    });
  });

  group('Password Reset', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should send password reset email', () async {
      final email = 'reset-${DateTime.now().millisecondsSinceEpoch}@example.com';

      // Create user first
      await authService.createUserWithEmailAndPassword(
        email: email,
        password: 'password123',
      );

      // Sign out
      await authService.signOut();

      // Send password reset email (in emulator, this won't actually send)
      await authService.sendPasswordResetEmail(email);

      // If no exception is thrown, the test passes
      expect(true, true);
    });
  });
}
