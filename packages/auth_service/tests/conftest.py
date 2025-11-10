"""
Test configuration and fixtures for auth_service tests.
"""

import os
from typing import Generator

import pytest
from fastapi.testclient import TestClient

# Set test environment variables before importing auth_service
os.environ["FIREBASE_PROJECT_ID"] = "test-project"
os.environ["FIREBASE_SERVICE_ACCOUNT_JSON"] = ""


@pytest.fixture
def mock_firebase_config():
    """Mock Firebase configuration for testing."""
    return {
        "project_id": "test-project",
        "api_key": "test-api-key",
        "auth_domain": "test-project.firebaseapp.com",
    }


@pytest.fixture
def mock_auth_user():
    """Mock authenticated user for testing."""
    from auth_service.models import AuthUser

    return AuthUser(
        uid="test-user-123",
        email="test@example.com",
        email_verified=True,
        name="Test User",
        role="user",
        tenant_id="test-tenant",
    )


@pytest.fixture
def mock_admin_user():
    """Mock admin user for testing."""
    from auth_service.models import AuthUser

    return AuthUser(
        uid="admin-user-123",
        email="admin@example.com",
        email_verified=True,
        name="Admin User",
        role="admin",
        tenant_id="test-tenant",
    )
