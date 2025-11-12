"""Response schema models for AI agents."""

from enum import Enum
from typing import List, Optional

from pydantic import BaseModel, Field


class IssueTypeEnum(str, Enum):
    """Enum for issue types."""

    SPELLING = "spelling"
    GRAMMAR = "grammar"
    SYNTAX = "syntax"
    COMPREHENSION = "comprehension"
    SOURCE = "source"
    OUTDATED = "outdated"
    DEPRECATED = "deprecated"


class IssueSeverityEnum(str, Enum):
    """Enum for issue severity."""

    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"


class AIReviewIssue(BaseModel):
    """Schema for a single review issue from AI."""

    type: str = Field(
        description="Type of issue: spelling, grammar, syntax, comprehension, source, outdated, or deprecated"
    )
    severity: str = Field(description="Severity level: critical, high, medium, or low")
    description: str = Field(description="Clear description of the issue")
    original_text: Optional[str] = Field(
        default=None, description="The problematic text from the content"
    )
    suggested_fix: Optional[str] = Field(
        default=None, description="Suggested correction or improvement"
    )
    confidence: float = Field(
        default=0.85, description="Confidence score between 0.0 and 1.0"
    )
    sources: Optional[List[str]] = Field(
        default=None, description="List of reference sources (for source verification)"
    )


class AIReviewResponse(BaseModel):
    """Schema for the complete review response from AI."""

    issues: List[AIReviewIssue] = Field(
        description="List of all issues found in the content"
    )
