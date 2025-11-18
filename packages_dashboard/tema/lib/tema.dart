/// Theme package with light/dark themes and provider for theme management.
///
/// This package provides theme definitions and a provider for managing
/// application themes in the FIAP AI-Enhanced Learning Platform.
///
/// ## Features
///
/// - Modern Material Design 3 light and dark themes
/// - Theme provider using Riverpod for state management
/// - System theme detection and automatic switching
/// - Theme preference persistence using SharedPreferences
/// - Easy theme toggling between light, dark, and system modes
///
/// ## Usage
///
/// 1. Wrap your app with ProviderScope:
/// ```dart
/// void main() {
///   runApp(
///     const ProviderScope(
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
///
/// 2. Use the theme provider in your MaterialApp:
/// ```dart
/// class MyApp extends ConsumerWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final themeMode = ref.watch(temaProvider);
///
///     return MaterialApp(
///       title: 'FIAP App',
///       theme: AppThemes.light,
///       darkTheme: AppThemes.dark,
///       themeMode: themeMode,
///       home: const HomePage(),
///     );
///   }
/// }
/// ```
///
/// 3. Control the theme from anywhere in your app:
/// ```dart
/// // In a ConsumerWidget or using Consumer
/// ref.read(temaProvider.notifier).setLight();   // Set light theme
/// ref.read(temaProvider.notifier).setDark();    // Set dark theme
/// ref.read(temaProvider.notifier).setSystem();  // Follow system theme
/// ref.read(temaProvider.notifier).toggle();     // Toggle between light/dark
/// ```
library tema;

// Export theme provider
export 'src/tema_provider.dart';

// Export theme definitions
export 'src/themes.dart';
