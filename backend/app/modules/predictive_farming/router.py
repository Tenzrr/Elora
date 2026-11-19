from typing import Annotated, List, Optional
from uuid import UUID
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import Actor, current_actor
from app.db.session import get_db
from app.modules.predictive_farming.schemas import (
    CareLogView,
    CareTaskAction,
    CareTaskCreate,
    CareTaskView,
    WeatherForecastResponse,
)
from app.modules.predictive_farming.service import (
    cancel_care_task,
    complete_care_task,
    create_care_task,
    fetch_weather_forecast,
    list_care_logs,
    list_care_tasks,
    skip_care_task,
)

router = APIRouter(prefix="/api/v1/farming", tags=["predictive-farming"])
DB = Annotated[AsyncSession, Depends(get_db, scope="function")]
Owner = Annotated[Actor, Depends(current_actor, scope="function")]


# Predefined coordinates for manual area selection (REQ-3.1)
PRESET_LOCATIONS = {
    "Colombo": (6.9271, 79.8612),
    "Kandy": (7.2906, 80.6337),
    "Gampaha": (7.0840, 79.9939),
    "Jaffna": (9.6615, 80.0255),
    "Matara": (5.9549, 80.5550),
}


@router.get("/weather", response_model=WeatherForecastResponse)
async def get_farming_weather(
    actor: Annotated[Actor, Depends(current_actor)],
    location: Annotated[str | None, Query(description="Preset location name (e.g. Colombo, Kandy)")] = None,
    latitude: Annotated[float | None, Query(ge=-90.0, le=90.0, description="Optional custom latitude")] = None,
    longitude: Annotated[float | None, Query(ge=-180.0, le=180.0, description="Optional custom longitude")] = None,
    force_refresh: Annotated[bool, Query(description="Bypass cache and fetch fresh forecast")] = False,
) -> WeatherForecastResponse:
    """Fetch live weather forecast and explainable care advisory for a selected location."""
    # Resolve location name and coordinates
    if location and location in PRESET_LOCATIONS:
        lat, lon = PRESET_LOCATIONS[location]
        resolved_name = location
    elif latitude is not None and longitude is not None:
        lat, lon = latitude, longitude
        resolved_name = location or f"{lat:.2f}, {lon:.2f}"
    else:
        # Default fallback to Colombo (Western Province)
        lat, lon = PRESET_LOCATIONS["Colombo"]
        resolved_name = "Colombo"

    return await fetch_weather_forecast(
        latitude=lat,
        longitude=lon,
        location_name=resolved_name,
        force_refresh=force_refresh,
    )


# --- Care Task & Care Log Endpoints (REQ-3.5 / Issue #70) ---


@router.get("/tasks", response_model=List[CareTaskView])
async def get_tasks(
    actor: Owner,
    db: DB,
    plant_id: Optional[UUID] = Query(default=None, description="Filter by plant"),
    status: Optional[str] = Query(default=None, description="Filter by task status"),
) -> List[CareTaskView]:
    """List scheduled and historical care tasks for the authenticated user."""
    return await list_care_tasks(db=db, user_id=actor.user.id, plant_id=plant_id, status=status)


@router.post("/tasks", response_model=CareTaskView, status_code=status.HTTP_201_CREATED)
async def post_task(
    body: CareTaskCreate,
    actor: Owner,
    db: DB,
) -> CareTaskView:
    """Create a new care task linked to an owned plant under ownership checks (REQ-3.5)."""
    return await create_care_task(db=db, user_id=actor.user.id, task_in=body)


@router.post("/tasks/{task_id}/complete", response_model=CareTaskView)
async def complete_task(
    task_id: UUID,
    actor: Owner,
    db: DB,
    body: Optional[CareTaskAction] = None,
) -> CareTaskView:
    """Mark a care task as completed and retain an actual care log (REQ-3.5, SAFE-5)."""
    notes = body.notes if body else None
    return await complete_care_task(db=db, user_id=actor.user.id, task_id=task_id, notes=notes)


@router.post("/tasks/{task_id}/skip", response_model=CareTaskView)
async def skip_task(
    task_id: UUID,
    actor: Owner,
    db: DB,
    body: Optional[CareTaskAction] = None,
) -> CareTaskView:
    """Mark a care task as skipped and retain an actual care log (REQ-3.5, SAFE-5)."""
    notes = body.notes if body else None
    return await skip_care_task(db=db, user_id=actor.user.id, task_id=task_id, notes=notes)


@router.post("/tasks/{task_id}/cancel", response_model=CareTaskView)
async def cancel_task(
    task_id: UUID,
    actor: Owner,
    db: DB,
) -> CareTaskView:
    """Cancel a scheduled care task (REQ-3.5)."""
    return await cancel_care_task(db=db, user_id=actor.user.id, task_id=task_id)


@router.get("/care-logs", response_model=List[CareLogView])
async def get_care_logs(
    actor: Owner,
    db: DB,
    plant_id: Optional[UUID] = Query(default=None, description="Filter care logs by plant"),
) -> List[CareLogView]:
    """Retrieve actual care logs retained separately from recommendations (REQ-3.5)."""
    return await list_care_logs(db=db, user_id=actor.user.id, plant_id=plant_id)

