"""
Project update models.
"""

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field


class ProjectUpdateModel(BaseModel):
    """Project progress update model."""

    update_id: str = Field(..., description="Unique update identifier")
    project_id: str = Field(..., description="Project identifier")
    submitted_by: str = Field(..., description="User ID who submitted")
    content: str = Field(..., description="Update content in Markdown format")
    milestone_completed: Optional[str] = Field(
        None, description="Milestone that was completed"
    )
    files_attached: List[str] = Field(
        default_factory=list, description="URLs of attached files"
    )
    timestamp: datetime = Field(
        default_factory=datetime.utcnow, description="Submission timestamp"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "update_id": "upd-789",
                "project_id": "proj-123",
                "submitted_by": "user-456",
                "content": "Completed initial data collection and preprocessing. Started model training.",
                "milestone_completed": "Data Collection Phase",
                "files_attached": [
                    "https://storage.example.com/files/dataset.csv",
                    "https://storage.example.com/files/preprocessing_report.pdf",
                ],
                "timestamp": "2025-02-15T14:30:00Z",
            }
        }


class ProjectUpdateCreate(BaseModel):
    """Model for creating a project update."""

    content: str = Field(..., min_length=1, description="Update content in Markdown")
    milestone_completed: Optional[str] = None
    files_attached: List[str] = Field(default_factory=list)
