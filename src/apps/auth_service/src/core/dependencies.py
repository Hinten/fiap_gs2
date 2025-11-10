"""FastAPI dependency injection helpers."""
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError

from .security import decode_access_token

# OAuth2 scheme for token authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


async def get_current_user_id(token: str = Depends(oauth2_scheme)) -> str:
    """
    Extract and validate user ID from JWT token.

    Args:
        token: JWT token from request header

    Returns:
        User ID from token

    Raises:
        HTTPException: If token is invalid or expired
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = decode_access_token(token)
        user_id: Optional[str] = payload.get("sub")

        if user_id is None:
            raise credentials_exception

        return user_id
    except JWTError:
        raise credentials_exception


async def get_current_user_role(token: str = Depends(oauth2_scheme)) -> str:
    """
    Extract user role from JWT token.

    Args:
        token: JWT token from request header

    Returns:
        User role from token

    Raises:
        HTTPException: If token is invalid or expired
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = decode_access_token(token)
        role: Optional[str] = payload.get("role")

        if role is None:
            raise credentials_exception

        return role
    except JWTError:
        raise credentials_exception


def require_role(required_role: str):
    """
    Create a dependency that requires a specific role.

    Args:
        required_role: Required role (e.g., "admin", "recruiter")

    Returns:
        FastAPI dependency function
    """

    async def role_checker(
        user_id: str = Depends(get_current_user_id),
        role: str = Depends(get_current_user_role),
    ) -> str:
        """Check if user has required role."""
        # Admins have access to everything
        if role == "admin":
            return user_id

        if role != required_role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions"
            )

        return user_id

    return role_checker
