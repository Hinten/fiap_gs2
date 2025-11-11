# Copilot Instructions - FIAP AI-Enhanced Learning Platform

## Repository Overview

**Purpose**: FIAP Global Solution 2025.2 POC demonstrating how AI and gamification can make educational work more human, inclusive, and sustainable. This is a **monorepo** containing independent packages for a serverless AI-enhanced learning platform.

**Current State**: Monorepo with package-based architecture. Python packages in `packages/` and Flutter packages in `packages_dashboard/`. Most packages contain roadmaps and minimal code, with `auth_service` having full implementation.

**Tech Stack**:
- Backend: Python 3.11+ with FastAPI, serverless (Google Cloud Functions)
- Frontend: Flutter 3.x (Dart) for web/mobile
- AI Orchestration: CrewAI for multi-agent systems
- ML: scikit-learn, TensorFlow, Transformers (BERT)
- Cloud: Google Cloud Platform (primary) - Firestore, Cloud Functions, Cloud Storage, Firebase Authentication
- CI/CD: GitHub Actions (to be implemented)
- Package Management: pyproject.toml (Python), pubspec.yaml (Flutter)

**Repository Size**: Monorepo with 10 Python packages + 3 Flutter packages

## Critical Information for Agents

### Repository Structure
```
fiap_gs2/
├── .github/                      # GitHub workflows
│   └── copilot-instructions.md
├── assets/                       # Screenshots, images
├── docs/                         # Project documentation
│   ├── developer-guide.md
│   ├── roadmap-overview.md
│   ├── discipline-mapping.md
│   └── delivery-guidelines.md
├── packages/                     # Python packages (microservices)
│   ├── auth_service/
│   │   ├── src/
│   │   │   └── auth_service/    # Installable package
│   │   ├── tests/
│   │   ├── pyproject.toml       # Package metadata
│   │   ├── README.md
│   │   └── roadmap.md
│   ├── code_review_agent/
│   ├── grading_agent/
│   ├── award_methodology_agent/
│   ├── content_generator_agent/
│   ├── research_management/
│   ├── content_reviewer_agent/
│   ├── mental_health_agent/
│   ├── plagiarism_detection_agent/
│   └── ai_usage_detection_agent/
├── packages_dashboard/           # Flutter packages (interfaces)
│   ├── frontend_flutter/
│   │   ├── lib/
│   │   ├── test/
│   │   ├── pubspec.yaml         # Package metadata
│   │   ├── README.md
│   │   └── roadmap.md
│   ├── approval_interface/
│   └── gamified_exams/
└── .gitignore
```

**Package Structure**: Each package is independently installable with its own dependencies, tests, and documentation.

### Starting Implementation - Critical First Steps

**Before writing any code, always**:
1. Read the specific package's `packages/<package_name>/roadmap.md` or `packages_dashboard/<package_name>/roadmap.md`
2. Review `docs/developer-guide.md` for coding standards, stack details, and patterns
3. Check `docs/discipline-mapping.md` to understand which FIAP course requirements apply
4. If creating new documentation specific to a package, place it in the package's `docs/` folder

**When creating a new Python package**:
1. Follow the structure defined in the package's roadmap.md exactly
2. Standard Python package structure:
   ```
   packages/package_name/
   ├── docs/                    # Package-specific documentation (if any)
   ├── example/                 # Example app (if applicable)
   ├── src/
   │   └── package_name/        # Installable package
   │       ├── __init__.py
   │       ├── main.py          # FastAPI app or Cloud Function handler
   │       ├── api/             # Routes and endpoints
   │       ├── models/          # Pydantic models
   │       ├── services/        # Business logic
   │       └── repositories/    # Data access
   ├── tests/
   │   ├── test_api.py
   │   └── test_services.py
   ├── pyproject.toml           # Package metadata and dependencies
   ├── README.md
   └── roadmap.md
   ```

3. Standard Flutter package structure:
   ```
   packages_dashboard/package_name/
   ├── example/                    # Example app (if applicable)
   ├── docs/                       # Package-specific documentation (if any)
   ├── lib/
   │   ├── src/                 # Private implementation
   │   │   ├── screens/
   │   │   ├── widgets/
   │   │   ├── services/
   │   │   └── models/
   │   └── package_name.dart    # Public exports
   ├── test/
   │   └── package_name_test.dart
   ├── pubspec.yaml             # Package metadata and dependencies
   ├── README.md
   └── roadmap.md
   ```

