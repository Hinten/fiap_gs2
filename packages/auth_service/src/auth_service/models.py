"""
Data models for Firebase Authentication.
"""

from datetime import datetime
from typing import Any, Dict, Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class AuthUser(BaseModel):
    """
    Authenticated user model with claims from Firebase ID token.
    """

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "uid": "abc123",
                "email": "user@example.com",
                "email_verified": True,
                "name": "John Doe",
                "role": "user",
                "tenant_id": "fiap-school-1",
            }
        },
    )

    uid: str = Field(..., description="Firebase user ID")
    email: Optional[EmailStr] = Field(None, description="User email address")
    email_verified: bool = Field(False, description="Whether email is verified")
    name: Optional[str] = Field(None, description="User display name")
    picture: Optional[str] = Field(None, description="User profile picture URL")
    phone_number: Optional[str] = Field(None, description="User phone number")

    # Custom claims
    role: Optional[str] = Field(None, description="User role (admin, user, recruiter)")
    tenant_id: Optional[str] = Field(None, description="Tenant/organization ID")
    custom_claims: Dict[str, Any] = Field(
        default_factory=dict, description="Additional custom claims"
    )

    # Token metadata
    issued_at: Optional[datetime] = Field(None, description="Token issued timestamp")
    expires_at: Optional[datetime] = Field(None, description="Token expiry timestamp")
    auth_time: Optional[datetime] = Field(None, description="Authentication timestamp")


class FirebaseConfig(BaseModel):
    """
    Firebase configuration model for frontend clients.
    """

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "api_key": "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                "auth_domain": "my-project.firebaseapp.com",
                "project_id": "my-project",
                "storage_bucket": "my-project.appspot.com",
                "messaging_sender_id": "123456789",
                "app_id": "1:123456789:web:abcdef",
                "measurement_id": "G-XXXXXXXXXX",
            }
        }
    )

    api_key: str = Field(..., description="Firebase API key")
    auth_domain: str = Field(..., description="Firebase auth domain")
    project_id: str = Field(..., description="Firebase project ID")
    storage_bucket: Optional[str] = Field(None, description="Firebase storage bucket")
    messaging_sender_id: Optional[str] = Field(
        None, description="Firebase messaging sender ID"
    )
    app_id: str = Field(..., description="Firebase app ID")
    measurement_id: Optional[str] = Field(
        None, description="Firebase measurement ID for analytics"
    )


class TokenResponse(BaseModel):
    """
    Token response model.
    """

    id_token: str = Field(..., description="Firebase ID token")
    refresh_token: Optional[str] = Field(None, description="Firebase refresh token")
    expires_in: int = Field(..., description="Token expiry in seconds")
    user: AuthUser = Field(..., description="Authenticated user information")
