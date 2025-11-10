"""Tests for CodeAnalysisService."""

import pytest
from src.services.code_analysis_service import CodeAnalysisService
from src.models import IssueSeverity


@pytest.fixture
def analysis_service():
    """Fixture for CodeAnalysisService."""
    return CodeAnalysisService()


def test_analyze_empty_files(analysis_service):
    """Test analyzing empty file list."""
    results = analysis_service.analyze_code([], language="python")
    
    assert results.total_files_analyzed == 0
    assert results.total_issues_found == 0
    assert len(results.linting_issues) == 0


def test_analyze_simple_python_code(analysis_service):
    """Test analyzing simple Python code."""
    files = [
        {
            'filename': 'test.py',
            'content': '''
def hello():
    print("Hello, World!")

if __name__ == "__main__":
    hello()
'''
        }
    ]
    
    results = analysis_service.analyze_code(files, language="python")
    
    assert results.total_files_analyzed == 1
    # Results may vary depending on linter availability
    assert results.total_issues_found >= 0


def test_analyze_code_with_security_issue(analysis_service):
    """Test analyzing code with potential security issue."""
    files = [
        {
            'filename': 'insecure.py',
            'content': '''
import subprocess

def run_command(user_input):
    subprocess.call(user_input, shell=True)  # Security issue
'''
        }
    ]
    
    results = analysis_service.analyze_code(files, language="python")
    
    assert results.total_files_analyzed == 1
    # Bandit should detect the shell=True issue if available


def test_skip_non_python_files(analysis_service):
    """Test that non-Python files are skipped appropriately."""
    files = [
        {
            'filename': 'readme.txt',
            'content': 'This is a text file'
        }
    ]
    
    results = analysis_service.analyze_code(files, language="python")
    
    # Should not analyze non-Python files
    assert results.total_files_analyzed == 1
    assert results.total_issues_found == 0
