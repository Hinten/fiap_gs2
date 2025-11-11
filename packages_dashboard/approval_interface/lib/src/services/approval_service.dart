import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/approval_item.dart';

/// Service for managing approval operations
///
/// This service handles all API interactions for approval items,
/// including fetching, approving, rejecting, and editing items.
class ApprovalService {
  final Dio _dio;
  final Logger _logger;
  final String baseUrl;

  /// Constructor
  ApprovalService({
    required this.baseUrl,
    Dio? dio,
    Logger? logger,
  })  : _dio = dio ?? Dio(),
        _logger = logger ?? Logger();

  /// Fetch pending approval items
  ///
  /// [filters] can include:
  /// - type: Filter by approval type
  /// - priority: Filter by priority
  /// - assignedTo: Filter by assigned user
  /// - status: Filter by status (defaults to pending)
  Future<List<ApprovalItem>> fetchPendingItems({
    Map<String, dynamic>? filters,
  }) async {
    try {
      _logger.d('Fetching pending approval items with filters: $filters');

      final response = await _dio.get(
        '$baseUrl/api/v1/approvals/pending',
        queryParameters: filters,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final items = data.map((json) => ApprovalItem.fromJson(json)).toList();

        _logger.i('Fetched ${items.length} approval items');
        return items;
      } else {
        throw Exception('Failed to fetch approval items: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException while fetching approval items', error: e);
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Error fetching approval items', error: e);
      rethrow;
    }
  }

  /// Fetch a specific approval item by ID
  Future<ApprovalItem> fetchItemById(String id) async {
    try {
      _logger.d('Fetching approval item: $id');

      final response = await _dio.get('$baseUrl/api/v1/approvals/$id');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ApprovalItem.fromJson(data);
      } else {
        throw Exception('Failed to fetch approval item: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException while fetching approval item', error: e);
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Error fetching approval item', error: e);
      rethrow;
    }
  }

  /// Approve an item
  ///
  /// [comment] is an optional comment about the approval
  Future<ApprovalItem> approveItem(String id, {String? comment}) async {
    try {
      _logger.d('Approving item: $id');

      final response = await _dio.post(
        '$baseUrl/api/v1/approvals/$id/approve',
        data: {'comment': comment},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        _logger.i('Item approved successfully: $id');
        return ApprovalItem.fromJson(data);
      } else {
        throw Exception('Failed to approve item: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException while approving item', error: e);
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Error approving item', error: e);
      rethrow;
    }
  }

  /// Reject an item
  ///
  /// [reason] is required to explain why the item was rejected
  Future<ApprovalItem> rejectItem(String id, {required String reason}) async {
    try {
      _logger.d('Rejecting item: $id');

      final response = await _dio.post(
        '$baseUrl/api/v1/approvals/$id/reject',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        _logger.i('Item rejected successfully: $id');
        return ApprovalItem.fromJson(data);
      } else {
        throw Exception('Failed to reject item: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException while rejecting item', error: e);
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Error rejecting item', error: e);
      rethrow;
    }
  }

  /// Edit an item before approving
  ///
  /// [updates] contains the fields to update
  Future<ApprovalItem> editItem(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      _logger.d('Editing item: $id with updates: $updates');

      final response = await _dio.put(
        '$baseUrl/api/v1/approvals/$id/edit',
        data: updates,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        _logger.i('Item edited successfully: $id');
        return ApprovalItem.fromJson(data);
      } else {
        throw Exception('Failed to edit item: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException while editing item', error: e);
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Error editing item', error: e);
      rethrow;
    }
  }

  /// Bulk approve multiple items
  ///
  /// Returns a map of item IDs to approval results
  Future<Map<String, bool>> bulkApprove(List<String> itemIds) async {
    try {
      _logger.d('Bulk approving ${itemIds.length} items');

      final response = await _dio.post(
        '$baseUrl/api/v1/approvals/bulk-approve',
        data: {'item_ids': itemIds},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final Map<String, bool> results = Map<String, bool>.from(data['results']);
        _logger.i('Bulk approval completed: ${results.length} items processed');
        return results;
      } else {
        throw Exception('Failed to bulk approve items: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException while bulk approving items', error: e);
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Error bulk approving items', error: e);
      rethrow;
    }
  }

  /// Fetch approval history
  ///
  /// [filters] can include date range, user, type, etc.
  Future<List<ApprovalItem>> fetchHistory({
    Map<String, dynamic>? filters,
  }) async {
    try {
      _logger.d('Fetching approval history with filters: $filters');

      final response = await _dio.get(
        '$baseUrl/api/v1/approvals/history',
        queryParameters: filters,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final items = data.map((json) => ApprovalItem.fromJson(json)).toList();

        _logger.i('Fetched ${items.length} history items');
        return items;
      } else {
        throw Exception('Failed to fetch history: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException while fetching history', error: e);
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Error fetching history', error: e);
      rethrow;
    }
  }
}
