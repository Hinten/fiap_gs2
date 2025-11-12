"""Tests for AI-powered source verification agent."""

from unittest.mock import Mock, patch

import pytest

from content_reviewer_agent.agents.source_verification import SourceVerificationAgent
from content_reviewer_agent.models.ai_schema import AIReviewIssue, AIReviewResponse
from content_reviewer_agent.models.content import Content, ContentType, IssueType


@pytest.mark.asyncio
async def test_source_missing_citation():
    """Test detection of missing citations."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text="Research shows that 80% of users prefer this.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(
        issues=[
            AIReviewIssue(
                type="source",
                severity="medium",
                description="Statistical claim requires citation",
                original_text="Research shows that 80% of users",
                suggested_fix="Add citation for research",
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
async def test_source_with_proper_citations():
    """Test content with proper citations."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text="According to Smith (2024), the approach works.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(issues=[])

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response_data.model_dump_json()
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) == 0
