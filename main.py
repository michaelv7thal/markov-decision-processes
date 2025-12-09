from src.grid_world import GridWorld
from src.grid_world_visualizer import GridWorldIterativeVisualizer


if __name__ == "__main__":
    env = GridWorld(grid_size=8)
    viz = GridWorldIterativeVisualizer(env, gamma=0.9, algorithm='value_iteration')
    viz.show()