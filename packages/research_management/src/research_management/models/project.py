"""
Research Project models.
"""

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class ProjectStatus(str, Enum):
    """Project lifecycle status."""

    PROPOSAL = "proposal"
    ACTIVE = "active"
    PAUSED = "paused"
    COMPLETED = "completed"
    ARCHIVED = "archived"


class HealthStatus(str, Enum):
    """Project health indicators."""

    ON_TRACK = "on_track"  # 🟢 Everything OK
    AT_RISK = "at_risk"  # 🟡 Minor delays or communication issues
    CRITICAL = "critical"  # 🔴 Significant delays or imminent abandonment


class ResearchProject(BaseModel):
    """Research project model."""

    project_id: str = Field(..., description="Unique project identifier")
    title: str = Field(..., min_length=1, max_length=200, description="Project title")
    description: str = Field(..., description="Project description")
    area: str = Field(
        ..., description="Research area (CS, ML, Networks, etc)", max_length=100
    )
    status: ProjectStatus = Field(
        default=ProjectStatus.PROPOSAL, description="Current project status"
    )
    health_status: HealthStatus = Field(
        default=HealthStatus.ON_TRACK, description="Project health indicator"
    )
    start_date: Optional[datetime] = Field(None, description="Project start date")
    expected_end_date: Optional[datetime] = Field(
        None, description="Expected completion date"
    )
    actual_end_date: Optional[datetime] = Field(
        None, description="Actual completion date"
    )
    created_at: datetime = Field(
        default_factory=datetime.utcnow, description="Creation timestamp"
    )
    updated_at: datetime = Field(
        default_factory=datetime.utcnow, description="Last update timestamp"
    )

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "project_id": "proj-123",
                "title": "ML for Image Classification",
                "description": "Research project on machine learning applications",
                "area": "Machine Learning",
                "status": "active",
                "health_status": "on_track",
                "start_date": "2025-01-15T00:00:00Z",
                "expected_end_date": "2025-06-30T00:00:00Z",
                "created_at": "2025-01-10T10:00:00Z",
                "updated_at": "2025-01-10T10:00:00Z",
            }
        }
    )


class ProjectCreate(BaseModel):
    """Model for creating a new project."""

    title: str = Field(..., min_length=1, max_length=200)
    description: str
    area: str = Field(..., max_length=100)
    start_date: Optional[datetime] = None
    expected_end_date: Optional[datetime] = None


class ProjectUpdate(BaseModel):
    """Model for updating a project."""

    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = None
    area: Optional[str] = Field(None, max_length=100)
    status: Optional[ProjectStatus] = None
    health_status: Optional[HealthStatus] = None
    start_date: Optional[datetime] = None
    expected_end_date: Optional[datetime] = None
    actual_end_date: Optional[datetime] = None
