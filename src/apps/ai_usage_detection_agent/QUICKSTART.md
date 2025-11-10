# AI Usage Detection Agent - Quick Start Guide

## ⚡ Quick Start (5 minutes)

### 1. Install Dependencies

```bash
cd src/apps/ai_usage_detection_agent
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure (Optional)

Copy the example environment file:
```bash
cp .env.example .env
# Edit .env if you want to change defaults
```

Default configuration works out-of-the-box!

### 3. Start the Server

```bash
python src/main.py
```

You should see:
```
INFO:     Started server process
INFO:     Uvicorn running on http://0.0.0.0:8002
```

### 4. Test It!

Open another terminal and try:

```bash
# Health check
curl http://localhost:8002/api/v1/ai-detection/health

# Analyze a submission
curl -X POST http://localhost:8002/api/v1/ai-detection/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "submission_id": "test-001",
    "student_id": "student-123",
    "content": "This is my submission about artificial intelligence.",
    "submission_type": "text"
  }'
```

### 5. Explore the API

Open your browser and go to:
- **Swagger UI**: http://localhost:8002/docs
- **ReDoc**: http://localhost:8002/redoc

Try the interactive API documentation!

## 📚 What's Next?

- Read the [README.md](README.md) for detailed documentation
- Check [API_EXAMPLES.md](API_EXAMPLES.md) for more API examples
- Run [examples.py](examples.py) to see programmatic usage
- Review [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) for technical details

## 🧪 Running Tests

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# View coverage report
open htmlcov/index.html  # On Mac
xdg-open htmlcov/index.html  # On Linux
start htmlcov/index.html  # On Windows
```

## 🎯 Key Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/v1/ai-detection/analyze` | Analyze a submission |
| GET | `/api/v1/ai-detection/guidelines` | Get usage guidelines |
| POST | `/api/v1/ai-detection/declare-usage` | Declare AI usage |
| GET | `/api/v1/ai-detection/health` | Health check |

## 💡 Example Analysis Result

```json
{
  "success": true,
  "data": {
    "submission_id": "test-001",
    "student_id": "student-123",
    "ai_usage_score": 0.25,
    "category": "appropriate",
    "explanation": "This submission shows minimal or appropriate use of AI tools...",
    "requires_verification": false,
    "recommended_action": "No action required. Accept submission."
  }
}
```

## ⚠️ Troubleshooting

### Import Errors
Make sure you're in the virtual environment:
```bash
source venv/bin/activate
```

### Port Already in Use
Change the port in `.env`:
```env
PORT=8003
```

### Module Not Found
Install dependencies:
```bash
pip install -r requirements.txt
```

## 🚀 Production Deployment

See the [README.md](README.md) for Docker and serverless deployment instructions.

---

**Need Help?** Check the full [README.md](README.md) or [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
