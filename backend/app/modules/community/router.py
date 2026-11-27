from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy import and_, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import Actor, verified_actor
from app.core.errors import fail
from app.db.session import get_db
from app.modules.community.models import CommunityPost
from app.modules.community.schemas import (
    CommunityPostCreate,
    CommunityPostPage,
    CommunityPostView,
)

router = APIRouter(prefix="/api/v1/community/posts", tags=["community"])

DB = Annotated[AsyncSession, Depends(get_db, scope="function")]
Owner = Annotated[Actor, Depends(verified_actor, scope="function")]


@router.post("", response_model=CommunityPostView, status_code=201)
async def create_post(body: CommunityPostCreate, actor: Owner, db: DB):
    post = CommunityPost(
        user_id=actor.user.id,
        text=body.text,
        published_at=None,
    )
    db.add(post)
    await db.flush()
    return CommunityPostView.model_validate(post)


@router.get("", response_model=CommunityPostPage)
async def list_posts(
    actor: Owner,
    db: DB,
    cursor: UUID | None = None,
    limit: int = Query(20, ge=1, le=100),
):
    query = select(CommunityPost).where(
        CommunityPost.user_id == actor.user.id
    )

    if cursor is not None:
        cursor_post = await db.scalar(
            select(CommunityPost).where(
                CommunityPost.id == cursor,
                CommunityPost.user_id == actor.user.id,
            )
        )

        if cursor_post is None:
            fail(404, "NOT_FOUND", "Post cursor was not found.")

        query = query.where(
            or_(
                CommunityPost.created_at < cursor_post.created_at,
                and_(
                    CommunityPost.created_at == cursor_post.created_at,
                    CommunityPost.id < cursor_post.id,
                ),
            )
        )

    rows = list(
        (
            await db.scalars(
                query.order_by(
                    CommunityPost.created_at.desc(),
                    CommunityPost.id.desc(),
                ).limit(limit + 1)
            )
        ).all()
    )

    page = rows[:limit]

    return CommunityPostPage(
        items=[
            CommunityPostView.model_validate(post)
            for post in page
        ],
        next_cursor=(
            page[-1].id if len(rows) > limit and page else None
        ),
    )
