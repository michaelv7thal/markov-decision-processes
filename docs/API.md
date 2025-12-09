# API Documentation

Complete API reference for the MDP Visualizer backend services.

**Base URL**: `http://localhost:8000`  
**API Version**: v1  
**Content-Type**: `application/json`

---

## Table of Contents

- [Authentication](#authentication)
- [REST Endpoints](#rest-endpoints)
  - [Initialize MDP](#initialize-mdp)
  - [Execute Iteration Step](#execute-iteration-step)
  - [Get Current State](#get-current-state)
  - [Update Configuration](#update-configuration)
  - [Reset Session](#reset-session)
  - [Delete Session](#delete-session)
- [WebSocket API](#websocket-api)
- [Data Models](#data-models)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)

---

## Authentication

**MVP Version**: No authentication required. Sessions are identified by UUID.

**Future**: JWT-based authentication with Bearer tokens.

```http
Authorization: Bearer <token>
```

---

## REST Endpoints

### Initialize MDP

Create a new MDP session with specified configuration.

#### Request

```http
POST /api/mdp/initialize
Content-Type: application/json
```

**Body**:
```json
{
  "grid_size": 5,
  "gamma": 0.9,
  "algorithm": "value_iteration"
}
```

**Parameters**:
| Field | Type | Required | Default | Constraints | Description |
|-------|------|----------|---------|-------------|-------------|
| `grid_size` | integer | No | 5 | 3 ≤ n ≤ 20 | Grid dimensions (n×n) |
| `gamma` | float | No | 0.9 | 0.0 ≤ γ ≤ 1.0 | Discount factor |
| `algorithm` | string | No | "value_iteration" | ["value_iteration", "policy_iteration"] | Algorithm type |

#### Response

**Status**: `201 Created`

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "grid_size": 5,
  "num_states": 25,
  "gamma": 0.9,
  "algorithm": "value_iteration",
  "V": [0.0, 0.0, 0.0, ...],
  "policy": [0, 0, 0, ...],
  "iteration": 0,
  "converged": false,
  "special_states": {
    "A": [0, 1],
    "A_prime": [4, 1],
    "B": [0, 3],
    "B_prime": [2, 3]
  },
  "timestamp": "2025-11-29T10:30:00Z"
}
```

#### Example

```bash
curl -X POST http://localhost:8000/api/mdp/initialize \
  -H "Content-Type: application/json" \
  -d '{
    "grid_size": 5,
    "gamma": 0.9,
    "algorithm": "value_iteration"
  }'
```

---

### Execute Iteration Step

Perform one or more iteration steps on an existing session.

#### Request

```http
POST /api/mdp/{session_id}/step
Content-Type: application/json
```

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_id` | string (UUID) | Session identifier |

**Body**:
```json
{
  "num_steps": 1
}
```

**Parameters**:
| Field | Type | Required | Default | Constraints | Description |
|-------|------|----------|---------|-------------|-------------|
| `num_steps` | integer | No | 1 | 1 ≤ n ≤ 100 | Number of iterations to execute |

#### Response

**Status**: `200 OK`

```json
{
  "V": [0.5, 1.2, 0.8, ...],
  "policy": [3, 1, 0, ...],
  "iteration": 1,
  "converged": false,
  "delta": 0.15,
  "max_change": 0.15,
  "execution_time_ms": 12.5
}
```

**Response Fields**:
| Field | Type | Description |
|-------|------|-------------|
| `V` | float[] | Updated value function |
| `policy` | int[] | Updated policy (action indices) |
| `iteration` | integer | Current iteration count |
| `converged` | boolean | Whether algorithm has converged |
| `delta` | float | Maximum value change from previous iteration |
| `max_change` | float | Same as delta (for compatibility) |
| `execution_time_ms` | float | Time taken for execution in milliseconds |

#### Example

```bash
curl -X POST http://localhost:8000/api/mdp/550e8400-e29b-41d4-a716-446655440000/step \
  -H "Content-Type: application/json" \
  -d '{"num_steps": 10}'
```

---

### Get Current State

Retrieve the current state of an MDP session without performing any iterations.

#### Request

```http
GET /api/mdp/{session_id}/state
```

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_id` | string (UUID) | Session identifier |

#### Response

**Status**: `200 OK`

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "grid_size": 5,
  "num_states": 25,
  "gamma": 0.9,
  "algorithm": "value_iteration",
  "V": [1.5, 2.3, 1.8, ...],
  "policy": [3, 1, 0, ...],
  "iteration": 42,
  "converged": true,
  "delta": 0.00005,
  "history_length": 43,
  "created_at": "2025-11-29T10:30:00Z",
  "last_updated": "2025-11-29T10:32:15Z"
}
```

#### Example

```bash
curl http://localhost:8000/api/mdp/550e8400-e29b-41d4-a716-446655440000/state
```

---

### Update Configuration

Update session configuration (gamma or algorithm). This resets the iteration state.

#### Request

```http
PATCH /api/mdp/{session_id}/config
Content-Type: application/json
```

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_id` | string (UUID) | Session identifier |

**Body**:
```json
{
  "gamma": 0.95,
  "algorithm": "policy_iteration"
}
```

**Parameters**:
| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `gamma` | float | No | 0.0 ≤ γ ≤ 1.0 | New discount factor |
| `algorithm` | string | No | ["value_iteration", "policy_iteration"] | New algorithm type |

**Note**: At least one field must be provided.

#### Response

**Status**: `200 OK`

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "gamma": 0.95,
  "algorithm": "policy_iteration",
  "V": [0.0, 0.0, 0.0, ...],
  "policy": [0, 0, 0, ...],
  "iteration": 0,
  "converged": false,
  "message": "Configuration updated and session reset"
}
```

#### Example

```bash
curl -X PATCH http://localhost:8000/api/mdp/550e8400-e29b-41d4-a716-446655440000/config \
  -H "Content-Type: application/json" \
  -d '{"gamma": 0.95}'
```

---

### Reset Session

Reset the iteration state of a session while preserving configuration.

#### Request

```http
POST /api/mdp/{session_id}/reset
```

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_id` | string (UUID) | Session identifier |

#### Response

**Status**: `200 OK`

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "V": [0.0, 0.0, 0.0, ...],
  "policy": [0, 0, 0, ...],
  "iteration": 0,
  "converged": false,
  "message": "Session reset to initial state"
}
```

#### Example

```bash
curl -X POST http://localhost:8000/api/mdp/550e8400-e29b-41d4-a716-446655440000/reset
```

---

### Delete Session

Delete a session and free up server resources.

#### Request

```http
DELETE /api/mdp/{session_id}
```

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_id` | string (UUID) | Session identifier |

#### Response

**Status**: `204 No Content`

#### Example

```bash
curl -X DELETE http://localhost:8000/api/mdp/550e8400-e29b-41d4-a716-446655440000
```

---

## WebSocket API

Real-time communication for streaming iteration updates during convergence.

### Connection

```
WebSocket: ws://localhost:8000/ws/{session_id}
```

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `session_id` | string (UUID) | Session identifier |

### Message Protocol

#### Client → Server Messages

##### Converge Command

Request the algorithm to run until convergence with periodic updates.

```json
{
  "action": "converge",
  "max_iterations": 1000,
  "update_interval": 10
}
```

**Fields**:
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `action` | string | Yes | - | Must be "converge" |
| `max_iterations` | integer | No | 1000 | Maximum iterations before stopping |
| `update_interval` | integer | No | 10 | Send update every N iterations |

##### Step Command

Execute a single step or multiple steps.

```json
{
  "action": "step",
  "num_steps": 5
}
```

##### Stop Command

Stop the current convergence process.

```json
{
  "action": "stop"
}
```

#### Server → Client Messages

##### Iteration Update

Periodic update during convergence.

```json
{
  "type": "iteration_update",
  "iteration": 50,
  "V": [2.1, 3.5, 2.8, ...],
  "policy": [3, 1, 0, ...],
  "delta": 0.05,
  "converged": false,
  "timestamp": "2025-11-29T10:32:15.123Z"
}
```

##### Convergence Complete

Final message when algorithm converges or reaches max iterations.

```json
{
  "type": "convergence_complete",
  "iteration": 73,
  "V": [5.2, 7.8, 6.1, ...],
  "policy": [3, 1, 0, ...],
  "delta": 0.00008,
  "converged": true,
  "total_time_ms": 1250.5,
  "timestamp": "2025-11-29T10:32:16.373Z"
}
```

##### Error Message

Error during WebSocket operation.

```json
{
  "type": "error",
  "error": "Session not found",
  "code": "SESSION_NOT_FOUND",
  "timestamp": "2025-11-29T10:32:15.123Z"
}
```

### Example Usage (JavaScript)

```javascript
// Connect to WebSocket
const ws = new WebSocket(`ws://localhost:8000/ws/${sessionId}`);

// Connection opened
ws.addEventListener('open', () => {
  console.log('WebSocket connected');
  
  // Request convergence
  ws.send(JSON.stringify({
    action: 'converge',
    max_iterations: 1000,
    update_interval: 10
  }));
});

// Listen for messages
ws.addEventListener('message', (event) => {
  const data = JSON.parse(event.data);
  
  switch (data.type) {
    case 'iteration_update':
      console.log(`Iteration ${data.iteration}, delta: ${data.delta}`);
      updateVisualization(data.V, data.policy);
      break;
      
    case 'convergence_complete':
      console.log(`Converged at iteration ${data.iteration}`);
      updateVisualization(data.V, data.policy);
      showConvergenceNotification();
      ws.close();
      break;
      
    case 'error':
      console.error(`Error: ${data.error}`);
      break;
  }
});

// Connection closed
ws.addEventListener('close', () => {
  console.log('WebSocket disconnected');
});

// Stop convergence
function stopConvergence() {
  ws.send(JSON.stringify({ action: 'stop' }));
}
```

---

## Data Models

### MDPConfig

Configuration for creating a new MDP session.

```typescript
interface MDPConfig {
  grid_size: number;      // 3-20, default: 5
  gamma: number;          // 0.0-1.0, default: 0.9
  algorithm: 'value_iteration' | 'policy_iteration';  // default: 'value_iteration'
}
```

### MDPState

Complete state of an MDP session.

```typescript
interface MDPState {
  session_id: string;
  grid_size: number;
  num_states: number;
  gamma: number;
  algorithm: 'value_iteration' | 'policy_iteration';
  V: number[];            // Value function (length: num_states)
  policy: number[];       // Policy as action indices (length: num_states)
  iteration: number;
  converged: boolean;
  delta?: number;
  special_states: {
    A: [number, number];
    A_prime: [number, number];
    B: [number, number];
    B_prime: [number, number];
  };
  created_at?: string;    // ISO 8601 timestamp
  last_updated?: string;  // ISO 8601 timestamp
}
```

### IterationResult

Result of executing iteration step(s).

```typescript
interface IterationResult {
  V: number[];
  policy: number[];
  iteration: number;
  converged: boolean;
  delta: number;
  max_change: number;
  execution_time_ms?: number;
}
```

### Action Encoding

Actions are represented as integers:

| Action | Index | Symbol | Effect |
|--------|-------|--------|--------|
| Up | 0 | ↑ | row - 1 |
| Down | 1 | ↓ | row + 1 |
| Left | 2 | ← | col - 1 |
| Right | 3 | → | col + 1 |

### State Encoding

States are encoded as flat indices from 2D grid positions:

```
state_index = row * grid_size + col
```

Example for 5×5 grid:
```
 0  1  2  3  4
 5  6  7  8  9
10 11 12 13 14
15 16 17 18 19
20 21 22 23 24
```

---

## Error Handling

### Error Response Format

All errors follow a consistent JSON format:

```json
{
  "detail": "Human-readable error message",
  "error_code": "ERROR_CODE_CONSTANT",
  "timestamp": "2025-11-29T10:32:15.123Z"
}
```

### HTTP Status Codes

| Status Code | Description |
|-------------|-------------|
| 200 | OK - Request successful |
| 201 | Created - New resource created |
| 204 | No Content - Successful deletion |
| 400 | Bad Request - Invalid input parameters |
| 404 | Not Found - Session not found |
| 422 | Unprocessable Entity - Validation error |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server-side error |

### Common Error Codes

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `SESSION_NOT_FOUND` | 404 | Requested session does not exist |
| `VALIDATION_ERROR` | 422 | Input validation failed |
| `GRID_SIZE_INVALID` | 400 | Grid size outside allowed range |
| `GAMMA_INVALID` | 400 | Gamma outside allowed range |
| `ALGORITHM_INVALID` | 400 | Invalid algorithm specified |
| `SESSION_EXPIRED` | 404 | Session has expired (>30min idle) |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Unexpected server error |

### Example Error Responses

**Validation Error (422)**:
```json
{
  "detail": [
    {
      "loc": ["body", "grid_size"],
      "msg": "ensure this value is less than or equal to 20",
      "type": "value_error.number.not_le"
    }
  ]
}
```

**Session Not Found (404)**:
```json
{
  "detail": "Session with ID 550e8400-e29b-41d4-a716-446655440000 not found",
  "error_code": "SESSION_NOT_FOUND",
  "timestamp": "2025-11-29T10:32:15.123Z"
}
```

---

## Rate Limiting

**Current Implementation**: No rate limiting in MVP.

**Planned**: Rate limiting per session and per IP address.

### Future Rate Limits

| Endpoint | Limit |
|----------|-------|
| `POST /api/mdp/initialize` | 10 requests/minute per IP |
| `POST /api/mdp/{id}/step` | 100 requests/minute per session |
| WebSocket connections | 5 concurrent connections per IP |

Rate limit information will be included in response headers:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1638187200
```

---

## API Versioning

**Current**: All endpoints are under `/api/` prefix.

**Future**: Version-specific prefixes like `/api/v1/` and `/api/v2/`.

---

## CORS Configuration

**Development**: Allows all origins.

**Production**: Restricted to specific domains.

```python
# Example CORS configuration
CORS_ORIGINS = [
    "http://localhost:3000",
    "https://yourdomain.com"
]
```

---

## Health Check Endpoints

### API Health

```http
GET /health
```

**Response**:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2025-11-29T10:32:15.123Z"
}
```

### Detailed Health

```http
GET /health/detailed
```

**Response**:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "components": {
    "api": "healthy",
    "sessions": {
      "status": "healthy",
      "active_sessions": 12,
      "total_sessions": 145
    }
  },
  "timestamp": "2025-11-29T10:32:15.123Z"
}
```

---

## OpenAPI Documentation

Interactive API documentation is available at:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

---

## Examples

### Complete Workflow

```bash
# 1. Initialize session
SESSION=$(curl -X POST http://localhost:8000/api/mdp/initialize \
  -H "Content-Type: application/json" \
  -d '{"grid_size": 5, "gamma": 0.9}' \
  | jq -r '.session_id')

echo "Session ID: $SESSION"

# 2. Execute 10 steps
curl -X POST http://localhost:8000/api/mdp/$SESSION/step \
  -H "Content-Type: application/json" \
  -d '{"num_steps": 10}' | jq

# 3. Get current state
curl http://localhost:8000/api/mdp/$SESSION/state | jq

# 4. Update gamma
curl -X PATCH http://localhost:8000/api/mdp/$SESSION/config \
  -H "Content-Type: application/json" \
  -d '{"gamma": 0.95}' | jq

# 5. Reset session
curl -X POST http://localhost:8000/api/mdp/$SESSION/reset | jq

# 6. Delete session
curl -X DELETE http://localhost:8000/api/mdp/$SESSION
```

---

## Performance Benchmarks

Expected response times (measured on modern hardware):

| Operation | Grid Size | Time (ms) |
|-----------|-----------|-----------|
| Initialize | 5×5 | 10-20 |
| Initialize | 10×10 | 30-50 |
| Single step | 5×5 | 1-3 |
| Single step | 10×10 | 5-10 |
| Convergence | 5×5 | 50-100 |
| Convergence | 10×10 | 200-500 |

---

## Client Libraries

### Python Client Example

```python
import requests

class MDPClient:
    def __init__(self, base_url="http://localhost:8000"):
        self.base_url = base_url
        self.session_id = None
    
    def initialize(self, grid_size=5, gamma=0.9, algorithm="value_iteration"):
        response = requests.post(
            f"{self.base_url}/api/mdp/initialize",
            json={
                "grid_size": grid_size,
                "gamma": gamma,
                "algorithm": algorithm
            }
        )
        response.raise_for_status()
        data = response.json()
        self.session_id = data["session_id"]
        return data
    
    def step(self, num_steps=1):
        response = requests.post(
            f"{self.base_url}/api/mdp/{self.session_id}/step",
            json={"num_steps": num_steps}
        )
        response.raise_for_status()
        return response.json()
    
    def get_state(self):
        response = requests.get(
            f"{self.base_url}/api/mdp/{self.session_id}/state"
        )
        response.raise_for_status()
        return response.json()

# Usage
client = MDPClient()
initial_state = client.initialize(grid_size=5, gamma=0.9)
print(f"Initialized session: {client.session_id}")

result = client.step(num_steps=10)
print(f"After 10 steps: iteration={result['iteration']}, delta={result['delta']}")
```

### TypeScript Client Example

```typescript
class MDPClient {
  private baseUrl: string;
  private sessionId: string | null = null;

  constructor(baseUrl: string = 'http://localhost:8000') {
    this.baseUrl = baseUrl;
  }

  async initialize(config: MDPConfig): Promise<MDPState> {
    const response = await fetch(`${this.baseUrl}/api/mdp/initialize`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(config),
    });
    
    if (!response.ok) throw new Error('Failed to initialize');
    
    const data = await response.json();
    this.sessionId = data.session_id;
    return data;
  }

  async step(numSteps: number = 1): Promise<IterationResult> {
    if (!this.sessionId) throw new Error('No active session');
    
    const response = await fetch(
      `${this.baseUrl}/api/mdp/${this.sessionId}/step`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ num_steps: numSteps }),
      }
    );
    
    if (!response.ok) throw new Error('Failed to execute step');
    return response.json();
  }

  async getState(): Promise<MDPState> {
    if (!this.sessionId) throw new Error('No active session');
    
    const response = await fetch(
      `${this.baseUrl}/api/mdp/${this.sessionId}/state`
    );
    
    if (!response.ok) throw new Error('Failed to get state');
    return response.json();
  }
}

// Usage
const client = new MDPClient();
const initialState = await client.initialize({
  grid_size: 5,
  gamma: 0.9,
  algorithm: 'value_iteration'
});
console.log(`Initialized session: ${client.sessionId}`);

const result = await client.step(10);
console.log(`After 10 steps: iteration=${result.iteration}, delta=${result.delta}`);
```

---

## Support & Feedback

For API issues or feature requests:
- GitHub Issues: https://github.com/yourusername/mdp-visualizer/issues
- Documentation: https://yourdomain.com/docs
- Email: support@yourdomain.com
