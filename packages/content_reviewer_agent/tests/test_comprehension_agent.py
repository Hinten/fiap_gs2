"""Tests for AI-powered comprehension agent."""

from unittest.mock import Mock, patch

import pytest

from content_reviewer_agent.agents.comprehension import ComprehensionAgent
from content_reviewer_agent.models.ai_schema import AIReviewIssue, AIReviewResponse
from content_reviewer_agent.models.content import Content, ContentType, IssueType


@pytest.mark.asyncio
async def test_comprehension_complex_words():
    """Test detection of complex words."""
    agent = ComprehensionAgent()
    content = Content(
        title="Test Content",
        text="We must utilize this methodology.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(
        issues=[
            AIReviewIssue(
                type="comprehension",
                severity="low",
                description="Complex word can be simplified",
                original_text="utilize",
                suggested_fix="use",
                confidence=0.85,
            )
        ]
    )

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response_data.model_dump_json()
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) >= 1


@pytest.mark.asyncio
async def test_comprehension_simple_content():
    """Test with simple, clear content."""
    agent = ComprehensionAgent()
    content = Content(
        title="Test Content",
        text="Python is easy to learn.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(issues=[])

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response_data.model_dump_json()
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) == 0
