"""
Repository interfaces and implementations for approval data access.
"""

from .base import ApprovalRepository
from .dynamodb import DynamoDBApprovalRepository

__all__ = [
    "ApprovalRepository",
    "DynamoDBApprovalRepository",
]
