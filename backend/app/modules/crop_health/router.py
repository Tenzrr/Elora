import hashlib
import json
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Header, Request, Response
from pydantic import ValidationError
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.concurrency import run_in_threadpool
from starlette.datastructures import UploadFile
from starlette.requests import Request as MultipartRequest

from app.core.auth import Actor, verified_actor
from app.core.errors import fail
from app.db.models import Plant
from app.db.session import get_db
from app.modules.crop_health.models import ScanJob
from app.modules.crop_health.schemas import ScanFailure, ScanInput, ScanReceipt, ScanStatus
from app.shared.images import MAX_BYTES, validate_image

router = APIRouter(prefix="/api/v1/scans", tags=["scans"])
DB = Annotated[AsyncSession, Depends(get_db, scope="function")]
Owner = Annotated[Actor, Depends(verified_actor, scope="function")]


async def upload(request: Request):
    if not request.headers.get("content-type", "").startswith("multipart/form-data"):
        fail(415, "UNSUPPORTED_MEDIA_TYPE", "Send a multipart image upload.")
    body = bytearray()
    async for chunk in request.stream():
        if len(body) + len(chunk) > MAX_BYTES + 64 * 1024:
            fail(413, "IMAGE_TOO_LARGE", "Upload exceeds the 10 MiB image and 64 KiB form limits.")
        body.extend(chunk)

    async def receive():
        return {"type": "http.request", "body": bytes(body), "more_body": False}

    bounded = MultipartRequest(request.scope, receive)
    async with bounded.form(max_files=1, max_fields=4, max_part_size=1024) as form:
        keys = [key for key, _ in form.multi_items()]
        if len(keys) != len(set(keys)) or set(keys) - {"image", "crop_slug", "task", "subtype", "plant_id"}:
            fail(422, "INVALID_INPUT", "Send only the documented fields, once each.")
        image = form.get("image")
        if not isinstance(image, UploadFile):
            fail(422, "INVALID_IMAGE", "Choose an image.")
        fields = {key: value for key, value in form.items() if key != "image"}
        try:
            selection = ScanInput.model_validate(fields)
        except ValidationError:
            fail(422, "INVALID_INPUT", "Check crop, task and plant selection.")
        raw = await image.read(MAX_BYTES + 1)
    if len(raw) > MAX_BYTES:
        fail(413, "IMAGE_TOO_LARGE", "Image must contain at most 10 MiB.")
    if raw and not (raw.startswith(b"\xff\xd8\xff") or raw.startswith(b"\x89PNG\r\n\x1a\n")
                    or (raw.startswith(b"RIFF") and raw[8:12] == b"WEBP")):
        fail(415, "UNSUPPORTED_MEDIA_TYPE", "Use JPEG, PNG or WebP.")
    await run_in_threadpool(validate_image, raw)
    digest = hashlib.sha256(json.dumps(selection.model_dump(mode="json"), sort_keys=True).encode() + b"\0" + raw).hexdigest()
    return selection, digest


def view(job: ScanJob):
    # shortcut: every interim job is terminal; add worker state with the durable inference service in #54.
    return ScanStatus(scan_id=job.id, status_url=f"/api/v1/scans/{job.id}",
                      crop_slug=job.crop_slug, task=job.task, subtype=job.subtype,
                      plant_id=job.plant_id, created_at=job.created_at,
                      status=job.status, error=ScanFailure(code=job.error_code))


@router.post("", response_model=ScanReceipt, status_code=202, openapi_extra={
    "requestBody": {"required": True, "content": {"multipart/form-data": {"schema": {
        "type": "object", "required": ["image", "crop_slug", "task"], "additionalProperties": False,
        "properties": {"image": {"type": "string", "format": "binary"},
                       "crop_slug": {"type": "string", "enum": ["tomato", "citrus"]},
                       "task": {"type": "string", "enum": ["disease", "quality"]},
                       "subtype": {"type": "string", "enum": ["orange", "lemon"]},
                       "plant_id": {"type": "string", "format": "uuid"}},
    }}}},
})
async def submit(request: Request, response: Response, actor: Owner, db: DB,
                 idempotency_key: Annotated[UUID, Header()]):
    selection, digest = await upload(request)
    if selection.crop_slug == "citrus" and selection.task == "quality":
        if selection.subtype not in {"orange", "lemon"}:
            fail(422, "INVALID_SUBTYPE", "Choose orange or lemon for citrus quality.")
    elif selection.crop_slug == "tomato" and selection.task == "disease":
        if selection.subtype is not None:
            fail(422, "INVALID_SUBTYPE", "Omit subtype for tomato leaf disease.")
    else:
        fail(422, "UNSUPPORTED_SCAN", "The interim accepts tomato disease or citrus quality only.")

    query = select(ScanJob).where(ScanJob.user_id == actor.user.id, ScanJob.operation_id == idempotency_key)
    job = await db.scalar(query)
    if job is None:
        if selection.plant_id is not None:
            plant = await db.scalar(select(Plant).where(Plant.id == selection.plant_id, Plant.user_id == actor.user.id))
            if plant is None:
                fail(404, "NOT_FOUND", "Plant was not found.")
            if plant.crop_slug != selection.crop_slug:
                fail(422, "PLANT_CROP_MISMATCH", "Choose a plant matching the selected crop.")
        try:
            async with db.begin_nested():
                job = ScanJob(user_id=actor.user.id, operation_id=idempotency_key,
                              request_sha256=digest, **selection.model_dump())
                db.add(job)
                await db.flush()
        except IntegrityError:
            job = await db.scalar(query)
            if job is None:
                raise
    if job.request_sha256 != digest:
        fail(409, "IDEMPOTENCY_CONFLICT", "Use a new key after changing the photo or selections.")
    response.headers["Location"] = f"/api/v1/scans/{job.id}"
    return ScanReceipt(scan_id=job.id, status_url=response.headers["Location"])


@router.get("/{scan_id}", response_model=ScanStatus)
async def status(scan_id: UUID, actor: Owner, db: DB):
    job = await db.scalar(select(ScanJob).where(ScanJob.id == scan_id, ScanJob.user_id == actor.user.id))
    if job is None:
        fail(404, "NOT_FOUND", "Scan was not found.")
    return view(job)
