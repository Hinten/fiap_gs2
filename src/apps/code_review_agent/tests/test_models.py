"""Tests for code review models."""

import pytest
from datetime import datetime

from src.models import (
    CodeReview,
    CodeReviewRequest,
    ReviewStatus,
    IssueSeverity,
    CodeIssue,
    AnalysisResults,
)


def test_code_review_creation():
    """Test creating a CodeReview object."""
    review = CodeReview(
        review_id="test-123",
        repo_full_name="user/repo",
        commit_sha="abc123",
        student_id="student1",
        discipline="Software Engineering",
    )
    
    assert review.review_id == "test-123"
    assert review.status == ReviewStatus.PENDING
    assert review.pr_number is None
    assert isinstance(review.created_at, datetime)


def test_code_issue_creation():
    """Test creating a CodeIssue object."""
    issue = CodeIssue(
        file_path="main.py",
        line_number=10,
        severity=IssueSeverity.HIGH,
        category="security",
        message="SQL injection vulnerability",
        suggestion="Use parameterized queries"
    )
    
    assert issue.file_path == "main.py"
    assert issue.line_number == 10
    assert issue.severity == IssueSeverity.HIGH
    assert issue.suggestion is not None


def test_analysis_results_aggregation():
    """Test AnalysisResults aggregation."""
    results = AnalysisResults(
        total_files_analyzed=3,
        linting_issues=[
            CodeIssue(
                file_path="test.py",
                line_number=1,
                severity=IssueSeverity.LOW,
                category="style",
                message="Line too long"
            )
        ],
        security_issues=[
            CodeIssue(
                file_path="app.py",
                line_number=50,
                severity=IssueSeverity.CRITICAL,
                category="security",
                message="Hardcoded credentials"
            )
        ]
    )
    
    assert results.total_files_analyzed == 3
    assert len(results.linting_issues) == 1
    assert len(results.security_issues) == 1


def test_code_review_request_validation():
    """Test CodeReviewRequest validation."""
    request = CodeReviewRequest(
        repo_full_name="owner/repo",
        pr_number=123,
        student_id="student1",
        discipline="Software Engineering"
    )
    
    assert request.repo_full_name == "owner/repo"
    assert request.pr_number == 123
    assert request.commit_sha is None
