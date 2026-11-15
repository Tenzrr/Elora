import uuid
from datetime import date, datetime, timezone

from sqlalchemy import Boolean, CheckConstraint, Date, DateTime, ForeignKey, Integer, JSON, String, Uuid
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


def now():
    return datetime.now(timezone.utc)


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "users"
    __table_args__ = (
        CheckConstraint("language IN ('en', 'si', 'ta')", name="user_language"),
        {"schema": "app"},
    )
    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    firebase_uid: Mapped[str] = mapped_column(String(128), unique=True)
    email: Mapped[str | None] = mapped_column(String(320))
    display_name: Mapped[str] = mapped_column(String(80), default="Grower")
    language: Mapped[str] = mapped_column(String(2), default="en")
    interests: Mapped[list] = mapped_column(JSON, default=list)
    active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class Plant(Base):
    __tablename__ = "plants"
    __table_args__ = (
        CheckConstraint("crop_slug IN ('tomato','chilli','citrus','banana','roses','chrysanthemum')", name="plant_crop"),
        CheckConstraint("revision > 0", name="plant_revision"),
        {"schema": "app"},
    )
    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("app.users.id"), index=True)
    crop_slug: Mapped[str] = mapped_column(String(20))
    growing_area: Mapped[str] = mapped_column(String(160))
    nickname: Mapped[str | None] = mapped_column(String(80))
    planted_at: Mapped[date | None] = mapped_column(Date)
    notes: Mapped[str | None] = mapped_column(String(2000))
    revision: Mapped[int] = mapped_column(Integer, default=1)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)
