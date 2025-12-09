# Architecture Documentation

## System Overview

The MDP Visualizer is a full-stack web application designed to provide interactive visualization and exploration of Markov Decision Process algorithms. The system follows a modern microservices architecture with a clear separation between frontend presentation, backend business logic, and the core MDP computation engine.

---

## High-Level Architecture

```mermaid
graph TB
    subgraph "Client Browser"
        UI[Next.js Frontend<br/>TypeScript + React]
        WS[WebSocket Client]
    end
    
    subgraph "Docker Compose Network"
        subgraph "Frontend Container"
            NEXT[Next.js Server<br/>Port 3000]
        end
        
        subgraph "Backend Container"
            API[FastAPI Server<br/>Port 8000]
            MDP[MDP Engine<br/>GridWorld + Algorithms]
            WS_SERVER[WebSocket Handler]
        end
    end
    
    UI -->|HTTP/REST| API
    WS -->|WebSocket| WS_SERVER
    API --> MDP
    WS_SERVER --> MDP
    
    style UI fill:#61dafb
    style NEXT fill:#1565c0
    style API fill:#009688
    style MDP fill:#00695c
    style WS_SERVER fill:#00695c
```

### Architecture Layers

1. **Presentation Layer** (Frontend)
   - Next.js 14+ with App Router
   - React 18+ for UI components
   - TypeScript for type safety
   - Tailwind CSS for styling
   - Real-time visualization with Canvas/SVG and Recharts

2. **API Layer** (Backend)
   - FastAPI for REST endpoints
   - WebSocket support for real-time updates
   - Pydantic for data validation
   - Session management for concurrent users

3. **Business Logic Layer** (Services)
   - MDP service for session orchestration
   - Iteration service for algorithm execution
   - State management and caching

4. **Core Layer** (MDP Engine)
   - GridWorld environment implementation
   - Value Iteration algorithm
   - Policy Iteration algorithm
   - Matrix operations with NumPy

---

## Component Architecture

```mermaid
graph TB
    subgraph "Frontend Components"
        D[Dashboard Layout]
        
        subgraph "Visualization Components"
            VH[ValueHeatmap<br/>Canvas-based heatmap]
            PG[PolicyGrid<br/>SVG arrow grid]
            CC[ConvergenceChart<br/>Line chart]
        end
        
        subgraph "Control Components"
            IC[IterationControls<br/>Step/Converge/Reset]
            GS[GammaSlider<br/>Discount factor]
            AS[AlgorithmSelector<br/>VI/PI toggle]
            SN[StateNavigation<br/>Directional buttons]
        end
        
        D --> VH
        D --> PG
        D --> CC
        D --> IC
        D --> GS
        D --> AS
        D --> SN
    end
    
    subgraph "State Management"
        H[useMDP Hook<br/>React Context]
        API_CLIENT[API Client<br/>Fetch wrapper]
        WS_CLIENT[WebSocket Client<br/>Connection manager]
        
        H --> API_CLIENT
        H --> WS_CLIENT
    end
    
    D --> H
    
    subgraph "Backend Services"
        ROUTES[API Routes]
        MDPSVC[MDP Service<br/>Session management]
        ITERSVC[Iteration Service<br/>Algorithm execution]
        GW[GridWorld<br/>Environment]
        
        ROUTES --> MDPSVC
        MDPSVC --> ITERSVC
        ITERSVC --> GW
    end
    
    API_CLIENT --> ROUTES
    WS_CLIENT --> ROUTES
    
    style D fill:#ff6b6b
    style H fill:#4ecdc4
    style ROUTES fill:#f39c12
    style MDPSVC fill:#e67e22
```

---

## Data Flow Architecture

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant API
    participant MDPService
    participant GridWorld
    
    User->>Frontend: Initialize MDP (grid_size=5, gamma=0.9)
    Frontend->>API: POST /api/mdp/initialize
    API->>MDPService: create_session()
    MDPService->>GridWorld: GridWorld(grid_size=5)
    GridWorld-->>MDPService: instance
    MDPService->>GridWorld: build_transition_matrices()
    GridWorld-->>MDPService: P, R matrices
    MDPService-->>API: session_id, initial_state
    API-->>Frontend: {session_id, V, policy, ...}
    Frontend-->>User: Display initial visualization
    
    User->>Frontend: Click "Step Once"
    Frontend->>API: POST /api/mdp/{session_id}/step
    API->>MDPService: get_session(session_id)
    MDPService->>GridWorld: perform_bellman_backup()
    GridWorld-->>MDPService: updated V, delta
    MDPService-->>API: iteration_result
    API-->>Frontend: {V, policy, iteration, delta}
    Frontend-->>User: Update visualizations
    
    User->>Frontend: Click "Converge"
    Frontend->>API: WebSocket connect /ws/{session_id}
    API->>MDPService: run_to_convergence()
    loop Every N iterations
        MDPService->>GridWorld: perform_bellman_backup()
        GridWorld-->>MDPService: updated state
        MDPService->>API: intermediate_update
        API-->>Frontend: WebSocket message
        Frontend-->>User: Real-time visualization update
    end
    MDPService->>API: convergence_complete
    API-->>Frontend: Final WebSocket message
    Frontend-->>User: Show convergence status
```

---

## See Also

- [API Documentation](./API.md) - Complete REST and WebSocket API reference
- [Development Guide](./DEVELOPMENT.md) - Setup and development workflow
- [Deployment Guide](./DEPLOYMENT.md) - Production deployment instructions 