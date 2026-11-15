> HISTORICAL DESIGN REFERENCE ONLY. The [finalized SRS](Elora_SRS.md) overrides this document. Do not implement conflicting auth, platform, API, model-count or output requirements below.

# Garden API and Integration Contract

> **Legacy supporting specification.** [Elora SRS v1.0](Elora_SRS.md) and [implementation decisions](Elora_Implementation_Decisions.md) supersede conflicting content here. In particular, use Firebase identity, the consolidated scan job/abstention contract, twelve dataset-backed models, 768-dimensional embeddings and the newly confirmed reporting/owner review scope. Reconcile affected schemas/contracts before dependent implementation; this notice does not migrate code.

**REST Endpoints, Schemas, and Model Contract Binding**

Version 1.0  
Prepared: 27 October 2026  
Status: Approved  

This document defines the authoritative HTTP REST API contracts, request/response JSON schemas, error envelopes, and CNN model integration bindings for the **Garden** platform. All public application endpoints reside under `/api/v1`.

Primary Readers: Backend Engineers, Mobile Engineers, QA Engineers, AI/ML Engineers.

---

## 1 Purpose and authority

This document is the integration boundary between the Flutter mobile application and the FastAPI backend service. Before introducing or altering any request/response field in production code, this document and the schemas in `shared/schemas/` must be updated first.

---

## 2 API principles and conventions

- **API-001: Explicit Versioning**: All production endpoints are prefixed with `/api/v1`. Unversioned root endpoints are limited to diagnostic checks (e.g., `GET /health`).
- **API-002: Uniform Error Representation**: All HTTP $4\text{xx}$ and $5\text{xx}$ responses return an RFC-compliant JSON payload containing an `error` object with `code`, `message`, and optional `details`.
- **API-003: Stateless JWT Authentication**: Protected endpoints require standard HTTP Bearer authorization (`Authorization: Bearer <jwt_token>`).
- **API-004: Standard Timestamps**: All datetime fields are formatted as ISO-8601 strings in UTC (`YYYY-MM-DDTHH:MM:SS.sssZ`).
- **API-005: Idempotency on Critical Mutations**: Record creation and image analysis requests support optional `Idempotency-Key` headers to prevent duplicate processing on mobile retries.

---

## 3 Error contract

Every error returned by the API must conform to the following JSON structure:

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "The uploaded image file is not an acceptable format.",
    "details": {
      "field": "image",
      "allowed_types": ["image/jpeg", "image/png"]
    }
  }
}
```

### Standard error codes

| Error Code | HTTP Status | Meaning |
|---|---|---|
| `UNAUTHORIZED` | 401 | Missing, malformed, or expired JWT token. |
| `FORBIDDEN` | 403 | Authenticated user lacks permission to access the target resource. |
| `NOT_FOUND` | 404 | The requested entity (plant, post, analysis record) does not exist. |
| `VALIDATION_FAILED` | 422 | Input schema validation failed against Pydantic model. |
| `UNSUPPORTED_CROP` | 400 | The requested `crop_slug` is not supported by the invoked module. |
| `MODEL_INFERENCE_FAILED` | 502 | The underlying CNN model execution encountered a fatal error. |
| `RATE_LIMITED` | 429 | Request threshold exceeded. |
| `INTERNAL_ERROR` | 500 | Unhandled server exception. |

---

## 4 Complete endpoint inventory

### 4.1 System endpoints

#### `GET /health`
Service health check (unauthenticated).
- **Response `200 OK`**:
  ```json
  {
    "status": "ok",
    "service": "garden-api"
  }
  ```

#### `GET /api/v1`
API version and documentation metadata (unauthenticated).
- **Response `200 OK`**:
  ```json
  {
    "version": "v1",
    "docs": "/docs"
  }
  ```

---

### 4.2 Authentication & User Profiles

#### `POST /api/v1/auth/register`
Register a new user account.
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "SecurePassword123!",
    "display_name": "Maria Silva"
  }
  ```
- **Response `201 Created`**:
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "email": "user@example.com",
      "display_name": "Maria Silva"
    }
  }
  ```

#### `POST /api/v1/auth/login`
Authenticate with email and password.
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "SecurePassword123!"
  }
  ```
- **Response `200 OK`**: Returns token and user payload identical to register.

#### `GET /api/v1/profile`
Retrieve current authenticated user profile.
- **Headers**: `Authorization: Bearer <token>`
- **Response `200 OK`**: Returns user profile object.

---

### 4.3 Plant management and diary

#### `GET /api/v1/plants`
List all plants owned by authenticated user.
- **Response `200 OK`**: Array of plant objects.

