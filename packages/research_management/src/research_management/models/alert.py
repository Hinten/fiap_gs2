"""
Alert models for monitoring and notifications.
"""

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class AlertType(str, Enum):
    """Types of alerts in the system."""

    NO_ADVISOR = "no_advisor"  # Student without advisor for > 14 days
    NO_UPDATE = "no_update"  # Project without update for > 30 days
    DEADLINE_SOON = "deadline_soon"  # Deadline approaching in 7 days
    MEETING_REMINDER = "meeting_reminder"  # Meeting in 24 hours


class AlertSeverity(str, Enum):
    """Alert severity levels."""

    INFO = "info"  # 🟢 Informational
    WARNING = "warning"  # 🟡 Requires attention
    CRITICAL = "critical"  # 🔴 Urgent action needed


class AlertStatus(str, Enum):
    """Alert status."""

    ACTIVE = "active"
    RESOLVED = "resolved"
    DISMISSED = "dismissed"


class Alert(BaseModel):
    """Alert model for system notifications."""

    alert_id: str = Field(..., description="Unique alert identifier")
    type: AlertType = Field(..., description="Type of alert")
    project_id: Optional[str] = Field(None, description="Related project ID")
    user_id: Optional[str] = Field(None, description="Related user ID")
    message: str = Field(..., description="Alert message")
    severity: AlertSeverity = Field(..., description="Alert severity level")
    status: AlertStatus = Field(
        default=AlertStatus.ACTIVE, description="Current alert status"
    )
    created_at: datetime = Field(
        default_factory=datetime.utcnow, description="Alert creation timestamp"
    )
    resolved_at: Optional[datetime] = Field(
        None, description="Alert resolution timestamp"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "alert_id": "alert-001",
                "type": "no_advisor",
                "project_id": None,
                "user_id": "user-789",
                "message": "🔴 CRITICAL: Student João Silva is without advisor for 18 days",
                "severity": "critical",
                "status": "active",
                "created_at": "2025-02-01T09:00:00Z",
                "resolved_at": None,
            }
        }


class AlertCreate(BaseModel):
    """Model for creating an alert."""

    type: AlertType
    project_id: Optional[str] = None
    user_id: Optional[str] = None
    message: str = Field(..., min_length=1)
    severity: AlertSeverity
