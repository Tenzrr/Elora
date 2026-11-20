import asyncio
import io
import json
from datetime import datetime
from pathlib import Path
from uuid import UUID, uuid4

import pytest
from fastapi.testclient import TestClient
from jsonschema import Draft202012Validator, FormatChecker
from PIL import Image
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import async_sessionmaker

from app.core.auth import verify_identity
from app.db.models import User
from app.main import create_app
from app.modules.crop_health.models import ScanJob
from app.shared.images import MAX_BYTES
from conftest import signed_in


def picture(fmt="PNG", size=(32, 24)):
    output = io.BytesIO()
    Image.new("RGB", size, "green").save(output, fmt)
    return output.getvalue()


def submit(client, headers, key=None, image=None, **fields):
    return client.post("/api/v1/scans", headers={**headers, "Idempotency-Key": key or str(uuid4())},
                       data={"crop_slug": "tomato", "task": "disease", **fields},
                       files={"image": ("untrusted.jpg", picture() if image is None else image, "image/jpeg")})


def test_durable_failure_contract_and_idempotent_retry(api):
    client, engine, app = api
    alice = signed_in(client)
    key = str(uuid4())
    response = submit(client, alice, key)
    assert response.status_code == 202, response.text
    receipt = response.json()
    assert response.headers["Location"] == receipt["status_url"]
    assert submit(client, alice, key).json() == receipt
    assert submit(client, alice, key, image=picture("JPEG")).status_code == 409
    status = client.get(receipt["status_url"], headers=alice)
    assert status.status_code == 200
    job = status.json()
    assert datetime.fromisoformat(job["created_at"]).tzinfo is not None
    assert job["status"] == "failed" and job["error"]["code"] == "MODEL_UNAVAILABLE"
    assert job["result"] is None and job["image_retained"] is False
    schema = json.loads(Path("shared/schemas/scan_job.json").read_text())
    Draft202012Validator(schema, format_checker=FormatChecker()).validate(job)

    # A new app instance reads the committed job from the same database.
    restarted = create_app(app.state.settings, engine=engine)
    restarted.dependency_overrides[verify_identity] = app.dependency_overrides[verify_identity]
    with TestClient(restarted) as other:
        assert other.get(receipt["status_url"], headers=alice).json() == job
    async def rows():
        async with async_sessionmaker(engine)() as db:
            jobs = list((await db.scalars(select(ScanJob))).all())
            assert len(jobs) == 1 and jobs[0].operation_id == UUID(key)
    asyncio.run(rows())


def test_experimental_preview_requires_verified_user_and_model_configuration(api, monkeypatch):
    client, _, app = api
    alice = signed_in(client)
    fields = {"crop_slug": "tomato", "task": "disease"}
    files = {"image": ("leaf.jpg", picture("JPEG"), "image/jpeg")}
    path = "/api/v1/scans/preview"
    assert client.post(path, data=fields, files=files).status_code == 401
    assert client.post(path, headers=signed_in(client, "unverified"), data=fields, files=files).status_code == 403
    assert client.post(path, headers=alice, data=fields, files=files).status_code == 503
    app.state.settings.tomato_preview_model_path = "test-checkpoint.keras"
    import importlib
    module = importlib.import_module("app.modules.crop_health.router")
    seen = []
    monkeypatch.setattr(module, "predict_leaf", lambda model_path, image: seen.append((model_path, image)) or "healthy")
    response = client.post(path, headers=alice, data=fields, files=files)
    assert response.status_code == 200, response.text
    assert response.json()["label_id"] == "healthy"
    assert "not a confirmed diagnosis" in response.json()["notice"]
    assert seen[0][0] == "test-checkpoint.keras" and seen[0][1].startswith(b"\xff\xd8\xff")
    assert client.post(path, headers=alice, data={**fields, "crop_slug": "citrus"}, files=files).status_code == 422
    app.state.settings.app_env = "production"
    assert client.post(path, headers=alice, data=fields, files=files).status_code == 403


