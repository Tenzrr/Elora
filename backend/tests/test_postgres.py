"""Run in CI against disposable PostgreSQL; no developer database is required."""
import asyncio
import json
import os
from pathlib import Path
import subprocess
import sys

import pytest
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

pytestmark = pytest.mark.skipif(not os.environ.get("TEST_DATABASE_URL"), reason="PostgreSQL integration runs in CI")


def test_migrations_and_database_role_isolation(tmp_path, monkeypatch):
    from app.core.config import Settings
    from app.db.session import make_engine
    from app.main import create_app
    from app.core.auth import verify_identity
    from fastapi.testclient import TestClient

    admin_url = os.environ["TEST_DATABASE_URL"]
    env = {**os.environ, "DATABASE_ADMIN_URL": admin_url, "DATABASE_URL": admin_url,
           "APP_ENV": "test", "DATABASE_REQUIRE_TLS": "false"}
    files = {}
    for schema in ["dev1", "dev2"]:
        output = tmp_path / (schema + ".json")
        subprocess.run([sys.executable, "backend/tools/workspace.py", "create", schema,
                        "--output", str(output)], env=env, check=True)
        subprocess.run([sys.executable, "-m", "alembic", "-c", "backend/alembic.ini", "upgrade", "head"],
                       env={**env, "DATABASE_SCHEMA": schema}, check=True)
        files[schema] = json.loads(output.read_text())
    settings = Settings(_env_file=None, app_env="test", database_url=files["dev1"]["DATABASE_URL"],
                        database_schema="dev1", database_require_tls=False)
    engine = make_engine(settings)
    app = create_app(settings, engine=engine)
    async def identity():
        return {"uid": "postgres-test", "email_verified": True}
    app.dependency_overrides[verify_identity] = identity
    with TestClient(app) as client:
        assert client.post("/api/v1/session").status_code == 200
        response = client.post("/api/v1/plants", json={"crop_slug": "tomato", "growing_area": "test"})
        assert response.status_code == 201, response.text
        assert client.get("/api/v1/plants").json()["items"][0]["id"] == response.json()["id"]
    asyncio.run(engine.dispose())

    async def isolation():
        engine = make_engine(settings)
        try:
            async with engine.connect() as conn:
                with pytest.raises(Exception) as error:
                    await conn.execute(text("SELECT * FROM dev2.users"))
                assert "permission denied" in str(error.value).lower()
        finally:
            await engine.dispose()
    asyncio.run(isolation())
