"""
Base repository interface for approval data access.
"""

from abc import ABC, abstractmethod
from datetime import datetime
from typing import List, Optional

from ..models.approval import (ApprovalChat, ApprovalEdit, ApprovalItem,
                               ApprovalPriority, ApprovalStatus, ApprovalType)


class ApprovalRepository(ABC):
    """
    Abstract base class for approval data access.
    Implementations can use DynamoDB, Aurora, or in-memory storage.
    """

    @abstractmethod
    async def create_approval(self, approval: ApprovalItem) -> ApprovalItem:
        """Create a new approval item."""
        pass

    @abstractmethod
    async def get_approval(self, approval_id: str) -> Optional[ApprovalItem]:
        """Get an approval item by ID."""
        pass

    @abstractmethod
    async def list_pending(
        self,
        assigned_to: Optional[str] = None,
        approval_type: Optional[ApprovalType] = None,
        priority: Optional[ApprovalPriority] = None,
        limit: int = 50,
        offset: int = 0,
    ) -> List[ApprovalItem]:
        """List pending approval items with optional filters."""
        pass

    @abstractmethod
    async def update_approval(self, approval_id: str, updates: dict) -> ApprovalItem:
        """Update an approval item."""
        pass

    @abstractmethod
    async def update_status(
        self,
        approval_id: str,
        status: ApprovalStatus,
        decision_by: str,
        reason: Optional[str] = None,
    ) -> ApprovalItem:
        """Update the status of an approval item."""
        pass

    @abstractmethod
    async def create_edit(self, edit: ApprovalEdit) -> ApprovalEdit:
        """Record an edit to an approval item."""
        pass

    @abstractmethod
    async def get_edits(self, approval_id: str) -> List[ApprovalEdit]:
        """Get all edits for an approval item."""
        pass

    @abstractmethod
    async def create_chat_message(self, message: ApprovalChat) -> ApprovalChat:
        """Create a chat message."""
        pass

    @abstractmethod
    async def get_chat_history(self, approval_id: str) -> List[ApprovalChat]:
        """Get chat history for an approval item."""
        pass

    @abstractmethod
    async def get_history(
        self,
        user_id: Optional[str] = None,
        approval_type: Optional[ApprovalType] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        limit: int = 50,
        offset: int = 0,
    ) -> List[ApprovalItem]:
        """Get approval history with filters."""
        pass

    @abstractmethod
    async def get_stats(self, user_id: Optional[str] = None) -> dict:
        """Get approval statistics."""
        pass
