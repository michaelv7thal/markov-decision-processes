#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Running All Tests (via Nx) ===${NC}\n"

# Activate Python virtual environment
if [ ! -d ".venv" ]; then
    echo -e "${RED}✗ Virtual environment not found. Run ./scripts/setup.sh first${NC}"
    exit 1
fi

source .venv/bin/activate

# Run Python tests with uv
echo -e "${YELLOW}Running Python tests...${NC}"
if uv run pytest backend/tests 2>/dev/null; then
    echo -e "${GREEN}✓ Python tests passed${NC}\n"
    PYTHON_EXIT=0
else
    echo -e "${RED}✗ Python tests failed${NC}\n"
    PYTHON_EXIT=1
fi

# Run Frontend tests via Nx
echo -e "${YELLOW}Running Frontend tests...${NC}"
if nx run frontend:test 2>/dev/null; then
    echo -e "${GREEN}✓ Frontend tests passed${NC}\n"
    FRONTEND_EXIT=0
else
    echo -e "${RED}✗ Frontend tests failed${NC}\n"
    FRONTEND_EXIT=1
fi

# Exit with error if any tests failed
if [ $PYTHON_EXIT -ne 0 ] || [ $FRONTEND_EXIT -ne 0 ]; then
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi

echo -e "${GREEN}All tests passed!${NC}"
