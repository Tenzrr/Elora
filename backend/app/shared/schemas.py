from datetime import date, datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

CropSlug = Literal["tomato", "chilli", "citrus", "banana", "roses", "chrysanthemum"]
Language = Literal["en", "si", "ta"]


class StrictModel(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


class ProfilePatch(StrictModel):
    display_name: str | None = Field(default=None, min_length=1, max_length=80)
    language: Language | None = None
    interests: list[CropSlug] | None = Field(default=None, max_length=6)


class Profile(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: UUID
    email: str | None
    display_name: str
    language: Language
    interests: list[CropSlug]
    created_at: datetime


class PlantCreate(StrictModel):
    crop_slug: CropSlug
    growing_area: str = Field(min_length=1, max_length=160)
    nickname: str | None = Field(default=None, max_length=80)
    planted_at: date | None = None
    notes: str | None = Field(default=None, max_length=2000)


class PlantPatch(StrictModel):
    crop_slug: CropSlug | None = None
    growing_area: str | None = Field(default=None, min_length=1, max_length=160)
    nickname: str | None = Field(default=None, max_length=80)
    planted_at: date | None = None
    notes: str | None = Field(default=None, max_length=2000)


class PlantView(PlantCreate):
    model_config = ConfigDict(from_attributes=True)
    id: UUID
    user_id: UUID
    revision: int
    created_at: datetime


class PlantPage(BaseModel):
    items: list[PlantView]
    next_cursor: UUID | None
