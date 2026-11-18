import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.models import Base, now


class ScanJob(Base):
    __tablename__ = "scan_jobs"
    __table_args__ = (UniqueConstraint("user_id", "operation_id", name="scan_operation"), {"schema": "app"})

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("app.users.id"), index=True)
    operation_id: Mapped[uuid.UUID] = mapped_column(Uuid)
    request_sha256: Mapped[str] = mapped_column(String(64))
    status: Mapped[str] = mapped_column(String(12), default="failed")
    error_code: Mapped[str] = mapped_column(String(40), default="MODEL_UNAVAILABLE")
    crop_slug: Mapped[str] = mapped_column(String(20))
    task: Mapped[str] = mapped_column(String(10))
    subtype: Mapped[str | None] = mapped_column(String(20))
    plant_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("app.plants.id", ondelete="SET NULL"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)
