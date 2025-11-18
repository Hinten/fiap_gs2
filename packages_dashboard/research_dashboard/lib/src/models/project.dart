/// Research project model
class ResearchProject {
  final String projectId;
  final String title;
  final String description;
  final String area;
  final ProjectStatus status;
  final HealthStatus healthStatus;
  final DateTime? startDate;
  final DateTime? expectedEndDate;
  final DateTime? actualEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ResearchProject({
    required this.projectId,
    required this.title,
    required this.description,
    required this.area,
    required this.status,
    required this.healthStatus,
    this.startDate,
    this.expectedEndDate,
    this.actualEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResearchProject.fromJson(Map<String, dynamic> json) {
    return ResearchProject(
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      area: json['area'] as String,
      status: ProjectStatus.fromString(json['status'] as String),
      healthStatus: HealthStatus.fromString(json['health_status'] as String),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      expectedEndDate: json['expected_end_date'] != null
          ? DateTime.parse(json['expected_end_date'] as String)
          : null,
      actualEndDate: json['actual_end_date'] != null
          ? DateTime.parse(json['actual_end_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'title': title,
      'description': description,
      'area': area,
      'status': status.value,
      'health_status': healthStatus.value,
      'start_date': startDate?.toIso8601String(),
      'expected_end_date': expectedEndDate?.toIso8601String(),
      'actual_end_date': actualEndDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Project status enum
enum ProjectStatus {
  proposal('proposal'),
  active('active'),
  paused('paused'),
  completed('completed'),
  archived('archived');

  final String value;
  const ProjectStatus(this.value);

  static ProjectStatus fromString(String value) {
    return ProjectStatus.values.firstWhere((e) => e.value == value);
  }

  String get displayName {
    switch (this) {
      case ProjectStatus.proposal:
        return 'Proposta';
      case ProjectStatus.active:
        return 'Ativo';
      case ProjectStatus.paused:
        return 'Pausado';
      case ProjectStatus.completed:
        return 'Concluído';
      case ProjectStatus.archived:
        return 'Arquivado';
    }
  }
}

/// Project health status enum
enum HealthStatus {
  onTrack('on_track'),
  atRisk('at_risk'),
  critical('critical');

  final String value;
  const HealthStatus(this.value);

  static HealthStatus fromString(String value) {
    return HealthStatus.values.firstWhere((e) => e.value == value);
  }

  String get displayName {
    switch (this) {
      case HealthStatus.onTrack:
        return '🟢 No Prazo';
      case HealthStatus.atRisk:
        return '🟡 Em Risco';
      case HealthStatus.critical:
        return '🔴 Crítico';
    }
  }

  String get emoji {
    switch (this) {
      case HealthStatus.onTrack:
        return '🟢';
      case HealthStatus.atRisk:
        return '🟡';
      case HealthStatus.critical:
        return '🔴';
    }
  }
}
