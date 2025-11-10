# Copilot Instructions - FIAP AI-Enhanced Learning Platform

## Repository Overview

**Purpose**: FIAP Global Solution 2025.2 POC demonstrating how AI and gamification can make educational work more human, inclusive, and sustainable. This is a **planning/architecture repository** currently containing roadmaps and documentation for a serverless AI-enhanced learning platform.

**Current State**: Documentation and roadmap phase - no implementation code exists yet. All 13 microservice apps have detailed roadmaps in `src/apps/*/roadmap.md` but contain no actual code files.

**Tech Stack**:
- Backend: Python 3.11+ with FastAPI, serverless (AWS Lambda/GCP Functions)
- Frontend: Flutter 3.x (Dart) for web/mobile
- AI Orchestration: CrewAI for multi-agent systems
- ML: scikit-learn, TensorFlow, Transformers (BERT)
- Analytics: R with tidyverse, ggplot2
- Cloud: AWS (primary) - DynamoDB, Aurora Serverless, S3, Lambda, API Gateway
- CI/CD: GitHub Actions (to be implemented)

**Repository Size**: ~47 files, 324KB total, primarily markdown documentation

## Critical Information for Agents

### Repository Structure
```
fiap_gs2/
├── .github/               # GitHub workflows (empty - to be created)
├── assets/                # Screenshots, images (8KB)
├── docs/                  # Project documentation (100KB)
│   ├── developer-guide.md      # Comprehensive dev guide
│   ├── roadmap-overview.md     # Project roadmap
│   ├── discipline-mapping.md   # FIAP course integration
│   └── delivery-guidelines.md  # GS 2025.2 submission rules
├── src/apps/              # 13 microservice directories (216KB)
│   ├── auth_service/           # JWT, OAuth2, RBAC
│   ├── frontend_flutter/       # Flutter web/mobile UI
│   ├── code_review_agent/      # GitHub API integration
│   ├── grading_agent/          # Automated grading with AI
│   ├── award_methodology_agent/# Transparent prize system
│   ├── content_generator_agent/# Veo3, NotebookLM, Grok
│   ├── research_management/    # Academic research mgmt
│   ├── gamified_exams/         # Inclusive adaptive tests
│   ├── content_reviewer_agent/ # Content quality checks
│   ├── mental_health_agent/    # Wellbeing monitoring
│   ├── plagiarism_detection_agent/
│   ├── ai_usage_detection_agent/
│   └── approval_interface/     # Human-in-the-loop UI
└── .gitignore
```

**Each app directory currently contains only**: `roadmap.md` (15-17KB detailed implementation plan)

### Starting Implementation - Critical First Steps

**Before writing any code, always**:
1. Read the specific app's `src/apps/<app_name>/roadmap.md` - these are comprehensive implementation guides
2. Review `docs/developer-guide.md` for coding standards, stack details, and patterns
3. Check `docs/discipline-mapping.md` to understand which FIAP course requirements apply

**When creating a new microservice**:
1. Follow the structure defined in the app's roadmap.md exactly
2. Standard Python service structure:
   ```
   app_name/
   ├── src/
   │   ├── main.py              # FastAPI app or Lambda handler
   │   ├── api/                 # Routes and endpoints
   │   ├── models/              # Pydantic models
   │   ├── services/            # Business logic
   │   └── repositories/        # Data access
   ├── tests/
   │   ├── test_api.py
   │   └── test_services.py
   ├── requirements.txt
   ├── requirements-dev.txt
   └── README.md
   ```

3. Standard Flutter app structure:
   ```
   frontend_flutter/
   ├── lib/
   │   ├── main.dart
   │   ├── screens/
   │   ├── widgets/
   │   ├── services/
   │   ├── models/
   │   └── providers/
   ├── test/
   ├── pubspec.yaml
   └── README.md
   ```

### Build, Test, and Run Commands

**Python Services** (once implemented):
```bash
cd src/apps/<service_name>

# Setup (always first)
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows
pip install -r requirements.txt

# Testing (use pytest)
pytest                              # All tests
pytest --cov=src --cov-report=html # With coverage
pytest tests/test_specific.py -v   # Specific file

# Linting (always run before commit)
black .                  # Format code
isort .                  # Sort imports
flake8 .                 # Lint (or pylint)

# Local development
uvicorn src.main:app --reload --port 8001
```

**Flutter Frontend** (once implemented):
```bash
cd src/apps/frontend_flutter

# Setup (always first)
flutter pub get

# Testing
flutter test                    # Unit/widget tests
flutter analyze                 # Static analysis
flutter format .                # Format code

# Running
flutter devices                 # List available devices
flutter run -d chrome           # Run on Chrome
flutter run -d <device-id>      # Run on specific device
```

**R Scripts** (for analytics):
```bash
# In R console or RStudio
install.packages(c("tidyverse", "ggplot2"))
source("path/to/analysis_script.R")
```

### Coding Standards - Non-Negotiable

**Python**:
- PEP 8 compliant, use `black` for formatting (line length 88)
- Type hints required: `def function(param: str) -> dict:`
- Docstrings in Google or NumPy style for all public functions
- Use Pydantic for data validation
- Structured logging (JSON format)
- Example from roadmaps:
  ```python
  from typing import Optional
  from datetime import timedelta
  
  def create_access_token(
      user_id: str,
      expires_delta: Optional[timedelta] = None
  ) -> str:
      """Create JWT access token.
      
      Args:
          user_id: Unique user identifier
          expires_delta: Optional custom expiration
          
      Returns:
          Encoded JWT token string
      """
  ```

