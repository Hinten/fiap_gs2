"""
API routes for the approval interface.
"""

from .approvals import router as approvals_router

__all__ = [
    "approvals_router",
]
