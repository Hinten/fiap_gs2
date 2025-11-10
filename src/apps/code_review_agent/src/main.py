"""Main FastAPI application for Code Review Agent."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api import routes, github_routes, plagiarism_routes
from .utils.config import settings

# Create FastAPI app
app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="AI-powered code review agent for FIAP students",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: Configure specific origins in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(
    routes.router,
    prefix=f"{settings.api_v1_prefix}/code-review",
    tags=["code-review"]
)
app.include_router(
    github_routes.router,
    prefix=f"{settings.api_v1_prefix}/github",
    tags=["github"]
)
app.include_router(
    plagiarism_routes.router,
    prefix=f"{settings.api_v1_prefix}/plagiarism",
    tags=["plagiarism"]
)


@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "name": settings.app_name,
        "version": settings.app_version,
        "status": "running",
        "docs_url": "/docs"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
