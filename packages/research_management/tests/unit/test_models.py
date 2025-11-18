"""
Unit tests for project models.
"""

from datetime import datetime

import pytest

from research_management.models.project import (
    HealthStatus,
    ProjectCreate,
    ProjectStatus,
    ProjectUpdate,
    ResearchProject,
)


def test_project_create_model():
    """Test ProjectCreate model validation."""
    project_data = ProjectCreate(
        title="Test Project",
        description="A test research project",
        area="Computer Science",
    )
    assert project_data.title == "Test Project"
    assert project_data.area == "Computer Science"


def test_project_model():
    """Test ResearchProject model."""
    project = ResearchProject(
        project_id="proj-123",
        title="ML Research",
        description="Machine learning project",
        area="AI",
        status=ProjectStatus.ACTIVE,
        health_status=HealthStatus.ON_TRACK,
    )
    assert project.project_id == "proj-123"
    assert project.status == ProjectStatus.ACTIVE
    assert project.health_status == HealthStatus.ON_TRACK


def test_project_status_enum():
    """Test ProjectStatus enum values."""
    assert ProjectStatus.PROPOSAL.value == "proposal"
    assert ProjectStatus.ACTIVE.value == "active"
    assert ProjectStatus.COMPLETED.value == "completed"
    assert ProjectStatus.ARCHIVED.value == "archived"


def test_health_status_enum():
    """Test HealthStatus enum values."""
    assert HealthStatus.ON_TRACK.value == "on_track"
    assert HealthStatus.AT_RISK.value == "at_risk"
    assert HealthStatus.CRITICAL.value == "critical"


def test_project_update_model():
    """Test ProjectUpdate model."""
    update = ProjectUpdate(
        title="Updated Title",
        health_status=HealthStatus.AT_RISK,
    )
    assert update.title == "Updated Title"
    assert update.health_status == HealthStatus.AT_RISK
    assert update.description is None  # Not provided


def test_project_create_validation():
    """Test ProjectCreate validation."""
    with pytest.raises(ValueError):
        ProjectCreate(
            title="",  # Empty title should fail
            description="Test",
            area="CS",
        )
