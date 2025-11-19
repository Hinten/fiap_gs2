#!/bin/bash
# run_backend.sh - Script to run the unified backend

set -e

echo "=========================================="
echo "FIAP Backend - Unified API"
echo "=========================================="

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "⚠️  Virtual environment not found. Creating..."
    python3 -m venv .venv
fi

# Activate virtual environment
echo "📦 Activating virtual environment..."
source .venv/bin/activate

# Check if packages are installed
echo "🔍 Checking package installations..."

if ! python -c "import auth_service" 2>/dev/null; then
    echo "📦 Installing auth_service..."
    cd ../../packages/auth_service && pip install -e ".[dev]" && cd ../../production/backend
fi

if ! python -c "import research_management" 2>/dev/null; then
    echo "📦 Installing research_management..."
    cd ../../packages/research_management && pip install -e ".[dev]" && cd ../../production/backend
fi

if ! python -c "import content_reviewer_agent" 2>/dev/null; then
    echo "📦 Installing content_reviewer_agent..."
    cd ../../packages/content_reviewer_agent && pip install -e ".[dev]" && cd ../../production/backend
fi

# Install unified backend dependencies
echo "📦 Installing backend dependencies..."
pip install -e ".[dev]" > /dev/null 2>&1 || echo "⚠️  Some dependencies already installed"

# Check for .env file
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Copy .env.example to .env and configure it."
    echo "   cp .env.example .env"
    exit 1
fi

# Start the server
echo ""
echo "🚀 Starting unified backend server..."
echo "📝 API Documentation: http://localhost:8000/docs"
echo "🏥 Health Check: http://localhost:8000/health"
echo ""

python main.py
