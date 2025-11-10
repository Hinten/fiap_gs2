"""
Tests for data models.
"""

import pytest

from auth_service.models import AuthUser, FirebaseConfig, TokenResponse


def test_auth_user_creation(mock_auth_user):
    """Test AuthUser model creation."""
    assert mock_auth_user.uid == "test-user-123"
    assert mock_auth_user.email == "test@example.com"
    assert mock_auth_user.email_verified is True
    assert mock_auth_user.role == "user"


def test_auth_user_with_custom_claims():
    """Test AuthUser with custom claims."""
    user = AuthUser(
        uid="user123",
        email="user@example.com",
        custom_claims={"subscription": "premium", "level": 5},
    )
    assert user.custom_claims["subscription"] == "premium"
    assert user.custom_claims["level"] == 5


def test_firebase_config_model():
    """Test FirebaseConfig model."""
    config = FirebaseConfig(
        api_key="test-key",
        auth_domain="test.firebaseapp.com",
        project_id="test-project",
        app_id="test-app-id",
    )
    assert config.api_key == "test-key"
    assert config.project_id == "test-project"


def test_token_response_model():
    """Test TokenResponse model."""
    user = AuthUser(uid="user123", email="user@example.com")
    response = TokenResponse(id_token="test-token", expires_in=3600, user=user)
    assert response.id_token == "test-token"
    assert response.expires_in == 3600
    assert response.user.uid == "user123"
