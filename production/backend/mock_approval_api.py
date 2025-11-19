"""
Mock Approval API endpoints for demonstration purposes.
This is a placeholder until the full approval backend is implemented.
"""

from typing import List, Dict, Any, Optional
from datetime import datetime, UTC
from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel

router = APIRouter(prefix="/approvals", tags=["approvals"])

# Mock data store adjusted to match ApprovalItem Dart model JSON structure
# Keys use snake_case to align with frontend expectations:
# id, type, title, description, priority, status, content, assigned_to,
# created_at, reviewed_at, approved_at, metadata
mock_approvals: List[Dict[str, Any]] = [
    {
        "id": "approval-1",
        "type": "codeReview",  # matches ApprovalType.codeReview
        "title": "Review Python Code Changes",
        "description": "Please review the recent changes to the authentication module",
        "priority": "high",  # matches ApprovalPriority.high
        "status": "pending",  # matches ApprovalStatus.pending
        "content": None,
        "assigned_to": "reviewer-1",
        "created_at": "2025-11-19T10:00:00Z",
        "reviewed_at": None,
        "approved_at": None,
        "created_by": "developer-1",  # extra field (not in Dart model) retained for backend context
        "metadata": {
            "repository": "fiap_gs2",
            "pull_request": "#123",
            "lines_changed": 150,
        },
    },
    {
        "id": "approval-2",
        "type": "content",  # matches ApprovalType.content
        "title": "Educational Content Approval",
        "description": "New lesson content needs approval before publishing",
        "priority": "normal",  # 'medium' mapped to 'normal'
        "status": "pending",
        "content": None,
        "assigned_to": "coordinator-1",
        "created_at": "2025-11-19T11:30:00Z",
        "reviewed_at": None,
        "approved_at": None,
        "created_by": "content-creator-1",
        "metadata": {
            "course": "Python Programming",
            "lesson": "Chapter 5: Object-Oriented Programming",
        },
    },
    {
        "id": "approval-3",
        "type": "grading",  # matches ApprovalType.grading
        "title": "Student Assignment Grading",
        "description": "Review and approve AI-suggested grade for student submission",
        "priority": "high",
        "status": "pending",
        "content": None,
        "assigned_to": "professor-1",
        "created_at": "2025-11-19T12:00:00Z",
        "reviewed_at": None,
        "approved_at": None,
        "created_by": "grading-agent",
        "metadata": {
            "student": "student-123",
            "assignment": "Project 1",
            "suggested_grade": 8.5,
        },
    },
]


class ApprovalComment(BaseModel):
    comment: Optional[str] = None


class ApprovalRejection(BaseModel):
    reason: str


class BulkApprovalRequest(BaseModel):
    item_ids: List[str]


@router.get("/pending")
async def get_pending_approvals(
    type: Optional[str] = Query(None),
    priority: Optional[str] = Query(None),
    assigned_to: Optional[str] = Query(None),
) -> Dict[str, Any]:
    """Get pending approval items with optional filters"""
    filtered_items = [
        item
        for item in mock_approvals
        if item["status"] == "pending"
        and (not type or item["type"] == type)
        and (not priority or item["priority"] == priority)
        and (not assigned_to or item.get("assigned_to") == assigned_to)
    ]

    return {"data": filtered_items, "count": len(filtered_items)}


@router.get("/{approval_id}")
async def get_approval_by_id(approval_id: str) -> Dict[str, Any]:
    """Get a specific approval item by ID"""
    item = next((item for item in mock_approvals if item["id"] == approval_id), None)
    if not item:
        raise HTTPException(status_code=404, detail="Approval item not found")

    return {"data": item}


@router.post("/{approval_id}/approve")
async def approve_item(approval_id: str, comment: ApprovalComment) -> Dict[str, Any]:
    """Approve an approval item"""
    item = next((item for item in mock_approvals if item["id"] == approval_id), None)
    if not item:
        raise HTTPException(status_code=404, detail="Approval item not found")

    # Update status
    item["status"] = "approved"
    item["approved_at"] = datetime.now(UTC).isoformat().replace("+00:00", "Z")
    item["approver_comment"] = comment.comment

    return {"data": item, "message": "Item approved successfully"}


@router.post("/{approval_id}/reject")
async def reject_item(approval_id: str, rejection: ApprovalRejection) -> Dict[str, Any]:
    """Reject an approval item"""
    item = next((item for item in mock_approvals if item["id"] == approval_id), None)
    if not item:
        raise HTTPException(status_code=404, detail="Approval item not found")

    # Update status
    item["status"] = "rejected"
    item["rejected_at"] = datetime.now(UTC).isoformat().replace("+00:00", "Z")
    item["rejection_reason"] = rejection.reason

    return {"data": item, "message": "Item rejected successfully"}


@router.put("/{approval_id}/edit")
async def edit_item(approval_id: str, updates: Dict[str, Any]) -> Dict[str, Any]:
    """Edit an approval item"""
    item = next((item for item in mock_approvals if item["id"] == approval_id), None)
    if not item:
        raise HTTPException(status_code=404, detail="Approval item not found")

    protected_fields = {"id", "created_at", "created_by"}
    for key, value in updates.items():
        if key in item and key not in protected_fields:
            item[key] = value

    item["updated_at"] = datetime.now(UTC).isoformat().replace("+00:00", "Z")

    return {"data": item, "message": "Item updated successfully"}


@router.post("/bulk-approve")
async def bulk_approve(request: BulkApprovalRequest) -> Dict[str, Any]:
    """Bulk approve multiple items"""
    results = {}

    for item_id in request.item_ids:
        item = next((item for item in mock_approvals if item["id"] == item_id), None)
        if item and item["status"] == "pending":
            item["status"] = "approved"
            item["approved_at"] = datetime.now(UTC).isoformat().replace("+00:00", "Z")
            results[item_id] = True
        else:
            results[item_id] = False

    return {
        "data": {
            "results": results,
            "success_count": sum(1 for v in results.values() if v),
            "total_count": len(request.item_ids),
        }
    }


@router.get("/history")
async def get_approval_history(
    type: Optional[str] = Query(None),
    status: Optional[str] = Query(None),
) -> Dict[str, Any]:
    """Get approval history with optional filters"""
    filtered_items = [
        item
        for item in mock_approvals
        if (not type or item["type"] == type) and (not status or item["status"] == status)
    ]

    return {"data": filtered_items, "count": len(filtered_items)}
