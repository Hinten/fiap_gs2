"""
Unified Backend API - FIAP AI-Enhanced Learning Platform
Integrates all implemented microservices into a single production application.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import routers from implemented packages
from research_management.api import (
    alerts_router,
    dashboard_router,
    projects_router,
    updates_router,
)
from content_reviewer_agent.api.routes import router as content_review_router

# Import Firebase initialization
from research_management.firebase_admin import initialize_firebase
from research_management.config import get_settings

# Initialize settings
settings = get_settings()

# Create unified FastAPI app
app = FastAPI(
    title="FIAP AI-Enhanced Learning Platform - Unified Backend",
    description="Production MVP integrating all implemented microservices",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup_event():
    """Initialize services on startup."""
    # Initialize Firebase (shared across services)
    initialize_firebase()
    print("=" * 60)
    print("FIAP AI-Enhanced Learning Platform - Unified Backend")
    print("=" * 60)
    print("✅ Firebase initialized")
    print(f"📦 Services integrated:")
    print("   - Research Management System")
    print("   - Content Reviewer Agent")
    print("   - Auth Service (shared)")
    print(f"🌐 API version: 1.0.0")
    print(f"🔥 Firebase project: {settings.firebase_project_id}")
    print("=" * 60)


@app.get("/")
def root():
    """Root endpoint - API information."""
    return {
        "service": "FIAP AI-Enhanced Learning Platform - Unified Backend",
        "version": "1.0.0",
        "status": "running",
        "services": {
            "research_management": {
                "status": "active",
                "prefix": "/api/v1/research",
                "description": "Research project management and dashboards"
            },
            "content_reviewer": {
                "status": "active",
                "prefix": "/api/v1/content-review",
                "description": "AI-powered content review and validation"
            }
        },
        "docs": "/docs",
        "health": "/health"
    }


@app.get("/health")
def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "services": {
            "research_management": "healthy",
            "content_reviewer": "healthy",
            "firebase": "healthy"
        }
    }


# Include routers with prefixes
# Research Management System endpoints
app.include_router(projects_router, prefix="/api/v1/research", tags=["Research Management"])
app.include_router(updates_router, prefix="/api/v1/research", tags=["Research Management"])
app.include_router(alerts_router, prefix="/api/v1/research", tags=["Research Management"])
app.include_router(dashboard_router, prefix="/api/v1/research", tags=["Research Management"])

# Content Reviewer Agent endpoints
app.include_router(content_review_router, prefix="/api/v1/content-review", tags=["Content Review"])


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )
