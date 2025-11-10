"""Service for plagiarism detection using code similarity analysis."""

import hashlib
from typing import List, Dict, Any, Optional
from datetime import datetime
import uuid

from ..models import PlagiarismReport


class PlagiarismDetectionService:
    """Service for detecting code plagiarism and similarity."""
    
    def __init__(self):
        """Initialize plagiarism detection service."""
        self.similarity_threshold = 0.85
    
    def check_plagiarism(
        self,
        code_content: str,
        repo_name: str,
        comparison_repos: Optional[List[Dict[str, str]]] = None
    ) -> PlagiarismReport:
        """
        Check code for plagiarism against other submissions.
        
        Args:
            code_content: The code to check
            repo_name: Name of the repository being checked
            comparison_repos: Optional list of repos to compare against
            
        Returns:
            PlagiarismReport with similarity scores and findings
        """
        report_id = str(uuid.uuid4())
        similar_files = []
        sources_found = []
        max_similarity = 0.0
        most_similar_repo = None
        
        # Normalize code for comparison
        normalized_code = self._normalize_code(code_content)
        code_hash = self._hash_code(normalized_code)
        
        # If comparison repos provided, check against them
        if comparison_repos:
            for repo in comparison_repos:
                repo_code = repo.get('content', '')
                similarity = self._calculate_similarity(
                    normalized_code,
                    self._normalize_code(repo_code)
                )
                
                if similarity > self.similarity_threshold:
                    similar_files.append({
                        'repo': repo.get('name', 'unknown'),
                        'file': repo.get('file', 'unknown'),
                        'similarity': similarity,
                        'matched_lines': self._find_matched_lines(
                            normalized_code,
                            self._normalize_code(repo_code)
                        )
                    })
                    
                    if similarity > max_similarity:
                        max_similarity = similarity
                        most_similar_repo = repo.get('name')
        
        # Check for common patterns that might indicate copied code
        common_sources = self._check_common_sources(code_content)
        sources_found.extend(common_sources)
        
        # Create report
        report = PlagiarismReport(
            report_id=report_id,
            repo_a=repo_name,
            repo_b=most_similar_repo,
            similarity_score=max_similarity,
            similar_files=similar_files,
            sources_found=sources_found,
            created_at=datetime.utcnow()
        )
        
        return report
    
    def _normalize_code(self, code: str) -> str:
        """
        Normalize code by removing comments, whitespace, and formatting.
        
        Args:
            code: Raw code string
            
        Returns:
            Normalized code string
        """
        lines = []
        for line in code.split('\n'):
            # Remove comments
            if '#' in line:
                line = line[:line.index('#')]
            
            # Strip whitespace and convert to lowercase
            line = line.strip().lower()
            
            # Skip empty lines
            if line:
                lines.append(line)
        
        return '\n'.join(lines)
    
    def _hash_code(self, code: str) -> str:
        """
        Create a hash of the code for quick comparison.
        
        Args:
            code: Code string
            
        Returns:
            SHA256 hash of the code
        """
        return hashlib.sha256(code.encode('utf-8')).hexdigest()
    
    def _calculate_similarity(self, code1: str, code2: str) -> float:
        """
        Calculate similarity between two code snippets using simple difflib.
        
        Args:
            code1: First code string
            code2: Second code string
            
        Returns:
            Similarity score between 0 and 1
        """
        from difflib import SequenceMatcher
        
        matcher = SequenceMatcher(None, code1, code2)
        return matcher.ratio()
    
    def _find_matched_lines(self, code1: str, code2: str) -> List[int]:
        """
        Find line numbers that match between two code snippets.
        
        Args:
            code1: First code string
            code2: Second code string
            
        Returns:
            List of line numbers with matches
        """
        lines1 = code1.split('\n')
        lines2 = code2.split('\n')
        matched_lines = []
        
        for i, line1 in enumerate(lines1):
            if line1 in lines2:
                matched_lines.append(i + 1)
        
        return matched_lines[:10]  # Return first 10 matches
    
    def _check_common_sources(self, code: str) -> List[str]:
        """
        Check for common patterns that indicate copied code.
        
        Args:
            code: Code string to check
            
        Returns:
            List of potential sources
        """
        sources = []
        
        # Common patterns that suggest copied code
        common_patterns = [
            ('stackoverflow.com', 'Stack Overflow'),
            ('github.com', 'GitHub'),
            ('geeksforgeeks.org', 'GeeksforGeeks'),
            ('w3schools.com', 'W3Schools'),
            ('tutorialspoint.com', 'TutorialsPoint'),
        ]
        
        code_lower = code.lower()
        
        for pattern, source_name in common_patterns:
            if pattern in code_lower:
                sources.append(f"{source_name} (URL found in code)")
        
        return sources
    
    def calculate_code_fingerprint(self, code: str) -> str:
        """
        Generate a fingerprint for code based on structure.
        
        This can be used for more advanced similarity detection
        using Abstract Syntax Trees (AST).
        
        Args:
            code: Code string
            
        Returns:
            Fingerprint string
        """
        # TODO: Implement AST-based fingerprinting for better detection
        # For now, use normalized code hash
        normalized = self._normalize_code(code)
        return self._hash_code(normalized)
    
    def batch_check_submissions(
        self,
        submissions: List[Dict[str, str]]
    ) -> List[PlagiarismReport]:
        """
        Check multiple submissions against each other for plagiarism.
        
        Args:
            submissions: List of submission dicts with 'repo', 'content'
            
        Returns:
            List of PlagiarismReport objects for suspicious pairs
        """
        reports = []
        
        # Compare each submission with every other submission
        for i, submission_a in enumerate(submissions):
            for submission_b in submissions[i+1:]:
                similarity = self._calculate_similarity(
                    self._normalize_code(submission_a['content']),
                    self._normalize_code(submission_b['content'])
                )
                
                if similarity > self.similarity_threshold:
                    report = PlagiarismReport(
                        report_id=str(uuid.uuid4()),
                        repo_a=submission_a['repo'],
                        repo_b=submission_b['repo'],
                        similarity_score=similarity,
                        similar_files=[],
                        sources_found=[],
                        created_at=datetime.utcnow()
                    )
                    reports.append(report)
        
        return reports
