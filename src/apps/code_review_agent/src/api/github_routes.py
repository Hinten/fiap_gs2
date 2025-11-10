"""API routes for GitHub webhook integration."""

from fastapi import APIRouter, HTTPException, Request, status
import hmac
import hashlib

from ..models import GitHubWebhookPayload, APIResponse, CodeReviewRequest
from ..services.code_review_service import CodeReviewService
from ..utils.config import settings

router = APIRouter()
code_review_service = CodeReviewService()


def verify_webhook_signature(payload_body: bytes, signature: str) -> bool:
    """
    Verify GitHub webhook signature.
    
    Args:
        payload_body: Raw request body
        signature: X-Hub-Signature-256 header value
        
    Returns:
        True if signature is valid, False otherwise
    """
    if not settings.github_webhook_secret:
        return True  # Skip verification if secret not configured
    
    if not signature:
        return False
    
    # Extract hash from signature (format: sha256=hash)
    try:
        hash_algorithm, signature_hash = signature.split('=')
    except ValueError:
        return False
    
    if hash_algorithm != 'sha256':
        return False
    
    # Compute expected signature
    secret = settings.github_webhook_secret.encode('utf-8')
    expected_hash = hmac.new(secret, payload_body, hashlib.sha256).hexdigest()
    
    # Compare signatures
    return hmac.compare_digest(expected_hash, signature_hash)


@router.post("/webhook", response_model=APIResponse)
async def github_webhook(request: Request):
    """
    Handle GitHub webhook events.
    
    Args:
        request: FastAPI request object
        
    Returns:
        APIResponse with processing status
    """
    # Get raw body for signature verification
    payload_body = await request.body()
    signature = request.headers.get('X-Hub-Signature-256', '')
    
    # Verify webhook signature
    if not verify_webhook_signature(payload_body, signature):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid webhook signature"
        )
    
    # Parse payload
    try:
        payload = await request.json()
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid JSON payload"
        )
    
    # Get event type
    event_type = request.headers.get('X-GitHub-Event', '')
    
    # Handle pull request events
    if event_type == 'pull_request':
        action = payload.get('action', '')
        
        # Only process 'opened' and 'synchronize' (new commits) actions
        if action in ['opened', 'synchronize']:
            pr = payload.get('pull_request', {})
            repo = payload.get('repository', {})
            
            # Create code review request
            review_request = CodeReviewRequest(
                repo_full_name=repo.get('full_name', ''),
                pr_number=pr.get('number', 0),
                commit_sha=pr.get('head', {}).get('sha', ''),
                student_id=pr.get('user', {}).get('login', 'unknown'),
                discipline='General'  # TODO: Extract from PR labels or description
            )
            
            # Create and analyze review
            response = await code_review_service.create_review(review_request)
            
            if response.success:
                # Trigger analysis in background
                await code_review_service.analyze_code(response.review_id)
                
                return APIResponse(
                    success=True,
                    message=f"Code review created: {response.review_id}"
                )
            else:
                return APIResponse(
                    success=False,
                    error=response.message
                )
    
    # For other events, just acknowledge receipt
    return APIResponse(
        success=True,
        message=f"Webhook received: {event_type}"
    )
