"""Source verification agent using Google AI."""

from typing import List

from content_reviewer_agent.agents.base_ai import BaseAIAgent
from content_reviewer_agent.models.content import (
    Content,
    IssueSeverity,
    IssueType,
    ReviewIssue,
)


class SourceVerificationAgent(BaseAIAgent):
    """Agent that verifies sources and references using AI."""

    SYSTEM_PROMPT = """You are an expert fact-checker and academic research assistant. Your task is to analyze educational content for source verification issues.

Focus on:
1. Claims that require citations but lack them
2. Quoted material without attribution
3. Statistics or data without source references
4. Potentially unreliable or unverified sources
5. Missing references for factual statements
6. Outdated or broken reference links

For each issue, provide:
{
    "type": "source",
    "severity": "critical|high|medium|low",
    "description": "Description of the source issue",
    "original_text": "The text that needs citation/verification",
    "suggested_fix": "Suggestion for improvement (e.g., 'Add citation', 'Verify source')",
    "sources": ["Suggested trusted sources if applicable"],
    "confidence": 0.85
}

Return a JSON array of issues. Be thorough but reasonable - not every statement needs a citation."""

    def __init__(self):
        """Initialize the source verification agent."""
        super().__init__(
            name="Source Verification Agent",
            description="Verifies sources, citations, and references in content",
            system_prompt=self.SYSTEM_PROMPT,
        )

    def get_review_prompt(self, content: Content) -> str:
        """Generate the review prompt for source verification.

        Args:
            content: Content to review

        Returns:
            Prompt string for the AI model
        """
        return f"""Please analyze the following content for source verification issues:

Title: {content.title}
Content Type: {content.content_type.value}
{f"Discipline: {content.discipline}" if content.discipline else ""}
Text:
{content.text}

Identify claims, statistics, or statements that need citations or have questionable sources. Return your findings as a JSON array."""

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

                sources = item.get("sources", [])
                if isinstance(sources, str):
                    sources = [sources]

                issue = self.create_issue(
                    content=content,
                    issue_type=IssueType.SOURCE,
                    severity=severity,
                    description=item.get("description", ""),
                    original_text=item.get("original_text"),
                    suggested_fix=item.get("suggested_fix"),
                    sources=sources,
                    confidence=float(item.get("confidence", 0.75)),
                )
                issues.append(issue)

            except (KeyError, ValueError, TypeError) as e:
                print(f"Error parsing source issue: {e}")
                continue

        return issues
