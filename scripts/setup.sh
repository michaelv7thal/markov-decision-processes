#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== MDP Monorepo Setup (Nx + uv) ===${NC}\n"

# Check uv installation
echo "Checking uv installation..."
if ! command -v uv &> /dev/null; then
    echo -e "${YELLOW}uv not found. Installing uv...${NC}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
    
    if ! command -v uv &> /dev/null; then
        echo -e "${RED}✗ Failed to install uv. Please install manually: https://docs.astral.sh/uv/${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓ uv $(uv --version | awk '{print $2}')${NC}"

# Check Python version
echo "Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 11) else 1)" 2>/dev/null; then
    echo -e "${RED}✗ Python 3.11+ required. Found: $PYTHON_VERSION${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python $PYTHON_VERSION${NC}"

# Check Node version
echo "Checking Node version..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js not found. Please install Node.js 18+${NC}"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2)
if ! node -e "process.exit(parseInt(process.version.slice(1)) >= 18 ? 0 : 1)" 2>/dev/null; then
    echo -e "${RED}✗ Node.js 18+ required. Found: $NODE_VERSION${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js $NODE_VERSION${NC}"

# Create root-level Python virtual environment with uv
echo -e "\n${YELLOW}Setting up Python environment with uv...${NC}"
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment at project root..."
    uv venv .venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
else
    echo -e "${YELLOW}Virtual environment already exists${NC}"
fi

# Activate virtual environment
source .venv/bin/activate

# Install Python dependencies using uv
echo "Installing Python dependencies with uv..."
echo "  - Syncing workspace (installs all members)..."
uv sync --all-extras
echo -e "${GREEN}✓ Python dependencies installed${NC}"

# Install Node dependencies
echo -e "\n${YELLOW}Setting up Node.js workspace with Nx...${NC}"
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${YELLOW}node_modules already exists. Running npm install to ensure Nx is installed...${NC}"
    npm install
fi

# Create environment files
echo -e "\n${YELLOW}Setting up environment files...${NC}"

# Backend .env
if [ ! -f "backend/.env" ]; then
    cat > backend/.env << 'EOF'
# Backend Configuration
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=INFO

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_RELOAD=true

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001

# WebSocket Configuration
WS_HEARTBEAT_INTERVAL=30
WS_MAX_CONNECTIONS=100
EOF
    echo -e "${GREEN}✓ Created backend/.env${NC}"
else
    echo -e "${YELLOW}backend/.env already exists${NC}"
fi

# Frontend .env.local
if [ ! -f "frontend/.env.local" ]; then
    cat > frontend/.env.local << 'EOF'
# Frontend Configuration
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_WS_URL=ws://localhost:8000
EOF
    echo -e "${GREEN}✓ Created frontend/.env.local${NC}"
else
    echo -e "${YELLOW}frontend/.env.local already exists${NC}"
fi

echo -e "\n${GREEN}=== Setup Complete! ===${NC}\n"
echo "Python environment managed by uv"
echo "Monorepo managed by Nx"
echo ""
echo "To activate the Python environment, run:"
echo -e "  ${YELLOW}source .venv/bin/activate${NC}\n"
echo "To start development:"
echo -e "  Backend:  ${YELLOW}npm run dev:backend${NC} or ${YELLOW}uv run uvicorn backend.app.main:app --reload${NC}"
echo -e "  Frontend: ${YELLOW}npm run dev${NC} or ${YELLOW}nx run frontend:dev${NC}"
echo -e "  Both:     ${YELLOW}npm run dev:all${NC}\n"
echo "View dependency graph:"
echo -e "  ${YELLOW}npm run graph${NC}\n"
