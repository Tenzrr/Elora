"""Coordinator migration entry point. The admin credential never enters CLI arguments."""
import argparse
import os
from pathlib import Path
import subprocess
import sys

from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "backend"))
from app.core.config import Settings

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("schema")
    args = parser.parse_args()
    load_dotenv(ROOT / ".env.coordinator")
    Settings(_env_file=None, database_schema=args.schema)
    admin = os.environ.get("DATABASE_ADMIN_URL")
    if not admin:
        raise SystemExit("Configure DATABASE_ADMIN_URL privately before migration")
    env = {**os.environ, "DATABASE_URL": admin, "DATABASE_SCHEMA": args.schema}
    result = subprocess.run([sys.executable, "-m", "alembic", "-c", "backend/alembic.ini",
                             "upgrade", "head"], cwd=ROOT, env=env, capture_output=True)
    if result.returncode:
        raise SystemExit("Migration failed. No API rollout should occur; inspect privately with the coordinator.")
    print(f"Workspace {args.schema} is at the current migration head.")
