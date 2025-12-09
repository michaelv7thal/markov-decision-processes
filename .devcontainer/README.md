# DevContainer Setup

This directory contains the DevContainer configuration for the MDP Visualizer monorepo.

## Features

- **Python 3.12** with uv package manager
- **Node.js 20** with npm
- **Git** and GitHub CLI
- **Pre-configured VS Code extensions**:
  - Python (Pylance, Ruff)
  - TypeScript/JavaScript (ESLint, Prettier)
  - Docker, YAML, Markdown support
- **Port forwarding**: 3000 (Next.js), 8000 (FastAPI)
- **Persistent volumes** for node_modules and .venv

## Quick Start

### Using VS Code

1. Install the **Dev Containers** extension
2. Open the project folder
3. Press `F1` → "Dev Containers: Reopen in Container"
4. Wait for the container to build and setup to complete

### Manual Build

```bash
# Build the container
docker-compose -f .devcontainer/docker-compose.yml build

# Start the container
docker-compose -f .devcontainer/docker-compose.yml up -d

# Attach to the container
docker exec -it <container-id> /bin/bash
```

## Post-Create Setup

The `post-create.sh` script automatically:

1. Installs uv if not present
2. Creates Python virtual environment
3. Installs all Python dependencies via `uv sync`
4. Installs Node.js dependencies via `npm install`
5. Creates `.env` files if missing

## Development Workflow

```bash
# Activate Python environment (already done in devcontainer)
source .venv/bin/activate

# Start backend
npm run dev:backend

# Start frontend (in another terminal)
npm run dev

# Or start both
npm run dev:all
```

## Ports

- **3000**: Next.js frontend
- **8000**: FastAPI backend

Ports are automatically forwarded and accessible from your host machine.

## Customization

### Add VS Code Extensions

Edit [devcontainer.json](devcontainer.json):

```json
"customizations": {
  "vscode": {
    "extensions": [
      "your-extension-id"
    ]
  }
}
```

### Add System Packages

Edit [Dockerfile](Dockerfile):

```dockerfile
RUN apt-get update && apt-get install -y \
    your-package \
    && apt-get clean -y
```

### Environment Variables

Edit [docker-compose.yml](docker-compose.yml):

```yaml
environment:
  - YOUR_VAR=value
```

## Volumes

Persistent volumes are used for:

- `node_modules/` - Root Node.js dependencies
- `frontend/node_modules/` - Frontend dependencies
- `.venv/` - Python virtual environment

This improves performance and preserves dependencies between container rebuilds.

## Troubleshooting

### Rebuild Container

```bash
# In VS Code: F1 → "Dev Containers: Rebuild Container"
# Or manually:
docker-compose -f .devcontainer/docker-compose.yml build --no-cache
```

### Reset Volumes

```bash
docker-compose -f .devcontainer/docker-compose.yml down -v
```

### Check Logs

```bash
docker-compose -f .devcontainer/docker-compose.yml logs
```
