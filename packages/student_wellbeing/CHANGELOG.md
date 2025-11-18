# Changelog

All notable changes to the Student Wellbeing Monitoring package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2024-11-16

### Added
- **Enhanced Data Retention**:
  - `setRetention(int days)` method for dynamic retention configuration
  - `purgeOldData()` method for manual data cleanup
  - Automatic purging after check-in registration
  
- **Advanced Anonymization**:
  - `anonymizeBatchForSend()` method for batch anonymization with aggregation
  - Rotating UUID (sendId) for each transmission batch
  - Day-level timestamp truncation for enhanced privacy
  - Aggregate daily statistics (avg mood, avg stress, sample size)
  - Visual anonymization details shown to users after submission

- **Moving Average Analysis**:
  - `computeMovingAverage()` method with configurable window size
  - Weighted moving average calculation (recent data weighted higher)
  - Integration with score calculation and alert detection
  
- **Enhanced Alert System**:
  - Sudden drop detection comparing current score with moving average
  - Consecutive low mood pattern detection (configurable threshold)
  - Consecutive high stress pattern detection (configurable threshold)
  - Alert metadata includes daysWindow and affectedSampleSize
  - Contextual recommendations based on alert type and severity
  - Configuration options: `alertDropPercentThreshold`, `consecutiveLowMoodThreshold`, `movingAverageWindowSize`

- **Widget Enhancements**:
  - Detailed consent modal in `WellbeingCheckinWidget` with "Learn More" button
  - Comprehensive privacy explanations with icons and sections
  - Semantic labels for screen reader accessibility
  - Trend chart in `EarlyAlertDashboard` showing 14-day mood/stress history
  - Interactive line chart with tooltips (using fl_chart)
  - Real-time chart updates via stream subscriptions
  - Chart legend for mood/stress identification

- **Accessibility Improvements**:
  - Semantics widgets for mood selector buttons
  - Semantics for stress level slider with increase/decrease actions
  - Text field semantics for notes input
  - Proper button labels and hints for screen readers

- **Production Security TODOs**:
  - Comprehensive comments on required security measures for production
  - HSM integration requirements
  - Backend API security specifications
  - Key management guidelines
  - Audit logging recommendations

### Changed
- Retention policy now uses mutable `_retentionDays` field instead of final
- Alert detection logic refactored into separate `_createAlert()` helper method
- Improved stream emission consistency across all data operations
- Enhanced error messages with more context

### Improved
- Better user feedback when submitting check-ins with consent
- More informative privacy notices and consent explanations
- Clearer visual indicators for anonymization process
- More robust alert deduplication logic

### Fixed
- Ensured all streams emit properly on data changes
- Fixed potential issues with old data not being purged promptly

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
