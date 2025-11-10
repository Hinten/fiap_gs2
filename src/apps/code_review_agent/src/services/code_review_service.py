"""Main service for code review orchestration."""

import uuid
from typing import Optional

from ..models import (
    CodeReview,
    CodeReviewRequest,
    CodeReviewResponse,
    ReviewStatus,
    AnalysisResults,
)
from ..repositories.code_review_repository import CodeReviewRepository
from .github_service import GitHubService
from .code_analysis_service import CodeAnalysisService
from .ai_feedback_service import AIFeedbackService


class CodeReviewService:
    """Main service for orchestrating code reviews."""
    
    def __init__(self):
        """Initialize code review service with dependencies."""
        self.repository = CodeReviewRepository()
        self.github_service = GitHubService()
        self.analysis_service = CodeAnalysisService()
        self.ai_service = AIFeedbackService()
    
    async def create_review(
        self, 
        request: CodeReviewRequest
    ) -> CodeReviewResponse:
        """
        Create a new code review.
        
        Args:
            request: Code review request with repo and PR details
            
        Returns:
            CodeReviewResponse with review ID and status
        """
        try:
            # Generate review ID
            review_id = str(uuid.uuid4())
            
            # Get commit SHA if not provided
            commit_sha = request.commit_sha
            if not commit_sha and request.pr_number:
                pr = self.github_service.get_pull_request(
                    request.repo_full_name,
                    request.pr_number
                )
                commit_sha = pr.head.sha
            
            if not commit_sha:
                raise ValueError("Either pr_number or commit_sha must be provided")
            
            # Create initial review record
            review = CodeReview(
                review_id=review_id,
                repo_full_name=request.repo_full_name,
                pr_number=request.pr_number,
                commit_sha=commit_sha,
                student_id=request.student_id,
                discipline=request.discipline,
                status=ReviewStatus.PENDING
            )
            
            await self.repository.create(review)
            
            return CodeReviewResponse(
                success=True,
                review_id=review_id,
                status=ReviewStatus.PENDING,
                message="Code review created successfully"
            )
            
        except Exception as e:
            return CodeReviewResponse(
                success=False,
                review_id="",
                status=ReviewStatus.PENDING,
                message=f"Failed to create review: {str(e)}"
            )
    
    async def analyze_code(self, review_id: str) -> bool:
        """
        Perform code analysis for a review.
        
        Args:
            review_id: ID of the review to analyze
            
        Returns:
            True if analysis succeeded, False otherwise
        """
        try:
            # Get review from database
            review = await self.repository.get(review_id)
            if not review:
                raise ValueError(f"Review {review_id} not found")
            
            # Get files from PR
            files_info = []
            if review.pr_number:
                pr_files = self.github_service.get_pr_files(
                    review.repo_full_name,
                    review.pr_number
                )
                
                # Get file contents
                for file_info in pr_files:
                    if file_info['status'] == 'removed':
                        continue
                    
                    try:
                        content = self.github_service.get_file_content(
                            review.repo_full_name,
                            file_info['filename'],
                            ref=review.commit_sha
                        )
                        files_info.append({
                            'filename': file_info['filename'],
                            'content': content
                        })
                    except Exception:
                        # Skip files that can't be read
                        continue
            
            # Perform static analysis
            analysis_results = self.analysis_service.analyze_code(
                files_info,
                language="python"  # TODO: Detect language automatically
            )
            
            # Generate AI feedback
            combined_code = "\n\n".join(
                f"# File: {f['filename']}\n{f['content']}" 
                for f in files_info[:3]  # Limit to first 3 files
            )
            
            ai_feedback = self.ai_service.generate_feedback(
                code_content=combined_code,
                analysis_results=analysis_results,
                discipline=review.discipline
            )
            
            # Update review with results
            review.analysis_results = analysis_results
            review.ai_feedback = ai_feedback
            await self.repository.update(review)
            
            return True
            
        except Exception as e:
            print(f"Error analyzing code: {e}")
            return False
    
    async def approve_review(
        self,
        review_id: str,
        professor_edits: Optional[str] = None,
        post_to_github: bool = True
    ) -> bool:
        """
        Approve a code review and optionally post to GitHub.
        
        Args:
            review_id: ID of the review to approve
            professor_edits: Optional edits from professor
            post_to_github: Whether to post feedback to GitHub
            
        Returns:
            True if approval succeeded, False otherwise
        """
        try:
            # Get review from database
            review = await self.repository.get(review_id)
            if not review:
                raise ValueError(f"Review {review_id} not found")
            
            # Update review status
            review.status = ReviewStatus.APPROVED
            if professor_edits:
                review.professor_edits = professor_edits
            
            # Post to GitHub if requested
            if post_to_github and review.pr_number:
                feedback = professor_edits or review.ai_feedback or "Code review completed."
                
                self.github_service.post_pr_comment(
                    review.repo_full_name,
                    review.pr_number,
                    feedback
                )
                
                review.status = ReviewStatus.POSTED
            
            # Update review in database
            from datetime import datetime
            review.approved_at = datetime.utcnow()
            await self.repository.update(review)
            
            return True
            
        except Exception as e:
            print(f"Error approving review: {e}")
            return False
    
    async def get_review(self, review_id: str) -> Optional[CodeReview]:
        """
        Get a code review by ID.
        
        Args:
            review_id: ID of the review
            
        Returns:
            CodeReview object if found, None otherwise
        """
        return await self.repository.get(review_id)
    
    async def list_pending_reviews(self) -> list[CodeReview]:
        """
        List all pending code reviews.
        
        Returns:
            List of pending CodeReview objects
        """
        return await self.repository.list_pending()
