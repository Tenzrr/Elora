import ssl

from fastapi import Request
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from app.core.errors import fail


def make_engine(settings, url=None):
    return create_async_engine(
        url or settings.database_url.get_secret_value(),
        pool_size=2,
        max_overflow=0,
        pool_pre_ping=True,
        connect_args={
            "ssl": ssl.create_default_context() if settings.database_require_tls else False,
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
