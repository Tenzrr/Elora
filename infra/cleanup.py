"""Retire only this project's expired/closed-PR development previews, including failed first rollouts."""
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import urllib.error
import urllib.request

sys.path.insert(0, str(Path(__file__).resolve().parent))
from deploy import cloud, gate
from google.cloud import storage


def cleanup():
    gate()
    project, region = os.environ["CLOUD_PROJECT_ID"], os.environ["CLOUD_REGION"]
    markers = json.loads(cloud("secrets", "list", "--filter", "labels.elora=true", "--format=json"))
    services = json.loads(cloud("run", "services", "list", "--region", region,
                                "--filter", "metadata.labels.elora=true", "--format=json"))
    accounts = json.loads(cloud("iam", "service-accounts", "list", "--format=json"))
    packages = json.loads(cloud("artifacts", "packages", "list", "--repository", "elora-api",
                                "--location", region, "--format=json"))
    now = int(datetime.now(timezone.utc).timestamp())
    for marker in markers:
        labels = marker.get("labels", {})
        schema = labels.get("workspace", "")
        if not re.fullmatch(r"pr_[1-9][0-9]*", schema):
            continue
        name = "elora-" + schema.replace("_", "-")
        if marker["name"].split("/")[-1] != name + "-database":
            continue
        expired = int(labels.get("expires", "0")) < now
        closed = False
        request = urllib.request.Request(
            f"https://api.github.com/repos/{os.environ['GITHUB_REPOSITORY']}/pulls/{schema[3:]}",
            headers={"Authorization": "Bearer " + os.environ["GH_TOKEN"],
                     "Accept": "application/vnd.github+json"})
        try:
            with urllib.request.urlopen(request, timeout=15) as response:
                closed = json.load(response)["state"] == "closed"
        except urllib.error.HTTPError as exc:
            if exc.code != 404:
                raise
        if not expired and not closed:
            continue
        if any(s["metadata"]["name"] == name for s in services):
            cloud("run", "services", "delete", name, "--region", region)
        subprocess.run([sys.executable, "backend/tools/workspace.py", "retire", schema], check=True)
        objects = storage.Client(project=project).bucket(os.environ["ASSET_BUCKET"])
        for blob in objects.list_blobs(prefix=f"private/{schema}/"):
            blob.delete(if_generation_match=blob.generation)
        account = name + "@" + project + ".iam.gserviceaccount.com"
        policy = json.loads(cloud("projects", "get-iam-policy", project, "--format=json"))
        if any(b["role"] == "roles/firebaseauth.viewer" and "serviceAccount:" + account in b["members"]
               and not b.get("condition") for b in policy.get("bindings", [])):
            cloud("projects", "remove-iam-policy-binding", project,
                  "--member", "serviceAccount:" + account, "--role", "roles/firebaseauth.viewer", "--condition=None")
        bucket = os.environ["ASSET_BUCKET"]
        policy = json.loads(cloud("storage", "buckets", "get-iam-policy", "gs://" + bucket, "--format=json"))
        if any(b["role"] == "roles/storage.objectUser" and "serviceAccount:" + account in b["members"]
               and b.get("condition", {}).get("title") == name for b in policy.get("bindings", [])):
            prefix = f"projects/_/buckets/{bucket}/objects/private/{schema}/"
            cloud("storage", "buckets", "remove-iam-policy-binding", "gs://" + bucket,
                  "--member", "serviceAccount:" + account, "--role", "roles/storage.objectUser",
                  "--condition", f'expression=resource.name.startsWith("{prefix}"),title={name}')
        if any(a["email"] == account for a in accounts):
            cloud("iam", "service-accounts", "delete", account)
        if any(p["name"].split("/")[-1] == name for p in packages):
            cloud("artifacts", "packages", "delete", name, "--repository", "elora-api", "--location", region)
        # Delete the ledger last. Interrupted cleanup is safe to retry on the next run.
        cloud("secrets", "delete", name + "-database")
        print("Retired disposable preview " + schema)


if __name__ == "__main__":
    try:
        cleanup()
    except Exception as exc:
        raise SystemExit("Preview cleanup incomplete (" + type(exc).__name__ + "); contact coordinator.")
