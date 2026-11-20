"""Persist interim upload receipt and retry identity, without storing photos."""
from alembic import context, op
import sqlalchemy as sa

from app.core.config import Settings

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None


def upgrade():
    schema = Settings().database_schema
    op.create_table(
        "scan_jobs",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("user_id", sa.Uuid(), sa.ForeignKey(f"{schema}.users.id"), nullable=False),
        sa.Column("operation_id", sa.Uuid(), nullable=False),
        sa.Column("request_sha256", sa.String(64), nullable=False),
        sa.Column("status", sa.String(12), nullable=False),
        sa.Column("error_code", sa.String(40), nullable=False),
        sa.Column("crop_slug", sa.String(20), nullable=False),
        sa.Column("task", sa.String(10), nullable=False),
        sa.Column("subtype", sa.String(20)),
        sa.Column("plant_id", sa.Uuid(), sa.ForeignKey(f"{schema}.plants.id", ondelete="SET NULL")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint("user_id", "operation_id", name="scan_operation"),
        schema=schema,
    )
    op.create_index("ix_app_scan_jobs_user_id", "scan_jobs", ["user_id"], schema=schema)


def downgrade():
    if not context.is_offline_mode() and Settings().app_env != "test":
        raise RuntimeError("Destructive downgrade is restricted to disposable test workspaces")
    op.drop_table("scan_jobs", schema=Settings().database_schema)
