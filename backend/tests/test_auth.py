from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient

from app.core.config import Settings
from app.main import create_app


def test_real_verifier_checks_revocation_and_maps_invalid_token():
    app = create_app(Settings(_env_file=None, firebase_project_id="elora-test"))
    with TestClient(app) as client, patch("app.core.auth.firebase_app", return_value=object()), patch(
        "app.core.auth.auth.verify_id_token", side_effect=ValueError("private error")
    ) as verify:
        response = client.post("/api/v1/session", headers={"Authorization": "Bearer private-token"})
        assert response.status_code == 401
        assert "private" not in response.text
        assert verify.call_args.kwargs["check_revoked"] is True


def test_workspace_validation_and_redacted_configuration():
    for schema in ["public", "integration;DROP SCHEMA public", "dev6"]:
        with pytest.raises(ValueError):
            Settings(_env_file=None, database_schema=schema)
    with pytest.raises(ValueError):
        Settings(_env_file=None, database_require_tls=False)
    config = Settings(_env_file=None, database_url="postgresql+asyncpg://a:password@host/db")
    assert "password" not in repr(config)
