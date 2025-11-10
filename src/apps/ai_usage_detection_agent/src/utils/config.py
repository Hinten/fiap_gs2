"""Configuration management for AI Usage Detection Agent."""

from typing import Optional
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings."""
    
    # API Configuration
    api_title: str = "AI Usage Detection Agent"
    api_version: str = "1.0.0"
    api_description: str = "Detect and analyze AI usage in academic submissions"
    
    # Server Configuration
    host: str = "0.0.0.0"
    port: int = 8002
    debug: bool = False
    
    # Detection Thresholds
    ai_usage_threshold_moderate: float = 0.30
    ai_usage_threshold_questionable: float = 0.60
    ai_usage_threshold_inadequate: float = 0.80
    
    # Feature Weights for Scoring
    text_ai_weight: float = 0.30
    code_ai_weight: float = 0.30
    style_inconsistency_weight: float = 0.20
    complexity_mismatch_weight: float = 0.10
    temporal_anomaly_weight: float = 0.10
    
    # Text Analysis Configuration
    min_text_length: int = 50
    max_perplexity_threshold: float = 50.0
    
    # Code Analysis Configuration
    min_code_lines: int = 10
    
    # AWS Configuration (for serverless deployment)
    aws_region: Optional[str] = None
    dynamodb_table_analyses: str = "ai_usage_analyses"
    dynamodb_table_declarations: str = "ai_usage_declarations"
    
    # Logging
    log_level: str = "INFO"
    
    class Config:
        """Pydantic config."""
        env_file = ".env"
        case_sensitive = False


# Global settings instance
settings = Settings()
