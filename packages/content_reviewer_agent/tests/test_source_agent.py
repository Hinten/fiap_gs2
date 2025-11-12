"""Tests for AI-powered source verification agent."""

from unittest.mock import Mock, patch

import pytest

from content_reviewer_agent.agents.source_verification import SourceVerificationAgent
from content_reviewer_agent.models.content import Content, ContentType, IssueType


@pytest.mark.asyncio
async def test_source_trusted_urls():
    """Test validation of trusted source URLs."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text="Research shows that 80% of users prefer the new design.",
        content_type=ContentType.TEXT,
    )

    mock_response = """```json
[
    {
        "type": "source",
        "severity": "medium",
        "description": "Statistical claim requires citation",
        "original_text": "Research shows that 80% of users prefer the new design",
        "suggested_fix": "Add citation for research source",
        "sources": ["academic journals", "research databases"],
        "confidence": 0.85
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
async def test_source_untrusted_urls():
    """Test detection of potentially untrusted sources."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text="According to random blog, this is the best approach.",
        content_type=ContentType.TEXT,
    )

    mock_response = """```json
[
    {
        "type": "source",
        "severity": "high",
        "description": "Unreliable source cited",
        "original_text": "According to random blog",
        "suggested_fix": "Replace with credible source",
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
async def test_source_missing_citations():
    """Test detection of missing citations."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text='"This is a quote without attribution"',
        content_type=ContentType.TEXT,
    )

    mock_response = """```json
[
    {
        "type": "source",
        "severity": "high",
        "description": "Quote without attribution",
        "original_text": "This is a quote without attribution",
        "suggested_fix": "Add source attribution",
        "confidence": 0.95
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
async def test_source_claims_without_sources():
    """Test claims requiring sources."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text="Studies have proven that this method is superior.",
        content_type=ContentType.TEXT,
    )

    mock_response = """```json
[
    {
        "type": "source",
        "severity": "medium",
        "description": "Claim requires supporting sources",
        "original_text": "Studies have proven",
        "suggested_fix": "Cite specific studies",
        "confidence": 0.80
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
async def test_source_with_proper_citations():
    """Test content with proper citations."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text="According to Smith et al. (2024), the new approach improves performance.",
        content_type=ContentType.TEXT,
    )

    mock_response = "```json\n[]\n```"

    with patch.object(agent.model, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) == 0
