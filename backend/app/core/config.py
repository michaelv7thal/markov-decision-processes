from functools import lru_cache
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from .env file."""

    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", case_sensitive=False, extra="ignore"
    )

    # Environment
    environment: str = Field(default="development", alias="ENVIRONMENT")
    debug: bool = Field(default=False, alias="DEBUG")
    log_level: str = Field(default="INFO", alias="LOG_LEVEL")

    # API Configuration
    api_host: str = Field(default="0.0.0.0", alias="API_HOST")
    api_port: int = Field(default=8000, alias="API_PORT")
    api_reload: bool = Field(default=False, alias="API_RELOAD")

    # API Metadata
    api_title: str = Field(default="MDP Solver API", alias="API_TITLE")
    api_version: str = Field(default="0.1.0", alias="API_VERSION")
    api_description: str = Field(
        default="API for solving Markov Decision Processes", alias="API_DESCRIPTION"
    )

    # CORS Configuration
    allowed_origins: list[str] = Field(default=["http://localhost:3000"], alias="ALLOWED_ORIGINS")

    # WebSocket Configuration
    ws_heartbeat_interval: int = Field(default=30, alias="WS_HEARTBEAT_INTERVAL")
    ws_max_connections: int = Field(default=100, alias="WS_MAX_CONNECTIONS")

    @property
    def cors_origins(self) -> list[str]:
        """Parse CORS origins from comma-separated string if needed."""
        if isinstance(self.allowed_origins, str):
            return [origin.strip() for origin in self.allowed_origins.split(",")]
        return self.allowed_origins


@lru_cache
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()
