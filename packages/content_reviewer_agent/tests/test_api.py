"""Tests for FastAPI endpoints."""

from unittest.mock import Mock, patch

import pytest
from fastapi.testclient import TestClient

from content_reviewer_agent.main import app
from content_reviewer_agent.models.content import Content
from content_reviewer_agent.models.review_result import (
    ReviewResult,
    ReviewStatus,
    ReviewType,
)

client = TestClient(app)


def test_root_endpoint():
    """Test root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "service" in data or "message" in data


def test_health_check():
    """Test health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_get_agents():
    """Test agents endpoint."""
    response = client.get("/api/v1/agents")
    assert response.status_code == 200
    data = response.json()
    assert "agents" in data
    assert len(data["agents"]) == 4


def test_review_content_full():
    """Test full content review endpoint."""
    content = {
        "title": "Test Content",
        "text": "I recieve emails regularly.",
        "content_type": "text",
    }

    # Mock the review service
    with patch(
        "content_reviewer_agent.api.routes.review_service.review_content"
    ) as mock_review:
        mock_result = ReviewResult(
            content_id="test-123",
            review_type=ReviewType.FULL_REVIEW,
            status=ReviewStatus.COMPLETED,
            summary="Test review",
            quality_score=90.0,
        )
        mock_review.return_value = mock_result

        response = client.post(
            "/api/v1/review?review_type=full_review",
            json=content,
        )

        assert response.status_code == 200
        assert response.json()["status"] == "completed"


def test_review_errors_endpoint():
    """Test error review endpoint."""
    content = {
        "title": "Test Content",
        "text": "I recieve emails.",
        "content_type": "text",
    }

    with patch(
        "content_reviewer_agent.api.routes.review_service.review_content"
    ) as mock_review:
        mock_result = ReviewResult(
            content_id="test-123",
            review_type=ReviewType.ERROR_DETECTION,
            status=ReviewStatus.COMPLETED,
            summary="Test review",
        )
        mock_review.return_value = mock_result

        response = client.post("/api/v1/review/errors", json=content)
        assert response.status_code == 200


def test_review_comprehension_endpoint():
    """Test comprehension review endpoint."""
    content = {
        "title": "Test Content",
        "text": "We must utilize this methodology.",
        "content_type": "text",
    }

    with patch(
        "content_reviewer_agent.api.routes.review_service.review_content"
    ) as mock_review:
        mock_result = ReviewResult(
            content_id="test-123",
            review_type=ReviewType.COMPREHENSION,
            status=ReviewStatus.COMPLETED,
            summary="Test review",
        )
        mock_review.return_value = mock_result

        response = client.post("/api/v1/review/comprehension", json=content)
        assert response.status_code == 200


def test_review_sources_endpoint():
    """Test source review endpoint."""
    content = {
        "title": "Test Content",
        "text": "Research shows results.",
        "content_type": "text",
    }

    with patch(
        "content_reviewer_agent.api.routes.review_service.review_content"
    ) as mock_review:
        mock_result = ReviewResult(
            content_id="test-123",
            review_type=ReviewType.SOURCE_VERIFICATION,
            status=ReviewStatus.COMPLETED,
            summary="Test review",
        )
        mock_review.return_value = mock_result

        response = client.post("/api/v1/review/sources", json=content)
        assert response.status_code == 200


def test_review_updates_endpoint():
    """Test update review endpoint."""
    content = {
        "title": "Test Content",
        "text": "Use Python 2.7 for this project.",
        "content_type": "text",
    }

    with patch(
        "content_reviewer_agent.api.routes.review_service.review_content"
    ) as mock_review:
        mock_result = ReviewResult(
            content_id="test-123",
            review_type=ReviewType.CONTENT_UPDATE,
            status=ReviewStatus.COMPLETED,
            summary="Test review",
        )
        mock_review.return_value = mock_result

        response = client.post("/api/v1/review/updates", json=content)
        assert response.status_code == 200


def test_review_with_query_param():
    """Test review with query parameter."""
    content = {
        "title": "Test Content",
        "text": "Test text.",
        "content_type": "text",
    }

    with patch(
        "content_reviewer_agent.api.routes.review_service.review_content"
    ) as mock_review:
        mock_result = ReviewResult(
            content_id="test-123",
            review_type=ReviewType.ERROR_DETECTION,
            status=ReviewStatus.COMPLETED,
            summary="Test review",
        )
        mock_review.return_value = mock_result

        response = client.post(
            "/api/v1/review?review_type=error_detection",
            json=content,
        )
        assert response.status_code == 200
