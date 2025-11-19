import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dashboard_auth/dashboard_auth.dart';
import 'package:tema/tema.dart';

import 'src/config/firebase_config.dart';
import 'src/core/routing/router.dart';
import 'src/core/auth/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseConfig.currentPlatform,
  );
  
  // Check if running with skip auth flag
  const bool skipAuth = bool.fromEnvironment('SKIP_AUTH', defaultValue: false);
  
  runApp(
    ProviderScope(
      overrides: [
        // Override skipAuth setting
        skipAuthProvider.overrideWith((ref) => skipAuth),
      ],
      child: const FiapDashboardApp(),
    ),
  );
}

class FiapDashboardApp extends ConsumerWidget {
  const FiapDashboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(temaProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FIAP AI-Enhanced Learning Platform',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
