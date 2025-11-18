"""
Repository for alerts data access.
"""

from datetime import datetime
from typing import List, Optional

from firebase_admin import firestore

from ..firebase_admin import get_db
from ..models.alert import Alert, AlertCreate, AlertSeverity, AlertStatus, AlertType
from ..utils import generate_id


class AlertRepository:
    """Repository for managing alerts in Firestore."""

    COLLECTION = "alerts"

    def __init__(self, db: Optional[firestore.Client] = None):
        """
        Initialize repository.

        Args:
            db: Optional Firestore client. If None, uses default.
        """
        self.db = db or get_db()

    def create(self, alert_data: AlertCreate) -> Alert:
        """
        Create a new alert.

        Args:
            alert_data: Alert creation data

        Returns:
            Created alert
        """
        alert_id = generate_id("alert")

        alert = Alert(
            alert_id=alert_id,
            type=alert_data.type,
            project_id=alert_data.project_id,
            user_id=alert_data.user_id,
            message=alert_data.message,
            severity=alert_data.severity,
            status=AlertStatus.ACTIVE,
            created_at=datetime.utcnow(),
        )

        # Save to Firestore
        doc_ref = self.db.collection(self.COLLECTION).document(alert_id)
        doc_ref.set(alert.model_dump(mode="json"))

        return alert

    def get_active_alerts(
        self,
        alert_type: Optional[AlertType] = None,
        severity: Optional[AlertSeverity] = None,
    ) -> List[Alert]:
        """
        Get all active alerts with optional filters.

        Args:
            alert_type: Filter by alert type
            severity: Filter by severity

        Returns:
            List of active alerts
        """
        query = self.db.collection(self.COLLECTION).where(
            "status", "==", AlertStatus.ACTIVE.value
        )

        if alert_type:
            query = query.where("type", "==", alert_type.value)
        if severity:
            query = query.where("severity", "==", severity.value)

        docs = query.stream()

        alerts = []
        for doc in docs:
            data = doc.to_dict()
            alerts.append(Alert(**data))

        return alerts

    def get_by_project(self, project_id: str) -> List[Alert]:
        """
        Get all alerts for a specific project.

        Args:
            project_id: Project identifier

        Returns:
            List of alerts
        """
        query = self.db.collection(self.COLLECTION).where(
            "project_id", "==", project_id
        )

        docs = query.stream()

        alerts = []
        for doc in docs:
            data = doc.to_dict()
            alerts.append(Alert(**data))

        return alerts

    def get_by_user(self, user_id: str) -> List[Alert]:
        """
        Get all alerts for a specific user.

        Args:
            user_id: User identifier

        Returns:
            List of alerts
        """
        query = self.db.collection(self.COLLECTION).where("user_id", "==", user_id)

        docs = query.stream()

        alerts = []
        for doc in docs:
            data = doc.to_dict()
            alerts.append(Alert(**data))

        return alerts

    def resolve(self, alert_id: str) -> Optional[Alert]:
        """
        Mark an alert as resolved.

        Args:
            alert_id: Alert identifier

        Returns:
            Updated alert if found, None otherwise
        """
        doc_ref = self.db.collection(self.COLLECTION).document(alert_id)
        doc = doc_ref.get()

        if not doc.exists:
            return None

        doc_ref.update(
            {"status": AlertStatus.RESOLVED.value, "resolved_at": datetime.utcnow()}
        )

        updated_doc = doc_ref.get()
        return Alert(**updated_doc.to_dict())

    def dismiss(self, alert_id: str) -> Optional[Alert]:
        """
        Dismiss an alert.

        Args:
            alert_id: Alert identifier

        Returns:
            Updated alert if found, None otherwise
        """
        doc_ref = self.db.collection(self.COLLECTION).document(alert_id)
        doc = doc_ref.get()

        if not doc.exists:
            return None

        doc_ref.update(
            {"status": AlertStatus.DISMISSED.value, "resolved_at": datetime.utcnow()}
        )

        updated_doc = doc_ref.get()
        return Alert(**updated_doc.to_dict())
