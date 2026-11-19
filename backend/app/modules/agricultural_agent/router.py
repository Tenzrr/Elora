import time
from typing import Annotated
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ai.agent.prompts.agronomist_system import (
    AGRONOMIST_SYSTEM_PROMPT,
    CHEMICAL_SAFETY_REFUSAL_MESSAGE,
    is_chemical_pesticide_query,
)
from ai.agent.provider import get_agent_provider
from app.core.auth import Actor, current_actor
from app.db.session import get_db
from app.modules.agricultural_agent.schemas import (
    ChatRequest,
    ChatResponse,
    ToolExecutionMeta,
    current_timestamp,
)
from app.modules.agricultural_agent.tools import lookup_user_plants

router = APIRouter(prefix="/api/v1")
DB = Annotated[AsyncSession, Depends(get_db, scope="function")]
Owner = Annotated[Actor, Depends(current_actor, scope="function")]


@router.post("/agricultural-agent/chat", response_model=ChatResponse, tags=["agricultural_agent"])
@router.post("/agricultural_agent/chat", response_model=ChatResponse, include_in_schema=False)
async def chat_turn(body: ChatRequest, actor: Owner, db: DB):
    thread_id = body.thread_id or uuid4()
    tools_executed: list[ToolExecutionMeta] = []
    plant_context_text = ""

    if body.plant_id is not None:
        start_time = time.perf_counter()
        lookup_result = await lookup_user_plants(
            db=db,
            user_id=actor.user.id,
            plant_id=body.plant_id,
        )
        elapsed_ms = int((time.perf_counter() - start_time) * 1000)
        tools_executed.append(
            ToolExecutionMeta(
                name="lookup_user_plants",
                duration_ms=elapsed_ms,
            )
        )
        if lookup_result.found and lookup_result.plants:
            plant = lookup_result.plants[0]
            plant_context_text = f" Context for your {plant.crop_slug} in {plant.growing_area}."
        else:
            plant_context_text = " Requested plant was not found in your garden."

    if is_chemical_pesticide_query(body.message):
        return ChatResponse(
            thread_id=thread_id,
            response=CHEMICAL_SAFETY_REFUSAL_MESSAGE,
            tools_executed=tools_executed,
            created_at=current_timestamp(),
        )

    provider = get_agent_provider()
    turn_result = await provider.generate_turn(
        prompt=body.message,
        system_prompt=AGRONOMIST_SYSTEM_PROMPT,
        context=plant_context_text.strip() if plant_context_text else None,
    )

    return ChatResponse(
        thread_id=thread_id,
        response=turn_result.text,
        tools_executed=tools_executed,
        created_at=current_timestamp(),
    )
