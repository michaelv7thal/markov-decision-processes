from fastapi.routing import APIRouter

router = APIRouter()


@router.get("/health")
def health_check():
    return {"status": "healthy"}
