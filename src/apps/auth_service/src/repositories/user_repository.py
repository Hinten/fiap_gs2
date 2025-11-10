"""User repository for DynamoDB operations."""
from datetime import datetime
from typing import Optional
from uuid import uuid4

import boto3
from botocore.exceptions import ClientError

from ..core.config import settings
from ..models.user import UserCreate, UserInDB, UserUpdate


class UserRepository:
    """Repository for user database operations."""

    def __init__(self):
        """Initialize DynamoDB client and table."""
        self.dynamodb = boto3.resource(
            "dynamodb",
            region_name=settings.aws_region,
            aws_access_key_id=settings.aws_access_key_id or None,
            aws_secret_access_key=settings.aws_secret_access_key or None,
        )
        self.table = self.dynamodb.Table(settings.dynamodb_table_users)

    async def create_user(self, user: UserCreate, hashed_password: str) -> UserInDB:
        """
        Create a new user in the database.

        Args:
            user: User creation data
            hashed_password: Pre-hashed password

        Returns:
            Created user

        Raises:
            ValueError: If email already exists
        """
        # Check if email already exists
        existing_user = await self.get_user_by_email(user.email)
        if existing_user:
            raise ValueError("Email already registered")

        user_id = str(uuid4())
        now = datetime.utcnow()

        item = {
            "user_id": user_id,
            "email": user.email,
            "full_name": user.full_name,
            "hashed_password": hashed_password,
            "is_active": True,
            "role": "user",
            "oauth_provider": None,
            "created_at": now.isoformat(),
            "updated_at": now.isoformat(),
        }

        try:
            self.table.put_item(Item=item)
        except ClientError as e:
            raise Exception(f"Failed to create user: {str(e)}")

        return UserInDB(**item, created_at=now, updated_at=now)

    async def get_user_by_id(self, user_id: str) -> Optional[UserInDB]:
        """
        Get user by ID.

        Args:
            user_id: User ID

        Returns:
            User if found, None otherwise
        """
        try:
            response = self.table.get_item(Key={"user_id": user_id})
            item = response.get("Item")

            if not item:
                return None

            # Convert ISO strings to datetime
            item["created_at"] = datetime.fromisoformat(item["created_at"])
            item["updated_at"] = datetime.fromisoformat(item["updated_at"])

            return UserInDB(**item)
        except ClientError:
            return None

    async def get_user_by_email(self, email: str) -> Optional[UserInDB]:
        """
        Get user by email using GSI.

        Args:
            email: User email

        Returns:
            User if found, None otherwise
        """
        try:
            response = self.table.query(
                IndexName="email-index",
                KeyConditionExpression="email = :email",
                ExpressionAttributeValues={":email": email},
            )

            items = response.get("Items", [])
            if not items:
                return None

            item = items[0]

            # Convert ISO strings to datetime
            item["created_at"] = datetime.fromisoformat(item["created_at"])
            item["updated_at"] = datetime.fromisoformat(item["updated_at"])

            return UserInDB(**item)
        except ClientError:
            return None

    async def update_user(
        self, user_id: str, update_data: UserUpdate
    ) -> Optional[UserInDB]:
        """
        Update user information.

        Args:
            user_id: User ID
            update_data: Data to update

        Returns:
            Updated user if found, None otherwise
        """
        # Get current user
        user = await self.get_user_by_id(user_id)
        if not user:
            return None

        # Build update expression
        update_expression_parts = []
        expression_attribute_values = {}
        expression_attribute_names = {}

        if update_data.full_name is not None:
            update_expression_parts.append("#fn = :fn")
            expression_attribute_values[":fn"] = update_data.full_name
            expression_attribute_names["#fn"] = "full_name"

        if update_data.email is not None:
            # Check if new email already exists
            existing = await self.get_user_by_email(update_data.email)
            if existing and existing.user_id != user_id:
                raise ValueError("Email already in use")

            update_expression_parts.append("email = :email")
            expression_attribute_values[":email"] = update_data.email

        if not update_expression_parts:
            return user

        # Always update updated_at
        update_expression_parts.append("updated_at = :updated_at")
        expression_attribute_values[":updated_at"] = datetime.utcnow().isoformat()

        update_expression = "SET " + ", ".join(update_expression_parts)

        try:
            kwargs = {
                "Key": {"user_id": user_id},
                "UpdateExpression": update_expression,
                "ExpressionAttributeValues": expression_attribute_values,
                "ReturnValues": "ALL_NEW",
            }

            if expression_attribute_names:
                kwargs["ExpressionAttributeNames"] = expression_attribute_names

            response = self.table.update_item(**kwargs)

            item = response["Attributes"]
            item["created_at"] = datetime.fromisoformat(item["created_at"])
            item["updated_at"] = datetime.fromisoformat(item["updated_at"])

            return UserInDB(**item)
        except ClientError as e:
            raise Exception(f"Failed to update user: {str(e)}")

    async def delete_user(self, user_id: str) -> bool:
        """
        Delete user (soft delete by setting is_active to False).

        Args:
            user_id: User ID

        Returns:
            True if successful
        """
        try:
            self.table.update_item(
                Key={"user_id": user_id},
                UpdateExpression="SET is_active = :inactive, updated_at = :updated_at",
                ExpressionAttributeValues={
                    ":inactive": False,
                    ":updated_at": datetime.utcnow().isoformat(),
                },
            )
            return True
        except ClientError:
            return False

    async def update_user_role(self, user_id: str, role: str) -> Optional[UserInDB]:
        """
        Update user role (admin only operation).

        Args:
            user_id: User ID
            role: New role (user, recruiter, admin)

        Returns:
            Updated user if found, None otherwise
        """
        try:
            response = self.table.update_item(
                Key={"user_id": user_id},
                UpdateExpression="SET #r = :role, updated_at = :updated_at",
                ExpressionAttributeNames={"#r": "role"},
                ExpressionAttributeValues={
                    ":role": role,
                    ":updated_at": datetime.utcnow().isoformat(),
                },
                ReturnValues="ALL_NEW",
            )

            item = response["Attributes"]
            item["created_at"] = datetime.fromisoformat(item["created_at"])
            item["updated_at"] = datetime.fromisoformat(item["updated_at"])

            return UserInDB(**item)
        except ClientError:
            return None


# Global repository instance
user_repository = UserRepository()
