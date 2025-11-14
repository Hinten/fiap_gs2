"""
Repository for project members data access.
"""

from datetime import datetime
from typing import List, Optional

from firebase_admin import firestore

from ..firebase_admin import get_db
from ..models.member import MemberRole, ProjectMember, ProjectMemberCreate


class MemberRepository:
    """Repository for managing project members in Firestore."""

    COLLECTION = "project_members"

    def __init__(self, db: Optional[firestore.Client] = None):
        """
        Initialize repository.

        Args:
            db: Optional Firestore client. If None, uses default.
        """
        self.db = db or get_db()

    def add_member(
        self, project_id: str, member_data: ProjectMemberCreate
    ) -> ProjectMember:
        """
        Add a member to a project.

        Args:
            project_id: Project identifier
            member_data: Member creation data

        Returns:
            Created project member
        """
        member = ProjectMember(
            project_id=project_id,
            user_id=member_data.user_id,
            role=member_data.role,
            joined_at=datetime.utcnow(),
        )

        # Use composite key: project_id#user_id
        doc_id = f"{project_id}#{member_data.user_id}"
        doc_ref = self.db.collection(self.COLLECTION).document(doc_id)
        doc_ref.set(member.model_dump(mode="json"))

        return member

    def get_members(
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
        query = self.db.collection(self.COLLECTION).where(
            "project_id", "==", project_id
        )

        if role:
            query = query.where("role", "==", role.value)

        # Filter out members who have left
        query = query.where("left_at", "==", None)

        docs = query.stream()

        members = []
        for doc in docs:
            data = doc.to_dict()
            members.append(ProjectMember(**data))

        return members

    def get_projects_by_user(
        self, user_id: str, role: Optional[MemberRole] = None
    ) -> List[str]:
        """
        Get all project IDs for a user.

        Args:
            user_id: User identifier
            role: Optional role filter

        Returns:
            List of project IDs
        """
        query = self.db.collection(self.COLLECTION).where("user_id", "==", user_id)

        if role:
            query = query.where("role", "==", role.value)

        # Filter out projects the user has left
        query = query.where("left_at", "==", None)

        docs = query.stream()

        project_ids = []
        for doc in docs:
            data = doc.to_dict()
            project_ids.append(data["project_id"])

        return project_ids

    def remove_member(self, project_id: str, user_id: str) -> bool:
        """
        Remove a member from a project (soft delete).

        Args:
            project_id: Project identifier
            user_id: User identifier

        Returns:
            True if removed, False if not found
        """
        doc_id = f"{project_id}#{user_id}"
        doc_ref = self.db.collection(self.COLLECTION).document(doc_id)
        doc = doc_ref.get()

        if not doc.exists:
            return False

        # Soft delete by setting left_at
        doc_ref.update({"left_at": datetime.utcnow()})
        return True

    def has_advisor(self, project_id: str) -> bool:
        """
        Check if a project has an advisor.

        Args:
            project_id: Project identifier

        Returns:
            True if project has an advisor, False otherwise
        """
        query = (
            self.db.collection(self.COLLECTION)
            .where("project_id", "==", project_id)
            .where(
                "role", "in", [MemberRole.ADVISOR.value, MemberRole.CO_ADVISOR.value]
            )
            .where("left_at", "==", None)
            .limit(1)
        )

        docs = list(query.stream())
        return len(docs) > 0

    def get_students_without_advisor(self) -> List[str]:
        """
        Get list of student IDs who don't have an advisor.

        Returns:
            List of student user IDs
        """
        # Get all students
        student_query = (
            self.db.collection(self.COLLECTION)
            .where("role", "==", MemberRole.STUDENT.value)
            .where("left_at", "==", None)
        )
        student_docs = student_query.stream()

        # Check which projects have no advisor
        students_without_advisor = []
        seen_projects = set()

        for doc in student_docs:
            data = doc.to_dict()
            project_id = data["project_id"]
            user_id = data["user_id"]

            # Skip if we already checked this project
            if project_id in seen_projects:
                if not self.has_advisor(project_id):
                    students_without_advisor.append(user_id)
            else:
                seen_projects.add(project_id)
                if not self.has_advisor(project_id):
                    students_without_advisor.append(user_id)

        return students_without_advisor
