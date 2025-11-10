"""User service for user management operations."""
from typing import Optional

from ..models.user import User, UserInDB, UserUpdate
from ..repositories.user_repository import user_repository


class UserService:
    """Service for user management operations."""

    def __init__(self):
        """Initialize user service."""
        self.user_repo = user_repository

    async def get_user(self, user_id: str) -> Optional[User]:
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

    async def update_user(
        self, user_id: str, update_data: UserUpdate
    ) -> Optional[User]:
        """
        Update user information.

        Args:
            user_id: User ID
            update_data: Data to update

        Returns:
            Updated user if found, None otherwise

        Raises:
            ValueError: If validation fails (e.g., email already in use)
        """
        user_in_db = await self.user_repo.update_user(user_id, update_data)

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

    async def delete_user(self, user_id: str) -> bool:
        """
        Delete user (soft delete).

        Args:
            user_id: User ID

        Returns:
            True if successful
        """
        return await self.user_repo.delete_user(user_id)

    async def update_user_role(self, user_id: str, role: str) -> Optional[User]:
        """
        Update user role (admin operation).

        Args:
            user_id: User ID
            role: New role (user, recruiter, admin)

        Returns:
            Updated user if found, None otherwise
        """
        # Validate role
        valid_roles = {"user", "recruiter", "admin"}
        if role not in valid_roles:
            raise ValueError(f"Invalid role. Must be one of: {valid_roles}")

        user_in_db = await self.user_repo.update_user_role(user_id, role)

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
user_service = UserService()
