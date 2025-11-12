"""Tests for AI-powered error detection agent."""

from unittest.mock import Mock, patch

import pytest

from content_reviewer_agent.agents.error_detection import ErrorDetectionAgent
from content_reviewer_agent.models.content import (
    Content,
    ContentType,
    IssueSeverity,
    IssueType,
)


@pytest.fixture
def mock_ai_response_spelling():
    """Mock AI response for spelling errors."""
    return """```json
[
    {
        "type": "spelling",
        "severity": "low",
        "description": "Spelling error: 'recieve' should be 'receive'",
        "original_text": "recieve",
        "suggested_fix": "receive",
        "confidence": 0.95
    },
    {
        "type": "spelling",
        "severity": "low",
        "description": "Spelling error: 'occured' should be 'occurred'",
        "original_text": "occured",
        "suggested_fix": "occurred",
        "confidence": 0.95
    },
    {
        "type": "spelling",
        "severity": "low",
        "description": "Spelling error: 'seperate' should be 'separate'",
        "original_text": "seperate",
        "suggested_fix": "separate",
        "confidence": 0.95
    }
]
```"""


@pytest.fixture
def mock_ai_response_grammar():
    """Mock AI response for grammar errors."""
    return """```json
[
    {
        "type": "grammar",
        "severity": "medium",
        "description": "Article usage: Use 'an' before words starting with vowel sounds",
        "original_text": "a example",
        "suggested_fix": "an example",
        "confidence": 0.90
    }
]
```"""


@pytest.mark.asyncio
async def test_error_agent_spelling(mock_ai_response_spelling):
    """Test spelling error detection with AI."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="I recieve emails regularly and occured issues with seperate accounts.",
        content_type=ContentType.TEXT,
    )

    # Mock the AI model response
    with patch.object(agent.model, "generate_content") as mock_generate:
        mock_response = Mock()
        mock_response.text = mock_ai_response_spelling
        mock_generate.return_value = mock_response

        issues = await agent.review(content)

        # Should find spelling errors
        assert len(issues) >= 3
        spelling_issues = [i for i in issues if i.issue_type == IssueType.SPELLING]
        assert len(spelling_issues) >= 3


@pytest.mark.asyncio
async def test_error_agent_grammar(mock_ai_response_grammar):
    """Test grammar error detection with AI."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="This is a example of incorrect grammar.",
        content_type=ContentType.TEXT,
    )

    # Mock the AI model response
    with patch.object(agent.model, "generate_content") as mock_generate:
        mock_response = Mock()
        mock_response.text = mock_ai_response_grammar
        mock_generate.return_value = mock_response

        issues = await agent.review(content)

        # Should find grammar issues
        grammar_issues = [i for i in issues if i.issue_type == IssueType.GRAMMAR]
        assert len(grammar_issues) >= 1


@pytest.mark.asyncio
async def test_error_agent_clean_content():
    """Test with clean content."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="This is well-written content with proper grammar and spelling.",
        content_type=ContentType.TEXT,
    )

    # Mock empty response
    with patch.object(agent.model, "generate_content") as mock_generate:
        mock_response = Mock()
        mock_response.text = "```json\n[]\n```"
        mock_generate.return_value = mock_response

        issues = await agent.review(content)
        assert len(issues) == 0


@pytest.mark.asyncio
async def test_error_agent_code_syntax():
    """Test syntax error detection in code."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="def example()\n    print('missing colon')",
        content_type=ContentType.CODE,
    )

    mock_syntax_response = """```json
[
    {
        "type": "syntax",
        "severity": "high",
        "description": "Missing colon after function definition",
        "original_text": "def example()",
        "suggested_fix": "def example():",
        "confidence": 0.95
    }
]
```"""

    with patch.object(agent.model, "generate_content") as mock_generate:
        mock_response = Mock()
        mock_response.text = mock_syntax_response
        mock_generate.return_value = mock_response

        issues = await agent.review(content)
        syntax_issues = [i for i in issues if i.issue_type == IssueType.SYNTAX]
        assert len(syntax_issues) >= 1
