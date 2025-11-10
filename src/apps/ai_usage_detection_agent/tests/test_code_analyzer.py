"""Tests for code analyzer."""

import pytest
from src.services.code_analyzer import CodeAnalyzer


@pytest.fixture
def analyzer():
    """Create code analyzer instance."""
    return CodeAnalyzer()


def test_analyze_empty_code(analyzer):
    """Test handling of empty code."""
    ai_prob, features = analyzer.analyze_code("")
    assert ai_prob == 0.0
    assert not features.has_perfect_docstrings


def test_analyze_short_code(analyzer):
    """Test handling of very short code."""
    ai_prob, features = analyzer.analyze_code("x = 1")
    assert ai_prob == 0.0  # Too short


def test_analyze_student_code(analyzer):
    """Test analysis of typical student code."""
    code = """
# my fibonacci function
def fib(n):
    # start with 0 and 1
    a, b = 0, 1
    result = []
    
    # loop n times
    for _ in range(n):
        result.append(a)
        a, b = b, a + b  # this part was tricky!
    
    return result

# test it
print(fib(10))
    """
    
    ai_prob, features = analyzer.analyze_code(code)
    
    # Student code should have low AI probability
    assert ai_prob < 0.5
    
    # Should not have perfect docstrings
    assert not features.has_perfect_docstrings
    
    # Should not have type hints everywhere
    assert not features.has_type_hints


def test_analyze_ai_generated_code(analyzer):
    """Test analysis of AI-generated-like code."""
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


def process_data(input_data: dict) -> dict:
    """
    This function processes the input data and returns the result.
    
    Args:
        input_data (dict): The data to process
        
    Returns:
        dict: The processed result
    """
    try:
        result = calculate_result(input_data)
        return result
    except Exception as e:
        print(f"Error: {e}")
        return {}
    '''
    
    ai_prob, features = analyzer.analyze_code(code)
    
    # AI code should have higher probability
    assert ai_prob > 0.6
    
    # Should have perfect docstrings
    assert features.has_perfect_docstrings
    
    # Should have type hints
    assert features.has_type_hints
    
    # Should have comprehensive error handling
    assert features.has_comprehensive_error_handling


def test_check_perfect_docstrings(analyzer):
    """Test perfect docstring detection."""
    code_with_docs = '''
def func1():
    """Docstring 1"""
    pass

def func2():
    """Docstring 2"""
    pass

def func3():
    """Docstring 3"""
    pass
    '''
    
    code_without_docs = '''
def func1():
    pass

def func2():
    # just a comment
    pass
    '''
    
    assert analyzer._check_perfect_docstrings(code_with_docs)
    assert not analyzer._check_perfect_docstrings(code_without_docs)


def test_check_error_handling(analyzer):
    """Test error handling detection."""
    code_with_errors = '''
def func1():
    try:
        do_something()
    except:
        pass

def func2():
    try:
        do_other()
    except Exception as e:
        handle(e)
    '''
    
    code_without_errors = '''
def func1():
    do_something()

def func2():
    do_other()
    '''
    
    assert analyzer._check_error_handling(code_with_errors)
    assert not analyzer._check_error_handling(code_without_errors)


def test_check_type_hints(analyzer):
    """Test type hint detection."""
    code_with_hints = '''
def func1(x: int, y: str) -> bool:
    return True

def func2(data: dict) -> list:
    return []
    '''
    
    code_without_hints = '''
def func1(x, y):
    return True

def func2(data):
    return []
    '''
    
    assert analyzer._check_type_hints(code_with_hints)
    assert not analyzer._check_type_hints(code_without_hints)


def test_generic_name_detection(analyzer):
    """Test generic name ratio calculation."""
    code_generic = '''
def calculate_result():
    data = process_data()
    result = handle_request(data)
    return result
    '''
    
    code_specific = '''
def compute_fibonacci():
    numbers = [0, 1]
    total = sum(numbers)
    return total
    '''
    
    ratio_generic = analyzer._calculate_generic_name_ratio(code_generic)
    ratio_specific = analyzer._calculate_generic_name_ratio(code_specific)
    
    assert ratio_generic > ratio_specific


def test_comment_formality(analyzer):
    """Test comment formality calculation."""
    formal_code = '''
# Function to calculate the result
# This function processes the input
# Returns: the computed value
def func():
    pass
    '''
    
    informal_code = '''
# does the thing
# idk why but it works
def func():
    pass
    '''
    
    formal_score = analyzer._calculate_comment_formality(formal_code)
    informal_score = analyzer._calculate_comment_formality(informal_code)
    
    assert formal_score > informal_score


def test_ai_pattern_detection(analyzer):
    """Test AI pattern detection."""
    ai_code = '''
# Function to calculate something
def calculate_result():
    """This function calculates the important result.
    
    This is a very long docstring that explains everything
    in great detail with perfect grammar and structure.
    """
    pass

if __name__ == "__main__":
    main()
    '''
    
    patterns = analyzer._detect_ai_patterns(ai_code)
    
    assert len(patterns) > 0
    assert any("Function to" in p for p in patterns)


def test_empty_features(analyzer):
    """Test empty features return."""
    features = analyzer._empty_features()
    
    assert not features.has_perfect_docstrings
    assert not features.has_comprehensive_error_handling
    assert not features.has_type_hints
    assert features.generic_name_ratio == 0.0
    assert len(features.ai_pattern_matches) == 0
