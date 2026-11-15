"""Coordinator/CI only. Provision isolated schemas; never print passwords or DSNs."""
import argparse
import asyncio
import json
import os
from pathlib import Path
import re
import secrets
import sys

import asyncpg
from dotenv import load_dotenv
from sqlalchemy.engine import make_url

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from app.core.config import Settings
from app.db.session import database_ssl


async def provision(schema, output, password=None):
    load_dotenv(".env.coordinator")
    Settings(_env_file=None, database_schema=schema)
    raw_url = os.environ.get("DATABASE_ADMIN_URL", "")
    if not raw_url:
        raise ValueError("Configure DATABASE_ADMIN_URL privately")
    require_tls = os.environ.get("APP_ENV") != "test"
    url = make_url(raw_url)
    tls_settings = Settings(_env_file=None, database_url=raw_url, database_schema=schema)
    connection = await asyncpg.connect(
        url.set(drivername="postgresql").render_as_string(hide_password=False),
        ssl=database_ssl(tls_settings),
        statement_cache_size=0,
    )
    owner, runtime = f"elora_{schema}_owner", f"elora_{schema}_app"
    if password is None and Path(output).exists():
        previous = json.loads(Path(output).read_text(encoding="utf-8"))
        if previous["DATABASE_SCHEMA"] != schema:
            raise ValueError("Credential output belongs to a different workspace")
        password = make_url(previous["DATABASE_URL"]).password
    password = password or secrets.token_urlsafe(32)
    try:
        async with connection.transaction():
            await connection.execute("SELECT pg_advisory_xact_lock(hashtext($1))", "elora-provision")
            for role, login in [(owner, "NOLOGIN"), (runtime, "LOGIN")]:
                if not await connection.fetchval("SELECT 1 FROM pg_roles WHERE rolname=$1", role):
                    await connection.execute(f'CREATE ROLE "{role}" {login}')
            # PostgreSQL utility statements cannot bind a password parameter.
            literal = await connection.fetchval("SELECT quote_literal($1)", password)
            await connection.execute(f'ALTER ROLE "{runtime}" PASSWORD {literal}')
            await connection.execute(f'GRANT "{owner}" TO CURRENT_USER')
            await connection.execute(f'CREATE SCHEMA IF NOT EXISTS "{schema}" AUTHORIZATION "{owner}"')
            await connection.execute(f'REVOKE ALL ON SCHEMA "{schema}" FROM PUBLIC')
            await connection.execute(f'GRANT USAGE ON SCHEMA "{schema}" TO "{runtime}"')
            await connection.execute(
                f'ALTER DEFAULT PRIVILEGES FOR ROLE "{owner}" IN SCHEMA "{schema}" '
                f'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "{runtime}"')
            await connection.execute(
                f'GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA "{schema}" TO "{runtime}"')
            await connection.execute("CREATE EXTENSION IF NOT EXISTS vector")
            namespace = await connection.fetchval(
                "SELECT quote_ident(n.nspname) FROM pg_extension e JOIN pg_namespace n "
                "ON n.oid=e.extnamespace WHERE e.extname='vector'")
            await connection.execute(f'GRANT USAGE ON SCHEMA {namespace} TO "{owner}", "{runtime}"')
            if await connection.fetchval("SELECT to_regclass($1)", schema + ".alembic_version"):
                await connection.execute(f'REVOKE ALL ON "{schema}".alembic_version FROM "{runtime}"')
    finally:
        await connection.close()
    suffix = "." + os.environ["SUPABASE_PROJECT_REF"] if os.environ.get("SUPABASE_PROJECT_REF") else ""
    runtime_url = url.set(drivername="postgresql+asyncpg", username=runtime + suffix,
                          password=password).render_as_string(hide_password=False)
    path = Path(output)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps({
        "DATABASE_URL": runtime_url, "DATABASE_SCHEMA": schema,
        "DATABASE_REQUIRE_TLS": str(require_tls).lower(),
    }), encoding="utf-8")
    if os.name != "nt":
        path.chmod(0o600)
    print(f"Workspace {schema} prepared; credentials written to private output file.")
    return runtime_url


async def retire(schema):
    load_dotenv(".env.coordinator")
    if not re.fullmatch(r"pr_[1-9][0-9]*", schema):
        raise ValueError("Only disposable PR schemas may be retired")
    raw_url = os.environ["DATABASE_ADMIN_URL"]
    url = make_url(raw_url).set(drivername="postgresql")
    tls_settings = Settings(_env_file=None, database_url=raw_url, database_schema=schema)
    conn = await asyncpg.connect(url.render_as_string(hide_password=False),
                                ssl=database_ssl(tls_settings), statement_cache_size=0)
    try:
        async with conn.transaction():
            await conn.execute("SELECT pg_advisory_xact_lock(hashtext($1))", "elora-provision")
            await conn.execute(f'DROP SCHEMA IF EXISTS "{schema}" CASCADE')
            for role in [f"elora_{schema}_app", f"elora_{schema}_owner"]:
                if await conn.fetchval("SELECT 1 FROM pg_roles WHERE rolname=$1", role):
                    await conn.execute(f'GRANT "{role}" TO CURRENT_USER')
                    await conn.execute(f'DROP OWNED BY "{role}"')
                    await conn.execute(f'DROP ROLE "{role}"')
    finally:
        await conn.close()
    print(f"Disposable workspace {schema} retired.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["create", "retire"])
    parser.add_argument("schema")
    parser.add_argument("--output", default=".secrets/workspace.json")
    args = parser.parse_args()
    try:
        asyncio.run(provision(args.schema, args.output) if args.action == "create" else retire(args.schema))
    except Exception as exc:
        print(f"Workspace operation failed ({type(exc).__name__}); check private configuration.", file=sys.stderr)
        sys.exit(1)