def test_auth_ownership_and_optional_plant(api):
    client, engine, _ = api
    alice, bob = signed_in(client), signed_in(client, "bob")
    assert submit(client, {}).status_code == 401
    unverified = signed_in(client, "unverified")
    assert submit(client, unverified).status_code == 403
    plant = client.post("/api/v1/plants", headers=alice,
                        json={"crop_slug": "tomato", "growing_area": "synthetic"}).json()
    assert submit(client, bob, plant_id=plant["id"]).status_code == 404
    assert submit(client, alice, plant_id=str(uuid4())).status_code == 404
    assert submit(client, alice, crop_slug="citrus", task="quality", subtype="orange",
                  plant_id=plant["id"]).status_code == 422
    key = str(uuid4())
    receipt = submit(client, alice, key, plant_id=plant["id"]).json()
    path = receipt["status_url"]
    assert client.get(path, headers=bob).status_code == 404
    assert client.get(path).status_code == 401
    assert client.get(path, headers=unverified).status_code == 403
    assert client.get("/api/v1/scans/" + str(uuid4()), headers=alice).status_code == 404
    assert submit(client, bob, key).status_code == 202  # Keys are scoped to each account.
    assert client.delete("/api/v1/plants/" + plant["id"], headers={**alice, "If-Match": '"1"'}).status_code == 204
    async def disable():
        async with async_sessionmaker(engine)() as db:
            await db.execute(update(User).where(User.firebase_uid == "alice").values(active=False))
            await db.commit()
    asyncio.run(disable())
    assert submit(client, alice).status_code == 403
    assert client.get(path, headers=alice).status_code == 403


@pytest.mark.parametrize("fields,code", [
    ({"crop_slug": "citrus", "task": "quality"}, "INVALID_SUBTYPE"),
    ({"crop_slug": "citrus", "task": "quality", "subtype": "lime"}, "INVALID_SUBTYPE"),
    ({"subtype": "leaf"}, "INVALID_SUBTYPE"),
    ({"crop_slug": "chilli"}, "UNSUPPORTED_SCAN"),
    ({"task": "invented"}, "INVALID_INPUT"),
    ({"plant_id": "bad"}, "INVALID_INPUT"),
    ({"user_id": "bob"}, "INVALID_INPUT"),
])
def test_selection_validation(api, fields, code):
    client, _, _ = api
    response = submit(client, signed_in(client), **fields)
    assert response.status_code == 422 and response.json()["error"]["code"] == code


@pytest.mark.parametrize("fmt", ["JPEG", "PNG", "WEBP"])
def test_supported_formats_and_citrus_handoff(api, fmt):
    client, _, _ = api
    alice = signed_in(client)
    for subtype in ["orange", "lemon"]:
        result = submit(client, alice, image=picture(fmt), crop_slug="citrus", task="quality", subtype=subtype)
        assert result.status_code == 202
        job = client.get(result.json()["status_url"], headers=alice).json()
        assert job["subtype"] == subtype and job["result"] is None


@pytest.mark.parametrize("data,status", [
    (b"", 422), (b"fake", 415), (b"\xff\xd8\xffbroken", 422),
    (b"x" * (MAX_BYTES + 1), 413), (b"x" * (MAX_BYTES + 65537), 413),
])
def test_image_limits_and_content(api, data, status):
    client, _, _ = api
    response = submit(client, signed_in(client), image=data)
    assert response.status_code == status
    assert "X-Request-ID" in response.headers


def test_dimensions_animation_missing_fields_and_duplicate_fields(api):
    client, _, _ = api
    alice = signed_in(client)
    assert submit(client, alice, image=picture(size=(5000, 4001))).status_code == 422
    output = io.BytesIO()
    Image.new("RGB", (4, 4), "red").save(output, "PNG", save_all=True,
                                          append_images=[Image.new("RGB", (4, 4), "blue")])
    assert submit(client, alice, image=output.getvalue()).status_code == 422
    headers = {**alice, "Idempotency-Key": str(uuid4())}
    assert client.post("/api/v1/scans", headers=headers, data={"task": "disease"}).status_code == 415
    assert client.post("/api/v1/scans", headers=headers, files={"image": ("a.png", picture())}).status_code == 422
    assert client.post("/api/v1/scans", headers=alice, data={"crop_slug": "tomato", "task": "disease"},
                       files={"image": ("a.png", picture())}).status_code == 422
    assert client.post("/api/v1/scans", headers=headers,
                       data={"crop_slug": ["tomato", "citrus"], "task": "disease"},
                       files={"image": ("a.png", picture())}).status_code == 422
    assert client.post("/api/v1/scans", headers={**alice, "Idempotency-Key": "bad"},
                       data={"crop_slug": "tomato", "task": "disease"},
                       files={"image": ("a.png", picture())}).status_code == 422


def test_chunked_body_cannot_bypass_upload_limit(api):
    client, _, _ = api
    headers = {**signed_in(client), "Idempotency-Key": str(uuid4()),
               "Content-Type": "multipart/form-data; boundary=test"}
    response = client.post("/api/v1/scans", headers=headers,
                           content=iter([b"x" * (MAX_BYTES + 64 * 1024 + 1)]))
    assert response.status_code == 413
