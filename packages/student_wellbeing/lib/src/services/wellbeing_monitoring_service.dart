import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/alert_cluster.dart';
import '../models/wellbeing_checkin.dart';
import '../models/wellbeing_score.dart';

/// Service for monitoring student wellbeing with LGPD/GDPR compliance.
///
/// This service provides:
/// - Consent-based data collection
/// - Local encrypted storage
/// - Data anonymization
/// - Early warning detection
/// - Privacy-focused data management
///
/// **IMPORTANT**: This implementation uses flutter_secure_storage as a
/// placeholder for secure storage. For production, integrate with
/// certified secure storage solutions and proper key management.
class WellbeingMonitoringService {
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  final Uuid _uuid;

  // Stream controllers for reactive state management
  final _checkinsController =
      StreamController<List<WellbeingCheckin>>.broadcast();
  final _scoresController = StreamController<WellbeingScore>.broadcast();
  final _alertsController = StreamController<List<AlertCluster>>.broadcast();

  // In-memory cache
  List<WellbeingCheckin> _checkins = [];
  List<AlertCluster> _alerts = [];

  // Configuration
  final int retentionDays;
  final int alertWindowDays;
  final double stressThreshold;
  final double scoreThreshold;

  /// Creates a new wellbeing monitoring service.
  ///
  /// [retentionDays]: How long to keep data locally (default: 30 days).
  /// [alertWindowDays]: Time window for alert detection (default: 7 days).
  /// [stressThreshold]: Stress level that triggers alerts (default: 4.0).
  /// [scoreThreshold]: Wellbeing score below which alerts trigger (default: 40.0).
  WellbeingMonitoringService({
    FlutterSecureStorage? secureStorage,
    Logger? logger,
    Uuid? uuid,
    this.retentionDays = 30,
    this.alertWindowDays = 7,
    this.stressThreshold = 4.0,
    this.scoreThreshold = 40.0,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _logger = logger ?? Logger(),
        _uuid = uuid ?? const Uuid();

  /// Stream of all check-ins (updates when new check-ins are added).
  Stream<List<WellbeingCheckin>> get checkinsStream =>
      _checkinsController.stream;

  /// Stream of wellbeing scores (updates when scores are recalculated).
  Stream<WellbeingScore> get scoresStream => _scoresController.stream;

  /// Stream of alerts (updates when new alerts are detected).
  Stream<List<AlertCluster>> get alertsStream => _alertsController.stream;

  /// Initializes the service and loads stored data.
  Future<void> initialize() async {
    _logger.i('Initializing WellbeingMonitoringService');
    await _loadCheckinsFromStorage();
    await _loadAlertsFromStorage();
    await _cleanupOldData();
    _logger.i(
      'Loaded ${_checkins.length} check-ins and ${_alerts.length} alerts',
    );
  }

  /// Records a new wellbeing check-in.
  ///
  /// [studentId]: Optional student identifier (only stored locally with consent).
  /// [moodLevel]: Mood rating from 1-5.
  /// [stressLevel]: Stress rating from 1-5.
  /// [notes]: Optional notes from the student.
  /// [consentToShare]: Whether student consents to share anonymized data.
  ///
  /// Returns the created check-in.
  Future<WellbeingCheckin> recordCheckin({
    String? studentId,
    required int moodLevel,
    required int stressLevel,
    String? notes,
    required bool consentToShare,
  }) async {
    _logger.d(
      'Recording check-in: mood=$moodLevel, stress=$stressLevel, '
      'consent=$consentToShare',
    );

    final checkin = WellbeingCheckin(
      id: _uuid.v4(),
      studentId: consentToShare ? studentId : null,
      timestamp: DateTime.now(),
      moodLevel: moodLevel,
      stressLevel: stressLevel,
      notes: notes,
      consentToShare: consentToShare,
    );

    _checkins.add(checkin);
    await _saveCheckinsToStorage();
    _checkinsController.add(List.unmodifiable(_checkins));

    // Recalculate scores and check for alerts
    await _updateScoresAndAlerts();

    _logger.i('Check-in recorded successfully: ${checkin.id}');
    return checkin;
  }

  /// Gets all check-ins for a specific student.
  ///
  /// Only returns check-ins if the student has consented to storage.
  List<WellbeingCheckin> getCheckinsForStudent(String studentId) {
    return _checkins
        .where((c) => c.studentId == studentId && c.consentToShare)
        .toList();
  }

  /// Calculates the current wellbeing score for a student.
  ///
  /// Uses check-ins from the last [alertWindowDays] days.
  Future<WellbeingScore> calculateScoreForStudent(String studentId) async {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(days: alertWindowDays));

    final recentCheckins = _checkins
        .where(
          (c) =>
              c.studentId == studentId &&
              c.timestamp.isAfter(windowStart) &&
              c.consentToShare,
        )
        .toList();

    final score = WellbeingScore.calculate(
      id: _uuid.v4(),
      checkins: recentCheckins,
      periodStart: windowStart,
      periodEnd: now,
    );

    _scoresController.add(score);
    return score;
  }

  /// Anonymizes check-ins for secure transmission.
  ///
  /// Removes all personal identifiers while preserving aggregate data.
  /// Only processes check-ins where the student has consented to share.
  List<WellbeingCheckin> anonymizeCheckinsForTransmission() {
    return _checkins
        .where((c) => c.consentToShare && !c.isAnonymized)
        .map((c) => c.anonymize(anonymousId: _uuid.v4()))
        .toList();
  }

  /// Deletes all data for a specific student (GDPR right to deletion).
  ///
  /// Removes all check-ins and related data from local storage.
  Future<void> deleteStudentData(String studentId) async {
    _logger.w('Deleting all data for student: $studentId');

    final initialCount = _checkins.length;
    _checkins.removeWhere((c) => c.studentId == studentId);
    final deletedCount = initialCount - _checkins.length;

    await _saveCheckinsToStorage();
    _checkinsController.add(List.unmodifiable(_checkins));

    _logger.i('Deleted $deletedCount check-ins for student $studentId');
  }

  /// Deletes all local data (complete reset).
  Future<void> deleteAllData() async {
    _logger.w('Deleting all local data');

    _checkins.clear();
    _alerts.clear();

    await _secureStorage.delete(key: _checkinsStorageKey);
    await _secureStorage.delete(key: _alertsStorageKey);

    _checkinsController.add(List.unmodifiable(_checkins));
    _alertsController.add(List.unmodifiable(_alerts));

    _logger.i('All data deleted successfully');
  }

  /// Gets the current list of active alerts.
  List<AlertCluster> getActiveAlerts() {
    return List.unmodifiable(_alerts);
  }

  /// Disposes the service and closes streams.
  void dispose() {
    _checkinsController.close();
    _scoresController.close();
    _alertsController.close();
  }

  // Private methods

  static const String _checkinsStorageKey = 'wellbeing_checkins';
  static const String _alertsStorageKey = 'wellbeing_alerts';

  Future<void> _loadCheckinsFromStorage() async {
    try {
      final data = await _secureStorage.read(key: _checkinsStorageKey);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
        _checkins = jsonList
            .map(
              (json) =>
                  WellbeingCheckin.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (e) {
      _logger.e('Error loading check-ins from storage: $e');
      _checkins = [];
    }
  }

  Future<void> _saveCheckinsToStorage() async {
    try {
      final jsonList = _checkins.map((c) => c.toJson()).toList();
      final data = jsonEncode(jsonList);
      await _secureStorage.write(key: _checkinsStorageKey, value: data);
    } catch (e) {
      _logger.e('Error saving check-ins to storage: $e');
    }
  }

  Future<void> _loadAlertsFromStorage() async {
    try {
      final data = await _secureStorage.read(key: _alertsStorageKey);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
        _alerts = jsonList
            .map((json) => AlertCluster.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _logger.e('Error loading alerts from storage: $e');
      _alerts = [];
    }
  }

  Future<void> _saveAlertsToStorage() async {
    try {
      final jsonList = _alerts.map((a) => a.toJson()).toList();
      final data = jsonEncode(jsonList);
      await _secureStorage.write(key: _alertsStorageKey, value: data);
    } catch (e) {
      _logger.e('Error saving alerts to storage: $e');
    }
  }

  /// Removes data older than the retention period.
  Future<void> _cleanupOldData() async {
    final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
    final initialCount = _checkins.length;

    _checkins.removeWhere((c) => c.timestamp.isBefore(cutoffDate));

    if (initialCount != _checkins.length) {
      await _saveCheckinsToStorage();
      _logger.i(
        'Cleaned up ${initialCount - _checkins.length} old check-ins',
      );
    }
  }

  /// Updates scores and detects alerts based on recent check-ins.
  Future<void> _updateScoresAndAlerts() async {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(days: alertWindowDays));

    // Get recent check-ins
    final recentCheckins =
        _checkins.where((c) => c.timestamp.isAfter(windowStart)).toList();

    if (recentCheckins.length < 2) {
      // Not enough data for meaningful analysis
      return;
    }

    // Create anonymous clusters (simple implementation: one cluster for demo)
    final clusterName = 'Cluster-Anonymous';
    final clusterSize = recentCheckins.length;

    // Calculate aggregate statistics
    final avgStress = recentCheckins
            .map((c) => c.stressLevel.toDouble())
            .reduce((a, b) => a + b) /
        recentCheckins.length;

    final score = WellbeingScore.calculate(
      id: _uuid.v4(),
      checkins: recentCheckins,
      periodStart: windowStart,
      periodEnd: now,
    );

    // Detect concerning patterns
    if (score.isConcerning() || avgStress >= stressThreshold) {
      final alert = AlertCluster(
        id: _uuid.v4(),
        clusterName: clusterName,
        alertType: avgStress >= stressThreshold
            ? AlertType.stressIncrease
            : AlertType.lowMood,
        severity: score.averageScore < 30 || avgStress > 4.5
            ? AlertSeverity.high
            : AlertSeverity.medium,
        description: avgStress >= stressThreshold
            ? 'Elevated stress levels detected in cluster'
            : 'Low wellbeing scores detected in cluster',
        timestamp: now,
        clusterSize: clusterSize,
        percentageChange: score.trend,
        recommendations: [
          'Consider outreach to cluster participants',
          'Review recent workload and deadlines',
          'Offer mental health resources',
          'Monitor situation closely',
        ],
      );

      // Only add if not duplicate
      final isDuplicate = _alerts.any(
        (a) =>
            a.clusterName == alert.clusterName &&
            a.alertType == alert.alertType &&
            now.difference(a.timestamp).inHours < 24,
      );

      if (!isDuplicate) {
        _alerts.add(alert);
        await _saveAlertsToStorage();
        _alertsController.add(List.unmodifiable(_alerts));
        _logger.w('New alert generated: ${alert.description}');
      }
    }
  }
}
