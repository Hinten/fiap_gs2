"""
Project member models.
"""

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class MemberRole(str, Enum):
    """Member roles in a research project."""

    STUDENT = "student"
    ADVISOR = "advisor"
    CO_ADVISOR = "co-advisor"
    COORDINATOR = "coordinator"


class ProjectMember(BaseModel):
    """Project member model."""

    project_id: str = Field(..., description="Project identifier")
    user_id: str = Field(..., description="User identifier")
    role: MemberRole = Field(..., description="Member role in the project")
    joined_at: datetime = Field(
        default_factory=datetime.utcnow, description="When member joined"
    )
    left_at: Optional[datetime] = Field(None, description="When member left (if any)")

    class Config:
        json_schema_extra = {
            "example": {
                "project_id": "proj-123",
                "user_id": "user-456",
                "role": "student",
                "joined_at": "2025-01-15T10:00:00Z",
                "left_at": None,
            }
        }


class ProjectMemberCreate(BaseModel):
    """Model for adding a member to a project."""

    user_id: str = Field(..., description="User identifier")
    role: MemberRole = Field(..., description="Member role in the project")
