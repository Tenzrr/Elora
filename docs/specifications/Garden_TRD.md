> HISTORICAL DESIGN REFERENCE ONLY. The [finalized SRS](Elora_SRS.md) overrides this document. Do not implement conflicting auth, platform, API, model-count or output requirements below.

# Garden Technical Requirements Document

> **Legacy supporting specification.** [Elora SRS v1.0](Elora_SRS.md) and [implementation decisions](Elora_Implementation_Decisions.md) supersede conflicting content here. In particular, use Firebase identity, the consolidated scan job/abstention contract, twelve dataset-backed models, 768-dimensional embeddings and the newly confirmed reporting/owner review scope. Reconcile affected schemas/contracts before dependent implementation; this notice does not migrate code.

**Architectural Specification, AI Authority, and Integration Standards**

Version 1.0  
Prepared: 27 October 2026  
Status: Approved  

This document defines the system architecture, component boundaries, AI authority rules, data persistence, and technical Definition of Done for the **Garden** platform.

Primary Readers: Backend Engineers, Mobile Engineers, AI/ML Engineers, Infrastructure/DevOps Engineers.

---

## Executive summary

Garden is architected as a modular, vertical-slice system. A Flutter mobile client interfaces with an asynchronous FastAPI backend service, supported by a PostgreSQL 16 database utilizing `pgvector` for vector embeddings, a suite of 10 trained Convolutional Neural Network (CNN) models for computer vision tasks, and a stateful LangGraph agentic workflow for personalized agronomic intelligence.

### Locked architectural decisions

| Domain | Architecture Choice | Enforced Rule |
|---|---|---|
| **Mobile Runtime** | Flutter (Dart $\ge 3.3.0$) | No web or desktop builds; Material 3 with `GardenTheme.light()` from `mobile/lib/core/theme/app_theme.dart`. |
| **Backend Runtime** | FastAPI (Python 3.12) | Asynchronous endpoints, Pydantic v2 validation, SQLAlchemy 2.0 AsyncSession. |
| **Relational & Vector Store** | PostgreSQL 16 with `pgvector` | Managed in Docker via `pgvector/pgvector:pg16`; relational data and 1536-dim vector embeddings co-located. |
| **Computer Vision Engine** | TensorFlow/Keras, TFLite, OpenCV | All 10 models must satisfy `shared/schemas/model_contract.json`. |
| **Agentic Workflow** | LangGraph + LangChain + LangSmith | Agent logic is stateful, cyclic, and checkpointed; all tool executions route through typed backend services. |
| **Third-Party Weather** | Open-Meteo REST API | Queried asynchronously via `httpx`; cached locally to reduce network latency. |
| **API Versioning** | Explicit `/api/v1` URL prefix | Uniform JSON envelope; all errors follow `{ "error": { "code", "message", "details" } }`. |

---

## 1 Purpose, scope, and technical constraints

### 1.1 Purpose
Deliver a responsive, resilient, and verifiable platform capable of performing low-latency computer vision inferences on crop foliage/fruit and providing stateful, grounded agricultural guidance on mobile devices.

### 1.2 System boundaries
- **In Scope**:
  - Flutter mobile client for Android and iOS.
  - FastAPI backend providing authenticated endpoints under `/api/v1`.
  - 10 CNN model pipelines covering 5 crops (Tomato, Chilli, Citrus, Banana, Roses, Chrysanthemum) across disease classification and quality grading.
  - Multi-turn conversational agent with semantic retrieval via `pgvector`.
  - Open-Meteo micro-climate ingestion and farming analytics.
  - PostgreSQL schema and Alembic migration pipeline.
- **Out of Scope**:
  - Web client, browser extensions, or administrative portals.
  - Direct camera hardware sensor drivers (standard mobile OS camera APIs used).
  - External payment gateways or commerce billing systems.

### 1.3 Technical constraints
- **Offline Resilience**: The mobile app must allow browsing cached plant diaries, viewing previous diagnostic results, and queuing image uploads when offline.
- **Cold Boot Time**: API initialization must take $< 5\text{ s}$; health check `GET /health` must respond in $< 50\text{ ms}$.
- **CNN Inference Latency**: Single image model inference must terminate in $< 1200\text{ ms}$ on standard cloud instances or on-device TFLite runtimes.

---

## 2 System architecture and vertical slices

Garden is organized into five developer-owned vertical slices, coordinated through a shared infrastructure kernel:

