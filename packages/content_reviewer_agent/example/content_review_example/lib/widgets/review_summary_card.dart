import 'package:flutter/material.dart';
import '../models/review_models.dart';

class ReviewSummaryCard extends StatelessWidget {
  final ReviewResult result;

  const ReviewSummaryCard({
    required this.result,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.summarize, size: 32, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Review Summary',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (result.qualityScore != null)
                  _buildQualityScoreBadge(context),
              ],
            ),
            const Divider(height: 24),

            // Summary text
            Text(
              result.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Issue counts
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildCountChip(
                  'Critical',
                  result.criticalCount,
                  Colors.red.shade700,
                ),
                _buildCountChip(
                  'High',
                  result.highCount,
                  Colors.orange.shade700,
                ),
                _buildCountChip(
                  'Medium',
                  result.mediumCount,
                  Colors.yellow.shade700,
                ),
                _buildCountChip(
                  'Low',
                  result.lowCount,
                  Colors.blue.shade700,
                ),
              ],
            ),

            // Recommendations
            if (result.recommendations.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...result.recommendations.map((rec) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(rec),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Metadata
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(result.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.verified, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      result.status.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityScoreBadge(BuildContext context) {
    final score = result.qualityScore!;
    final color = score >= 80
        ? Colors.green
        : score >= 60
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            '${score.toInt()}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'Quality',
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, int count, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
