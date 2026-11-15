"""Interactive coordinator setup. Uses only Python's standard library; never echoes secrets."""
import argparse
import getpass
import json
import os
from pathlib import Path
import re
from urllib.parse import quote

ROOT = Path(__file__).resolve().parents[2]


def private_write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("x", encoding="utf-8") as handle:
        handle.write(text)
    if os.name != "nt":
        path.chmod(0o600)


def setup():
    project = input("Supabase project ref [idptcxheihiakwttvkgo]: ").strip() or "idptcxheihiakwttvkgo"
    host = input("Session pooler hostname (Connect > Session pooler, port 5432): ").strip()
    if not re.fullmatch(r"[a-z0-9]{6,32}", project) or not re.fullmatch(
            r"[a-z0-9.-]+\.pooler\.supabase\.com", host):
        raise ValueError("Use the project reference and session-pooler hostname, not a URL")
    password = getpass.getpass("Database password (hidden): ")
    if not password:
        raise ValueError("Password is required")
    firebase = input("Firebase project ID [elora-dev-9f6b9]: ").strip() or "elora-dev-9f6b9"
    if not re.fullmatch(r"[a-z][a-z0-9-]{4,62}", firebase):
        raise ValueError("Invalid Firebase project ID")
    source = Path(input("Path to downloaded google-services.json: ").strip().strip('"'))
    client = json.loads(source.read_text(encoding="utf-8"))
    selected = next(c for c in client["client"] if
                    c["client_info"]["android_client_info"]["package_name"] == "app.elora.elora_mobile")
    info = client["project_info"]
    if info["project_id"] != firebase:
        raise ValueError("The Android configuration belongs to a different Firebase project")
    oauth = next((o["client_id"] for o in selected.get("oauth_client", [])
                  if o["client_type"] == 3), "")
    if not oauth:
        raise ValueError("Enable Google authentication, add the Android SHA-1, and download the updated config")
    config = {
        "API_BASE_URL": "http://10.0.2.2:8000",
        "FIREBASE_PROJECT_ID": firebase,
        "FIREBASE_API_KEY": selected["api_key"][0]["current_key"],
        "FIREBASE_APP_ID": selected["client_info"]["mobilesdk_app_id"],
        "FIREBASE_SENDER_ID": info["project_number"],
        "GOOGLE_WEB_CLIENT_ID": oauth,
    }
    targets = [ROOT / ".env.coordinator", ROOT / "mobile/config/dev.json"]
    if any(p.exists() for p in targets):
        raise FileExistsError("Configuration already exists. Edit it privately; this tool does not overwrite files")
    url = f"postgresql+asyncpg://postgres.{project}:{quote(password, safe='')}@{host}:5432/postgres"
    private_write(targets[0], f"APP_ENV=development\nSUPABASE_PROJECT_REF={project}\n"
                  f"DATABASE_ADMIN_URL={url}\nDATABASE_REQUIRE_TLS=true\n"
                  f"FIREBASE_PROJECT_ID={firebase}\n"
                  "GOOGLE_APPLICATION_CREDENTIALS=.secrets/firebase-admin.json\n")
    private_write(targets[1], json.dumps(config, indent=2) + "\n")
    print("Wrote ignored coordinator and Android configuration files. No service was provisioned.")


def runtime(workspace):
    if not re.fullmatch(r"integration|dev[1-5]", workspace):
        raise ValueError("Choose integration or dev1–dev5")
    role = json.loads((ROOT / f".secrets/{workspace}.json").read_text(encoding="utf-8"))
    config = json.loads((ROOT / "mobile/config/dev.json").read_text(encoding="utf-8"))
    # JSON escaping is accepted by dotenv; do not interpolate raw passwords into shell commands.
    values = {
        "APP_ENV": "development", **role, "FIREBASE_PROJECT_ID": config["FIREBASE_PROJECT_ID"],
        "GOOGLE_APPLICATION_CREDENTIALS": ".secrets/firebase-admin.json",
    }
    private_write(ROOT / ".env", "".join(k + "=" + json.dumps(v) + "\n" for k, v in values.items()))
    print("Wrote ignored .env using this workspace's scoped runtime role.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime", choices=["integration", "dev1", "dev2", "dev3", "dev4", "dev5"])
    args = parser.parse_args()
    try:
        runtime(args.runtime) if args.runtime else setup()
    except (ValueError, KeyError, StopIteration, FileExistsError, OSError) as exc:
        print(f"Setup incomplete ({type(exc).__name__}). Check the input/configuration guide.")
        raise SystemExit(1)
