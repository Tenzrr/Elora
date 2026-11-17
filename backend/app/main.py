import logging
from contextlib import asynccontextmanager
from uuid import UUID, uuid4

from fastapi import Depends, FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.exceptions import HTTPException

from app.core.auth import current_actor
from app.core.config import Settings, get_settings
from app.db.session import get_db, make_engine
from app.modules.agricultural_agent.router import router as agricultural_agent_router
from app.shared.router import router

logger = logging.getLogger("elora")


def create_app(settings: Settings | None = None, engine=None):
    settings = settings or get_settings()

    @asynccontextmanager
    async def lifespan(app):
        app.state.engine = engine
        if engine is None and settings.database_url:
            app.state.engine = make_engine(settings)
        try:
            yield
        finally:
            if engine is None and app.state.engine is not None:
                await app.state.engine.dispose()

    app = FastAPI(title="Elora API", version="0.2.0", lifespan=lifespan)
    app.state.settings = settings
    app.state.engine = engine

    @app.middleware("http")
    async def request_context(request: Request, call_next):
        try:
            request_id = str(UUID(request.headers.get("X-Request-ID", "")))
        except ValueError:
            request_id = str(uuid4())
        request.state.request_id = request_id
        try:
            response = await call_next(request)
        except Exception as exc:
            logger.error("request_failed id=%s type=%s", request_id, type(exc).__name__)
            response = JSONResponse(
                {"error": {"code": "INTERNAL_ERROR", "message": "The request could not be completed.", "details": None}},
                status_code=500,
            )
        response.headers["X-Request-ID"] = request_id
        logger.info("request id=%s method=%s status=%s", request_id, request.method, response.status_code)
        return response

    @app.exception_handler(HTTPException)
    async def http_error(request, exc):
        detail = exc.detail if isinstance(exc.detail, dict) else {
            "code": "NOT_FOUND" if exc.status_code == 404 else "REQUEST_FAILED",
            "message": "Resource was not found." if exc.status_code == 404 else str(exc.detail),
            "details": None,
        }
        return JSONResponse({"error": detail}, status_code=exc.status_code, headers=exc.headers)

    @app.exception_handler(RequestValidationError)
    async def input_error(request, exc):
        details = [{"field": ".".join(map(str, e["loc"])), "type": e["type"]} for e in exc.errors()]
        return JSONResponse(
            {"error": {"code": "INVALID_INPUT", "message": "Check the supplied fields.", "details": details}},
            status_code=422,
        )

    @app.exception_handler(SQLAlchemyError)
    async def database_error(request, exc):
        conflict = isinstance(exc, IntegrityError)
        return JSONResponse({"error": {
            "code": "CONFLICT" if conflict else "SERVICE_UNAVAILABLE",
            "message": "The change conflicts with existing data." if conflict else "Database is temporarily unavailable.",
            "details": None,
        }}, status_code=409 if conflict else 503)

    @app.get("/health", tags=["system"])
    async def health():
        return {"status": "ok", "service": "elora-api"}

    @app.get("/api/v1/readiness", tags=["system"], dependencies=[Depends(current_actor, scope="function")])
    async def readiness(db: AsyncSession = Depends(get_db, scope="function")):
        await db.execute(text("SELECT 1"))
        return {"status": "ready"}

    app.include_router(router)
    app.include_router(agricultural_agent_router)
    return app


app = create_app()
