"""Test configuration."""

import pytest
import dotenv
dotenv.load_dotenv()


@pytest.fixture
def sample_content_text():
    """Sample text content for testing."""
    return """
    Python is a high-level programming language. It was created by Guido van Rossum.
    Research shows that it is one of the most popular languages.
    """


@pytest.fixture
def sample_content_with_errors():
    """Sample content with various errors."""
    return """
    I recieve emails regularly and occured issues with seperate accounts.
    We must utilize this methodology to facilitate implementation.
    According to statistics from 2010, Python 2.7 is widely used.
    Research shows that jQuery is the most popular library.
    """


@pytest.fixture
def clean_content():
    """Clean content without errors."""
    return "Python is easy to learn. It has clear syntax. It is well-documented."
