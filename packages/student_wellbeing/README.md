# Student Wellbeing Monitoring Package

A comprehensive Flutter package for monitoring student wellbeing with LGPD/GDPR compliance. This package provides tools for collecting, analyzing, and responding to student mental health indicators through consent-based data collection and privacy-first design.

## Features

✅ **Privacy-First Design**
- Explicit consent collection before any data sharing
- Local encrypted storage using `flutter_secure_storage`
- Data anonymization for aggregate reporting
- Configurable data retention policies
- Complete data deletion capabilities (GDPR right to erasure)

🎯 **Early Warning System**
- Automated detection of concerning wellbeing patterns
- Anonymous cluster-based alerts (no individual identification)
- Configurable thresholds and time windows
- Actionable recommendations for educators

📊 **Wellbeing Monitoring**
- Simple mood and stress level tracking
- Visual, accessible check-in interface
- Trend analysis with moving averages
- Stream-based reactive state management

🔒 **LGPD/GDPR Compliant**
- Purpose limitation and data minimization
- Transparent data processing
- User rights implementation (access, deletion)
- Detailed compliance documentation

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  student_wellbeing:
    path: ../packages/student_wellbeing  # For monorepo
  
  # Or from pub.dev (once published)
  # student_wellbeing: ^0.1.0
```

Run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize the Service

```dart
import 'package:student_wellbeing/student_wellbeing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final service = WellbeingMonitoringService(
    retentionDays: 30,        // Keep data for 30 days
    alertWindowDays: 7,       // Analyze last 7 days for alerts
    stressThreshold: 4.0,     // Stress level that triggers alerts
    scoreThreshold: 40.0,     // Wellbeing score threshold
  );
  
  await service.initialize();
  
  runApp(MyApp(service: service));
}
```

### 2. Add Check-In Widget

```dart
import 'package:flutter/material.dart';
import 'package:student_wellbeing/student_wellbeing.dart';

class CheckInScreen extends StatelessWidget {
  final WellbeingMonitoringService service;
  
  const CheckInScreen({required this.service});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Check-In')),
      body: WellbeingCheckinWidget(
        service: service,
        studentId: 'current-student-id', // Optional
        onCheckinRecorded: () {
          // Handle successful check-in
          print('Check-in recorded!');
        },
      ),
    );
  }
}
```

### 3. Add Alert Dashboard

```dart
class AlertScreen extends StatelessWidget {
  final WellbeingMonitoringService service;
  
  const AlertScreen({required this.service});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Early Alerts')),
      body: EarlyAlertDashboard(service: service),
    );
  }
}
```

## Usage Examples

### Recording a Check-In Programmatically

```dart
final checkin = await service.recordCheckin(
  studentId: 'student-123',
  moodLevel: 4,              // 1-5 scale
  stressLevel: 2,            // 1-5 scale
  notes: 'Feeling good!',    // Optional
  consentToShare: true,      // User must consent
);
```

### Calculating Wellbeing Score

```dart
final score = await service.calculateScoreForStudent('student-123');
print('Average score: ${score.averageScore}');
print('Trend: ${score.trend}');
print('Is concerning: ${score.isConcerning()}');
```

### Listening to Stream Updates

```dart
// Listen to new check-ins
service.checkinsStream.listen((checkins) {
  print('Total check-ins: ${checkins.length}');
});

// Listen to score updates
service.scoresStream.listen((score) {
  print('New score: ${score.averageScore}');
});

// Listen to alerts
service.alertsStream.listen((alerts) {
  print('Active alerts: ${alerts.length}');
});
```

### Anonymizing Data for Transmission

```dart
// Get anonymized check-ins (only with user consent)
final anonymized = service.anonymizeCheckinsForTransmission();

// These can be safely transmitted to backend
// All personal identifiers removed
for (final checkin in anonymized) {
  print('Anonymous ID: ${checkin.id}');
  print('Student ID: ${checkin.studentId}'); // null
  print('Mood: ${checkin.moodLevel}');
}
```

### Implementing Data Deletion (GDPR)

```dart
// Delete specific student's data
await service.deleteStudentData('student-123');

// Delete all local data
await service.deleteAllData();
```

## Configuration

### Alert Thresholds

Customize when alerts are triggered:

```dart
final service = WellbeingMonitoringService(
  stressThreshold: 4.5,     // Higher = more sensitive to stress
  scoreThreshold: 35.0,     // Lower = more sensitive to low wellbeing
  alertWindowDays: 14,      // Longer window = more data for analysis
);
```

### Data Retention

Configure how long data is kept:

```dart
final service = WellbeingMonitoringService(
  retentionDays: 60,  // Keep data for 60 days
);

