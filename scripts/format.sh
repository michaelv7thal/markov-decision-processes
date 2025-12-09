#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Formatting and Linting Code ===${NC}\n"

# Activate Python virtual environment
if [ ! -d ".venv" ]; then
    echo -e "${YELLOW}Virtual environment not found. Skipping Python formatting.${NC}"
else
    source .venv/bin/activate
    
    echo -e "${YELLOW}Formatting Python code with Ruff...${NC}"
    uv run ruff format backend/ --quiet
    echo -e "${GREEN}✓ Ruff formatting complete${NC}"
    
    echo -e "${YELLOW}Linting Python code with Ruff...${NC}"
    uv run ruff check backend/ --fix --quiet
    echo -e "${GREEN}✓ Ruff linting complete${NC}"
    
    echo -e "${YELLOW}Type checking with mypy...${NC}"
    uv run mypy backend/ --pretty --no-error-summary 2>/dev/null || true
    echo -e "${GREEN}✓ Type checking complete${NC}\n"
fi

# Format frontend via Nx
if [ -d "node_modules" ]; then
    echo -e "${YELLOW}Formatting and linting frontend via Nx...${NC}"
    nx run frontend:format --quiet 2>/dev/null || true
    nx run frontend:lint --quiet 2>/dev/null || true
    echo -e "${GREEN}✓ Frontend formatting and linting complete${NC}"
else
    echo -e "${YELLOW}Node modules not installed. Skipping frontend formatting.${NC}"
fi

echo -e "\n${GREEN}All formatting and linting complete!${NC}"
