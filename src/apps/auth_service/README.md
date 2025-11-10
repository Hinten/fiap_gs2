# Auth Service

Authentication and authorization microservice for the SymbioWork platform (FIAP Global Solution 2025.2).

## 🔐 Features

- **User Registration and Login**: Secure authentication with JWT tokens
- **Password Security**: Bcrypt hashing with strong password policies
- **JWT Tokens**: Stateless authentication with access and refresh tokens
- **Role-Based Access Control (RBAC)**: Support for user, recruiter, and admin roles
- **LGPD Compliance**: Data export and right to be forgotten endpoints
- **RESTful API**: FastAPI with automatic OpenAPI documentation
- **Serverless**: Deployable to AWS Lambda

## 🏗️ Architecture

### Tech Stack
- **Framework**: FastAPI (Python 3.11+)
- **Authentication**: PyJWT, passlib with bcrypt
- **Database**: AWS DynamoDB
- **Deployment**: AWS Lambda via Serverless Framework
- **Validation**: Pydantic v2

### Project Structure
```
auth_service/
├── src/
│   ├── main.py              # FastAPI app and Lambda handler
│   ├── api/                 # API routes
│   │   ├── auth_routes.py   # Authentication endpoints
│   │   └── user_routes.py   # User management endpoints
│   ├── core/                # Core utilities
│   │   ├── config.py        # Configuration settings
│   │   ├── security.py      # JWT and password hashing
│   │   └── dependencies.py  # FastAPI dependencies
│   ├── models/              # Pydantic models
│   │   ├── user.py          # User schemas
│   │   └── token.py         # Token schemas
│   ├── services/            # Business logic
│   │   ├── auth_service.py  # Authentication logic
│   │   └── user_service.py  # User management logic
│   └── repositories/        # Data access layer
│       └── user_repository.py
├── tests/                   # Test suite
├── requirements.txt         # Production dependencies
├── requirements-dev.txt     # Development dependencies
├── serverless.yml          # Serverless Framework config
└── .env.example            # Environment variables template
```

## 🚀 Getting Started

### Prerequisites
- Python 3.11+
- AWS Account (for DynamoDB and Lambda deployment)
- Node.js and npm (for Serverless Framework)

### Local Development Setup

1. **Clone the repository**
```bash
cd src/apps/auth_service
```

2. **Create and activate virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

4. **Configure environment variables**
```bash
cp .env.example .env
# Edit .env with your configuration
```

Required environment variables:
- `JWT_SECRET_KEY`: Secret key for JWT signing (use a strong random string)
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `DYNAMODB_TABLE_USERS`: DynamoDB table name for users
- `DYNAMODB_TABLE_REFRESH_TOKENS`: DynamoDB table name for refresh tokens

5. **Run locally**
```bash
uvicorn src.main:app --reload --port 8000
```

The API will be available at:
- API: http://localhost:8000
- Interactive docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 🧪 Testing

### Run all tests
```bash
pytest
```

### Run with coverage
```bash
pytest --cov=src --cov-report=html
```

Coverage report will be generated in `htmlcov/index.html`.

### Run specific test file
```bash
pytest tests/test_security.py -v
```

## 📝 Code Quality

### Format code
```bash
black .
isort .
```

### Lint code
```bash
flake8 .
mypy src/
```

## 🌐 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login and get tokens
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - Logout (placeholder)

### User Management
- `GET /api/v1/users/me` - Get current user profile
- `PUT /api/v1/users/me` - Update current user profile
- `DELETE /api/v1/users/me` - Delete account (LGPD)
- `GET /api/v1/users/me/data-export` - Export user data (LGPD)

### Admin Endpoints (requires admin role)
- `GET /api/v1/users/{user_id}` - Get user by ID
- `PUT /api/v1/users/{user_id}/role` - Update user role

### Health
- `GET /` - Service status
- `GET /health` - Health check

## 🔒 Security

### Password Requirements
- Minimum 8 characters
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 digit

### JWT Token Strategy
- **Access Token**: Short-lived (30 minutes), used for API requests
- **Refresh Token**: Long-lived (7 days), used to obtain new access tokens

### RBAC Roles
- **user**: Basic access
- **recruiter**: Access to recruitment features
- **admin**: Full access to all features

## ☁️ Deployment

### Deploy to AWS

1. **Install Serverless Framework**
```bash
npm install -g serverless
npm install --save-dev serverless-python-requirements
```

2. **Configure AWS credentials**
```bash
aws configure
```

3. **Set environment variables**
```bash
export JWT_SECRET_KEY="your-production-secret-key"
export CORS_ORIGINS="https://yourdomain.com"
```

4. **Deploy**
```bash
# Deploy to dev
serverless deploy --stage dev

# Deploy to production
serverless deploy --stage prod
```

5. **View logs**
```bash
serverless logs -f api --tail
```

6. **Remove deployment**
```bash
serverless remove --stage dev
```

## 🗄️ Database Schema

### DynamoDB Tables

#### symbiowork-users
- **Partition Key**: `user_id` (String, UUID)
- **GSI**: `email-index` (email as partition key)
- **Attributes**:
  - user_id, email, full_name, hashed_password
  - is_active, role, oauth_provider
  - created_at, updated_at

#### symbiowork-refresh-tokens
- **Partition Key**: `token_id` (String, UUID)
- **GSI**: `user_id-index`
- **TTL**: `expires_at` attribute
- **Attributes**:
  - token_id, user_id, token_hash
  - expires_at, revoked, created_at

## 📚 Documentation

Interactive API documentation is automatically generated by FastAPI:
- **Swagger UI**: `/docs`
- **ReDoc**: `/redoc`

## 🤝 Integration with Other Services

This service is designed to integrate with:
- **frontend_flutter**: Web/mobile UI
- **code_review_agent**: GitHub integration
- **grading_agent**: Automated grading
- Other microservices in the SymbioWork platform

All services should include the JWT access token in the `Authorization` header:
```
Authorization: Bearer <access_token>
```

## 🛣️ Roadmap

- [x] Core authentication (register, login, tokens)
- [x] RBAC implementation
- [x] LGPD compliance endpoints
- [x] Comprehensive test suite
- [x] Serverless deployment configuration
- [ ] OAuth2 integration (Google, Microsoft)
- [ ] Rate limiting for brute force protection
- [ ] MFA/2FA support
- [ ] Session management with token blacklist
- [ ] Audit logging
- [ ] Email verification

## 📄 License

This project is part of FIAP Global Solution 2025.2.

## 👥 Contributors

Developed for FIAP AI-Enhanced Learning Platform.
