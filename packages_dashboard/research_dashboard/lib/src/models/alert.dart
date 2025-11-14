/// Alert model
class Alert {
  final String alertId;
  final AlertType type;
  final String? projectId;
  final String? userId;
  final String message;
  final AlertSeverity severity;
  final AlertStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const Alert({
    required this.alertId,
    required this.type,
    this.projectId,
    this.userId,
    required this.message,
    required this.severity,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      alertId: json['alert_id'] as String,
      type: AlertType.fromString(json['type'] as String),
      projectId: json['project_id'] as String?,
      userId: json['user_id'] as String?,
      message: json['message'] as String,
      severity: AlertSeverity.fromString(json['severity'] as String),
      status: AlertStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }
}

/// Alert type enum
enum AlertType {
  noAdvisor('no_advisor'),
  noUpdate('no_update'),
  deadlineSoon('deadline_soon'),
  meetingReminder('meeting_reminder');

  final String value;
  const AlertType(this.value);

  static AlertType fromString(String value) {
    return AlertType.values.firstWhere((e) => e.value == value);
  }

  String get displayName {
    switch (this) {
      case AlertType.noAdvisor:
        return 'Sem Orientador';
      case AlertType.noUpdate:
        return 'Sem Atualização';
      case AlertType.deadlineSoon:
        return 'Prazo Próximo';
      case AlertType.meetingReminder:
        return 'Lembrete de Reunião';
    }
  }
}

/// Alert severity enum
enum AlertSeverity {
  info('info'),
  warning('warning'),
  critical('critical');

  final String value;
  const AlertSeverity(this.value);

  static AlertSeverity fromString(String value) {
    return AlertSeverity.values.firstWhere((e) => e.value == value);
  }

  String get displayName {
    switch (this) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Aviso';
      case AlertSeverity.critical:
        return 'Crítico';
    }
  }

  String get emoji {
    switch (this) {
      case AlertSeverity.info:
        return '🟢';
      case AlertSeverity.warning:
        return '🟡';
      case AlertSeverity.critical:
        return '🔴';
    }
  }
}

/// Alert status enum
enum AlertStatus {
  active('active'),
  resolved('resolved'),
  dismissed('dismissed');

  final String value;
  const AlertStatus(this.value);

  static AlertStatus fromString(String value) {
    return AlertStatus.values.firstWhere((e) => e.value == value);
  }
}
