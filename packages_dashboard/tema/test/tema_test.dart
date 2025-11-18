import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tema/tema.dart';

void main() {
  // Set up mock SharedPreferences before each test
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TemaNotifier', () {
    test('initializes with system theme mode by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final themeMode = container.read(temaProvider);
      expect(themeMode, ThemeMode.system);
    });

    test('setLight changes theme to light mode', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(temaProvider.notifier).setLight();

      // Wait for state update
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(temaProvider), ThemeMode.light);
    });

    test('setDark changes theme to dark mode', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(temaProvider.notifier).setDark();

      // Wait for state update
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(temaProvider), ThemeMode.dark);
    });

    test('setSystem changes theme to system mode', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // First set to light
      container.read(temaProvider.notifier).setLight();
      await Future.delayed(const Duration(milliseconds: 100));

      // Then set to system
      container.read(temaProvider.notifier).setSystem();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(temaProvider), ThemeMode.system);
    });

    test('toggle switches from light to dark', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set to light
      container.read(temaProvider.notifier).setLight();
      await Future.delayed(const Duration(milliseconds: 100));

      // Toggle
      container.read(temaProvider.notifier).toggle();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(temaProvider), ThemeMode.dark);
    });

    test('toggle switches from dark to light', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set to dark
      container.read(temaProvider.notifier).setDark();
      await Future.delayed(const Duration(milliseconds: 100));

      // Toggle
      container.read(temaProvider.notifier).toggle();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(temaProvider), ThemeMode.light);
    });

    test('persists theme preference to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set to light
      container.read(temaProvider.notifier).setLight();

      // Wait for async save operation
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify it was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('tema_mode'), 'light');
    });

    test('loads theme preference from SharedPreferences', () async {
      // Pre-populate SharedPreferences
      SharedPreferences.setMockInitialValues({'tema_mode': 'dark'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Read the provider to trigger initialization
      container.read(temaProvider);

      // Wait for async load operation
      await Future.delayed(const Duration(milliseconds: 300));

      // Verify it was loaded
      expect(container.read(temaProvider), ThemeMode.dark);
    });

    test(
      'getEffectiveBrightness returns correct brightness for light mode',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(temaProvider.notifier).setLight();

        final brightness = container
            .read(temaProvider.notifier)
            .getEffectiveBrightness();
        expect(brightness, Brightness.light);
      },
    );

    test('getEffectiveBrightness returns correct brightness for dark mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(temaProvider.notifier).setDark();

      final brightness = container
          .read(temaProvider.notifier)
          .getEffectiveBrightness();
      expect(brightness, Brightness.dark);
    });
  });

  group('AppThemes', () {
    test('light theme is configured correctly', () {
      expect(AppThemes.light.brightness, Brightness.light);
      expect(AppThemes.light.useMaterial3, true);
      expect(AppThemes.light.colorScheme.brightness, Brightness.light);
    });

    test('dark theme is configured correctly', () {
      expect(AppThemes.dark.brightness, Brightness.dark);
      expect(AppThemes.dark.useMaterial3, true);
      expect(AppThemes.dark.colorScheme.brightness, Brightness.dark);
    });

    test('light theme has proper AppBar configuration', () {
      expect(AppThemes.light.appBarTheme.elevation, 0);
      expect(AppThemes.light.appBarTheme.centerTitle, true);
      expect(AppThemes.light.appBarTheme.scrolledUnderElevation, 2);
    });

    test('dark theme has proper AppBar configuration', () {
      expect(AppThemes.dark.appBarTheme.elevation, 0);
      expect(AppThemes.dark.appBarTheme.centerTitle, true);
      expect(AppThemes.dark.appBarTheme.scrolledUnderElevation, 2);
    });

    test('light theme has proper Card configuration', () {
      expect(AppThemes.light.cardTheme.elevation, 1);
      expect(AppThemes.light.cardTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('dark theme has proper Card configuration', () {
      expect(AppThemes.dark.cardTheme.elevation, 1);
      expect(AppThemes.dark.cardTheme.shape, isA<RoundedRectangleBorder>());
    });
  });
}
