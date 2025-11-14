import 'package:flutter_test/flutter_test.dart';
import 'package:research_dashboard/research_dashboard.dart';

void main() {
  test('ResearchManagementService can be instantiated', () {
    final service = ResearchManagementService();
    expect(service, isNotNull);
  });

  test('ProjectStatus enum has correct values', () {
    expect(ProjectStatus.active.value, 'active');
    expect(ProjectStatus.completed.value, 'completed');
  });

  test('HealthStatus enum has correct values', () {
    expect(HealthStatus.onTrack.value, 'on_track');
    expect(HealthStatus.atRisk.value, 'at_risk');
    expect(HealthStatus.critical.value, 'critical');
  });
}
