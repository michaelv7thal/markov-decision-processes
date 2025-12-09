# MDP Visualizer - Interactive Markov Decision Process Explorer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![TypeScript](https://img.shields.io/badge/typescript-5.3+-blue.svg)](https://www.typescriptlang.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109+-009688.svg)](https://fastapi.tiangolo.com/)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black.svg)](https://nextjs.org/)

A modern, full-stack web application for visualizing and exploring Markov Decision Process (MDP) algorithms in real-time. Built with Next.js, TypeScript, FastAPI, and Python.

![MDP Visualizer Demo](docs/images/demo.gif)

---

## 🌟 Features

### Core Functionality
- **Interactive Visualization**: Real-time heatmap, policy grid, and convergence charts
- **Multiple Algorithms**: Value Iteration and Policy Iteration
- **Step-by-Step Execution**: Execute one step at a time or run to convergence
- **Configurable Parameters**: Adjust discount factor (gamma) and grid size on-the-fly
- **State Navigation**: Explore individual states with directional controls
- **WebSocket Streaming**: Real-time updates during algorithm convergence

### Technical Highlights
- **Modern Stack**: Next.js 14 (App Router), TypeScript, FastAPI, Python 3.11+
- **Responsive Design**: Mobile-friendly interface with Tailwind CSS
- **Type Safety**: Full TypeScript frontend, Pydantic backend validation
- **Docker Ready**: Complete Docker Compose setup for development and production
- **DevContainer Support**: Consistent development environment
- **REST + WebSocket API**: Complete backend API with OpenAPI documentation

