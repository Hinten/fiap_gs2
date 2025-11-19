"""Base agent interface for AI-powered content reviewers."""

from abc import ABC, abstractmethod
from typing import List, Optional
import json
import re
from pydantic import ValidationError

from google import genai
from google.genai import types

from content_reviewer_agent.config import settings
from content_reviewer_agent.models.ai_schema import AIReviewResponse
from content_reviewer_agent.models.content import (
    Content,
    IssueSeverity,
    IssueType,
    ReviewIssue,
)


class BaseAIAgent(ABC):
    """Base class for all AI-powered review agents."""

    def __init__(self, name: str, description: str, system_prompt: str):
        """Initialize the AI agent.

        Args:
            name: Name of the agent
            description: Description of what the agent does
            system_prompt: System prompt for the AI model
        """
        self.name = name
        self.description = description
        self.system_prompt = system_prompt

        # Initialize the Google AI client (can be None for testing)
        api_key = settings.google_api_key or "test-key"  # Use test key if None
        self.client = genai.Client(api_key=api_key)

    @abstractmethod
    def get_review_prompt(self, content: Content) -> str:
        """Generate the review prompt for the given content.

        Args:
            content: Content to review

        Returns:
            Prompt string for the AI model
        """
        pass

    async def review(self, content: Content) -> List[ReviewIssue]:
        """Review content using AI and return list of issues.

        Args:
            content: Content to review

        Returns:
            List of issues found
        """
        try:
            # Generate the full prompt
            user_prompt = self.get_review_prompt(content)
            full_prompt = f"{self.system_prompt}\n\n{user_prompt}"

            # Call the AI model with structured output
            response = self.client.models.generate_content(
                model=settings.google_model_name,
                contents=full_prompt,
                config=types.GenerateContentConfig(
                    temperature=settings.temperature,
                    max_output_tokens=settings.max_output_tokens,
                    response_mime_type="application/json",
                    response_schema=AIReviewResponse,
                ),
            )

            raw_text = getattr(response, "text", None)

            if not raw_text:
                print("Empty response from AI model")
                return []

            print("AI model response received (length)", len(raw_text))

            # First attempt: direct Pydantic parsing
            try:
                review_response = AIReviewResponse.model_validate_json(raw_text)
            except ValidationError as ve:
                print(f"Primary JSON validation failed: {ve.errors()[0].get('msg', 'unknown error')}")
                # Try repair strategies
                repaired = self._repair_ai_json(raw_text)
                if repaired is None:
                    print("Failed to repair JSON - returning empty issues list")
                    return []
                try:
                    review_response = AIReviewResponse.model_validate(repaired)
                except ValidationError as ve2:
                    print(f"Repaired JSON still invalid: {ve2.errors()}")
                    return []

            issues = self.convert_ai_issues_to_review_issues(review_response.issues, content)
            return issues
        finally:
            print("Review completed by agent:", self.name)

    def _repair_ai_json(self, raw_text: str) -> Optional[dict]:
        """Attempt to repair truncated / malformed JSON from AI response.

        Strategies:
        1. Strip markdown fences / code blocks.
        2. Balance brackets/braces if clearly truncated.
        3. Remove dangling trailing commas.
        4. If still invalid, extract issue objects via regex and rebuild minimal structure.

        Args:
            raw_text: Raw JSON/text from model

        Returns:
            Dict compatible with AIReviewResponse or None if unrecoverable.
        """
        cleaned = raw_text.strip()
        cleaned = re.sub(r"^```(?:json)?", "", cleaned, flags=re.IGNORECASE).strip()
        cleaned = re.sub(r"```$", "", cleaned).strip()

        first_brace = cleaned.find('{')
        if first_brace > 0:
            cleaned = cleaned[first_brace:]

        # Try direct load
        try:
            return json.loads(cleaned)
        except Exception:
            pass

        # Balance braces/brackets
        balanced = self._balance_brackets(cleaned)
        if balanced:
            try:
                return json.loads(balanced)
            except Exception:
                pass

        # Remove trailing commas inside objects: pattern of 'value,' followed by newline and end of string
        # We'll conservatively remove a trailing comma before a closing brace if missing
        comma_fix = re.sub(r",\s*(?=\n?\}|$)", "", cleaned)
        if comma_fix != cleaned:
            attempt = self._balance_brackets(comma_fix) or comma_fix
            try:
                return json.loads(attempt)
            except Exception:
                cleaned = comma_fix  # use the comma-fixed version for extraction

        # Regex extraction fallback (on cleaned and comma_fixed variants)
        for text_variant in (cleaned, comma_fix):
            issue_objs = self._extract_issue_objects(text_variant)
            if issue_objs:
                return {"issues": issue_objs}

        return None

    def _balance_brackets(self, text: str) -> Optional[str]:
        """Balance curly braces and square brackets in a potentially truncated JSON string.
        Adds missing closing brackets/braces based on counts.

        Additionally removes a dangling trailing comma (common when truncation occurs
        right after the last field) to avoid JSON parse errors.
        """
        if not text.startswith('{'):
            return None
        # Remove trailing whitespace
        trimmed = text.rstrip()
        # If ends with a comma before we add closers, strip it
        # e.g. '"confidence": 0.9,' -> remove the trailing comma
        if re.search(r",\s*$", trimmed):
            trimmed = re.sub(r",\s*$", "", trimmed)
        open_curly = trimmed.count('{')
        close_curly = trimmed.count('}')
        open_square = trimmed.count('[')
        close_square = trimmed.count(']')
        to_add_curly = max(0, open_curly - close_curly)
        to_add_square = max(0, open_square - close_square)
        if to_add_curly == 0 and to_add_square == 0:
            return trimmed  # counts already balanced
        return trimmed + (']' * to_add_square) + ('}' * to_add_curly)

    def _extract_issue_objects(self, text: str) -> List[dict]:
        """Extract issue-like objects from malformed JSON using regex heuristics.
        This is a conservative approach to salvage partial valid data.
        Supports both fully enclosed objects and truncated objects missing closing braces.
        """
        pattern = re.compile(r'\{[^{}]*"type"[^{}]*"description"[^{}]*}')
        matches = pattern.findall(text)
        issues: List[dict] = []
        for m in matches:
            try:
                obj = json.loads(m)
                if all(k in obj for k in ["type", "severity", "description"]):
                    obj.setdefault("original_text", None)
                    obj.setdefault("suggested_fix", None)
                    obj.setdefault("confidence", 0.85)
                    obj.setdefault("sources", None)
                    issues.append(obj)
            except Exception:
                continue
        if issues:
            return issues
        # Fallback: attempt to reconstruct truncated single object by parsing lines
        if '"type"' in text and '"description"' in text:
            lines = [l.strip() for l in text.splitlines()]
            accumulator = {}
            for line in lines:
                if ':' not in line:
                    continue
                # Remove trailing commas and quotes artifacts
                cleaned_line = line.rstrip(',').strip().strip('{}')
                if not cleaned_line:
                    continue
                parts = cleaned_line.split(':', 1)
                if len(parts) != 2:
                    continue
                key = parts[0].strip().strip('"')
                value_raw = parts[1].strip().rstrip(',')
                # Basic value parsing
                if value_raw.startswith('"') and value_raw.endswith('"'):
                    value = value_raw.strip('"')
                elif value_raw in ('null', 'None'):
                    value = None
                else:
                    try:
                        value = float(value_raw)
                    except ValueError:
                        value = value_raw.strip('"')
                accumulator[key] = value
            required = {"type", "severity", "description"}
            if required.issubset(accumulator.keys()):
                accumulator.setdefault("original_text", accumulator.get("original_text"))
                accumulator.setdefault("suggested_fix", accumulator.get("suggested_fix"))
                accumulator.setdefault("confidence", accumulator.get("confidence", 0.85))
                accumulator.setdefault("sources", None)
                issues.append(accumulator)
        return issues

    def convert_ai_issues_to_review_issues(
        self, ai_issues: List, content: Content
    ) -> List[ReviewIssue]:
        """Convert AI response issues to ReviewIssue objects.

        Args:
            ai_issues: List of AIReviewIssue objects from AI
            content: Original content being reviewed

        Returns:
            List of ReviewIssue objects
        """
        issues = []

        for ai_issue in ai_issues:
            try:
                # Map AI response to our issue types
                issue_type_map = {
                    "spelling": IssueType.SPELLING,
                    "grammar": IssueType.GRAMMAR,
                    "syntax": IssueType.SYNTAX,
                    "comprehension": IssueType.COMPREHENSION,
                    "source": IssueType.SOURCE,
                    "outdated": IssueType.OUTDATED,
                    "deprecated": IssueType.DEPRECATED,
                }

                severity_map = {
                    "critical": IssueSeverity.CRITICAL,
                    "high": IssueSeverity.HIGH,
                    "medium": IssueSeverity.MEDIUM,
                    "low": IssueSeverity.LOW,
                }

                issue_type = issue_type_map.get(
                    ai_issue.type.lower(), IssueType.TECHNICAL
                )
                severity = severity_map.get(
                    ai_issue.severity.lower(), IssueSeverity.MEDIUM
                )

                issue = self.create_issue(
                    content=content,
                    issue_type=issue_type,
                    severity=severity,
                    description=ai_issue.description,
                    original_text=getattr(ai_issue, 'original_text', None),
                    suggested_fix=getattr(ai_issue, 'suggested_fix', None),
                    sources=getattr(ai_issue, 'sources', []) or [],
                    confidence=getattr(ai_issue, 'confidence', 0.85),
                )
                issues.append(issue)

            except (KeyError, ValueError, TypeError, AttributeError) as e:
                print(f"Error converting AI issue: {e}")
                continue

        return issues

    def create_issue(
        self,
        content: Content,
        issue_type: IssueType,
        severity: IssueSeverity,
        description: str,
        original_text: Optional[str] = None,
        suggested_fix: Optional[str] = None,
        location: Optional[str] = None,
        sources: Optional[List[str]] = None,
        confidence: float = 0.85,
    ) -> ReviewIssue:
        """Helper method to create a ReviewIssue.

        Args:
            content: Content being reviewed
            issue_type: Type of issue
            severity: Severity level
            description: Issue description
            original_text: Original problematic text
            suggested_fix: Suggested fix
            location: Location in content
            sources: Reference sources
            confidence: Confidence score (0-1)

        Returns:
            ReviewIssue object
        """
        # Generate agent name with model info
        agent_name = f"{self.name} ({settings.google_model_name})"

        return ReviewIssue(
            content_id=content.content_id,
            issue_type=issue_type,
            severity=severity,
            description=description,
            original_text=original_text,
            suggested_fix=suggested_fix,
            location=location,
            sources=sources or [],
            confidence=confidence,
            reviewed_by_agent=agent_name,
        )

    def __repr__(self) -> str:
        """String representation of the agent."""
        return f"{self.__class__.__name__}(name='{self.name}')"
