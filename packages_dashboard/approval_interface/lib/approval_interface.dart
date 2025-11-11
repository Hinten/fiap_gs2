/// Approval Interface Package
///
/// A generic, reusable approval interface for the FIAP AI-Enhanced Learning Platform.
/// This package provides widgets, models, and services for managing approval workflows
/// for various types of content including code reviews, grades, awards, and more.
///
/// ## Usage
///
/// ```dart
/// import 'package:approval_interface/approval_interface.dart';
/// import 'package:flutter/material.dart';
/// import 'package:flutter_riverpod/flutter_riverpod.dart';
///
/// void main() {
///   runApp(
///     ProviderScope(
///       child: MaterialApp(
///         home: ApprovalDashboardScreen(),
///       ),
///     ),
///   );
/// }
/// ```
///
/// ## Configuration
///
/// Configure the API base URL using environment variables:
///
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
/// ```
library approval_interface;

// Models
export 'src/models/approval_item.dart';

// Services
export 'src/services/approval_service.dart';

// Providers
export 'src/providers/approval_provider.dart';

// Widgets
export 'src/widgets/approval_card.dart';
export 'src/widgets/approval_list.dart';

// Screens
export 'src/screens/approval_dashboard_screen.dart';
