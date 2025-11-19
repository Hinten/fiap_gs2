# Changelog

All notable changes to the approval_interface package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2025-11-19

### Changed
- Migrated state management from `StateNotifierProvider` / `StateProvider` to Riverpod 3 `NotifierProvider` API.
- `ApprovalNotifier` now extends `Notifier<ApprovalState>` with `build()` method.
- Replaced raw `StateProvider<Set<String>>` for selection with `SelectedItemsNotifier` (encapsulated selection logic: `toggle`, `clear`, `addAll`).
- Updated README with migration notes and new peer dependency `flutter_riverpod: ^3.0.3`.

### Added
- Helper methods inside `SelectedItemsNotifier`.
- Migration section in README.

### Deprecated (Soft)
- Direct external writes to `approvalProvider.notifier.state` (prefer calling exposed methods). Backwards compatible for now.

### Notes
- No breaking changes for existing consumer code calling `ref.read(approvalProvider.notifier).approveItem()` etc.
- Future migration path planned for `AsyncNotifier` to streamline loading/error handling.

## [0.1.0] - 2024-11-11

### Added
- Initial release of approval_interface package
- Core data models:
  - `ApprovalItem` with full CRUD support
  - `ApprovalType` enum (codeReview, grading, award, content, issue, other)
  - `ApprovalPriority` enum (critical, high, normal, low)
  - `ApprovalStatus` enum (pending, inReview, approved, rejected)
- Service layer:
  - `ApprovalService` with complete API integration
  - Support for fetch, approve, reject, edit operations
  - Bulk approval support
  - Configurable base URL
  - Comprehensive error handling and logging
- State management:
  - Riverpod providers for reactive state
  - `ApprovalNotifier` for state updates
  - Selection management for bulk operations
  - Family providers for individual items
- UI widgets:
  - `ApprovalCard` - Rich Material Design 3 card component
  - `ApprovalList` - Smart list with refresh and error handling
  - `ApprovalDashboardScreen` - Full-featured dashboard
- Features:
  - Real-time statistics (4 metrics)
  - Advanced filtering (type, priority, status)
  - Bulk selection mode
  - Pull-to-refresh
  - Loading, error, and empty states
  - Confirmation dialogs for critical actions
- Testing:
  - 18 unit tests for models
  - 20 widget tests for ApprovalCard
  - Mock data generator for testing
- Documentation:
  - Comprehensive README with examples
  - API specification
  - Integration guide
  - Example app with mock data
  - Inline documentation for all public APIs
- Development tools:
  - analysis_options.yaml with strict linting
  - Example app for demonstration

### Technical Details
- Compatible with Flutter 3.0.0+
- Compatible with Dart 3.0.0+
- Uses flutter_riverpod 2.4.0+
- Uses dio 5.3.3+ for HTTP
- Material Design 3 compliant
- Null-safe
- Well-documented public APIs

### Notes
- Package designed for FIAP AI-Enhanced Learning Platform
- Generic and reusable for any approval workflow
- Backend API endpoints required for full functionality
- Example app includes mock data for offline testing

[0.1.1]: https://github.com/Hinten/fiap_gs2/releases/tag/approval_interface-v0.1.1
[0.1.0]: https://github.com/Hinten/fiap_gs2/releases/tag/approval_interface-v0.1.0
