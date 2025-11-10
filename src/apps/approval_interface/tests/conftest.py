"""
Test configuration and fixtures.
"""

from datetime import datetime

import pytest

from src.models.approval import (ApprovalItem, ApprovalPriority,
                                 ApprovalStatus, ApprovalType)
from src.repositories.dynamodb import DynamoDBApprovalRepository
from src.services.approval_service import ApprovalService


@pytest.fixture
def repository():
    """Create a test repository instance."""
    return DynamoDBApprovalRepository()


@pytest.fixture
def service(repository):
    """Create a test service instance."""
    return ApprovalService(repository)


@pytest.fixture
def sample_approval():
    """Create a sample approval item for testing."""
    return ApprovalItem(
        approval_id="test_apr_001",
        type=ApprovalType.CODE_REVIEW,
        related_id="review_001",
        title="Test Code Review",
        description="Test approval for code review",
        generated_content={"feedback": "Good code", "score": 85},
        assigned_to="prof_001",
        priority=ApprovalPriority.HIGH,
        status=ApprovalStatus.PENDING,
        created_at=datetime.utcnow(),
    )
