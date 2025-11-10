"""
Approval service containing business logic.
"""

import logging
from datetime import datetime
from typing import List, Optional
from uuid import uuid4

from ..models.approval import (ApprovalChat, ApprovalDecision, ApprovalEdit,
                               ApprovalItem, ApprovalPriority, ApprovalStats,
                               ApprovalStatus, ApprovalType,
                               BulkApprovalRequest, BulkApprovalResponse)
from ..repositories.base import ApprovalRepository

logger = logging.getLogger(__name__)


class ApprovalService:
    """
    Service layer for approval operations.
    Handles business logic and coordinates repository calls.
    """

    def __init__(self, repository: ApprovalRepository):
        """Initialize the service with a repository."""
        self.repository = repository

    async def create_approval_item(
        self,
        approval_type: ApprovalType,
        related_id: str,
        title: str,
        description: str,
        generated_content: dict,
        assigned_to: str,
        priority: ApprovalPriority = ApprovalPriority.NORMAL,
    ) -> ApprovalItem:
        """
        Create a new approval item.

        Args:
            approval_type: Type of approval (code_review, grading, etc.)
            related_id: ID of related entity
            title: Title of the approval item
            description: Description
            generated_content: AI-generated content
            assigned_to: User ID to assign to
            priority: Priority level

        Returns:
            Created ApprovalItem
        """
        approval = ApprovalItem(
            approval_id=f"apr_{uuid4().hex[:12]}",
            type=approval_type,
            related_id=related_id,
            title=title,
            description=description,
            generated_content=generated_content,
            assigned_to=assigned_to,
            priority=priority,
            status=ApprovalStatus.PENDING,
            created_at=datetime.utcnow(),
        )

        result = await self.repository.create_approval(approval)
        logger.info(f"Created approval item {result.approval_id} for {assigned_to}")
        return result

    async def get_approval(self, approval_id: str) -> Optional[ApprovalItem]:
        """
        Get an approval item by ID.

        Args:
            approval_id: ID of the approval item

        Returns:
            ApprovalItem if found, None otherwise
        """
        return await self.repository.get_approval(approval_id)

    async def list_pending(
        self,
        user_id: Optional[str] = None,
        approval_type: Optional[ApprovalType] = None,
        priority: Optional[ApprovalPriority] = None,
        limit: int = 50,
        offset: int = 0,
    ) -> List[ApprovalItem]:
        """
        List pending approval items with filters.

        Args:
            user_id: Filter by assigned user
            approval_type: Filter by type
            priority: Filter by priority
            limit: Maximum number of items to return
            offset: Pagination offset

        Returns:
            List of pending ApprovalItems
        """
        return await self.repository.list_pending(
            assigned_to=user_id,
            approval_type=approval_type,
            priority=priority,
            limit=limit,
            offset=offset,
        )

    async def edit_approval(
        self,
        approval_id: str,
        field_name: str,
        new_value: any,
        edited_by: str,
    ) -> ApprovalItem:
        """
        Edit an approval item and record the edit.

        Args:
            approval_id: ID of the approval item
            field_name: Name of the field to edit
            new_value: New value for the field
            edited_by: User making the edit

        Returns:
            Updated ApprovalItem

        Raises:
            ValueError: If approval not found or cannot be edited
        """
        approval = await self.repository.get_approval(approval_id)
        if not approval:
            raise ValueError(f"Approval {approval_id} not found")

        if approval.status != ApprovalStatus.PENDING:
            raise ValueError(f"Cannot edit approval in status {approval.status}")

        # Get old value
        old_value = None
        if "." in field_name:
            # Handle nested fields like "generated_content.score"
            parts = field_name.split(".")
            obj = approval
            for part in parts[:-1]:
                obj = getattr(obj, part, {})
            old_value = (
                obj.get(parts[-1])
                if isinstance(obj, dict)
                else getattr(obj, parts[-1], None)
            )
        else:
            old_value = getattr(approval, field_name, None)

        # Record the edit
        edit = ApprovalEdit(
            edit_id=f"edit_{uuid4().hex[:12]}",
            approval_id=approval_id,
            field_changed=field_name,
            old_value=old_value,
            new_value=new_value,
            changed_by=edited_by,
            timestamp=datetime.utcnow(),
        )
        await self.repository.create_edit(edit)

        # Update the approval
        if "." in field_name:
            # Handle nested fields
            parts = field_name.split(".")
            if parts[0] == "generated_content":
                approval.generated_content[parts[1]] = new_value
                updates = {"generated_content": approval.generated_content}
            else:
                updates = {field_name: new_value}
        else:
            updates = {field_name: new_value}

        result = await self.repository.update_approval(approval_id, updates)
        logger.info(f"Edited approval {approval_id}, field {field_name} by {edited_by}")
        return result

    async def send_chat_message(
        self,
        approval_id: str,
        sender: str,
        message: str,
    ) -> ApprovalChat:
        """
        Send a chat message to an agent about an approval.

        Args:
            approval_id: ID of the approval item
            sender: Either 'user' or 'agent'
            message: Message content

        Returns:
            Created ApprovalChat message

        Raises:
            ValueError: If approval not found
        """
        approval = await self.repository.get_approval(approval_id)
        if not approval:
            raise ValueError(f"Approval {approval_id} not found")

        chat_message = ApprovalChat(
            message_id=f"msg_{uuid4().hex[:12]}",
            approval_id=approval_id,
            sender=sender,
            message=message,
            timestamp=datetime.utcnow(),
        )

        result = await self.repository.create_chat_message(chat_message)
        logger.info(f"Chat message sent for approval {approval_id} by {sender}")

        # In production, this would trigger the AI agent to respond
        # For now, just log it
        if sender == "user":
            logger.info(f"Would trigger AI agent to respond to: {message}")

        return result

    async def get_chat_history(self, approval_id: str) -> List[ApprovalChat]:
        """
        Get chat history for an approval.

        Args:
            approval_id: ID of the approval item

        Returns:
            List of chat messages
        """
        return await self.repository.get_chat_history(approval_id)

    async def approve(
        self,
        approval_id: str,
        approved_by: str,
    ) -> ApprovalDecision:
        """
        Approve an approval item.

        Args:
            approval_id: ID of the approval item
            approved_by: User ID approving

        Returns:
            ApprovalDecision

        Raises:
            ValueError: If approval not found or cannot be approved
        """
        approval = await self.repository.get_approval(approval_id)
        if not approval:
            raise ValueError(f"Approval {approval_id} not found")

        if approval.status != ApprovalStatus.PENDING:
            raise ValueError(f"Cannot approve item with status {approval.status}")

        # Update status
        await self.repository.update_status(
            approval_id,
            ApprovalStatus.APPROVED,
            approved_by,
        )

        decision = ApprovalDecision(
            approval_id=approval_id,
            decision=ApprovalStatus.APPROVED,
            decision_by=approved_by,
            timestamp=datetime.utcnow(),
        )

        logger.info(f"Approved {approval_id} by {approved_by}")

        # In production, this would trigger actions based on approval type
        # e.g., post GitHub comment, publish grades, upload video
        await self._execute_approval_action(approval)

        return decision

    async def reject(
        self,
        approval_id: str,
        rejected_by: str,
        reason: str,
    ) -> ApprovalDecision:
        """
        Reject an approval item.

        Args:
            approval_id: ID of the approval item
            rejected_by: User ID rejecting
            reason: Reason for rejection

        Returns:
            ApprovalDecision

        Raises:
            ValueError: If approval not found or cannot be rejected
        """
        if not reason:
            raise ValueError("Reason is required for rejection")

        approval = await self.repository.get_approval(approval_id)
        if not approval:
            raise ValueError(f"Approval {approval_id} not found")

        if approval.status != ApprovalStatus.PENDING:
            raise ValueError(f"Cannot reject item with status {approval.status}")

        # Update status
        await self.repository.update_status(
            approval_id,
            ApprovalStatus.REJECTED,
            rejected_by,
            reason,
        )

        decision = ApprovalDecision(
            approval_id=approval_id,
            decision=ApprovalStatus.REJECTED,
            decision_by=rejected_by,
            reason=reason,
            timestamp=datetime.utcnow(),
        )

        logger.info(f"Rejected {approval_id} by {rejected_by}: {reason}")

        # In production, this would notify the agent to regenerate
        await self._handle_rejection(approval, reason)

        return decision

    async def bulk_approve(
        self,
        request: BulkApprovalRequest,
    ) -> BulkApprovalResponse:
        """
        Approve multiple items at once.

        Args:
            request: Bulk approval request with list of IDs

        Returns:
            BulkApprovalResponse with results
        """
        response = BulkApprovalResponse(
            total=len(request.approval_ids),
            approved=0,
            failed=0,
            errors=[],
        )

        for approval_id in request.approval_ids:
            try:
                await self.approve(approval_id, request.approved_by)
                response.approved += 1
            except Exception as e:
                response.failed += 1
                response.errors.append(
                    {
                        "approval_id": approval_id,
                        "error": str(e),
                    }
                )
                logger.error(f"Failed to approve {approval_id}: {e}")

        logger.info(
            f"Bulk approval: {response.approved}/{response.total} succeeded, "
            f"{response.failed} failed"
        )

        return response

    async def get_history(
        self,
        user_id: Optional[str] = None,
        approval_type: Optional[ApprovalType] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        limit: int = 50,
        offset: int = 0,
    ) -> List[ApprovalItem]:
        """
        Get approval history with filters.

        Args:
            user_id: Filter by user
            approval_type: Filter by type
            start_date: Filter by start date
            end_date: Filter by end date
            limit: Maximum items to return
            offset: Pagination offset

        Returns:
            List of historical approval items
        """
        return await self.repository.get_history(
            user_id=user_id,
            approval_type=approval_type,
            start_date=start_date,
            end_date=end_date,
            limit=limit,
            offset=offset,
        )

    async def get_stats(self, user_id: Optional[str] = None) -> ApprovalStats:
        """
        Get approval statistics.

        Args:
            user_id: Optional user to filter by

        Returns:
            ApprovalStats
        """
        stats_dict = await self.repository.get_stats(user_id)
        return ApprovalStats(**stats_dict)

    async def _execute_approval_action(self, approval: ApprovalItem):
        """
        Execute the appropriate action after approval.

        In production, this would:
        - Post GitHub comment for code reviews
        - Publish grades for grading
        - Upload videos for content
        - etc.
        """
        logger.info(
            f"Would execute action for {approval.type} approval {approval.approval_id}"
        )
        # Placeholder for actual implementation

    async def _handle_rejection(self, approval: ApprovalItem, reason: str):
        """
        Handle rejection by notifying the agent.

        In production, this would:
        - Send feedback to the agent
        - Trigger regeneration if configured
        - Update reinforcement learning metrics
        """
        logger.info(
            f"Would handle rejection for {approval.type} approval {approval.approval_id}: {reason}"
        )
        # Placeholder for actual implementation
