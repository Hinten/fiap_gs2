"""
Tests for approval service business logic.
"""

from datetime import datetime

import pytest

from src.models.approval import (ApprovalPriority, ApprovalStatus,
                                 ApprovalType, BulkApprovalRequest)


@pytest.mark.asyncio
async def test_create_approval_item(service):
    """Test creating a new approval item."""
    approval = await service.create_approval_item(
        approval_type=ApprovalType.GRADING,
        related_id="grading_001",
        title="Test Grading",
        description="Test grading approval",
        generated_content={"grade": 8.5, "feedback": "Good work"},
        assigned_to="prof_001",
        priority=ApprovalPriority.NORMAL,
    )

    assert approval.approval_id.startswith("apr_")
    assert approval.type == ApprovalType.GRADING
    assert approval.status == ApprovalStatus.PENDING
    assert approval.assigned_to == "prof_001"


@pytest.mark.asyncio
async def test_list_pending_approvals(service, sample_approval, repository):
    """Test listing pending approvals."""
    # Create some test approvals
    await repository.create_approval(sample_approval)

    # List pending items
    items = await service.list_pending(user_id="prof_001")

    assert len(items) >= 1
    assert all(item.status == ApprovalStatus.PENDING for item in items)


@pytest.mark.asyncio
async def test_edit_approval(service, sample_approval, repository):
    """Test editing an approval item."""
    # Create approval
    await repository.create_approval(sample_approval)

    # Edit the score
    updated = await service.edit_approval(
        approval_id=sample_approval.approval_id,
        field_name="generated_content.score",
        new_value=80,
        edited_by="prof_001",
    )

    assert updated.generated_content["score"] == 80

    # Check edit was recorded
    edits = await repository.get_edits(sample_approval.approval_id)
    assert len(edits) == 1
    assert edits[0].field_changed == "generated_content.score"
    assert edits[0].old_value == 85
    assert edits[0].new_value == 80


@pytest.mark.asyncio
async def test_send_chat_message(service, sample_approval, repository):
    """Test sending a chat message."""
    # Create approval
    await repository.create_approval(sample_approval)

    # Send message
    message = await service.send_chat_message(
        approval_id=sample_approval.approval_id,
        sender="user",
        message="Please reduce the score to 80",
    )

    assert message.message_id.startswith("msg_")
    assert message.sender == "user"
    assert message.approval_id == sample_approval.approval_id

    # Check message was stored
    history = await service.get_chat_history(sample_approval.approval_id)
    assert len(history) == 1
    assert history[0].message == "Please reduce the score to 80"


@pytest.mark.asyncio
async def test_approve_item(service, sample_approval, repository):
    """Test approving an item."""
    # Create approval
    await repository.create_approval(sample_approval)

    # Approve it
    decision = await service.approve(
        approval_id=sample_approval.approval_id,
        approved_by="prof_001",
    )

    assert decision.decision == ApprovalStatus.APPROVED
    assert decision.decision_by == "prof_001"

    # Check status was updated
    approval = await repository.get_approval(sample_approval.approval_id)
    assert approval.status == ApprovalStatus.APPROVED
    assert approval.approved_at is not None


@pytest.mark.asyncio
async def test_reject_item(service, sample_approval, repository):
    """Test rejecting an item."""
    # Create approval
    await repository.create_approval(sample_approval)

    # Reject it
    decision = await service.reject(
        approval_id=sample_approval.approval_id,
        rejected_by="prof_001",
        reason="Score is too high",
    )

    assert decision.decision == ApprovalStatus.REJECTED
    assert decision.reason == "Score is too high"

    # Check status was updated
    approval = await repository.get_approval(sample_approval.approval_id)
    assert approval.status == ApprovalStatus.REJECTED


@pytest.mark.asyncio
async def test_reject_without_reason_fails(service, sample_approval, repository):
    """Test that rejecting without a reason fails."""
    # Create approval
    await repository.create_approval(sample_approval)

    # Try to reject without reason
    with pytest.raises(ValueError, match="Reason is required"):
        await service.reject(
            approval_id=sample_approval.approval_id,
            rejected_by="prof_001",
            reason="",
        )


@pytest.mark.asyncio
async def test_bulk_approve(service, repository):
    """Test bulk approval of multiple items."""
    # Create multiple approvals
    approval_ids = []
    for i in range(3):
        approval = await service.create_approval_item(
            approval_type=ApprovalType.CODE_REVIEW,
            related_id=f"review_{i}",
            title=f"Test Review {i}",
            description=f"Test approval {i}",
            generated_content={"score": 80 + i},
            assigned_to="prof_001",
        )
        approval_ids.append(approval.approval_id)

    # Bulk approve
    request = BulkApprovalRequest(
        approval_ids=approval_ids,
        approved_by="prof_001",
    )
    response = await service.bulk_approve(request)

    assert response.total == 3
    assert response.approved == 3
    assert response.failed == 0

    # Check all were approved
    for approval_id in approval_ids:
        approval = await repository.get_approval(approval_id)
        assert approval.status == ApprovalStatus.APPROVED


@pytest.mark.asyncio
async def test_get_stats(service, repository):
    """Test getting approval statistics."""
    # Create some approvals
    await service.create_approval_item(
        ApprovalType.CODE_REVIEW,
        "r1",
        "R1",
        "D1",
        {},
        "prof_001",
        ApprovalPriority.HIGH,
    )
    await service.create_approval_item(
        ApprovalType.GRADING, "g1", "G1", "D1", {}, "prof_001", ApprovalPriority.NORMAL
    )

    # Get stats
    stats = await service.get_stats(user_id="prof_001")

    assert stats.total_pending == 2
    assert stats.by_type["code_review"] == 1
    assert stats.by_type["grading"] == 1
    assert stats.by_priority["high"] == 1
    assert stats.by_priority["normal"] == 1


@pytest.mark.asyncio
async def test_cannot_edit_approved_item(service, sample_approval, repository):
    """Test that approved items cannot be edited."""
    # Create and approve
    await repository.create_approval(sample_approval)
    await service.approve(sample_approval.approval_id, "prof_001")

    # Try to edit
    with pytest.raises(ValueError, match="Cannot edit approval in status"):
        await service.edit_approval(
            approval_id=sample_approval.approval_id,
            field_name="title",
            new_value="New Title",
            edited_by="prof_001",
        )


@pytest.mark.asyncio
async def test_cannot_approve_twice(service, sample_approval, repository):
    """Test that items cannot be approved twice."""
    # Create and approve once
    await repository.create_approval(sample_approval)
    await service.approve(sample_approval.approval_id, "prof_001")

    # Try to approve again
    with pytest.raises(ValueError, match="Cannot approve item with status"):
        await service.approve(sample_approval.approval_id, "prof_001")
