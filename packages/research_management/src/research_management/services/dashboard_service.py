"""
Service layer for coordinator dashboard and metrics.
"""

from collections import defaultdict
from typing import Dict, List, Optional

from ..models.member import MemberRole
from ..models.project import HealthStatus, ProjectStatus
from ..repositories import (
    AlertRepository,
    MemberRepository,
    ProjectRepository,
)


class DashboardService:
    """Service for coordinator dashboard and metrics."""

    def __init__(
        self,
        project_repo: Optional[ProjectRepository] = None,
        member_repo: Optional[MemberRepository] = None,
        alert_repo: Optional[AlertRepository] = None,
    ):
        """
        Initialize service.

        Args:
            project_repo: Optional project repository
            member_repo: Optional member repository
            alert_repo: Optional alert repository
        """
        self.project_repo = project_repo or ProjectRepository()
        self.member_repo = member_repo or MemberRepository()
        self.alert_repo = alert_repo or AlertRepository()

    def get_coordinator_dashboard(self) -> Dict:
        """
        Get dashboard metrics for coordinators.

        Returns:
            Dictionary with dashboard metrics
        """
        # Get all projects
        all_projects = self.project_repo.list(limit=1000)

        # Count by status
        status_counts = defaultdict(int)
        for project in all_projects:
            status_counts[project.status.value] += 1

        # Count by health
        health_counts = defaultdict(int)
        for project in all_projects:
            health_counts[project.health_status.value] += 1

        # Calculate completion rate
        completed = status_counts.get(ProjectStatus.COMPLETED.value, 0)
        total_projects = len(all_projects)
        completion_rate = (
            (completed / total_projects * 100) if total_projects > 0 else 0
        )

        # Get active projects
        active_projects = [p for p in all_projects if p.status == ProjectStatus.ACTIVE]

        # Calculate average students per advisor
        advisor_student_count = self._calculate_advisor_student_ratio(active_projects)

        # Count projects in risk
        at_risk = health_counts.get(HealthStatus.AT_RISK.value, 0)
        critical = health_counts.get(HealthStatus.CRITICAL.value, 0)
        projects_in_risk = at_risk + critical

        # Get students without advisor
        students_without_advisor = self.member_repo.get_students_without_advisor()

        # Get active alerts
        active_alerts = self.alert_repo.get_active_alerts()

        return {
            "total_projects": total_projects,
            "active_projects": len(active_projects),
            "archived_projects": status_counts.get(ProjectStatus.ARCHIVED.value, 0),
            "completion_rate": round(completion_rate, 1),
            "avg_students_per_advisor": advisor_student_count,
            "projects_in_risk": projects_in_risk,
            "at_risk_count": at_risk,
            "critical_count": critical,
            "students_without_advisor": len(students_without_advisor),
            "active_alerts_count": len(active_alerts),
            "status_breakdown": dict(status_counts),
            "health_breakdown": dict(health_counts),
        }

    def _calculate_advisor_student_ratio(self, projects: List) -> float:
        """
        Calculate average number of students per advisor.

        Args:
            projects: List of projects to analyze

        Returns:
            Average students per advisor
        """
        advisor_counts = defaultdict(int)
        total_students = 0

        for project in projects:
            members = self.member_repo.get_members(project.project_id)

            # Count advisors
            advisors = [
                m
                for m in members
                if m.role in [MemberRole.ADVISOR, MemberRole.CO_ADVISOR]
            ]

            # Count students
            students = [m for m in members if m.role == MemberRole.STUDENT]
            total_students += len(students)

            # Track students per advisor
            for advisor in advisors:
                advisor_counts[advisor.user_id] += len(students)

        total_advisors = len(advisor_counts)
        if total_advisors == 0:
            return 0.0

        return round(total_students / total_advisors, 1)

    def get_advisor_dashboard(self, advisor_id: str) -> Dict:
        """
        Get dashboard metrics for a specific advisor.

        Args:
            advisor_id: Advisor user ID

        Returns:
            Dictionary with advisor-specific metrics
        """
        # Get advisor's projects
        project_ids = self.member_repo.get_projects_by_user(
            advisor_id, role=MemberRole.ADVISOR
        )

        projects = []
        for project_id in project_ids:
            project = self.project_repo.get(project_id)
            if project:
                projects.append(project)

        # Count active projects
        active_projects = [p for p in projects if p.status == ProjectStatus.ACTIVE]

        # Count total students
        total_students = 0
        for project in projects:
            students = self.member_repo.get_members(
                project.project_id, role=MemberRole.STUDENT
            )
            total_students += len(students)

        # Get alerts for advisor's projects
        alerts = []
        for project_id in project_ids:
            project_alerts = self.alert_repo.get_by_project(project_id)
            alerts.extend(project_alerts)

        active_alerts = [a for a in alerts if a.status.value == "active"]

        return {
            "total_projects": len(projects),
            "active_projects": len(active_projects),
            "total_students": total_students,
            "active_alerts": len(active_alerts),
            "projects": [
                {
                    "project_id": p.project_id,
                    "title": p.title,
                    "status": p.status.value,
                    "health_status": p.health_status.value,
                }
                for p in projects
            ],
        }

    def get_student_dashboard(self, student_id: str) -> Dict:
        """
        Get dashboard metrics for a specific student.

        Args:
            student_id: Student user ID

        Returns:
            Dictionary with student-specific metrics
        """
        # Get student's projects
        project_ids = self.member_repo.get_projects_by_user(
            student_id, role=MemberRole.STUDENT
        )

        if not project_ids:
            return {
                "has_project": False,
                "message": "No active project found",
            }

        # Get the first active project
        project = None
        for project_id in project_ids:
            p = self.project_repo.get(project_id)
            if p and p.status == ProjectStatus.ACTIVE:
                project = p
                break

        if not project:
            return {
                "has_project": False,
                "message": "No active project found",
            }

        # Get project members
        members = self.member_repo.get_members(project.project_id)
        advisors = [
            m for m in members if m.role in [MemberRole.ADVISOR, MemberRole.CO_ADVISOR]
        ]

        # Get alerts for this project
        alerts = self.alert_repo.get_by_project(project.project_id)
        active_alerts = [a for a in alerts if a.status.value == "active"]

        return {
            "has_project": True,
            "project_id": project.project_id,
            "project_title": project.title,
            "status": project.status.value,
            "health_status": project.health_status.value,
            "area": project.area,
            "expected_end_date": (
                project.expected_end_date.isoformat()
                if project.expected_end_date
                else None
            ),
            "has_advisor": len(advisors) > 0,
            "active_alerts": len(active_alerts),
        }
