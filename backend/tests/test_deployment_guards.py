import importlib.util
from pathlib import Path
from unittest.mock import patch

import pytest


def load_deploy():
    path = Path("infra/deploy.py")
    spec = importlib.util.spec_from_file_location("elora_deploy_test", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_no_cloud_command_before_explicit_approval(monkeypatch):
    module = load_deploy()
    monkeypatch.delenv("BILLING_APPROVED", raising=False)
    monkeypatch.setenv("CLOUD_SERVICES_READY", "true")
    with patch.object(module.subprocess, "run") as command:
        with pytest.raises(RuntimeError):
            module.deploy("integration", "a" * 40)
        command.assert_not_called()


def test_preview_limit_stops_before_database_or_build(monkeypatch):
    module = load_deploy()
    for key, value in {"BILLING_APPROVED": "true", "CLOUD_SERVICES_READY": "true",
                       "CLOUD_PROJECT_ID": "elora-dev-test", "CLOUD_REGION": "asia-south1",
                       "ASSET_BUCKET": "private-test"}.items():
        monkeypatch.setenv(key, value)
    import json
    services = [{"name": f"projects/test/secrets/elora-pr-{i}-database", "labels": {"workspace": f"pr_{i}"}}
                for i in range(1, 6)]
    with patch.object(module, "cloud", return_value=json.dumps(services)) as command:
        with pytest.raises(RuntimeError, match="Five previews"):
            module.deploy("pr_99", "a" * 40)
        assert command.call_count == 1


def test_finalized_srs_hash_is_unchanged():
    import hashlib
    import json
    metadata = json.loads(Path("docs/specifications/Elora_SRS.source.json").read_text())
    normalized = Path("docs/specifications/Elora_SRS.md").read_text(encoding="utf-8").encode()
    assert hashlib.sha256(normalized).hexdigest() == metadata["text_sha256"]
