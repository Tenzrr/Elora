from datetime import datetime, timezone
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.shared.schemas import StrictModel


def current_timestamp() -> datetime:
    return datetime.now(timezone.utc)


class ToolExecutionMeta(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    duration_ms: int = Field(ge=0)


class ChatRequest(StrictModel):
    thread_id: UUID | None = None
    plant_id: UUID | None = None
    message: str = Field(min_length=1, max_length=4000)


class ChatResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    thread_id: UUID
    response: str
    tools_executed: list[ToolExecutionMeta] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=current_timestamp)
