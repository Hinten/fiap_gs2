"""
Tests for FastAPI endpoints.
"""

from datetime import datetime

import pytest
from httpx import AsyncClient

from src.api.approvals import get_approval_service
from src.main import app
from src.models.approval import ApprovalPriority, ApprovalType
from src.repositories.dynamodb import DynamoDBApprovalRepository
from src.services.approval_service import ApprovalService

# Create a shared repository for all tests
_test_repository = DynamoDBApprovalRepository()


def get_test_approval_service() -> ApprovalService:
    """Get a test approval service with shared repository."""
    return ApprovalService(_test_repository)


# Override the dependency
app.dependency_overrides[get_approval_service] = get_test_approval_service


@pytest.mark.asyncio
async def test_health_endpoint():
    """Test the health check endpoint."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


@pytest.mark.asyncio
async def test_root_endpoint():
    """Test the root endpoint."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/")

    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "approval_interface"
    assert data["status"] == "healthy"


@pytest.mark.asyncio
async def test_create_approval():
    """Test creating an approval via API."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/approvals",
            json={
                "type": "code_review",
                "related_id": "review_001",
                "title": "Test Code Review",
                "description": "API test",
                "generated_content": {"score": 85},
                "assigned_to": "prof_001",
                "priority": "high",
            },
        )

    assert response.status_code == 201
    data = response.json()
    assert data["success"] is True
    assert "approval_id" in data["data"]


@pytest.mark.asyncio
async def test_list_pending():
    """Test listing pending approvals."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        # Create an approval first
        await client.post(
            "/api/v1/approvals",
            json={
                "type": "grading",
                "related_id": "grade_001",
                "title": "Test Grading",
                "description": "API test",
                "generated_content": {"grade": 8.5},
                "assigned_to": "prof_002",
                "priority": "normal",
            },
        )

        # List pending
        response = await client.get("/api/v1/approvals/pending")

    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert isinstance(data["data"], list)


@pytest.mark.asyncio
async def test_approve_item():
    """Test approving an item via API."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        # Create an approval
        create_response = await client.post(
            "/api/v1/approvals",
            json={
                "type": "content",
                "related_id": "content_001",
                "title": "Test Content",
                "description": "API test",
                "generated_content": {"url": "https://example.com/video"},
                "assigned_to": "prof_003",
                "priority": "normal",
            },
        )
        approval_id = create_response.json()["data"]["approval_id"]

        # Approve it
        response = await client.post(
            f"/api/v1/approvals/{approval_id}/approve",
            json={"approved_by": "prof_003"},
        )

    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["data"]["decision"] == "approved"


@pytest.mark.asyncio
async def test_reject_item():
    """Test rejecting an item via API."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        # Create an approval
        create_response = await client.post(
            "/api/v1/approvals",
            json={
                "type": "award",
                "related_id": "award_001",
                "title": "Test Award",
                "description": "API test",
                "generated_content": {"ranking": [1, 2, 3]},
                "assigned_to": "prof_004",
                "priority": "critical",
            },
        )
        approval_id = create_response.json()["data"]["approval_id"]

        # Reject it
        response = await client.post(
            f"/api/v1/approvals/{approval_id}/reject",
            json={
                "rejected_by": "prof_004",
                "reason": "Ranking is incorrect",
            },
        )

    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["data"]["decision"] == "rejected"
    assert data["data"]["reason"] == "Ranking is incorrect"


@pytest.mark.asyncio
async def test_get_stats():
    """Test getting statistics via API."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/api/v1/approvals/stats")

    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "total_pending" in data["data"]
    assert "by_type" in data["data"]
    assert "by_priority" in data["data"]


@pytest.mark.asyncio
async def test_chat_endpoint():
    """Test sending a chat message via API."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        # Create an approval
        create_response = await client.post(
            "/api/v1/approvals",
            json={
                "type": "grading",
                "related_id": "grade_002",
                "title": "Test Grading",
                "description": "API test",
                "generated_content": {"grade": 9.0},
                "assigned_to": "prof_005",
                "priority": "high",
            },
        )
        approval_id = create_response.json()["data"]["approval_id"]

        # Send chat message
        response = await client.post(
            f"/api/v1/approvals/{approval_id}/chat",
            json={
                "sender": "user",
                "message": "Please reduce the grade to 8.5",
            },
        )

    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["data"]["sender"] == "user"


@pytest.mark.asyncio
async def test_get_nonexistent_approval():
    """Test getting a nonexistent approval returns 404."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/api/v1/approvals/nonexistent_id")

    assert response.status_code == 404
