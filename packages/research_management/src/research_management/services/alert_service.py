"""
Service layer for alerts and monitoring.
"""

from datetime import datetime, timedelta
from typing import List, Optional

from ..config import get_settings
from ..models.alert import Alert, AlertCreate, AlertSeverity, AlertStatus, AlertType
from ..repositories import AlertRepository, MemberRepository, UpdateRepository


class AlertService:
    """Service for managing alerts and monitoring."""

    def __init__(
        self,
        alert_repo: Optional[AlertRepository] = None,
        member_repo: Optional[MemberRepository] = None,
        update_repo: Optional[UpdateRepository] = None,
    ):
        """
        Initialize service.

        Args:
            alert_repo: Optional alert repository
            member_repo: Optional member repository
            update_repo: Optional update repository
        """
        self.alert_repo = alert_repo or AlertRepository()
        self.member_repo = member_repo or MemberRepository()
        self.update_repo = update_repo or UpdateRepository()
        self.settings = get_settings()

    def create_alert(self, alert_data: AlertCreate) -> Alert:
        """
        Create a new alert.

        Args:
            alert_data: Alert creation data

        Returns:
            Created alert
        """
        return self.alert_repo.create(alert_data)

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
        return self.alert_repo.get_active_alerts(
            alert_type=alert_type, severity=severity
        )

    def get_project_alerts(self, project_id: str) -> List[Alert]:
        """
        Get all alerts for a specific project.

        Args:
            project_id: Project identifier

        Returns:
            List of alerts
        """
        return self.alert_repo.get_by_project(project_id)

    def get_user_alerts(self, user_id: str) -> List[Alert]:
        """
        Get all alerts for a specific user.

        Args:
            user_id: User identifier

        Returns:
            List of alerts
        """
        return self.alert_repo.get_by_user(user_id)

    def resolve_alert(self, alert_id: str) -> Optional[Alert]:
        """
        Mark an alert as resolved.

        Args:
            alert_id: Alert identifier

        Returns:
            Updated alert if found, None otherwise
        """
        return self.alert_repo.resolve(alert_id)

    def dismiss_alert(self, alert_id: str) -> Optional[Alert]:
        """
        Dismiss an alert.

        Args:
            alert_id: Alert identifier

        Returns:
            Updated alert if found, None otherwise
        """
        return self.alert_repo.dismiss(alert_id)

    def check_students_without_advisor(self) -> List[Alert]:
        """
        Check for students without advisors and create alerts.

        Returns:
            List of created alerts
        """
        student_ids = self.member_repo.get_students_without_advisor()
        alerts = []

        for user_id in student_ids:
            # Check if there's already an active alert for this user
            existing_alerts = self.alert_repo.get_by_user(user_id)
            has_active = any(
                a.type == AlertType.NO_ADVISOR and a.status == AlertStatus.ACTIVE
                for a in existing_alerts
            )

            if not has_active:
                alert_data = AlertCreate(
                    type=AlertType.NO_ADVISOR,
                    user_id=user_id,
                    message=f"🔴 CRITICAL: Student is without advisor for more than {self.settings.alert_no_advisor_days} days",
                    severity=AlertSeverity.CRITICAL,
                )
                alert = self.create_alert(alert_data)
                alerts.append(alert)

        return alerts

    def check_projects_without_updates(self, project_ids: List[str]) -> List[Alert]:
        """
        Check for projects without recent updates and create alerts.

        Args:
            project_ids: List of project IDs to check

        Returns:
            List of created alerts
        """
        alerts = []
        cutoff_date = datetime.utcnow() - timedelta(
            days=self.settings.alert_no_update_days
        )

        for project_id in project_ids:
            last_update_date = self.update_repo.get_last_update_date(project_id)

            # Check if project hasn't been updated
            needs_alert = last_update_date is None or last_update_date < cutoff_date

            if needs_alert:
                # Check if there's already an active alert
                existing_alerts = self.alert_repo.get_by_project(project_id)
                has_active = any(
                    a.type == AlertType.NO_UPDATE and a.status == AlertStatus.ACTIVE
                    for a in existing_alerts
                )

                if not has_active:
                    alert_data = AlertCreate(
                        type=AlertType.NO_UPDATE,
                        project_id=project_id,
                        message=f"🟡 WARNING: Project has not been updated in {self.settings.alert_no_update_days} days",
                        severity=AlertSeverity.WARNING,
                    )
                    alert = self.create_alert(alert_data)
                    alerts.append(alert)

        return alerts
