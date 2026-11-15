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