#### `POST /api/v1/plants`
Register a new plant in user's garden.
- **Request Body**:
  ```json
  {
    "crop_slug": "tomato",
    "nickname": "Balcony Cherry Tomato",
    "variety": "Sweet 100",
    "location_description": "South-facing balcony",
    "planted_at": "2026-09-15"
  }
  ```
- **Response `201 Created`**: Created plant object.

#### `POST /api/v1/plants/{plant_id}/logs`
Add an activity log entry or photo note to a plant.
- **Request Body**:
  ```json
  {
    "log_type": "watering",
    "content": "Deep soak after 2 sunny days.",
    "image_url": null
  }
  ```
- **Response `201 Created`**: Created log record.

---

### 4.4 Crop Health Analysis (Dev 1 — Tomato & Chilli)

#### `POST /api/v1/crop-health/analyze`
Analyze a captured leaf image for disease diagnosis.
- **Content-Type**: `multipart/form-data`
- **Form Fields**:
  - `image`: Binary file (JPEG/PNG, $\le 10\text{ MB}$)
  - `crop_slug`: String (`tomato` or `chilli`)
  - `plant_id`: Optional UUID string
- **Response `200 OK`**:
  ```json
  {
    "session_id": "8f8b82a1-bf3d-4c57-8be6-5789fcfda21a",
    "crop_slug": "tomato",
    "task": "disease",
    "label": "Early Blight",
    "botanical_pathogen": "Alternaria solani",
    "confidence": 0.942,
    "severity_level": "moderate",
    "top_predictions": [
      { "label": "Early Blight", "confidence": 0.942 },
      { "label": "Septoria Leaf Spot", "confidence": 0.041 },
      { "label": "Healthy", "confidence": 0.017 }
    ],
    "organic_remedy": "Prune infected lower foliage immediately. Apply bio-fungicide containing Bacillus subtilis or organic neem oil spray.",
    "chemical_remedy": "Apply copper-based fungicide according to label directions. Ensure full leaf coverage.",
    "preventive_measures": "Avoid overhead watering; maintain adequate air circulation between plants.",
    "model_version": "tomato-disease-v1.2",
    "created_at": "2026-10-27T10:30:00.000Z"
  }
  ```

#### `GET /api/v1/crop-health/history`
Retrieve historical disease diagnoses for authenticated user.
- **Query Params**: `crop_slug` (optional), `limit` (default 20), `offset` (default 0)
- **Response `200 OK`**: List of previous scan summaries.

---

### 4.5 Produce Quality Assessment (Dev 2 — Citrus)

#### `POST /api/v1/produce-quality/analyze`
Grade produce ripeness, surface defects, and harvest readiness for Citrus crops.
- **Content-Type**: `multipart/form-data`
- **Form Fields**:
  - `image`: Binary file (JPEG/PNG)
  - `crop_slug`: String (`citrus`)
  - `plant_id`: Optional UUID string
- **Response `200 OK`**:
  ```json
  {
    "session_id": "9b1c7a22-4821-4d32-9cb4-81d76a211903",
    "crop_slug": "citrus",
    "task": "quality",
    "quality_grade": "Grade A",
    "ripeness_index": 0.885,
    "defect_percentage": 3.5,
    "confidence": 0.918,
    "top_predictions": [
      { "label": "Grade A", "confidence": 0.918 },
      { "label": "Grade B", "confidence": 0.062 },
      { "label": "Grade C", "confidence": 0.020 }
    ],
    "shelf_life_days": 14,
    "harvest_recommendation": "Fruit has reached optimal sugar-acid balance. Recommend harvest within 3 to 5 days.",
    "model_version": "citrus-quality-v1.0",
    "created_at": "2026-10-27T10:35:00.000Z"
  }
  ```

---

### 4.6 Predictive Farming Analytics (Dev 3 — Banana)

#### `GET /api/v1/predictive-farming/weather`
Retrieve hyper-local micro-climate forecast from Open-Meteo.
- **Query Params**: `lat` (float, required), `lon` (float, required)
- **Response `200 OK`**:
  ```json
  {
    "latitude": 6.9271,
    "longitude": 79.8612,
    "current": {
      "temperature_c": 29.4,
      "relative_humidity": 78,
      "precipitation_mm": 0.0,
      "weather_code": 1
    },
    "daily_forecast": [
      {
        "date": "2026-10-28",
        "temp_max_c": 31.0,
        "temp_min_c": 25.2,
        "precipitation_sum_mm": 18.5,
        "precipitation_probability": 85
      }
    ]
  }
  ```

