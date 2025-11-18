"""
Configuration settings for Research Management System.
"""

import base64
import json
import os
from functools import lru_cache
from typing import Optional

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings."""

    # Firebase Configuration
    firebase_project_id: str = os.getenv("FIREBASE_PROJECT_ID", "demo-test-project")
    firebase_service_account_base64: Optional[str] = os.getenv(
        "FIREBASE_SERVICE_ACCOUNT_BASE64"
    )
    google_application_credentials: Optional[str] = os.getenv(
        "GOOGLE_APPLICATION_CREDENTIALS"
    )

    # Firebase Emulator Configuration (for local testing)
    firebase_auth_emulator_host: Optional[str] = os.getenv(
        "FIREBASE_AUTH_EMULATOR_HOST"
    )
    firestore_emulator_host: Optional[str] = os.getenv("FIRESTORE_EMULATOR_HOST")

    # API Configuration
    api_version: str = "v1"
    api_prefix: str = "/api/v1"

    # Alert Configuration
    alert_no_advisor_days: int = 14  # Days before alerting about no advisor
    alert_no_update_days: int = 30  # Days before alerting about no updates
    alert_deadline_warning_days: int = 7  # Days before deadline to send warning

    model_config = {
        "env_file": ".env",
        "case_sensitive": False,
    }

    def get_firebase_credentials_dict(self) -> Optional[dict]:
        """
        Get Firebase credentials as a dictionary.

        Returns credentials from base64 encoded env var or file path.
        """
        if self.firebase_service_account_base64:
            try:
                credentials_json = base64.b64decode(
                    self.firebase_service_account_base64
                )
                return json.loads(credentials_json)
            except Exception as e:
                print(f"Error decoding Firebase credentials: {e}")
                return None
        elif self.google_application_credentials:
            try:
                with open(self.google_application_credentials, "r") as f:
                    return json.load(f)
            except Exception as e:
                print(f"Error reading Firebase credentials file: {e}")
                return None
        return None


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()
