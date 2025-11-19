/// Service for communicating with Content Reviewer Agent API
library;

import 'package:dio/dio.dart';
import '../models/review_models.dart';

class ContentReviewService {
  final Dio _dio;
  final String baseUrl;

  ContentReviewService({String? baseUrl, Dio? dio})
    : baseUrl = baseUrl ?? 'http://localhost:8000',
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

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

      final queryParams = {'review_type': _toSnakeCase(reviewType.name)};

      final response = await _dio.post(
        '$baseUrl/api/v1/content-review/review',
        data: requestData,
        queryParameters: queryParams,
      );

      return ReviewResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to review content: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  String _toSnakeCase(String str) {
    final result = str.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
    // Remove leading underscore only if string starts with it
    return result.startsWith('_') ? result.substring(1) : result;
  }
}
