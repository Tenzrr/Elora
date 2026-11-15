import asyncio

import pytest
from fastapi import Request
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import create_async_engine

from app.core.auth import verify_identity
from app.core.config import Settings
from app.core.errors import fail
from app.db.models import Base
from app.main import create_app


@pytest.fixture
def api(tmp_path):
    engine = create_async_engine(
        f"sqlite+aiosqlite:///{tmp_path / 'test.db'}",
        execution_options={"schema_translate_map": {"app": None}},
    )

    async def setup():
        async with engine.begin() as connection:
            await connection.run_sync(Base.metadata.create_all)
    asyncio.run(setup())
    app = create_app(Settings(_env_file=None, app_env="test"), engine=engine)

    async def identity(request: Request):
        token = request.headers.get("Authorization", "").removeprefix("Bearer ")
        if token not in {"alice", "bob", "unverified"}:
            fail(401, "UNAUTHORIZED", "Invalid test session.")
        return {"uid": token, "email": token + "@example.test", "email_verified": token != "unverified"}

    app.dependency_overrides[verify_identity] = identity
    with TestClient(app) as client:
        yield client, engine, app
    asyncio.run(engine.dispose())


def signed_in(client, name="alice"):
    headers = {"Authorization": "Bearer " + name}
    assert client.post("/api/v1/session", headers=headers).status_code == 200
    return headers
