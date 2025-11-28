import numpy as np


## Input MDP Definition for toy example
# gamma parameter
gamma = 0.9

# states
x = np.arange(4)

# actions
a = np.arange(2)

# randomly generated transition probabilities
transition_probs = np.random.dirichlet(np.ones(len(x)), size=(len(x), len(a)))

# randomly generated rewards
rewards = np.random.rand(len(x), len(a))

# Fixed-point iteration for value iteration
# V(x) = max_{a} [ r(x,a) + \gamma \sum_{x'} P(x'|x,a) V(x') ]
def fixed_point_iteration(
    transition_probs: np.ndarray, rewards: np.ndarray, gamma: float, theta: float = 1e-6
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
    transition_probs: np.ndarray, rewards: np.ndarray, V: np.ndarray, gamma: float
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
    transition_probs: np.ndarray, policy: np.ndarray, rewards: np.ndarray, gamma: float
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


if __name__ == "__main__":
    V = fixed_point_iteration(transition_probs, rewards, gamma)
    print("Optimal State Values:", V)
    optimal_policy = extract_policy(transition_probs, rewards, V, gamma)
    print("Optimal Policy:", optimal_policy)    
    V_pi = exact_evaluation(transition_probs, optimal_policy, rewards, gamma)
    print("Policy Evaluation State Values:", V_pi)
    print("\nValues match:", np.allclose(V, V_pi))