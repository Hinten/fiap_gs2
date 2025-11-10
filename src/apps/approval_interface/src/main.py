"""
Main FastAPI application for the Approval Interface service.
"""

import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api.approvals import router as approvals_router

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='{"timestamp": "%(asctime)s", "level": "%(levelname)s", "service": "approval_interface", "message": "%(message)s"}',
)

logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="FIAP Approval Interface API",
    description="Human-in-the-loop approval interface for AI-generated content",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict this to specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(approvals_router)


@app.get("/")
async def root():
    """Health check endpoint."""
    return {"service": "approval_interface", "status": "healthy", "version": "1.0.0"}


@app.get("/health")
async def health():
    """Health check for load balancers."""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
