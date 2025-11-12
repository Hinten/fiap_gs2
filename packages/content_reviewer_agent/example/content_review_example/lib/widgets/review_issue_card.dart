import 'package:flutter/material.dart';
import '../models/review_models.dart';

class ReviewIssueCard extends StatelessWidget {
  final ReviewIssue issue;

  const ReviewIssueCard({required this.issue, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, type, and severity
            Row(
              children: [
                Icon(issue.typeIcon, color: issue.severityColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    _formatIssueType(issue.issueType),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildSeverityBadge(context),
              ],
            ),

            // Agent information
            if (issue.reviewedByAgent != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.smart_toy, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SelectableText(
                      issue.reviewedByAgent!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const Divider(height: 16),

            // Description
            SelectableText(
              issue.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            // Location
            if (issue.location != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  SelectableText(
                    issue.location!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],

            // Original text
            if (issue.originalText != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.close, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SelectableText(
                        issue.originalText!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Suggested fix
            if (issue.suggestedFix != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SelectableText(
                        issue.suggestedFix!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Sources
            if (issue.sources.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: issue.sources.map((source) {
                  return Chip(
                    label: SelectableText(source, style: const TextStyle(fontSize: 12)),
                    avatar: const Icon(Icons.link, size: 16),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],

            // Confidence
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Confidence: '),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    value: issue.confidence,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      issue.confidence > 0.8
                          ? Colors.green
                          : issue.confidence > 0.6
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(issue.confidence * 100).toInt()}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: issue.severityColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: issue.severityColor),
      ),
      child: Text(
        issue.severity.name.toUpperCase(),
        style: TextStyle(
          color: issue.severityColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatIssueType(IssueType type) {
    return type.name[0].toUpperCase() +
        type.name
            .substring(1)
            .replaceAllMapped(
              RegExp(r'[A-Z]'),
              (match) => ' ${match.group(0)}',
            );
  }
}
