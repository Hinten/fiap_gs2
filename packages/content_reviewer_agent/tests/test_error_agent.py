"""Tests for AI-powered error detection agent."""

from unittest.mock import Mock, patch

import pytest

from content_reviewer_agent.agents.error_detection import ErrorDetectionAgent
from content_reviewer_agent.models.ai_schema import AIReviewIssue, AIReviewResponse
from content_reviewer_agent.models.content import Content, ContentType, IssueType


@pytest.mark.asyncio
async def test_error_agent_spelling():
    """Test spelling error detection with AI."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="I recieve emails regularly.",
        content_type=ContentType.TEXT,
    )

    # Mock AI response with Pydantic models
    mock_response_data = AIReviewResponse(
        issues=[
            AIReviewIssue(
                type="spelling",
                severity="low",
                description="Spelling error: 'recieve' should be 'receive'",
                original_text="recieve",
                suggested_fix="receive",
                confidence=0.95,
            )
        ]
    )

    # Mock the client's generate_content method
    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_response = Mock()
        mock_response.text = mock_response_data.model_dump_json()
        mock_generate.return_value = mock_response

        issues = await agent.review(content)

        # Should find spelling errors
        assert len(issues) >= 1
        spelling_issues = [i for i in issues if i.issue_type == IssueType.SPELLING]
        assert len(spelling_issues) >= 1


@pytest.mark.asyncio
async def test_error_agent_grammar():
    """Test grammar error detection with AI."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="This is a example.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(
        issues=[
            AIReviewIssue(
                type="grammar",
                severity="medium",
                description="Article usage error",
                original_text="a example",
                suggested_fix="an example",
                confidence=0.90,
            )
        ]
    )

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_response = Mock()
        mock_response.text = mock_response_data.model_dump_json()
        mock_generate.return_value = mock_response

        issues = await agent.review(content)
        grammar_issues = [i for i in issues if i.issue_type == IssueType.GRAMMAR]
        assert len(grammar_issues) >= 1


@pytest.mark.asyncio
async def test_error_agent_clean_content():
    """Test with clean content."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="This is well-written content.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(issues=[])

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_response = Mock()
        mock_response.text = mock_response_data.model_dump_json()
        mock_generate.return_value = mock_response

        issues = await agent.review(content)
        assert len(issues) == 0


@pytest.mark.asyncio
async def test_error_agent_syntax():
    """Test syntax error detection."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="def example()\n    print('missing colon')",
        content_type=ContentType.CODE,
    )

    mock_response_data = AIReviewResponse(
        issues=[
            AIReviewIssue(
                type="syntax",
                severity="high",
                description="Missing colon",
                original_text="def example()",
                suggested_fix="def example():",
                confidence=0.95,
            )
        ]
    )

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_response = Mock()
        mock_response.text = mock_response_data.model_dump_json()
        mock_generate.return_value = mock_response

        issues = await agent.review(content)
        syntax_issues = [i for i in issues if i.issue_type == IssueType.SYNTAX]
        assert len(syntax_issues) >= 1
