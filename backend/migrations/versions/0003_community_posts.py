"""Persist authenticated interim Community text posts."""

from alembic import context, op
import sqlalchemy as sa

from app.core.config import Settings

revision = "0003"
down_revision = "0002"
branch_labels = None
depends_on = None


def upgrade():
    schema = Settings().database_schema

    op.create_table(
        "community_posts",
        sa.Column("id", sa.Uuid(), primary_key=True, nullable=False),
        sa.Column(
            "user_id",
            sa.Uuid(),
            sa.ForeignKey(f"{schema}.users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("text", sa.Text(), nullable=False),
        sa.Column("published_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint(
            "length(trim(text)) > 0",
            name="community_post_text_nonempty",
        ),
        schema=schema,
    )

    op.create_index(
        "ix_app_community_posts_user_id",
        "community_posts",
        ["user_id"],
        schema=schema,
    )
    op.create_index(
        "ix_app_community_posts_published_at",
        "community_posts",
        ["published_at"],
        schema=schema,
    )
    op.create_index(
        "ix_app_community_posts_created_at",
        "community_posts",
        ["created_at"],
        schema=schema,
    )


def downgrade():
    if not context.is_offline_mode() and Settings().app_env != "test":
        raise RuntimeError(
            "Destructive downgrade is restricted to disposable test workspaces"
        )

    op.drop_table("community_posts", schema=Settings().database_schema)
