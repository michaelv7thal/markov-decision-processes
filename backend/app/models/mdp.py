from pydantic import BaseModel, Field

class GridWorldConfig(BaseModel):
    """Configuration for GridWorld environment."""
    grid_size: int = Field(default=5, ge=3, le=10, description="Size of the grid")
    gamma: float = Field(default=0.9, ge=0, le=1, description="Discount factor")
    theta: float = Field(default=1e-6, gt=0, description="Convergence threshold")

class GridWorldResponse(BaseModel):
    """Response containing GridWorld solution."""
    values: list[list[float]] = Field(description="State values in grid format")
    policy: list[list[str]] = Field(description="Optimal policy actions in grid format")
    grid_size: int
    gamma: float
    iterations: int | None = None