```text
                               +-------------------------------------+
                               |         Flutter Mobile App          |
                               | (Riverpod, GoRouter, GardenTheme)   |
                               +------------------+------------------+
                                                  |
                                                  | HTTPS / JSON / Multipart
                                                  v
                               +-------------------------------------+
                               |          FastAPI Gateway            |
                               |            (/api/v1/...)            |
                               +------------------+------------------+
                                                  |
        +--------------------+--------------------+--------------------+--------------------+
        |                    |                    |                    |                    |
        v                    v                    v                    v                    v
+---------------+    +---------------+    +---------------+    +---------------+    +---------------+
|     Dev 1     |    |     Dev 2     |    |     Dev 3     |    |     Dev 4     |    |     Dev 5     |
|  Crop Health  |    |Produce Quality|    |  Predictive   |    | Agricultural  |    |  Community &  |
|   Analysis    |    |  Assessment   |    |    Farming    |    |     Agent     |    | User Accounts |
| (Tomato/Chilli|    |   (Citrus)    |    |   (Banana)    |    |    (Roses)    |    | (Chrysanth.)  |
+-------+-------+    +-------+-------+    +-------+-------+    +-------+-------+    +-------+-------+
        |                    |                    |                    |                    |
        | 4 CNNs             | 2 CNNs             | 2 CNNs + Weather   | 2 CNNs + LangGraph | 2 CNNs + Feed
        v                    v                    v                    v                    v
+---------------------------------------------------------------------------------------------------+
|                                   Shared Infrastructure Layer                                     |
|  - PostgreSQL 16 + pgvector (Tables: users, plants, assessments, embeddings, logs)                |
|  - LangSmith Tracing & Telemetry                                                                  |
|  - Open-Meteo REST Weather Service                                                                |
+---------------------------------------------------------------------------------------------------+
```

