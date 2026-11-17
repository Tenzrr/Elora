from datetime import date
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class PlantLookupInput(BaseModel):
    model_config = ConfigDict(extra="forbid")

    plant_id: UUID | None = Field(
        default=None,
        description="Optional plant identifier to look up",
    )
    crop_slug: str | None = Field(
        default=None,
        description="Optional crop slug filter",
    )


class PlantMetadata(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    crop_slug: str
    growing_area: str
    nickname: str | None = None
    planted_at: date | None = None
    notes: str | None = None


class PlantLookupResult(BaseModel):
    found: bool
    plants: list[PlantMetadata] = Field(default_factory=list)
    message: str = Field(default="")
