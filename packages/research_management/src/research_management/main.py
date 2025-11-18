"""
FastAPI application for Research Management System.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api import (
    alerts_router,
    dashboard_router,
    projects_router,
    updates_router,
)
from .config import get_settings
from .firebase_admin import initialize_firebase

# Initialize settings
settings = get_settings()

# Create FastAPI app
app = FastAPI(
    title="Research Management API",
    description="API for managing scientific research initiation projects",
    version="0.1.0",
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
    # Initialize Firebase
    initialize_firebase()
    print("Research Management API started")
    print(f"API version: {settings.api_version}")
    print(f"Firebase project: {settings.firebase_project_id}")


@app.get("/")
def root():
    """Root endpoint."""
    return {
        "service": "Research Management API",
        "version": "0.1.0",
        "status": "running",
    }


@app.get("/health")
def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}


# Include routers
app.include_router(projects_router, prefix=settings.api_prefix)
app.include_router(updates_router, prefix=settings.api_prefix)
app.include_router(alerts_router, prefix=settings.api_prefix)
app.include_router(dashboard_router, prefix=settings.api_prefix)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "research_management.main:app",
        host="0.0.0.0",
        port=8002,
        reload=True,
    )
