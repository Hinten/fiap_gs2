"""
Service layer for research project management.
"""

from typing import List, Optional

from ..models.member import MemberRole, ProjectMember, ProjectMemberCreate
from ..models.project import (
    HealthStatus,
    ProjectCreate,
    ProjectStatus,
    ProjectUpdate,
    ResearchProject,
)
from ..repositories import MemberRepository, ProjectRepository


class ProjectService:
    """Service for managing research projects."""

    def __init__(
        self,
        project_repo: Optional[ProjectRepository] = None,
        member_repo: Optional[MemberRepository] = None,
    ):
        """
        Initialize service.

        Args:
            project_repo: Optional project repository
            member_repo: Optional member repository
        """
        self.project_repo = project_repo or ProjectRepository()
        self.member_repo = member_repo or MemberRepository()

    def create_project(self, project_data: ProjectCreate) -> ResearchProject:
        """
        Create a new research project.

        Args:
            project_data: Project creation data

        Returns:
            Created project
        """
        return self.project_repo.create(project_data)

    def get_project(self, project_id: str) -> Optional[ResearchProject]:
        """
        Get a project by ID.

        Args:
            project_id: Project identifier

        Returns:
            Project if found, None otherwise
        """
        return self.project_repo.get(project_id)

    def list_projects(
        self,
        status: Optional[ProjectStatus] = None,
        area: Optional[str] = None,
        health_status: Optional[HealthStatus] = None,
        limit: int = 100,
    ) -> List[ResearchProject]:
        """
        List projects with optional filters.

        Args:
            status: Filter by project status
            area: Filter by research area
            health_status: Filter by health status
            limit: Maximum number of results

        Returns:
            List of projects
        """
        return self.project_repo.list(
            status=status, area=area, health_status=health_status, limit=limit
        )

    def update_project(
        self, project_id: str, update_data: ProjectUpdate
    ) -> Optional[ResearchProject]:
        """
        Update a project.

        Args:
            project_id: Project identifier
            update_data: Update data

        Returns:
            Updated project if found, None otherwise
        """
        return self.project_repo.update(project_id, update_data)

    def delete_project(self, project_id: str) -> bool:
        """
        Delete (archive) a project.

        Args:
            project_id: Project identifier

        Returns:
            True if deleted, False if not found
        """
        return self.project_repo.delete(project_id)

    def add_member(
        self, project_id: str, member_data: ProjectMemberCreate
    ) -> Optional[ProjectMember]:
        """
        Add a member to a project.

        Args:
            project_id: Project identifier
            member_data: Member creation data

        Returns:
            Created member if project exists, None otherwise
        """
        # Verify project exists
        project = self.project_repo.get(project_id)
        if not project:
            return None

        return self.member_repo.add_member(project_id, member_data)

    def get_project_members(
        self, project_id: str, role: Optional[MemberRole] = None
    ) -> List[ProjectMember]:
        """
        Get all members of a project.

        Args:
            project_id: Project identifier
            role: Optional role filter

        Returns:
            List of project members
        """
        return self.member_repo.get_members(project_id, role=role)

    def remove_member(self, project_id: str, user_id: str) -> bool:
        """
        Remove a member from a project.

        Args:
            project_id: Project identifier
            user_id: User identifier

        Returns:
            True if removed, False if not found
        """
        return self.member_repo.remove_member(project_id, user_id)

    def get_user_projects(
        self, user_id: str, role: Optional[MemberRole] = None
    ) -> List[ResearchProject]:
        """
        Get all projects for a user.

        Args:
            user_id: User identifier
            role: Optional role filter

        Returns:
            List of projects
        """
        project_ids = self.member_repo.get_projects_by_user(user_id, role=role)

        projects = []
        for project_id in project_ids:
            project = self.project_repo.get(project_id)
            if project:
                projects.append(project)

        return projects
