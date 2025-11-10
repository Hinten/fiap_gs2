"""Text analysis service for detecting AI-generated text."""

import re
import math
from typing import Dict, List, Tuple
from collections import Counter

from ..models.schemas import TextAnalysisFeatures
from ..utils.logger import logger


class TextAnalyzer:
    """Analyzes text to detect AI-generated content."""
    
    # AI-typical transitional phrases
    TRANSITIONAL_PHRASES = [
        "furthermore", "moreover", "additionally", "consequently",
        "nevertheless", "nonetheless", "therefore", "thus",
        "hence", "accordingly", "subsequently", "in conclusion",
        "to summarize", "in summary", "as a result"
    ]
    
    # Formal vocabulary indicators
    FORMAL_WORDS = [
        "utilize", "commence", "terminate", "endeavor", "facilitate",
        "optimize", "implement", "demonstrate", "establish", "acquire"
    ]
    
    def analyze_text(self, text: str) -> Tuple[float, TextAnalysisFeatures]:
        """
        Analyze text for AI generation patterns.
        
        Args:
            text: Text content to analyze
            
        Returns:
            Tuple of (ai_probability, features)
        """
        if not text or len(text.strip()) < 50:
            logger.warning("Text too short for reliable analysis")
            return 0.0, self._empty_features()
        
        features = self._extract_features(text)
        ai_probability = self._calculate_ai_probability(features)
        
        logger.info(
            "Text analysis complete",
            extra={
                "ai_probability": ai_probability,
                "perplexity": features.perplexity,
                "formality": features.formality_score
            }
        )
        
        return ai_probability, features
    
    def _extract_features(self, text: str) -> TextAnalysisFeatures:
        """Extract statistical features from text."""
        text_lower = text.lower()
        
        # Split into sentences and words
        sentences = self._split_sentences(text)
        words = text.split()
        
        # Calculate features
        perplexity = self._calculate_perplexity(text)
        burstiness = self._calculate_burstiness(sentences)
        avg_sentence_length = self._average_sentence_length(sentences)
        vocabulary_richness = len(set(words)) / max(len(words), 1)
        formality_score = self._calculate_formality(text_lower, words)
        transitional_count = self._count_transitional_phrases(text_lower)
        
        return TextAnalysisFeatures(
            perplexity=perplexity,
            burstiness=burstiness,
            avg_sentence_length=avg_sentence_length,
            vocabulary_richness=vocabulary_richness,
            formality_score=formality_score,
            transitional_phrases_count=transitional_count
        )
    
    def _calculate_ai_probability(self, features: TextAnalysisFeatures) -> float:
        """
        Calculate AI probability from features.
        
        AI-generated text typically has:
        - Low perplexity (too perfect)
        - Low burstiness (uniform complexity)
        - High formality
        - Many transitional phrases
        """
        score = 0.0
        
        # Low perplexity indicates AI (inverse scoring)
        if features.perplexity < 20:
            score += 0.25
        elif features.perplexity < 30:
            score += 0.15
        
        # Low burstiness indicates AI
        if features.burstiness < 0.3:
            score += 0.20
        elif features.burstiness < 0.5:
            score += 0.10
        
        # High formality indicates AI
        if features.formality_score > 0.7:
            score += 0.20
        elif features.formality_score > 0.5:
            score += 0.10
        
        # Many transitional phrases indicates AI
        if features.transitional_phrases_count > 5:
            score += 0.20
        elif features.transitional_phrases_count > 2:
            score += 0.10
        
        # Very high vocabulary richness can also indicate AI
        if features.vocabulary_richness > 0.8:
            score += 0.15
        
        return min(1.0, score)
    
    def _calculate_perplexity(self, text: str) -> float:
        """
        Calculate text perplexity (simplified version).
        
        Lower perplexity = more predictable text (AI-like)
        Higher perplexity = more surprising/natural text (human-like)
        """
        words = text.lower().split()
        if len(words) < 2:
            return 50.0
        
        # Calculate word frequencies
        word_counts = Counter(words)
        total_words = len(words)
        
        # Calculate entropy
        entropy = 0.0
        for count in word_counts.values():
            p = count / total_words
            entropy -= p * math.log2(p)
        
        # Convert to perplexity
        perplexity = 2 ** entropy
        
        # Normalize to reasonable range (0-100)
        return min(100.0, perplexity * 5)
    
    def _calculate_burstiness(self, sentences: List[str]) -> float:
        """
        Calculate burstiness (variation in sentence complexity).
        
        Low burstiness = uniform complexity (AI-like)
        High burstiness = varying complexity (human-like)
        """
        if len(sentences) < 2:
            return 0.5
        
        # Calculate sentence lengths
        lengths = [len(s.split()) for s in sentences if s.strip()]
        if not lengths:
            return 0.5
        
        # Calculate coefficient of variation
        mean_length = sum(lengths) / len(lengths)
        if mean_length == 0:
            return 0.5
        
        variance = sum((x - mean_length) ** 2 for x in lengths) / len(lengths)
        std_dev = math.sqrt(variance)
        
        cv = std_dev / mean_length
        
        # Normalize to 0-1 range
        return min(1.0, cv)
    
    def _average_sentence_length(self, sentences: List[str]) -> float:
        """Calculate average sentence length in words."""
        if not sentences:
            return 0.0
        
        total_words = sum(len(s.split()) for s in sentences if s.strip())
        return total_words / len(sentences)
    
    def _calculate_formality(self, text_lower: str, words: List[str]) -> float:
        """
        Calculate text formality score.
        
        Higher score = more formal (AI-like)
        """
        if not words:
            return 0.0
        
        # Count formal words
        formal_count = sum(
            1 for word in self.FORMAL_WORDS if word in text_lower
        )
        
        # Count contractions (informal)
        contraction_count = len(re.findall(r"\w+n't|\w+'ll|\w+'re|\w+'ve", text_lower))
        
        # Calculate formality ratio
        formality = (formal_count * 2 - contraction_count) / len(words)
        
        # Normalize to 0-1 range
        return max(0.0, min(1.0, formality * 10 + 0.5))
    
    def _count_transitional_phrases(self, text_lower: str) -> int:
        """Count AI-typical transitional phrases."""
        count = 0
        for phrase in self.TRANSITIONAL_PHRASES:
            count += text_lower.count(phrase)
        return count
    
    def _split_sentences(self, text: str) -> List[str]:
        """Split text into sentences."""
        # Simple sentence splitting
        sentences = re.split(r'[.!?]+', text)
        return [s.strip() for s in sentences if s.strip()]
    
    def _empty_features(self) -> TextAnalysisFeatures:
        """Return empty features for invalid input."""
        return TextAnalysisFeatures(
            perplexity=0.0,
            burstiness=0.0,
            avg_sentence_length=0.0,
            vocabulary_richness=0.0,
            formality_score=0.0,
            transitional_phrases_count=0
        )
