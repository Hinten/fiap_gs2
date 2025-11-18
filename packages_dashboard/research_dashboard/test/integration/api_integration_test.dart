import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:research_dashboard/research_dashboard.dart';

void main() {
  group('Research Management API Integration Tests', () {
    late ResearchManagementService service;
    
    setUpAll(() {
      // Configure service with longer timeouts for integration tests
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      
      service = ResearchManagementService(
        baseUrl: 'http://localhost:8002',
        dio: dio,
      );
    });

    test('Health check endpoint should respond', () async {
      try {
        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 5);
        final response = await dio.get('http://localhost:8002/health');
        expect(response.statusCode, 200);
        expect(response.data, isA<Map>());
        expect(response.data['status'], 'healthy');
      } catch (e) {
        fail('Health check failed: $e. Make sure Python API is running on localhost:8002');
      }
    });

    test('Root endpoint should respond', () async {
      try {
        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 5);
        final response = await dio.get('http://localhost:8002/');
        expect(response.statusCode, 200);
        expect(response.data, isA<Map>());
        expect(response.data['status'], 'running');
        expect(response.data['service'], 'Research Management API');
      } catch (e) {
        fail('Root endpoint failed: $e. Make sure Python API is running on localhost:8002');
      }
    });

    test('Coordinator dashboard endpoint should respond', () async {
      try {
        final dashboard = await service.getCoordinatorDashboard();
        expect(dashboard, isA<CoordinatorDashboard>());
        expect(dashboard.totalProjects, isA<int>());
        expect(dashboard.completionRate, isA<double>());
      } catch (e) {
        if (e.toString().contains('Connection timeout') || 
            e.toString().contains('Failed host lookup')) {
          fail('Connection failed: $e. Make sure:\n'
              '1. Python API is running: python -m research_management.main\n'
              '2. Firebase emulator is running: firebase emulators:start\n'
              '3. Port 8002 is accessible');
        }
        fail('Coordinator dashboard failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Projects endpoint should respond', () async {
      try {
        final projects = await service.getProjects();
        expect(projects, isA<List<ResearchProject>>());
      } catch (e) {
        if (e.toString().contains('Connection timeout')) {
          fail('Connection timeout. Make sure Python API is running and accessible.');
        }
        // It's ok if there are no projects, we just want to verify the endpoint responds
        if (!e.toString().contains('404')) {
          fail('Projects endpoint failed unexpectedly: $e');
        }
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Alerts endpoint should respond', () async {
      try {
        final alerts = await service.getAlerts();
        expect(alerts, isA<List<Alert>>());
      } catch (e) {
        if (e.toString().contains('Connection timeout')) {
          fail('Connection timeout. Make sure Python API is running and accessible.');
        }
        // It's ok if there are no alerts
        if (!e.toString().contains('404')) {
          fail('Alerts endpoint failed unexpectedly: $e');
        }
      }
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  group('Error Handling Tests', () {
    test('Service should handle invalid base URL gracefully', () {
      final service = ResearchManagementService(
        baseUrl: 'http://invalid-url-that-does-not-exist:9999',
      );
      
      expect(
        () => service.getCoordinatorDashboard(),
        throwsA(isA<Exception>()),
      );
    });

    test('Service should provide meaningful error messages', () async {
      final service = ResearchManagementService(
        baseUrl: 'http://localhost:9999', // Wrong port
      );
      
      try {
        await service.getCoordinatorDashboard();
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('timeout'));
      }
    });
  });
}
