"""Content update agent using Google AI for detecting outdated information."""

from typing import List

from content_reviewer_agent.agents.base_ai import BaseAIAgent
from content_reviewer_agent.models.content import (
    Content,
    IssueSeverity,
    IssueType,
    ReviewIssue,
)


class ContentUpdateAgent(BaseAIAgent):
    """Agent that detects outdated or deprecated content using AI."""

    SYSTEM_PROMPT = """You are an expert technology analyst and educator. Your task is to identify outdated, deprecated, or obsolete information in educational content.

Focus on:
1. References to deprecated technologies or obsolete software versions
2. Outdated best practices or methodologies
3. Old statistics or data that should be updated
4. References to discontinued products or services
5. Outdated API references or programming patterns
6. Old URLs or broken links
7. Information that contradicts current standards

For each issue, provide:
{
    "type": "outdated|deprecated",
    "severity": "critical|high|medium|low",
    "description": "Description of what is outdated/deprecated",
    "original_text": "The outdated content",
    "suggested_fix": "Current alternative or update",
    "confidence": 0.85
}

Return a JSON array of issues. Current year is 2025. Be specific about why something is outdated and what the current alternative is."""

    def __init__(self):
        """Initialize the content update agent."""
        super().__init__(
            name="Content Update Agent",
            description="Detects outdated technology references and deprecated APIs",
            system_prompt=self.SYSTEM_PROMPT,
        )

    def get_review_prompt(self, content: Content) -> str:
        """Generate the review prompt for content update check.

        Args:
            content: Content to review

        Returns:
            Prompt string for the AI model
        """
        return f"""Please analyze the following content for outdated or deprecated information:

Title: {content.title}
Content Type: {content.content_type.value}
{f"Discipline: {content.discipline}" if content.discipline else ""}
Text:
{content.text}

Identify any references to outdated technologies, deprecated APIs, old versions, or information that should be updated for 2025. Return your findings as a JSON array."""

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
                # Map AI response to our issue types
                issue_type_map = {
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
                    item.get("type", "").lower(), IssueType.OUTDATED
                )
                severity = severity_map.get(
                    item.get("severity", "").lower(), IssueSeverity.MEDIUM
                )

                issue = self.create_issue(
                    content=content,
                    issue_type=issue_type,
                    severity=severity,
                    description=item.get("description", ""),
                    original_text=item.get("original_text"),
                    suggested_fix=item.get("suggested_fix"),
                    confidence=float(item.get("confidence", 0.80)),
                )
                issues.append(issue)

            except (KeyError, ValueError, TypeError) as e:
                print(f"Error parsing update issue: {e}")
                continue

        return issues
