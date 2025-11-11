/// Service for communicating with Content Reviewer Agent API
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/review_models.dart';

class ContentReviewService {
  final Dio _dio;
  final Logger _logger = Logger();
  final String baseUrl;

  ContentReviewService({
    String? baseUrl,
    Dio? dio,
  })  : baseUrl = baseUrl ?? 'http://localhost:8000',
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ));

  /// Get available agents information
  Future<List<AgentInfo>> getAgents() async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/agents');
      final data = response.data as Map<String, dynamic>;
      final agents = data['agents'] as List<dynamic>;

      return agents
          .map((a) => AgentInfo.fromJson(a as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      _logger.e('Error getting agents', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Review content
  Future<ReviewResult> reviewContent({
    required String title,
    required String text,
    ReviewType reviewType = ReviewType.fullReview,
    String? discipline,
  }) async {
    try {
      final requestData = {
        'title': title,
        'text': text,
        'content_type': 'text',
        if (discipline != null) 'discipline': discipline,
      };

      final queryParams = {
        'review_type': _toSnakeCase(reviewType.name),
      };

      _logger.i('Reviewing content: $title (${reviewType.name})');

      final response = await _dio.post(
        '$baseUrl/api/v1/review',
        data: requestData,
        queryParameters: queryParams,
      );

      return ReviewResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logger.e('Dio error reviewing content', error: e);
      throw Exception('Failed to review content: ${e.message}');
    } catch (e, st) {
      _logger.e('Error reviewing content', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Review for errors only
  Future<ReviewResult> reviewErrors({
    required String title,
    required String text,
  }) async {
    try {
      final requestData = {
        'title': title,
        'text': text,
        'content_type': 'text',
      };

      final response = await _dio.post(
        '$baseUrl/api/v1/review/errors',
        data: requestData,
      );

      return ReviewResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error reviewing for errors', error: e);
      rethrow;
    }
  }

  /// Review for comprehension
  Future<ReviewResult> reviewComprehension({
    required String title,
    required String text,
  }) async {
    try {
      final requestData = {
        'title': title,
        'text': text,
        'content_type': 'text',
      };

      final response = await _dio.post(
        '$baseUrl/api/v1/review/comprehension',
        data: requestData,
      );

      return ReviewResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error reviewing comprehension', error: e);
      rethrow;
    }
  }

  /// Review sources
  Future<ReviewResult> reviewSources({
    required String title,
    required String text,
  }) async {
    try {
      final requestData = {
        'title': title,
        'text': text,
        'content_type': 'text',
      };

      final response = await _dio.post(
        '$baseUrl/api/v1/review/sources',
        data: requestData,
      );

      return ReviewResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error reviewing sources', error: e);
      rethrow;
    }
  }

  /// Review for updates
  Future<ReviewResult> reviewUpdates({
    required String title,
    required String text,
  }) async {
    try {
      final requestData = {
        'title': title,
        'text': text,
        'content_type': 'text',
      };

      final response = await _dio.post(
        '$baseUrl/api/v1/review/updates',
        data: requestData,
      );

      return ReviewResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error reviewing for updates', error: e);
      rethrow;
    }
  }

  String _toSnakeCase(String str) {
    return str.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst('_', '');
  }
}

/// Agent information
class AgentInfo {
  final String name;
  final String description;
  final String reviewType;

  const AgentInfo({
    required this.name,
    required this.description,
    required this.reviewType,
  });

  factory AgentInfo.fromJson(Map<String, dynamic> json) {
    return AgentInfo(
      name: json['name'] as String,
      description: json['description'] as String,
      reviewType: json['review_type'] as String,
    );
  }
}
