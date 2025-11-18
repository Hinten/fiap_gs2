import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for theme management state.
///
/// This provider manages the application's theme mode (light, dark, or system)
/// and handles persistence of user preferences.
///
/// Usage:
/// ```dart
/// // Read the current theme mode
/// final mode = ref.watch(temaProvider);
///
/// // Change theme mode
/// ref.read(temaProvider.notifier).setLight();
/// ref.read(temaProvider.notifier).setDark();
/// ref.read(temaProvider.notifier).setSystem();
/// ref.read(temaProvider.notifier).toggle();
/// ```
final temaProvider = NotifierProvider<TemaNotifier, ThemeMode>(
  TemaNotifier.new,
);

/// Notifier for managing theme state.
///
/// Handles theme mode changes, system theme detection, and persistence.
class TemaNotifier extends Notifier<ThemeMode> {
  static const String _prefKey = 'tema_mode';

  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.system;
  }

  /// Loads the saved theme mode from SharedPreferences.
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefKey);

      if (savedMode != null) {
        switch (savedMode) {
          case 'light':
            state = ThemeMode.light;
            break;
          case 'dark':
            state = ThemeMode.dark;
            break;
          case 'system':
            state = ThemeMode.system;
            break;
          default:
            state = ThemeMode.system;
        }
      }
    } catch (e) {
      // If loading fails, keep system theme as default
      debugPrint('Error loading theme mode: $e');
    }
  }

  /// Saves the theme mode to SharedPreferences.
  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String modeString;

      switch (mode) {
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }

      await prefs.setString(_prefKey, modeString);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Sets the theme to light mode.
  void setLight() {
    state = ThemeMode.light;
    _saveThemeMode(ThemeMode.light);
  }

  /// Sets the theme to dark mode.
  void setDark() {
    state = ThemeMode.dark;
    _saveThemeMode(ThemeMode.dark);
  }

  /// Sets the theme to follow system settings.
  void setSystem() {
    state = ThemeMode.system;
    _saveThemeMode(ThemeMode.system);
  }

  /// Toggles between light and dark themes.
  ///
  /// If currently in system mode, switches to light or dark based on
  /// the current system brightness.
  void toggle() {
    if (state == ThemeMode.light) {
      setDark();
    } else if (state == ThemeMode.dark) {
      setLight();
    } else {
      // If in system mode, toggle based on current system brightness
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      if (brightness == Brightness.dark) {
        setLight();
      } else {
        setDark();
      }
    }
  }

  /// Gets the effective brightness based on current theme mode.
  ///
  /// Returns the actual brightness that should be used, taking into account
  /// system settings when in system mode.
  Brightness getEffectiveBrightness() {
    if (state == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness;
    }
    return state == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }
}
