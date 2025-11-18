/// Student Wellbeing Monitoring Package
///
/// A LGPD/GDPR compliant package for monitoring student wellbeing
/// and generating early warning alerts.
///
/// ## Features
///
/// - 🔒 **Privacy First**: Explicit consent collection and management
/// - 🔐 **Secure Storage**: Local encrypted data storage
/// - 🎭 **Anonymization**: Data anonymization before transmission
/// - 📊 **Early Warnings**: Automated detection of concerning patterns
/// - 🗑️ **Data Rights**: Complete data deletion capabilities
/// - ⚡ **Reactive**: Stream-based state management
///
/// ## Usage
///
/// ```dart
/// import 'package:student_wellbeing/student_wellbeing.dart';
/// import 'package:flutter/material.dart';
///
/// void main() async {
///   // Initialize the service
///   final service = WellbeingMonitoringService();
///   await service.initialize();
///
///   runApp(MaterialApp(
///     home: Scaffold(
///       body: Column(
///         children: [
///           WellbeingCheckinWidget(
///             service: service,
///             studentId: 'optional-student-id',
///           ),
///           EarlyAlertDashboard(service: service),
///         ],
///       ),
///     ),
///   ));
/// }
/// ```
///
/// ## LGPD/GDPR Compliance
///
/// This package implements privacy-by-design principles:
/// - Explicit consent before data collection
/// - Purpose limitation and data minimization
/// - Configurable retention periods
/// - Right to access and deletion
/// - Anonymization for aggregate reporting
///
/// See PRIVACY_COMPLIANCE.md for detailed compliance information.
library student_wellbeing;

// Models
export 'src/models/alert_cluster.dart';
export 'src/models/wellbeing_checkin.dart';
export 'src/models/wellbeing_score.dart';

// Services
export 'src/services/wellbeing_monitoring_service.dart';

// Widgets
export 'src/widgets/early_alert_dashboard.dart';
export 'src/widgets/wellbeing_checkin_widget.dart';
