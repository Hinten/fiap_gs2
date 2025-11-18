"""
API routes for alerts.
"""

from typing import List, Optional

from fastapi import APIRouter, HTTPException, Query

from ..models.alert import Alert, AlertCreate, AlertSeverity, AlertType
from ..services import AlertService

router = APIRouter(prefix="/alerts", tags=["alerts"])


@router.get("", response_model=List[Alert])
def get_alerts(
    alert_type: Optional[AlertType] = Query(None, description="Filter by alert type"),
    severity: Optional[AlertSeverity] = Query(None, description="Filter by severity"),
):
    """Get all active alerts with optional filters."""
    service = AlertService()
    return service.get_active_alerts(alert_type=alert_type, severity=severity)


@router.post("", response_model=Alert, status_code=201)
def create_alert(alert_data: AlertCreate):
    """Create a new alert (mainly for testing/manual creation)."""
    service = AlertService()
    return service.create_alert(alert_data)


@router.post("/{alert_id}/resolve", response_model=Alert)
def resolve_alert(alert_id: str):
    """Mark an alert as resolved."""
    service = AlertService()
    alert = service.resolve_alert(alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    return alert


@router.post("/{alert_id}/dismiss", response_model=Alert)
def dismiss_alert(alert_id: str):
    """Dismiss an alert."""
    service = AlertService()
    alert = service.dismiss_alert(alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    return alert


@router.get("/projects/{project_id}", response_model=List[Alert])
def get_project_alerts(project_id: str):
    """Get all alerts for a specific project."""
    service = AlertService()
    return service.get_project_alerts(project_id)


@router.get("/users/{user_id}", response_model=List[Alert])
def get_user_alerts(user_id: str):
    """Get all alerts for a specific user."""
    service = AlertService()
    return service.get_user_alerts(user_id)
