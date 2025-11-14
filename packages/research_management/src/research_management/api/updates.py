"""
API routes for project updates.
"""

from typing import List

from fastapi import APIRouter, HTTPException, Path, Query

from ..models.update import ProjectUpdateCreate, ProjectUpdateModel
from ..services import UpdateService

router = APIRouter(prefix="/projects", tags=["updates"])


@router.post(
    "/{project_id}/updates", response_model=ProjectUpdateModel, status_code=201
)
def submit_update(
    project_id: str,
    update_data: ProjectUpdateCreate,
    user_id: str = Query(..., description="User ID who is submitting the update"),
):
    """Submit a progress update for a project."""
    service = UpdateService()
    update = service.submit_update(project_id, user_id, update_data)
    if not update:
        raise HTTPException(status_code=404, detail="Project not found")
    return update


@router.get("/{project_id}/updates", response_model=List[ProjectUpdateModel])
def get_project_updates(
    project_id: str,
    limit: int = Query(50, ge=1, le=100, description="Maximum number of results"),
):
    """Get all updates for a project."""
    service = UpdateService()
    return service.get_project_updates(project_id, limit=limit)


@router.get("/{project_id}/timeline", response_model=List[ProjectUpdateModel])
def get_project_timeline(
    project_id: str,
    limit: int = Query(50, ge=1, le=100, description="Maximum number of results"),
):
    """Get project timeline (same as updates, but with semantic name)."""
    service = UpdateService()
    return service.get_project_updates(project_id, limit=limit)
