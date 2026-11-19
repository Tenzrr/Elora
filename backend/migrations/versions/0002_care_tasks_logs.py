"""Care tasks and actual care logs (REQ-3.5)."""
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
        "care_tasks",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("user_id", sa.Uuid(), sa.ForeignKey(f"{schema}.users.id"), nullable=False),
        sa.Column("plant_id", sa.Uuid(), sa.ForeignKey(f"{schema}.plants.id", ondelete="CASCADE"), nullable=True),
        sa.Column("task_type", sa.String(30), nullable=False, server_default="watering"),
        sa.Column("title", sa.String(160), nullable=False),
        sa.Column("description", sa.String(1000)),
        sa.Column("due_date", sa.DateTime(timezone=True), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("advisory_rationale", sa.String(500)),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("task_type IN ('watering', 'fertilizer', 'pruning', 'harvest', 'pest_control')", name="care_task_type"),
        sa.CheckConstraint("status IN ('pending', 'completed', 'skipped', 'cancelled')", name="care_task_status"),
        schema=schema,
    )
    op.create_index("ix_app_care_tasks_user_id", "care_tasks", ["user_id"], schema=schema)
    op.create_index("ix_app_care_tasks_plant_id", "care_tasks", ["plant_id"], schema=schema)

    op.create_table(
        "care_logs",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("task_id", sa.Uuid(), sa.ForeignKey(f"{schema}.care_tasks.id", ondelete="SET NULL"), nullable=True),
        sa.Column("user_id", sa.Uuid(), sa.ForeignKey(f"{schema}.users.id"), nullable=False),
        sa.Column("plant_id", sa.Uuid(), sa.ForeignKey(f"{schema}.plants.id", ondelete="CASCADE"), nullable=True),
        sa.Column("action_taken", sa.String(50), nullable=False),
        sa.Column("notes", sa.String(1000)),
        sa.Column("logged_at", sa.DateTime(timezone=True), nullable=False),
        schema=schema,
    )
    op.create_index("ix_app_care_logs_user_id", "care_logs", ["user_id"], schema=schema)
    op.create_index("ix_app_care_logs_plant_id", "care_logs", ["plant_id"], schema=schema)


def downgrade():
    if not context.is_offline_mode() and Settings().app_env != "test":
        raise RuntimeError("Destructive downgrade is restricted to disposable test workspaces")
    schema = Settings().database_schema
    op.drop_table("care_logs", schema=schema)
    op.drop_table("care_tasks", schema=schema)
