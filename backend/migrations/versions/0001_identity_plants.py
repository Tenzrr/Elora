"""Initial identity/profile and owned plants."""
from alembic import context, op
import sqlalchemy as sa

from app.core.config import Settings

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    schema = Settings().database_schema
    op.create_table(
        "users",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("firebase_uid", sa.String(128), nullable=False, unique=True),
        sa.Column("email", sa.String(320)),
        sa.Column("display_name", sa.String(80), nullable=False),
        sa.Column("language", sa.String(2), nullable=False),
        sa.Column("interests", sa.JSON(), nullable=False),
        sa.Column("active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("language IN ('en','si','ta')", name="user_language"),
        schema=schema,
    )
    op.create_table(
        "plants",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("user_id", sa.Uuid(), sa.ForeignKey(f"{schema}.users.id"), nullable=False),
        sa.Column("crop_slug", sa.String(20), nullable=False),
        sa.Column("growing_area", sa.String(160), nullable=False),
        sa.Column("nickname", sa.String(80)),
        sa.Column("planted_at", sa.Date()),
        sa.Column("notes", sa.String(2000)),
        sa.Column("revision", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("crop_slug IN ('tomato','chilli','citrus','banana','roses','chrysanthemum')", name="plant_crop"),
        sa.CheckConstraint("revision > 0", name="plant_revision"),
        schema=schema,
    )
    op.create_index("ix_app_plants_user_id", "plants", ["user_id"], schema=schema)


def downgrade():
    if not context.is_offline_mode() and Settings().app_env != "test":
        raise RuntimeError("Destructive downgrade is restricted to disposable test workspaces")
    schema = Settings().database_schema
    op.drop_table("plants", schema=schema)
    op.drop_table("users", schema=schema)
