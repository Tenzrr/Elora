@echo off
setlocal
cd /d "%~dp0"
set "checker=import pathlib,sys; p=pathlib.Path(sys.argv[1]); exec(compile(p.read_text(encoding='utf-8').split('\n# CHECKER PYTHON\n',1)[1], str(p), 'exec'))"
if exist ".venv\Scripts\python.exe" (
    ".venv\Scripts\python.exe" -c "%checker%" "%~f0"
) else (
    where py >nul 2>nul
    if errorlevel 1 (
        echo [FAIL] Python launcher not found. Install Python 3.12 and reopen this file.
        set "result=1"
        goto finish
    )
    py -3.12 -c "%checker%" "%~f0"
)
set "result=%errorlevel%"
:finish
if not "%result%"=="0" echo Check the FAIL or PENDING lines above.
echo.
if not "%~1"=="--no-pause" pause
exit /b %result%

# CHECKER PYTHON
import asyncio
import json
from pathlib import Path
import re
import shutil
import socket
import ssl
import struct
import sys
from urllib.parse import urlsplit
from urllib.request import urlopen
from uuid import uuid4

EXPECTED = "dev3"
PROJECT = "elora-dev-9f6b9"
issues = []


def report(status, label, detail):
    print(f"[{status}] {label}: {detail}", flush=True)
    if status in {"FAIL", "PENDING"}:
        issues.append(status)


def load_env():
    try:
        from dotenv import dotenv_values
    except ImportError:
        # The handoff has one JSON-quoted value per line, even before pip install.
        return {
            key: json.loads(value) if value.startswith('"') else value
            for key, value in (
                line.split("=", 1)
                for line in Path(".env").read_text(encoding="utf-8-sig").splitlines()
                if line.strip() and not line.lstrip().startswith("#")
            )
        }
    return dotenv_values(".env", interpolate=False)


def json_file(path):
    return json.loads(Path(path).read_text(encoding="utf-8-sig"))


def check_supabase_network(url):
    stage = "Connect to database port"
    try:
        with socket.create_connection((url.hostname, url.port or 5432), timeout=6) as raw:
            stage = "PostgreSQL SSL negotiation"
            raw.sendall(struct.pack("!II", 8, 80877103))
            if raw.recv(1) != b"S":
                report("FAIL", stage, "the pooler did not accept SSL")
                return False
            stage = "TLS certificate verification"
            context = ssl.create_default_context(cafile="backend/certs/supabase-root.crt")
            with context.wrap_socket(raw, server_hostname=url.hostname):
                report("OK", "Supabase network", "verified TLS connection to the database pooler")
            return True
    except TimeoutError:
        report("FAIL", stage, "timed out before login; try another network or check the pooler")
    except ssl.SSLCertVerificationError:
        report("FAIL", stage, "certificate could not be verified; check the repo CA file and PC clock")
    except OSError as error:
        report("FAIL", stage, f"{type(error).__name__}; check the connection and project status")
    return False


async def check_database(env, asyncpg, make_url):
    from app.core.config import Settings
    from app.db.session import database_ssl

    settings = Settings(_env_file=None, app_env="development", database_url=env["DATABASE_URL"],
                        database_schema=EXPECTED, database_require_tls=True)
    dsn = make_url(env["DATABASE_URL"]).set(drivername="postgresql")
    conn = await asyncpg.connect(dsn.render_as_string(hide_password=False),
                                 ssl=database_ssl(settings), timeout=8, statement_cache_size=0)
    try:
        role = await conn.fetchval("select current_user", timeout=5)
        can_read = await conn.fetchval(
            "select has_table_privilege($1, 'SELECT')", f"{EXPECTED}.plants", timeout=5
        )
        if role != f"elora_{EXPECTED}_app" or not can_read:
            raise ValueError
    finally:
        await conn.close(timeout=3)


def check_firebase(key, firebase_admin, auth, credentials):
    app = firebase_admin.initialize_app(credentials.Certificate(str(key)), {"projectId": PROJECT, "httpTimeout": 8})
    try:
        auth.get_user("elora-setup-check-" + uuid4().hex, app=app)
    except auth.UserNotFoundError:
        # This expected reply proves the key can perform the backend's required lookup.
        return
    raise RuntimeError("Unexpected identity response")


