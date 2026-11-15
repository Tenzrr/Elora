from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Header, Query, Response
from sqlalchemy import delete, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import Actor, current_actor, verify_identity
from app.core.errors import fail
from app.db.models import Plant, User
from app.db.session import get_db
from app.shared.schemas import PlantCreate, PlantPage, PlantPatch, PlantView, Profile, ProfilePatch

router = APIRouter(prefix="/api/v1")
DB = Annotated[AsyncSession, Depends(get_db, scope="function")]
Owner = Annotated[Actor, Depends(current_actor, scope="function")]


@router.post("/session", response_model=Profile, tags=["identity"])
async def session(identity: Annotated[dict, Depends(verify_identity)], db: DB):
    user = await db.scalar(select(User).where(User.firebase_uid == identity["uid"]))
    if user is None:
        try:
            async with db.begin_nested():
                user = User(
                    firebase_uid=identity["uid"],
                    email=identity.get("email"),
                    display_name=(identity.get("name") or "Grower")[:80],
                )
                db.add(user)
                await db.flush()
        except IntegrityError:
            user = await db.scalar(select(User).where(User.firebase_uid == identity["uid"]))
            if user is None:
                raise
    if not user.active:
        fail(403, "ACCOUNT_INACTIVE", "This account is not active.")
    return Profile.model_validate(user)


@router.get("/profile", response_model=Profile, tags=["identity"])
async def profile(actor: Owner):
    return actor.user


@router.patch("/profile", response_model=Profile, tags=["identity"])
async def patch_profile(body: ProfilePatch, actor: Owner, db: DB):
    fields = body.model_dump(exclude_unset=True)
    if any(v is None for v in fields.values()):
        fail(422, "INVALID_INPUT", "Profile fields cannot be null.")
    if "interests" in fields:
        fields["interests"] = list(dict.fromkeys(fields["interests"]))
    for key, value in fields.items():
        setattr(actor.user, key, value)
    await db.flush()
    return actor.user


@router.post("/plants", response_model=PlantView, status_code=201, tags=["plants"])
async def create_plant(body: PlantCreate, actor: Owner, db: DB):
    plant = Plant(user_id=actor.user.id, **body.model_dump())
    db.add(plant)
    await db.flush()
    return plant


@router.get("/plants", response_model=PlantPage, tags=["plants"])
async def plants(actor: Owner, db: DB, cursor: UUID | None = None,
                 limit: int = Query(20, ge=1, le=100)):
    query = select(Plant).where(Plant.user_id == actor.user.id)
    if cursor:
        query = query.where(Plant.id > cursor)
    rows = list((await db.scalars(query.order_by(Plant.id).limit(limit + 1))).all())
    return PlantPage(
        items=[PlantView.model_validate(p) for p in rows[:limit]],
        next_cursor=rows[limit - 1].id if len(rows) > limit else None,
    )


async def owned_plant(plant_id: UUID, actor: Actor, db: AsyncSession):
    plant = await db.scalar(select(Plant).where(Plant.id == plant_id, Plant.user_id == actor.user.id))
    if plant is None:
        fail(404, "NOT_FOUND", "Plant was not found.")
    return plant


@router.get("/plants/{plant_id}", response_model=PlantView, tags=["plants"])
async def get_plant(plant_id: UUID, actor: Owner, db: DB, response: Response):
    plant = await owned_plant(plant_id, actor, db)
    response.headers["ETag"] = f'"{plant.revision}"'
    return plant


def expected_revision(value: str | None):
    if value is None:
        fail(428, "REVISION_REQUIRED", "Send the current ETag in If-Match.")
    import re
    if not re.fullmatch(r'"[1-9][0-9]*"', value):
        fail(422, "INVALID_INPUT", 'If-Match must be a quoted positive revision, such as "1".')
    return int(value[1:-1])


@router.patch("/plants/{plant_id}", response_model=PlantView, tags=["plants"])
async def patch_plant(plant_id: UUID, body: PlantPatch, actor: Owner, db: DB,
                      response: Response, if_match: str | None = Header(default=None)):
    plant = await owned_plant(plant_id, actor, db)
    revision = expected_revision(if_match)
    fields = body.model_dump(exclude_unset=True)
    if any(fields.get(k, True) is None for k in ["crop_slug", "growing_area"]):
        fail(422, "INVALID_INPUT", "Crop and growing area cannot be null.")
    result = await db.execute(
        update(Plant).where(Plant.id == plant_id, Plant.user_id == actor.user.id,
                            Plant.revision == revision)
        .values(**fields, revision=Plant.revision + 1)
    )
    if result.rowcount != 1:
        fail(409, "REVISION_CONFLICT", "Plant changed. Reload before editing.")
    await db.refresh(plant)
    response.headers["ETag"] = f'"{plant.revision}"'
    return plant


@router.delete("/plants/{plant_id}", status_code=204, tags=["plants"])
async def delete_plant(plant_id: UUID, actor: Owner, db: DB,
                       if_match: str | None = Header(default=None)):
    await owned_plant(plant_id, actor, db)
    revision = expected_revision(if_match)
    result = await db.execute(delete(Plant).where(
        Plant.id == plant_id, Plant.user_id == actor.user.id, Plant.revision == revision))
    if result.rowcount != 1:
        fail(409, "REVISION_CONFLICT", "Plant changed. Reload before deleting.")
    return Response(status_code=204)
