import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/approval_item.dart';
import '../providers/approval_provider.dart';
import 'approval_card.dart';

/// A list widget that displays approval items
///
/// This widget manages the display of multiple approval items,
/// including loading states, error handling, and empty states.
class ApprovalList extends ConsumerWidget {
  final VoidCallback? onItemTap;
  final bool enableSelection;
  final bool showActions;

  const ApprovalList({
    super.key,
    this.onItemTap,
    this.enableSelection = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalState = ref.watch(approvalProvider);
    final selectedItems = ref.watch(selectedItemsProvider);

    if (approvalState.isLoading && approvalState.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (approvalState.error != null && approvalState.items.isEmpty) {
      return _buildErrorState(context, ref, approvalState.error!);
    }

    if (approvalState.items.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(approvalProvider.notifier).refresh();
      },
      child: ListView.builder(
        itemCount: approvalState.items.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final item = approvalState.items[index];
          final isSelected = selectedItems.contains(item.id);

          return ApprovalCard(
            item: item,
            isSelected: isSelected,
            showActions: showActions,
            onSelectChanged: enableSelection
                ? (value) => _toggleSelection(ref, item.id, value ?? false)
                : null,
            onTap: onItemTap != null
                ? () {
                    // Navigate to detail view or trigger custom action
                    // The parent widget can provide the navigation logic
                    onItemTap?.call();
                  }
                : null,
            onApprove: () => _handleApprove(context, ref, item),
            onReject: () => _handleReject(context, ref, item),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum item pendente',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Parabéns! Não há items aguardando aprovação.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(approvalProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(WidgetRef ref, String itemId, bool selected) {
    final currentSelection = ref.read(selectedItemsProvider);
    final newSelection = Set<String>.from(currentSelection);

    if (selected) {
      newSelection.add(itemId);
    } else {
      newSelection.remove(itemId);
    }

    ref.read(selectedItemsProvider.notifier).state = newSelection;
  }

  Future<void> _handleApprove(
    BuildContext context,
    WidgetRef ref,
    ApprovalItem item,
  ) async {
    try {
      await ref.read(approvalProvider.notifier).approveItem(item.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item "${item.title}" aprovado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao aprovar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    WidgetRef ref,
    ApprovalItem item,
  ) async {
    final reason = await _showRejectDialog(context);

    if (reason == null || reason.isEmpty) {
      return; // User cancelled or didn't provide a reason
    }

    try {
      await ref.read(approvalProvider.notifier).rejectItem(
            item.id,
            reason: reason,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item "${item.title}" rejeitado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao rejeitar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<String?> _showRejectDialog(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeitar Item'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Motivo da rejeição',
            hintText: 'Explique por que este item está sendo rejeitado',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );
  }
}
