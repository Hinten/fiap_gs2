"""API routes module initialization."""
from .auth_routes import router as auth_router
from .user_routes import router as user_router

__all__ = ["auth_router", "user_router"]
