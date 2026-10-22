# API contracts

All public endpoints are under `/api/v1`. Responses use JSON and return an `error` object with `code`, `message`, and optional `details` when a request fails.

## Current system endpoints

- `GET /health` — service health check
- `GET /api/v1` — API version information

## Feature endpoint conventions

- `POST /api/v1/{module}/analyze` for image analysis
- `GET /api/v1/{module}/history` for authenticated history
- `POST /api/v1/{module}/records` for user-created records
- `GET /api/v1/{module}/recommendations` for AI recommendations

Before changing a request or response field, update the matching schema under `shared/schemas/` and add an example payload to the pull request.
