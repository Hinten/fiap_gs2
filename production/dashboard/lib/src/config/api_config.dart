/// API Configuration for Production Dashboard
/// 
/// This file contains configuration for all backend services

const String defaultBackendUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'http://localhost:8000',
);

/// Research Management API Configuration
const String researchApiBaseUrl = String.fromEnvironment(
  'RESEARCH_API_URL',
  defaultValue: defaultBackendUrl,
);

/// Content Review API Configuration
const String contentReviewApiBaseUrl = String.fromEnvironment(
  'CONTENT_REVIEW_API_URL',
  defaultValue: defaultBackendUrl,
);

/// Approval Interface API Configuration
/// Note: Approval backend is not yet implemented, using mock data
const String approvalApiBaseUrl = String.fromEnvironment(
  'APPROVAL_API_URL',
  defaultValue: defaultBackendUrl,
);
