"""Main FastAPI application for AI Usage Detection Agent."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api.routes import router
from .utils.config import settings
from .utils.logger import logger


def create_app() -> FastAPI:
    """
    Create and configure FastAPI application.
    
    Returns:
        Configured FastAPI app
    """
    app = FastAPI(
        title=settings.api_title,
        version=settings.api_version,
        description=settings.api_description,
        debug=settings.debug
    )
    
    # CORS Configuration
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # In production, specify actual origins
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # Include routers
    app.include_router(router)
    
    # Startup event
    @app.on_event("startup")
    async def startup_event():
        """Run on application startup."""
        logger.info(
            "AI Usage Detection Agent starting",
            extra={
                "version": settings.api_version,
                "debug": settings.debug
            }
        )
    
    # Shutdown event
    @app.on_event("shutdown")
    async def shutdown_event():
        """Run on application shutdown."""
        logger.info("AI Usage Detection Agent shutting down")
    
    # Root endpoint
    @app.get("/")
    async def root():
        """Root endpoint."""
        return {
            "service": settings.api_title,
            "version": settings.api_version,
            "status": "running",
            "endpoints": {
                "analyze": "/api/v1/ai-detection/analyze",
                "guidelines": "/api/v1/ai-detection/guidelines",
                "health": "/api/v1/ai-detection/health",
                "docs": "/docs"
            }
        }
    
    return app


# Create app instance
app = create_app()


# Lambda handler for serverless deployment
def lambda_handler(event, context):
    """
    AWS Lambda handler for serverless deployment.
    
    Args:
        event: Lambda event
        context: Lambda context
        
    Returns:
        API Gateway compatible response
    """
    from mangum import Mangum
    
    handler = Mangum(app)
    return handler(event, context)


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "src.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug
    )
