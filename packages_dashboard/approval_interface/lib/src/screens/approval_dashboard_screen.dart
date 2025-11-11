import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/approval_item.dart';
import '../providers/approval_provider.dart';
import '../widgets/approval_list.dart';

/// Main dashboard screen for approval interface
///
/// This screen provides a unified view of all pending approvals
/// with filtering, bulk operations, and detailed statistics.
class ApprovalDashboardScreen extends ConsumerStatefulWidget {
  const ApprovalDashboardScreen({super.key});

  @override
  ConsumerState<ApprovalDashboardScreen> createState() =>
      _ApprovalDashboardScreenState();
}

class _ApprovalDashboardScreenState
    extends ConsumerState<ApprovalDashboardScreen> {
  ApprovalType? _filterType;
  ApprovalPriority? _filterPriority;
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    // Fetch pending items when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(approvalProvider.notifier).fetchPendingItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final approvalState = ref.watch(approvalProvider);
    final selectedItems = ref.watch(selectedItemsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprovações Pendentes'),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtros',
          ),
          // Selection mode toggle
          IconButton(
            icon: Icon(_selectionMode ? Icons.check_box : Icons.check_box_outline_blank),
            onPressed: () {
              setState(() {
                _selectionMode = !_selectionMode;
                if (!_selectionMode) {
                  // Clear selection when exiting selection mode
                  ref.read(selectedItemsProvider.notifier).state = {};
                }
              });
            },
            tooltip: 'Modo de seleção',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics card
          _buildStatsCard(approvalState.items),

          // Active filters chip
          if (_filterType != null || _filterPriority != null)
            _buildActiveFiltersChip(),

          // List of approval items
          Expanded(
            child: ApprovalList(
              enableSelection: _selectionMode,
              showActions: !_selectionMode,
            ),
          ),

          // Bulk actions bar (shown when items are selected)
          if (_selectionMode && selectedItems.isNotEmpty)
            _buildBulkActionsBar(selectedItems),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref.read(approvalProvider.notifier).refresh();
        },
        tooltip: 'Atualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStatsCard(List<ApprovalItem> items) {
    final theme = Theme.of(context);

    // Calculate statistics
    final totalPending = items.where((i) => i.status == ApprovalStatus.pending).length;
    final criticalCount = items.where((i) => i.priority == ApprovalPriority.critical).length;
    final codeReviewCount = items.where((i) => i.type == ApprovalType.codeReview).length;
    final gradingCount = items.where((i) => i.type == ApprovalType.grading).length;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.pending_actions,
                  label: 'Pendentes',
                  value: totalPending.toString(),
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.priority_high,
                  label: 'Críticos',
                  value: criticalCount.toString(),
                  color: theme.colorScheme.error,
                ),
                _buildStatItem(
                  icon: Icons.code,
                  label: 'Code Reviews',
                  value: codeReviewCount.toString(),
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.grade,
                  label: 'Avaliações',
                  value: gradingCount.toString(),
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFiltersChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_filterType != null)
            Chip(
              label: Text(_getTypeLabel(_filterType!)),
              onDeleted: () {
                setState(() => _filterType = null);
                _applyFilters();
              },
            ),
          if (_filterPriority != null)
            Chip(
              label: Text(_getPriorityLabel(_filterPriority!)),
              onDeleted: () {
                setState(() => _filterPriority = null);
                _applyFilters();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBulkActionsBar(Set<String> selectedItems) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedItems.length} selecionado(s)',
              style: theme.textTheme.titleMedium,
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(selectedItemsProvider.notifier).state = {};
                  },
                  child: const Text('Limpar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _handleBulkApprove(selectedItems),
                  icon: const Icon(Icons.check),
                  label: const Text('Aprovar Todos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filtros'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tipo'),
              DropdownButton<ApprovalType?>(
                value: _filterType,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ...ApprovalType.values.map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeLabel(type)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _filterType = value);
                },
              ),
              const SizedBox(height: 16),
              const Text('Prioridade'),
              DropdownButton<ApprovalPriority?>(
                value: _filterPriority,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ...ApprovalPriority.values.map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(_getPriorityLabel(priority)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _filterPriority = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _filterType = null;
                  _filterPriority = null;
                });
              },
              child: const Text('Limpar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyFilters();
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_filterType != null) {
      filters['type'] = _filterType.toString().split('.').last;
    }

    if (_filterPriority != null) {
      filters['priority'] = _filterPriority.toString().split('.').last;
    }

    ref.read(approvalProvider.notifier).fetchPendingItems(filters: filters);
  }

  Future<void> _handleBulkApprove(Set<String> itemIds) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Aprovação em Massa'),
        content: Text(
          'Tem certeza que deseja aprovar ${itemIds.length} item(ns)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final results = await ref
          .read(approvalProvider.notifier)
          .bulkApprove(itemIds.toList());

      final successCount = results.values.where((v) => v).length;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount item(ns) aprovado(s) com sucesso'),
            backgroundColor: Colors.green,
          ),
        );

        // Exit selection mode and clear selection
        setState(() => _selectionMode = false);
        ref.read(selectedItemsProvider.notifier).state = {};
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao aprovar items: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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

  String _getPriorityLabel(ApprovalPriority priority) {
    switch (priority) {
      case ApprovalPriority.critical:
        return 'Crítico';
      case ApprovalPriority.high:
        return 'Alto';
      case ApprovalPriority.normal:
        return 'Normal';
      case ApprovalPriority.low:
        return 'Baixo';
    }
  }
}