def main():
    print(f"Elora setup check - {EXPECTED}\n", flush=True)
    if not Path("backend/requirements.lock").is_file() or not Path("mobile/pubspec.yaml").is_file():
        report("FAIL", "Repository", "copy this file and the rest of your package into the Elora repo root")
        return

    report("OK", "Python", ".".join(map(str, sys.version_info[:3])))
    for tool in ("git", "flutter"):
        if shutil.which(tool):
            report("OK", tool, "found on PATH")
        else:
            report("FAIL", tool, "install it or add it to PATH, then open a fresh window")

    env = None
    url = None
    try:
        env = load_env()
        url = urlsplit(env["DATABASE_URL"])
        if (env["DATABASE_SCHEMA"] != EXPECTED or env["FIREBASE_PROJECT_ID"] != PROJECT
                or env["DATABASE_REQUIRE_TLS"].lower() != "true"
                or env["GOOGLE_APPLICATION_CREDENTIALS"] != ".secrets/firebase-admin.json"
                or url.scheme != "postgresql+asyncpg" or not url.hostname
                or not url.hostname.endswith(".pooler.supabase.com")
                or (url.username or "").split(".")[0] != f"elora_{EXPECTED}_app"):
            raise ValueError
        report("OK", ".env", f"configured for {EXPECTED}")
    except (OSError, AttributeError, KeyError, TypeError, ValueError):
        url = None
        report("FAIL", ".env", f"recopy the .env for {EXPECTED} into the repo root")

    try:
        config = json_file("mobile/config/dev.json")
        required = ("API_BASE_URL", "FIREBASE_API_KEY", "FIREBASE_APP_ID", "FIREBASE_SENDER_ID",
                    "GOOGLE_WEB_CLIENT_ID")
        if config["FIREBASE_PROJECT_ID"] != PROJECT or not all(config.get(key) for key in required):
            raise ValueError
        if not urlsplit(config["API_BASE_URL"]).hostname:
            raise ValueError
        report("OK", "Android configuration", "development config found")
    except (OSError, KeyError, TypeError, ValueError):
        report("FAIL", "Android configuration", "recopy mobile/config/dev.json from your package")

    key = Path(".secrets/firebase-admin.json")
    try:
        config = json_file(key)
        if (config["project_id"] != PROJECT or config["type"] != "service_account"
                or not config.get("private_key") or not config.get("client_email")):
            raise ValueError
        report("OK", "Firebase key file", "development key found")
    except (OSError, KeyError, TypeError, ValueError):
        key = None
        report("FAIL", "Firebase key file", "place your assigned key at .secrets/firebase-admin.json")

    network_ok = url is not None and check_supabase_network(url)
    try:
        import asyncpg
        import firebase_admin
        from firebase_admin import auth, credentials
        from sqlalchemy.engine import make_url
        import pydantic_settings
    except ImportError:
        report("PENDING", "Live Firebase and database login", "install the backend dependencies, then rerun")
        print(r"  py -3.12 -m venv .venv")
        print(r"  .\.venv\Scripts\python -m pip install --require-hashes -r backend/requirements.lock")
    else:
        sys.path.insert(0, str(Path("backend").resolve()))
        if network_ok:
            try:
                asyncio.run(check_database(env, asyncpg, make_url))
                report("OK", "Supabase login", f"read access verified in {EXPECTED}")
            except asyncpg.InvalidPasswordError:
                report("FAIL", "Supabase login", "password rejected; ask Kaveesha for your current .env")
            except Exception as error:
                report("FAIL", "Supabase login", f"{type(error).__name__}; check your .env and project status")
        if key is not None:
            try:
                check_firebase(key, firebase_admin, auth, credentials)
                report("OK", "Firebase backend", "credential and user lookup permission verified")
            except Exception as error:
                report("FAIL", "Firebase backend", f"{type(error).__name__}; check the key and its account permissions")

    try:
        with urlopen("http://127.0.0.1:8000/health", timeout=3) as response:
            health = json.load(response)
        if health.get("status") != "ok" or health.get("service") != "elora-api":
            raise ValueError
        report("OK", "Local API", "Elora responds on port 8000")
    except (OSError, ValueError, AttributeError):
        report("INFO", "Local API", "start FastAPI and rerun to check port 8000")

    print("\nFinal Android check: run the app and try Continue with Google, then add a test plant.")


if __name__ == "__main__":
    main()
    sys.exit(1 if issues else 0)

