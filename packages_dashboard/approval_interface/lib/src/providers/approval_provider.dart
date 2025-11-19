import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/approval_item.dart';
import '../services/approval_service.dart';

/// Provider for ApprovalService
final approvalServiceProvider = Provider<ApprovalService>((ref) {
  return ApprovalService(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    ),
  );
});

/// State for approval items
class ApprovalState {
  final List<ApprovalItem> items;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? filters;

  const ApprovalState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.filters,
  });

  ApprovalState copyWith({
    List<ApprovalItem>? items,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? filters,
  }) {
    return ApprovalState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
    );
  }
}

/// Notifier para gerenciar itens de aprovação (migração da API antiga StateNotifier)
class ApprovalNotifier extends Notifier<ApprovalState> {
  late final ApprovalService _service;

  @override
  ApprovalState build() {
    _service = ref.watch(approvalServiceProvider);
    return const ApprovalState();
  }

  Future<void> fetchPendingItems({Map<String, dynamic>? filters}) async {
    state = state.copyWith(isLoading: true, error: null, filters: filters);
    try {
      final items = await _service.fetchPendingItems(filters: filters);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> approveItem(String id, {String? comment}) async {
    try {
      final updatedItem = await _service.approveItem(id, comment: comment);
      final updatedItems = state.items
          .map((item) => item.id == id ? updatedItem : item)
          .toList();
      state = state.copyWith(items: updatedItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> rejectItem(String id, {required String reason}) async {
    try {
      final updatedItem = await _service.rejectItem(id, reason: reason);
      final updatedItems = state.items
          .map((item) => item.id == id ? updatedItem : item)
          .toList();
      state = state.copyWith(items: updatedItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> editItem(String id, Map<String, dynamic> updates) async {
    try {
      final updatedItem = await _service.editItem(id, updates);
      final updatedItems = state.items
          .map((item) => item.id == id ? updatedItem : item)
          .toList();
      state = state.copyWith(items: updatedItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<Map<String, bool>> bulkApprove(List<String> itemIds) async {
    try {
      final results = await _service.bulkApprove(itemIds);
      final remainingItems = state.items
          .where((item) => !results.containsKey(item.id) || !results[item.id]!)
          .toList();
      state = state.copyWith(items: remainingItems);
      return results;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> refresh() async {
    await fetchPendingItems(filters: state.filters);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider para ApprovalNotifier usando nova API NotifierProvider
final approvalProvider =
    NotifierProvider<ApprovalNotifier, ApprovalState>(ApprovalNotifier.new);

/// Notifier para itens selecionados (substitui StateProvider<Set<String>>)
class SelectedItemsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String id, bool selected) {
    final next = Set<String>.from(state);
    if (selected) {
      next.add(id);
    } else {
      next.remove(id);
    }
    state = next;
  }

  void clear() => state = <String>{};

  void addAll(Iterable<String> ids) {
    final next = Set<String>.from(state)..addAll(ids);
    state = next;
  }
}

final selectedItemsProvider =
    NotifierProvider<SelectedItemsNotifier, Set<String>>(SelectedItemsNotifier.new);

/// Provider para item específico
final approvalItemProvider =
    FutureProvider.family<ApprovalItem, String>((ref, id) async {
  final service = ref.watch(approvalServiceProvider);
  return service.fetchItemById(id);
});

/// Provider para histórico de aprovações
final approvalHistoryProvider = FutureProvider.autoDispose
    .family<List<ApprovalItem>, Map<String, dynamic>?>(
        (ref, filters) async {
  final service = ref.watch(approvalServiceProvider);
  return service.fetchHistory(filters: filters);
});
