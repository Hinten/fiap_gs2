"""Tests for security module."""
from datetime import datetime, timedelta

import pytest
from jose import JWTError, jwt

from src.core.config import settings
from src.core.security import (create_access_token, create_refresh_token,
                               decode_access_token, decode_refresh_token,
                               hash_password, verify_password)


class TestPasswordHashing:
    """Test password hashing functions."""

    def test_hash_password(self):
        """Test that password is hashed."""
        password = "TestPassword123!"
        hashed = hash_password(password)

        assert hashed != password
        assert len(hashed) > 0
        assert hashed.startswith("$2b$")  # bcrypt prefix

    def test_verify_password_correct(self):
        """Test password verification with correct password."""
        password = "TestPassword123!"
        hashed = hash_password(password)

        assert verify_password(password, hashed) is True

    def test_verify_password_incorrect(self):
        """Test password verification with incorrect password."""
        password = "TestPassword123!"
        hashed = hash_password(password)

        assert verify_password("WrongPassword!", hashed) is False

    def test_same_password_different_hashes(self):
        """Test that same password produces different hashes (salt)."""
        password = "TestPassword123!"
        hash1 = hash_password(password)
        hash2 = hash_password(password)

        assert hash1 != hash2
        assert verify_password(password, hash1)
        assert verify_password(password, hash2)


class TestJWTTokens:
    """Test JWT token functions."""

    def test_create_access_token(self):
        """Test access token creation."""
        data = {"sub": "user123", "role": "user"}
        token = create_access_token(data)

        assert isinstance(token, str)
        assert len(token) > 0

        # Decode without verification to check payload
        payload = jwt.decode(
            token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm]
        )

        assert payload["sub"] == "user123"
        assert payload["role"] == "user"
        assert payload["type"] == "access"
        assert "exp" in payload

    def test_create_refresh_token(self):
        """Test refresh token creation."""
        user_id = "user123"
        token = create_refresh_token(user_id)

        assert isinstance(token, str)
        assert len(token) > 0

        # Decode without verification to check payload
        payload = jwt.decode(
            token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm]
        )

        assert payload["sub"] == user_id
        assert payload["type"] == "refresh"
        assert "exp" in payload

    def test_decode_access_token_valid(self):
        """Test decoding valid access token."""
        data = {"sub": "user123", "role": "admin"}
        token = create_access_token(data)

        payload = decode_access_token(token)

        assert payload["sub"] == "user123"
        assert payload["role"] == "admin"
        assert payload["type"] == "access"

    def test_decode_access_token_invalid(self):
        """Test decoding invalid access token."""
        invalid_token = "invalid.token.here"

        with pytest.raises(JWTError):
            decode_access_token(invalid_token)

    def test_decode_refresh_token_valid(self):
        """Test decoding valid refresh token."""
        user_id = "user123"
        token = create_refresh_token(user_id)

        payload = decode_refresh_token(token)

        assert payload["sub"] == user_id
        assert payload["type"] == "refresh"

    def test_decode_wrong_token_type(self):
        """Test that access token cannot be decoded as refresh token."""
        data = {"sub": "user123", "role": "user"}
        access_token = create_access_token(data)

        with pytest.raises(JWTError):
            decode_refresh_token(access_token)

    def test_access_token_expiration(self):
        """Test that access token includes expiration."""
        data = {"sub": "user123", "role": "user"}
        token = create_access_token(data)

        payload = jwt.decode(
            token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm]
        )

        exp = datetime.fromtimestamp(payload["exp"])
        now = datetime.utcnow()

        # Token should expire in the future
        assert exp > now

        # Token should expire within expected time range
        expected_exp = now + timedelta(minutes=settings.access_token_expire_minutes)
        assert abs((exp - expected_exp).total_seconds()) < 5  # Allow 5 second margin

    def test_custom_expiration(self):
        """Test access token with custom expiration."""
        data = {"sub": "user123", "role": "user"}
        custom_delta = timedelta(minutes=60)
        token = create_access_token(data, expires_delta=custom_delta)

        payload = jwt.decode(
            token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm]
        )

        exp = datetime.fromtimestamp(payload["exp"])
        now = datetime.utcnow()
        expected_exp = now + custom_delta

        assert abs((exp - expected_exp).total_seconds()) < 5  # Allow 5 second margin
