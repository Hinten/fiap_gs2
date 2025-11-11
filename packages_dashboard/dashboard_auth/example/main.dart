import 'package:flutter/material.dart';
import 'package:dashboard_auth/dashboard_auth.dart';

/// Firebase Auth Emulator Example App
///
/// This example demonstrates how to use Firebase Authentication with the
/// Firebase Emulator in a Flutter application.
///
/// Prerequisites:
/// 1. Start Firebase Auth Emulator:
///    firebase emulators:start --only auth --project demo-test-project
///
/// 2. Run this example:
///    cd example
///    flutter run -d chrome (or any other device)
///
/// Features demonstrated:
/// - User registration
/// - User sign in
/// - User sign out
/// - Display current user info
/// - Token retrieval

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with emulator
  await FirebaseInitService.initializeWithEmulator(
    projectId: 'demo-test-project',
    emulatorHost: 'localhost',
    emulatorPort: 9099,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Emulator Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthDemoPage(),
    );
  }
}

class AuthDemoPage extends StatefulWidget {
  const AuthDemoPage({super.key});

  @override
  State<AuthDemoPage> createState() => _AuthDemoPageState();
}

class _AuthDemoPageState extends State<AuthDemoPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  AuthUserModel? _currentUser;
  String _status = 'Ready';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();

    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      _loadCurrentUser();
    });
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _setStatus('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _displayNameController.text.isEmpty
            ? null
            : _displayNameController.text,
      );

      _setStatus('✅ Registered successfully! UID: ${user.uid}');
      _clearFields();
    } on FirebaseAuthException catch (e) {
      _setStatus('❌ Registration failed: ${e.message}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _setStatus('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      _setStatus('✅ Signed in successfully! UID: ${user.uid}');
      _clearFields();
    } on FirebaseAuthException catch (e) {
      _setStatus('❌ Sign in failed: ${e.message}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signOut();
      _setStatus('✅ Signed out successfully');
    } catch (e) {
      _setStatus('❌ Sign out failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getToken() async {
    setState(() => _isLoading = true);

    try {
      final token = await _authService.getIdToken();
      if (token != null) {
        _setStatus('✅ Token: ${token.substring(0, 50)}...');
      } else {
        _setStatus('❌ No token available (not signed in)');
      }
    } catch (e) {
      _setStatus('❌ Failed to get token: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setStatus(String status) {
    setState(() => _status = status);
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _displayNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth Emulator Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Emulator Info Card
            Card(
              color: Colors.amber.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade900),
                        const SizedBox(width: 8),
                        Text(
                          'Using Firebase Emulator',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connected to localhost:9099',
                      style: TextStyle(color: Colors.amber.shade900),
                    ),
                    Text(
                      'Project: demo-test-project',
                      style: TextStyle(color: Colors.amber.shade900),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Current User Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    if (_currentUser != null) ...[
                      _buildInfoRow('UID', _currentUser!.uid),
                      _buildInfoRow('Email', _currentUser!.email),
                      if (_currentUser!.displayName != null)
                        _buildInfoRow('Name', _currentUser!.displayName!),
                      _buildInfoRow('Role', _currentUser!.role),
                      _buildInfoRow(
                        'Email Verified',
                        _currentUser!.emailVerified.toString(),
                      ),
                    ] else
                      const Text('Not signed in', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Auth Form Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Authentication',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _register,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Register'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _signIn,
                          icon: const Icon(Icons.login),
                          label: const Text('Sign In'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading || _currentUser == null
                              ? null
                              : _signOut,
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading || _currentUser == null
                              ? null
                              : _getToken,
                          icon: const Icon(Icons.token),
                          label: const Text('Get Token'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
}
