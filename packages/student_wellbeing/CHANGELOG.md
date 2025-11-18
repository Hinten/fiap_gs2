# Changelog

All notable changes to the Student Wellbeing Monitoring package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0+1] - 2024-11-16

### Added
- Initial release of Student Wellbeing Monitoring package
- `WellbeingMonitoringService` for managing wellbeing data
  - Consent-based check-in recording
  - Local encrypted storage using flutter_secure_storage
  - Data anonymization for transmission
  - Wellbeing score calculation with trend analysis
  - Automated alert detection for concerning patterns
  - Configurable retention policies
  - Complete data deletion capabilities
- `WellbeingCheckinWidget` for student input
  - Visual mood selector with emojis
  - Stress level slider
  - Optional notes field
  - Clear consent interface
  - Local-only save option
- `EarlyAlertDashboard` for viewing alerts
  - Anonymous cluster-level alerts
  - Severity indicators
  - Actionable recommendations
  - Privacy-protected display
- Data models:
  - `WellbeingCheckin` with anonymization support
  - `WellbeingScore` with trend calculation
  - `AlertCluster` for aggregate alerts
- Comprehensive documentation:
  - README.md with usage examples
  - PRIVACY_COMPLIANCE.md with LGPD/GDPR details
  - API documentation in code
- Example app demonstrating all features
- Unit tests covering core functionality
- LGPD/GDPR compliance features:
  - Explicit consent collection
  - Purpose limitation
  - Data minimization
  - Storage limitation
  - User rights (access, deletion)
  - Privacy by design

### Security
- Encrypted local storage using flutter_secure_storage
- Data anonymization before transmission
- No personal identifiers in aggregate reporting
- Configurable data retention with automatic cleanup

### Known Limitations
- Web platform has reduced security compared to mobile
- Parental consent verification not included (must be implemented at app level)
- Current encryption suitable for development (production requires HSM integration)
- No backend integration (local-only by design, apps must implement transmission)

[0.1.0+1]: https://github.com/luxyvsc/fiap_gs2/releases/tag/student_wellbeing-v0.1.0
