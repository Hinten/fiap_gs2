"""
Integration tests for Research Management API endpoints.
Tests the API with Firebase emulator.
"""

import pytest
import requests
import time
from typing import Dict, Any

# API base URL
API_BASE_URL = "http://localhost:8002"


def wait_for_api(max_wait: int = 30) -> bool:
    """Wait for API to be ready."""
    for _ in range(max_wait):
        try:
            response = requests.get(f"{API_BASE_URL}/health", timeout=2)
            if response.status_code == 200:
                return True
        except requests.exceptions.RequestException:
            pass
        time.sleep(1)
    return False


class TestAPIConnectivity:
    """Test basic API connectivity."""

    def test_health_endpoint(self):
        """Test health check endpoint."""
        response = requests.get(f"{API_BASE_URL}/health", timeout=5)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"

    def test_root_endpoint(self):
        """Test root endpoint."""
        response = requests.get(f"{API_BASE_URL}/", timeout=5)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "running"
        assert data["service"] == "Research Management API"

    def test_api_docs_available(self):
        """Test that API documentation is available."""
        response = requests.get(f"{API_BASE_URL}/docs", timeout=5)
        assert response.status_code == 200


class TestDashboardEndpoints:
    """Test dashboard endpoints."""

    def test_coordinator_dashboard(self):
        """Test coordinator dashboard endpoint."""
        response = requests.get(
            f"{API_BASE_URL}/api/v1/dashboard/coordinator", timeout=10
        )
        assert response.status_code == 200
        data = response.json()
        
        # Verify expected fields
        assert "total_projects" in data
        assert "active_projects" in data
        assert "completion_rate" in data
        assert "avg_students_per_advisor" in data
        assert "projects_in_risk" in data
        assert "students_without_advisor" in data
        assert "active_alerts_count" in data
        
        # Verify data types
        assert isinstance(data["total_projects"], int)
        assert isinstance(data["completion_rate"], (int, float))

    def test_advisor_dashboard(self):
        """Test advisor dashboard endpoint."""
        response = requests.get(
            f"{API_BASE_URL}/api/v1/dashboard/advisor",
            params={"advisor_id": "advisor-001"},
            timeout=10,
        )
        assert response.status_code == 200
        data = response.json()
        
        # Verify expected fields
        assert "total_projects" in data
        assert "active_projects" in data
        assert "total_students" in data
        assert "active_alerts" in data
        assert "projects" in data

    def test_student_dashboard(self):
        """Test student dashboard endpoint."""
        response = requests.get(
            f"{API_BASE_URL}/api/v1/dashboard/student",
            params={"student_id": "student-001"},
            timeout=10,
        )
        assert response.status_code == 200
        data = response.json()
        
        # Verify expected field
        assert "has_project" in data


class TestProjectEndpoints:
    """Test project CRUD endpoints."""

    def test_list_projects(self):
        """Test listing projects."""
        response = requests.get(f"{API_BASE_URL}/api/v1/projects", timeout=10)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    def test_list_projects_with_filters(self):
        """Test listing projects with filters."""
        response = requests.get(
            f"{API_BASE_URL}/api/v1/projects",
            params={"status": "active", "limit": 10},
            timeout=10,
        )
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)


class TestAlertEndpoints:
    """Test alert endpoints."""

    def test_list_alerts(self):
        """Test listing alerts."""
        response = requests.get(f"{API_BASE_URL}/api/v1/alerts", timeout=10)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)


class TestCORS:
    """Test CORS configuration."""

    def test_cors_headers(self):
        """Test that CORS headers are present."""
        response = requests.options(
            f"{API_BASE_URL}/api/v1/projects",
            headers={"Origin": "http://localhost:3000"},
            timeout=5,
        )
        # CORS should allow the request
        assert response.status_code in [200, 204]


if __name__ == "__main__":
    print("Testing API connectivity...")
    print(f"API Base URL: {API_BASE_URL}")
    print("\nWaiting for API to be ready...")
    
    if wait_for_api():
        print("✓ API is ready")
        print("\nRunning tests...")
        pytest.main([__file__, "-v", "--tb=short"])
    else:
        print("✗ API is not responding")
        print("\nPlease make sure:")
        print("1. Firebase emulator is running:")
        print("   firebase emulators:start --only firestore --project demo-test-project")
        print("2. Python API is running:")
        print("   cd packages/research_management")
        print("   FIRESTORE_EMULATOR_HOST=localhost:8080 python -m research_management.main")
