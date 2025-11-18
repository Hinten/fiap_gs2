"""
Repository for research projects data access.
"""

from datetime import datetime
from typing import List, Optional

from firebase_admin import firestore

from ..firebase_admin import get_db
from ..models.project import (
    HealthStatus,
    ProjectCreate,
    ProjectStatus,
    ProjectUpdate,
    ResearchProject,
)
from ..utils import generate_id


class ProjectRepository:
    """Repository for managing research projects in Firestore."""

    COLLECTION = "research_projects"

    def __init__(self, db: Optional[firestore.Client] = None):
        """
        Initialize repository.

        Args:
            db: Optional Firestore client. If None, uses default.
        """
        self.db = db or get_db()

    def create(self, project_data: ProjectCreate) -> ResearchProject:
        """
        Create a new research project.

        Args:
            project_data: Project creation data

        Returns:
            Created project
        """
        project_id = generate_id("proj")
        now = datetime.utcnow()

        project = ResearchProject(
            project_id=project_id,
            title=project_data.title,
            description=project_data.description,
            area=project_data.area,
            status=ProjectStatus.PROPOSAL,
            health_status=HealthStatus.ON_TRACK,
            start_date=project_data.start_date,
            expected_end_date=project_data.expected_end_date,
            created_at=now,
            updated_at=now,
        )

        # Save to Firestore
        doc_ref = self.db.collection(self.COLLECTION).document(project_id)
        doc_ref.set(project.model_dump(mode="json"))

        return project

    def get(self, project_id: str) -> Optional[ResearchProject]:
        """
        Get a project by ID.

        Args:
            project_id: Project identifier

        Returns:
            Project if found, None otherwise
        """
        doc_ref = self.db.collection(self.COLLECTION).document(project_id)
        doc = doc_ref.get()

        if not doc.exists:
            return None

        data = doc.to_dict()
        return ResearchProject(**data)

    def list(
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
        query = self.db.collection(self.COLLECTION)

        if status:
            query = query.where("status", "==", status.value)
        if area:
            query = query.where("area", "==", area)
        if health_status:
            query = query.where("health_status", "==", health_status.value)

        query = query.limit(limit)
        docs = query.stream()

        projects = []
        for doc in docs:
            data = doc.to_dict()
            projects.append(ResearchProject(**data))

        return projects

    def update(
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
        doc_ref = self.db.collection(self.COLLECTION).document(project_id)
        doc = doc_ref.get()

        if not doc.exists:
            return None

        # Only update non-None fields
        update_dict = update_data.model_dump(exclude_none=True)
        update_dict["updated_at"] = datetime.utcnow()

        doc_ref.update(update_dict)

        # Fetch and return updated document
        updated_doc = doc_ref.get()
        return ResearchProject(**updated_doc.to_dict())

    def delete(self, project_id: str) -> bool:
        """
        Delete (archive) a project.

        Args:
            project_id: Project identifier

        Returns:
            True if deleted, False if not found
        """
        doc_ref = self.db.collection(self.COLLECTION).document(project_id)
        doc = doc_ref.get()

        if not doc.exists:
            return False

        # Soft delete by marking as archived
        doc_ref.update(
            {
                "status": ProjectStatus.ARCHIVED.value,
                "updated_at": datetime.utcnow(),
            }
        )
        return True

    def get_projects_by_advisor(self, advisor_id: str) -> List[ResearchProject]:
        """
        Get all projects for a specific advisor.

        Args:
            advisor_id: Advisor user ID

        Returns:
            List of projects
        """
        # This requires querying project_members collection first
        # Then fetching the projects
        # Implementation depends on member repository
        # For now, return empty list - will be implemented in services layer
        return []
