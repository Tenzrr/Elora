"""Run in CI against disposable PostgreSQL; no developer database is required."""
import asyncio
import json
import os
import subprocess
import sys
import io
from concurrent.futures import ThreadPoolExecutor
from uuid import uuid4

import pytest
from sqlalchemy import text
from PIL import Image

pytestmark = pytest.mark.skipif(not os.environ.get("TEST_DATABASE_URL"), reason="PostgreSQL integration runs in CI")


def test_migrations_and_database_role_isolation(tmp_path):
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
        image = io.BytesIO()
        Image.new("RGB", (32, 24), "green").save(image, "PNG")
        key = str(uuid4())
        def upload():
            return client.post("/api/v1/scans", headers={"Idempotency-Key": key},
                               data={"crop_slug": "tomato", "task": "disease", "plant_id": response.json()["id"]},
                               files={"image": ("synthetic.png", image.getvalue(), "image/png")})
        with ThreadPoolExecutor(max_workers=2) as threads:
            replies = list(threads.map(lambda _: upload(), range(2)))
        assert [r.status_code for r in replies] == [202, 202], [r.text for r in replies]
        assert replies[0].json() == replies[1].json()
        status_url = replies[0].json()["status_url"]
        assert client.get(status_url).json()["error"]["code"] == "MODEL_UNAVAILABLE"
        assert client.delete("/api/v1/plants/" + response.json()["id"],
                             headers={"If-Match": '"1"'}).status_code == 204
        assert client.get(status_url).json()["plant_id"] is None
    asyncio.run(engine.dispose())

    restarted = create_app(settings)
    restarted.dependency_overrides[verify_identity] = identity
    with TestClient(restarted) as client:
        assert client.get(status_url).json()["status"] == "failed"

    async def isolation():
        engine = make_engine(settings)
        try:
            async with engine.connect() as conn:
                with pytest.raises(Exception) as error:
                    await conn.execute(text("SELECT * FROM dev2.users"))
                assert "permission denied" in str(error.value).lower()
                await conn.rollback()
                assert not await conn.scalar(text(
                    "SELECT has_table_privilege('dev1.alembic_version', 'UPDATE')"
                ))
                with pytest.raises(Exception) as error:
                    await conn.execute(text("SELECT * FROM dev2.scan_jobs"))
                assert "permission denied" in str(error.value).lower()
        finally:
            await engine.dispose()
    asyncio.run(isolation())
