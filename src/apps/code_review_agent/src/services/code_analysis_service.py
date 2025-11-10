"""Service for static code analysis."""

import subprocess
import tempfile
import os
from typing import List, Dict, Any
from pathlib import Path

from ..models import CodeIssue, IssueSeverity, AnalysisResults


class CodeAnalysisService:
    """Service for performing static code analysis."""
    
    def __init__(self):
        """Initialize code analysis service."""
        pass
    
    def analyze_code(
        self, 
        files: List[Dict[str, Any]], 
        language: str = "python"
    ) -> AnalysisResults:
        """
        Analyze code files for issues.
        
        Args:
            files: List of file dictionaries with 'filename' and 'content'
            language: Programming language of the code
            
        Returns:
            AnalysisResults object with found issues
        """
        results = AnalysisResults(total_files_analyzed=len(files))
        
        for file_info in files:
            filename = file_info.get('filename', '')
            content = file_info.get('content', '')
            
            if not content:
                continue
            
            # Analyze based on language
            if language == "python" or filename.endswith('.py'):
                file_issues = self._analyze_python(filename, content)
            elif language == "javascript" or filename.endswith('.js'):
                file_issues = self._analyze_javascript(filename, content)
            elif language == "dart" or filename.endswith('.dart'):
                file_issues = self._analyze_dart(filename, content)
            else:
                continue
            
            # Categorize issues
            for issue in file_issues:
                if issue.category == "security":
                    results.security_issues.append(issue)
                elif issue.category == "complexity":
                    results.complexity_issues.append(issue)
                else:
                    results.linting_issues.append(issue)
        
        results.total_issues_found = (
            len(results.linting_issues) + 
            len(results.security_issues) + 
            len(results.complexity_issues)
        )
        
        return results
    
    def _analyze_python(self, filename: str, content: str) -> List[CodeIssue]:
        """
        Analyze Python code using pylint and bandit.
        
        Args:
            filename: Name of the file
            content: File content
            
        Returns:
            List of CodeIssue objects
        """
        issues = []
        
        # Write content to temporary file
        with tempfile.NamedTemporaryFile(
            mode='w', 
            suffix='.py', 
            delete=False
        ) as tmp_file:
            tmp_file.write(content)
            tmp_path = tmp_file.name
        
        try:
            # Run pylint
            issues.extend(self._run_pylint(tmp_path, filename))
            
            # Run bandit for security
            issues.extend(self._run_bandit(tmp_path, filename))
            
            # Run radon for complexity
            issues.extend(self._run_radon(tmp_path, filename))
            
        finally:
            # Clean up temporary file
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
        
        return issues
    
    def _run_pylint(self, file_path: str, original_filename: str) -> List[CodeIssue]:
        """Run pylint on a Python file."""
        issues = []
        try:
            result = subprocess.run(
                ['pylint', file_path, '--output-format=json'],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            # Parse pylint JSON output
            import json
            if result.stdout:
                lint_results = json.loads(result.stdout)
                for item in lint_results[:10]:  # Limit to first 10 issues
                    severity_map = {
                        'error': IssueSeverity.HIGH,
                        'warning': IssueSeverity.MEDIUM,
                        'convention': IssueSeverity.LOW,
                        'refactor': IssueSeverity.INFO,
                    }
                    
                    issues.append(CodeIssue(
                        file_path=original_filename,
                        line_number=item.get('line', 0),
                        severity=severity_map.get(item.get('type', 'warning'), IssueSeverity.MEDIUM),
                        category='quality',
                        message=item.get('message', ''),
                        rule_id=item.get('message-id', '')
                    ))
        except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError):
            # Pylint not available or error - skip
            pass
        
        return issues
    
    def _run_bandit(self, file_path: str, original_filename: str) -> List[CodeIssue]:
        """Run bandit security scanner on a Python file."""
        issues = []
        try:
            result = subprocess.run(
                ['bandit', file_path, '-f', 'json'],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            # Parse bandit JSON output
            import json
            if result.stdout:
                bandit_results = json.loads(result.stdout)
                for item in bandit_results.get('results', [])[:10]:
                    severity_map = {
                        'HIGH': IssueSeverity.CRITICAL,
                        'MEDIUM': IssueSeverity.HIGH,
                        'LOW': IssueSeverity.MEDIUM,
                    }
                    
                    issues.append(CodeIssue(
                        file_path=original_filename,
                        line_number=item.get('line_number', 0),
                        severity=severity_map.get(item.get('issue_severity', 'LOW'), IssueSeverity.MEDIUM),
                        category='security',
                        message=item.get('issue_text', ''),
                        rule_id=item.get('test_id', '')
                    ))
        except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError):
            # Bandit not available or error - skip
            pass
        
        return issues
    
    def _run_radon(self, file_path: str, original_filename: str) -> List[CodeIssue]:
        """Run radon complexity analysis on a Python file."""
        issues = []
        try:
            result = subprocess.run(
                ['radon', 'cc', file_path, '-j'],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            # Parse radon JSON output
            import json
            if result.stdout:
                radon_results = json.loads(result.stdout)
                for file_result in radon_results.values():
                    for item in file_result[:5]:  # Top 5 complex functions
                        complexity = item.get('complexity', 0)
                        if complexity > 10:  # Threshold for complex code
                            issues.append(CodeIssue(
                                file_path=original_filename,
                                line_number=item.get('lineno', 0),
                                severity=IssueSeverity.MEDIUM if complexity > 15 else IssueSeverity.LOW,
                                category='complexity',
                                message=f"High cyclomatic complexity ({complexity}) in {item.get('name', 'function')}",
                                suggestion="Consider breaking down this function into smaller pieces"
                            ))
        except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError):
            # Radon not available or error - skip
            pass
        
        return issues
    
    def _analyze_javascript(self, filename: str, content: str) -> List[CodeIssue]:
        """Analyze JavaScript code (placeholder for ESLint integration)."""
        # TODO: Implement ESLint integration
        return []
    
    def _analyze_dart(self, filename: str, content: str) -> List[CodeIssue]:
        """Analyze Dart code (placeholder for dart analyze integration)."""
        # TODO: Implement dart analyze integration
        return []
