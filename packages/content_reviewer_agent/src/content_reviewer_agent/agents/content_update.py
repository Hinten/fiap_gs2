"""Content update agent using Google AI for detecting outdated information."""

from content_reviewer_agent.agents.base_ai import BaseAIAgent
from content_reviewer_agent.models.content import Content


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

For each issue, provide the type as "outdated" or "deprecated", severity level, description of what is outdated/deprecated, original text, suggested fix with current alternative, and confidence score. Current year is 2025."""

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

Identify any references to outdated technologies, deprecated APIs, old versions, or information that should be updated for 2025."""
