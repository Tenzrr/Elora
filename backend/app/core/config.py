import re
from functools import lru_cache

from pydantic import SecretStr, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")
    app_env: str = "development"
    database_url: SecretStr | None = None
    database_schema: str = "integration"
    database_require_tls: bool = True
    database_ca_file: str | None = None
    firebase_project_id: str = ""
    google_application_credentials: str | None = None

    @model_validator(mode="after")
    def validate_workspace(self):
        if not re.fullmatch(r"integration|dev[1-5]", self.database_schema):
            raise ValueError("Use integration or dev1–dev5 as DATABASE_SCHEMA")
        if not self.database_require_tls and self.app_env != "test":
            raise ValueError("Unencrypted database connections are allowed only in tests")
        if self.database_url and not self.database_url.get_secret_value().startswith("postgresql+asyncpg://"):
            raise ValueError("DATABASE_URL must use postgresql+asyncpg")
        return self


@lru_cache
def get_settings() -> Settings:
    return Settings()
