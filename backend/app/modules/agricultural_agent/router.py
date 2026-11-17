from typing import Annotated
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import Actor, current_actor
from app.db.session import get_db
from app.modules.agricultural_agent.schemas import ChatRequest, ChatResponse, current_timestamp

router = APIRouter(prefix="/api/v1")
DB = Annotated[AsyncSession, Depends(get_db, scope="function")]
Owner = Annotated[Actor, Depends(current_actor, scope="function")]


@router.post("/agricultural-agent/chat", response_model=ChatResponse, tags=["agricultural_agent"])
@router.post("/agricultural_agent/chat", response_model=ChatResponse, include_in_schema=False)
async def chat_turn(body: ChatRequest, actor: Owner, db: DB):
    thread_id = body.thread_id or uuid4()
    guidance = (
        "Welcome to Elora Agricultural Assistant. "
        "Inspect leaf surfaces, monitor soil moisture before watering, and maintain clean tools. "
        "For specific disease diagnosis, share clear photos through crop scanning."
    )
    return ChatResponse(
        thread_id=thread_id,
        response=guidance,
        tools_executed=[],
        created_at=current_timestamp(),
    )
