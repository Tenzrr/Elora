# Shared foundation API

The [finalized SRS](specifications/Elora_SRS.md) remains authoritative. This document defines the implemented foundation subset. OpenAPI is generated at `/openapi.json`; no model inference, community, weather or assistant endpoints are implemented here.

| Route | Contract |
|---|---|
| GET /health | Public process diagnostic; no credentials or database details |
| POST /api/v1/session | Firebase bearer token; idempotently create/find the profile by Firebase UID; no caller-supplied UID/email |
| GET /api/v1/profile | Current active account profile |
| PATCH /api/v1/profile | display_name, language (en/si/ta), interests (six supported crop slugs); unknown/null fields rejected |
| GET /api/v1/plants | Owned items only; UUID cursor; limit default 20, maximum 100; items and next_cursor |
| POST /api/v1/plants | crop_slug and growing_area required; nickname, planted_at and notes optional; 201 response |
| GET /api/v1/plants/{id} | Owned plant or 404; ETag contains quoted revision |
| PATCH /api/v1/plants/{id} | Owned record and If-Match revision required; atomic update increments revision |
| DELETE /api/v1/plants/{id} | Owned record and If-Match revision required; 204 |
| GET /api/v1/readiness | Authenticated active profile; database check; no public configuration disclosure |

IDs are UUIDs. Crop slugs: tomato, chilli, citrus, banana, roses, chrysanthemum. Profiles expose id, email, display_name, language, interests and created_at, not passwords or Firebase admin credentials. Plants expose id, user_id, crop_slug, growing_area, nickname, planted_at, notes, revision and created_at. Growing area is a grower-entered location/area description; exact volume/soil inference is not implied.

Every request verifies Firebase identity with revocation checks and checks active status. Helpers for verified-email-only scan/post/paid-AI actions are supplied for future modules. Profile/plant setup is not a paid/scan/post action. Only verified users enter the current Android workspace.

Errors use `{"error":{"code":"...","message":"...","details":null}}` and X-Request-ID. 401 is invalid/missing identity, 403 inactive/unverified restricted access, 404 unavailable/not-owned, 409 revision/data conflict, 422 invalid input, 428 missing If-Match, 503 missing/unavailable service configuration. Validation details omit submitted values. No token, body, database URL or provider error appears in API logs.

Example If-Match: `"1"`. A stale update/delete returns 409 and must reload; never silently overwrite. Mobile automatically refreshes/replays only reads. Unknown-outcome writes require checking current state before another attempt.

Shared scan result validation is in [model_contract.json](../shared/schemas/model_contract.json). It is not a working scan API. Feature owners implement the rest of the SRS route inventory through reviewed contracts.

## Interim shared scan contract — issue #44

This contract is a prerequisite for the #44 implementation; merging this
document alone does not implement the endpoints below. It records the Dev 1/Dev 2
agreement from commit `5c72db8`, with an explicit interim persistence boundary.
Dev 1 owns the API; Dev 2 consumes it for Quality.
The SRS remains the full release contract. The assessment schema is unchanged.

| Area | Contract |
|---|---|
| Submit | `POST /api/v1/scans`, verified active Firebase user; required UUID `Idempotency-Key` header |
| Multipart | Exactly one `image`, `crop_slug`, `task`; optional `plant_id`, `subtype`; unknown/duplicate fields rejected |
| Interim selections | `tomato` / `disease`: leaf photo, omit subtype. `citrus` / `quality`: fruit photo, require `orange` or `lemon`; otherwise `422 INVALID_SUBTYPE`. Other valid crop/task combinations return `422 UNSUPPORTED_SCAN`. |
| Plant | Optional owned UUID matching crop; unavailable/not-owned `404`, mismatching crop `422 PLANT_CROP_MISMATCH` |
| Image | Shared safe decoder: JPEG/PNG/WebP, at most 10 MiB / 20 megapixels; orientation corrected and metadata stripped during validation. Oversize `413 IMAGE_TOO_LARGE`, unsupported format `415 UNSUPPORTED_MEDIA_TYPE`, empty/corrupt/animated/oversize dimensions `422 INVALID_IMAGE`. Multipart envelope is bounded to 10 MiB + 64 KiB; each text field at most 1 KiB. MIME and filename are untrusted. |
| Receipt | `202 {"scan_id":"<uuid>","status_url":"/api/v1/scans/<uuid>"}` plus `Location`, only after transaction commit succeeds |
| Retry | Same owner/key and identical image bytes + canonical selections return the same receipt. Different content returns `409 IDEMPOTENCY_CONFLICT`. Multipart boundaries and filenames are excluded from identity. |
| Read | `GET /api/v1/scans/{id}`: verified active owner only; other owners and unknown IDs return `404`. Schema: [scan_job.json](../shared/schemas/scan_job.json). |
| Actual interim status | The upload receipt, owner, digest, selections, timestamp and terminal `failed` / `MODEL_UNAVAILABLE` state persist in PostgreSQL. `result=null`, `image_retained=false`. Image bytes are discarded after validation. No worker, inference, saved diagnosis or cloud image storage is claimed. The record remains readable after an API restart. |
| Mobile | Keep photo/selections/retry key after errors; reuse the key on manual retry. New photo/selections use a new UUID. Poll `queued`/`running` at 2–10 seconds and resume in foreground; terminal failures stop polling. No automatic write replay. |

Acceptance records a terminal failure immediately because no model is connected;
it does not leave a job misleadingly queued. If a future deployment refuses
submission before recording a job, return `503 MODEL_UNAVAILABLE` instead.
Durable asynchronous execution/private media belongs to #53/#54. A future
completed result must follow `model_contract.json`, including null label and
confidence with an `unable_to_assess` reason. Model absence is a job failure,
not a fabricated assessment or abstention with an invented model version.

Dev 2 may develop Fresh, Spoiled and unable-to-assess screens using visibly
labelled fixtures; this API currently produces none of those results. Citrus
quality's agreed future labels are `fresh` and `spoiled`. Human review by Dev 3
and Dev 2 is required before integration of this shared contract.
