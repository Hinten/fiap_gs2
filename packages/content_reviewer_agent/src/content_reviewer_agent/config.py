"""Configuration settings for content reviewer agent."""

from typing import Optional

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings for Content Reviewer Agent.

    Uses explicit aliases for environment variables to ensure clarity:
    - GOOGLE_API_KEY -> google_api_key
    - DEBUG -> debug
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        populate_by_name=True,
    )

    # API Configuration
    api_title: str = "Content Reviewer Agent API"
    api_version: str = "1.0.0"
    api_prefix: str = "/api/v1"
    debug: bool = Field(default=False, alias="DEBUG")

    # Google AI Configuration
    google_api_key: Optional[str] = Field(default=None, alias="GOOGLE_API_KEY")
    google_model_name: str = "gemini-2.5-flash"
    temperature: float = 0.3
    max_output_tokens: int = 2048

    # Agent Configuration
    max_retries: int = 3
    timeout_seconds: int = 120

    # Database (placeholder for future use)
    database_url: Optional[str] = None


settings = Settings()
