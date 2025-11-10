"""Integration tests for user management routes."""
from datetime import datetime
from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient

from src.main import app
from src.models.user import User

client = TestClient(app)


class TestUserRoutes:
    """Test user management endpoints."""

    @patch("src.core.dependencies.decode_access_token")
    @patch("src.services.user_service.user_service.get_user")
    def test_get_current_user(self, mock_get_user, mock_decode):
        """Test getting current user profile."""
        mock_decode.return_value = {
            "sub": "test-user-id",
            "role": "user",
            "type": "access",
        }

        mock_get_user.return_value = User(
            user_id="test-user-id",
            email="test@example.com",
            full_name="Test User",
            is_active=True,
            role="user",
            oauth_provider=None,
            created_at=datetime.utcnow(),
        )

        response = client.get(
            "/api/v1/users/me", headers={"Authorization": "Bearer valid-token"}
        )

        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == "test-user-id"
        assert data["email"] == "test@example.com"

    def test_get_current_user_unauthorized(self):
        """Test getting current user without token."""
        response = client.get("/api/v1/users/me")

        assert response.status_code == 401

    @patch("src.core.dependencies.decode_access_token")
    @patch("src.services.user_service.user_service.update_user")
    def test_update_current_user(self, mock_update, mock_decode):
        """Test updating current user profile."""
        mock_decode.return_value = {
            "sub": "test-user-id",
            "role": "user",
            "type": "access",
        }

        mock_update.return_value = User(
            user_id="test-user-id",
            email="newemail@example.com",
            full_name="Updated Name",
            is_active=True,
            role="user",
            oauth_provider=None,
            created_at=datetime.utcnow(),
        )

        response = client.put(
            "/api/v1/users/me",
            headers={"Authorization": "Bearer valid-token"},
            json={"full_name": "Updated Name", "email": "newemail@example.com"},
        )

        assert response.status_code == 200
        data = response.json()
        assert data["full_name"] == "Updated Name"
        assert data["email"] == "newemail@example.com"

    @patch("src.core.dependencies.decode_access_token")
    @patch("src.services.user_service.user_service.delete_user")
    def test_delete_current_user(self, mock_delete, mock_decode):
        """Test deleting current user account."""
        mock_decode.return_value = {
            "sub": "test-user-id",
            "role": "user",
            "type": "access",
        }

        mock_delete.return_value = True

        response = client.delete(
            "/api/v1/users/me", headers={"Authorization": "Bearer valid-token"}
        )

        assert response.status_code == 204

    @patch("src.core.dependencies.decode_access_token")
    @patch("src.services.user_service.user_service.get_user")
    def test_export_user_data(self, mock_get_user, mock_decode):
        """Test exporting user data (LGPD compliance)."""
        mock_decode.return_value = {
            "sub": "test-user-id",
            "role": "user",
            "type": "access",
        }

        now = datetime.utcnow()
        mock_get_user.return_value = User(
            user_id="test-user-id",
            email="test@example.com",
            full_name="Test User",
            is_active=True,
            role="user",
            oauth_provider=None,
            created_at=now,
        )

        response = client.get(
            "/api/v1/users/me/data-export",
            headers={"Authorization": "Bearer valid-token"},
        )

        assert response.status_code == 200
        data = response.json()
        assert "user_id" in data
        assert "email" in data
        assert "full_name" in data
        assert "created_at" in data

    @patch("src.core.dependencies.decode_access_token")
    @patch("src.services.user_service.user_service.get_user")
    def test_admin_get_user_by_id(self, mock_get_user, mock_decode):
        """Test admin getting user by ID."""
        mock_decode.return_value = {
            "sub": "admin-id",
            "role": "admin",
            "type": "access",
        }

        mock_get_user.return_value = User(
            user_id="other-user-id",
            email="other@example.com",
            full_name="Other User",
            is_active=True,
            role="user",
            oauth_provider=None,
            created_at=datetime.utcnow(),
        )

        response = client.get(
            "/api/v1/users/other-user-id",
            headers={"Authorization": "Bearer admin-token"},
        )

        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == "other-user-id"

    @patch("src.core.dependencies.decode_access_token")
    def test_non_admin_cannot_get_user_by_id(self, mock_decode):
        """Test that non-admin cannot get user by ID."""
        mock_decode.return_value = {"sub": "user-id", "role": "user", "type": "access"}

        response = client.get(
            "/api/v1/users/other-user-id",
            headers={"Authorization": "Bearer user-token"},
        )

        assert response.status_code == 403

    @patch("src.core.dependencies.decode_access_token")
    @patch("src.services.user_service.user_service.update_user_role")
    def test_admin_update_user_role(self, mock_update_role, mock_decode):
        """Test admin updating user role."""
        mock_decode.return_value = {
            "sub": "admin-id",
            "role": "admin",
            "type": "access",
        }

        mock_update_role.return_value = User(
            user_id="user-id",
            email="user@example.com",
            full_name="User",
            is_active=True,
            role="recruiter",
            oauth_provider=None,
            created_at=datetime.utcnow(),
        )

        response = client.put(
            "/api/v1/users/user-id/role?role=recruiter",
            headers={"Authorization": "Bearer admin-token"},
        )

        assert response.status_code == 200
        data = response.json()
        assert data["role"] == "recruiter"
