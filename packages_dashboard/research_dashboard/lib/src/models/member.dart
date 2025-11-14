/// Project member model
class ProjectMember {
  final String projectId;
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;
  final DateTime? leftAt;

  const ProjectMember({
    required this.projectId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.leftAt,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      projectId: json['project_id'] as String,
      userId: json['user_id'] as String,
      role: MemberRole.fromString(json['role'] as String),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      leftAt: json['left_at'] != null
          ? DateTime.parse(json['left_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'user_id': userId,
      'role': role.value,
      'joined_at': joinedAt.toIso8601String(),
      'left_at': leftAt?.toIso8601String(),
    };
  }
}

/// Member role enum
enum MemberRole {
  student('student'),
  advisor('advisor'),
  coAdvisor('co-advisor'),
  coordinator('coordinator');

  final String value;
  const MemberRole(this.value);

  static MemberRole fromString(String value) {
    return MemberRole.values.firstWhere((e) => e.value == value);
  }

  String get displayName {
    switch (this) {
      case MemberRole.student:
        return 'Aluno';
      case MemberRole.advisor:
        return 'Orientador';
      case MemberRole.coAdvisor:
        return 'Co-orientador';
      case MemberRole.coordinator:
        return 'Coordenador';
    }
  }
}
