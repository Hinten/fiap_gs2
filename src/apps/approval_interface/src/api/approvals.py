"""
FastAPI routes for approval operations.
"""

from datetime import datetime
from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel

from ..models.approval import (ApprovalChat, ApprovalDecision, ApprovalEdit,
                               ApprovalItem, ApprovalPriority, ApprovalStats,
                               ApprovalType, BulkApprovalRequest,
                               BulkApprovalResponse)
from ..repositories.dynamodb import DynamoDBApprovalRepository
from ..services.approval_service import ApprovalService

router = APIRouter(prefix="/api/v1/approvals", tags=["approvals"])


# Dependency for service injection
def get_approval_service() -> ApprovalService:
    """Get an instance of the approval service."""
    repository = DynamoDBApprovalRepository()
    return ApprovalService(repository)


# Request/Response models
class CreateApprovalRequest(BaseModel):
    """Request to create a new approval item."""

    type: ApprovalType
    related_id: str
    title: str
    description: str
    generated_content: dict
    assigned_to: str
    priority: ApprovalPriority = ApprovalPriority.NORMAL


class EditApprovalRequest(BaseModel):
    """Request to edit an approval item."""

    field_name: str
    new_value: Any
    edited_by: str


class ChatMessageRequest(BaseModel):
    """Request to send a chat message."""

    sender: str  # 'user' or 'agent'
    message: str


class ApproveRequest(BaseModel):
    """Request to approve an item."""

    approved_by: str


class RejectRequest(BaseModel):
    """Request to reject an item."""

    rejected_by: str
    reason: str


class StandardResponse(BaseModel):
    """Standard API response format."""

    success: bool
    data: Any = None
    error: Optional[str] = None


# Routes
@router.get("/stats", response_model=StandardResponse)
async def get_stats(
    user_id: Optional[str] = Query(None, description="Filter by user"),
    service: ApprovalService = Depends(get_approval_service),
):
    """
    Get approval statistics for the dashboard.

    Returns counts by type, priority, average approval time, and approval rate.
    """
    try:
        stats = await service.get_stats(user_id)
        return StandardResponse(success=True, data=stats)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/pending", response_model=StandardResponse)
async def list_pending_approvals(
    user_id: Optional[str] = Query(None, description="Filter by assigned user"),
    type: Optional[ApprovalType] = Query(None, description="Filter by approval type"),
    priority: Optional[ApprovalPriority] = Query(
        None, description="Filter by priority"
    ),
    limit: int = Query(50, ge=1, le=100, description="Maximum items to return"),
    offset: int = Query(0, ge=0, description="Pagination offset"),
    service: ApprovalService = Depends(get_approval_service),
):
    """
    List all pending approval items with optional filters.

    Returns items sorted by priority (critical first) and creation date.
    """
    try:
        items = await service.list_pending(
            user_id=user_id,
            approval_type=type,
            priority=priority,
            limit=limit,
            offset=offset,
        )
        return StandardResponse(success=True, data=items)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/history", response_model=StandardResponse)
async def get_history(
    user_id: Optional[str] = Query(None, description="Filter by user"),
    type: Optional[ApprovalType] = Query(None, description="Filter by type"),
    start_date: Optional[datetime] = Query(None, description="Filter by start date"),
    end_date: Optional[datetime] = Query(None, description="Filter by end date"),
    limit: int = Query(50, ge=1, le=100, description="Maximum items to return"),
    offset: int = Query(0, ge=0, description="Pagination offset"),
    service: ApprovalService = Depends(get_approval_service),
):
    """
    Get approval history with filters.

    Returns approved and rejected items for audit purposes.
    """
    try:
        items = await service.get_history(
            user_id=user_id,
            approval_type=type,
            start_date=start_date,
            end_date=end_date,
            limit=limit,
            offset=offset,
        )
        return StandardResponse(success=True, data=items)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{approval_id}", response_model=StandardResponse)
async def get_approval(
    approval_id: str,
    service: ApprovalService = Depends(get_approval_service),
):
    """
    Get details of a specific approval item.
    """
    try:
        approval = await service.get_approval(approval_id)
        if not approval:
            raise HTTPException(status_code=404, detail="Approval not found")
        return StandardResponse(success=True, data=approval)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("", response_model=StandardResponse, status_code=201)
async def create_approval(
    request: CreateApprovalRequest,
    service: ApprovalService = Depends(get_approval_service),
):
    """
    Create a new approval item.

    This is typically called by AI agents when they generate content
    that requires human approval.
    """
    try:
        approval = await service.create_approval_item(
            approval_type=request.type,
            related_id=request.related_id,
            title=request.title,
            description=request.description,
            generated_content=request.generated_content,
            assigned_to=request.assigned_to,
            priority=request.priority,
        )
        return StandardResponse(success=True, data=approval)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{approval_id}/edit", response_model=StandardResponse)
async def edit_approval(
    approval_id: str,
    request: EditApprovalRequest,
    service: ApprovalService = Depends(get_approval_service),
):
    """
    Edit an approval item before approving.

    All edits are recorded in the audit log for transparency.
    """
    try:
        approval = await service.edit_approval(
            approval_id=approval_id,
            field_name=request.field_name,
            new_value=request.new_value,
            edited_by=request.edited_by,
        )
        return StandardResponse(success=True, data=approval)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/{approval_id}/chat", response_model=StandardResponse)
async def send_chat_message(
    approval_id: str,
    request: ChatMessageRequest,
    service: ApprovalService = Depends(get_approval_service),
):
    """
    Send a message to the AI agent about this approval.

    The agent will respond with suggestions or execute changes.
    """
    try:
        message = await service.send_chat_message(
            approval_id=approval_id,
            sender=request.sender,
            message=request.message,
        )
        return StandardResponse(success=True, data=message)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{approval_id}/chat", response_model=StandardResponse)
async def get_chat_history(
    approval_id: str,
    service: ApprovalService = Depends(get_approval_service),
):
    """
    Get the chat history for an approval item.
    """
    try:
        messages = await service.get_chat_history(approval_id)
        return StandardResponse(success=True, data=messages)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/{approval_id}/approve", response_model=StandardResponse)
async def approve_item(
    approval_id: str,
    request: ApproveRequest,
    service: ApprovalService = Depends(get_approval_service),
):
    """
    Approve an approval item.

    This triggers the appropriate action based on the approval type:
    - Code review: Post comment to GitHub
    - Grading: Publish grades to system
    - Content: Upload to YouTube/platform
    - etc.
    """
    try:
        decision = await service.approve(
            approval_id=approval_id,
            approved_by=request.approved_by,
        )
        return StandardResponse(success=True, data=decision)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/{approval_id}/reject", response_model=StandardResponse)
async def reject_item(
    approval_id: str,
    request: RejectRequest,
    service: ApprovalService = Depends(get_approval_service),
):
    """
    Reject an approval item with a reason.

    The reason is sent back to the AI agent for learning and regeneration.
    """
    try:
        decision = await service.reject(
            approval_id=approval_id,
            rejected_by=request.rejected_by,
            reason=request.reason,
        )
        return StandardResponse(success=True, data=decision)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/bulk-approve", response_model=StandardResponse)
async def bulk_approve(
    request: BulkApprovalRequest,
    service: ApprovalService = Depends(get_approval_service),
):
    """
    Approve multiple items at once.

    Returns a summary of successful and failed approvals.
    """
    try:
        result = await service.bulk_approve(request)
        return StandardResponse(success=True, data=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
