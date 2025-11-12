"""Error detection agent using Google AI for spelling, grammar, and syntax checking."""

from typing import List

from content_reviewer_agent.agents.base_ai import BaseAIAgent
from content_reviewer_agent.models.content import (
    Content,
    IssueSeverity,
    IssueType,
    ReviewIssue,
)


class ErrorDetectionAgent(BaseAIAgent):
    """Agent that detects errors in content using AI (spelling, grammar, syntax)."""

    SYSTEM_PROMPT = """You are an expert editor and proofreader. Your task is to identify spelling errors, grammar mistakes, and syntax issues in educational content.

For each issue you find, provide:
1. The type of error (spelling, grammar, or syntax)
2. The severity (critical, high, medium, low)
3. A clear description of the problem
4. The original problematic text
5. A suggested fix
6. Your confidence level (0.0 to 1.0)

Return your findings as a JSON array of issues. Each issue should have this structure:
{
    "type": "spelling|grammar|syntax",
    "severity": "critical|high|medium|low",
    "description": "Clear description of the issue",
    "original_text": "The problematic text",
    "suggested_fix": "The corrected version",
    "confidence": 0.95
}

Be thorough but focus on genuine errors that affect readability and correctness."""

    def __init__(self):
        """Initialize the error detection agent."""
        super().__init__(
            name="Error Detection Agent",
            description="Detects spelling, grammar, and syntax errors using AI",
            system_prompt=self.SYSTEM_PROMPT,
        )

    def get_review_prompt(self, content: Content) -> str:
        """Generate the review prompt for error detection.

        Args:
            content: Content to review

        Returns:
            Prompt string for the AI model
        """
        return f"""Please review the following content for spelling, grammar, and syntax errors:

Title: {content.title}
Content Type: {content.content_type.value}
Text:
{content.text}

Identify all errors and return them as a JSON array."""

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
                    "spelling": IssueType.SPELLING,
                    "grammar": IssueType.GRAMMAR,
                    "syntax": IssueType.SYNTAX,
                }

                severity_map = {
                    "critical": IssueSeverity.CRITICAL,
                    "high": IssueSeverity.HIGH,
                    "medium": IssueSeverity.MEDIUM,
                    "low": IssueSeverity.LOW,
                }

                issue_type = issue_type_map.get(
                    item.get("type", "").lower(), IssueType.TECHNICAL
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
                    confidence=float(item.get("confidence", 0.85)),
                )
                issues.append(issue)

            except (KeyError, ValueError, TypeError) as e:
                print(f"Error parsing issue item: {e}")
                continue

        return issues
