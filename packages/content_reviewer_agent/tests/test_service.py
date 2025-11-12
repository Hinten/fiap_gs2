"""Tests for content review service."""

from unittest.mock import Mock, patch

import pytest

from content_reviewer_agent.models.content import Content, ContentType
from content_reviewer_agent.models.review_result import ReviewStatus, ReviewType
from content_reviewer_agent.services.review_service import ContentReviewService


@pytest.mark.asyncio
async def test_service_full_review():
    """Test full review with all agents."""
    service = ContentReviewService()
    content = Content(
        title="Test Content",
        text="I recieve emails regularly.",
        content_type=ContentType.TEXT,
    )

    # Mock all agents
    with patch.object(service.error_agent, "review", return_value=[]):
        with patch.object(service.comprehension_agent, "review", return_value=[]):
            with patch.object(service.source_agent, "review", return_value=[]):
                with patch.object(service.update_agent, "review", return_value=[]):
                    result = await service.review_content(
                        content, ReviewType.FULL_REVIEW
                    )

                    assert result.review_type == ReviewType.FULL_REVIEW
                    assert result.status == ReviewStatus.COMPLETED
                    assert isinstance(result.quality_score, float)


@pytest.mark.asyncio
async def test_service_error_only():
    """Test error detection only."""
    service = ContentReviewService()
    content = Content(
        title="Test Content",
        text="I recieve emails.",
        content_type=ContentType.TEXT,
    )

    with patch.object(service.error_agent, "review", return_value=[]):
        result = await service.review_content(content, ReviewType.ERROR_DETECTION)

        assert result.review_type == ReviewType.ERROR_DETECTION
        assert result.status == ReviewStatus.COMPLETED


@pytest.mark.asyncio
async def test_service_comprehension_only():
    """Test comprehension review only."""
    service = ContentReviewService()
    content = Content(
        title="Test Content",
        text="We must utilize this methodology.",
        content_type=ContentType.TEXT,
    )

    with patch.object(service.comprehension_agent, "review", return_value=[]):
        result = await service.review_content(content, ReviewType.COMPREHENSION)

        assert result.review_type == ReviewType.COMPREHENSION
        assert result.status == ReviewStatus.COMPLETED


@pytest.mark.asyncio
async def test_service_source_only():
    """Test source verification only."""
    service = ContentReviewService()
    content = Content(
        title="Test Content",
        text="Research shows that statistics indicate results.",
        content_type=ContentType.TEXT,
    )

    with patch.object(service.source_agent, "review", return_value=[]):
        result = await service.review_content(content, ReviewType.SOURCE_VERIFICATION)

        assert result.review_type == ReviewType.SOURCE_VERIFICATION
        assert result.status == ReviewStatus.COMPLETED


@pytest.mark.asyncio
async def test_service_update_only():
    """Test content update review only."""
    service = ContentReviewService()
    content = Content(
        title="Test Content",
        text="Use Python 2.7 for this project.",
        content_type=ContentType.TEXT,
    )

    with patch.object(service.update_agent, "review", return_value=[]):
        result = await service.review_content(content, ReviewType.CONTENT_UPDATE)

        assert result.review_type == ReviewType.CONTENT_UPDATE
        assert result.status == ReviewStatus.COMPLETED


@pytest.mark.asyncio
async def test_service_clean_content():
    """Test service with clean content."""
    service = ContentReviewService()
    content = Content(
        title="Test Content",
        text="This is clean, well-written content.",
        content_type=ContentType.TEXT,
    )

    with patch.object(service.error_agent, "review", return_value=[]):
        with patch.object(service.comprehension_agent, "review", return_value=[]):
            with patch.object(service.source_agent, "review", return_value=[]):
                with patch.object(service.update_agent, "review", return_value=[]):
                    result = await service.review_content(
                        content, ReviewType.FULL_REVIEW
                    )

                    assert len(result.issues) == 0
                    assert result.quality_score == 100.0


@pytest.mark.asyncio
async def test_service_get_agents():
    """Test getting agent information."""
    service = ContentReviewService()
    agents_info = await service.get_agent_info()

    assert "agents" in agents_info
    assert len(agents_info["agents"]) == 4
    assert all("name" in agent for agent in agents_info["agents"])
    assert all("description" in agent for agent in agents_info["agents"])
