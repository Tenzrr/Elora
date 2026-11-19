from datetime import datetime, timezone
import pytest

from tests.conftest import signed_in


def test_create_and_list_care_task(api):
    """REQ-3.5: Create plant care task under ownership checks and list it."""
    client, _, _ = api
    headers = signed_in(client, "alice")

    # 1. Create an owned plant first
    plant_resp = client.post(
        "/api/v1/plants",
        headers=headers,
        json={
            "crop_slug": "tomato",
            "growing_area": "Backyard Garden Plot 1",
            "nickname": "Roma Tomato 1",
        },
    )
    assert plant_resp.status_code == 201
    plant_id = plant_resp.json()["id"]

    # 2. Create a care task linked to the plant
    due_time = datetime(2026, 11, 20, 7, 0, tzinfo=timezone.utc).isoformat()
    task_resp = client.post(
        "/api/v1/farming/tasks",
        headers=headers,
        json={
            "plant_id": plant_id,
            "task_type": "watering",
            "title": "Morning Irrigation",
            "description": "Apply 500ml water following weather check",
            "due_date": due_time,
            "advisory_rationale": "Forecast shows rain < 5.0mm (Normal watering)",
        },
    )
    assert task_resp.status_code == 201
    task_data = task_resp.json()
    assert task_data["title"] == "Morning Irrigation"
    assert task_data["status"] == "pending"
    assert task_data["plant_id"] == plant_id
    assert task_data["advisory_rationale"] == "Forecast shows rain < 5.0mm (Normal watering)"
    task_id = task_data["id"]

    # 3. List care tasks
    list_resp = client.get(f"/api/v1/farming/tasks?plant_id={plant_id}", headers=headers)
    assert list_resp.status_code == 200
    items = list_resp.json()
    assert len(items) == 1
    assert items[0]["id"] == task_id


def test_create_care_task_rejects_unowned_plant(api):
    """REQ-3.5: Attempting to link task to another user's plant is rejected with 404."""
    client, _, _ = api
    alice_headers = signed_in(client, "alice")
    bob_headers = signed_in(client, "bob")

    # Alice creates a plant
    plant_resp = client.post(
        "/api/v1/plants",
        headers=alice_headers,
        json={
            "crop_slug": "chilli",
            "growing_area": "Balcony Pot",
        },
    )
    alice_plant_id = plant_resp.json()["id"]

    # Bob tries to schedule a task on Alice's plant
    bob_resp = client.post(
        "/api/v1/farming/tasks",
        headers=bob_headers,
        json={
            "plant_id": alice_plant_id,
            "task_type": "watering",
            "title": "Unauthorized task",
            "due_date": datetime.now(timezone.utc).isoformat(),
        },
    )
    assert bob_resp.status_code == 404


def test_complete_care_task_creates_care_log_and_is_idempotent(api):
    """REQ-3.5 & SAFE-5: Completing task logs actual care separately and is idempotent."""
    client, _, _ = api
    headers = signed_in(client, "alice")

    # Create task
    task_resp = client.post(
        "/api/v1/farming/tasks",
        headers=headers,
        json={
            "task_type": "watering",
            "title": "Evening Watering",
            "due_date": datetime.now(timezone.utc).isoformat(),
        },
    )
    task_id = task_resp.json()["id"]

    # Complete the task
    complete_resp = client.post(
        f"/api/v1/farming/tasks/{task_id}/complete",
        headers=headers,
        json={"notes": "Completed 500ml drip watering"},
    )
    assert complete_resp.status_code == 200
    assert complete_resp.json()["status"] == "completed"

    # Verify actual care log was recorded separately (REQ-3.5)
    logs_resp = client.get("/api/v1/farming/care-logs", headers=headers)
    assert logs_resp.status_code == 200
    logs = logs_resp.json()
    assert len(logs) == 1
    assert logs[0]["task_id"] == task_id
    assert logs[0]["action_taken"] == "completed"
    assert logs[0]["notes"] == "Completed 500ml drip watering"

    # SAFE-5 Replay: Completing again should succeed without creating duplicate care log
    replay_resp = client.post(
        f"/api/v1/farming/tasks/{task_id}/complete",
        headers=headers,
        json={"notes": "Duplicate completion"},
    )
    assert replay_resp.status_code == 200
    logs_after_replay = client.get("/api/v1/farming/care-logs", headers=headers).json()
    assert len(logs_after_replay) == 1  # No duplicate log created!


def test_skip_and_cancel_care_task(api):
    """REQ-3.5: Skipping and cancelling care tasks."""
    client, _, _ = api
    headers = signed_in(client, "alice")

    # Create task 1 for skip
    task1_resp = client.post(
        "/api/v1/farming/tasks",
        headers=headers,
        json={
            "task_type": "watering",
            "title": "Rainy day skip",
            "due_date": datetime.now(timezone.utc).isoformat(),
        },
    )
    task1_id = task1_resp.json()["id"]

    # Skip task 1
    skip_resp = client.post(
        f"/api/v1/farming/tasks/{task1_id}/skip",
        headers=headers,
        json={"notes": "Skipped due to unexpected 12mm rain"},
    )
    assert skip_resp.status_code == 200
    assert skip_resp.json()["status"] == "skipped"

    # Check log recorded the skip
    logs = client.get("/api/v1/farming/care-logs", headers=headers).json()
    assert any(log["task_id"] == task1_id and log["action_taken"] == "skipped" for log in logs)

    # Create task 2 for cancel
    task2_resp = client.post(
        "/api/v1/farming/tasks",
        headers=headers,
        json={
            "task_type": "fertilizer",
            "title": "Cancel test",
            "due_date": datetime.now(timezone.utc).isoformat(),
        },
    )
    task2_id = task2_resp.json()["id"]

    # Cancel task 2
    cancel_resp = client.post(f"/api/v1/farming/tasks/{task2_id}/cancel", headers=headers)
    assert cancel_resp.status_code == 200
    assert cancel_resp.json()["status"] == "cancelled"

    # Attempting to complete a cancelled task should be rejected
    invalid_resp = client.post(f"/api/v1/farming/tasks/{task2_id}/complete", headers=headers)
    assert invalid_resp.status_code == 400
