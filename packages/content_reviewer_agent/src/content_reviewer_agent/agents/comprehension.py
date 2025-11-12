"""Comprehension agent using Google AI for readability analysis."""

from typing import List

from content_reviewer_agent.agents.base_ai import BaseAIAgent
from content_reviewer_agent.models.content import (
    Content,
    IssueSeverity,
    IssueType,
    ReviewIssue,
)


class ComprehensionAgent(BaseAIAgent):
    """Agent that analyzes content comprehension using AI."""

    SYSTEM_PROMPT = """You are an expert in educational content design and readability. Your task is to analyze content for comprehension issues and suggest improvements.

Focus on:
1. Overly complex vocabulary that could be simplified
2. Long, convoluted sentences that could be broken up
3. Dense paragraphs that need better structure
4. Passive voice that could be made more direct
5. Technical jargon without explanation
6. Unclear explanations or logical flow

For each issue, provide:
{
    "type": "comprehension",
    "severity": "critical|high|medium|low",
    "description": "Clear description of the comprehension issue",
    "original_text": "The problematic text segment",
    "suggested_fix": "A clearer alternative",
    "confidence": 0.85
}

Return a JSON array of issues. Focus on changes that genuinely improve clarity and understanding."""

    def __init__(self):
        """Initialize the comprehension agent."""
        super().__init__(
            name="Comprehension Improvement Agent",
            description="Analyzes content clarity and suggests improvements for easier understanding",
            system_prompt=self.SYSTEM_PROMPT,
        )

    def get_review_prompt(self, content: Content) -> str:
        """Generate the review prompt for comprehension analysis.

        Args:
            content: Content to review

        Returns:
            Prompt string for the AI model
        """
        return f"""Please analyze the following content for comprehension and readability issues:

Title: {content.title}
Content Type: {content.content_type.value}
{f"Discipline: {content.discipline}" if content.discipline else ""}
Text:
{content.text}

Identify areas where the content could be clearer or easier to understand. Return your findings as a JSON array."""

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
        issues = []

        # Parse JSON response
        parsed = self.parse_json_response(response_text)
        if not parsed:
            return issues

        # Handle both single dict and list of dicts
        issue_list = parsed if isinstance(parsed, list) else [parsed]

        for item in issue_list:
            try:
                severity_map = {
                    "critical": IssueSeverity.CRITICAL,
                    "high": IssueSeverity.HIGH,
                    "medium": IssueSeverity.MEDIUM,
                    "low": IssueSeverity.LOW,
                }

                severity = severity_map.get(
                    item.get("severity", "").lower(), IssueSeverity.MEDIUM
                )

                issue = self.create_issue(
                    content=content,
                    issue_type=IssueType.COMPREHENSION,
                    severity=severity,
                    description=item.get("description", ""),
                    original_text=item.get("original_text"),
                    suggested_fix=item.get("suggested_fix"),
                    confidence=float(item.get("confidence", 0.80)),
                )
                issues.append(issue)

            except (KeyError, ValueError, TypeError) as e:
                print(f"Error parsing comprehension issue: {e}")
                continue

        return issues
