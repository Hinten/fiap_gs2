"""Tests for detection service."""

import pytest
from src.models.schemas import (
    AnalysisRequest,
    SubmissionType,
    AIUsageCategory
)
from src.services.detection_service import AIUsageDetectionService


@pytest.fixture
def service():
    """Create detection service instance."""
    return AIUsageDetectionService()


def test_analyze_text_submission(service):
    """Test analyzing a text submission."""
    request = AnalysisRequest(
        submission_id="test-001",
        student_id="student-123",
        content="This is a simple test submission with natural language.",
        submission_type=SubmissionType.TEXT
    )
    
    analysis = service.analyze_submission(request)
    
    assert analysis.submission_id == "test-001"
    assert analysis.student_id == "student-123"
    assert 0.0 <= analysis.ai_usage_score <= 1.0
    assert analysis.category in AIUsageCategory
    assert analysis.text_ai_probability is not None
    assert analysis.code_ai_probability is None


def test_analyze_code_submission(service):
    """Test analyzing a code submission."""
    code = """
def hello():
    print("Hello, world!")

hello()
    """
    
    request = AnalysisRequest(
        submission_id="test-002",
        student_id="student-123",
        content=code,
        submission_type=SubmissionType.CODE
    )
    
    analysis = service.analyze_submission(request)
    
    assert analysis.submission_id == "test-002"
    assert analysis.code_ai_probability is not None
    assert analysis.text_ai_probability is None
    assert analysis.code_features is not None


def test_analyze_mixed_submission(service):
    """Test analyzing a mixed submission."""
    content = """
# My Assignment
This is the explanation of my code.

def calculate(x):
    return x * 2
    """
    
    request = AnalysisRequest(
        submission_id="test-003",
        student_id="student-123",
        content=content,
        submission_type=SubmissionType.MIXED
    )
    
    analysis = service.analyze_submission(request)
    
    assert analysis.text_ai_probability is not None
    assert analysis.code_ai_probability is not None
    assert analysis.text_features is not None
    assert analysis.code_features is not None


def test_categorization_appropriate(service):
    """Test appropriate usage categorization."""
    category = service._categorize_usage(0.20)
    assert category == AIUsageCategory.APPROPRIATE


def test_categorization_moderate(service):
    """Test moderate usage categorization."""
    category = service._categorize_usage(0.45)
    assert category == AIUsageCategory.MODERATE


def test_categorization_questionable(service):
    """Test questionable usage categorization."""
    category = service._categorize_usage(0.70)
    assert category == AIUsageCategory.QUESTIONABLE


def test_categorization_inadequate(service):
    """Test inadequate usage categorization."""
    category = service._categorize_usage(0.90)
    assert category == AIUsageCategory.INADEQUATE


def test_flag_generation(service):
    """Test flag generation."""
    from src.models.schemas import TextAnalysisFeatures, CodeAnalysisFeatures
    
    text_features = TextAnalysisFeatures(
        perplexity=15.0,  # Low
        burstiness=0.2,  # Low
        avg_sentence_length=15.0,
        vocabulary_richness=0.7,
        formality_score=0.8,  # High
        transitional_phrases_count=6  # Many
    )
    
    code_features = CodeAnalysisFeatures(
        has_perfect_docstrings=True,
        has_comprehensive_error_handling=True,
        has_type_hints=True,
        generic_name_ratio=0.6,
        comment_formality_score=0.8,
        ai_pattern_matches=["pattern1", "pattern2", "pattern3"]
    )
    
    flags = service._generate_flags(0.8, 0.8, text_features, code_features)
    
    assert "low_perplexity" in flags
    assert "low_burstiness" in flags
    assert "excessive_formality" in flags
    assert "many_transitional_phrases" in flags
    assert "perfect_docstrings" in flags


def test_verification_requirement(service):
    """Test verification requirement logic."""
    # Appropriate - no verification
    request_low = AnalysisRequest(
        submission_id="test-004",
        student_id="student-123",
        content="Simple natural text that is clearly human written.",
        submission_type=SubmissionType.TEXT
    )
    analysis_low = service.analyze_submission(request_low)
    
    # High AI score should require verification
    ai_text = """
    Furthermore, artificial intelligence presents unprecedented opportunities.
    Moreover, the integration of machine learning algorithms facilitates
    optimization. Consequently, organizations can leverage these capabilities.
    Additionally, the implementation enables enhanced efficiency.
    """
    
    request_high = AnalysisRequest(
        submission_id="test-005",
        student_id="student-123",
        content=ai_text,
        submission_type=SubmissionType.TEXT
    )
    analysis_high = service.analyze_submission(request_high)
    
    # If high score, should require verification
    if analysis_high.ai_usage_score > 0.6:
        assert analysis_high.requires_verification


def test_recommended_actions(service):
    """Test recommended actions for each category."""
    action_appropriate = service._recommend_action(AIUsageCategory.APPROPRIATE)
    action_moderate = service._recommend_action(AIUsageCategory.MODERATE)
    action_questionable = service._recommend_action(AIUsageCategory.QUESTIONABLE)
    action_inadequate = service._recommend_action(AIUsageCategory.INADEQUATE)
    
    assert "No action" in action_appropriate
    assert "Review" in action_moderate
    assert "verification" in action_questionable
    assert "re-submission" in action_inadequate


def test_confidence_calculation(service):
    """Test confidence calculation."""
    # Mixed submission with both scores = high confidence
    confidence_mixed = service._calculate_confidence(0.5, 0.6, SubmissionType.MIXED)
    assert confidence_mixed >= 0.80
    
    # Single type = moderate confidence
    confidence_text = service._calculate_confidence(0.5, None, SubmissionType.TEXT)
    assert confidence_text >= 0.70


def test_explanation_generation(service):
    """Test explanation generation."""
    explanation = service._generate_explanation(
        score=0.85,
        category=AIUsageCategory.INADEQUATE,
        flags=["low_perplexity", "perfect_docstrings"],
        submission_type=SubmissionType.MIXED
    )
    
    assert len(explanation) > 0
    assert "AI-generated" in explanation or "inadequate" in explanation.lower()


def test_overall_score_calculation_text(service):
    """Test overall score calculation for text."""
    score = service._calculate_overall_score(0.7, None, SubmissionType.TEXT)
    assert score == 0.7


def test_overall_score_calculation_code(service):
    """Test overall score calculation for code."""
    score = service._calculate_overall_score(None, 0.8, SubmissionType.CODE)
    assert score == 0.8


def test_overall_score_calculation_mixed(service):
    """Test overall score calculation for mixed."""
    score = service._calculate_overall_score(0.6, 0.8, SubmissionType.MIXED)
    assert 0.6 <= score <= 0.8  # Should be weighted average
