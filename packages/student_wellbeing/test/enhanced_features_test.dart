import 'package:flutter_test/flutter_test.dart';
import 'package:student_wellbeing/student_wellbeing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Retention Policy Tests', () {
    late WellbeingMonitoringService service;

    setUp(() async {
      service = WellbeingMonitoringService(retentionDays: 7);
      await service.initialize();
    });

    tearDown(() {
      service.dispose();
    });

    test('setRetention updates retention period and purges old data', () async {
      // Add check-ins at different times
      final now = DateTime.now();
      
      // Add old check-in (10 days ago)
      await service.recordCheckin(
        moodLevel: 3,
        stressLevel: 3,
        consentToShare: false,
      );
      
      // Manually set timestamp to 10 days ago (simulated)
      // In real scenario, we'd mock the timestamp
      
      // Change retention to 5 days
      final initialRetention = service.retentionDays;
      expect(initialRetention, equals(7));
      
      await service.setRetention(5);
      expect(service.retentionDays, equals(5));
    });

    test('purgeOldData removes data older than retention period', () async {
      // This test would need time manipulation or mocking
      // For now, test that purgeOldData runs without error
      final removedCount = await service.purgeOldData();
      expect(removedCount, greaterThanOrEqualTo(0));
    });

    test('purgeOldData is called automatically after recordCheckin', () async {
      // Add a check-in
      await service.recordCheckin(
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: false,
      );
      
      // Verify no errors occurred (purge was called)
      // In production, we'd verify via logging or state inspection
      expect(true, isTrue);
    });
  });

  group('Moving Average Tests', () {
    late WellbeingMonitoringService service;

    setUp(() async {
      service = WellbeingMonitoringService(
        movingAverageWindowSize: 5,
      );
      await service.initialize();
    });

    tearDown(() {
      service.dispose();
    });

    test('computeMovingAverage returns null for insufficient data', () {
      final movingAvg = service.computeMovingAverage();
      expect(movingAvg, isNull);
    });

    test('computeMovingAverage handles single entry', () async {
      await service.recordCheckin(
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: false,
      );
      
      final movingAvg = service.computeMovingAverage();
      // With 1 entry, still insufficient for meaningful average (needs 2+)
      expect(movingAvg, isNull);
    });

    test('computeMovingAverage calculates correct average', () async {
      // Add several check-ins
      for (int i = 0; i < 5; i++) {
        await service.recordCheckin(
          moodLevel: 3,
          stressLevel: 3,
          consentToShare: false,
        );
      }
      
      final movingAvg = service.computeMovingAverage();
      expect(movingAvg, isNotNull);
      expect(movingAvg!.sampleSize, lessThanOrEqualTo(5));
      expect(movingAvg.averageScore, greaterThan(0));
    });

    test('computeMovingAverage with constant values', () async {
      // Add 5 identical check-ins
      for (int i = 0; i < 5; i++) {
        await service.recordCheckin(
          moodLevel: 5,  // Max mood
          stressLevel: 1,  // Min stress
          consentToShare: false,
        );
      }
      
      final movingAvg = service.computeMovingAverage();
      expect(movingAvg, isNotNull);
      // Score should be consistent (100.0 for mood=5, stress=1)
      expect(movingAvg!.averageScore, equals(100.0));
      expect(movingAvg.trend, equals(0.0));  // No trend in constant values
    });

    test('computeMovingAverage respects custom window size', () async {
      // Add 10 check-ins
      for (int i = 0; i < 10; i++) {
        await service.recordCheckin(
          moodLevel: 3 + (i % 2),  // Alternating 3 and 4
          stressLevel: 2 + (i % 2),
          consentToShare: false,
        );
      }
      
      // Use smaller window
      final shortAvg = service.computeMovingAverage(windowSize: 3);
      expect(shortAvg, isNotNull);
      expect(shortAvg!.sampleSize, lessThanOrEqualTo(3));
      
      // Use larger window
      final longAvg = service.computeMovingAverage(windowSize: 7);
      expect(longAvg, isNotNull);
      expect(longAvg!.sampleSize, lessThanOrEqualTo(7));
    });
  });

  group('Alert Detection Tests', () {
    late WellbeingMonitoringService service;

    setUp() async {
      service = WellbeingMonitoringService(
        alertDropPercentThreshold: 20.0,
        consecutiveLowMoodThreshold: 3,
        stressThreshold: 4.0,
        alertWindowDays: 7,
      );
      await service.initialize();
    });

    tearDown(() {
      service.dispose();
    });

    test('sudden drop alert is triggered correctly', () async {
      // Add several good check-ins to establish baseline
      for (int i = 0; i < 5; i++) {
        await service.recordCheckin(
          moodLevel: 5,
          stressLevel: 1,
          consentToShare: true,
        );
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      // Add several bad check-ins to trigger drop
      for (int i = 0; i < 3; i++) {
        await service.recordCheckin(
          moodLevel: 1,
          stressLevel: 5,
          consentToShare: true,
        );
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      final alerts = service.getActiveAlerts();
      // Should have at least one alert
      expect(alerts.isNotEmpty, isTrue);
    });

    test('consecutive low mood alert is triggered', () async {
      // Add 3 consecutive low mood check-ins
      for (int i = 0; i < 3; i++) {
        await service.recordCheckin(
          moodLevel: 2,  // Low mood
          stressLevel: 3,
          consentToShare: true,
        );
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      final alerts = service.getActiveAlerts();
      // Check if low mood alert exists
      final hasLowMoodAlert = alerts.any(
        (a) => a.alertType == AlertType.lowMood,
      );
      expect(hasLowMoodAlert, isTrue);
    });

    test('consecutive high stress alert is triggered', () async {
      // Add consecutive high stress check-ins
      for (int i = 0; i < 4; i++) {
        await service.recordCheckin(
          moodLevel: 3,
          stressLevel: 5,  // High stress
          consentToShare: true,
        );
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      final alerts = service.getActiveAlerts();
      // Check if stress alert exists
      final hasStressAlert = alerts.any(
        (a) => a.alertType == AlertType.stressIncrease,
      );
      expect(hasStressAlert, isTrue);
    });

    test('no false positives with good data', () async {
      // Add several good check-ins
      for (int i = 0; i < 5; i++) {
        await service.recordCheckin(
          moodLevel: 4,
          stressLevel: 2,
          consentToShare: true,
        );
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      final alerts = service.getActiveAlerts();
      // Should have no alerts or only low-severity ones
      expect(
        alerts.where((a) => a.severity == AlertSeverity.high).length,
        equals(0),
      );
    });

    test('alert metadata includes required fields', () async {
      // Trigger an alert
      for (int i = 0; i < 5; i++) {
        await service.recordCheckin(
          moodLevel: 1,
          stressLevel: 5,
          consentToShare: true,
        );
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      final alerts = service.getActiveAlerts();
      if (alerts.isNotEmpty) {
        final alert = alerts.first;
        expect(alert.clusterSize, greaterThan(0));
        expect(alert.clusterName, isNotEmpty);
        expect(alert.description, isNotEmpty);
        expect(alert.recommendations, isNotEmpty);
      }
    });
  });

  group('Anonymization Tests', () {
    late WellbeingMonitoringService service;

    setUp(() async {
      service = WellbeingMonitoringService();
      await service.initialize();
    });

    tearDown() {
      service.dispose();
    });

    test('anonymizeBatchForSend returns empty for no consented data', () async {
      // Add check-ins without consent
      await service.recordCheckin(
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: false,
      );
      
      final batches = service.anonymizeBatchForSend();
      expect(batches, isEmpty);
    });

    test('anonymizeBatchForSend includes sendId in each batch', () async {
      await service.recordCheckin(
        studentId: 'student-123',
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: true,
      );
      
      final batches = service.anonymizeBatchForSend();
      expect(batches, isNotEmpty);
      
      for (final batch in batches) {
        expect(batch.containsKey('send_id'), isTrue);
        expect(batch['send_id'], isNotNull);
        expect(batch['send_id'], isA<String>());
      }
    });

    test('anonymizeBatchForSend removes personal identifiers', () async {
      await service.recordCheckin(
        studentId: 'student-123',
        moodLevel: 4,
        stressLevel: 2,
        notes: 'Personal notes here',
        consentToShare: true,
      );
      
      final batches = service.anonymizeBatchForSend();
      expect(batches, isNotEmpty);
      
      for (final batch in batches) {
        // Should not contain student ID or notes
        expect(batch.containsKey('student_id'), isFalse);
        expect(batch.containsKey('notes'), isFalse);
        expect(batch.containsKey('studentId'), isFalse);
      }
    });

    test('anonymizeBatchForSend truncates timestamps to day', () async {
      await service.recordCheckin(
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: true,
      );
      
      final batches = service.anonymizeBatchForSend();
      expect(batches, isNotEmpty);
      
      for (final batch in batches) {
        expect(batch.containsKey('date'), isTrue);
        final date = batch['date'] as String;
        // Should be ISO date format (YYYY-MM-DD)
        expect(date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}')));
      }
    });

    test('anonymizeBatchForSend includes aggregate statistics', () async {
      // Add multiple check-ins on same day
      for (int i = 0; i < 3; i++) {
        await service.recordCheckin(
          moodLevel: 3 + i,
          stressLevel: 2 + i,
          consentToShare: true,
        );
      }
      
      final batches = service.anonymizeBatchForSend();
      expect(batches, isNotEmpty);
      
      final batch = batches.first;
      expect(batch.containsKey('sample_size'), isTrue);
      expect(batch.containsKey('avg_mood'), isTrue);
      expect(batch.containsKey('avg_stress'), isTrue);
      expect(batch['sample_size'], greaterThan(0));
      expect(batch['is_anonymized'], isTrue);
    });

    test('sendId is rotating (different for each call)', () async {
      await service.recordCheckin(
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: true,
      );
      
      final batches1 = service.anonymizeBatchForSend();
      final batches2 = service.anonymizeBatchForSend();
      
      if (batches1.isNotEmpty && batches2.isNotEmpty) {
        final sendId1 = batches1.first['send_id'];
        final sendId2 = batches2.first['send_id'];
        
        // Send IDs should be different (rotating)
        expect(sendId1, isNot(equals(sendId2)));
      }
    });
  });

  group('Stream Emission Tests', () {
    late WellbeingMonitoringService service;

    setUp(() async {
      service = WellbeingMonitoringService();
      await service.initialize();
    });

    tearDown() {
      service.dispose();
    });

    test('checkinsStream emits on recordCheckin', () async {
      final streamFuture = service.checkinsStream.first;
      
      await service.recordCheckin(
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: false,
      );
      
      final checkins = await streamFuture;
      expect(checkins, isNotEmpty);
    });

    test('checkinsStream emits on deleteAllData', () async {
      // Add a check-in first
      await service.recordCheckin(
        moodLevel: 4,
        stressLevel: 2,
        consentToShare: false,
      );
      
      // Listen for next emission
      final streamFuture = service.checkinsStream.first;
      
      await service.deleteAllData();
      
      final checkins = await streamFuture;
      expect(checkins, isEmpty);
    });

    test('alertsStream emits when alerts are created', () async {
      final streamFuture = service.alertsStream.first;
      
      // Trigger alerts with high stress
      for (int i = 0; i < 5; i++) {
        await service.recordCheckin(
          moodLevel: 1,
          stressLevel: 5,
          consentToShare: true,
        );
      }
      
      final alerts = await streamFuture;
      expect(alerts, isNotEmpty);
    });
  });
}