// Data older than retentionDays is automatically deleted
```

## Consent Flow

The package implements a clear consent flow:

1. **Explicit Consent Request**: Users see clear explanation before data collection
2. **Purpose Statement**: Why data is collected (student support, early warning)
3. **Optional Sharing**: Users can save locally without sharing
4. **Consent Storage**: Consent status saved with each check-in
5. **Withdrawal**: Users can delete data at any time

Example consent UI is provided in `WellbeingCheckinWidget`.

## Privacy & Compliance

This package is designed for LGPD/GDPR compliance:

### Data Minimization
- Only collects necessary wellbeing indicators
- No unnecessary personal information
- Notes are optional and can be excluded

### Purpose Limitation
- Data used only for wellbeing monitoring and early warning
- Clear communication of data usage to users

### Anonymization
- Personal identifiers removed before aggregation
- Dashboard shows only cluster-level data
- Individuals cannot be identified from alerts

### User Rights
- **Right to Access**: Users can view their check-ins via service methods
- **Right to Deletion**: Complete data deletion supported
- **Right to Restrict**: Users control what data is shared

### Storage Security
- Uses `flutter_secure_storage` for encrypted local storage
- Data at rest is encrypted
- No data transmission without explicit consent

⚠️ **Production Note**: The current implementation uses `flutter_secure_storage` as a 
placeholder. For production deployment, integrate with certified secure storage 
solutions and implement proper key management systems.

See [PRIVACY_COMPLIANCE.md](./PRIVACY_COMPLIANCE.md) for detailed compliance information.

## Architecture

### Models

- **WellbeingCheckin**: Individual wellbeing report with mood and stress levels
- **WellbeingScore**: Calculated score with trend analysis
- **AlertCluster**: Anonymous cluster alert for early warning

### Services

- **WellbeingMonitoringService**: Main service handling all operations
  - Check-in recording and storage
  - Score calculation
  - Alert detection
  - Data anonymization
  - Privacy management

### Widgets

- **WellbeingCheckinWidget**: User interface for daily check-ins
  - Visual mood selector (emojis)
  - Stress level slider
  - Optional notes field
  - Clear consent interface
  
- **EarlyAlertDashboard**: Alert viewing interface
  - Privacy-protected display
  - Severity indicators
  - Actionable recommendations
  - Anonymous cluster information

## Testing

Run the test suite:

```bash
cd packages/student_wellbeing
flutter test
```

Run with coverage:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Coverage

The package includes comprehensive tests:
- Service functionality (check-ins, scores, alerts)
- Data anonymization
- Privacy controls (consent, deletion)
- Stream updates
- Model calculations

## Example App

A complete example app is included in the `example/` directory:

```bash
cd example
flutter pub get
flutter run -d chrome
```

The example demonstrates:
- Full check-in workflow
- Alert dashboard
- Statistics view
- Data deletion

## Roadmap

Future enhancements:

- [ ] Backend integration with Cloud Functions
- [ ] Advanced analytics (ML-based pattern detection)
- [ ] Multi-language support
- [ ] Accessibility improvements
- [ ] Additional wellbeing indicators (sleep, exercise)
- [ ] Integration with mental health resources
- [ ] Advanced clustering algorithms
- [ ] Export functionality for educators

## Contributing

This package is part of the FIAP AI-Enhanced Learning Platform monorepo. 
Contributions should follow the project's coding standards:

- Use Dart's official style guide
- Maintain test coverage above 80%
- Document all public APIs
- Follow privacy-by-design principles

## License

Part of FIAP Global Solution 2025.2 project.

## Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Contact the development team
- Review PRIVACY_COMPLIANCE.md for compliance questions

## Important Notes

### Security Considerations

1. **Encryption**: Current implementation uses flutter_secure_storage. For production:
   - Implement hardware-backed key storage
   - Use certified encryption libraries
   - Implement proper key rotation

2. **Network Security**: When implementing backend transmission:
   - Use TLS 1.3+
   - Implement certificate pinning
   - Use secure authentication (OAuth 2.0, JWT)

3. **Data Sanitization**: Always validate and sanitize user inputs

### Legal Compliance

This package provides technical tools for LGPD/GDPR compliance but:
- Legal review is required before production use
- Privacy policy must be drafted by legal counsel
- Data processing agreements may be needed
- Local regulations may have additional requirements

### Ethical Considerations

Mental health data is sensitive:
- Never use for punitive measures
- Ensure proper training for staff reviewing alerts
- Have mental health resources available
- Consider cultural contexts in wellbeing assessment

## Acknowledgments

Developed as part of FIAP Global Solution 2025.2 - Making education more human, 
inclusive, and sustainable through AI and gamification.
