import numpy as np


class GridWorld:
    def __init__(self, grid_size: int = 5) -> None:
        self.size = grid_size
        self.num_states = grid_size * grid_size
        self.num_actions = 4

        # Special states A and B (from Sutton & Barto Example 3.5)
        self.special_A = (0, 1)
        self.special_A_prime = (4, 1)
        self.special_B = (0, 3)
        self.special_B_prime = (2, 3)

        # Actions: 0=up, 1=down, 2=left, 3=right
        self.actions = ["up", "down", "left", "right"]
        self.action_effects = [(-1, 0), (1, 0), (0, -1), (0, 1)]

    def pos_to_state(self, row: int, col: int) -> int:
        """Convert (row, col) position to state index."""
        return row * self.size + col

    def state_to_pos(self, state: int) -> tuple[int, int]:
        """Convert state index to (row, col) position."""
        return (state // self.size, state % self.size)

    def get_next_state_and_reward(self, state: int, action: int) -> tuple[int, float]:
        """Return next state and reward given current state and action."""
        pos = self.state_to_pos(state)

        # Special state A
        if pos == self.special_A:
            return self.pos_to_state(*self.special_A_prime), 10.0

        # Special state B
        if pos == self.special_B:
            return self.pos_to_state(*self.special_B_prime), 5.0

        # Normal transitions
        row, col = pos
        drow, dcol = self.action_effects[action]
        new_row, new_col = row + drow, col + dcol

        # Check boundaries
        if new_row < 0 or new_row >= self.size or new_col < 0 or new_col >= self.size:
            # Hit wall stays in same state with -1 reward
            return state, -1.0

        # Valid move- reward 0
        return self.pos_to_state(new_row, new_col), 0.0

    def build_transition_and_reward_matrices(self) -> tuple[np.ndarray, np.ndarray]:
        P = np.zeros((self.num_states, self.num_actions, self.num_states))
        R = np.zeros((self.num_states, self.num_actions))

        for s in range(self.num_states):
            for a in range(self.num_actions):
                next_state, reward = self.get_next_state_and_reward(s, a)
                P[s, a, next_state] = 1.0  # Deterministic transition
                R[s, a] = reward

        return P, R

    # Fixed-point iteration for value iteration
    # V(x) = max_{a} [ r(x,a) + \gamma \sum_{x'} P(x'|x,a) V(x') ]
    def fixed_point_iteration(
        self,
        transition_probs: np.ndarray,
        rewards: np.ndarray,
        gamma: float,
        theta: float = 1e-6,
    ) -> np.ndarray:
        num_states, num_actions = rewards.shape
        V = np.zeros(num_states)

        while True:
            delta = 0
            for s in range(num_states):
                v = V[s]
                Q_s = np.zeros(num_actions)
                for a in range(num_actions):
                    # r(x,\pi(x)) + \gamma \sum_{x'} P(x'|x,\pi(x)) V(x')
                    Q_s[a] = rewards[s, a] + gamma * np.sum(transition_probs[s, a] * V)
                V[s] = np.max(Q_s)
                delta = max(delta, abs(v - V[s]))
            if delta < theta:
                break
        return V

    # Extract optimal policy from value iteration
    def extract_policy(
        self,
        transition_probs: np.ndarray,
        rewards: np.ndarray,
        V: np.ndarray,
        gamma: float,
    ) -> np.ndarray:
        num_states, num_actions = rewards.shape
        policy = np.zeros(num_states, dtype=int)

        for s in range(num_states):
            Q_s = np.zeros(num_actions)
            for a in range(num_actions):
                Q_s[a] = rewards[s, a] + gamma * np.sum(transition_probs[s, a] * V)
            policy[s] = np.argmax(Q_s)

        return policy

    # Bellman equation in matrix form
    # V^{\pi} = (I-\gamma P^{\pi})^{-1} R^{\pi}
    def exact_evaluation(
        self,
        transition_probs: np.ndarray,
        policy: np.ndarray,
        rewards: np.ndarray,
        gamma: float,
    ) -> np.ndarray:
        num_states = len(policy)

        P_pi = np.zeros((num_states, num_states))
        R_pi = np.zeros(num_states)

        for s in range(num_states):
            a = policy[s]
            P_pi[s] = transition_probs[s, a]
            R_pi[s] = rewards[s, a]

        V_pi = np.linalg.inv(np.eye(num_states) - gamma * P_pi) @ R_pi
        return V_pi