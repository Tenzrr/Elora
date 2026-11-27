from fastapi import Request
from fastapi.testclient import TestClient

from app.core.auth import verify_identity
from app.core.config import Settings
from app.core.errors import fail
from app.main import create_app
from conftest import signed_in


def test_create_post_uses_server_identity_and_is_private(api):
    client, _, _ = api

    alice = signed_in(client, "alice")
    bob = signed_in(client, "bob")

    alice_id = client.get("/api/v1/profile", headers=alice).json()["id"]

    response = client.post(
        "/api/v1/community/posts",
        headers=alice,
        json={"text": "My tomato plants are growing well."},
    )

    assert response.status_code == 201, response.text
    post = response.json()

    assert post["user_id"] == alice_id
    assert post["text"] == "My tomato plants are growing well."
    assert post["published_at"] is None

    alice_posts = client.get(
        "/api/v1/community/posts", headers=alice
    ).json()

    bob_posts = client.get(
        "/api/v1/community/posts", headers=bob
    ).json()

    assert len(alice_posts["items"]) == 1
    assert alice_posts["items"][0]["id"] == post["id"]
    assert bob_posts["items"] == []


def test_client_cannot_spoof_post_owner(api):
    client, _, _ = api

    alice = signed_in(client, "alice")
    bob = signed_in(client, "bob")
    bob_id = client.get("/api/v1/profile", headers=bob).json()["id"]

    response = client.post(
        "/api/v1/community/posts",
        headers=alice,
        json={
            "text": "Attempted identity spoof.",
            "user_id": bob_id,
        },
    )

    assert response.status_code == 422, response.text


def test_post_validation_and_verified_email(api):
    client, _, _ = api

    alice = signed_in(client, "alice")
    unverified = signed_in(client, "unverified")

    empty = client.post(
        "/api/v1/community/posts",
        headers=alice,
        json={"text": "   "},
    )
    assert empty.status_code == 422

    too_long = client.post(
        "/api/v1/community/posts",
        headers=alice,
        json={"text": "x" * 2001},
    )
    assert too_long.status_code == 422

    blocked = client.post(
        "/api/v1/community/posts",
        headers=unverified,
        json={"text": "Unverified user post."},
    )
    assert blocked.status_code == 403


def test_post_pagination_is_stable(api):
    client, _, _ = api
    alice = signed_in(client, "alice")

    for number in range(3):
        response = client.post(
            "/api/v1/community/posts",
            headers=alice,
            json={"text": f"Community test post {number}"},
        )
        assert response.status_code == 201, response.text

    first = client.get(
        "/api/v1/community/posts?limit=2",
        headers=alice,
    )
    assert first.status_code == 200, first.text

    first_page = first.json()
    assert len(first_page["items"]) == 2
    assert first_page["next_cursor"] is not None

    second = client.get(
        "/api/v1/community/posts",
        params={"limit": 2, "cursor": first_page["next_cursor"]},
        headers=alice,
    )
    assert second.status_code == 200, second.text

    second_page = second.json()
    assert len(second_page["items"]) == 1
    assert second_page["next_cursor"] is None

    ids = [
        item["id"]
        for item in first_page["items"] + second_page["items"]
    ]
    assert len(ids) == len(set(ids))


def test_post_survives_application_restart(api):
    client, engine, _ = api
    alice = signed_in(client, "alice")

    created = client.post(
        "/api/v1/community/posts",
        headers=alice,
        json={"text": "This post must survive an API restart."},
    )
    assert created.status_code == 201, created.text
    post_id = created.json()["id"]

    restarted_app = create_app(
        Settings(_env_file=None, app_env="test"),
        engine=engine,
    )

    async def test_identity(request: Request):
        token = request.headers.get(
            "Authorization", ""
        ).removeprefix("Bearer ")

        if token not in {"alice", "bob", "unverified"}:
            fail(401, "UNAUTHORIZED", "Invalid test session.")

        return {
            "uid": token,
            "email": token + "@example.test",
            "email_verified": token != "unverified",
        }

    restarted_app.dependency_overrides[verify_identity] = test_identity

    with TestClient(restarted_app) as restarted_client:
        restarted_alice = signed_in(restarted_client, "alice")

        page = restarted_client.get(
            "/api/v1/community/posts",
            headers=restarted_alice,
        )

        assert page.status_code == 200, page.text
        assert any(
            post["id"] == post_id
            for post in page.json()["items"]
        )
