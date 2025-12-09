# Development Guide

Complete guide for setting up and developing the MDP Visualizer application.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
  - [Option 1: DevContainer (Recommended)](#option-1-devcontainer-recommended)
  - [Option 2: Local Setup](#option-2-local-setup)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Backend Development](#backend-development)
- [Frontend Development](#frontend-development)
- [Testing](#testing)
- [Code Quality](#code-quality)
- [Debugging](#debugging)
- [Common Tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **Docker Desktop** 24.0+ ([Download](https://www.docker.com/products/docker-desktop/))
- **Visual Studio Code** 1.80+ ([Download](https://code.visualstudio.com/))
- **VS Code Extensions**:
  - Dev Containers
  - Python (Microsoft)
  - ESLint
  - Prettier

### Optional (for local development without DevContainer)

- **Python** 3.11+
- **Node.js** 20+ with npm 10+
- **Git** 2.40+

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/markov-decision-processes.git
cd markov-decision-processes
```

### 2. Open in VS Code

```bash
code .
```

### 3. Choose Your Development Environment

You have two options: **DevContainer** (recommended) or **Local Setup**.

---

## Development Environment

### Option 1: DevContainer (Recommended)

DevContainers provide a consistent development environment across all machines.

#### Setup

1. **Install Prerequisites**:
   - Docker Desktop (running)
   - VS Code with Dev Containers extension

2. **Open in Container**:
   - Open VS Code
   - Press `F1` or `Ctrl+Shift+P`
   - Type "Dev Containers: Reopen in Container"
   - Select it and wait for container to build (~5 minutes first time)

3. **Verify Setup**:
   ```bash
   # Backend
   cd backend
   python --version  # Should show Python 3.11+
   pip list | grep fastapi
   
   # Frontend
   cd ../frontend
   node --version  # Should show Node 20+
   npm --version
   ```

#### What's Included

The DevContainer includes:
- Python 3.11 with all backend dependencies
- Node.js 20 with npm
- PostgreSQL client tools
- Git, curl, wget, vim
- Pre-configured VS Code extensions
- Formatted shell prompt

#### DevContainer Configuration

See `.devcontainer/devcontainer.json` for full configuration.

---

### Option 2: Local Setup

If you prefer not to use DevContainers:

#### Backend Setup

```bash
cd backend

# Create virtual environment
python3.11 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install dev dependencies
pip install -r requirements-dev.txt
```

#### Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Create environment file
cp .env.example .env.local
```

---

## Project Structure

```
markov-decision-processes/
├── .devcontainer/              # DevContainer configuration
│   ├── devcontainer.json       # Container definition
│   └── docker-compose.dev.yml  # Dev services
│
├── backend/                    # FastAPI backend
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py            # FastAPI app entry point
│   │   ├── api/               # API routes
│   │   │   ├── routes/
│   │   │   │   ├── mdp.py     # MDP endpoints
│   │   │   │   └── websocket.py
│   │   │   └── dependencies.py
│   │   ├── core/              # Core logic
│   │   │   ├── config.py
│   │   │   └── grid_world.py  # MDP algorithms
│   │   ├── services/          # Business logic
│   │   │   ├── mdp_service.py
│   │   │   └── iteration_service.py
│   │   ├── models/            # Pydantic models
│   │   │   ├── requests.py
│   │   │   └── responses.py
│   │   └── utils/
│   ├── tests/                 # Backend tests
│   ├── pyproject.toml         # Python project config
│   └── requirements.txt       # Python dependencies
│
├── frontend/                  # Next.js frontend
│   ├── src/
│   │   ├── app/              # Next.js 14 App Router
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx
│   │   │   └── globals.css
│   │   ├── components/       # React components
│   │   │   ├── visualizations/
│   │   │   ├── controls/
│   │   │   └── layout/
│   │   ├── hooks/           # Custom React hooks
│   │   │   ├── useMDP.ts
│   │   │   └── useWebSocket.ts
│   │   ├── types/           # TypeScript types
│   │   │   └── mdp.ts
│   │   └── lib/             # Utilities
│   │       ├── api.ts
│   │       └── utils.ts
│   ├── public/              # Static assets
│   ├── package.json
│   ├── tsconfig.json
│   ├── next.config.js
│   └── tailwind.config.ts
│
├── docs/                    # Documentation
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── DEPLOYMENT.md
│   └── DEVELOPMENT.md (this file)
│
├── docker-compose.yml       # Production compose
├── docker-compose.dev.yml   # Development compose
└── README.md
```

---

## Development Workflow

### Starting Development Servers

#### Using Docker Compose (Recommended)

```bash
# Start all services
docker-compose -f docker-compose.dev.yml up

# Start specific service
docker-compose -f docker-compose.dev.yml up backend
docker-compose -f docker-compose.dev.yml up frontend

# Stop services
docker-compose -f docker-compose.dev.yml down
```

#### Manual Start

**Terminal 1 - Backend:**
```bash
cd backend
source .venv/bin/activate  # If using venv
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

### Accessing the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

---

## Backend Development

### Running the Backend

```bash
cd backend

# With hot-reload (development)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# With specific log level
uvicorn app.main:app --reload --log-level debug

# With custom configuration
ENVIRONMENT=development uvicorn app.main:app --reload
```

### Adding a New API Endpoint

1. **Define Request/Response Models** (`app/models/requests.py`, `responses.py`):
   ```python
   from pydantic import BaseModel, Field
   
   class NewFeatureRequest(BaseModel):
       param1: str = Field(..., description="First parameter")
       param2: int = Field(ge=0, le=100, description="Second parameter")
   
   class NewFeatureResponse(BaseModel):
       result: str
       success: bool
   ```

2. **Create Route** (`app/api/routes/feature.py`):
   ```python
   from fastapi import APIRouter, HTTPException
   from app.models.requests import NewFeatureRequest
   from app.models.responses import NewFeatureResponse
   
   router = APIRouter(prefix="/api/feature", tags=["feature"])
   
   @router.post("/action", response_model=NewFeatureResponse)
   async def perform_action(request: NewFeatureRequest):
       # Implementation
       return NewFeatureResponse(result="success", success=True)
   ```

3. **Register Router** (`app/main.py`):
   ```python
   from app.api.routes import feature
   
   app.include_router(feature.router)
   ```

### Database Migrations (Future)

```bash
# Create migration
alembic revision --autogenerate -m "Add new table"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

### Environment Variables

Create `.env` file in `backend/`:

```env
ENVIRONMENT=development
LOG_LEVEL=debug
CORS_ORIGINS=http://localhost:3000
SESSION_TIMEOUT_MINUTES=30
```

---

## Frontend Development

### Running the Frontend

```bash
cd frontend

# Development server with hot-reload
npm run dev

# Production build
npm run build

# Start production server
npm start

# Lint code
npm run lint

# Type check
npm run type-check
```

### Creating a New Component

1. **Create Component File** (`src/components/features/MyComponent.tsx`):
   ```typescript
   import React from 'react';
   
   interface MyComponentProps {
     title: string;
     value: number;
     onChange?: (value: number) => void;
   }
   
   export function MyComponent({ title, value, onChange }: MyComponentProps) {
     return (
       <div className="p-4 border rounded">
         <h3 className="text-lg font-bold">{title}</h3>
         <p>Value: {value}</p>
         {onChange && (
           <button onClick={() => onChange(value + 1)}>
             Increment
           </button>
         )}
       </div>
     );
   }
   ```

2. **Export Component** (`src/components/features/index.ts`):
   ```typescript
   export { MyComponent } from './MyComponent';
   ```

3. **Use Component**:
   ```typescript
   import { MyComponent } from '@/components/features';
   
   export default function Page() {
     const [value, setValue] = useState(0);
     
     return (
       <MyComponent 
         title="My Feature"
         value={value}
         onChange={setValue}
       />
     );
   }
   ```

### Adding a New Hook

Create custom hook (`src/hooks/useMyFeature.ts`):

```typescript
import { useState, useEffect } from 'react';

export function useMyFeature(initialValue: number = 0) {
  const [value, setValue] = useState(initialValue);
  const [loading, setLoading] = useState(false);
  
  useEffect(() => {
    // Effect logic
  }, [value]);
  
  const increment = () => setValue(v => v + 1);
  const decrement = () => setValue(v => v - 1);
  const reset = () => setValue(initialValue);
  
  return { value, loading, increment, decrement, reset };
}
```

### Styling Guidelines

We use Tailwind CSS for styling:

```tsx
// Good: Using Tailwind utility classes
<div className="flex items-center justify-between p-4 bg-blue-500 hover:bg-blue-600">
  <span className="text-white font-bold">Title</span>
</div>

// For complex/reusable styles, create component variants
const buttonVariants = {
  primary: 'bg-blue-500 hover:bg-blue-600 text-white',
  secondary: 'bg-gray-500 hover:bg-gray-600 text-white',
  outline: 'border-2 border-blue-500 text-blue-500 hover:bg-blue-50'
};
```

---

## Testing

### Backend Tests

```bash
cd backend

# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_grid_world.py

# Run specific test
pytest tests/test_grid_world.py::test_value_iteration

# Run with output
pytest -v -s

# Run only fast tests (skip slow integration tests)
pytest -m "not slow"
```

### Writing Backend Tests

Example test (`tests/test_mdp_service.py`):

```python
import pytest
from app.services.mdp_service import MDPService
from app.models.requests import InitializeMDPRequest

@pytest.fixture
def mdp_service():
    return MDPService()

def test_create_session(mdp_service):
    config = InitializeMDPRequest(grid_size=5, gamma=0.9)
    session_id = mdp_service.create_session(config)
    
    assert session_id is not None
    assert isinstance(session_id, str)

def test_value_iteration_step(mdp_service):
    config = InitializeMDPRequest(grid_size=5, gamma=0.9)
    session_id = mdp_service.create_session(config)
    
    result = mdp_service.step(session_id, num_steps=1)
    
    assert result.iteration == 1
    assert result.delta >= 0
    assert len(result.V) == 25
```

### Frontend Tests

```bash
cd frontend

# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run in watch mode
npm run test:watch

# Run e2e tests
npm run test:e2e
```

### Writing Frontend Tests

Example test (`src/components/__tests__/MyComponent.test.tsx`):

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { MyComponent } from '../MyComponent';

describe('MyComponent', () => {
  it('renders title correctly', () => {
    render(<MyComponent title="Test Title" value={0} />);
    expect(screen.getByText('Test Title')).toBeInTheDocument();
  });
  
  it('calls onChange when button clicked', () => {
    const handleChange = jest.fn();
    render(
      <MyComponent 
        title="Test" 
        value={5} 
        onChange={handleChange} 
      />
    );
    
    fireEvent.click(screen.getByText('Increment'));
    expect(handleChange).toHaveBeenCalledWith(6);
  });
});
```

---

## Code Quality

### Linting

**Backend (Ruff)**:
```bash
cd backend

# Check code
ruff check .

# Auto-fix issues
ruff check --fix .

# Format code
ruff format .
```

**Frontend (ESLint + Prettier)**:
```bash
cd frontend

# Lint
npm run lint

# Auto-fix
npm run lint:fix

# Format
npm run format
```

### Type Checking

**Backend (mypy)**:
```bash
cd backend
mypy app/
```

**Frontend (TypeScript)**:
```bash
cd frontend
npm run type-check
```

### Pre-commit Hooks

Install pre-commit hooks:

```bash
# Install pre-commit
pip install pre-commit

# Setup hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

---

## Debugging

### Backend Debugging

#### VS Code Launch Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: FastAPI",
      "type": "python",
      "request": "launch",
      "module": "uvicorn",
      "args": [
        "app.main:app",
        "--reload",
        "--host", "0.0.0.0",
        "--port", "8000"
      ],
      "jinja": true,
      "justMyCode": false,
      "cwd": "${workspaceFolder}/backend"
    }
  ]
}
```

#### Using pdb

```python
# Add breakpoint in code
import pdb; pdb.set_trace()

# Or use built-in breakpoint()
breakpoint()
```

### Frontend Debugging

#### Browser DevTools

1. Open Chrome/Firefox DevTools (F12)
2. Navigate to Sources tab
3. Set breakpoints in TypeScript files
4. Use Console for interactive debugging

#### VS Code Debugging

Install "Debugger for Chrome" extension, then create launch config:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Next.js: debug full stack",
      "type": "node-terminal",
      "request": "launch",
      "command": "npm run dev",
      "cwd": "${workspaceFolder}/frontend",
      "serverReadyAction": {
        "pattern": "started server on .+, url: (https?://.+)",
        "uriFormat": "%s",
        "action": "debugWithChrome"
      }
    }
  ]
}
```

---

## Common Tasks

### Adding a New Python Dependency

```bash
cd backend

# Install package
pip install package-name

# Add to requirements.txt
pip freeze | grep package-name >> requirements.txt

# Or use pip-tools
pip-compile requirements.in
```

### Adding a New npm Package

```bash
cd frontend

# Install package
npm install package-name

# Install dev dependency
npm install --save-dev package-name

# Update package.json
npm update package-name
```

### Database Reset (Future)

```bash
# Drop all tables
alembic downgrade base

# Re-create all tables
alembic upgrade head

# Seed with test data
python scripts/seed_database.py
```

### Clear All Caches

```bash
# Backend
cd backend
rm -rf .pytest_cache __pycache__ .coverage htmlcov
find . -type d -name "__pycache__" -exec rm -rf {} +

# Frontend
cd frontend
rm -rf .next node_modules/.cache
npm run clean
```

### Generate API Client (Future)

```bash
# Generate TypeScript client from OpenAPI spec
npx openapi-typescript-codegen \
  --input http://localhost:8000/openapi.json \
  --output frontend/src/lib/api-client \
  --client fetch
```

---

## Troubleshooting

### Common Issues

#### Port Already in Use

```bash
# Find process using port 8000
lsof -i :8000

# Kill process
kill -9 <PID>

# Or use different port
uvicorn app.main:app --reload --port 8001
```

#### Module Not Found (Python)

```bash
# Ensure virtual environment is activated
source .venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt

# Check PYTHONPATH
echo $PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:${PWD}"
```

#### TypeScript Errors

```bash
cd frontend

# Clear Next.js cache
rm -rf .next

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Restart TypeScript server in VS Code
# Cmd/Ctrl+Shift+P -> "TypeScript: Restart TS Server"
```

#### Docker Issues

```bash
# Remove all containers and volumes
docker-compose -f docker-compose.dev.yml down -v

# Rebuild images
docker-compose -f docker-compose.dev.yml build --no-cache

# Clean Docker system
docker system prune -a --volumes
```

#### DevContainer Won't Start

1. Check Docker Desktop is running
2. Ensure no other containers using same ports
3. Try rebuilding container:
   - `F1` -> "Dev Containers: Rebuild Container"
4. Check logs: `F1` -> "Dev Containers: Show Container Log"

---

## Best Practices

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature"

# Push to remote
git push origin feature/my-feature

# Create Pull Request on GitHub
```

### Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new visualization component
fix: resolve session timeout issue
docs: update API documentation
refactor: simplify iteration logic
test: add tests for MDP service
chore: update dependencies
```

### Code Review Checklist

- [ ] Code follows project style guidelines
- [ ] All tests pass
- [ ] Type checking passes (TypeScript/mypy)
- [ ] Linting passes (ESLint/Ruff)
- [ ] Documentation updated if needed
- [ ] No console.log or debug prints in production code
- [ ] Error handling is appropriate
- [ ] Performance considerations addressed

---

## Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Python Type Hints](https://docs.python.org/3/library/typing.html)

---

## Getting Help

- **GitHub Issues**: Report bugs or request features
- **Discussions**: Ask questions in GitHub Discussions
- **Documentation**: Check other docs in `docs/` folder
- **Team Chat**: Slack/Discord channel (if applicable)

---

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for detailed contribution guidelines.