#### `GET /api/v1/predictive-farming/recommendations`
Generate predictive farming advisories for crops (Banana focus).
- **Query Params**: `plant_id` (UUID, required), `lat` (float), `lon` (float)
- **Response `200 OK`**:
  ```json
  {
    "plant_id": "1a2b3c4d-...",
    "crop_slug": "banana",
    "advisory_type": "irrigation",
    "action": "DELAY_WATERING",
    "reason": "18.5mm rainfall forecasted within 24 hours. Postponing irrigation prevents soil waterlogging and root hypoxia.",
    "next_scheduled_action": "2026-10-30T08:00:00Z"
  }
  ```

#### `POST /api/v1/predictive-farming/banana/analyze`
Banana leaf disease classification and bunch quality grading matching the shared model contract.

---

### 4.7 Personalized Agricultural Agent (Dev 4 — Roses)

#### `POST /api/v1/agricultural-agent/chat`
Submit a message to the LangGraph Agricultural Assistant.
- **Request Body**:
  ```json
  {
    "thread_id": "5f6e7d8c-...",
    "plant_id": "optional-uuid-context",
    "message": "My rose petals have black spots and are curling. What should I do?"
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "thread_id": "5f6e7d8c-...",
    "response": "Based on your description and your registered Red Rose, this resembles Black Spot (Diplocarpon rosae). I have cross-checked your recent weather (high humidity) which accelerates fungal sporulation. Here are immediate steps:\n1. Prune all infected foliage and discard (do not compost).\n2. Spray with sulfur or neem-based organic fungicide in the cool evening.",
    "tools_executed": [
      { "name": "get_plant_history", "duration_ms": 42 },
      { "name": "search_agronomic_kb", "duration_ms": 115 }
    ],
    "created_at": "2026-10-27T10:40:00.000Z"
  }
  ```

#### `POST /api/v1/agricultural-agent/roses/analyze`
Rose disease and bloom quality grading matching the shared model contract.

---

### 4.8 Community and User Accounts (Dev 5 — Chrysanthemum)

#### `GET /api/v1/community/feed`
Fetch public community feed.
- **Query Params**: `crop_slug` (optional filter), `limit` (default 20), `offset` (default 0)
- **Response `200 OK`**:
  ```json
  {
    "posts": [
      {
        "id": "e4f5a6b7-...",
        "author": {
          "id": "user-uuid",
          "display_name": "Kamal Perera",
          "avatar_url": null
        },
        "crop_slug": "chrysanthemum",
        "title": "Autumn Chrysanthemum blooming successfully!",
        "content": "Used baking soda spray early for white rust and it cleared right up.",
        "image_url": "https://storage.garden.app/posts/image1.jpg",
        "likes_count": 12,
        "comments_count": 3,
        "created_at": "2026-10-27T08:15:00.000Z"
      }
    ],
    "total": 45
  }
  ```

#### `POST /api/v1/community/posts`
Create a new community post.
- **Request Body**:
  ```json
  {
    "crop_slug": "chrysanthemum",
    "title": "Autumn Chrysanthemum blooming successfully!",
    "content": "Used baking soda spray early for white rust...",
    "image_url": "https://storage.garden.app/posts/image1.jpg"
  }
  ```
- **Response `201 Created`**: Created post object.

#### `POST /api/v1/community/chrysanthemum/analyze`
Chrysanthemum disease and quality assessment matching the shared model contract.

---

## 5 Model contract binding

The computer vision analysis endpoints (`/crop-health/analyze`, `/produce-quality/analyze`, etc.) strictly wrap the low-level inference schema defined in `shared/schemas/model_contract.json`:

```json
{
  "contract_version": "1.0",
  "request": {
    "image_uri": "string",
    "crop_slug": "tomato|chilli|citrus|banana|roses|chrysanthemum",
    "model_task": "disease|quality",
    "model_version": "string"
  },
  "response": {
    "crop_slug": "string",
    "task": "disease|quality",
    "label": "string",
    "confidence": "number 0..1",
    "top_predictions": [{"label": "string", "confidence": "number 0..1"}],
    "model_version": "string",
    "created_at": "ISO-8601 timestamp"
  }
}
```

The FastAPI router maps the uploaded file to an internal temporary URI or memory buffer, invokes the owner's trained model pipeline, validates the output against `model_contract.json`, decorates the response with agronomic recommendations from the database, and returns the response to the client.

---

## 6 Contract testing strategy

All endpoints are validated through automated integration tests located in `backend/tests/`:
1. **Schema Integrity**: Pydantic models automatically validate incoming requests and outgoing responses against OpenAPI v3 specifications.
2. **Error Envelope Verification**: Every endpoint is tested for $401$ (unauthorized), $422$ (invalid payload), and $404$ (missing entity) to guarantee the unified `{ error: { code, message, details } }` format is returned.
3. **Model Contract Compliance**: Test fixtures verify that mock inference responses validate against `shared/schemas/model_contract.json`.
