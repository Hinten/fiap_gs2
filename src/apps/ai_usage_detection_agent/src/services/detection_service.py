"""Main AI usage detection service."""

from datetime import datetime
from typing import Optional
import uuid

from ..models.schemas import (
    AnalysisRequest,
    AIUsageAnalysis,
    AIUsageCategory,
    SubmissionType,
    TextAnalysisFeatures,
    CodeAnalysisFeatures
)
from ..services.text_analyzer import TextAnalyzer
from ..services.code_analyzer import CodeAnalyzer
from ..utils.config import settings
from ..utils.logger import logger


class AIUsageDetectionService:
    """Main service for detecting AI usage in submissions."""
    
    def __init__(self):
        """Initialize detection service with analyzers."""
        self.text_analyzer = TextAnalyzer()
        self.code_analyzer = CodeAnalyzer()
    
    def analyze_submission(self, request: AnalysisRequest) -> AIUsageAnalysis:
        """
        Analyze a submission for AI usage.
        
        Args:
            request: Analysis request with submission details
            
        Returns:
            Complete AI usage analysis
        """
        logger.info(
            "Starting submission analysis",
            extra={
                "submission_id": request.submission_id,
                "student_id": request.student_id,
                "type": request.submission_type
            }
        )
        
        # Analyze based on submission type
        text_prob = None
        code_prob = None
        text_features = None
        code_features = None
        
        if request.submission_type in [SubmissionType.TEXT, SubmissionType.MIXED]:
            text_prob, text_features = self.text_analyzer.analyze_text(
                request.content
            )
        
        if request.submission_type in [SubmissionType.CODE, SubmissionType.MIXED]:
            code_prob, code_features = self.code_analyzer.analyze_code(
                request.content
            )
        
        # Calculate overall AI usage score
        ai_usage_score = self._calculate_overall_score(
            text_prob=text_prob,
            code_prob=code_prob,
            submission_type=request.submission_type
        )
        
        # Determine category
        category = self._categorize_usage(ai_usage_score)
        
        # Generate flags and explanation
        flags = self._generate_flags(
            text_prob, code_prob, text_features, code_features
        )
        explanation = self._generate_explanation(
            ai_usage_score, category, flags, request.submission_type
        )
        
        # Determine if verification is required
        requires_verification = (
            category in [AIUsageCategory.QUESTIONABLE, AIUsageCategory.INADEQUATE]
        )
        
        # Recommend action
        recommended_action = self._recommend_action(category)
        
        # Calculate confidence
        confidence = self._calculate_confidence(
            text_prob, code_prob, request.submission_type
        )
        
        analysis = AIUsageAnalysis(
            analysis_id=str(uuid.uuid4()),
            submission_id=request.submission_id,
            student_id=request.student_id,
            analyzed_at=datetime.utcnow(),
            ai_usage_score=ai_usage_score,
            category=category,
            text_ai_probability=text_prob,
            code_ai_probability=code_prob,
            text_features=text_features,
            code_features=code_features,
            flags=flags,
            explanation=explanation,
            confidence=confidence,
            requires_verification=requires_verification,
            recommended_action=recommended_action
        )
        
        logger.info(
            "Analysis complete",
            extra={
                "submission_id": request.submission_id,
                "ai_usage_score": ai_usage_score,
                "category": category.value,
                "requires_verification": requires_verification
            }
        )
        
        return analysis
    
    def _calculate_overall_score(
        self,
        text_prob: Optional[float],
        code_prob: Optional[float],
        submission_type: SubmissionType
    ) -> float:
        """Calculate weighted overall AI usage score."""
        score = 0.0
        
        if submission_type == SubmissionType.TEXT:
            score = text_prob if text_prob is not None else 0.0
        elif submission_type == SubmissionType.CODE:
            score = code_prob if code_prob is not None else 0.0
        elif submission_type == SubmissionType.MIXED:
            # Use weighted average
            text_weight = settings.text_ai_weight
            code_weight = settings.code_ai_weight
            total_weight = text_weight + code_weight
            
            text_component = (text_prob or 0.0) * text_weight
            code_component = (code_prob or 0.0) * code_weight
            
            score = (text_component + code_component) / total_weight
        
        return round(score, 3)
    
    def _categorize_usage(self, score: float) -> AIUsageCategory:
        """Categorize AI usage based on score."""
        if score <= settings.ai_usage_threshold_moderate:
            return AIUsageCategory.APPROPRIATE
        elif score <= settings.ai_usage_threshold_questionable:
            return AIUsageCategory.MODERATE
        elif score <= settings.ai_usage_threshold_inadequate:
            return AIUsageCategory.QUESTIONABLE
        else:
            return AIUsageCategory.INADEQUATE
    
    def _generate_flags(
        self,
        text_prob: Optional[float],
        code_prob: Optional[float],
        text_features: Optional[TextAnalysisFeatures],
        code_features: Optional[CodeAnalysisFeatures]
    ) -> list[str]:
        """Generate list of detected issues."""
        flags = []
        
        # Text-related flags
        if text_prob and text_prob > 0.7:
            flags.append("high_text_ai_probability")
        
        if text_features:
            if text_features.perplexity < 20:
                flags.append("low_perplexity")
            if text_features.burstiness < 0.3:
                flags.append("low_burstiness")
            if text_features.formality_score > 0.7:
                flags.append("excessive_formality")
            if text_features.transitional_phrases_count > 5:
                flags.append("many_transitional_phrases")
        
        # Code-related flags
        if code_prob and code_prob > 0.7:
            flags.append("high_code_ai_probability")
        
        if code_features:
            if code_features.has_perfect_docstrings:
                flags.append("perfect_docstrings")
            if code_features.has_comprehensive_error_handling:
                flags.append("comprehensive_error_handling")
            if code_features.has_type_hints:
                flags.append("all_functions_typed")
            if code_features.generic_name_ratio > 0.5:
                flags.append("generic_naming")
            if len(code_features.ai_pattern_matches) > 2:
                flags.append("multiple_ai_patterns")
        
        return flags
    
    def _generate_explanation(
        self,
        score: float,
        category: AIUsageCategory,
        flags: list[str],
        submission_type: SubmissionType
    ) -> str:
        """Generate human-readable explanation."""
        explanations = {
            AIUsageCategory.APPROPRIATE: (
                "This submission shows minimal or appropriate use of AI tools. "
                "The content appears to be primarily student-generated with "
                "possible minor AI assistance."
            ),
            AIUsageCategory.MODERATE: (
                "This submission shows moderate use of AI tools. "
                "While AI assistance is evident, there are signs of student "
                "involvement and understanding."
            ),
            AIUsageCategory.QUESTIONABLE: (
                "This submission shows significant AI usage that raises concerns. "
                "Comprehension verification is recommended to ensure the student "
                "understands the content."
            ),
            AIUsageCategory.INADEQUATE: (
                "This submission appears to be primarily AI-generated with "
                "minimal student contribution. This likely violates academic "
                "integrity policies."
            )
        }
        
        base_explanation = explanations[category]
        
        # Add specific flags
        if flags:
            flag_descriptions = []
            if "low_perplexity" in flags:
                flag_descriptions.append("text is unusually predictable")
            if "excessive_formality" in flags:
                flag_descriptions.append("excessively formal language")
            if "perfect_docstrings" in flags:
                flag_descriptions.append("perfect documentation (unusual for students)")
            if "multiple_ai_patterns" in flags:
                flag_descriptions.append("multiple AI-typical patterns detected")
            
            if flag_descriptions:
                base_explanation += f" Specific indicators: {', '.join(flag_descriptions)}."
        
        return base_explanation
    
    def _recommend_action(self, category: AIUsageCategory) -> str:
        """Recommend next steps based on category."""
        actions = {
            AIUsageCategory.APPROPRIATE: (
                "No action required. Accept submission."
            ),
            AIUsageCategory.MODERATE: (
                "Review submission. Consider asking student about their process."
            ),
            AIUsageCategory.QUESTIONABLE: (
                "Require comprehension verification. Student should explain "
                "their work and answer questions about key concepts."
            ),
            AIUsageCategory.INADEQUATE: (
                "Require re-submission with original work. Consider academic "
                "integrity review. Student should meet with instructor."
            )
        }
        return actions[category]
    
    def _calculate_confidence(
        self,
        text_prob: Optional[float],
        code_prob: Optional[float],
        submission_type: SubmissionType
    ) -> float:
        """Calculate confidence in the analysis."""
        # Higher confidence when we have more data
        if submission_type == SubmissionType.MIXED:
            if text_prob is not None and code_prob is not None:
                return 0.85
            return 0.70
        else:
            # Single type analysis
            return 0.80
