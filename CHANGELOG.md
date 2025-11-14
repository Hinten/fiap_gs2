# Changelog - FIAP AI-Enhanced Learning Platform

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### In Progress
- CI/CD pipeline with GitHub Actions
- Deployment to Google Cloud Functions
- Grading Agent implementation
- Code Review Agent implementation
- Frontend Flutter main dashboard

---

## [0.2.0] - 2025-11-13

### Added - Major Components

#### Backend (Python)
- **Auth Service (v0.2.0)** - Firebase Authentication
  - Firebase Admin SDK integration
  - FastAPI middleware for token verification
  - RBAC (Role-Based Access Control)
  - Multi-tenant support
  - Custom claims management
  - User management utilities
  - 10 unit tests (100% passing)
  - Comprehensive documentation (4 guides)

- **Content Reviewer Agent (v0.1.0)** - Content Review
  - 18 Python modules implemented
  - Automatic content review
  - Fact-checking and source validation
  - Outdated material detection
  - CrewAI integration

#### Frontend (Flutter)
- **Dashboard Auth (v1.0.0)** - Firebase Authentication UI
  - Firebase Flutter SDK integration
  - Multiple authentication methods (Email/Password, Google, Custom Token)
  - Automatic ID token management
  - Dio HTTP interceptor
  - Riverpod state management
  - Auth wrapper widgets for route protection
  - Role and tenant-based access control
  - 4 Dart modules with example app

- **Approval Interface (v0.1.0)** - Generic Approval Dashboard
  - Generic, reusable approval workflow package
  - Material Design 3 with light/dark theme
  - Real-time statistics dashboard
  - Advanced filtering (type, priority, status)
  - Bulk operations (approve/reject)
  - 7 Dart modules
  - 38 tests (18 unit + 20 widget)
  - Complete example app with mock data

### Added - Documentation
- Firebase Authentication Integration Guide
- Firebase Implementation Summary
- Firebase Quickstart Guide
- Firebase Emulator Testing Guide
- Updated Developer Guide with Firebase sections
- Updated Migration Guide
- Comprehensive READMEs for all implemented packages

### Added - Infrastructure
- Monorepo structure with independent packages
- Firebase project configuration
- Firebase Emulators setup for local testing
- Python packaging with pyproject.toml
- Flutter packaging with pubspec.yaml
- Code formatting tools (black, isort, flutter format)
- Testing infrastructure (pytest, flutter test)

### Changed
- **BREAKING**: Migrated from custom JWT to Firebase Authentication
- Updated roadmap with completed sprints
- Updated README with "Estado Atual" section
- Enhanced "Como Começar" section with real examples

### Documentation Updates
- README.md: Added detailed status of implemented packages
- docs/roadmap-overview.md: Marked Sprint 1 as complete, Sprints 4 & 5 as partial
- All package READMEs updated with current implementation status
- Links between documentation files improved

---

## [0.1.0] - 2025-11-01

### Added
- Initial monorepo structure
- Project documentation:
  - Developer Guide
  - Discipline Mapping
  - Delivery Guidelines
  - Roadmap Overview
  - Migration Guide
- GitHub Copilot instructions
- Roadmaps for all 13+ planned packages
- Basic project README
- .gitignore configuration

### Structure
- `packages/` - Python backend packages (10 packages planned)
- `packages_dashboard/` - Flutter frontend packages (3 packages planned)
- `docs/` - Complete project documentation
- `assets/` - Screenshots and visual resources

---

## Project Statistics (as of 2025-11-13)

### Implementation Progress
- **Sprints Completed**: 1 of 7 (Sprint 1: Foundation & Infrastructure)
- **Sprints Partial**: 2 of 7 (Sprint 4 & 5)
- **Packages Implemented**: 4 of 13 (31%)
- **Lines of Code**: ~2,000+ (Python + Dart)
- **Unit Tests**: 25+ automated tests
- **Documentation Files**: 8+ complete guides

### Technology Stack
- **Backend**: Python 3.11+, FastAPI, Firebase Admin SDK
- **Frontend**: Flutter 3.x, Dart 3.0+, Material Design 3
- **Authentication**: Firebase Authentication
- **Database**: Firebase Firestore
- **State Management**: Riverpod (Flutter)
- **Testing**: pytest (Python), flutter test (Dart)
- **Formatting**: black, isort (Python), flutter format (Dart)

### Package Status
- ✅ **Implemented & Tested**: Auth Service, Content Reviewer Agent, Dashboard Auth, Approval Interface
- 📋 **Planned**: Code Review Agent, Grading Agent, Mental Health Agent, Plagiarism Detection, AI Usage Detection, Award Methodology, Content Generator, Research Management, Gamified Exams, Frontend Flutter

---

## Links

- [Repository](https://github.com/Hinten/fiap_gs2)
- [Developer Guide](docs/developer-guide.md)
- [Roadmap Overview](docs/roadmap-overview.md)
- [Firebase Integration Guide](docs/firebase-auth-integration.md)
- [Package Documentation](packages/)

---

**Note**: This is a Proof of Concept (POC) developed for FIAP Global Solution 2025.2 - "O Futuro do Trabalho".
