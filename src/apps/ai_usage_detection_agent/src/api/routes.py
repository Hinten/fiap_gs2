"""API routes for AI usage detection."""

from fastapi import APIRouter, HTTPException, status
from typing import Dict

from ..models.schemas import (
    AnalysisRequest,
    AnalysisResponse,
    AIUsageAnalysis,
    GuidelinesResponse,
    UsageDeclaration
)
from ..services.detection_service import AIUsageDetectionService
from ..utils.logger import logger

router = APIRouter(prefix="/api/v1/ai-detection", tags=["ai-detection"])

# Initialize service
detection_service = AIUsageDetectionService()


@router.post("/analyze", response_model=AnalysisResponse)
async def analyze_submission(request: AnalysisRequest) -> AnalysisResponse:
    """
    Analyze a submission for AI usage.
    
    This endpoint analyzes text and/or code submissions to detect
    inappropriate use of AI tools while promoting ethical learning.
    
    Args:
        request: Analysis request with submission content
        
    Returns:
        Analysis result with AI usage score and recommendations
        
    Raises:
        HTTPException: If analysis fails
    """
    try:
        logger.info(
            "Received analysis request",
            extra={
                "submission_id": request.submission_id,
                "student_id": request.student_id
            }
        )
        
        analysis = detection_service.analyze_submission(request)
        
        return AnalysisResponse(success=True, data=analysis, error=None)
        
    except ValueError as e:
        logger.error(f"Validation error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Analysis failed: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Analysis failed. Please try again."
        )


@router.get("/report/{submission_id}", response_model=AnalysisResponse)
async def get_analysis_report(submission_id: str) -> AnalysisResponse:
    """
    Get detailed analysis report for a submission.
    
    Args:
        submission_id: Unique submission identifier
        
    Returns:
        Analysis report
        
    Note:
        This is a placeholder. In production, this would fetch from database.
    """
    # TODO: Implement database retrieval
    logger.info(f"Report requested for submission: {submission_id}")
    
    return AnalysisResponse(
        success=False,
        data=None,
        error="Report retrieval not yet implemented. Use /analyze endpoint."
    )


@router.get("/guidelines", response_model=GuidelinesResponse)
async def get_ai_usage_guidelines() -> GuidelinesResponse:
    """
    Get guidelines for ethical AI usage in academic work.
    
    Returns:
        Guidelines and policies for students and instructors
    """
    guidelines = {
        "title": "AI Usage Guidelines for Students",
        "version": "1.0",
        "categories": {
            "appropriate_usage": {
                "description": "Acceptable ways to use AI tools",
                "examples": [
                    "Using AI to understand complex concepts",
                    "Getting help with debugging errors",
                    "Asking for explanations of programming concepts",
                    "Using AI to improve code you wrote (with understanding)",
                    "Research and exploration of topics"
                ],
                "requirements": [
                    "Must understand all AI-assisted content",
                    "Should be able to explain your work",
                    "Declare AI usage when submitting"
                ]
            },
            "questionable_usage": {
                "description": "Usage that requires careful consideration",
                "examples": [
                    "Having AI generate significant portions of code",
                    "Using AI to write paragraphs without editing",
                    "Heavily relying on AI for problem-solving"
                ],
                "requirements": [
                    "Discuss with instructor first",
                    "Be prepared to demonstrate understanding",
                    "Must declare usage explicitly"
                ]
            },
            "inappropriate_usage": {
                "description": "Unacceptable use of AI tools",
                "examples": [
                    "Submitting AI-generated work as your own",
                    "Using AI to complete entire assignments",
                    "Copying AI output without understanding",
                    "Not declaring AI usage when required"
                ],
                "consequences": [
                    "First offense: Educational conversation, re-submission required",
                    "Second offense: Grade penalty, mandatory comprehension verification",
                    "Serious violations: Academic integrity review"
                ]
            }
        },
        "declaration_policy": {
            "required": True,
            "how_to_declare": "Check the AI usage box when submitting and describe how you used AI tools",
            "honesty_reward": "Students who honestly declare AI usage are treated more leniently"
        },
        "verification_process": {
            "when_required": "When AI usage score is high (>60%)",
            "what_to_expect": [
                "Answer questions about your submission",
                "Explain key concepts used in your work",
                "Demonstrate understanding through discussion"
            ],
            "purpose": "Ensure you learned from the assignment, not just got answers"
        }
    }
    
    return GuidelinesResponse(success=True, data=guidelines, error=None)


@router.post("/declare-usage")
async def declare_ai_usage(declaration: UsageDeclaration) -> Dict:
    """
    Allow students to declare their AI usage.
    
    Args:
        declaration: Student's declaration of AI usage
        
    Returns:
        Confirmation message
        
    Note:
        This is a placeholder. In production, this would save to database.
    """
    logger.info(
        "AI usage declaration received",
        extra={
            "submission_id": declaration.submission_id,
            "student_id": declaration.student_id,
            "declared_usage": declaration.declared_usage
        }
    )
    
    # TODO: Save to database
    
    return {
        "success": True,
        "message": "AI usage declaration recorded. Thank you for your honesty.",
        "data": {
            "submission_id": declaration.submission_id,
            "declared_at": declaration.declared_at.isoformat()
        }
    }


@router.get("/health")
async def health_check() -> Dict:
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": "ai-usage-detection-agent",
        "version": "1.0.0"
    }
