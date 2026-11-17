from uuid import uuid4

from conftest import signed_in


def test_chat_authenticated_success(api):
    client, _, _ = api
    headers = signed_in(client, "alice")
    response = client.post(
        "/api/v1/agricultural-agent/chat",
        headers=headers,
        json={"message": "What are optimal irrigation practices for home gardening?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert "thread_id" in data
    assert "soil moisture" in data["response"]
    assert isinstance(data["tools_executed"], list)
    assert "created_at" in data


def test_chat_unauthenticated(api):
    client, _, _ = api
    response = client.post(
        "/api/v1/agricultural-agent/chat",
        json={"message": "Hello agronomist"},
    )
    assert response.status_code == 401


def test_chat_invalid_payload(api):
    client, _, _ = api
    headers = signed_in(client, "alice")
    response = client.post(
        "/api/v1/agricultural-agent/chat",
        headers=headers,
        json={"plant_id": str(uuid4())},
    )
    assert response.status_code == 422


def test_chat_with_existing_thread(api):
    client, _, _ = api
    headers = signed_in(client, "alice")
    thread_id = str(uuid4())
    response = client.post(
        "/api/v1/agricultural-agent/chat",
        headers=headers,
        json={"thread_id": thread_id, "message": "Continuing prior consultation."},
    )
    assert response.status_code == 200
    assert response.json()["thread_id"] == thread_id
