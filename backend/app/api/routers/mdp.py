from fastapi import APIRouter, HTTPException
from app.models.mdp import GridWorldConfig, GridWorldResponse
from app.services.mdp_service import MDPService

router = APIRouter(prefix="/mdp", tags=["mdp"])

@router.post("/gridworld/solve", response_model=GridWorldResponse)
async def solve_gridworld(config: GridWorldConfig):
    """Endpoint to solve the GridWorld MDP using Value Iteration."""
    try:
        result = MDPService.solve_gridworld(
            grid_size=config.grid_size,
            gamma=config.gamma,
            theta=config.theta
        )
        return GridWorldResponse(
            values=result["values"],
            policy=result["policy"],
            grid_size=result["grid_size"],
            gamma=result["gamma"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))