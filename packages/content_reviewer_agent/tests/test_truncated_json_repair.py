"""Tests for JSON repair in BaseAIAgent when AI returns truncated JSON with trailing commas."""

import pytest
from unittest.mock import Mock, patch

from content_reviewer_agent.agents.error_detection import ErrorDetectionAgent
from content_reviewer_agent.models.content import Content, ContentType, IssueType


@pytest.mark.asyncio
async def test_truncated_json_repair_single_issue():
    """Ensure truncated JSON with trailing comma is repaired and parsed into issues list."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="I recieve emails regularly.",
        content_type=ContentType.TEXT,
    )

    # Simulate AI response that was truncated mid-object (missing closing braces) and has trailing comma
    truncated = (
        '{\n  "issues": [\n    {\n      "type": "spelling",\n'  # start
        '      "severity": "low",\n'
        '      "description": "Spelling error: \'recieve\' should be \'receive\'",\n'
        '      "original_text": "recieve",\n'
        '      "suggested_fix": "receive",\n'
        '      "confidence": 0.9,\n'  # trailing comma at end of last field
    )  # truncated without closing braces/array

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_response = Mock()
        mock_response.text = truncated
        mock_generate.return_value = mock_response

        issues = await agent.review(content)

    assert len(issues) == 1, "Should recover a single issue from truncated JSON"
    issue = issues[0]
    assert issue.issue_type == IssueType.SPELLING
    assert issue.description.lower().startswith("spelling error")
    assert issue.original_text == "recieve"
    assert issue.suggested_fix == "receive"
    assert issue.confidence >= 0.85


@pytest.mark.asyncio
async def test_truncated_json_repair_multiple_objects():
    """Repair should salvage multiple issue objects if present."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="Bad grammar and syntax: def example()\n    print('test')",
        content_type=ContentType.CODE,
    )

    truncated = (
        '{"issues": ['
        '{"type": "grammar", "severity": "medium", "description": "Article usage error", "original_text": "a example", "suggested_fix": "an example", "confidence": 0.92},'
        '{"type": "syntax", "severity": "high", "description": "Missing colon", "original_text": "def example()", "suggested_fix": "def example():", "confidence": 0.95},'
    )  # Missing closing ] and }

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_response = Mock()
        mock_response.text = truncated
        mock_generate.return_value = mock_response

        issues = await agent.review(content)

    # We should salvage both objects via regex extraction
    types_found = sorted([i.issue_type for i in issues])
    assert IssueType.GRAMMAR in types_found
    assert IssueType.SYNTAX in types_found
    assert len(issues) == 2

