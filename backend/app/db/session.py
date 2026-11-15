import ssl
from pathlib import Path
from sqlalchemy.engine import make_url

from fastapi import Request
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from app.core.errors import fail


def database_ssl(settings):
    if not settings.database_require_tls:
        return False
    context = ssl.create_default_context()
    authority = settings.database_ca_file
    if not authority and settings.database_url:
        host = make_url(settings.database_url.get_secret_value()).host or ""
        bundled = Path(__file__).resolve().parents[2] / "certs/supabase-root.crt"
        if host.endswith((".supabase.com", ".supabase.co")) and bundled.exists():
            authority = str(bundled)
    if authority:
        context.load_verify_locations(cafile=authority)
    return context


def make_engine(settings, url=None):
    return create_async_engine(
        url or settings.database_url.get_secret_value(),
        pool_size=2,
        max_overflow=0,
        pool_pre_ping=True,
        connect_args={
            "ssl": database_ssl(settings),
            "statement_cache_size": 0,
            "server_settings": {"application_name": "elora-" + settings.database_schema},
        },
        execution_options={"schema_translate_map": {"app": settings.database_schema}},
    )


async def get_db(request: Request):
    engine = request.app.state.engine
    if engine is None:
        fail(503, "SERVICE_UNAVAILABLE", "Database configuration is not available.")
    async with async_sessionmaker(engine, expire_on_commit=False)() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
