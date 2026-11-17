from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ai.agent.tools.plant_context import PlantLookupResult, PlantMetadata
from app.db.models import Plant


async def lookup_user_plants(
    db: AsyncSession,
    user_id: UUID,
    plant_id: UUID | None = None,
    crop_slug: str | None = None,
) -> PlantLookupResult:
    query = select(Plant).where(Plant.user_id == user_id)
    if plant_id is not None:
        query = query.where(Plant.id == plant_id)
    if crop_slug is not None:
        query = query.where(Plant.crop_slug == crop_slug)

    result = await db.scalars(query.order_by(Plant.created_at.desc()))
    records = list(result.all())

    if not records:
        return PlantLookupResult(
            found=False,
            plants=[],
            message="No matching plants found for current user",
        )

    return PlantLookupResult(
        found=True,
        plants=[PlantMetadata.model_validate(record) for record in records],
        message=f"Found {len(records)} matching plants",
    )
