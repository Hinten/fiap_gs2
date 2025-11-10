# Code Review Agent

AI-powered code review agent for FIAP students that integrates with GitHub to provide intelligent, educational, and personalized code reviews.

## 🎯 Features

- **GitHub Integration**: Automatic webhook handling for pull requests
- **Static Code Analysis**: Multi-language support (Python, JavaScript, Dart)
- **AI-Powered Feedback**: Educational and constructive reviews using CrewAI
- **Security Scanning**: Detection of security vulnerabilities
- **Complexity Analysis**: Identifies overly complex code
- **Human-in-the-Loop**: Professor approval before posting feedback

## 🏗️ Architecture

- **FastAPI**: Modern Python web framework
- **CrewAI**: AI agent orchestration
- **PyGithub**: GitHub API integration
- **DynamoDB**: Serverless database for reviews
- **AWS Lambda**: Serverless deployment (compatible)

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- GitHub Personal Access Token
- AWS Account (for DynamoDB)
- OpenAI or Anthropic API Key

### Installation

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt

# Copy environment variables
cp .env.example .env
# Edit .env with your credentials
```

### Configuration

Edit `.env` with your credentials:

```bash
GITHUB_TOKEN=your_github_token
OPENAI_API_KEY=your_openai_key
AWS_REGION=us-east-1
```

### Run Locally

```bash
# Development server
uvicorn src.main:app --reload --port 8001

# Access API docs
open http://localhost:8001/docs
```

## 📋 API Endpoints

### Code Review

- `POST /api/v1/code-review/analyze` - Create and analyze code review
- `GET /api/v1/code-review/pending` - List pending reviews
- `GET /api/v1/code-review/{review_id}` - Get review details
- `PUT /api/v1/code-review/{review_id}/approve` - Approve and post review
- `PUT /api/v1/code-review/{review_id}/edit` - Edit review feedback

### GitHub Integration

- `POST /api/v1/github/webhook` - Webhook endpoint for GitHub events

## 🧪 Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test file
pytest tests/test_api.py -v
```

## 📦 Project Structure

```
code_review_agent/
├── src/
│   ├── main.py              # FastAPI application
│   ├── api/                 # API routes
│   │   ├── routes.py
│   │   └── github_routes.py
│   ├── models/              # Pydantic models
│   ├── services/            # Business logic
│   │   ├── code_review_service.py
│   │   ├── github_service.py
│   │   ├── code_analysis_service.py
│   │   └── ai_feedback_service.py
│   ├── repositories/        # Data access
│   │   └── code_review_repository.py
│   └── utils/               # Utilities
│       └── config.py
├── tests/                   # Test suite
├── requirements.txt
├── requirements-dev.txt
├── pytest.ini
└── README.md
```

## 🔒 Security

- Never commit `.env` file (already in `.gitignore`)
- Use strong JWT secrets in production
- Verify GitHub webhook signatures
- Validate all user inputs
- Follow OWASP security guidelines

## 📚 Documentation

For detailed implementation information, see:
- [Roadmap](roadmap.md) - Complete implementation roadmap
- [Developer Guide](../../docs/developer-guide.md) - Project-wide standards
- [API Documentation](http://localhost:8001/docs) - Interactive API docs

## 🤝 Contributing

1. Follow PEP 8 style guide
2. Write tests for new features
3. Update documentation
4. Use type hints
5. Run linters before committing:

```bash
black .
isort .
flake8 .
```

## 📄 License

This is a Proof of Concept for FIAP Global Solution 2025.2.

## 👥 Authors

FIAP GS 2025.2 Team

---

**Last Updated**: 2025-11-10  
**Version**: 1.0.0
