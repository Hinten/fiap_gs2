import 'package:flutter/material.dart';

/// Defines light and dark themes for the FIAP AI-Enhanced Learning Platform.
///
/// Uses Material Design 3 with modern color schemes and typography.
class AppThemes {
  /// Private constructor to prevent instantiation.
  AppThemes._();

  /// Primary color for light theme - Purple/Violet inspired by AI/tech
  static const Color _lightPrimary = Color(0xFF6750A4);

  /// Primary color for dark theme - Lighter purple for better contrast
  static const Color _darkPrimary = Color(0xFFD0BCFF);

  /// Secondary color for both themes - Teal for balance
  static const Color _lightSecondary = Color(0xFF00897B);
  static const Color _darkSecondary = Color(0xFF4DB6AC);

  /// Error color
  static const Color _lightError = Color(0xFFBA1A1A);
  static const Color _darkError = Color(0xFFFFB4AB);

  /// Light theme configuration using Material Design 3
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      brightness: Brightness.light,
      primary: _lightPrimary,
      secondary: _lightSecondary,
      error: _lightError,
    ),

    // AppBar styling
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 2,
    ),

    // Card styling
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    // Floating action button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
    ),

    // Divider
    dividerTheme: const DividerThemeData(space: 1, thickness: 1),
  );

  /// Dark theme configuration using Material Design 3
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _darkPrimary,
      brightness: Brightness.dark,
      primary: _darkPrimary,
      secondary: _darkSecondary,
      error: _darkError,
    ),

    // AppBar styling
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 2,
    ),

    // Card styling
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    // Floating action button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
    ),

    // Divider
    dividerTheme: const DividerThemeData(space: 1, thickness: 1),
  );
}
