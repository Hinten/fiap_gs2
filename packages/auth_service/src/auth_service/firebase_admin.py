"""
Firebase Admin SDK initialization and configuration.

This module handles the initialization of Firebase Admin SDK for server-side
authentication and user management.
"""

import json
import logging
import os
from typing import Optional

import firebase_admin
from firebase_admin import auth, credentials
from pydantic import ConfigDict, Field
from pydantic_settings import BaseSettings

logger = logging.getLogger(__name__)


class FirebaseConfig(BaseSettings):
    """Firebase configuration from environment variables."""

    model_config = ConfigDict(env_file=".env", case_sensitive=False)

    firebase_project_id: str = Field(
        ...,
        description="Firebase project ID",
    )
    firebase_service_account_json: Optional[str] = Field(
        None,
        description="Firebase service account JSON string",
    )
    firebase_service_account_base64: Optional[str] = Field(
        None,
        description="Base64-encoded Firebase service account JSON",
    )
    firebase_database_url: Optional[str] = Field(
        None,
        description="Firebase Realtime Database URL",
    )


_firebase_app: Optional[firebase_admin.App] = None


def init_firebase_admin(config: Optional[FirebaseConfig] = None) -> firebase_admin.App:
    """
    Initialize Firebase Admin SDK.

    Args:
        config: Optional Firebase configuration. If not provided, loads from environment.

    Returns:
        firebase_admin.App: Initialized Firebase app instance

    Raises:
        ValueError: If configuration is invalid or missing
    """
    global _firebase_app

    if _firebase_app is not None:
        logger.debug("Firebase Admin already initialized")
        return _firebase_app

    if config is None:
        config = FirebaseConfig()

    try:
        # Try to get service account from different sources
        service_account_dict = None

        if config.firebase_service_account_json:
            # Direct JSON string
            service_account_dict = json.loads(config.firebase_service_account_json)
        elif config.firebase_service_account_base64:
            # Base64-encoded JSON (for secure storage)
            import base64

            decoded = base64.b64decode(config.firebase_service_account_base64)
            service_account_dict = json.loads(decoded.decode("utf-8"))
        else:
            # Try to use Application Default Credentials (ADC)
            # This works in Google Cloud environments
            logger.info(
                "No service account provided, attempting to use Application Default Credentials"
            )
            cred = credentials.ApplicationDefault()
            options = {"projectId": config.firebase_project_id}
            if config.firebase_database_url:
                options["databaseURL"] = config.firebase_database_url

            _firebase_app = firebase_admin.initialize_app(cred, options)
            logger.info(
                f"Firebase Admin initialized with ADC for project: {config.firebase_project_id}"
            )
            return _firebase_app

        # Initialize with service account
        cred = credentials.Certificate(service_account_dict)
        options = {"projectId": config.firebase_project_id}
        if config.firebase_database_url:
            options["databaseURL"] = config.firebase_database_url

        _firebase_app = firebase_admin.initialize_app(cred, options)
        logger.info(
            f"Firebase Admin initialized successfully for project: {config.firebase_project_id}"
        )
        return _firebase_app

    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in Firebase service account: {e}")
        raise ValueError(
            "Invalid Firebase service account JSON. Please check your configuration."
        )
    except Exception as e:
        logger.error(f"Failed to initialize Firebase Admin: {e}")
        raise


def get_firebase_admin() -> firebase_admin.App:
    """
    Get the initialized Firebase Admin app instance.

    Returns:
        firebase_admin.App: Firebase app instance

    Raises:
        RuntimeError: If Firebase Admin has not been initialized
    """
    global _firebase_app

    if _firebase_app is None:
        # Auto-initialize if not done yet
        logger.info("Firebase Admin not initialized, auto-initializing...")
        return init_firebase_admin()

    return _firebase_app


def get_auth_client() -> auth:
    """
    Get Firebase Auth client.

    Returns:
        firebase_admin.auth: Firebase Auth client
    """
    get_firebase_admin()  # Ensure initialized
    return auth
