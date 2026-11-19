from datetime import datetime, timezone
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, field_validator

from app.shared.schemas import CropSlug, StrictModel


class ScanInput(StrictModel):
    crop_slug: CropSlug
    task: Literal["disease", "quality"]
    subtype: str | None = None
    plant_id: UUID | None = None


class ScanReceipt(BaseModel):
    scan_id: UUID
    status_url: str


class ScanFailure(BaseModel):
    code: Literal["MODEL_UNAVAILABLE"] = "MODEL_UNAVAILABLE"
    message: str = "No inference model is connected. Select a photo to try again after model integration."


class ScanStatus(ScanReceipt):
    status: Literal["failed"] = "failed"
    crop_slug: CropSlug
    task: Literal["disease", "quality"]
    subtype: str | None
    plant_id: UUID | None
    created_at: datetime
    image_retained: Literal[False] = False
    result: None = None
    error: ScanFailure = ScanFailure()

    @field_validator("created_at")
    @classmethod
    def utc_timestamp(cls, value: datetime):
        # SQLite test storage drops timezone information from UTC timestamps.
        return value.replace(tzinfo=timezone.utc) if value.tzinfo is None else value
