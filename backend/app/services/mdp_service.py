import numpy as np
from app.services.gridworld import GridWorld

class MDPService:

    @staticmethod
    def solve_gridworld(grid_size: int = 5, gamma: float = 0.9, theta: float = 1e-6) -> dict:
        """Solve the GridWorld MDP using Value Iteration."""
        mdp = GridWorld(grid_size)
        P, R = mdp.build_transition_and_reward_matrices()
        V = mdp.fixed_point_iteration(P, R, gamma, theta)

        policy = mdp.extract_policy(P, R, V, gamma)

        values_grid = V.reshape(grid_size, grid_size).tolist()
        policy_grid = []

        for i in range(grid_size):
            row = []
            for j in range(grid_size):
                state = i * grid_size + j
                action_idx = policy[state]
                row.append(mdp.actions[action_idx])
            policy_grid.append(row)
        
        return {
            "values": values_grid,
            "policy": policy_grid,
            "grid_size": grid_size,
            "gamma": gamma,
        }