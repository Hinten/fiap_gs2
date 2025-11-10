"""
Tests for Firebase Admin initialization and configuration.
"""

import pytest

from auth_service.firebase_admin import FirebaseConfig


def test_firebase_config_creation():
    """Test FirebaseConfig model creation."""
    config = FirebaseConfig(
        firebase_project_id="test-project",
        firebase_service_account_json='{"type": "service_account"}',
    )
    assert config.firebase_project_id == "test-project"
    assert config.firebase_service_account_json == '{"type": "service_account"}'


def test_firebase_config_optional_fields():
    """Test FirebaseConfig with optional fields."""
    config = FirebaseConfig(
        firebase_project_id="test-project",
        firebase_database_url="https://test.firebaseio.com",
    )
    assert config.firebase_project_id == "test-project"
    assert config.firebase_database_url == "https://test.firebaseio.com"
    # Service account JSON defaults to empty string from environment
    assert config.firebase_service_account_json == ""
