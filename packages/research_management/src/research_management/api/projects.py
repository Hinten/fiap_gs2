"""
API routes for research project management.
"""

from typing import List, Optional

from fastapi import APIRouter, HTTPException, Query

from ..models.member import ProjectMember, ProjectMemberCreate
from ..models.project import (
    HealthStatus,
    ProjectCreate,
    ProjectStatus,
    ProjectUpdate,
    ResearchProject,
)
from ..services import ProjectService

router = APIRouter(prefix="/projects", tags=["projects"])


@router.post("", response_model=ResearchProject, status_code=201)
def create_project(project_data: ProjectCreate):
    """Create a new research project."""
    service = ProjectService()
    return service.create_project(project_data)


@router.get("", response_model=List[ResearchProject])
def list_projects(
    status: Optional[ProjectStatus] = Query(None, description="Filter by status"),
    area: Optional[str] = Query(None, description="Filter by research area"),
    health_status: Optional[HealthStatus] = Query(
        None, description="Filter by health status"
    ),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of results"),
):
    """List research projects with optional filters."""
    service = ProjectService()
    return service.list_projects(
        status=status, area=area, health_status=health_status, limit=limit
    )


@router.get("/{project_id}", response_model=ResearchProject)
def get_project(project_id: str):
    """Get details of a specific project."""
    service = ProjectService()
    project = service.get_project(project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project


@router.put("/{project_id}", response_model=ResearchProject)
def update_project(project_id: str, update_data: ProjectUpdate):
    """Update a project."""
    service = ProjectService()
    project = service.update_project(project_id, update_data)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project


@router.delete("/{project_id}", status_code=204)
def delete_project(project_id: str):
    """Archive a project."""
    service = ProjectService()
    success = service.delete_project(project_id)
    if not success:
        raise HTTPException(status_code=404, detail="Project not found")
    return None


@router.post("/{project_id}/members", response_model=ProjectMember, status_code=201)
def add_project_member(project_id: str, member_data: ProjectMemberCreate):
    """Add a member to a project."""
    service = ProjectService()
    member = service.add_member(project_id, member_data)
    if not member:
        raise HTTPException(status_code=404, detail="Project not found")
    return member


@router.get("/{project_id}/members", response_model=List[ProjectMember])
def get_project_members(project_id: str):
    """Get all members of a project."""
    service = ProjectService()
    return service.get_project_members(project_id)


@router.delete("/{project_id}/members/{user_id}", status_code=204)
def remove_project_member(project_id: str, user_id: str):
    """Remove a member from a project."""
    service = ProjectService()
    success = service.remove_member(project_id, user_id)
    if not success:
        raise HTTPException(status_code=404, detail="Member not found")
    return None
