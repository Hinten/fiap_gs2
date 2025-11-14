"""
Firebase Admin initialization for Research Management.
"""

import os
from typing import Optional

import firebase_admin
from firebase_admin import credentials, firestore

from .config import get_settings

_db: Optional[firestore.Client] = None


def initialize_firebase() -> firestore.Client:
    """
    Initialize Firebase Admin SDK and return Firestore client.

    Returns:
        Firestore client instance
    """
    global _db

    if _db is not None:
        return _db

    settings = get_settings()

    # Check if using emulator
    if settings.firestore_emulator_host:
        os.environ["FIRESTORE_EMULATOR_HOST"] = settings.firestore_emulator_host
        # For emulator, use default app without credentials
        if not firebase_admin._apps:
            firebase_admin.initialize_app(
                options={"projectId": settings.firebase_project_id}
            )
    else:
        # Production: use credentials
        cred_dict = settings.get_firebase_credentials_dict()
        if cred_dict:
            cred = credentials.Certificate(cred_dict)
            if not firebase_admin._apps:
                firebase_admin.initialize_app(cred)
        else:
            # Try default credentials
            if not firebase_admin._apps:
                firebase_admin.initialize_app()

    _db = firestore.client()
    return _db


def get_db() -> firestore.Client:
    """
    Get Firestore database client.

    Returns:
        Firestore client instance
    """
    if _db is None:
        return initialize_firebase()
    return _db
