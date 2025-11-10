"""Authentication service for user registration and login."""
from datetime import timedelta
from typing import Optional

from ..core.security import (create_access_token, create_refresh_token,
                             decode_refresh_token, hash_password,
                             verify_password)
from ..models.token import Token
from ..models.user import User, UserCreate, UserInDB
from ..repositories.user_repository import user_repository


class AuthService:
    """Service for authentication operations."""

    def __init__(self):
        """Initialize auth service."""
        self.user_repo = user_repository

    async def register_user(self, user_data: UserCreate) -> User:
        """
        Register a new user.

        Args:
            user_data: User registration data

        Returns:
            Created user (without password)

        Raises:
            ValueError: If email already exists or validation fails
        """
        # Hash password
        hashed_pwd = hash_password(user_data.password)

        # Create user in database
        user_in_db = await self.user_repo.create_user(user_data, hashed_pwd)

        # Return user without password
        return User(
            user_id=user_in_db.user_id,
            email=user_in_db.email,
            full_name=user_in_db.full_name,
            is_active=user_in_db.is_active,
            role=user_in_db.role,
            oauth_provider=user_in_db.oauth_provider,
            created_at=user_in_db.created_at,
        )

    async def authenticate_user(self, email: str, password: str) -> Optional[UserInDB]:
        """
        Authenticate a user with email and password.

        Args:
            email: User email
            password: Plain text password

        Returns:
            User if authentication successful, None otherwise
        """
        # Get user by email
        user = await self.user_repo.get_user_by_email(email)

        if not user:
            return None

        # Check if user is active
        if not user.is_active:
            return None

        # Verify password
        if not user.hashed_password:
            # OAuth user without password
            return None

        if not verify_password(password, user.hashed_password):
            return None

        return user

    async def login(self, email: str, password: str) -> Optional[Token]:
        """
        Login user and generate tokens.

        Args:
            email: User email
            password: Plain text password

        Returns:
            Token object with access and refresh tokens, or None if auth fails
        """
        # Authenticate user
        user = await self.authenticate_user(email, password)

        if not user:
            return None

        # Generate tokens
        access_token = create_access_token(
            data={"sub": user.user_id, "role": user.role}
        )
        refresh_token = create_refresh_token(user.user_id)

        return Token(
            access_token=access_token, refresh_token=refresh_token, token_type="bearer"
        )

    async def refresh_access_token(self, refresh_token: str) -> Optional[Token]:
        """
        Refresh access token using a refresh token.

        Args:
            refresh_token: Valid refresh token

        Returns:
            New token object, or None if refresh token is invalid
        """
        try:
            # Decode refresh token
            payload = decode_refresh_token(refresh_token)
            user_id = payload.get("sub")

            if not user_id:
                return None

            # Get user to verify they still exist and are active
            user = await self.user_repo.get_user_by_id(user_id)

            if not user or not user.is_active:
                return None

            # Generate new tokens
            new_access_token = create_access_token(
                data={"sub": user.user_id, "role": user.role}
            )
            new_refresh_token = create_refresh_token(user.user_id)

            return Token(
                access_token=new_access_token,
                refresh_token=new_refresh_token,
                token_type="bearer",
            )
        except Exception:
            return None

    async def get_user_by_id(self, user_id: str) -> Optional[User]:
        """
        Get user by ID.

        Args:
            user_id: User ID

        Returns:
            User if found, None otherwise
        """
        user_in_db = await self.user_repo.get_user_by_id(user_id)

        if not user_in_db:
            return None

        return User(
            user_id=user_in_db.user_id,
            email=user_in_db.email,
            full_name=user_in_db.full_name,
            is_active=user_in_db.is_active,
            role=user_in_db.role,
            oauth_provider=user_in_db.oauth_provider,
            created_at=user_in_db.created_at,
        )


# Global service instance
auth_service = AuthService()
