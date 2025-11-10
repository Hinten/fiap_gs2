"""Code analysis service for detecting AI-generated code."""

import re
from typing import Dict, List, Tuple

from ..models.schemas import CodeAnalysisFeatures
from ..utils.logger import logger


class CodeAnalyzer:
    """Analyzes code to detect AI-generated content."""
    
    # AI-typical code patterns
    AI_COMMENT_PATTERNS = [
        r"# Function to ",
        r"# This function ",
        r"# Returns:",
        r"# Args:",
        r"# Parameters:",
        r'"""This function calculates',
        r'"""This method ',
        r"# Calculate the ",
        r"# Process the ",
        r"# Handle the "
    ]
    
    # Generic variable/function names common in AI-generated code
    GENERIC_NAMES = [
        "calculate_result", "process_data", "handle_request",
        "get_information", "perform_operation", "execute_task",
        "manage_resources", "handle_response", "process_input",
        "calculate_value", "get_data", "set_value"
    ]
    
    def analyze_code(self, code: str) -> Tuple[float, CodeAnalysisFeatures]:
        """
        Analyze code for AI generation patterns.
        
        Args:
            code: Code content to analyze
            
        Returns:
            Tuple of (ai_probability, features)
        """
        if not code or len(code.strip()) < 100:
            logger.warning("Code too short for reliable analysis")
            return 0.0, self._empty_features()
        
        features = self._extract_features(code)
        ai_probability = self._calculate_ai_probability(features)
        
        logger.info(
            "Code analysis complete",
            extra={
                "ai_probability": ai_probability,
                "has_docstrings": features.has_perfect_docstrings,
                "has_type_hints": features.has_type_hints
            }
        )
        
        return ai_probability, features
    
    def _extract_features(self, code: str) -> CodeAnalysisFeatures:
        """Extract code features for AI detection."""
        lines = code.split('\n')
        
        # Check for perfect documentation
        has_perfect_docstrings = self._check_perfect_docstrings(code)
        
        # Check for comprehensive error handling
        has_comprehensive_error_handling = self._check_error_handling(code)
        
        # Check for type hints
        has_type_hints = self._check_type_hints(code)
        
        # Calculate generic name ratio
        generic_name_ratio = self._calculate_generic_name_ratio(code)
        
        # Calculate comment formality
        comment_formality_score = self._calculate_comment_formality(code)
        
        # Detect AI patterns
        ai_pattern_matches = self._detect_ai_patterns(code)
        
        return CodeAnalysisFeatures(
            has_perfect_docstrings=has_perfect_docstrings,
            has_comprehensive_error_handling=has_comprehensive_error_handling,
            has_type_hints=has_type_hints,
            generic_name_ratio=generic_name_ratio,
            comment_formality_score=comment_formality_score,
            ai_pattern_matches=ai_pattern_matches
        )
    
    def _calculate_ai_probability(self, features: CodeAnalysisFeatures) -> float:
        """
        Calculate AI probability from code features.
        
        AI-generated code typically has:
        - Perfect docstrings everywhere
        - Comprehensive error handling
        - All functions have type hints
        - Generic, overly descriptive names
        - Very formal comments
        """
        score = 0.0
        
        # Perfect docstrings (unusual for students)
        if features.has_perfect_docstrings:
            score += 0.25
        
        # Comprehensive error handling
        if features.has_comprehensive_error_handling:
            score += 0.20
        
        # All functions have type hints
        if features.has_type_hints:
            score += 0.20
        
        # High ratio of generic names
        if features.generic_name_ratio > 0.5:
            score += 0.15
        elif features.generic_name_ratio > 0.3:
            score += 0.10
        
        # Formal comments
        if features.comment_formality_score > 0.7:
            score += 0.15
        elif features.comment_formality_score > 0.5:
            score += 0.10
        
        # Multiple AI patterns detected
        if len(features.ai_pattern_matches) > 3:
            score += 0.15
        elif len(features.ai_pattern_matches) > 1:
            score += 0.10
        
        return min(1.0, score)
    
    def _check_perfect_docstrings(self, code: str) -> bool:
        """Check if all functions have perfect docstrings."""
        # Find all function definitions
        function_pattern = r'def\s+\w+\s*\('
        functions = re.findall(function_pattern, code)
        
        if not functions:
            return False
        
        # Find all docstrings
        docstring_pattern = r'"""[\s\S]*?"""|\'\'\'[\s\S]*?\'\'\''
        docstrings = re.findall(docstring_pattern, code)
        
        # Check if ratio is very high (90%+)
        # This is suspicious for student code
        if len(functions) > 0:
            ratio = len(docstrings) / len(functions)
            return ratio >= 0.9
        
        return False
    
    def _check_error_handling(self, code: str) -> bool:
        """Check for comprehensive error handling."""
        # Count try-except blocks
        try_count = code.count('try:')
        except_count = code.count('except')
        
        # Count functions
        function_count = len(re.findall(r'def\s+\w+\s*\(', code))
        
        if function_count == 0:
            return False
        
        # If most functions have try-except, it's suspicious
        error_handling_ratio = try_count / max(function_count, 1)
        return error_handling_ratio >= 0.5
    
    def _check_type_hints(self, code: str) -> bool:
        """Check if all functions have type hints."""
        # Find functions with type hints
        typed_function_pattern = r'def\s+\w+\s*\([^)]*:\s*\w+[^)]*\)\s*->'
        typed_functions = re.findall(typed_function_pattern, code)
        
        # Find all functions
        all_functions = re.findall(r'def\s+\w+\s*\(', code)
        
        if not all_functions:
            return False
        
        # Check if ratio is very high
        ratio = len(typed_functions) / len(all_functions)
        return ratio >= 0.8
    
    def _calculate_generic_name_ratio(self, code: str) -> float:
        """Calculate ratio of generic names."""
        # Extract identifiers (functions and variables)
        identifiers = re.findall(r'\b[a-z_][a-z0-9_]*\b', code.lower())
        
        if not identifiers:
            return 0.0
        
        # Count generic names
        generic_count = sum(
            1 for name in self.GENERIC_NAMES
            if name in identifiers
        )
        
        return generic_count / len(set(identifiers))
    
    def _calculate_comment_formality(self, code: str) -> float:
        """Calculate formality of comments."""
        # Extract comments
        comments = re.findall(r'#.*$|"""[\s\S]*?"""|\'\'\'[\s\S]*?\'\'\'', 
                             code, re.MULTILINE)
        
        if not comments:
            return 0.0
        
        # Formal comment indicators
        formal_indicators = [
            'function to', 'this function', 'this method',
            'returns:', 'args:', 'parameters:', 'raises:',
            'note:', 'example:', 'description:'
        ]
        
        # Count formal comments
        formal_count = 0
        for comment in comments:
            comment_lower = comment.lower()
            if any(indicator in comment_lower for indicator in formal_indicators):
                formal_count += 1
        
        return formal_count / len(comments)
    
    def _detect_ai_patterns(self, code: str) -> List[str]:
        """Detect specific AI-generated patterns."""
        patterns = []
        
        for pattern in self.AI_COMMENT_PATTERNS:
            if re.search(pattern, code, re.IGNORECASE):
                patterns.append(pattern.replace('\\', ''))
        
        # Check for textbook-perfect structure
        if re.search(r'if __name__ == ["\']__main__["\']:', code):
            if 'def main(' in code:
                patterns.append("perfect_main_structure")
        
        # Check for overly descriptive docstrings
        if re.search(r'"""[\s\S]{200,}"""', code):
            patterns.append("very_long_docstrings")
        
        # Check for comprehensive imports
        imports = re.findall(r'^import\s+\w+|^from\s+\w+', code, re.MULTILINE)
        if len(imports) > 10:
            patterns.append("many_imports")
        
        return patterns
    
    def _empty_features(self) -> CodeAnalysisFeatures:
        """Return empty features for invalid input."""
        return CodeAnalysisFeatures(
            has_perfect_docstrings=False,
            has_comprehensive_error_handling=False,
            has_type_hints=False,
            generic_name_ratio=0.0,
            comment_formality_score=0.0,
            ai_pattern_matches=[]
        )
