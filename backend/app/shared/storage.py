from datetime import timedelta
from uuid import UUID, uuid4

from google.cloud import storage

from app.core.errors import fail


def store_image(bucket_name: str, owner_id: str, data: bytes):
    """Backend-only utility: call after authentication, ownership checks and image validation."""
    owner = str(UUID(owner_id))
    if not bucket_name:
        fail(503, "SERVICE_UNAVAILABLE", "Image storage has not been configured.")
    key = f"private/{owner}/{uuid4()}.jpg"
    blob = storage.Client().bucket(bucket_name).blob(key)
    blob.upload_from_string(data, content_type="image/jpeg", if_generation_match=0)
    return key


def signed_image_url(bucket_name: str, owner_id: str, key: str, *, service_account_email=None, access_token=None):
    owner = str(UUID(owner_id))
    if not key.startswith(f"private/{owner}/") or ".." in key:
        fail(404, "NOT_FOUND", "Image was not found.")
    blob = storage.Client().bucket(bucket_name).blob(key)
    return blob.generate_signed_url(
        version="v4", expiration=timedelta(minutes=15), method="GET",
        service_account_email=service_account_email, access_token=access_token,
    )
