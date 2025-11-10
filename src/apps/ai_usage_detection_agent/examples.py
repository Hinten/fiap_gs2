"""
Example usage scenarios for AI Usage Detection Agent.

This file demonstrates how to use the detection service programmatically.
"""

from src.models.schemas import AnalysisRequest, SubmissionType
from src.services.detection_service import AIUsageDetectionService


def example_analyze_human_text():
    """Example: Analyzing typical student text."""
    service = AIUsageDetectionService()
    
    request = AnalysisRequest(
        submission_id="sub-001",
        student_id="student-123",
        content="""
        Hey professor! So I worked on this assignment and it was pretty challenging.
        I tried several different approaches but kept running into bugs. Finally 
        figured it out after reviewing the lecture notes again. The solution isn't
        perfect but it works! Let me know if you have any questions.
        """,
        submission_type=SubmissionType.TEXT
    )
    
    result = service.analyze_submission(request)
    
    print(f"Analysis for submission {result.submission_id}")
    print(f"AI Usage Score: {result.ai_usage_score:.2%}")
    print(f"Category: {result.category.value}")
    print(f"Explanation: {result.explanation}")
    print(f"Requires Verification: {result.requires_verification}")
    print()


def example_analyze_ai_like_text():
    """Example: Analyzing AI-generated-like text."""
    service = AIUsageDetectionService()
    
    request = AnalysisRequest(
        submission_id="sub-002",
        student_id="student-456",
        content="""
        Artificial Intelligence represents a transformative paradigm shift in 
        computational capabilities. Furthermore, the integration of machine learning
        algorithms facilitates unprecedented optimization of complex systems.
        Moreover, deep learning architectures enable sophisticated pattern recognition.
        Consequently, organizations can leverage these advanced methodologies to 
        enhance operational efficiency and drive innovation. Additionally, the 
        implementation of neural networks demonstrates remarkable performance.
        """,
        submission_type=SubmissionType.TEXT
    )
    
    result = service.analyze_submission(request)
    
    print(f"Analysis for submission {result.submission_id}")
    print(f"AI Usage Score: {result.ai_usage_score:.2%}")
    print(f"Category: {result.category.value}")
    print(f"Flags: {', '.join(result.flags)}")
    print(f"Explanation: {result.explanation}")
    print(f"Recommended Action: {result.recommended_action}")
    print()


def example_analyze_student_code():
    """Example: Analyzing typical student code."""
    service = AIUsageDetectionService()
    
    code = """
# my fibonacci calculator
def fib(n):
    # start with 0 and 1
    a, b = 0, 1
    nums = []
    
    # loop n times
    for i in range(n):
        nums.append(a)
        a, b = b, a + b  # swap - this was tricky!
    
    return nums

# test it
print(fib(10))
    """
    
    request = AnalysisRequest(
        submission_id="sub-003",
        student_id="student-789",
        content=code,
        submission_type=SubmissionType.CODE
    )
    
    result = service.analyze_submission(request)
    
    print(f"Code Analysis for submission {result.submission_id}")
    print(f"AI Usage Score: {result.ai_usage_score:.2%}")
    print(f"Category: {result.category.value}")
    if result.code_features:
        print(f"Perfect Docstrings: {result.code_features.has_perfect_docstrings}")
        print(f"Type Hints: {result.code_features.has_type_hints}")
    print()


def example_analyze_ai_generated_code():
    """Example: Analyzing AI-generated-like code."""
    service = AIUsageDetectionService()
    
    code = '''
def calculate_fibonacci_sequence(n: int) -> list[int]:
    """
    This function calculates the Fibonacci sequence up to n terms.
    
    Args:
        n (int): The number of terms to generate
        
    Returns:
        list[int]: A list containing the Fibonacci sequence
        
    Raises:
        ValueError: If n is less than 1
    """
    if n < 1:
        raise ValueError("n must be at least 1")
    
    try:
        sequence = [0, 1]
        for i in range(2, n):
            sequence.append(sequence[i-1] + sequence[i-2])
        return sequence[:n]
    except Exception as e:
        raise RuntimeError(f"Error calculating sequence: {e}")
    '''
    
    request = AnalysisRequest(
        submission_id="sub-004",
        student_id="student-999",
        content=code,
        submission_type=SubmissionType.CODE
    )
    
    result = service.analyze_submission(request)
    
    print(f"Code Analysis for submission {result.submission_id}")
    print(f"AI Usage Score: {result.ai_usage_score:.2%}")
    print(f"Category: {result.category.value}")
    print(f"Flags: {', '.join(result.flags)}")
    if result.code_features:
        print(f"AI Patterns Detected: {len(result.code_features.ai_pattern_matches)}")
    print(f"Requires Verification: {result.requires_verification}")
    print()


def example_analyze_mixed_submission():
    """Example: Analyzing mixed text and code."""
    service = AIUsageDetectionService()
    
    content = """
# Assignment: Sorting Algorithm

I implemented a simple bubble sort algorithm for this assignment.
Here's my solution:

def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(0, n-i-1):
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
    return arr

I tested it with several lists and it works correctly!
    """
    
    request = AnalysisRequest(
        submission_id="sub-005",
        student_id="student-555",
        content=content,
        submission_type=SubmissionType.MIXED
    )
    
    result = service.analyze_submission(request)
    
    print(f"Mixed Analysis for submission {result.submission_id}")
    print(f"Overall AI Usage Score: {result.ai_usage_score:.2%}")
    print(f"Text AI Probability: {result.text_ai_probability:.2%}")
    print(f"Code AI Probability: {result.code_ai_probability:.2%}")
    print(f"Category: {result.category.value}")
    print(f"Confidence: {result.confidence:.2%}")
    print()


if __name__ == "__main__":
    print("=" * 60)
    print("AI Usage Detection Agent - Example Usage")
    print("=" * 60)
    print()
    
    print("Example 1: Analyzing Human-Written Text")
    print("-" * 60)
    example_analyze_human_text()
    
    print("Example 2: Analyzing AI-Like Text")
    print("-" * 60)
    example_analyze_ai_like_text()
    
    print("Example 3: Analyzing Student Code")
    print("-" * 60)
    example_analyze_student_code()
    
    print("Example 4: Analyzing AI-Generated-Like Code")
    print("-" * 60)
    example_analyze_ai_generated_code()
    
    print("Example 5: Analyzing Mixed Submission")
    print("-" * 60)
    example_analyze_mixed_submission()
    
    print("=" * 60)
    print("Examples completed!")
