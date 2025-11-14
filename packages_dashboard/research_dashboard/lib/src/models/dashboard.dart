/// Dashboard metrics for coordinator
class CoordinatorDashboard {
  final int totalProjects;
  final int activeProjects;
  final int archivedProjects;
  final double completionRate;
  final double avgStudentsPerAdvisor;
  final int projectsInRisk;
  final int atRiskCount;
  final int criticalCount;
  final int studentsWithoutAdvisor;
  final int activeAlertsCount;
  final Map<String, int> statusBreakdown;
  final Map<String, int> healthBreakdown;

  const CoordinatorDashboard({
    required this.totalProjects,
    required this.activeProjects,
    required this.archivedProjects,
    required this.completionRate,
    required this.avgStudentsPerAdvisor,
    required this.projectsInRisk,
    required this.atRiskCount,
    required this.criticalCount,
    required this.studentsWithoutAdvisor,
    required this.activeAlertsCount,
    required this.statusBreakdown,
    required this.healthBreakdown,
  });

  factory CoordinatorDashboard.fromJson(Map<String, dynamic> json) {
    return CoordinatorDashboard(
      totalProjects: json['total_projects'] as int,
      activeProjects: json['active_projects'] as int,
      archivedProjects: json['archived_projects'] as int,
      completionRate: (json['completion_rate'] as num).toDouble(),
      avgStudentsPerAdvisor:
          (json['avg_students_per_advisor'] as num).toDouble(),
      projectsInRisk: json['projects_in_risk'] as int,
      atRiskCount: json['at_risk_count'] as int,
      criticalCount: json['critical_count'] as int,
      studentsWithoutAdvisor: json['students_without_advisor'] as int,
      activeAlertsCount: json['active_alerts_count'] as int,
      statusBreakdown:
          Map<String, int>.from(json['status_breakdown'] as Map),
      healthBreakdown:
          Map<String, int>.from(json['health_breakdown'] as Map),
    );
  }
}

/// Dashboard metrics for advisor
class AdvisorDashboard {
  final int totalProjects;
  final int activeProjects;
  final int totalStudents;
  final int activeAlerts;
  final List<ProjectSummary> projects;

  const AdvisorDashboard({
    required this.totalProjects,
    required this.activeProjects,
    required this.totalStudents,
    required this.activeAlerts,
    required this.projects,
  });

  factory AdvisorDashboard.fromJson(Map<String, dynamic> json) {
    return AdvisorDashboard(
      totalProjects: json['total_projects'] as int,
      activeProjects: json['active_projects'] as int,
      totalStudents: json['total_students'] as int,
      activeAlerts: json['active_alerts'] as int,
      projects: (json['projects'] as List)
          .map((e) => ProjectSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Dashboard metrics for student
class StudentDashboard {
  final bool hasProject;
  final String? projectId;
  final String? projectTitle;
  final String? status;
  final String? healthStatus;
  final String? area;
  final String? expectedEndDate;
  final bool? hasAdvisor;
  final int? activeAlerts;
  final String? message;

  const StudentDashboard({
    required this.hasProject,
    this.projectId,
    this.projectTitle,
    this.status,
    this.healthStatus,
    this.area,
    this.expectedEndDate,
    this.hasAdvisor,
    this.activeAlerts,
    this.message,
  });

  factory StudentDashboard.fromJson(Map<String, dynamic> json) {
    return StudentDashboard(
      hasProject: json['has_project'] as bool,
      projectId: json['project_id'] as String?,
      projectTitle: json['project_title'] as String?,
      status: json['status'] as String?,
      healthStatus: json['health_status'] as String?,
      area: json['area'] as String?,
      expectedEndDate: json['expected_end_date'] as String?,
      hasAdvisor: json['has_advisor'] as bool?,
      activeAlerts: json['active_alerts'] as int?,
      message: json['message'] as String?,
    );
  }
}

/// Project summary for lists
class ProjectSummary {
  final String projectId;
  final String title;
  final String status;
  final String healthStatus;

  const ProjectSummary({
    required this.projectId,
    required this.title,
    required this.status,
    required this.healthStatus,
  });

  factory ProjectSummary.fromJson(Map<String, dynamic> json) {
    return ProjectSummary(
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      healthStatus: json['health_status'] as String,
    );
  }
}
