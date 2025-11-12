"""Error detection agent using Google AI for spelling, grammar, and syntax checking."""

from content_reviewer_agent.agents.base_ai import BaseAIAgent
from content_reviewer_agent.models.content import Content


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

Identify all errors and provide them in a structured format."""
