from dataclasses import dataclass
from functools import lru_cache

import firebase_admin
from firebase_admin import auth, credentials as firebase_credentials
from fastapi import Depends, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.concurrency import run_in_threadpool

from app.core.errors import fail
from app.db.models import User
from app.db.session import get_db

bearer = HTTPBearer(auto_error=False)


@lru_cache
def firebase_app(project_id: str, credential_path: str | None = None):
    # ADC on Cloud Run; scoped development credentials locally. No credential file in Git.
    credential = firebase_credentials.Certificate(credential_path) if credential_path else None
    return firebase_admin.initialize_app(credential, options={"projectId": project_id}, name=project_id)


async def verify_identity(
    request: Request,
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer),
):
    if credentials is None or credentials.scheme.lower() != "bearer":
        fail(401, "UNAUTHORIZED", "Sign in to continue.")
    project = request.app.state.settings.firebase_project_id
    if not project:
        fail(503, "SERVICE_UNAVAILABLE", "Firebase configuration is not available.")
    try:
        return await run_in_threadpool(
            auth.verify_id_token,
            credentials.credentials,
            app=firebase_app(project, request.app.state.settings.google_application_credentials),
            check_revoked=True,
        )
    except (auth.ExpiredIdTokenError, auth.RevokedIdTokenError, auth.InvalidIdTokenError,
            auth.UserDisabledError, auth.UserNotFoundError, ValueError):
        fail(401, "UNAUTHORIZED", "Your session is invalid or expired. Sign in again.")
    except Exception:
        # Never expose credential errors, tokens or provider responses.
        fail(503, "SERVICE_UNAVAILABLE", "Identity verification is temporarily unavailable.")


@dataclass
class Actor:
    user: User
    verified: bool


async def current_actor(identity=Depends(verify_identity), db: AsyncSession = Depends(get_db, scope="function")):
    user = await db.scalar(select(User).where(User.firebase_uid == identity["uid"]))
    if user is None:
        fail(401, "SESSION_REQUIRED", "Initialize your session first.")
    if not user.active:
        fail(403, "ACCOUNT_INACTIVE", "This account is not active.")
    return Actor(user=user, verified=identity.get("email_verified") is True)


async def verified_actor(actor: Actor = Depends(current_actor, scope="function")):
    """Use for scanning, posting and paid-AI routes as they are implemented."""
    if not actor.verified:
        fail(403, "EMAIL_NOT_VERIFIED", "Verify your email before using this feature.")
    return actor
