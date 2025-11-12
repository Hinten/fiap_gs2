"""Base agent interface for AI-powered content reviewers."""

from abc import ABC, abstractmethod
from typing import List, Optional

from google import genai
from google.genai import types

from content_reviewer_agent.config import settings
from content_reviewer_agent.models.ai_schema import AIReviewResponse
from content_reviewer_agent.models.content import (
    Content,
    IssueSeverity,
    IssueType,
    ReviewIssue,
)


class BaseAIAgent(ABC):
    """Base class for all AI-powered review agents."""

    def __init__(self, name: str, description: str, system_prompt: str):
        """Initialize the AI agent.

        Args:
            name: Name of the agent
            description: Description of what the agent does
            system_prompt: System prompt for the AI model
        """
        self.name = name
        self.description = description
        self.system_prompt = system_prompt

        # Initialize the Google AI client (can be None for testing)
        api_key = settings.google_api_key or "test-key"  # Use test key if None
        self.client = genai.Client(api_key=api_key)

    @abstractmethod
    def get_review_prompt(self, content: Content) -> str:
        """Generate the review prompt for the given content.

        Args:
            content: Content to review

        Returns:
            Prompt string for the AI model
        """
        pass

    async def review(self, content: Content) -> List[ReviewIssue]:
        """Review content using AI and return list of issues.

        Args:
            content: Content to review

        Returns:
            List of issues found
        """
        try:
            # Generate the full prompt
            user_prompt = self.get_review_prompt(content)
            full_prompt = f"{self.system_prompt}\n\n{user_prompt}"

            # Call the AI model with structured output
            response = self.client.models.generate_content(
                model=settings.google_model_name,
                contents=full_prompt,
                config=types.GenerateContentConfig(
                    temperature=settings.temperature,
                    max_output_tokens=settings.max_output_tokens,
                    response_mime_type="application/json",
                    response_schema=AIReviewResponse,
                ),
            )

            # Parse the response using Pydantic
            if response.text:
                print("AI model response received")
                review_response = AIReviewResponse.model_validate_json(response.text)
                issues = self.convert_ai_issues_to_review_issues(
                    review_response.issues, content
                )
                return issues
            else:
                print("Empty response from AI model")
                return []
        finally:
            print('Review completed by agent:', self.name)
        # except Exception as e:
        #     print(f"Error in {self.name}: {e}")
        #     return []

    def convert_ai_issues_to_review_issues(
        self, ai_issues: List, content: Content
    ) -> List[ReviewIssue]:
        """Convert AI response issues to ReviewIssue objects.

        Args:
            ai_issues: List of AIReviewIssue objects from AI
            content: Original content being reviewed

        Returns:
            List of ReviewIssue objects
        """
        issues = []

        for ai_issue in ai_issues:
            try:
                # Map AI response to our issue types
                issue_type_map = {
                    "spelling": IssueType.SPELLING,
                    "grammar": IssueType.GRAMMAR,
                    "syntax": IssueType.SYNTAX,
                    "comprehension": IssueType.COMPREHENSION,
                    "source": IssueType.SOURCE,
                    "outdated": IssueType.OUTDATED,
                    "deprecated": IssueType.DEPRECATED,
                }

                severity_map = {
                    "critical": IssueSeverity.CRITICAL,
                    "high": IssueSeverity.HIGH,
                    "medium": IssueSeverity.MEDIUM,
                    "low": IssueSeverity.LOW,
                }

                issue_type = issue_type_map.get(
                    ai_issue.type.lower(), IssueType.TECHNICAL
                )
                severity = severity_map.get(
                    ai_issue.severity.lower(), IssueSeverity.MEDIUM
                )

                issue = self.create_issue(
                    content=content,
                    issue_type=issue_type,
                    severity=severity,
                    description=ai_issue.description,
                    original_text=ai_issue.original_text,
                    suggested_fix=ai_issue.suggested_fix,
                    sources=ai_issue.sources or [],
                    confidence=ai_issue.confidence,
                )
                issues.append(issue)

            except (KeyError, ValueError, TypeError) as e:
                print(f"Error converting AI issue: {e}")
                continue

        return issues

    def create_issue(
        self,
        content: Content,
        issue_type: IssueType,
        severity: IssueSeverity,
        description: str,
        original_text: Optional[str] = None,
        suggested_fix: Optional[str] = None,
        location: Optional[str] = None,
        sources: Optional[List[str]] = None,
        confidence: float = 0.85,
    ) -> ReviewIssue:
        """Helper method to create a ReviewIssue.

        Args:
            content: Content being reviewed
            issue_type: Type of issue
            severity: Severity level
            description: Issue description
            original_text: Original problematic text
            suggested_fix: Suggested fix
            location: Location in content
            sources: Reference sources
            confidence: Confidence score (0-1)

        Returns:
            ReviewIssue object
        """
        return ReviewIssue(
            content_id=content.content_id,
            issue_type=issue_type,
            severity=severity,
            description=description,
            original_text=original_text,
            suggested_fix=suggested_fix,
            location=location,
            sources=sources or [],
            confidence=confidence,
        )

    def __repr__(self) -> str:
        """String representation of the agent."""
        return f"{self.__class__.__name__}(name='{self.name}')"