---

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** 24.0+ ([Install](https://www.docker.com/products/docker-desktop/))
- **VS Code** with Dev Containers extension (recommended)

### Option 1: DevContainer (Recommended)

```bash
# Clone repository
git clone https://github.com/yourusername/markov-decision-processes.git
cd markov-decision-processes

# Open in VS Code
code .

# Reopen in Container (Cmd/Ctrl+Shift+P -> "Dev Containers: Reopen in Container")
# Wait for container to build (~5 minutes first time)

# Services will start automatically
```

### Option 2: Docker Compose

```bash
# Clone repository
git clone https://github.com/yourusername/markov-decision-processes.git
cd markov-decision-processes

# Start development environment
docker-compose -f docker-compose.dev.yml up

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000/docs
```

### Option 3: Local Development

**Backend:**
```bash
cd backend
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```

---

## 📚 Documentation

- **[Architecture](docs/ARCHITECTURE.md)** - System design and component architecture
- **[API Reference](docs/API.md)** - Complete REST and WebSocket API documentation
- **[Development Guide](docs/DEVELOPMENT.md)** - Setup and development workflow
- **[Deployment Guide](docs/DEPLOYMENT.md)** - Production deployment instructions

---

## 🎮 Usage

### Basic Workflow

1. **Initialize**: Set grid size (3-20) and gamma (0.0-1.0)
2. **Choose Algorithm**: Select Value Iteration or Policy Iteration
3. **Execute**: Step through iterations or run to convergence
4. **Explore**: Navigate states and observe value/policy changes
5. **Analyze**: View convergence metrics and iteration history

### Example API Usage

```bash
# Initialize new MDP session
curl -X POST http://localhost:8000/api/mdp/initialize \
  -H "Content-Type: application/json" \
  -d '{
    "grid_size": 5,
    "gamma": 0.9,
    "algorithm": "value_iteration"
  }'

# Execute 10 iteration steps
curl -X POST http://localhost:8000/api/mdp/{session_id}/step \
  -H "Content-Type: application/json" \
  -d '{"num_steps": 10}'

# Get current state
curl http://localhost:8000/api/mdp/{session_id}/state
```

---

## 🏗️ Project Structure

```
markov-decision-processes/
├── backend/                # FastAPI backend
│   ├── app/
│   │   ├── api/           # REST endpoints
│   │   ├── core/          # MDP algorithms
│   │   ├── services/      # Business logic
│   │   └── models/        # Pydantic models
│   └── tests/             # Backend tests
├── frontend/              # Next.js frontend
│   ├── src/
│   │   ├── app/           # Next.js pages
│   │   ├── components/    # React components
│   │   ├── hooks/         # Custom hooks
│   │   └── types/         # TypeScript types
│   └── public/            # Static assets
├── docs/                  # Documentation
├── .devcontainer/         # DevContainer config
└── docker-compose*.yml    # Docker configurations
```

---

## 🧪 Testing

### Backend Tests

```bash
cd backend
pytest                      # Run all tests
pytest --cov=app           # With coverage
pytest tests/test_grid_world.py  # Specific test
```

### Frontend Tests

```bash
cd frontend
npm test                   # Run all tests
npm run test:coverage      # With coverage
npm run test:e2e          # E2E tests
```

---

## 🛠️ Technology Stack

### Frontend
- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript 5.3+
- **Styling**: Tailwind CSS 3.4+
- **Visualization**: Recharts, Canvas API
- **State Management**: React Hooks

### Backend
- **Framework**: FastAPI 0.109+
- **Language**: Python 3.11+
- **Validation**: Pydantic 2.5+
- **Computation**: NumPy 1.26+
- **WebSocket**: Native FastAPI support

### Infrastructure
- **Containers**: Docker 24+, Docker Compose 2.23+
- **Development**: VS Code DevContainers
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus, Grafana (optional)

---

## 📊 Algorithms

### Value Iteration

Implements the Bellman optimality equation:

$$V(s) = \max_a \left[ R(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s') \right]$$

- Guaranteed convergence to optimal policy
- Iteration complexity: O(|S|² |A|)

### Policy Iteration

Two-phase algorithm:
1. **Policy Evaluation**: Compute V^π using Bellman expectation
2. **Policy Improvement**: Greedy policy update

- Fewer iterations than value iteration
- More computation per iteration

---

## 🌐 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/mdp/initialize` | Create new MDP session |
| POST | `/api/mdp/{id}/step` | Execute iteration steps |
| GET | `/api/mdp/{id}/state` | Get current state |
| PATCH | `/api/mdp/{id}/config` | Update configuration |
| POST | `/api/mdp/{id}/reset` | Reset iteration |
| DELETE | `/api/mdp/{id}` | Delete session |
| WebSocket | `/ws/{id}` | Real-time updates |

See [API Documentation](docs/API.md) for full reference.

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'feat: add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow [Conventional Commits](https://www.conventionalcommits.org/)
- Write tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR
- Follow existing code style (ESLint, Ruff)

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Based on Sutton & Barto's "Reinforcement Learning: An Introduction"
- GridWorld environment from Example 3.5 (Jack's Car Rental variant)
- Inspired by classic RL visualization tools

---

## 📮 Contact & Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/yourusername/markov-decision-processes/issues)
- **Discussions**: [Ask questions](https://github.com/yourusername/markov-decision-processes/discussions)
- **Email**: your.email@example.com

---

## 🗺️ Roadmap

### Phase 1: MVP (Current)
- [x] Basic GridWorld implementation
- [x] Value Iteration algorithm
- [x] Policy Iteration algorithm
- [x] Interactive matplotlib visualization
- [ ] Full-stack web application
- [ ] Docker deployment

### Phase 2: Enhancement
- [ ] Additional algorithms (Q-learning, SARSA)
- [ ] Custom environment editor
- [ ] Multi-user support with authentication
- [ ] Result export (JSON, CSV, PNG)

### Phase 3: Advanced Features
- [ ] 3D visualization
- [ ] Algorithm comparison mode
- [ ] Mobile app (React Native)
- [ ] Real-time collaboration

---

## 📈 Performance

Expected performance on modern hardware:

| Grid Size | Convergence Time | Memory Usage |
|-----------|------------------|--------------|
| 5×5 | 50-100ms | ~10MB |
| 10×10 | 200-500ms | ~50MB |
| 20×20 | 1-2s | ~200MB |

---

## 🔒 Security

- Input validation with Pydantic
- Session-based isolation
- Rate limiting on API endpoints
- CORS configuration
- SSL/TLS in production
- Non-root Docker containers

Report security vulnerabilities to: security@yourdomain.com

---

## 📸 Screenshots

### Dashboard View
![Dashboard](docs/images/dashboard.png)

### Value Iteration
![Value Iteration](docs/images/value-iteration.png)

### Convergence Analysis
![Convergence](docs/images/convergence.png)

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/markov-decision-processes&type=Date)](https://star-history.com/#yourusername/markov-decision-processes&Date)

---

**Built with ❤️ for the reinforcement learning community**
