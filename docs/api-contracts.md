# Garden API Contracts

> **Notice: Specification Migrated**  
> This contract has been migrated to the authoritative API specification:  
> 👉 [Garden API and Integration Contract (Garden_API_and_Integration_Contract.md)](specifications/Garden_API_and_Integration_Contract.md)

---

## Summary

All public endpoints are served under `/api/v1`. Responses use JSON and return a standard `error` object (`{ "error": { "code", "message", "details" } }`) on failure.

### Core endpoint inventory

- **System**:
  - `GET /health` — Service health check
  - `GET /api/v1` — API version and info
- **Crop Health (Dev 1)**:
  - `POST /api/v1/crop-health/analyze` — Tomato and Chilli leaf disease detection
  - `GET /api/v1/crop-health/history` — User diagnostic history
- **Produce Quality (Dev 2)**:
  - `POST /api/v1/produce-quality/analyze` — Citrus quality and ripeness grading
- **Predictive Farming (Dev 3)**:
  - `GET /api/v1/predictive-farming/weather` — Micro-climate weather forecast
  - `GET /api/v1/predictive-farming/recommendations` — Irrigation and farming advisories
- **Agricultural Agent (Dev 4)**:
  - `POST /api/v1/agricultural-agent/chat` — LangGraph agent chat endpoint
- **Community (Dev 5)**:
  - `GET /api/v1/community/feed` — Community feed
  - `POST /api/v1/community/posts` — Share garden updates

For detailed request/response schemas, status codes, and headers, see [specifications/Garden_API_and_Integration_Contract.md](specifications/Garden_API_and_Integration_Contract.md).
