"""Source verification agent using Google AI."""

from content_reviewer_agent.agents.base_ai import BaseAIAgent
from content_reviewer_agent.models.content import Content


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

For each issue, provide the type as "source", severity level, description, original text, suggested fix (like "Add citation" or "Verify source"), and optionally suggest trusted sources in the "sources" field. Include confidence score."""

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

Identify claims, statistics, or statements that need citations or have questionable sources."""
