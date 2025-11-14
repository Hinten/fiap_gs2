"""
Utility functions and helpers.
"""

import uuid
from datetime import datetime


def generate_id(prefix: str = "") -> str:
    """
    Generate a unique ID with optional prefix.

    Args:
        prefix: Optional prefix for the ID (e.g., "proj", "user", "alert")

    Returns:
        Unique identifier string
    """
    unique_id = str(uuid.uuid4())[:8]
    return f"{prefix}-{unique_id}" if prefix else unique_id


def get_current_timestamp() -> datetime:
    """
    Get current UTC timestamp.

    Returns:
        Current datetime in UTC
    """
    return datetime.utcnow()


def calculate_days_since(date: datetime) -> int:
    """
    Calculate number of days since a given date.

    Args:
        date: The date to calculate from

    Returns:
        Number of days elapsed
    """
    if not date:
        return 0
    delta = datetime.utcnow() - date
    return delta.days
