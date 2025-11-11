import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/approval_item.dart';
import '../services/approval_service.dart';

/// Provider for ApprovalService
final approvalServiceProvider = Provider<ApprovalService>((ref) {
  // In a real app, this should be configured with the actual base URL
  // It can be overridden in main.dart or through a configuration provider
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

  ApprovalState({
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

/// StateNotifier for managing approval items
class ApprovalNotifier extends StateNotifier<ApprovalState> {
  final ApprovalService _service;

  ApprovalNotifier(this._service) : super(ApprovalState());

  /// Fetch pending items with optional filters
  Future<void> fetchPendingItems({Map<String, dynamic>? filters}) async {
    state = state.copyWith(isLoading: true, error: null, filters: filters);

    try {
      final items = await _service.fetchPendingItems(filters: filters);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Approve an item
  Future<void> approveItem(String id, {String? comment}) async {
    try {
      final updatedItem = await _service.approveItem(id, comment: comment);

      // Update the item in the list
      final updatedItems = state.items
          .map((item) => item.id == id ? updatedItem : item)
          .toList();

      state = state.copyWith(items: updatedItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Reject an item
  Future<void> rejectItem(String id, {required String reason}) async {
    try {
      final updatedItem = await _service.rejectItem(id, reason: reason);

      // Update the item in the list
      final updatedItems = state.items
          .map((item) => item.id == id ? updatedItem : item)
          .toList();

      state = state.copyWith(items: updatedItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Edit an item
  Future<void> editItem(String id, Map<String, dynamic> updates) async {
    try {
      final updatedItem = await _service.editItem(id, updates);

      // Update the item in the list
      final updatedItems = state.items
          .map((item) => item.id == id ? updatedItem : item)
          .toList();

      state = state.copyWith(items: updatedItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Bulk approve items
  Future<Map<String, bool>> bulkApprove(List<String> itemIds) async {
    try {
      final results = await _service.bulkApprove(itemIds);

      // Remove approved items from the list or update their status
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

  /// Refresh the current view
  Future<void> refresh() async {
    await fetchPendingItems(filters: state.filters);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for ApprovalNotifier
final approvalProvider =
    StateNotifierProvider<ApprovalNotifier, ApprovalState>((ref) {
  final service = ref.watch(approvalServiceProvider);
  return ApprovalNotifier(service);
});

/// Provider for selected items (for bulk operations)
final selectedItemsProvider = StateProvider<Set<String>>((ref) => {});

/// Provider for a specific approval item
final approvalItemProvider =
    FutureProvider.family<ApprovalItem, String>((ref, id) async {
  final service = ref.watch(approvalServiceProvider);
  return service.fetchItemById(id);
});

/// Provider for approval history
final approvalHistoryProvider = FutureProvider.autoDispose
    .family<List<ApprovalItem>, Map<String, dynamic>?>((ref, filters) async {
  final service = ref.watch(approvalServiceProvider);
  return service.fetchHistory(filters: filters);
});