### Build, Test, and Run Commands

**Python Packages**:
```bash
cd packages/<package_name>

# Setup (always first)
pip install -e ".[dev]"         # Install in editable mode with dev dependencies

# Testing (use pytest)
pytest                              # All tests
pytest --cov=src --cov-report=html # With coverage
pytest tests/test_specific.py -v   # Specific file

# Linting (always run before commit)
black .                  # Format code
isort .                  # Sort imports
flake8 .                 # Lint (or pylint)

# Local development
cd src/<package_name>
python -m <package_name>.main
# or for FastAPI apps
uvicorn <package_name>.main:app --reload --port 8001
```

**Flutter Packages**:
```bash
cd packages_dashboard/<package_name>

# Setup (always first)
flutter pub get
```

Note (environment): The Flutter SDK is already installed in the current development environment. Agents and developers can verify the installation and environment with the following Windows (cmd.exe) commands:

```cmd
REM Show Flutter version
flutter --version

REM Run Flutter doctor for diagnostics
flutter doctor -v
```

**Installing Multiple Packages**:
```bash
# Python - from project root
pip install -e packages/auth_service
pip install -e packages/code_review_agent
# or install all at once with a script

# Flutter - dependencies in pubspec.yaml
dependencies:
  package_name:
    path: ../other_package
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

### Security Requirements - Always Enforce

1. **Never commit secrets**: Use `.env` (already in `.gitignore`), Google Cloud Secret Manager in prod
2. **Environment variables required**:
   ```
   GOOGLE_CLOUD_PROJECT, GOOGLE_APPLICATION_CREDENTIALS
   OPENAI_API_KEY, ANTHROPIC_API_KEY
   JWT_SECRET_KEY (must be strong)
   ```
3. **JWT tokens**: 15-60 min expiration, use refresh tokens
4. **Input validation**: Use Pydantic (Python), validators (Dart) for all user inputs
5. **HTTPS/TLS**: Mandatory in production
6. **Rate limiting**: Configure in Cloud Load Balancing or API Gateway
7. **Logging**: Never log secrets, passwords, or PII

### Testing Strategy

**Testing is mandatory** - when implementing:
- **Python**: Write pytest tests alongside code, aim for 80%+ coverage
- **Flutter**: Write widget and unit tests, use mockito for mocking
- **Integration tests**: Test API endpoints with real HTTP calls (use test fixtures)
- Test file naming: `test_<module_name>.py` or `<widget>_test.dart`
- **All tests must be created and run before finalizing pull requests**

#### Firebase & Cloud Functions emulator usage

All tests that interact with Firebase services (Authentication, Firestore, Realtime Database, Storage, Functions, etc.) MUST run against the Firebase Emulator Suite (local or CI). Never run test suites against production Firebase projects.

Microservices implemented as Cloud Functions must be tested using the Cloud Functions emulator (part of the Firebase Emulator Suite) for integration/end-to-end tests. Start the emulators and run tests in the same runner/job so the tests can reach the local emulators.

Key guidelines:
- Use the emulator for unit/integration tests that require I/O with Firebase services.
- Run the emulators locally for developer testing and in CI jobs that require Firebase interaction.
- Always use a dedicated `project-id` for emulated tests (for example `test-project`) and do not reuse production project IDs.
- Ensure CI jobs that start emulators run tests in the same job (runners can't share running background processes across jobs).

Note (environment): The Firebase Emulator Suite is already running in the current development environment. The agents and tests should connect to the emulated services using the `test-project` project id and the following default ports (unless overridden in a custom `firebase.json`):

- Firestore emulator: 8080
- Realtime Database emulator: 9000
- Authentication (Auth) emulator: 9099
- Functions emulator: 5001
- Storage emulator: 9199

Agentes de IA que precisem consultar ou executar funções devem usar essas portas para conexões locais. Não use credenciais de produção ao apontar para os emuladores.

How to check the running emulators and ports (Windows cmd.exe):

```cmd
REM Check if a given port is listening (replace 8080 with the port you need)
netstat -ano | findstr :8080

REM If you need the process id from netstat output, use tasklist to map PID to process name
tasklist /FI "PID eq <PID_FROM_NETSTAT>"

REM View emulator log file if started with nohup in CI (or created by the workflow)
type emulators.log | more
```

If you are using PowerShell you can also tail the log interactively:

```powershell
Get-Content .\emulators.log -Wait -Tail 200
```

Example (Windows cmd - interactive):

```cmd
REM Install firebase-tools (one-time)
npm install -g firebase-tools@latest

