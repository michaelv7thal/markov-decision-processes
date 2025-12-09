# Monorepo Setup with Nx and uv

This monorepo uses **Nx** for task orchestration and caching, and **uv** for fast Python package management.

## Structure

```
markov-decision-processes/
├── pyproject.toml          # Python dependencies (managed by uv)
├── package.json            # Node.js workspace with Nx
├── nx.json                 # Nx configuration
├── tsconfig.json           # Root TypeScript config
├── .venv/                  # Python virtual environment (uv)
├── node_modules/           # Root npm dependencies
├── .nx/                    # Nx cache
├── backend/                # FastAPI backend
│   ├── app/
│   ├── tests/
│   └── .env
├── frontend/               # Next.js frontend
│   ├── package.json        # Nx-aware project
│   ├── tsconfig.json
│   ├── src/
│   └── .env.local
└── scripts/                # Automation scripts
    ├── setup.sh
    ├── test-all.sh
    ├── format.sh
    └── clean.sh
```

## Why Nx?

**Benefits:**
- ⚡ **Task Caching**: Never rebuild/test the same code twice
- 📊 **Dependency Graph**: Visualize project relationships with `npm run graph`
- 🎯 **Affected Commands**: Run tasks only on changed projects
- 🔄 **Task Orchestration**: Parallel execution with smart dependency management
- 📦 **Workspace Management**: Coordinate frontend/backend development

## Why uv?

**Benefits:**
- 🚀 **10-100x faster** than pip for package installation
- 📦 **Built-in virtual environment** management
- 🔒 **Deterministic** dependency resolution
- 🎯 **Drop-in replacement** for pip (but faster)
- 📝 **Compatible** with existing pyproject.toml files

## Quick Start

```bash
# Initial setup (installs uv if needed)
./scripts/setup.sh

# Activate Python environment
source .venv/bin/activate
```

## Development Commands

### Frontend Development
```bash
# Start Next.js dev server
npm run dev
# or
nx run frontend:dev

# Build frontend
npm run build
# or
nx run frontend:build

# Type check
nx run frontend:type-check

# Lint
nx run frontend:lint
```

### Backend Development
```bash
# Start FastAPI server with hot reload
npm run dev:backend
# or
uv run uvicorn backend.app.main:app --reload

# Run tests
npm run test:backend
# or
uv run pytest backend/tests

# Lint
npm run lint:backend
# or
uv run ruff check backend/
```

### Run Multiple Tasks
```bash
# Run dev servers for all projects
npm run dev:all

# Build all projects
npm run build:all

# Run all tests
npm test
# or
./scripts/test-all.sh

# Lint everything
npm run lint

# Format everything
npm run format
# or
./scripts/format.sh
```

### Nx-Specific Commands
```bash
# View dependency graph (opens in browser)
npm run graph

# Run affected tests (only test changed projects)
nx affected -t test

# Clear Nx cache
nx reset

# Show what would be affected by current changes
nx show projects --affected
```

## Adding Dependencies

### Python Dependencies (with uv)

Edit `pyproject.toml`:
```toml
dependencies = [
    "numpy>=1.24.0",
    "your-package>=1.0.0",
]
```

Install:
```bash
uv pip install -e ".[dev]"
# or
uv pip install your-package
```

### Node.js Dependencies

#### Root dependencies:
```bash
npm install -D some-tool
```

#### Frontend dependencies:
```bash
npm install recharts --workspace=frontend
# or
cd frontend && npm install recharts
```

## Python with uv

### Common uv Commands

```bash
# Create virtual environment
uv venv .venv

# Install dependencies
uv pip install -e ".[dev]"

# Install a single package
uv pip install fastapi

# List installed packages
uv pip list

# Update a package
uv pip install --upgrade fastapi

# Run a command in the virtual environment
uv run pytest
uv run python script.py
```

### Why uv is Fast

- Written in Rust (not Python)
- Parallel downloads and installations
- Smart caching across projects
- Zero-copy installations when possible

## Nx Task Pipeline

Nx automatically manages task dependencies:

```
frontend:build
  ↓
frontend:lint (can run in parallel)
  ↓
frontend:test (uses build output)
```

### Caching

Nx caches task outputs based on:
- Source code changes
- Dependencies changes
- Configuration changes

Example:
```bash
# First run: builds and tests
nx run frontend:test
# ✓ Completed (5s)

# Second run: instant (from cache)
nx run frontend:test
# ✓ Completed [existing outputs match the cache, left as is]
```

## VS Code Integration

Settings configured in `.vscode/settings.json`:
- Python interpreter: `${workspaceFolder}/.venv/bin/python`
- Ruff formatter and linter enabled
- Nx task detection
- TypeScript SDK from workspace

## Environment Variables

### Backend (`.env`)
```env
ENVIRONMENT=development
API_HOST=0.0.0.0
API_PORT=8000
ALLOWED_ORIGINS=http://localhost:3000
```

### Frontend (`.env.local`)
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_WS_URL=ws://localhost:8000
```

## Monorepo Benefits

1. **Single Source of Truth**: All code in one repo
2. **Shared Tooling**: One set of dev tools for everything
3. **Atomic Changes**: Update frontend + backend in one commit
4. **Dependency Management**: Clear relationships between projects
5. **Task Caching**: Nx speeds up all operations
6. **Fast Python**: uv makes Python installation instant

## Troubleshooting

### uv not found
```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"
```

### Nx cache issues
```bash
# Clear cache
nx reset
```

### Python import errors
```bash
# Reinstall with uv
source .venv/bin/activate
uv pip install -e ".[dev]"
```

### Frontend build errors
```bash
# Clear Next.js and Nx cache
nx reset
rm -rf frontend/.next
npm install
```

### Deep clean and restart
```bash
./scripts/clean.sh --deep
./scripts/setup.sh
```

## Performance Comparison

### uv vs pip
- **uv**: Install 100 packages in ~2 seconds
- **pip**: Same installation takes ~30-60 seconds

### Nx Caching
- **First run**: Full build + test = 45 seconds
- **Cached run**: Same tasks = 0.2 seconds
- **Affected only**: Only rebuild changed code

## Learn More

- [Nx Documentation](https://nx.dev)
- [uv Documentation](https://docs.astral.sh/uv/)
- [Next.js Documentation](https://nextjs.org/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com)
