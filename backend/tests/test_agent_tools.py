from uuid import uuid4

from conftest import signed_in


def test_agent_plant_lookup_happy_path(api):
    client, _, _ = api
    alice = signed_in(client, "alice")

    plant_resp = client.post(
        "/api/v1/plants",
        headers=alice,
        json={"crop_slug": "tomato", "growing_area": "Colombo terrace"},
    )
    assert plant_resp.status_code == 201
    plant_data = plant_resp.json()
    plant_id = plant_data["id"]

    chat_resp = client.post(
        "/api/v1/agricultural-agent/chat",
        headers=alice,
        json={
            "message": "What is the best care routine for my crop?",
            "plant_id": plant_id,
        },
    )
    assert chat_resp.status_code == 200
    body = chat_resp.json()
    assert "Context for your tomato in Colombo terrace" in body["response"]
    assert len(body["tools_executed"]) == 1
    tool_meta = body["tools_executed"][0]
    assert tool_meta["name"] == "lookup_user_plants"
    assert tool_meta["duration_ms"] >= 0


def test_agent_plant_lookup_cross_user_isolation(api):
    client, _, _ = api
    alice = signed_in(client, "alice")
    bob = signed_in(client, "bob")

    plant_resp = client.post(
        "/api/v1/plants",
        headers=alice,
        json={"crop_slug": "chilli", "growing_area": "Alice private yard"},
    )
    assert plant_resp.status_code == 201
    alice_plant_id = plant_resp.json()["id"]

    chat_resp = client.post(
        "/api/v1/agricultural-agent/chat",
        headers=bob,
        json={
            "message": "Inspect this plant",
            "plant_id": alice_plant_id,
        },
    )
    assert chat_resp.status_code == 200
    body = chat_resp.json()
    assert "Requested plant was not found in your garden" in body["response"]
    assert "Alice private yard" not in body["response"]
    assert len(body["tools_executed"]) == 1
    assert body["tools_executed"][0]["name"] == "lookup_user_plants"


def test_agent_plant_lookup_nonexistent_plant(api):
    client, _, _ = api
    alice = signed_in(client, "alice")
    missing_id = str(uuid4())

    chat_resp = client.post(
        "/api/v1/agricultural-agent/chat",
        headers=alice,
        json={
            "message": "Inspect plant",
            "plant_id": missing_id,
        },
    )
    assert chat_resp.status_code == 200
    body = chat_resp.json()
    assert "Requested plant was not found in your garden" in body["response"]
    assert len(body["tools_executed"]) == 1
    assert body["tools_executed"][0]["name"] == "lookup_user_plants"
