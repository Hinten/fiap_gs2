"""API routes for code review agent."""

from typing import List
from fastapi import APIRouter, HTTPException, status, BackgroundTasks

from ..models import (
    CodeReviewRequest,
    CodeReviewResponse,
    CodeReview,
    ApprovalRequest,
    APIResponse,
)
from ..services.code_review_service import CodeReviewService

router = APIRouter()
code_review_service = CodeReviewService()


@router.post("/analyze", response_model=CodeReviewResponse)
async def create_code_review(
    request: CodeReviewRequest,
    background_tasks: BackgroundTasks
):
    """
    Create a new code review and trigger analysis.
    
    Args:
        request: Code review request with repo and PR details
        background_tasks: FastAPI background tasks
        
    Returns:
        CodeReviewResponse with review ID and status
    """
    response = await code_review_service.create_review(request)
    
    if response.success:
        # Run analysis in background
        background_tasks.add_task(
            code_review_service.analyze_code,
            response.review_id
        )
    
    return response


@router.get("/pending", response_model=List[CodeReview])
async def list_pending_reviews():
    """
    List all pending code reviews.
    
    Returns:
        List of pending CodeReview objects
    """
    try:
        reviews = await code_review_service.list_pending_reviews()
        return reviews
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to list reviews: {str(e)}"
        )


@router.get("/{review_id}", response_model=CodeReview)
async def get_code_review(review_id: str):
    """
    Get details of a specific code review.
    
    Args:
        review_id: Unique identifier of the review
        
    Returns:
        CodeReview object with full details
    """
    review = await code_review_service.get_review(review_id)
    
    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Review {review_id} not found"
        )
    
    return review


@router.put("/{review_id}/approve", response_model=APIResponse)
async def approve_review(
    review_id: str,
    approval: ApprovalRequest
):
    """
    Approve a code review and optionally post to GitHub.
    
    Args:
        review_id: Unique identifier of the review
        approval: Approval request with optional edits
        
    Returns:
        APIResponse with success status
    """
    success = await code_review_service.approve_review(
        review_id=review_id,
        professor_edits=approval.edits,
        post_to_github=approval.post_to_github
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to approve review"
        )
    
    return APIResponse(
        success=True,
        message="Review approved successfully"
    )


@router.put("/{review_id}/edit", response_model=APIResponse)
async def edit_review(review_id: str, edits: str):
    """
    Edit the feedback of a code review.
    
    Args:
        review_id: Unique identifier of the review
        edits: New feedback text
        
    Returns:
        APIResponse with success status
    """
    review = await code_review_service.get_review(review_id)
    
    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Review {review_id} not found"
        )
    
    review.professor_edits = edits
    # Note: Update logic should be in service layer
    # This is simplified for MVP
    
    return APIResponse(
        success=True,
        message="Review updated successfully"
    )
