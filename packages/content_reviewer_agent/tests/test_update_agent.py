"""Tests for AI-powered content update agent."""

from unittest.mock import Mock, patch

import pytest

from content_reviewer_agent.agents.content_update import ContentUpdateAgent
from content_reviewer_agent.models.ai_schema import AIReviewIssue, AIReviewResponse
from content_reviewer_agent.models.content import Content, ContentType, IssueType


@pytest.mark.asyncio
async def test_update_deprecated_tech():
    """Test detection of deprecated technology."""
    agent = ContentUpdateAgent()
    content = Content(
        title="Test Content",
        text="Use Python 2.7 for this project.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(
        issues=[
            AIReviewIssue(
                type="deprecated",
                severity="high",
                description="Python 2.7 is deprecated",
                original_text="Python 2.7",
                suggested_fix="Python 3.11 or later",
                confidence=0.95,
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
async def test_update_current_content():
    """Test with current technology references."""
    agent = ContentUpdateAgent()
    content = Content(
        title="Test Content",
        text="Use Python 3.11 for modern development.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(issues=[])

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response_data.model_dump_json()
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) == 0
