"""API routes for plagiarism detection."""

from typing import List, Optional
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel

from ..models import PlagiarismReport, APIResponse
from ..services.plagiarism_detection_service import PlagiarismDetectionService
from ..services.github_service import GitHubService

router = APIRouter()
plagiarism_service = PlagiarismDetectionService()
github_service = GitHubService()


class PlagiarismCheckRequest(BaseModel):
    """Request to check plagiarism for a repository."""
    repo_full_name: str
    file_path: Optional[str] = None
    compare_with: Optional[List[str]] = None  # List of repo names to compare


class BatchPlagiarismCheckRequest(BaseModel):
    """Request to check plagiarism across multiple submissions."""
    repos: List[str]  # List of repo full names


@router.post("/check", response_model=PlagiarismReport)
async def check_plagiarism(request: PlagiarismCheckRequest):
    """
    Check a repository for plagiarism.
    
    Args:
        request: Plagiarism check request
        
    Returns:
        PlagiarismReport with findings
    """
    try:
        # Get code from repository
        if request.file_path:
            code_content = github_service.get_file_content(
                request.repo_full_name,
                request.file_path
            )
        else:
            # Get all Python files from repo (simplified)
            # In production, this should be more sophisticated
            code_content = ""
        
        # Get comparison repositories if specified
        comparison_repos = []
        if request.compare_with:
            for repo_name in request.compare_with:
                try:
                    # Get code from comparison repo
                    # Simplified - in production, get specific files
                    comparison_repos.append({
                        'name': repo_name,
                        'file': 'main.py',
                        'content': ''  # Would fetch actual content
                    })
                except Exception:
                    continue
        
        # Perform plagiarism check
        report = plagiarism_service.check_plagiarism(
            code_content=code_content,
            repo_name=request.repo_full_name,
            comparison_repos=comparison_repos if comparison_repos else None
        )
        
        return report
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to check plagiarism: {str(e)}"
        )


@router.post("/batch-check", response_model=List[PlagiarismReport])
async def batch_check_plagiarism(request: BatchPlagiarismCheckRequest):
    """
    Check multiple repositories for plagiarism against each other.
    
    Args:
        request: Batch check request with list of repos
        
    Returns:
        List of PlagiarismReport objects for suspicious pairs
    """
    try:
        submissions = []
        
        # Fetch code from all repositories
        for repo_name in request.repos:
            try:
                # Simplified - fetch main Python file
                # In production, fetch all relevant files
                content = ""  # Would fetch actual content from repo
                
                submissions.append({
                    'repo': repo_name,
                    'content': content
                })
            except Exception:
                continue
        
        if len(submissions) < 2:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Need at least 2 valid repositories to compare"
            )
        
        # Perform batch plagiarism check
        reports = plagiarism_service.batch_check_submissions(submissions)
        
        return reports
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to perform batch check: {str(e)}"
        )


@router.get("/report/{report_id}", response_model=PlagiarismReport)
async def get_plagiarism_report(report_id: str):
    """
    Get a specific plagiarism report.
    
    Args:
        report_id: Unique identifier of the report
        
    Returns:
        PlagiarismReport object
    """
    # TODO: Implement repository layer for plagiarism reports
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Report retrieval not yet implemented"
    )
