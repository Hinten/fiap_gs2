import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_provider.dart';
import '../../screens/home_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/research_screen.dart';
import '../../screens/content_review_screen.dart';
import '../../screens/approval_screen.dart';
import '../../screens/wellbeing_screen.dart';
import '../../screens/adaptive_assessment_screen.dart';

/// Router provider with authentication guard
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && state.matchedLocation != '/login') {
        return '/login';
      }
      
      // If authenticated and on login page, redirect to home
      if (isAuthenticated && state.matchedLocation == '/login') {
        return '/';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/research',
        builder: (context, state) => const ResearchScreen(),
      ),
      GoRoute(
        path: '/content-review',
        builder: (context, state) => const ContentReviewScreen(),
      ),
      GoRoute(
        path: '/approval',
        builder: (context, state) => const ApprovalScreen(),
      ),
      GoRoute(
        path: '/wellbeing',
        builder: (context, state) => const WellbeingScreen(),
      ),
      GoRoute(
        path: '/adaptive-assessment',
        builder: (context, state) => const AdaptiveAssessmentScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
