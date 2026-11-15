from fastapi.testclient import TestClient

from app.main import app


def test_scaffold_exposes_only_health_and_documentation():
    with TestClient(app) as client:
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json() == {"status": "ok", "service": "elora-api"}
        assert set(client.get("/openapi.json").json()["paths"]) == {"/health"}
        assert client.post("/api/v1/crop-health/analyze").status_code == 404
