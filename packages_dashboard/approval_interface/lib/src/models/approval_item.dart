/// Model representing an item pending approval
///
/// This generic model can represent various types of content requiring approval,
/// such as code reviews, grades, awards, content, or issues.
class ApprovalItem {
  /// Unique identifier for the approval item
  final String id;

  /// Type of the approval item (e.g., 'code_review', 'grading', 'award', 'content', 'issue')
  final ApprovalType type;

  /// Title of the item
  final String title;

  /// Optional description or subtitle
  final String? description;

  /// Priority level of the approval
  final ApprovalPriority priority;

  /// Current status of the approval
  final ApprovalStatus status;

  /// The generated content or data (can be any structure)
  final Map<String, dynamic>? content;

  /// ID of the user assigned to review this item
  final String? assignedTo;

  /// When the item was created
  final DateTime createdAt;

  /// When the item was last reviewed
  final DateTime? reviewedAt;

  /// When the item was approved
  final DateTime? approvedAt;

  /// Optional metadata for additional information
  final Map<String, dynamic>? metadata;

  /// Constructor
  ApprovalItem({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.priority = ApprovalPriority.normal,
    this.status = ApprovalStatus.pending,
    this.content,
    this.assignedTo,
    required this.createdAt,
    this.reviewedAt,
    this.approvedAt,
    this.metadata,
  });

  /// Create an ApprovalItem from JSON
  factory ApprovalItem.fromJson(Map<String, dynamic> json) {
    return ApprovalItem(
      id: json['id'] as String,
      type: ApprovalType.values.firstWhere(
        (e) => e.toString() == 'ApprovalType.${json['type']}',
        orElse: () => ApprovalType.other,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: ApprovalPriority.values.firstWhere(
        (e) => e.toString() == 'ApprovalPriority.${json['priority']}',
        orElse: () => ApprovalPriority.normal,
      ),
      status: ApprovalStatus.values.firstWhere(
        (e) => e.toString() == 'ApprovalStatus.${json['status']}',
        orElse: () => ApprovalStatus.pending,
      ),
      content: json['content'] as Map<String, dynamic>?,
      assignedTo: json['assigned_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert ApprovalItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'content': content,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with modified fields
  ApprovalItem copyWith({
    String? id,
    ApprovalType? type,
    String? title,
    String? description,
    ApprovalPriority? priority,
    ApprovalStatus? status,
    Map<String, dynamic>? content,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? reviewedAt,
    DateTime? approvedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ApprovalItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      content: content ?? this.content,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'ApprovalItem(id: $id, type: $type, title: $title, status: $status)';
  }
}

/// Types of approval items
enum ApprovalType {
  codeReview,
  grading,
  award,
  content,
  issue,
  other,
}

/// Priority levels for approval
enum ApprovalPriority {
  critical,
  high,
  normal,
  low,
}

/// Status of approval item
enum ApprovalStatus {
  pending,
  inReview,
  approved,
  rejected,
}
