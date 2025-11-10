"""
Configuration settings for the Code Review Agent.

This module provides centralized configuration management using Pydantic Settings.
"""

from typing import Optional
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Application
    app_name: str = "Code Review Agent"
    app_version: str = "1.0.0"
    debug: bool = False
    
    # API
    api_v1_prefix: str = "/api/v1"
    
    # GitHub
    github_app_id: Optional[str] = None
    github_app_private_key: Optional[str] = None
    github_webhook_secret: Optional[str] = None
    github_token: Optional[str] = None
    
    # AI/LLM
    openai_api_key: Optional[str] = None
    anthropic_api_key: Optional[str] = None
    
    # AWS
    aws_region: str = "us-east-1"
    dynamodb_table_reviews: str = "code_reviews"
    dynamodb_table_plagiarism: str = "plagiarism_reports"
    
    # Security
    jwt_secret_key: str = "change-this-secret-key-in-production"
    jwt_algorithm: str = "HS256"
    jwt_expiration_minutes: int = 30
    
    # Code Analysis
    max_file_size_bytes: int = 1024 * 1024  # 1MB
    supported_languages: list[str] = ["python", "javascript", "typescript", "dart"]
    
    # Plagiarism Detection
    similarity_threshold: float = 0.85
    
    class Config:
        """Pydantic configuration."""
        env_file = ".env"
        case_sensitive = False


settings = Settings()
