# Shared foundation API

The [finalized SRS](specifications/Elora_SRS.md) remains authoritative. OpenAPI for the implemented foundation is generated at `/openapi.json`.

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

## Interim shared scan contract

Dev 1 owns the shared upload and status API. Dev 2 owns the Quality screen. The following contract is agreed for the interim demo and awaits implementation.

| Area | Agreed behavior |
|---|---|
| Submit and read | Both screens submit to `POST /api/v1/scans` and read status or results from `GET /api/v1/scans/{id}`. Both routes require a verified Firebase user. |
| Multipart fields | Send `image`, `crop_slug`, and `task`. The Dev 1 demo uses `tomato` and `disease` with a leaf photo. The Dev 2 demo uses `citrus` and `quality` with a fruit photo. |
| Citrus subtype | Require `subtype=orange` or `subtype=lemon` for citrus quality. Omit `subtype` for tomato disease. For citrus quality, a missing or unsupported subtype returns `422` with `INVALID_SUBTYPE`. |
| Plant link | `plant_id` is optional. When supplied, it must identify a plant owned by the caller and matching `crop_slug`. |
| Image validation | Reuse the shared validator for decoded JPEG, PNG, and WebP, up to 10 MiB and 20 megapixels. The scan route returns `413` for an upload over the byte limit, `415` for unsupported formats, and `422` for corrupt images or invalid dimensions. |
| Job status | Return `202` with `scan_id` and `status_url` once a durable job is recorded. The app handles `queued`, `running`, `completed`, and `failed` and keeps the selected photo and form values available for retry. |
| Retry identity | Send a client-generated UUID in `Idempotency-Key`. Reuse it for the same upload and selections. Use a new key after changing the photo or selections. |
| Assessed result | Use the [shared assessment schema](../shared/schemas/model_contract.json). Citrus quality uses `label_id` values `fresh` and `spoiled`, displayed as **Fresh** and **Spoiled**, with prediction confidence and model version. |
| Unable to assess | Return `completed` with `outcome=unable_to_assess`, a reason, and null `label_id` and `confidence`. Show relevant guidance, such as taking a clearer photo. |
| Model and job failure | If model unavailability prevents submission, return `503` with `MODEL_UNAVAILABLE`. If an accepted job later fails, return `failed` through the status endpoint. In either case the app shows the failure and offers retry. |

Prepare shared demo fixtures for Fresh, Spoiled, unable to assess, invalid subtype, and model unavailable. Dev 2 can use labelled fixtures to demonstrate the Quality screen while Dev 1 validates the upload path and trains the tomato disease baseline.
