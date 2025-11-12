"""Comprehension agent using Google AI for readability analysis."""

from content_reviewer_agent.agents.base_ai import BaseAIAgent
from content_reviewer_agent.models.content import Content


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

For each issue, provide the type as "comprehension", severity level, description, original text, suggested fix, and confidence score."""

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

Identify areas where the content could be clearer or easier to understand."""
