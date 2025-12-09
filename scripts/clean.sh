#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DEEP_CLEAN=false

# Parse arguments
if [[ "$1" == "--deep" ]]; then
    DEEP_CLEAN=true
fi

echo -e "${GREEN}=== Cleaning Build Artifacts ===${NC}\n"

# Python artifacts
echo -e "${YELLOW}Cleaning Python artifacts...${NC}"
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
find . -type f -name "*.pyo" -delete 2>/dev/null || true
rm -rf htmlcov/ .coverage 2>/dev/null || true
echo -e "${GREEN}✓ Python artifacts cleaned${NC}"

# Frontend artifacts
echo -e "${YELLOW}Cleaning Frontend artifacts...${NC}"
rm -rf frontend/.next 2>/dev/null || true
rm -rf frontend/out 2>/dev/null || true
rm -rf frontend/node_modules/.cache 2>/dev/null || true
echo -e "${GREEN}✓ Frontend artifacts cleaned${NC}"

# Deep clean (remove dependencies)
if [ "$DEEP_CLEAN" = true ]; then
    echo -e "\n${YELLOW}Performing deep clean...${NC}"
    
    echo "Removing Python virtual environment..."
    rm -rf .venv 2>/dev/null || true
    echo -e "${GREEN}✓ Python .venv removed${NC}"
    
    echo "Removing Node.js dependencies..."
    rm -rf node_modules 2>/dev/null || true
    rm -rf frontend/node_modules 2>/dev/null || true
    rm -rf package-lock.json frontend/package-lock.json 2>/dev/null || true
    echo -e "${GREEN}✓ Node.js dependencies removed${NC}"
    
        echo "Removing Nx cache..."
    rm -rf .nx 2>/dev/null || true
    echo -e "${GREEN}✓ Nx cache removed${NC}"
    
    echo -e "\n${GREEN}Deep clean complete! Run ./scripts/setup.sh to reinstall.${NC}"
else
    echo -e "\n${GREEN}Clean complete!${NC}"
    echo -e "${YELLOW}Tip: Use './scripts/clean.sh --deep' to also remove dependencies${NC}"
fi
