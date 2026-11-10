import io
import json
import pytest
from fastapi.testclient import TestClient
from ai.models.crop_health_classifier import CropHealthClassifier
from app.main import app

client = TestClient(app)


def test_health_endpoints():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

    crop_health_health = client.get("/api/v1/crop-health/health")
    assert crop_health_health.status_code == 200
    assert crop_health_health.json()["module"] == "crop-health"


def test_ai_classifier_model_contract():
    classifier = CropHealthClassifier()

    # Test Tomato Disease
    dummy_bytes = b"sample_tomato_leaf_image_data_bytes"
    res = classifier.predict(dummy_bytes, crop_slug="tomato", model_task="disease")

    assert res["crop_slug"] == "tomato"
    assert res["task"] == "disease"
    assert "label" in res
    assert 0.0 <= res["confidence"] <= 1.0
    assert len(res["top_predictions"]) >= 3
    assert res["model_version"].startswith("CNN-TOM-DIS")

    # Test Chilli Quality
    res_chilli = classifier.predict(dummy_bytes, crop_slug="chilli", model_task="quality")
    assert res_chilli["crop_slug"] == "chilli"
    assert res_chilli["task"] == "quality"
    assert res_chilli["model_version"].startswith("CNN-CHL-QLT")


def test_analyze_crop_api_endpoint():
    dummy_image = io.BytesIO(b"\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x01\x00H\x00H\x00\x00")
    dummy_image.name = "leaf_sample.jpg"

    response = client.post(
        "/api/v1/crop-health/analyze",
        files={"file": ("leaf_sample.jpg", dummy_image, "image/jpeg")},
        data={"crop_slug": "tomato", "task": "disease"},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["crop_slug"] == "tomato"
    assert data["task"] == "disease"
    assert "detected_label" in data
    assert "severity_level" in data
    assert len(data["recovery_steps"]) == 3
    assert len(data["top_predictions"]) > 0
    assert "advisory_footnote" in data
    assert data["recovery_steps"][0]["title"] != ""


def test_analyze_invalid_crop():
    dummy_image = io.BytesIO(b"fake_image_bytes")
    response = client.post(
        "/api/v1/crop-health/analyze",
        files={"file": ("leaf.jpg", dummy_image, "image/jpeg")},
        data={"crop_slug": "unsupported_crop", "task": "disease"},
    )
    assert response.status_code == 400
    assert "not supported" in response.json()["detail"]
