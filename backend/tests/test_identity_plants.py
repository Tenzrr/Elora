import asyncio

from fastapi import Depends
from sqlalchemy import update

from app.core.auth import verified_actor
from app.db.models import User
from sqlalchemy.ext.asyncio import async_sessionmaker
from conftest import signed_in


def test_identity_is_idempotent_and_never_merges_matching_claims(api):
    client, _, _ = api
    alice = signed_in(client)
    first = client.get("/api/v1/profile", headers=alice).json()
    assert client.post("/api/v1/session", headers=alice).json()["id"] == first["id"]
    bob = signed_in(client, "bob")
    assert client.get("/api/v1/profile", headers=bob).json()["id"] != first["id"]
    response = client.patch("/api/v1/profile", headers=alice,
                            json={"language": "ta", "interests": ["tomato", "tomato"]})
    assert response.json()["interests"] == ["tomato"]
    assert response.json()["language"] == "ta"
    assert client.patch("/api/v1/profile", headers=alice, json={"firebase_uid": "bob"}).status_code == 422
    assert client.patch("/api/v1/profile", headers=alice, json={"language": None}).status_code == 422


def test_ownership_pagination_and_atomic_revisions(api):
    client, _, _ = api
    alice = signed_in(client)
    bob = signed_in(client, "bob")
    def make():
        r = client.post("/api/v1/plants", headers=alice,
                        json={"crop_slug": "tomato", "growing_area": "Colombo balcony"})
        assert r.status_code == 201, r.text
        return r.json()
    plant = make()
    make()
    path = "/api/v1/plants/" + plant["id"]
    assert client.get(path, headers=bob).status_code == 404
    assert client.patch(path, headers=bob, json={"nickname": "stolen"},
                        **{}).status_code == 404
    assert client.delete(path, headers=bob).status_code == 404
    page = client.get("/api/v1/plants?limit=1", headers=alice).json()
    assert len(page["items"]) == 1
    second = client.get("/api/v1/plants?limit=1&cursor=" + page["next_cursor"], headers=alice).json()
    assert page["items"][0]["id"] != second["items"][0]["id"]
    assert client.get("/api/v1/plants", headers=bob).json()["items"] == []
    etag = client.get(path, headers=alice).headers["ETag"]
    assert client.patch(path, headers=alice, json={"nickname": "new"}).status_code == 428
    updated = client.patch(path, headers={**alice, "If-Match": etag}, json={"nickname": "new"})
    assert updated.status_code == 200, updated.text
    assert updated.json()["revision"] == 2
    assert client.patch(path, headers={**alice, "If-Match": etag}, json={"nickname": "lost"}).status_code == 409
    assert client.delete(path, headers={**alice, "If-Match": etag}).status_code == 409
    assert client.get(path, headers=alice).json()["nickname"] == "new"
    assert client.delete(path, headers={**alice, "If-Match": '"2"'}).status_code == 204
    assert client.get(path, headers=alice).status_code == 404


def test_validation_and_email_gate(api):
    client, _, app = api
    alice = signed_in(client)
    assert client.post("/api/v1/plants", headers=alice, json={"crop_slug": "unknown"}).status_code == 422
    response = client.post("/api/v1/plants", headers=alice,
                           json={"crop_slug": "tomato", "growing_area": "  "})
    assert response.status_code == 422
    assert "input" not in str(response.json())
    @app.get("/test-verified", dependencies=[Depends(verified_actor, scope="function")])
    def restricted():
        return {"ok": True}
    unverified = signed_in(client, "unverified")
    assert client.get("/test-verified", headers=unverified).status_code == 403
    assert client.get("/test-verified", headers=alice).status_code == 200


def test_inactive_account_cannot_be_reactivated_by_session(api):
    client, engine, _ = api
    headers = signed_in(client)
    async def disable():
        async with async_sessionmaker(engine)() as db:
            await db.execute(update(User).where(User.firebase_uid == "alice").values(active=False))
            await db.commit()
    asyncio.run(disable())
    assert client.post("/api/v1/session", headers=headers).status_code == 403
    assert client.get("/api/v1/profile", headers=headers).status_code == 403
