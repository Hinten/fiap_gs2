"""Tests for API routes."""

import pytest
from fastapi.testclient import TestClient
from src.main import app
from src.models.schemas import SubmissionType


@pytest.fixture
def client():
    """Create test client."""
    return TestClient(app)


def test_root_endpoint(client):
    """Test root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "running"
    assert "endpoints" in data


def test_health_check(client):
    """Test health check endpoint."""
    response = client.get("/api/v1/ai-detection/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"


def test_analyze_text_submission(client):
    """Test analyzing a text submission."""
    payload = {
        "submission_id": "test-001",
        "student_id": "student-123",
        "content": "This is a test submission with some natural text content that is long enough for analysis.",
        "submission_type": "text"
    }
    
    response = client.post("/api/v1/ai-detection/analyze", json=payload)
    assert response.status_code == 200
    
    data = response.json()
    assert data["success"] is True
    assert data["data"] is not None
    assert data["error"] is None
    
    analysis = data["data"]
    assert analysis["submission_id"] == "test-001"
    assert analysis["student_id"] == "student-123"
    assert "ai_usage_score" in analysis
    assert "category" in analysis
    assert "explanation" in analysis


def test_analyze_code_submission(client):
    """Test analyzing a code submission."""
    code = """
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print(fibonacci(10))
    """
    
    payload = {
        "submission_id": "test-002",
        "student_id": "student-456",
        "content": code,
        "submission_type": "code"
    }
    
    response = client.post("/api/v1/ai-detection/analyze", json=payload)
    assert response.status_code == 200
    
    data = response.json()
    assert data["success"] is True
    analysis = data["data"]
    assert analysis["code_ai_probability"] is not None


def test_analyze_mixed_submission(client):
    """Test analyzing a mixed submission."""
    content = """
# Assignment: Fibonacci Calculator

This program calculates fibonacci numbers using recursion.

def fib(n):
    if n <= 1:
        return n
    return fib(n-1) + fib(n-2)
    """
    
    payload = {
        "submission_id": "test-003",
        "student_id": "student-789",
        "content": content,
        "submission_type": "mixed"
    }
    
    response = client.post("/api/v1/ai-detection/analyze", json=payload)
    assert response.status_code == 200
    
    data = response.json()
    analysis = data["data"]
    assert analysis["text_ai_probability"] is not None
    assert analysis["code_ai_probability"] is not None


def test_analyze_empty_content(client):
    """Test analyzing empty content."""
    payload = {
        "submission_id": "test-004",
        "student_id": "student-999",
        "content": "",
        "submission_type": "text"
    }
    
    response = client.post("/api/v1/ai-detection/analyze", json=payload)
    assert response.status_code == 422  # Validation error


def test_analyze_missing_fields(client):
    """Test analyzing with missing required fields."""
    payload = {
        "submission_id": "test-005",
        "content": "Some content"
        # Missing student_id
    }
    
    response = client.post("/api/v1/ai-detection/analyze", json=payload)
    assert response.status_code == 422


def test_get_guidelines(client):
    """Test getting AI usage guidelines."""
    response = client.get("/api/v1/ai-detection/guidelines")
    assert response.status_code == 200
    
    data = response.json()
    assert data["success"] is True
    assert data["data"] is not None
    
    guidelines = data["data"]
    assert "appropriate_usage" in guidelines["categories"]
    assert "inappropriate_usage" in guidelines["categories"]
    assert "declaration_policy" in guidelines


def test_declare_usage(client):
    """Test declaring AI usage."""
    payload = {
        "submission_id": "test-006",
        "student_id": "student-111",
        "declared_usage": True,
        "usage_description": "I used ChatGPT to understand the algorithm"
    }
    
    response = client.post("/api/v1/ai-detection/declare-usage", json=payload)
    assert response.status_code == 200
    
    data = response.json()
    assert data["success"] is True
    assert "message" in data


def test_get_report_placeholder(client):
    """Test get report endpoint (placeholder)."""
    response = client.get("/api/v1/ai-detection/report/test-001")
    assert response.status_code == 200
    
    data = response.json()
    assert data["success"] is False  # Not implemented yet
    assert "not yet implemented" in data["error"].lower()


def test_analyze_ai_like_text(client):
    """Test analyzing AI-like text."""
    ai_text = """
    Furthermore, artificial intelligence represents a transformative paradigm
    shift in computational capabilities. Moreover, the integration of machine
    learning algorithms facilitates unprecedented optimization of complex systems.
    Consequently, organizations can leverage these sophisticated methodologies
    to enhance operational efficiency and drive innovation.
    """
    
    payload = {
        "submission_id": "test-007",
        "student_id": "student-222",
        "content": ai_text,
        "submission_type": "text"
    }
    
    response = client.post("/api/v1/ai-detection/analyze", json=payload)
    assert response.status_code == 200
    
    data = response.json()
    analysis = data["data"]
    
    # Should detect high AI probability
    assert analysis["ai_usage_score"] > 0.3


def test_analyze_student_like_code(client):
    """Test analyzing student-like code."""
    student_code = """
# my solution
def calc(x, y):
    # add them
    result = x + y
    return result

# test
print(calc(2, 3))
    """
    
    payload = {
        "submission_id": "test-008",
        "student_id": "student-333",
        "content": student_code,
        "submission_type": "code"
    }
    
    response = client.post("/api/v1/ai-detection/analyze", json=payload)
    assert response.status_code == 200
    
    data = response.json()
    analysis = data["data"]
    
    # Should detect low AI probability for student code
    # (assuming the analyzer works as expected)
    assert analysis["category"] in ["appropriate", "moderate"]
