"""
Repository for project updates data access.
"""

from datetime import datetime
from typing import List, Optional

from firebase_admin import firestore

from ..firebase_admin import get_db
from ..models.update import ProjectUpdateCreate, ProjectUpdateModel
from ..utils import generate_id


class UpdateRepository:
    """Repository for managing project updates in Firestore."""

    COLLECTION = "project_updates"

    def __init__(self, db: Optional[firestore.Client] = None):
        """
        Initialize repository.

        Args:
            db: Optional Firestore client. If None, uses default.
        """
        self.db = db or get_db()

    def create(
        self, project_id: str, user_id: str, update_data: ProjectUpdateCreate
    ) -> ProjectUpdateModel:
        """
        Create a new project update.

        Args:
            project_id: Project identifier
            user_id: User who submitted the update
            update_data: Update creation data

        Returns:
            Created update
        """
        update_id = generate_id("upd")

        update = ProjectUpdateModel(
            update_id=update_id,
            project_id=project_id,
            submitted_by=user_id,
            content=update_data.content,
            milestone_completed=update_data.milestone_completed,
            files_attached=update_data.files_attached,
            timestamp=datetime.utcnow(),
        )

        # Save to Firestore
        doc_ref = self.db.collection(self.COLLECTION).document(update_id)
        doc_ref.set(update.model_dump(mode="json"))

        return update

    def get_by_project(
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
        query = (
            self.db.collection(self.COLLECTION)
            .where("project_id", "==", project_id)
            .order_by("timestamp", direction=firestore.Query.DESCENDING)
            .limit(limit)
        )

        docs = query.stream()

        updates = []
        for doc in docs:
            data = doc.to_dict()
            updates.append(ProjectUpdateModel(**data))

        return updates

    def get_latest_update(self, project_id: str) -> Optional[ProjectUpdateModel]:
        """
        Get the most recent update for a project.

        Args:
            project_id: Project identifier

        Returns:
            Latest update if found, None otherwise
        """
        updates = self.get_by_project(project_id, limit=1)
        return updates[0] if updates else None

    def get_last_update_date(self, project_id: str) -> Optional[datetime]:
        """
        Get the timestamp of the last update for a project.

        Args:
            project_id: Project identifier

        Returns:
            Timestamp of last update, None if no updates
        """
        latest = self.get_latest_update(project_id)
        return latest.timestamp if latest else None
