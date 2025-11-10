"""Integration tests for authentication routes."""
from datetime import datetime
from unittest.mock import AsyncMock, patch

import pytest
from fastapi.testclient import TestClient

from src.main import app
from src.models.user import User, UserInDB

client = TestClient(app)


class TestAuthRoutes:
    """Test authentication endpoints."""

    @patch("src.services.auth_service.auth_service.register_user")
    def test_register_success(self, mock_register):
        """Test successful user registration."""
        # Mock the register_user method
        mock_register.return_value = User(
            user_id="test-id",
            email="newuser@example.com",
            full_name="New User",
            is_active=True,
            role="user",
            oauth_provider=None,
            created_at=datetime.utcnow(),
        )

        response = client.post(
            "/api/v1/auth/register",
            json={
                "email": "newuser@example.com",
                "full_name": "New User",
                "password": "SecurePass123!",
            },
        )

        assert response.status_code == 201
        data = response.json()
        assert data["email"] == "newuser@example.com"
        assert data["full_name"] == "New User"
        assert "password" not in data
        assert "user_id" in data

    @patch("src.services.auth_service.auth_service.register_user")
    def test_register_duplicate_email(self, mock_register):
        """Test registration with duplicate email."""
        mock_register.side_effect = ValueError("Email already registered")

        response = client.post(
            "/api/v1/auth/register",
            json={
                "email": "existing@example.com",
                "full_name": "Existing User",
                "password": "SecurePass123!",
            },
        )

        assert response.status_code == 400
        assert "already registered" in response.json()["detail"].lower()

    def test_register_weak_password(self):
        """Test registration with weak password."""
        response = client.post(
            "/api/v1/auth/register",
            json={
                "email": "test@example.com",
                "full_name": "Test User",
                "password": "weak",  # Too short, no uppercase, no digit
            },
        )

        assert response.status_code == 422  # Validation error

    def test_register_invalid_email(self):
        """Test registration with invalid email."""
        response = client.post(
            "/api/v1/auth/register",
            json={
                "email": "not-an-email",
                "full_name": "Test User",
                "password": "SecurePass123!",
            },
        )

        assert response.status_code == 422  # Validation error

    @patch("src.services.auth_service.auth_service.login")
    def test_login_success(self, mock_login):
        """Test successful login."""
        from src.models.token import Token

        mock_login.return_value = Token(
            access_token="test-access-token",
            refresh_token="test-refresh-token",
            token_type="bearer",
        )

        response = client.post(
            "/api/v1/auth/login",
            data={"username": "test@example.com", "password": "TestPass123!"},
        )

        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"

    @patch("src.services.auth_service.auth_service.login")
    def test_login_invalid_credentials(self, mock_login):
        """Test login with invalid credentials."""
        mock_login.return_value = None

        response = client.post(
            "/api/v1/auth/login",
            data={"username": "test@example.com", "password": "WrongPassword"},
        )

        assert response.status_code == 401
        assert "incorrect" in response.json()["detail"].lower()

    @patch("src.services.auth_service.auth_service.refresh_access_token")
    def test_refresh_token_success(self, mock_refresh):
        """Test successful token refresh."""
        from src.models.token import Token

        mock_refresh.return_value = Token(
            access_token="new-access-token",
            refresh_token="new-refresh-token",
            token_type="bearer",
        )

        response = client.post(
            "/api/v1/auth/refresh", json={"refresh_token": "valid-refresh-token"}
        )

        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data

    @patch("src.services.auth_service.auth_service.refresh_access_token")
    def test_refresh_token_invalid(self, mock_refresh):
        """Test token refresh with invalid token."""
        mock_refresh.return_value = None

        response = client.post(
            "/api/v1/auth/refresh", json={"refresh_token": "invalid-token"}
        )

        assert response.status_code == 401

    def test_logout(self):
        """Test logout endpoint."""
        response = client.post("/api/v1/auth/logout")

        # For now, logout just returns 204 (placeholder)
        assert response.status_code == 204


class TestHealthEndpoints:
    """Test health check endpoints."""

    def test_root_endpoint(self):
        """Test root endpoint."""
        response = client.get("/")

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "service" in data

    def test_health_check(self):
        """Test health check endpoint."""
        response = client.get("/health")

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "auth_service"
