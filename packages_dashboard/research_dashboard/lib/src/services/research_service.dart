import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/project.dart';
import '../models/alert.dart';
import '../models/dashboard.dart';

/// Service for communicating with Research Management API
class ResearchManagementService {
  final Dio _dio;
  final Logger _logger = Logger();
  final String baseUrl;

  ResearchManagementService({
    String? baseUrl,
    Dio? dio,
  })  : baseUrl = baseUrl ?? 'http://localhost:8002',
        _dio = dio ?? Dio() {
    _dio.options.baseUrl = this.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Add interceptors for logging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d('Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('Response: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// Get coordinator dashboard metrics
  Future<CoordinatorDashboard> getCoordinatorDashboard() async {
    try {
      final response = await _dio.get('/api/v1/research/dashboard/coordinator');
      return CoordinatorDashboard.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logger.e('Failed to get coordinator dashboard', error: e);
      throw _handleError(e);
    }
  }

  /// Get advisor dashboard metrics
  Future<AdvisorDashboard> getAdvisorDashboard(String advisorId) async {
    try {
      final response = await _dio.get(
        '/api/v1/research/dashboard/advisor',
        queryParameters: {'advisor_id': advisorId},
      );
      return AdvisorDashboard.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logger.e('Failed to get advisor dashboard', error: e);
      throw _handleError(e);
    }
  }

  /// Get student dashboard metrics
  Future<StudentDashboard> getStudentDashboard(String studentId) async {
    try {
      final response = await _dio.get(
        '/api/v1/research/dashboard/student',
        queryParameters: {'student_id': studentId},
      );
      return StudentDashboard.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logger.e('Failed to get student dashboard', error: e);
      throw _handleError(e);
    }
  }

  /// Get all projects with optional filters
  Future<List<ResearchProject>> getProjects({
    String? status,
    String? area,
    String? healthStatus,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status;
      if (area != null) queryParams['area'] = area;
      if (healthStatus != null) queryParams['health_status'] = healthStatus;

      final response = await _dio.get(
        '/api/v1/research/projects',
        queryParameters: queryParams,
      );
      
      return (response.data as List)
          .map((e) => ResearchProject.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _logger.e('Failed to get projects', error: e);
      throw _handleError(e);
    }
  }

  /// Get project by ID
  Future<ResearchProject> getProject(String projectId) async {
    try {
      final response = await _dio.get('/api/v1/research/projects/$projectId');
      return ResearchProject.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logger.e('Failed to get project', error: e);
      throw _handleError(e);
    }
  }

  /// Get active alerts with optional filters
  Future<List<Alert>> getAlerts({
    String? alertType,
    String? severity,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (alertType != null) queryParams['alert_type'] = alertType;
      if (severity != null) queryParams['severity'] = severity;

      final response = await _dio.get(
        '/api/v1/research/alerts',
        queryParameters: queryParams,
      );
      
      return (response.data as List)
          .map((e) => Alert.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _logger.e('Failed to get alerts', error: e);
      throw _handleError(e);
    }
  }

  /// Resolve an alert
  Future<Alert> resolveAlert(String alertId) async {
    try {
      final response = await _dio.post('/api/v1/research/alerts/$alertId/resolve');
      return Alert.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logger.e('Failed to resolve alert', error: e);
      throw _handleError(e);
    }
  }

  /// Dismiss an alert
  Future<Alert> dismissAlert(String alertId) async {
    try {
      final response = await _dio.post('/api/v1/research/alerts/$alertId/dismiss');
      return Alert.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logger.e('Failed to dismiss alert', error: e);
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your network.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['detail'] ?? 'Request failed';
        return Exception('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error: ${error.message}');
    }
  }
}
