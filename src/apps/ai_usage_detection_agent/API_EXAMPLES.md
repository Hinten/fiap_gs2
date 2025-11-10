# API Examples - AI Usage Detection Agent

This file contains cURL examples for testing the API endpoints.

## Prerequisites

Start the server first:
```bash
python src/main.py
# or
uvicorn src.main:app --reload --port 8002
```

The server will be available at: `http://localhost:8002`

---

## Health Check

```bash
curl http://localhost:8002/api/v1/ai-detection/health
```

---

## Root Endpoint

```bash
curl http://localhost:8002/
```

---

## Analyze Text Submission (Human-Like)

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-001",
    "student_id": "student-123",
    "content": "Hey! So I worked on this assignment and honestly it was pretty tough. I tried a few different approaches but kept getting errors. Finally figured it out after looking at the lecture notes again. The code is kinda messy but it works lol.",
    "submission_type": "text"
  }'
```

---

## Analyze Text Submission (AI-Like)

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-002",
    "student_id": "student-456",
    "content": "Artificial Intelligence represents a transformative paradigm shift in computational capabilities. Furthermore, the integration of machine learning algorithms facilitates unprecedented optimization. Moreover, deep learning architectures enable sophisticated pattern recognition. Consequently, organizations can leverage these advanced methodologies.",
    "submission_type": "text"
  }'
```

---

## Analyze Code Submission (Student-Like)

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-003",
    "student_id": "student-789",
    "content": "# my fibonacci function\ndef fib(n):\n    a, b = 0, 1\n    result = []\n    for _ in range(n):\n        result.append(a)\n        a, b = b, a + b\n    return result\n\nprint(fib(10))",
    "submission_type": "code"
  }'
```

---

## Analyze Code Submission (AI-Like)

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-004",
    "student_id": "student-999",
    "content": "def calculate_fibonacci_sequence(n: int) -> list[int]:\n    \"\"\"\n    This function calculates the Fibonacci sequence up to n terms.\n    \n    Args:\n        n (int): The number of terms to generate\n        \n    Returns:\n        list[int]: A list containing the Fibonacci sequence\n    \"\"\"\n    if n < 1:\n        raise ValueError(\"n must be at least 1\")\n    \n    sequence = [0, 1]\n    for i in range(2, n):\n        sequence.append(sequence[i-1] + sequence[i-2])\n    return sequence[:n]",
    "submission_type": "code"
  }'
```

---

## Analyze Mixed Submission

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-005",
    "student_id": "student-555",
    "content": "# Assignment: Sorting\n\nI implemented bubble sort:\n\ndef bubble_sort(arr):\n    n = len(arr)\n    for i in range(n):\n        for j in range(0, n-i-1):\n            if arr[j] > arr[j+1]:\n                arr[j], arr[j+1] = arr[j+1], arr[j]\n    return arr\n\nIt works great!",
    "submission_type": "mixed"
  }'
```

---

## Get AI Usage Guidelines

```bash
curl http://localhost:8002/api/v1/ai-detection/guidelines
```

---

## Declare AI Usage (Honest Student)

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/declare-usage" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-006",
    "student_id": "student-123",
    "declared_usage": true,
    "usage_description": "I used ChatGPT to understand the algorithm better and for debugging help"
  }'
```

---

## Declare No AI Usage

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/declare-usage" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-007",
    "student_id": "student-456",
    "declared_usage": false
  }'
```

---

## Get Analysis Report (Placeholder)

```bash
curl http://localhost:8002/api/v1/ai-detection/report/sub-001
```

---

## Using jq for Pretty Output

If you have `jq` installed, you can format the JSON output:

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-test",
    "student_id": "student-test",
    "content": "Test content",
    "submission_type": "text"
  }' | jq .
```

---

## Testing with Python requests

```python
import requests

url = "http://localhost:8002/api/v1/ai-detection/analyze"
payload = {
    "submission_id": "sub-001",
    "student_id": "student-123",
    "content": "Your submission content here",
    "submission_type": "text"
}

response = requests.post(url, json=payload)
print(response.json())
```

---

## Expected Response Format

All endpoints return responses in this format:

```json
{
  "success": true,
  "data": {
    "analysis_id": "uuid-here",
    "submission_id": "sub-001",
    "student_id": "student-123",
    "analyzed_at": "2025-11-10T16:55:30.123Z",
    "ai_usage_score": 0.45,
    "category": "moderate",
    "text_ai_probability": 0.42,
    "code_ai_probability": null,
    "flags": ["low_burstiness", "excessive_formality"],
    "explanation": "This submission shows moderate use of AI tools...",
    "confidence": 0.80,
    "requires_verification": false,
    "recommended_action": "Review submission..."
  },
  "error": null
}
```

---

## Error Handling

Invalid request example:

```bash
curl -X POST "http://localhost:8002/api/v1/ai-detection/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "sub-001"
  }'
```

Response:
```json
{
  "detail": [
    {
      "loc": ["body", "student_id"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```
