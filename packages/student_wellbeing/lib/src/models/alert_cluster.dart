/// Represents an anonymized cluster alert for early warning.
///
/// Alerts are generated for aggregated groups without identifying individuals,
/// ensuring LGPD/GDPR compliance.
class AlertCluster {
  /// Unique identifier for this alert.
  final String id;

  /// Anonymous cluster identifier (e.g., "Cluster-A", "Turma-3B").
  final String clusterName;

  /// Type of alert detected.
  final AlertType alertType;

  /// Severity level of the alert.
  final AlertSeverity severity;

  /// Human-readable description of the pattern detected.
  final String description;

  /// Timestamp when the alert was generated.
  final DateTime timestamp;

  /// Number of individuals in the cluster (without identifying them).
  final int clusterSize;

  /// Percentage change that triggered the alert.
  final double? percentageChange;

  /// Recommended actions for educators/counselors.
  final List<String> recommendations;

  const AlertCluster({
    required this.id,
    required this.clusterName,
    required this.alertType,
    required this.severity,
    required this.description,
    required this.timestamp,
    required this.clusterSize,
    this.percentageChange,
    required this.recommendations,
  });

  /// Creates an alert from JSON data.
  factory AlertCluster.fromJson(Map<String, dynamic> json) {
    return AlertCluster(
      id: json['id'] as String,
      clusterName: json['cluster_name'] as String,
      alertType: AlertType.values.firstWhere(
        (e) => e.name == json['alert_type'],
        orElse: () => AlertType.generalConcern,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.medium,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      clusterSize: json['cluster_size'] as int,
      percentageChange: json['percentage_change'] as double?,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  /// Converts this alert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cluster_name': clusterName,
      'alert_type': alertType.name,
      'severity': severity.name,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'cluster_size': clusterSize,
      'percentage_change': percentageChange,
      'recommendations': recommendations,
    };
  }

  @override
  String toString() {
    return 'AlertCluster($clusterName: $description, '
        'severity: $severity)';
  }
}

/// Types of alerts that can be generated.
enum AlertType {
  /// Sudden increase in stress levels.
  stressIncrease,

  /// Persistent low mood across cluster.
  lowMood,

  /// General concerning wellbeing pattern.
  generalConcern,

  /// Declining trend detected.
  decliningTrend,
}

/// Severity levels for alerts.
enum AlertSeverity {
  /// Requires immediate attention.
  high,

  /// Should be addressed soon.
  medium,

  /// Monitoring recommended.
  low,
}
