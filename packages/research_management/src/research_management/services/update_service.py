"""
Service layer for project updates and progress tracking.
"""

from typing import List, Optional

from ..models.update import ProjectUpdateCreate, ProjectUpdateModel
from ..repositories import ProjectRepository, UpdateRepository


class UpdateService:
    """Service for managing project updates."""

    def __init__(
        self,
        update_repo: Optional[UpdateRepository] = None,
        project_repo: Optional[ProjectRepository] = None,
    ):
        """
        Initialize service.

        Args:
            update_repo: Optional update repository
            project_repo: Optional project repository
        """
        self.update_repo = update_repo or UpdateRepository()
        self.project_repo = project_repo or ProjectRepository()

    def submit_update(
        self, project_id: str, user_id: str, update_data: ProjectUpdateCreate
    ) -> Optional[ProjectUpdateModel]:
        """
        Submit a project update.

        Args:
            project_id: Project identifier
            user_id: User who submitted the update
            update_data: Update creation data

        Returns:
            Created update if project exists, None otherwise
        """
        # Verify project exists
        project = self.project_repo.get(project_id)
        if not project:
            return None

        return self.update_repo.create(project_id, user_id, update_data)

    def get_project_updates(
        self, project_id: str, limit: int = 50
    ) -> List[ProjectUpdateModel]:
        """
        Get all updates for a project.

        Args:
            project_id: Project identifier
            limit: Maximum number of results

        Returns:
            List of updates, sorted by timestamp descending
        """
        return self.update_repo.get_by_project(project_id, limit=limit)

    def get_latest_update(self, project_id: str) -> Optional[ProjectUpdateModel]:
        """
        Get the most recent update for a project.

        Args:
            project_id: Project identifier

        Returns:
            Latest update if found, None otherwise
        """
        return self.update_repo.get_latest_update(project_id)
