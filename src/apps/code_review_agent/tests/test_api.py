"""Tests for API endpoints."""

import pytest
from fastapi.testclient import TestClient
from unittest.mock import Mock, patch

from src.main import app
from src.models import CodeReview, ReviewStatus


client = TestClient(app)


def test_root_endpoint():
    """Test root endpoint returns API information."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "name" in data
    assert "version" in data
    assert data["status"] == "running"


def test_health_check():
    """Test health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


@patch('src.api.routes.code_review_service')
def test_create_code_review(mock_service):
    """Test creating a code review via API."""
    # Mock service response
    from src.models import CodeReviewResponse
    mock_service.create_review.return_value = CodeReviewResponse(
        success=True,
        review_id="test-123",
        status=ReviewStatus.PENDING,
        message="Review created"
    )
    
    response = client.post(
        "/api/v1/code-review/analyze",
        json={
            "repo_full_name": "user/repo",
            "pr_number": 123,
            "student_id": "student1",
            "discipline": "Software Engineering"
        }
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "review_id" in data


@patch('src.api.routes.code_review_service')
def test_get_nonexistent_review(mock_service):
    """Test getting a review that doesn't exist."""
    mock_service.get_review.return_value = None
    
    response = client.get("/api/v1/code-review/nonexistent-id")
    
    assert response.status_code == 404


@patch('src.api.routes.code_review_service')
def test_list_pending_reviews(mock_service):
    """Test listing pending reviews."""
    mock_service.list_pending_reviews.return_value = []
    
    response = client.get("/api/v1/code-review/pending")
    
    assert response.status_code == 200
    assert isinstance(response.json(), list)
