"""Tests for AI-powered comprehension agent."""

from unittest.mock import Mock, patch

import pytest

from content_reviewer_agent.agents.comprehension import ComprehensionAgent
from content_reviewer_agent.models.content import Content, ContentType, IssueType


@pytest.mark.asyncio
async def test_comprehension_complex_words():
    """Test detection of complex words."""
    agent = ComprehensionAgent()
    content = Content(
        title="Test Content",
        text="We must utilize this methodology to facilitate the implementation process.",
        content_type=ContentType.TEXT,
    )

    mock_response = """```json
[
    {
        "type": "comprehension",
        "severity": "low",
        "description": "Complex word 'utilize' can be simplified",
        "original_text": "utilize",
        "suggested_fix": "use",
        "confidence": 0.85
    },
    {
        "type": "comprehension",
        "severity": "low",
        "description": "Complex word 'facilitate' can be simplified",
        "original_text": "facilitate",
        "suggested_fix": "help with",
        "confidence": 0.80
    }
]
```"""

    with patch.object(agent.model, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) >= 2


@pytest.mark.asyncio
async def test_comprehension_long_sentences():
    """Test detection of long sentences."""
    agent = ComprehensionAgent()
    content = Content(
        title="Test Content",
        text="This is a very long sentence that contains many clauses and continues on and on without proper breaks which makes it quite difficult for readers to follow and understand the main point being communicated.",
        content_type=ContentType.TEXT,
    )

    mock_response = """```json
[
    {
        "type": "comprehension",
        "severity": "medium",
        "description": "Sentence is too long and complex",
        "original_text": "This is a very long sentence...",
        "suggested_fix": "Break into multiple sentences",
        "confidence": 0.90
    }
]
```"""

    with patch.object(agent.model, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) >= 1


@pytest.mark.asyncio
async def test_comprehension_passive_voice():
    """Test passive voice detection."""
    agent = ComprehensionAgent()
    content = Content(
        title="Test Content",
        text="The code was tested thoroughly.",
        content_type=ContentType.TEXT,
    )

    mock_response = """```json
[
    {
        "type": "comprehension",
        "severity": "low",
        "description": "Passive voice - could be more direct",
        "original_text": "The code was tested",
        "suggested_fix": "We tested the code",
        "confidence": 0.75
    }
]
```"""

    with patch.object(agent.model, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert isinstance(issues, list)


@pytest.mark.asyncio
async def test_comprehension_simple_content():
    """Test with simple, clear content."""
    agent = ComprehensionAgent()
    content = Content(
        title="Test Content",
        text="Python is easy to learn. It has clear syntax. Many people use it.",
        content_type=ContentType.TEXT,
    )

    mock_response = "```json\n[]\n```"

    with patch.object(agent.model, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) == 0