### 2.1 Ownership and dependency rules
1. **Vertical Isolation**: Feature modules (`crop_health`, `produce_quality`, `predictive_farming`, `agricultural_agent`, `community`) must not import each other's internal database models or private helper functions.
2. **Shared Kernel Exclusivity**: Only `mobile/lib/core/`, `backend/app/core/`, `backend/app/db/`, `backend/app/shared/`, and `shared/` contain cross-cutting utilities. Changes to these paths require cross-team pull request review.
3. **Cross-Feature Communication**: If Feature A requires data from Feature B (e.g., the Agricultural Agent looking up Dev 1's disease scan history), it must call the typed service layer or query the shared `plants` and `assessments` contracts.

---

## 3 Software intelligence and AI authority

### 3.1 Responsibility matrix

| Agent / Model Component | Authorized Responsibilities | Strict Prohibitions |
|---|---|---|
| **Crop CNN Models (10)** | - Classify leaf disease labels.<br>- Grade produce maturity and defects.<br>- Calculate prediction confidences and top-k distributions. | - Must not issue treatment text directly.<br>- Must not alter database state directly.<br>- Must not accept images outside assigned crop domains. |
| **LangGraph Agent** | - Coordinate multi-turn agronomic conversation.<br>- Invoke registered backend tools (weather, diagnosis lookup, plant log).<br>- Retrieve grounding context from `pgvector`. | - Must not execute raw database SQL queries.<br>- Must not bypass authentication or access other users' data.<br>- Must not invent ungrounded chemical recipes. |
| **Open-Meteo Engine** | - Ingest hourly/daily precipitation, temperature, wind, and solar radiation. | - Does not make agronomic judgements (the backend rules engine interprets weather data). |

### 3.2 Prohibited AI authority
1. **No Autonomous Database Mutation**: The AI Agent cannot perform destructive mutations (e.g., `DELETE`, user account edits) without explicit user confirmation via an interactive client prompt.
2. **Confidence Thresholding**: Predictions with confidence $< 0.60$ must be labeled as `LOW_CONFIDENCE` and cannot be treated as an authoritative diagnosis.

---

## 4 Mobile application architecture

### 4.1 Flutter structure
The mobile app is located in `mobile/lib/` and structured as:
```text
mobile/lib/
|-- core/
|   |-- models/         # Shared entity models (User, Plant, API Response)
|   |-- network/        # GardenApiClient, interceptors, auth headers
|   |-- theme/          # app_theme.dart (GardenColors, GardenTheme)
|   `-- router/         # GoRouter configuration and route definitions
|-- features/
|   |-- crop_health/          # Dev 1 (screens, providers, widgets)
|   |-- produce_quality/      # Dev 2 (screens, providers, widgets)
|   |-- predictive_farming/   # Dev 3 (screens, providers, widgets)
|   |-- agricultural_agent/   # Dev 4 (screens, providers, widgets)
|   `-- community/            # Dev 5 (screens, providers, widgets)
`-- main.dart
```

### 4.2 State management and navigation
- **State Management**: `flutter_riverpod` (v2.5.1+) provides reactive, dependency-injected state.
- **Routing**: `go_router` (v14.6.2+) manages deep linking, route guards (authentication checks), and shell routes for bottom navigation.
- **Network Client**: `http` (v1.2.2+) wrapped inside `GardenApiClient`, configured with automatic JSON deserialization, auth token injection, and timeout handling.

---

## 5 Backend application architecture

### 5.1 FastAPI structure
The backend application is located in `backend/app/` and structured as:
```text
backend/app/
|-- core/
|   |-- config.py       # Pydantic Settings (environment variables)
|   |-- security.py     # JWT encode/decode, password hashing
|   `-- exceptions.py   # Global HTTPException handlers
|-- db/
|   |-- session.py      # AsyncEngine, AsyncSessionmaker
|   |-- base.py         # SQLAlchemy declarative base
|   `-- init.sql        # Database initialization DDL with pgvector
|-- modules/
|   |-- crop_health/          # Dev 1 (router, service, schemas)
|   |-- produce_quality/      # Dev 2 (router, service, schemas)
|   |-- predictive_farming/   # Dev 3 (router, service, schemas)
|   |-- agricultural_agent/   # Dev 4 (router, service, LangGraph agent)
|   `-- community/            # Dev 5 (router, service, schemas)
|-- shared/
|   |-- models/         # Shared DB models (User, Plant, Assessment)
|   `-- schemas/        # Shared Pydantic response models
`-- main.py             # FastAPI entrypoint, router registrations, CORS
```

---

## 6 Storage and vector query architecture

### 6.1 Relational database design
Garden utilizes PostgreSQL 16. Key tables include:
- `users`: User identity, authentication credentials, and display profiles.
- `plants`: Registered user crops (linked to `crop_slug`, nickname, planting date).
- `assessments`: Unified journal for all CNN inferences (crop health diagnoses and produce quality assessments).
- `weather_snapshots`: Cached Open-Meteo forecasts indexed by geospatial grid.
- `agent_memories`: Agronomic documents, treatment guides, and past conversation insights stored with 1536-dimensional embeddings.
- `community_posts` & `community_comments`: Social interaction, discussions, and photo logs.

### 6.2 Vector embeddings & pgvector
- Extension: `CREATE EXTENSION IF NOT EXISTS vector;`
- Dimensions: 1536 (OpenAI `text-embedding-3-small` or compatible local embeddings).
- Indexing: HNSW (Hierarchical Navigable Small World) index for cosine distance searches:
  ```sql
  CREATE INDEX IF NOT EXISTS idx_agent_memories_embedding 
  ON agent_memories USING hnsw (embedding vector_cosine_ops);
  ```

---

## 7 CNN model inference and integration

### 7.1 Shared contract specification
Every model must implement the contract in `shared/schemas/model_contract.json`:

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
    "top_predictions": [
      { "label": "string", "confidence": "number 0..1" }
    ],
    "model_version": "string",
    "created_at": "ISO-8601 timestamp"
  }
}
```

### 7.2 Preprocessing and artifacts
- Images resized to standard input dimensions (e.g., $224 \times 224 \times 3$ or $256 \times 256 \times 3$).
- Normalization: Normalized to $[-1, 1]$ or $[0, 1]$ according to individual model card specifications.
- Model Storage: Trained weights (`.keras`, `.h5`, `.tflite`) are tracked via Git LFS or external artifact buckets; they must **never** be committed as raw binary blobs in ordinary Git history.

---

## 8 Agentic system architecture

### 8.1 LangGraph state workflow
The Agricultural Agent is built as a compiled `StateGraph` in `ai/agent/`:
1. **User Query Ingestion**: Ingests user message, session history, and active plant context.
2. **Intent Classification & Tool Routing**: LLM determines whether domain tools are required.
3. **Tool Execution Node**: Executes backend tools asynchronously:
   - `get_weather_advisory(lat, lon)`
   - `get_plant_history(plant_id)`
   - `get_crop_diagnostic_guide(crop_slug, disease_label)`
   - `search_agronomic_kb(query_embedding)`
4. **Synthesis Node**: Synthesizes verified tool responses with conversational context.
5. **Validation Node**: Checks output for prohibited claims or dangerous chemical prescriptions before emitting to user.

### 8.2 Observability via LangSmith
Tracing is activated via standard environment variables:
- `LANGCHAIN_TRACING_V2=true`
- `LANGCHAIN_PROJECT=garden-dev`
All agent runs, tool latency, and token consumption are recorded for evaluation and debugging.

---

## 9 Security and privacy

1. **Authentication**: JWT bearer tokens using `HS256` signed with `JWT_SECRET`. Tokens expire after 7 days; refresh flows require re-authentication.
2. **Credential Safety**: User passwords hashed using `bcrypt` ($\ge 12$ rounds). Raw credentials must never be logged or exposed.
3. **Input Validation**: All image uploads are validated for file magic numbers (JPEG/PNG only) and capped at $10\text{ MB}$ to prevent denial-of-service memory exhaustion.
4. **Environment Isolation**: Production environments reject loopback URLs, default passwords, and unconfigured secret keys.

---

## 10 Testing and verification strategy

### 10.1 Automated test suites
1. **Backend Verification**:
   ```powershell
   python -m compileall backend/app
   pytest backend/tests
   ```
2. **Infrastructure Verification**:
   ```powershell
   docker compose config --quiet
   ```
3. **Mobile Verification**:
   ```powershell
   flutter analyze
   flutter test
   ```

### 10.2 Technical Definition of Done (DoD)
A task or PR is complete only when:
1. Code compiles without errors or critical linter warnings.
2. Unit tests verify happy paths, error envelopes, and edge cases.
3. Relevant contracts in `docs/specifications/` or `shared/schemas/` are updated.
4. Changes in shared infrastructure (`mobile/lib/core/`, `backend/app/db/`, etc.) have documented backwards compatibility.
