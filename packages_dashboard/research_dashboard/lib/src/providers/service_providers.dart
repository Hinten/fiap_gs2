import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/research_service.dart';

/// Global provider for Research Management Service
final researchServiceProvider = Provider<ResearchManagementService>((ref) {
  return ResearchManagementService();
});
