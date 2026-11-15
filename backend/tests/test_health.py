from fastapi.testclient import TestClient

from app.core.config import Settings
from app.main import create_app


def test_health_has_no_cloud_dependency():
    with TestClient(create_app(Settings(_env_file=None))) as client:
        response = client.get("/health")
        assert response.json() == {"status": "ok", "service": "elora-api"}
        assert "X-Request-ID" in response.headers
        assert client.get("/api/v1/profile").status_code == 401
        assert client.post("/api/v1/crop-health/analyze").status_code == 404
        response = client.post("/api/v1/session", headers={"Authorization": "Bearer any"})
        assert response.status_code == 503
        assert response.json()["error"]["code"] == "SERVICE_UNAVAILABLE"