REM Start emulators (interactive) - keep this terminal open while you run tests
firebase emulators:start --only auth,firestore,functions,storage,database --project test-project

REM In a separate terminal run your tests (pytest or npm test)
pytest
```

Example (bash / CI runner):

```bash
# Install firebase-tools
npm install -g firebase-tools@latest

# Start emulators in background and capture logs (Linux runners)
nohup firebase emulators:start --only auth,firestore,functions,storage,database --project test-project > emulators.log 2>&1 &

# Wait/health-check loop (basic)
for i in $(seq 1 60); do
  if grep -i "All emulators" emulators.log >/dev/null 2>&1 || grep -i "emulators started" emulators.log >/dev/null 2>&1; then
    echo "Emulators ready"
    break
  fi
  sleep 1
done

# Run your tests while emulators are running
pytest

# Optionally stop emulators at the end of the job
kill $(cat emulators.pid) || true
```

CI notes:
- In GitHub Actions, start the Firebase emulators inside the job before running tests and run tests in the same job (see `jobs.<job_id>.steps` in workflows). Do not attempt to start emulators in one job and use them in another.
- If you prefer an action to manage the emulator lifecycle, prefer a maintained action; otherwise start `firebase-tools` directly as shown above.

Security and data handling:
- Use seeded test data and clear or reinitialize emulator state between test runs when appropriate.
- Do not commit test credentials or secrets; use environment variables and GitHub Secrets for CI if necessary.

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

**Local CI emulation**: Run all tests + linting before finalizing pull requests

### Common Patterns and Conventions

**API Response Format** (from developer-guide.md):
```json
{
  "success": true,
  "data": {},
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
- Firestore for events/logs, Cloud SQL for relational data

### Project-Specific Constraints

1. **Serverless-first**: All services must be deployable as Cloud Functions
2. **Stateless APIs**: No server-side sessions, use JWT
3. **Multi-tenant**: Design for multiple schools/institutions (use tenant_id)
4. **LGPD/GDPR**: Handle student data with care, implement data deletion
5. **AI Explainability**: All AI decisions must be explainable (required for approval UI)
6. **Human-in-the-loop**: AI outputs always require human approval (except monitoring)

### Roadmap Navigation

Each package has a detailed roadmap file (`packages/<package_name>/roadmap.md` or `packages_dashboard/<package_name>/roadmap.md`) averaging 15KB. These contain:
- Architecture and tech stack
- Complete folder structure
- Phase-by-phase implementation tasks with checkboxes
- Code examples and API specifications
- Database schemas
- Testing requirements
- Integration points with other packages

**Always reference the specific package's roadmap before implementing features.**

### Common Pitfalls to Avoid

1. **Use pyproject.toml, not requirements.txt** - packages use modern pyproject.toml format
2. **Don't assume database schema** - schemas are defined in roadmaps
3. **Don't skip the approval interface** - human oversight is core to the project
4. **Don't implement without reading roadmap** - detailed specs exist
5. **Install packages in editable mode** - use `pip install -e .` for development
6. **Cloud Functions cold starts**: Optimize package size, use min instances for critical paths
7. **Serverless limits**: Cloud Functions 9min timeout (up to 60min), 2GB memory max (2nd gen higher)
8. **Flutter web vs mobile**: Some features differ (file pickers, platform channels)
9. **Package imports**: Use absolute imports from package name, not relative paths

### Files to Reference

**Priority reading order**:
1. `packages/<package_name>/roadmap.md` or `packages_dashboard/<package_name>/roadmap.md` - Implementation blueprint
2. `docs/developer-guide.md` - Coding standards, stack details
3. `docs/discipline-mapping.md` - FIAP course integration requirements
4. `docs/roadmap-overview.md` - Overall project roadmap and MVP scope
5. `.gitignore` - What not to commit (venv, .env, build artifacts, etc.)

### Quick Reference

**Key files in repo root**: `.gitignore`, `README.md` (project overview)
**Documentation**: All in `docs/` directory
**Python packages**: `packages/*/` (10 packages)
**Flutter packages**: `packages_dashboard/*/` (3 packages)
**All roadmaps**: `packages/*/roadmap.md` and `packages_dashboard/*/roadmap.md`
**Package structure**: Each package is independently installable
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

**Last Updated**: 2025-11-11 | **Version**: 1.0 | **Project Phase**: Planning/Documentation
