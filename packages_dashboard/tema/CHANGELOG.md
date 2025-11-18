# Changelog

All notable changes to the Tema package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-18

### Added
- Initial release of Tema package
- Modern Material Design 3 light theme with purple/violet primary color
- Modern Material Design 3 dark theme with light purple primary color
- TemaProvider using Riverpod StateNotifier for theme management
- System theme detection and automatic following
- Theme preference persistence using SharedPreferences
- Methods for theme control:
  - `setLight()` - Switch to light theme
  - `setDark()` - Switch to dark theme
  - `setSystem()` - Follow system theme
  - `toggle()` - Toggle between light and dark
  - `getEffectiveBrightness()` - Get current effective brightness
- Comprehensive unit tests with >90% coverage
- Complete documentation in README.md
- Detailed roadmap in roadmap.md
- DartDoc documentation for all public APIs
- Compliance with project linting rules
- Support for Flutter 3.9.2+ (SDK ^3.9.2)

### Dependencies
- flutter_riverpod: ^3.0.3 - State management
- shared_preferences: ^2.2.2 - Local preference persistence

### Theme Features
- Custom color schemes for light and dark modes
- Styled components: AppBar, Card, Input, Buttons, FAB, Divider
- Rounded corners and appropriate elevations
- Optimized for readability and accessibility
- Material Design 3 compliance

### Testing
- 18 unit tests covering all functionality
- Tests for theme mode changes
- Tests for persistence (save/load)
- Tests for toggle functionality
- Tests for theme configurations

### Documentation
- Complete README with usage examples
- API documentation with code samples
- Installation instructions
- Integration guide for Riverpod
- Color palette documentation
- Full working example application

[1.0.0]: https://github.com/Hinten/fiap_gs2/releases/tag/tema-v1.0.0
