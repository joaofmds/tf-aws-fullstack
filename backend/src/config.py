from functools import lru_cache
from typing import List

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=None, extra="ignore")

    database_host: str = Field(..., alias="DATABASE_HOST")
    database_user: str = Field(..., alias="DATABASE_USER")
    database_pass: str = Field(..., alias="DATABASE_PASS")
    database_dbname: str = Field(..., alias="DATABASE_DBNAME")
    database_port: int = Field(default=5432, alias="DATABASE_PORT")

    upload_dir: str = Field(default="uploads", alias="UPLOAD_DIR")
    upload_s3_bucket: str | None = Field(default=None, alias="UPLOAD_S3_BUCKET")
    upload_max_mb: int = Field(default=10, alias="UPLOAD_MAX_MB")

    cors_origins: str = Field(default="http://localhost:8080,http://localhost", alias="CORS_ORIGINS")
    app_workers: int = Field(default=2, alias="APP_WORKERS")

    @property
    def database_url(self) -> str:
        return (
            f"postgresql://{self.database_user}:{self.database_pass}"
            f"@{self.database_host}:{self.database_port}/{self.database_dbname}"
        )

    @property
    def cors_origin_list(self) -> List[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
