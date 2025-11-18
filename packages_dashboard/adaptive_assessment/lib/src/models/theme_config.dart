import 'package:flutter/material.dart';

/// Available theme modes for accessibility
enum AccessibilityTheme {
  /// Standard theme with default settings
  standard,

  /// High contrast theme for better visibility
  highContrast,

  /// Dyslexia-friendly theme with special font and spacing
  dyslexiaFriendly,
}

/// Theme configuration for accessibility options
class ThemeConfig {
  /// Current accessibility theme
  final AccessibilityTheme theme;

  /// Font size multiplier (1.0 is default)
  final double fontSizeMultiplier;

  /// Letter spacing for improved readability
  final double letterSpacing;

  /// Font family name
  final String? fontFamily;

  /// Whether text-to-speech is enabled
  final bool ttsEnabled;

  /// Speech rate for TTS (0.5 - 1.5, default 1.0)
  final double speechRate;

  /// Creates a new ThemeConfig instance
  const ThemeConfig({
    this.theme = AccessibilityTheme.standard,
    this.fontSizeMultiplier = 1.0,
    this.letterSpacing = 0.0,
    this.fontFamily,
    this.ttsEnabled = false,
    this.speechRate = 1.0,
  });

  /// Creates a standard theme configuration
  factory ThemeConfig.standard() => const ThemeConfig(
        theme: AccessibilityTheme.standard,
        fontSizeMultiplier: 1.0,
        letterSpacing: 0.0,
        fontFamily: null,
        ttsEnabled: false,
        speechRate: 1.0,
      );

  /// Creates a high contrast theme configuration
  factory ThemeConfig.highContrast() => const ThemeConfig(
        theme: AccessibilityTheme.highContrast,
        fontSizeMultiplier: 1.2,
        letterSpacing: 0.5,
        fontFamily: null,
        ttsEnabled: false,
        speechRate: 1.0,
      );

  /// Creates a dyslexia-friendly theme configuration
  factory ThemeConfig.dyslexiaFriendly() => const ThemeConfig(
        theme: AccessibilityTheme.dyslexiaFriendly,
        fontSizeMultiplier: 1.3,
        letterSpacing: 1.5,
        fontFamily: 'OpenDyslexic',
        ttsEnabled: true,
        speechRate: 0.9,
      );

  /// Creates a copy of this config with updated fields
  ThemeConfig copyWith({
    AccessibilityTheme? theme,
    double? fontSizeMultiplier,
    double? letterSpacing,
    String? fontFamily,
    bool? ttsEnabled,
    double? speechRate,
  }) =>
      ThemeConfig(
        theme: theme ?? this.theme,
        fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        fontFamily: fontFamily ?? this.fontFamily,
        ttsEnabled: ttsEnabled ?? this.ttsEnabled,
        speechRate: speechRate ?? this.speechRate,
      );

  /// Gets the appropriate color scheme for the current theme
  ColorScheme getColorScheme({required Brightness brightness}) {
    switch (theme) {
      case AccessibilityTheme.highContrast:
        return brightness == Brightness.dark
            ? const ColorScheme.dark(
                primary: Colors.white,
                secondary: Colors.yellow,
                surface: Colors.black,
                error: Colors.red,
              )
            : const ColorScheme.light(
                primary: Colors.black,
                secondary: Colors.blue,
                surface: Colors.white,
                error: Colors.red,
              );

      case AccessibilityTheme.dyslexiaFriendly:
        return ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: brightness,
        );

      case AccessibilityTheme.standard:
        return ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        );
    }
  }

  /// Converts this config to a JSON map
  Map<String, dynamic> toJson() => {
        'theme': theme.name,
        'fontSizeMultiplier': fontSizeMultiplier,
        'letterSpacing': letterSpacing,
        'fontFamily': fontFamily,
        'ttsEnabled': ttsEnabled,
        'speechRate': speechRate,
      };

  /// Creates a ThemeConfig from a JSON map
  factory ThemeConfig.fromJson(Map<String, dynamic> json) => ThemeConfig(
        theme: AccessibilityTheme.values.firstWhere(
          (e) => e.name == json['theme'],
          orElse: () => AccessibilityTheme.standard,
        ),
        fontSizeMultiplier: (json['fontSizeMultiplier'] as num).toDouble(),
        letterSpacing: (json['letterSpacing'] as num).toDouble(),
        fontFamily: json['fontFamily'] as String?,
        ttsEnabled: json['ttsEnabled'] as bool,
        speechRate: (json['speechRate'] as num).toDouble(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeConfig &&
          runtimeType == other.runtimeType &&
          theme == other.theme &&
          fontSizeMultiplier == other.fontSizeMultiplier &&
          letterSpacing == other.letterSpacing &&
          fontFamily == other.fontFamily &&
          ttsEnabled == other.ttsEnabled &&
          speechRate == other.speechRate;

  @override
  int get hashCode =>
      theme.hashCode ^
      fontSizeMultiplier.hashCode ^
      letterSpacing.hashCode ^
      fontFamily.hashCode ^
      ttsEnabled.hashCode ^
      speechRate.hashCode;
}
