from datetime import datetime, timezone
from uuid import UUID

from pydantic import ConfigDict, Field, field_validator

from app.shared.schemas import StrictModel


class CommunityPostCreate(StrictModel):
    text: str = Field(min_length=1, max_length=2000)


class CommunityPostView(StrictModel):
    model_config = ConfigDict(from_attributes=True, extra="forbid")

    id: UUID
    user_id: UUID
    text: str
    published_at: datetime | None
    created_at: datetime
    updated_at: datetime

    @field_validator("published_at", "created_at", "updated_at")
    @classmethod
    def utc_timestamp(cls, value):
        if value is not None and value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value


class CommunityPostPage(StrictModel):
    items: list[CommunityPostView]
    next_cursor: UUID | None = None
