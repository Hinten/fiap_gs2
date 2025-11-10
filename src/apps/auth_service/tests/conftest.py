"""Test fixtures for auth service tests."""
import os
from datetime import datetime
from typing import Generator

import pytest

# Set test environment variables
os.environ["JWT_SECRET_KEY"] = "test-secret-key-for-testing-only"
os.environ["AWS_REGION"] = "us-east-1"
os.environ["DYNAMODB_TABLE_USERS"] = "test-users"
os.environ["DYNAMODB_TABLE_REFRESH_TOKENS"] = "test-refresh-tokens"


@pytest.fixture
def sample_user_data():
    """Sample user data for testing."""
    return {
        "email": "test@example.com",
        "full_name": "Test User",
        "password": "TestPass123!",
    }


@pytest.fixture
def sample_user_in_db():
    """Sample user as stored in database."""
    from src.models.user import UserInDB

    return UserInDB(
        user_id="test-user-id-123",
        email="test@example.com",
        full_name="Test User",
        hashed_password="$2b$12$hashed_password_here",
        is_active=True,
        role="user",
        oauth_provider=None,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )


@pytest.fixture
def valid_access_token():
    """Generate a valid access token for testing."""
    from src.core.security import create_access_token

    return create_access_token(data={"sub": "test-user-id-123", "role": "user"})


@pytest.fixture
def valid_refresh_token():
    """Generate a valid refresh token for testing."""
    from src.core.security import create_refresh_token

    return create_refresh_token("test-user-id-123")


@pytest.fixture
def admin_access_token():
    """Generate an admin access token for testing."""
    from src.core.security import create_access_token

    return create_access_token(data={"sub": "admin-user-id", "role": "admin"})
