"""Tests for text analyzer."""

import pytest
from src.services.text_analyzer import TextAnalyzer


@pytest.fixture
def analyzer():
    """Create text analyzer instance."""
    return TextAnalyzer()


def test_analyze_empty_text(analyzer):
    """Test handling of empty text."""
    ai_prob, features = analyzer.analyze_text("")
    assert ai_prob == 0.0
    assert features.perplexity == 0.0


def test_analyze_short_text(analyzer):
    """Test handling of very short text."""
    ai_prob, features = analyzer.analyze_text("Hi there!")
    assert ai_prob == 0.0  # Too short for analysis


def test_analyze_human_like_text(analyzer):
    """Test analysis of natural human text."""
    text = """
    Hey! So I was working on this assignment and honestly it was pretty tough.
    I tried a few different approaches but kept getting errors. Finally figured
    it out after looking at the lecture notes again. The code is kinda messy
    but it works lol.
    """
    
    ai_prob, features = analyzer.analyze_text(text)
    
    # Human text should have low AI probability
    assert ai_prob < 0.5
    
    # Should have some burstiness (variation)
    assert features.burstiness > 0.2
    
    # Should not be too formal
    assert features.formality_score < 0.7


def test_analyze_ai_like_text(analyzer):
    """Test analysis of AI-generated-like text."""
    text = """
    Artificial Intelligence is a transformative technology that has 
    revolutionized numerous sectors. Furthermore, it presents unprecedented 
    opportunities for innovation. Moreover, the integration of AI systems 
    enables organizations to optimize their operational efficiency. 
    Consequently, businesses can leverage these capabilities to enhance 
    their competitive advantage. Additionally, the implementation of 
    machine learning algorithms facilitates data-driven decision making.
    """
    
    ai_prob, features = analyzer.analyze_text(text)
    
    # AI text should have higher probability
    assert ai_prob > 0.5
    
    # Should be very formal
    assert features.formality_score > 0.4
    
    # Should have many transitional phrases
    assert features.transitional_phrases_count > 3


def test_perplexity_calculation(analyzer):
    """Test perplexity calculation."""
    # Repetitive text (low perplexity)
    repetitive = "the the the the the cat cat cat"
    perplexity_low = analyzer._calculate_perplexity(repetitive)
    
    # Diverse text (higher perplexity)
    diverse = "quick brown fox jumps over lazy dog"
    perplexity_high = analyzer._calculate_perplexity(diverse)
    
    assert perplexity_high > perplexity_low


def test_burstiness_calculation(analyzer):
    """Test burstiness calculation."""
    # Uniform sentences (low burstiness)
    uniform_sentences = [
        "This is a sentence.",
        "This is another one.",
        "This is one more."
    ]
    burstiness_low = analyzer._calculate_burstiness(uniform_sentences)
    
    # Varied sentences (high burstiness)
    varied_sentences = [
        "Hi!",
        "This is a medium length sentence with several words.",
        "Short one."
    ]
    burstiness_high = analyzer._calculate_burstiness(varied_sentences)
    
    assert burstiness_high > burstiness_low


def test_formality_score(analyzer):
    """Test formality score calculation."""
    informal = "gonna try this. it's kinda cool. won't work tho"
    formal = "I shall endeavor to utilize this methodology to facilitate optimization"
    
    # Extract words for formal text
    formal_words = formal.split()
    informal_words = informal.split()
    
    formal_score = analyzer._calculate_formality(formal.lower(), formal_words)
    informal_score = analyzer._calculate_formality(informal.lower(), informal_words)
    
    assert formal_score > informal_score


def test_transitional_phrases_count(analyzer):
    """Test counting of transitional phrases."""
    text_with_transitions = """
    Furthermore, this is important. Moreover, we should consider this.
    Consequently, the result is clear.
    """
    
    text_without = "This is simple. We know the answer. It works."
    
    count_with = analyzer._count_transitional_phrases(text_with_transitions.lower())
    count_without = analyzer._count_transitional_phrases(text_without.lower())
    
    assert count_with > count_without
    assert count_with >= 3


def test_sentence_splitting(analyzer):
    """Test sentence splitting."""
    text = "First sentence. Second sentence! Third sentence?"
    sentences = analyzer._split_sentences(text)
    
    assert len(sentences) == 3
    assert "First sentence" in sentences[0]


def test_average_sentence_length(analyzer):
    """Test average sentence length calculation."""
    sentences = [
        "Short one.",
        "This is a longer sentence with more words.",
        "Medium length here."
    ]
    
    avg_length = analyzer._average_sentence_length(sentences)
    assert avg_length > 2
    assert avg_length < 10
