"""Tests for AI-powered content update agent."""

from unittest.mock import Mock, patch

import pytest

from content_reviewer_agent.agents.content_update import ContentUpdateAgent
from content_reviewer_agent.models.content import Content, ContentType, IssueType


@pytest.mark.asyncio
async def test_update_deprecated_tech():
    """Test detection of deprecated technology."""
    agent = ContentUpdateAgent()
    content = Content(
        title="Test Content",
        text="Use Python 2.7 for this project and install jQuery for the frontend.",
        content_type=ContentType.TEXT,
    )

    mock_response = """```json
[
    {
        "type": "deprecated",
        "severity": "high",
        "description": "Python 2.7 is deprecated and no longer supported",
        "original_text": "Python 2.7",
        "suggested_fix": "Python 3.11 or later",
        "confidence": 0.95
    },
    {
        "type": "outdated",
        "severity": "medium",
        "description": "jQuery is largely replaced by modern frameworks",
        "original_text": "jQuery",
        "suggested_fix": "Consider modern alternatives like React or Vue",
        "confidence": 0.85
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
async def test_update_old_versions():
    """Test old version detection."""
    agent = ContentUpdateAgent()
    content = Content(
        title="Test Content",
        text="Install Node.js 8.x and use AngularJS for the project.",
        content_type=ContentType.TEXT,
    )

    mock_response = """```json
[
    {
        "type": "outdated",
        "severity": "high",
        "description": "Node.js 8.x is outdated and unsupported",
        "original_text": "Node.js 8.x",
        "suggested_fix": "Node.js 20.x LTS",
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
async def test_update_outdated_dates():
    """Test outdated date detection."""
    agent = ContentUpdateAgent()
    content = Content(
        title="Test Content",
        text="According to 2010 statistics, the usage rate was 30%.",
        content_type=ContentType.TEXT,
    )

    mock_response = """```json
[
    {
        "type": "outdated",
        "severity": "medium",
        "description": "Statistics from 2010 are 15 years old",
        "original_text": "2010 statistics",
        "suggested_fix": "Update with current statistics",
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
async def test_update_current_content():
    """Test with current technology references."""
    agent = ContentUpdateAgent()
    content = Content(
        title="Test Content",
        text="Use Python 3.11 and React 18 for modern development.",
        content_type=ContentType.TEXT,
    )

    mock_response = "```json\n[]\n```"

    with patch.object(agent.model, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) == 0


@pytest.mark.asyncio
async def test_update_jquery_detection():
    """Test jQuery deprecation detection."""
    agent = ContentUpdateAgent()
    content = Content(
        title="Test Content",
        text="Include jQuery library for DOM manipulation.",
        content_type=ContentType.TEXT,
    )

    mock_response = """```json
[
    {
        "type": "outdated",
        "severity": "low",
        "description": "jQuery is less commonly used in modern development",
        "original_text": "jQuery library",
        "suggested_fix": "Consider vanilla JavaScript or modern framework",
        "confidence": 0.75
    }
]
```"""

    with patch.object(agent.model, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) >= 1
