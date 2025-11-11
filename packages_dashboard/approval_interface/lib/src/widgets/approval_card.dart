import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/approval_item.dart';

/// A card widget that displays an approval item
///
/// This widget shows the item's title, description, priority, status,
/// and provides action buttons for approve/reject.
class ApprovalCard extends StatelessWidget {
  final ApprovalItem item;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;
  final bool showActions;

  const ApprovalCard({
    super.key,
    required this.item,
    this.onTap,
    this.onApprove,
    this.onReject,
    this.isSelected = false,
    this.onSelectChanged,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with checkbox, title, and priority badge
              Row(
                children: [
                  if (onSelectChanged != null)
                    Checkbox(
                      value: isSelected,
                      onChanged: onSelectChanged,
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildTypeChip(context),
                      ],
                    ),
                  ),
                  _buildPriorityBadge(context),
                ],
              ),

              if (item.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  item.description!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Metadata row
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    context,
                    icon: Icons.calendar_today,
                    label: _formatDate(item.createdAt),
                  ),
                  _buildStatusChip(context),
                  if (item.assignedTo != null)
                    _buildInfoChip(
                      context,
                      icon: Icons.person,
                      label: item.assignedTo!,
                    ),
                ],
              ),

              // Actions
              if (showActions && item.status == ApprovalStatus.pending) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onReject != null)
                      TextButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close),
                        label: const Text('Rejeitar'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.error,
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (onApprove != null)
                      ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check),
                        label: const Text('Aprovar'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = _getTypeLabel(item.type);

    return Chip(
      label: Text(
        typeLabel,
        style: theme.textTheme.bodySmall,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color badgeColor;
    IconData icon;

    switch (item.priority) {
      case ApprovalPriority.critical:
        badgeColor = colorScheme.error;
        icon = Icons.priority_high;
        break;
      case ApprovalPriority.high:
        badgeColor = Colors.orange;
        icon = Icons.arrow_upward;
        break;
      case ApprovalPriority.normal:
        badgeColor = Colors.blue;
        icon = Icons.horizontal_rule;
        break;
      case ApprovalPriority.low:
        badgeColor = Colors.grey;
        icon = Icons.arrow_downward;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: badgeColor, size: 20),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Color chipColor;
    String label;

    switch (item.status) {
      case ApprovalStatus.pending:
        chipColor = Colors.orange;
        label = 'Pendente';
        break;
      case ApprovalStatus.inReview:
        chipColor = Colors.blue;
        label = 'Em Revisão';
        break;
      case ApprovalStatus.approved:
        chipColor = Colors.green;
        label = 'Aprovado';
        break;
      case ApprovalStatus.rejected:
        chipColor = colorScheme.error;
        label = 'Rejeitado';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: chipColor),
      ),
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getTypeLabel(ApprovalType type) {
    switch (type) {
      case ApprovalType.codeReview:
        return 'Code Review';
      case ApprovalType.grading:
        return 'Avaliação';
      case ApprovalType.award:
        return 'Premiação';
      case ApprovalType.content:
        return 'Conteúdo';
      case ApprovalType.issue:
        return 'Issue';
      case ApprovalType.other:
        return 'Outro';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}min atrás';
      }
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
