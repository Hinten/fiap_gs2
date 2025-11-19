/// Models for content review
library;

// Import necessary packages at the top
import 'package:flutter/material.dart';

/// Issue severity levels
enum IssueSeverity { critical, high, medium, low, info }

/// Types of issues
enum IssueType {
  spelling,
  grammar,
  syntax,
  comprehension,
  source,
  outdated,
  deprecated,
  technical,
  factual,
}

/// Types of review
enum ReviewType {
  fullReview,
  errorDetection,
  comprehension,
  sourceVerification,
  contentUpdate,
}

/// A review issue found in content
class ReviewIssue {
  final String issueId;
  final String contentId;
  final IssueType issueType;
  final IssueSeverity severity;
  final String description;
  final String? location;
  final String? originalText;
  final String? suggestedFix;
  final List<String> sources;
  final double confidence;
  final String? reviewedByAgent;
  final DateTime createdAt;

  const ReviewIssue({
    required this.issueId,
    required this.contentId,
    required this.issueType,
    required this.severity,
    required this.description,
    this.location,
    this.originalText,
    this.suggestedFix,
    this.sources = const [],
    required this.confidence,
    this.reviewedByAgent,
    required this.createdAt,
  });

  factory ReviewIssue.fromJson(Map<String, dynamic> json) {
    return ReviewIssue(
      issueId: json['issue_id'] as String,
      contentId: json['content_id'] as String,
      issueType: IssueType.values.firstWhere(
        (e) => e.name == json['issue_type'],
        orElse: () => IssueType.technical,
      ),
      severity: IssueSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => IssueSeverity.medium,
      ),
      description: json['description'] as String,
      location: json['location'] as String?,
      originalText: json['original_text'] as String?,
      suggestedFix: json['suggested_fix'] as String?,
      sources:
          (json['sources'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      reviewedByAgent: json['reviewed_by_agent'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Get color based on severity
  Color get severityColor {
    switch (severity) {
      case IssueSeverity.critical:
        return Colors.red.shade700;
      case IssueSeverity.high:
        return Colors.orange.shade700;
      case IssueSeverity.medium:
        return Colors.yellow.shade700;
      case IssueSeverity.low:
        return Colors.blue.shade700;
      case IssueSeverity.info:
        return Colors.grey.shade700;
    }
  }

  /// Get icon based on issue type
  IconData get typeIcon {
    switch (issueType) {
      case IssueType.spelling:
        return Icons.spellcheck;
      case IssueType.grammar:
        return Icons.text_fields;
      case IssueType.syntax:
        return Icons.code;
      case IssueType.comprehension:
        return Icons.lightbulb_outline;
      case IssueType.source:
        return Icons.link;
      case IssueType.outdated:
        return Icons.update;
      case IssueType.deprecated:
        return Icons.warning;
      case IssueType.technical:
        return Icons.engineering;
      case IssueType.factual:
        return Icons.fact_check;
    }
  }
}

/// Review result from the API
class ReviewResult {
  final String reviewId;
  final String contentId;
  final ReviewType reviewType;
  final String status;
  final List<ReviewIssue> issues;
  final String summary;
  final List<String> recommendations;
  final double? qualityScore;
  final DateTime createdAt;
  final DateTime? completedAt;

  const ReviewResult({
    required this.reviewId,
    required this.contentId,
    required this.reviewType,
    required this.status,
    required this.issues,
    required this.summary,
    required this.recommendations,
    this.qualityScore,
    required this.createdAt,
    this.completedAt,
  });

  factory ReviewResult.fromJson(Map<String, dynamic> json) {
    return ReviewResult(
      reviewId: json['review_id'] as String,
      contentId: json['content_id'] as String,
      reviewType: ReviewType.values.firstWhere(
        (e) => _toSnakeCase(e.name) == json['review_type'],
        orElse: () => ReviewType.fullReview,
      ),
      status: json['status'] as String,
      issues:
          (json['issues'] as List<dynamic>?)
              ?.map((e) => ReviewIssue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] as String? ?? '',
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      qualityScore: (json['quality_score'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  int get criticalCount =>
      issues.where((i) => i.severity == IssueSeverity.critical).length;
  int get highCount =>
      issues.where((i) => i.severity == IssueSeverity.high).length;
  int get mediumCount =>
      issues.where((i) => i.severity == IssueSeverity.medium).length;
  int get lowCount =>
      issues.where((i) => i.severity == IssueSeverity.low).length;
}

String _toSnakeCase(String str) {
  final result = str.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (match) => '_${match.group(0)!.toLowerCase()}',
  );
  // Remove leading underscore only if string starts with it
  return result.startsWith('_') ? result.substring(1) : result;
}
