"""Base agent interface for AI-powered content reviewers."""

import json
from abc import ABC, abstractmethod
from typing import List, Optional

import google.generativeai as genai

from content_reviewer_agent.config import settings
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

        # Configure Google AI
        if settings.google_api_key:
            genai.configure(api_key=settings.google_api_key)

        # Initialize the model
        self.model = genai.GenerativeModel(
            model_name=settings.google_model_name,
            generation_config={
                "temperature": settings.temperature,
                "max_output_tokens": settings.max_output_tokens,
            },
        )

    @abstractmethod
    def get_review_prompt(self, content: Content) -> str:
        """Generate the review prompt for the given content.

        Args:
            content: Content to review

        Returns:
            Prompt string for the AI model
        """
        pass

    @abstractmethod
    def parse_ai_response(
        self, response_text: str, content: Content
    ) -> List[ReviewIssue]:
        """Parse AI response into ReviewIssue objects.

        Args:
            response_text: Response from the AI model
            content: Original content being reviewed

        Returns:
            List of ReviewIssue objects
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

            # Call the AI model
            response = self.model.generate_content(full_prompt)

            # Parse the response
            if response.text:
                issues = self.parse_ai_response(response.text, content)
                return issues
            else:
                return []

        except Exception as e:
            print(f"Error in {self.name}: {e}")
            return []

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

    def parse_json_response(self, response_text: str) -> Optional[dict]:
        """Parse JSON response from AI, handling markdown code blocks.

        Args:
            response_text: Response text from AI

        Returns:
            Parsed JSON dict or None if parsing fails
        """
        try:
            # Remove markdown code blocks if present
            text = response_text.strip()
            if text.startswith("```json"):
                text = text[7:]
            elif text.startswith("```"):
                text = text[3:]
            if text.endswith("```"):
                text = text[:-3]

            text = text.strip()
            return json.loads(text)
        except json.JSONDecodeError:
            return None

    def __repr__(self) -> str:
        """String representation of the agent."""
        return f"{self.__class__.__name__}(name='{self.name}')"
