#!/bin/bash
set -e

echo "🚀 Running post-create setup..."

# Install uv for current user if not already installed
if ! command -v uv &> /dev/null; then
    echo "📦 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Create Python virtual environment
echo "🐍 Setting up Python environment..."
if [ ! -d ".venv" ]; then
    uv venv .venv
fi

# Install Python dependencies
echo "📦 Installing Python dependencies..."
source .venv/bin/activate
uv sync --all-extras

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
npm install

# Create environment files if they don't exist
if [ ! -f "backend/.env" ]; then
    echo "📝 Creating backend/.env..."
    cat > backend/.env << 'EOF'
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=INFO
API_HOST=0.0.0.0
API_PORT=8000
API_RELOAD=true
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001
WS_HEARTBEAT_INTERVAL=30
WS_MAX_CONNECTIONS=100
EOF
fi

if [ ! -f "frontend/.env.local" ]; then
    echo "📝 Creating frontend/.env.local..."
    cat > frontend/.env.local << 'EOF'
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_WS_URL=ws://localhost:8000
EOF
fi

# Configure git (optional, customize as needed)
git config --global --add safe.directory /workspace

echo "✅ DevContainer setup complete!"
echo ""
echo "Available commands:"
echo "  npm run dev:backend  - Start FastAPI backend"
echo "  npm run dev          - Start Next.js frontend"
echo "  npm run dev:all      - Start both servers"
echo "  npm run graph        - View Nx dependency graph"
echo ""
