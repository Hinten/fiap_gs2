"""AWS Lambda handler for serverless deployment.

This module provides an adapter to run the FastAPI application
on AWS Lambda using Mangum.
"""

from mangum import Mangum
from src.main import app

# Create Lambda handler
handler = Mangum(app, lifespan="off")
