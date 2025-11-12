# AI-Powered Content Reviewer Agents

This package implements four specialized AI agents using Google's Gemini API for intelligent content review.

## Architecture

### BaseAIAgent

All agents inherit from `BaseAIAgent`, which provides:
- Google Gemini integration
- System prompt management
- JSON response parsing
- Error handling and fallbacks
- Issue creation helpers

### The Four AI Agents

#### 1. ErrorDetectionAgent
**Purpose:** Detects spelling, grammar, and syntax errors using AI

**System Prompt Focus:**
- Spelling mistakes
- Grammar errors (articles, tense, agreement)
- Syntax issues in code blocks
- Capitalization and punctuation

**Returns:** Issues with severity levels, original text, and suggested fixes

#### 2. ComprehensionAgent
**Purpose:** Analyzes content for readability and clarity

**System Prompt Focus:**
- Complex vocabulary that can be simplified
- Long, convoluted sentences
- Dense paragraphs
- Passive voice usage
- Technical jargon without explanation
- Logical flow issues

**Returns:** Suggestions for clearer, more accessible content

#### 3. SourceVerificationAgent
**Purpose:** Verifies sources, citations, and references

**System Prompt Focus:**
- Claims requiring citations
- Quotes without attribution
- Statistics without sources
- Unreliable or unverified sources
- Missing references
- Outdated or broken links

**Returns:** Issues with suggested trusted sources

#### 4. ContentUpdateAgent
**Purpose:** Detects outdated or deprecated content

**System Prompt Focus:**
- Deprecated technologies (e.g., Python 2.7, jQuery)
- Old software versions
- Outdated best practices
- Old statistics or data
- Discontinued products
- Obsolete API references
- Information contradicting current standards

**Returns:** Issues with current alternatives

## Configuration

Set your Google API key:

```bash
export GOOGLE_API_KEY="your-api-key-here"
```

Or create a `.env` file:

```env
GOOGLE_API_KEY=your-api-key-here
GOOGLE_MODEL_NAME=gemini-1.5-flash  # Optional, default value
TEMPERATURE=0.3  # Optional, default value
MAX_OUTPUT_TOKENS=2048  # Optional, default value
```

## Usage

### Python API

```python
from content_reviewer_agent.agents import (
    ErrorDetectionAgent,
    ComprehensionAgent,
    SourceVerificationAgent,
    ContentUpdateAgent
)
from content_reviewer_agent.models.content import Content, ContentType

# Create content to review
content = Content(
    title="Introduction to Python",
    text="I recieve emails regularly using Python 2.7.",
    content_type=ContentType.TEXT
)

# Review with specific agents
error_agent = ErrorDetectionAgent()
issues = await error_agent.review(content)

# Each agent returns a list of ReviewIssue objects
for issue in issues:
    print(f"{issue.severity.name}: {issue.description}")
    print(f"  Original: {issue.original_text}")
    print(f"  Suggested: {issue.suggested_fix}")
    print(f"  Confidence: {issue.confidence}")
```

### REST API

Start the server:

```bash
python -m content_reviewer_agent.main
```

Make requests:

```bash
# Full review (all agents)
curl -X POST "http://localhost:8000/api/v1/review?review_type=full_review" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My Content",
    "text": "I recieve emails regularly.",
    "content_type": "text"
  }'

# Specific agent
curl -X POST "http://localhost:8000/api/v1/review/errors" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My Content",
    "text": "I recieve emails regularly.",
    "content_type": "text"
  }'
```

## How It Works

### 1. Prompt Construction

Each agent constructs a prompt with:
- System prompt (defines agent's role and output format)
- User prompt (includes content to review)

Example for ErrorDetectionAgent:

```
System: You are an expert editor and proofreader. Identify errors and return JSON...
User: Review this content:
Title: Introduction to Python
Text: I recieve emails regularly.
```

### 2. AI Processing

The agent calls Google Gemini:

```python
response = self.model.generate_content(full_prompt)
```

### 3. Response Parsing

AI returns JSON with issues:

```json
[
  {
    "type": "spelling",
    "severity": "low",
    "description": "Spelling error: 'recieve' should be 'receive'",
    "original_text": "recieve",
    "suggested_fix": "receive",
    "confidence": 0.95
  }
]
```

### 4. Issue Creation

Parsed into `ReviewIssue` objects with:
- Issue type and severity
- Description and location
- Original and suggested text
- Confidence score
- Sources (if applicable)

## Testing

Tests use mocking to avoid real API calls:

```python
@pytest.mark.asyncio
async def test_error_agent_spelling(mock_ai_response):
    agent = ErrorDetectionAgent()
    content = Content(title="Test", text="I recieve emails.")
    
    # Mock the AI response
    with patch.object(agent.model, 'generate_content') as mock:
        mock_response = Mock()
        mock_response.text = mock_ai_response
        mock.return_value = mock_response
        
        issues = await agent.review(content)
        assert len(issues) > 0
```

Run tests:

```bash
pytest tests/ -v
```

## Advantages of AI-Based Approach

### vs Pattern-Based Detection

**Pattern-Based (Old):**
- Limited to predefined rules
- No context understanding
- Hard to maintain large rule sets
- Language-specific patterns

**AI-Based (New):**
- Context-aware analysis
- Understands intent and meaning
- Handles edge cases naturally
- Provides explanations
- Multilingual potential
- Improves over time

### Examples

**Pattern-Based:** "recieve" → "receive" (dictionary lookup)

**AI-Based:** Understands that "utilize" → "use" is better in informal educational content, but might keep "utilize" in academic papers

## Cost Considerations

- Google Gemini offers free tier for testing
- Gemini-1.5-flash is cost-effective for production
- Average content review: ~500-1000 tokens
- Batch processing recommended for large volumes

## Best Practices

1. **Set appropriate temperature:** Lower (0.1-0.3) for consistency, higher (0.5-0.7) for creative suggestions
2. **Handle API errors gracefully:** Agents return empty lists on failures
3. **Monitor confidence scores:** Ignore issues with confidence < 0.7
4. **Use appropriate review types:** Don't run all agents if only checking spelling
5. **Rate limiting:** Implement delays for high-volume processing

## Extending

To add a new agent:

1. Create class inheriting from `BaseAIAgent`
2. Define system prompt with clear instructions
3. Implement `get_review_prompt()` and `parse_ai_response()`
4. Add tests with mocked responses

Example:

```python
class StyleGuideAgent(BaseAIAgent):
    SYSTEM_PROMPT = """You are a style guide expert..."""
    
    def get_review_prompt(self, content: Content) -> str:
        return f"Check style: {content.text}"
    
    def parse_ai_response(self, response_text: str, content: Content):
        # Parse JSON response
        parsed = self.parse_json_response(response_text)
        # Create ReviewIssue objects
        return issues
```

## Troubleshooting

**"API key not found"**
- Set `GOOGLE_API_KEY` environment variable

**"Model not responding"**
- Check API quota and limits
- Verify network connectivity
- Check Google AI service status

**"Empty response from AI"**
- Content might be too long (reduce `max_output_tokens`)
- Prompt might be unclear (review system prompt)
- API might be rate-limited

## License

Part of FIAP Global Solution 2025.2 project.
