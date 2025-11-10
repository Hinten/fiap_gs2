"""
Utility functions for Firebase Authentication.
"""

import logging
from typing import Any, Dict, Optional

from firebase_admin import auth

from .firebase_admin import get_auth_client
from .models import AuthUser

logger = logging.getLogger(__name__)


def get_user_claims(uid: str) -> Dict[str, Any]:
    """
    Get custom claims for a user.

    Args:
        uid: Firebase user ID

    Returns:
        Dict containing user's custom claims

    Raises:
        auth.UserNotFoundError: If user doesn't exist
    """
    auth_client = get_auth_client()
    user = auth_client.get_user(uid)
    return user.custom_claims or {}


def set_custom_claims(uid: str, claims: Dict[str, Any]) -> None:
    """
    Set custom claims for a user.

    Args:
        uid: Firebase user ID
        claims: Dictionary of custom claims to set

    Raises:
        auth.UserNotFoundError: If user doesn't exist

    Example:
        ```python
        set_custom_claims("user123", {"role": "admin", "tenant_id": "fiap-1"})
        ```
    """
    auth_client = get_auth_client()
    auth_client.set_custom_user_claims(uid, claims)
    logger.info(f"Set custom claims for user {uid}: {claims}")


def verify_custom_claims(user: AuthUser, required_claims: Dict[str, Any]) -> bool:
    """
    Verify if user has required custom claims.

    Args:
        user: Authenticated user
        required_claims: Dictionary of required claim key-value pairs

    Returns:
        True if user has all required claims with matching values

    Example:
        ```python
        if verify_custom_claims(user, {"role": "admin", "tenant_id": "fiap-1"}):
            # User is admin in tenant fiap-1
            pass
        ```
    """
    for key, value in required_claims.items():
        if key == "role" and user.role != value:
            return False
        elif key == "tenant_id" and user.tenant_id != value:
            return False
        elif key in user.custom_claims and user.custom_claims[key] != value:
            return False
        elif key not in ["role", "tenant_id"] and key not in user.custom_claims:
            return False
    return True


def create_custom_token(
    uid: str, additional_claims: Optional[Dict[str, Any]] = None
) -> str:
    """
    Create a custom Firebase token for a user.

    This is useful for server-side user authentication (e.g., after OAuth flow).

    Args:
        uid: Firebase user ID
        additional_claims: Optional additional claims to include in token

    Returns:
        Custom token string that can be used to sign in on the client

    Example:
        ```python
        # After successful OAuth, create custom token for frontend
        token = create_custom_token("user123", {"role": "admin"})
        return {"custom_token": token}
        ```
    """
    auth_client = get_auth_client()
    token = auth_client.create_custom_token(uid, additional_claims)
    logger.info(f"Created custom token for user {uid}")
    return token.decode("utf-8") if isinstance(token, bytes) else token


def revoke_refresh_tokens(uid: str) -> None:
    """
    Revoke all refresh tokens for a user.

    This effectively signs out the user from all devices.

    Args:
        uid: Firebase user ID

    Raises:
        auth.UserNotFoundError: If user doesn't exist
    """
    auth_client = get_auth_client()
    auth_client.revoke_refresh_tokens(uid)
    logger.info(f"Revoked all refresh tokens for user {uid}")


def get_user_by_email(email: str) -> Optional[auth.UserRecord]:
    """
    Get user record by email.

    Args:
        email: User email address

    Returns:
        UserRecord if found, None otherwise
    """
    auth_client = get_auth_client()
    try:
        user = auth_client.get_user_by_email(email)
        return user
    except auth.UserNotFoundError:
        return None


def create_user(
    email: str,
    password: Optional[str] = None,
    display_name: Optional[str] = None,
    photo_url: Optional[str] = None,
    email_verified: bool = False,
) -> auth.UserRecord:
    """
    Create a new Firebase user.

    Args:
        email: User email address
        password: User password (optional for OAuth users)
        display_name: User display name
        photo_url: User photo URL
        email_verified: Whether email is verified

    Returns:
        Created UserRecord

    Example:
        ```python
        user = create_user(
            email="newuser@example.com",
            password="SecurePass123",
            display_name="New User",
            email_verified=True
        )
        ```
    """
    auth_client = get_auth_client()
    user_create_kwargs = {
        "email": email,
        "email_verified": email_verified,
    }
    if password:
        user_create_kwargs["password"] = password
    if display_name:
        user_create_kwargs["display_name"] = display_name
    if photo_url:
        user_create_kwargs["photo_url"] = photo_url

    user = auth_client.create_user(**user_create_kwargs)
    logger.info(f"Created new user: {user.uid} ({email})")
    return user


def update_user(
    uid: str,
    email: Optional[str] = None,
    password: Optional[str] = None,
    display_name: Optional[str] = None,
    photo_url: Optional[str] = None,
    email_verified: Optional[bool] = None,
    disabled: Optional[bool] = None,
) -> auth.UserRecord:
    """
    Update Firebase user.

    Args:
        uid: User ID
        email: New email
        password: New password
        display_name: New display name
        photo_url: New photo URL
        email_verified: Email verification status
        disabled: Account disabled status

    Returns:
        Updated UserRecord
    """
    auth_client = get_auth_client()
    update_kwargs = {}
    if email is not None:
        update_kwargs["email"] = email
    if password is not None:
        update_kwargs["password"] = password
    if display_name is not None:
        update_kwargs["display_name"] = display_name
    if photo_url is not None:
        update_kwargs["photo_url"] = photo_url
    if email_verified is not None:
        update_kwargs["email_verified"] = email_verified
    if disabled is not None:
        update_kwargs["disabled"] = disabled

    user = auth_client.update_user(uid, **update_kwargs)
    logger.info(f"Updated user: {uid}")
    return user


def delete_user(uid: str) -> None:
    """
    Delete a Firebase user.

    Args:
        uid: User ID

    Raises:
        auth.UserNotFoundError: If user doesn't exist
    """
    auth_client = get_auth_client()
    auth_client.delete_user(uid)
    logger.info(f"Deleted user: {uid}")
