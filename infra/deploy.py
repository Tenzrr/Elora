"""Trusted coordinator/CI deployment. Requires prior billing approval and project bootstrap."""
import argparse
from datetime import datetime, timedelta, timezone
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from tempfile import TemporaryDirectory
import time
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "backend"))
from app.core.config import Settings


def cloud(*args, input=None, capture=True):
    command = ["gcloud", *args, "--project", os.environ["CLOUD_PROJECT_ID"], "--quiet"]
    result = subprocess.run(command, input=input, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError("Cloud command failed: " + " ".join(args[:2]))
    return result.stdout.strip()


def gate():
    if os.environ.get("BILLING_APPROVED") != "true" or os.environ.get("CLOUD_SERVICES_READY") != "true":
        raise RuntimeError("Cloud configuration and itemized cost approval are required")
    for key in ["CLOUD_PROJECT_ID", "CLOUD_REGION", "ASSET_BUCKET"]:
        if not os.environ.get(key):
            raise RuntimeError("Missing deployment configuration: " + key)


def deploy(schema, commit):
    gate()
    Settings(_env_file=None, database_schema=schema)
    if not re.fullmatch(r"[0-9a-f]{40}", commit):
        raise ValueError("Use an immutable full commit SHA")
    project = os.environ["CLOUD_PROJECT_ID"]
    region = os.environ["CLOUD_REGION"]
    service = "elora-" + schema.replace("_", "-")
    secret = service + "-database"
    image = f"{region}-docker.pkg.dev/{project}/elora-api/{service}:{commit}"
    active = json.loads(cloud("secrets", "list", "--filter", "labels.elora=true", "--format=json"))
    previews = [s for s in active if s.get("labels", {}).get("workspace", "").startswith("pr_")]
    if schema.startswith("pr_") and not any(s["name"].split("/")[-1] == secret for s in previews) and len(previews) >= 5:
        raise RuntimeError("Five previews are already active; retire one before creating another")
    expiry = str(int((datetime.now(timezone.utc) + timedelta(hours=48)).timestamp()))
    labels = "elora=true,workspace=" + schema + (",expires=" + expiry if schema.startswith("pr_") else "")
    exists = any(s["name"].split("/")[-1] == secret for s in active)
    # This empty secret is also a resource ledger, so failed first deployments expire.
    if not exists:
        cloud("secrets", "create", secret, "--replication-policy", "automatic", "--labels", labels)
    else:
        cloud("secrets", "update", secret, "--update-labels", labels)
    has_version = bool(cloud("secrets", "versions", "list", secret, "--filter", "state=ENABLED",
                             "--format=value(name)", "--limit=1"))
    provision_env = {**os.environ, "APP_ENV": "development", "DATABASE_SCHEMA": schema}
    with TemporaryDirectory(prefix="elora-deploy-") as temporary:
        private = Path(temporary) / "database.json"
        local_workspace = ROOT / ".secrets" / (schema + ".json")
        if has_version:
            url = cloud("secrets", "versions", "access", "latest", "--secret", secret)
            data = {"DATABASE_URL": url, "DATABASE_SCHEMA": schema}
            private.write_text(json.dumps(data), encoding="utf-8")
        elif local_workspace.is_file():
            private.write_bytes(local_workspace.read_bytes())
        subprocess.run([sys.executable, "backend/tools/workspace.py", "create", schema,
                        "--output", str(private)], cwd=ROOT, env=provision_env, check=True)
        if not has_version:
            data = json.loads(private.read_text(encoding="utf-8"))
            cloud("secrets", "versions", "add", secret, "--data-file=-", input=data["DATABASE_URL"])
    subprocess.run([sys.executable, "backend/tools/migrate.py", schema],
                   cwd=ROOT, env=provision_env, check=True)
    account = service + "@" + project + ".iam.gserviceaccount.com"
    has_account = subprocess.run(["gcloud", "iam", "service-accounts", "describe", account,
                                 "--project", project], capture_output=True).returncode == 0
    if not has_account:
        cloud("iam", "service-accounts", "create", service)
    cloud("projects", "add-iam-policy-binding", project, "--member", "serviceAccount:" + account,
          "--role", "roles/firebaseauth.viewer", "--condition=None")
    cloud("iam", "service-accounts", "add-iam-policy-binding", account,
          "--member", "serviceAccount:" + account, "--role", "roles/iam.serviceAccountTokenCreator")
    prefix = f"projects/_/buckets/{os.environ['ASSET_BUCKET']}/objects/private/{schema}/"
    cloud("storage", "buckets", "add-iam-policy-binding", "gs://" + os.environ["ASSET_BUCKET"],
          "--member", "serviceAccount:" + account, "--role", "roles/storage.objectUser",
          "--condition", f'expression=resource.name.startsWith("{prefix}"),title={service}')
    cloud("secrets", "add-iam-policy-binding", secret,
          "--member", "serviceAccount:" + account, "--role", "roles/secretmanager.secretAccessor")
    cloud("builds", "submit", ".", "--config", "infra/cloudbuild.yaml",
          "--substitutions", "_IMAGE=" + image)
    cloud("run", "deploy", service, "--image", image, "--region", region,
          "--service-account", account, "--allow-unauthenticated", "--no-traffic",
          "--tag", "candidate", "--min-instances", "0", "--max-instances", "1",
          "--cpu", "1", "--memory", "512Mi", "--concurrency", "20",
          "--labels", labels, "--set-secrets", "DATABASE_URL=" + secret + ":latest",
          "--set-env-vars", ",".join([
              "APP_ENV=development", "DATABASE_SCHEMA=" + schema, "DATABASE_REQUIRE_TLS=true",
              "FIREBASE_PROJECT_ID=" + project, "ASSET_BUCKET=" + os.environ["ASSET_BUCKET"],
              "REQUIRE_DATABASE_AT_STARTUP=true",
          ]))
    description = json.loads(cloud("run", "services", "describe", service, "--region", region, "--format=json"))
    candidate = next(t["url"] for t in description["status"]["traffic"] if t.get("tag") == "candidate")
    for attempt in range(12):
        try:
            with urllib.request.urlopen(candidate + "/health", timeout=15) as response:
                if json.load(response)["status"] == "ok":
                    break
        except (OSError, ValueError, KeyError):
            pass
        if attempt < 11:
            time.sleep(5)
    else:
        raise RuntimeError("Candidate health check failed; traffic was not promoted")
    cloud("run", "services", "update-traffic", service, "--region", region, "--to-latest")
    url = cloud("run", "services", "describe", service, "--region", region, "--format=value(status.url)")
    print("Development API: " + url)
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as handle:
            handle.write(f"## {schema}\nAPI: {url}\nCommit: {commit}\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("schema")
    parser.add_argument("commit")
    args = parser.parse_args()
    try:
        deploy(args.schema, args.commit)
    except Exception as exc:
        print(f"Deployment stopped ({type(exc).__name__}). No successful rollout is claimed.", file=sys.stderr)
        raise SystemExit(1)
