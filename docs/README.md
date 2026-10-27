# Garden documentation

This folder contains the canonical product specifications, architecture contracts, UI design guidelines, and system integration standards for the **Garden** crop intelligence platform.

## Structure

```text
docs/
|-- screens/                        # Authoritative UI screen PNGs from Figma
|   |-- Mobile app.png
|   |-- Block selected.png
|   |-- Plant 1 details.png
|   |-- Scan camera.png
|   |-- Crop diagnosis results.png
|   |-- Garden AI chat.png
|   `-- Community.png
|-- specifications/
|   |-- Garden_PRD.md
|   |-- Garden_TRD.md
|   |-- Garden_UI_UX_Design_Specification.md
|   |-- Garden_Backend_Schema_and_Data_Model.md
|   |-- Garden_App_Flow_and_Screen_State_Specification.md
|   `-- Garden_API_and_Integration_Contract.md
|-- operations/
|   |-- ci.md
|   `-- environments.md
|-- project-management/
|   |-- Garden_Development_Task_Table.md
|   `-- Garden_Development_Network_Plan.md
|-- architecture.md                 # Redirect reference to Garden_TRD.md
|-- api-contracts.md                # Redirect reference to Garden_API_and_Integration_Contract.md
|-- figma-foundation.md             # Redirect reference to Garden_UI_UX_Design_Specification.md
`-- model-contract.md               # Redirect reference to Garden_TRD.md and shared/schemas/
```

## Authority order for implementation

When implementing features, resolving conflicts, or planning tasks, adhere to the following strict order of precedence:

1. `specifications/Garden_PRD.md` defines product vision, scope, user stories, vertical slice requirements, and business rules.
2. `specifications/Garden_TRD.md` defines system architecture, technical constraints, AI authority boundaries, and service-level objectives.
3. `screens/*.png` defines the canonical visual composition, layout, and appearance of each primary screen (synchronized with [My Garden Figma](https://www.figma.com/design/i3Jq3mO3o724r7J8JjkKLv/My-Garden?m=dev)).
4. `specifications/Garden_UI_UX_Design_Specification.md` defines design tokens, visual language, component hierarchies, accessibility rules, and screen state contracts.
5. `specifications/Garden_Backend_Schema_and_Data_Model.md` defines stored entities, PostgreSQL/`pgvector` tables, relationships, constraints, indexes, and migrations.
6. `specifications/Garden_App_Flow_and_Screen_State_Specification.md` defines Flutter routes, screen states, navigation transitions, error recovery, and offline resilience.
7. `specifications/Garden_API_and_Integration_Contract.md` defines public endpoints under `/api/v1`, request/response schemas, error envelopes, and contract tests.
8. `shared/schemas/model_contract.json` defines the machine-enforced boundary for all 10 crop CNN models.
9. The live codebase (`mobile/`, `backend/`, `ai/`) reflects the current implementation of the authoritative specifications above.

Coding agents must open and inspect the matching PNG from `docs/screens/` before implementing or modifying any Flutter screen or component. When visual behavior in code conflicts with the PNG, adjust the code to follow the PNG and the design specification.

## Module ownership & parallel development

Garden is organized into five developer-owned vertical slices, coordinated through shared infrastructure:

- **Dev 1 (Crop Health Analysis)**: Tomato and Chilli disease and quality CNNs (4 total), `mobile/lib/features/crop_health/`, `backend/app/modules/crop_health/`.
- **Dev 2 (Produce Quality Assessment)**: Citrus disease and quality CNNs (2 total), `mobile/lib/features/produce_quality/`, `backend/app/modules/produce_quality/`.
- **Dev 3 (Predictive Farming Analytics)**: Banana disease and quality CNNs (2 total), Open-Meteo weather integration, `mobile/lib/features/predictive_farming/`, `backend/app/modules/predictive_farming/`.
- **Dev 4 (Personalized Agricultural Agent)**: Roses disease and quality CNNs (2 total), LangChain, LangGraph, LangSmith, and pgvector semantic retrieval, `mobile/lib/features/agricultural_agent/`, `backend/app/modules/agricultural_agent/`, `ai/agent/`.
- **Dev 5 (Community and User Accounts)**: Chrysanthemum disease and quality CNNs (2 total), user profiles, plant logs, community feed, `mobile/lib/features/community/`, `backend/app/modules/community/`.

### Instructions for coding agents and contributors

- **Read before editing**: Check `WORK_DISTRIBUTION.md`, `AGENTS.md`, and the relevant specification document before modifying code.
- **Never import private module code**: All cross-module interactions must proceed via the public `/api/v1` API or the shared model contract.
- **Shared kernel**: Modifications to `mobile/lib/core/`, `backend/app/core/`, `backend/app/db/`, `backend/app/shared/`, `shared/`, or `docs/` require an explicit PR documenting cross-module impact.
- **Verification**: Run `python -m compileall backend/app` and `docker compose config --quiet` before submitting backend changes.