**Flutter/Dart**:
- Follow official Dart Style Guide
- Use `flutter format .` (dartfmt)
- Enable `flutter analyze` rules in `analysis_options.yaml`
- Use const constructors wherever possible
- State management: Riverpod or Bloc (define early)
- Example:
  ```dart
  /// Service for handling authentication.
  class AuthService {
    final Dio _dio;
    
    AuthService({required Dio dio}) : _dio = dio;
    
    /// Logs in user with email and password.
    /// Throws [NetworkException] on failure.
    Future<AuthToken> login(String email, String password) async {
      // Implementation
    }
  }
  ```

**R**:
- Tidyverse Style Guide
- Use `<-` for assignment
- snake_case for variables
- Descriptive comments

### Security Requirements - Always Enforce

1. **Never commit secrets**: Use `.env` (already in `.gitignore`), AWS Secrets Manager in prod
2. **Environment variables required**:
   ```
   AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION
   OPENAI_API_KEY, ANTHROPIC_API_KEY
   JWT_SECRET_KEY (must be strong)
   ```
3. **JWT tokens**: 15-60 min expiration, use refresh tokens
4. **Input validation**: Use Pydantic (Python), validators (Dart) for all user inputs
5. **HTTPS/TLS**: Mandatory in production
6. **Rate limiting**: Configure in API Gateway
7. **Logging**: Never log secrets, passwords, or PII

### Testing Strategy

**No tests exist yet** - when implementing:
- **Python**: Write pytest tests alongside code, aim for 80%+ coverage
- **Flutter**: Write widget and unit tests, use mockito for mocking
- **Integration tests**: Test API endpoints with real HTTP calls (use test fixtures)
- Test file naming: `test_<module_name>.py` or `<widget>_test.dart`

### CI/CD and Validation (To Be Implemented)

**No GitHub Actions workflows exist yet**. When creating `.github/workflows/`:

**Expected CI pipeline**:
```yaml
# .github/workflows/ci.yml (example)
on: [push, pull_request]
jobs:
  test-python:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - run: |
          pip install -r requirements.txt pytest
          pytest --cov
  
  test-flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: |
          flutter pub get
          flutter analyze
          flutter test
```

**Local CI emulation**: Run all tests + linting before committing

### Common Patterns and Conventions

**API Response Format** (from developer-guide.md):
```json
{
  "success": true,
  "data": { ... },
  "error": null
}
```

**Error Handling**:
- Python: Use FastAPI HTTPException with proper status codes
- Flutter: Custom exception classes (NetworkException, AuthException)

**Logging**:
- Python: `import logging`, structured JSON logs
- Include: timestamp, level, service name, trace_id, message

**Database Access**:
- Repository pattern: separate data access from business logic
- Use async operations for I/O
- DynamoDB for events/logs, Aurora Serverless for relational data

### Project-Specific Constraints

1. **Serverless-first**: All services must be deployable as Lambda functions
2. **Stateless APIs**: No server-side sessions, use JWT
3. **Multi-tenant**: Design for multiple schools/institutions (use tenant_id)
4. **LGPD/GDPR**: Handle student data with care, implement data deletion
5. **AI Explainability**: All AI decisions must be explainable (required for approval UI)
6. **Human-in-the-loop**: AI outputs always require human approval (except monitoring)

### Roadmap Navigation

Each microservice has a detailed roadmap file (`src/apps/<app_name>/roadmap.md`) averaging 15KB. These contain:
- Architecture and tech stack
- Complete folder structure
- Phase-by-phase implementation tasks with checkboxes
- Code examples and API specifications
- Database schemas
- Testing requirements
- Integration points with other services

**Always reference the specific app's roadmap before implementing features.**

### Common Pitfalls to Avoid

1. **Don't create requirements.txt yet** - each roadmap specifies exact dependencies
2. **Don't assume database schema** - schemas are defined in roadmaps
3. **Don't skip the approval interface** - human oversight is core to the project
4. **Don't implement without reading roadmap** - detailed specs exist
5. **Lambda cold starts**: Optimize package size, use provisioned concurrency for critical paths
6. **Serverless limits**: AWS Lambda 15min timeout, 10GB memory max
7. **Flutter web vs mobile**: Some features differ (file pickers, platform channels)

### Files to Reference

**Priority reading order**:
1. `src/apps/<relevant_app>/roadmap.md` - Your implementation blueprint
2. `docs/developer-guide.md` - Coding standards, stack details (38KB)
3. `docs/discipline-mapping.md` - FIAP course integration requirements
4. `docs/roadmap-overview.md` - Overall project roadmap and MVP scope
5. `.gitignore` - What not to commit (venv, .env, build artifacts, etc.)

### Quick Reference

**Key files in repo root**: `.gitignore`, `README.md` (project overview)
**Documentation**: All in `docs/` directory
**All roadmaps**: `src/apps/*/roadmap.md` (13 total)
**No code yet**: Repository is in planning phase
**No CI/CD yet**: GitHub Actions workflows need to be created
**No infrastructure yet**: Terraform/Serverless Framework configs need creation

### Working as an AI Agent

**Trust these instructions first**. Only search the repository when:
- You need specific implementation details from a roadmap
- You need to verify existing code (when code exists)
- These instructions lack information you need

**Before making changes**:
1. Read the relevant roadmap completely
2. Understand the integration points with other services
3. Follow the exact structure specified in the roadmap
4. Check security requirements apply
5. Write tests alongside code

**When stuck**: Refer to `docs/developer-guide.md` for comprehensive examples, patterns, and troubleshooting guidance.

---

**Last Updated**: 2025-11-10 | **Version**: 1.0 | **Project Phase**: Planning/Documentation
