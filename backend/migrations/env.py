import asyncio

from alembic import context
from sqlalchemy import text

from app.core.config import Settings
from app.db.models import Base
from app.modules.crop_health.models import ScanJob  # Register feature metadata for Alembic.
from app.modules.community.models import CommunityPost  # Register Community metadata for Alembic.
from app.db.session import make_engine

settings = Settings()
schema = settings.database_schema


def migrations(connection):
    connection.execute(text(f'SET ROLE "elora_{schema}_owner"'))
    connection.execute(text(f'SET search_path TO "{schema}", public'))
    connection.commit()
    context.configure(connection=connection, target_metadata=Base.metadata,
                      version_table_schema=schema, include_schemas=True)
    with context.begin_transaction():
        context.run_migrations()
    connection.execute(text(f'REVOKE ALL ON "{schema}".alembic_version FROM "elora_{schema}_app"'))
    connection.commit()


async def online():
    if not settings.database_url:
        raise RuntimeError("Set DATABASE_URL before running migrations")
    engine = make_engine(settings)
    async with engine.connect() as conn:
        await conn.run_sync(migrations)
    await engine.dispose()


if context.is_offline_mode():
    context.configure(url="postgresql+asyncpg://", target_metadata=Base.metadata,
                      literal_binds=True, version_table_schema=schema)
    with context.begin_transaction():
        context.run_migrations()
else:
    asyncio.run(online())
