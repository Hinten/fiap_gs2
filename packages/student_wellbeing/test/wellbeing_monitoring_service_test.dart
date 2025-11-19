import 'package:flutter_test/flutter_test.dart';
import 'package:student_wellbeing/student_wellbeing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WellbeingMonitoringService', () {
    late WellbeingMonitoringService service;

    setUp(() async {
      service = WellbeingMonitoringService(
        retentionDays: 30,
        alertWindowDays: 7,
        stressThreshold: 4.0,
        scoreThreshold: 40.0,
      );
      await service.initialize();
    });

    tearDown(() {
      service.dispose();
    });

    test('should record check-in with consent', () async {
      final checkin = await service.recordCheckin(
        studentId: 'test-student-1',
        moodLevel: 4,
        stressLevel: 2,
        notes: 'Feeling good today',
        consentToShare: true,
      );

      expect(checkin.studentId, equals('test-student-1'));
      expect(checkin.moodLevel, equals(4));
      expect(checkin.stressLevel, equals(2));
      expect(checkin.consentToShare, isTrue);
    });

    test('should not store student ID without consent', () async {
      final checkin = await service.recordCheckin(
        studentId: 'test-student-2',
        moodLevel: 3,
        stressLevel: 3,
        consentToShare: false,
      );

      expect(checkin.studentId, isNull);
      expect(checkin.consentToShare, isFalse);
    });

    test('should calculate wellbeing score', () async {
      // Add multiple check-ins
      await service.recordCheckin(
        studentId: 'student-1',
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: true,
      );

      await service.recordCheckin(
        studentId: 'student-1',
        moodLevel: 5,
        stressLevel: 1,
        consentToShare: true,
      );

      await service.recordCheckin(
        studentId: 'student-1',
        moodLevel: 3,
        stressLevel: 3,
        consentToShare: true,
      );

      final score = await service.calculateScoreForStudent('student-1');

      expect(score.sampleSize, equals(3));
      expect(score.averageScore, greaterThan(0));
      expect(score.averageScore, lessThanOrEqualTo(100));
    });

    test('should detect concerning patterns and generate alerts', () async {
      // Add check-ins with high stress
      for (int i = 0; i < 5; i++) {
        await service.recordCheckin(
          studentId: 'student-stressed',
          moodLevel: 2,
          stressLevel: 5,
          consentToShare: true,
        );
      }

      // Wait a bit for alert processing
      await Future.delayed(const Duration(milliseconds: 100));

      final alerts = service.getActiveAlerts();
      expect(alerts, isNotEmpty);
      expect(alerts.first.alertType, equals(AlertType.stressIncrease));
    });

    test('should anonymize check-ins for transmission', () async {
      await service.recordCheckin(
        studentId: 'student-to-anonymize',
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: true,
      );

      final anonymized = service.anonymizeCheckinsForTransmission();

      expect(anonymized, isNotEmpty);
      expect(anonymized.first.studentId, isNull);
      expect(anonymized.first.isAnonymized, isTrue);
      expect(anonymized.first.moodLevel, equals(4));
      expect(anonymized.first.stressLevel, equals(2));
    });

    test('should not anonymize check-ins without consent', () async {
      await service.recordCheckin(
        studentId: 'student-no-consent',
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: false,
      );

      final anonymized = service.anonymizeCheckinsForTransmission();

      expect(anonymized, isEmpty);
    });

    test('should delete student data', () async {
      // Add check-ins
      await service.recordCheckin(
        studentId: 'student-to-delete',
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: true,
      );

      await service.recordCheckin(
        studentId: 'student-to-delete',
        moodLevel: 3,
        stressLevel: 3,
        consentToShare: true,
      );

      // Verify check-ins exist
      var checkins = service.getCheckinsForStudent('student-to-delete');
      expect(checkins.length, equals(2));

      // Delete student data
      await service.deleteStudentData('student-to-delete');

      // Verify check-ins are deleted
      checkins = service.getCheckinsForStudent('student-to-delete');
      expect(checkins, isEmpty);
    });

    test('should delete all data', () async {
      // Add multiple check-ins
      await service.recordCheckin(
        studentId: 'student-1',
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: true,
      );

      await service.recordCheckin(
        studentId: 'student-2',
        moodLevel: 3,
        stressLevel: 3,
        consentToShare: true,
      );

      // Delete all data
      await service.deleteAllData();

      // Verify all data is deleted
      final checkins1 = service.getCheckinsForStudent('student-1');
      final checkins2 = service.getCheckinsForStudent('student-2');
      final alerts = service.getActiveAlerts();

      expect(checkins1, isEmpty);
      expect(checkins2, isEmpty);
      expect(alerts, isEmpty);
    });

    test('should emit stream updates when check-ins are added', () async {
      final streamFuture = service.checkinsStream.first;

      await service.recordCheckin(
        studentId: 'stream-test',
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: true,
      );

      final checkins = await streamFuture;
      expect(checkins, isNotEmpty);
    });
  });

  group('WellbeingCheckin', () {
    test('should calculate score correctly', () {
      final checkin = WellbeingCheckin(
        id: 'test-1',
        studentId: 'student-1',
        timestamp: DateTime.now(),
        moodLevel: 5,
        stressLevel: 1,
        consentToShare: true,
      );

      final score = checkin.calculateScore();
      // mood: 5, inverted stress: 5 (6-1), average: 5, scaled: 100
      expect(score, equals(100.0));
    });

    test('should anonymize correctly', () {
      final checkin = WellbeingCheckin(
        id: 'original-id',
        studentId: 'student-123',
        timestamp: DateTime.now(),
        moodLevel: 4,
        stressLevel: 2,
        notes: 'Personal notes',
        consentToShare: true,
      );

      final anonymized = checkin.anonymize(anonymousId: 'anon-id');

      expect(anonymized.id, equals('anon-id'));
      expect(anonymized.studentId, isNull);
      expect(anonymized.notes, isNull);
      expect(anonymized.isAnonymized, isTrue);
      expect(anonymized.moodLevel, equals(4));
      expect(anonymized.stressLevel, equals(2));
    });
  });

  group('WellbeingScore', () {
    test('should identify concerning patterns', () {
      final concerningScore = WellbeingScore(
        id: 'score-1',
        averageScore: 35.0, // Below threshold
        trend: -5.0,
        periodStart: DateTime.now().subtract(const Duration(days: 7)),
        periodEnd: DateTime.now(),
        sampleSize: 5,
        checkins: [],
      );

      expect(concerningScore.isConcerning(), isTrue);
    });

    test('should not flag normal patterns as concerning', () {
      final normalScore = WellbeingScore(
        id: 'score-2',
        averageScore: 70.0,
        trend: 5.0,
        periodStart: DateTime.now().subtract(const Duration(days: 7)),
        periodEnd: DateTime.now(),
        sampleSize: 5,
        checkins: [],
      );

      expect(normalScore.isConcerning(), isFalse);
    });

    test('should calculate score from check-ins', () {
      final now = DateTime.now();
      final checkins = [
        WellbeingCheckin(
          id: '1',
          timestamp: now,
          moodLevel: 5,
          stressLevel: 1,
          consentToShare: true,
        ),
        WellbeingCheckin(
          id: '2',
          timestamp: now,
          moodLevel: 4,
          stressLevel: 2,
          consentToShare: true,
        ),
        WellbeingCheckin(
          id: '3',
          timestamp: now,
          moodLevel: 3,
          stressLevel: 3,
          consentToShare: true,
        ),
      ];

      final score = WellbeingScore.calculate(
        id: 'calc-score',
        checkins: checkins,
        periodStart: now.subtract(const Duration(days: 7)),
        periodEnd: now,
      );

      expect(score.sampleSize, equals(3));
      expect(score.averageScore, greaterThan(0));
      expect(score.averageScore, lessThanOrEqualTo(100));
    });
  });

  group('AlertCluster', () {
    test('should create alert from JSON', () {
      final json = {
        'id': 'alert-1',
        'cluster_name': 'Test Cluster',
        'alert_type': 'stressIncrease',
        'severity': 'high',
        'description': 'Test alert',
        'timestamp': DateTime.now().toIso8601String(),
        'cluster_size': 10,
        'percentage_change': -15.5,
        'recommendations': ['Action 1', 'Action 2'],
      };

      final alert = AlertCluster.fromJson(json);

      expect(alert.id, equals('alert-1'));
      expect(alert.clusterName, equals('Test Cluster'));
      expect(alert.alertType, equals(AlertType.stressIncrease));
      expect(alert.severity, equals(AlertSeverity.high));
      expect(alert.clusterSize, equals(10));
      expect(alert.recommendations.length, equals(2));
    });

    test('should convert alert to JSON', () {
      final alert = AlertCluster(
        id: 'alert-1',
        clusterName: 'Test Cluster',
        alertType: AlertType.lowMood,
        severity: AlertSeverity.medium,
        description: 'Test description',
        timestamp: DateTime(2024, 1, 1),
        clusterSize: 5,
        percentageChange: -10.0,
        recommendations: ['Do something'],
      );

      final json = alert.toJson();

      expect(json['id'], equals('alert-1'));
      expect(json['cluster_name'], equals('Test Cluster'));
      expect(json['alert_type'], equals('lowMood'));
      expect(json['severity'], equals('medium'));
      expect(json['cluster_size'], equals(5));
    });
  });
}
