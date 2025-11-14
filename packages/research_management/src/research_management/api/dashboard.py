"""
API routes for dashboards.
"""

from typing import Dict

from fastapi import APIRouter, Query

from ..services import DashboardService

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("/coordinator", response_model=Dict)
def get_coordinator_dashboard():
    """
    Get dashboard metrics for coordinators.

    Returns comprehensive metrics including:
    - Total projects and status breakdown
    - Completion rate
    - Average students per advisor
    - Projects in risk
    - Students without advisor
    - Active alerts count
    """
    service = DashboardService()
    return service.get_coordinator_dashboard()


@router.get("/advisor", response_model=Dict)
def get_advisor_dashboard(
    advisor_id: str = Query(..., description="Advisor user ID"),
):
    """
    Get dashboard metrics for a specific advisor.

    Returns:
    - Total and active projects
    - Total students
    - Active alerts
    - List of projects with their status
    """
    service = DashboardService()
    return service.get_advisor_dashboard(advisor_id)


@router.get("/student", response_model=Dict)
def get_student_dashboard(
    student_id: str = Query(..., description="Student user ID"),
):
    """
    Get dashboard metrics for a specific student.

    Returns:
    - Current project information
    - Project status and health
    - Advisor status
    - Active alerts
    """
    service = DashboardService()
    return service.get_student_dashboard(student_id)
