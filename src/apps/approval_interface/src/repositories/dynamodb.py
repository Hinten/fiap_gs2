"""
DynamoDB implementation of the approval repository.
"""

from datetime import datetime
from typing import List, Optional
from uuid import uuid4

from ..models.approval import (ApprovalChat, ApprovalEdit, ApprovalItem,
                               ApprovalPriority, ApprovalStatus, ApprovalType)
from .base import ApprovalRepository


class DynamoDBApprovalRepository(ApprovalRepository):
    """
    DynamoDB implementation of the approval repository.

    Tables:
    - approval_items: Main approval items
    - approval_edits: Edit history
    - approval_chats: Chat messages

    Note: This is a placeholder implementation. In production, this would
    use boto3 to interact with actual DynamoDB tables.
    """

    def __init__(self):
        """Initialize the repository with in-memory storage for now."""
        # In production, this would initialize boto3 DynamoDB client
        self._approvals = {}
        self._edits = {}
        self._chats = {}

    async def create_approval(self, approval: ApprovalItem) -> ApprovalItem:
        """Create a new approval item."""
        if not approval.approval_id:
            approval.approval_id = f"apr_{uuid4().hex[:12]}"

        self._approvals[approval.approval_id] = approval
        return approval

    async def get_approval(self, approval_id: str) -> Optional[ApprovalItem]:
        """Get an approval item by ID."""
        return self._approvals.get(approval_id)

    async def list_pending(
        self,
        assigned_to: Optional[str] = None,
        approval_type: Optional[ApprovalType] = None,
        priority: Optional[ApprovalPriority] = None,
        limit: int = 50,
        offset: int = 0,
    ) -> List[ApprovalItem]:
        """List pending approval items with optional filters."""
        items = [
            item
            for item in self._approvals.values()
            if item.status == ApprovalStatus.PENDING
        ]

        # Apply filters
        if assigned_to:
            items = [item for item in items if item.assigned_to == assigned_to]
        if approval_type:
            items = [item for item in items if item.type == approval_type]
        if priority:
            items = [item for item in items if item.priority == priority]

        # Sort by priority and creation date
        priority_order = {
            ApprovalPriority.CRITICAL: 0,
            ApprovalPriority.HIGH: 1,
            ApprovalPriority.NORMAL: 2,
            ApprovalPriority.LOW: 3,
        }
        items.sort(key=lambda x: (priority_order.get(x.priority, 4), x.created_at))

        # Apply pagination
        return items[offset : offset + limit]

    async def update_approval(self, approval_id: str, updates: dict) -> ApprovalItem:
        """Update an approval item."""
        approval = self._approvals.get(approval_id)
        if not approval:
            raise ValueError(f"Approval {approval_id} not found")

        # Update fields
        for key, value in updates.items():
            if hasattr(approval, key):
                setattr(approval, key, value)

        self._approvals[approval_id] = approval
        return approval

    async def update_status(
        self,
        approval_id: str,
        status: ApprovalStatus,
        decision_by: str,
        reason: Optional[str] = None,
    ) -> ApprovalItem:
        """Update the status of an approval item."""
        approval = self._approvals.get(approval_id)
        if not approval:
            raise ValueError(f"Approval {approval_id} not found")

        approval.status = status
        approval.reviewed_at = datetime.utcnow()

        if status == ApprovalStatus.APPROVED:
            approval.approved_at = datetime.utcnow()

        self._approvals[approval_id] = approval
        return approval

    async def create_edit(self, edit: ApprovalEdit) -> ApprovalEdit:
        """Record an edit to an approval item."""
        if not edit.edit_id:
            edit.edit_id = f"edit_{uuid4().hex[:12]}"

        if edit.approval_id not in self._edits:
            self._edits[edit.approval_id] = []

        self._edits[edit.approval_id].append(edit)
        return edit

    async def get_edits(self, approval_id: str) -> List[ApprovalEdit]:
        """Get all edits for an approval item."""
        return self._edits.get(approval_id, [])

    async def create_chat_message(self, message: ApprovalChat) -> ApprovalChat:
        """Create a chat message."""
        if not message.message_id:
            message.message_id = f"msg_{uuid4().hex[:12]}"

        if message.approval_id not in self._chats:
            self._chats[message.approval_id] = []

        self._chats[message.approval_id].append(message)
        return message

    async def get_chat_history(self, approval_id: str) -> List[ApprovalChat]:
        """Get chat history for an approval item."""
        return self._chats.get(approval_id, [])

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
        items = [
            item
            for item in self._approvals.values()
            if item.status in [ApprovalStatus.APPROVED, ApprovalStatus.REJECTED]
        ]

        # Apply filters
        if user_id:
            items = [item for item in items if item.assigned_to == user_id]
        if approval_type:
            items = [item for item in items if item.type == approval_type]
        if start_date:
            items = [
                item
                for item in items
                if item.reviewed_at and item.reviewed_at >= start_date
            ]
        if end_date:
            items = [
                item
                for item in items
                if item.reviewed_at and item.reviewed_at <= end_date
            ]

        # Sort by reviewed date descending
        items.sort(key=lambda x: x.reviewed_at or datetime.min, reverse=True)

        # Apply pagination
        return items[offset : offset + limit]

    async def get_stats(self, user_id: Optional[str] = None) -> dict:
        """Get approval statistics."""
        items = list(self._approvals.values())

        if user_id:
            items = [item for item in items if item.assigned_to == user_id]

        pending = [item for item in items if item.status == ApprovalStatus.PENDING]
        approved = [item for item in items if item.status == ApprovalStatus.APPROVED]
        rejected = [item for item in items if item.status == ApprovalStatus.REJECTED]

        # Count by type
        by_type = {}
        for item in pending:
            by_type[item.type.value] = by_type.get(item.type.value, 0) + 1

        # Count by priority
        by_priority = {}
        for item in pending:
            by_priority[item.priority.value] = (
                by_priority.get(item.priority.value, 0) + 1
            )

        # Calculate average approval time
        approval_times = []
        for item in approved:
            if item.created_at and item.approved_at:
                delta = item.approved_at - item.created_at
                approval_times.append(delta.total_seconds() / 60)  # in minutes

        avg_time = sum(approval_times) / len(approval_times) if approval_times else None

        # Calculate approval rate
        total_decided = len(approved) + len(rejected)
        approval_rate = (
            (len(approved) / total_decided * 100) if total_decided > 0 else None
        )

        return {
            "total_pending": len(pending),
            "by_type": by_type,
            "by_priority": by_priority,
            "avg_approval_time_minutes": avg_time,
            "approval_rate": approval_rate,
        }
