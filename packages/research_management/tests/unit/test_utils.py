"""
Unit tests for utility functions.
"""

from datetime import datetime, timedelta

import pytest

from research_management.utils import (
    calculate_days_since,
    generate_id,
    get_current_timestamp,
)


def test_generate_id_without_prefix():
    """Test ID generation without prefix."""
    id1 = generate_id()
    id2 = generate_id()

    assert len(id1) == 8  # UUID first 8 characters
    assert id1 != id2  # Should be unique


def test_generate_id_with_prefix():
    """Test ID generation with prefix."""
    project_id = generate_id("proj")
    alert_id = generate_id("alert")

    assert project_id.startswith("proj-")
    assert alert_id.startswith("alert-")
    assert len(project_id) == 13  # "proj-" + 8 chars


def test_get_current_timestamp():
    """Test getting current timestamp."""
    now = get_current_timestamp()
    assert isinstance(now, datetime)

    # Should be very recent (within 1 second)
    delta = datetime.utcnow() - now
    assert delta.total_seconds() < 1


def test_calculate_days_since():
    """Test calculating days since a date."""
    # Test with 5 days ago
    five_days_ago = datetime.utcnow() - timedelta(days=5)
    days = calculate_days_since(five_days_ago)
    assert days == 5

    # Test with today
    today = datetime.utcnow()
    days = calculate_days_since(today)
    assert days == 0

    # Test with None
    days = calculate_days_since(None)
    assert days == 0
