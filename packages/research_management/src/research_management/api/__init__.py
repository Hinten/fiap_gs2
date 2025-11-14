"""
API module.
"""

from .alerts import router as alerts_router
from .dashboard import router as dashboard_router
from .projects import router as projects_router
from .updates import router as updates_router

__all__ = [
    "projects_router",
    "updates_router",
    "alerts_router",
    "dashboard_router",
]
