"""
FastAPI middleware for Firebase Authentication token verification.

This module provides middleware and dependency functions for protecting
FastAPI endpoints with Firebase Authentication.
"""

import logging
from typing import Optional

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from firebase_admin import auth

from .firebase_admin import get_auth_client
from .models import AuthUser

logger = logging.getLogger(__name__)

security = HTTPBearer(auto_error=False)


async def verify_firebase_token(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
) -> AuthUser:
    """
    Verify Firebase ID token from Authorization header.

    This is a FastAPI dependency that can be used to protect endpoints.

    Args:
        credentials: HTTP Bearer credentials from Authorization header

    Returns:
        AuthUser: Authenticated user with claims

    Raises:
        HTTPException: If token is missing, invalid, or expired

    Example:
        ```python
        @app.get("/protected")
        async def protected_route(user: AuthUser = Depends(verify_firebase_token)):
            return {"message": f"Hello {user.email}"}
        ```
    """
    if credentials is None:
        logger.warning("No authorization credentials provided")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials

    try:
        # Verify the ID token
        auth_client = get_auth_client()
        decoded_token = auth_client.verify_id_token(token)

        # Extract user information
        user = AuthUser(
            uid=decoded_token.get("uid"),
            email=decoded_token.get("email"),
            email_verified=decoded_token.get("email_verified", False),
            name=decoded_token.get("name"),
            picture=decoded_token.get("picture"),
            phone_number=decoded_token.get("phone_number"),
            role=decoded_token.get("role"),
            tenant_id=decoded_token.get("tenant_id"),
            custom_claims={
                k: v
                for k, v in decoded_token.items()
                if k
                not in [
                    "uid",
                    "email",
                    "email_verified",
                    "name",
                    "picture",
                    "phone_number",
                    "role",
                    "tenant_id",
                    "iat",
                    "exp",
                    "auth_time",
                ]
            },
            issued_at=decoded_token.get("iat"),
            expires_at=decoded_token.get("exp"),
            auth_time=decoded_token.get("auth_time"),
        )

        logger.info(f"Successfully authenticated user: {user.uid}")
        return user

    except auth.ExpiredIdTokenError:
        logger.warning("Expired ID token")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired. Please refresh your token.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except auth.RevokedIdTokenError:
        logger.warning("Revoked ID token")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has been revoked",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except auth.InvalidIdTokenError as e:
        logger.warning(f"Invalid ID token: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as e:
        logger.error(f"Unexpected error during token verification: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Authentication service error",
        )


def require_role(required_role: str):
    """
    Dependency factory for role-based access control.

    Args:
        required_role: Required role (e.g., "admin", "recruiter")

    Returns:
        Dependency function that checks user role

    Example:
        ```python
        @app.get("/admin-only")
        async def admin_route(user: AuthUser = Depends(require_role("admin"))):
            return {"message": "Admin access granted"}
        ```
    """

    async def role_checker(user: AuthUser = Depends(verify_firebase_token)) -> AuthUser:
        if user.role != required_role and user.role != "admin":
            logger.warning(
                f"User {user.uid} attempted to access {required_role} resource with role {user.role}"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions. Required role: {required_role}",
            )
        return user

    return role_checker


def require_any_role(*roles: str):
    """
    Dependency factory for checking if user has any of the specified roles.

    Args:
        *roles: Allowed roles

    Returns:
        Dependency function that checks user role

    Example:
        ```python
        @app.get("/recruiter-or-admin")
        async def route(user: AuthUser = Depends(require_any_role("admin", "recruiter"))):
            return {"message": "Access granted"}
        ```
    """

    async def role_checker(user: AuthUser = Depends(verify_firebase_token)) -> AuthUser:
        if user.role not in roles and user.role != "admin":
            logger.warning(
                f"User {user.uid} attempted to access resource with role {user.role}, required: {roles}"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions. Required roles: {', '.join(roles)}",
            )
        return user

    return role_checker


def require_tenant(tenant_id: str):
    """
    Dependency factory for tenant-based access control.

    Args:
        tenant_id: Required tenant ID

    Returns:
        Dependency function that checks user tenant

    Example:
        ```python
        @app.get("/tenant-data")
        async def tenant_route(user: AuthUser = Depends(require_tenant("fiap-school-1"))):
            return {"message": "Tenant access granted"}
        ```
    """

    async def tenant_checker(
        user: AuthUser = Depends(verify_firebase_token),
    ) -> AuthUser:
        if user.tenant_id != tenant_id and user.role != "admin":
            logger.warning(
                f"User {user.uid} attempted to access tenant {tenant_id} but belongs to {user.tenant_id}"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. User does not belong to tenant: {tenant_id}",
            )
        return user

    return tenant_checker
