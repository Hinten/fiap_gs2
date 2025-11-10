# GitHub Actions Workflows

This directory contains CI/CD workflows for the FIAP AI-Enhanced Learning Platform.

## Available Workflows

### `copilot-setup-steps.yml`

**Purpose**: Comprehensive CI/CD pipeline for multi-language project validation and testing.

**Triggers**:
- Push to `main`, `develop`, or `feature/**` branches
- Pull requests to `main` or `develop` branches

**Jobs**:

1. **Python Backend Services Validation**
   - Validates all 13 Python microservices using a matrix strategy
   - Tests with Python 3.11 and 3.12
   - Runs: Black, isort, flake8, mypy, pytest with coverage
   - Handles planning phase gracefully (no implementation yet)

2. **Flutter Frontend Validation**
   - Sets up Flutter 3.24.x
   - Runs: analyzer, formatter, tests, web build
   - Checks for pubspec.yaml before running

3. **R Analytics Scripts Validation**
   - Sets up R 4.3
   - Installs tidyverse and ggplot2
   - Validates R script syntax

4. **Documentation & Repository Health**
   - Checks required documentation files exist
   - Validates Markdown files
   - Scans for sensitive data patterns
   - Verifies .gitignore configuration

5. **Security & Dependency Scanning**
   - Python: Safety (dependency vulnerabilities)
   - Python: Bandit (security issues in code)
   - Trivy (filesystem vulnerability scanner)

6. **Build Summary**
   - Aggregates all job results
   - Generates comprehensive summary in GitHub Actions UI

**Features**:
- ✅ Matrix strategy for efficient parallel execution
- ✅ Caching for pip and Flutter dependencies
- ✅ Minimal permissions (security best practice)
- ✅ Graceful handling of planning phase (continue-on-error)
- ✅ Comprehensive build summaries
- ✅ Security scanning integrated

**Usage**:

The workflow runs automatically on push and pull request events. No manual intervention required.

To test locally before pushing:

```bash
# Python services
cd src/apps/auth_service  # or any service
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
black .
isort .
flake8 .
pytest

# Flutter
cd src/apps/frontend_flutter
flutter pub get
flutter analyze
flutter format .
flutter test

# R scripts
R -e "source('your_script.R')"
```

**Notes**:
- During the planning phase, many checks use `continue-on-error: true` to allow workflow success even when code doesn't exist yet
- Once implementation begins, these will become mandatory checks
- The workflow is designed to scale with the project as services are implemented

## Adding New Workflows

When adding new workflows:

1. Create a new `.yml` file in this directory
2. Follow the naming convention: `<purpose>-<action>.yml`
3. Include clear comments explaining the workflow's purpose
4. Use minimal necessary permissions
5. Add appropriate caching for dependencies
6. Document the workflow in this README

## CI/CD Best Practices

- ✅ Use specific action versions (e.g., `@v4`, not `@latest`)
- ✅ Cache dependencies to speed up builds
- ✅ Use matrix strategies for testing multiple versions
- ✅ Set minimal permissions required
- ✅ Include security scanning in pipelines
- ✅ Generate meaningful build summaries
- ✅ Use secrets for sensitive data (never hardcode)

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

---

**Last Updated**: 2025-11-10  
**Maintained By**: FIAP GS 2025.2 Team
