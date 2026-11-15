# Elora team guide and work distribution

Elora is a mobile-first application. The client is built with Flutter/Dart in `mobile/`; the service layer is built with FastAPI/Python in `backend/`. Every developer owns a complete vertical slice: Flutter screens, FastAPI routes, database queries, and AI/model integration.

First follow the [development setup guide](docs/operations/DEVELOPMENT_SETUP.md) and open your plan below. Coding agents also follow [AGENTS.md](AGENTS.md).

The [finalized SRS](docs/specifications/Elora_SRS.md) governs scope. Use the [implementation guidance](docs/specifications/Elora_Implementation_Decisions.md), [dataset catalogue](docs/datasets/Elora_Dataset_Catalog.md), [shared API contracts](docs/api-contracts.md), and [Android guide](mobile/README.md) when building. The [interim tracker](docs/project-management/INTERIM_PLAN.md) records dates and completion evidence. Reports retain their intended submission-state wording.

| Developer | Team member | GitHub | Workspace | Android tab and plan |
|---|---|---|---|---|
| Dev 1 | Athauda K. G. | `Kavee-ginty` | `dev1` | [Scan](docs/project-management/developers/dev1-crop-health.md) |
| Dev 2 | Dulaksha Dulan | `dulakshadulan` | `dev2` | [Quality](docs/project-management/developers/dev2-produce-quality.md) |
| Dev 3 | Perera H.D.S | `Dimanya-Perera` | `dev3` | [Farming](docs/project-management/developers/dev3-predictive-farming.md) |
| Dev 4 | Herath P.H.S.N | `SadeepaNHerath` | `dev4` | [Chat](docs/project-management/developers/dev4-agricultural-agent.md) |
| Dev 5 | Sansayan K. | `sansajan3103` | `dev5` | [Community](docs/project-management/developers/dev5-community-accounts.md) |

Initial integration coordinator: Dev 1. Shared-change reviewer: Dev 3, plus affected module owners. Shared authentication/Android/database preparation is separate from individual feature delivery. Dev 3–5 train their assigned CNNs later as learning/release work; their interim evaluation focuses on their main modules.

## Delivery checkpoints

- **November 16–19, 2026.** Target about 20% of each core module through its agreed demonstrable slice. The plan tables assume access to the shared development setup and show proposed work windows, dependencies, and the critical path. Parallel rows can overlap within a developer’s workdays. Each owner decides their own implementation approach and raises blockers that change the shared dates or contracts.
- **November 20–22.** Review and integrate the individual PRs, then rehearse the group demo.
- **November 23.** Present the group demo and each developer’s own contribution. Bring a running example or recorded evidence, the related requirement IDs and PR, and the limits of what was built.
- **April 2027.** Final delivery. Exact date is pending.

## Ownership

| Developer | Module | Complete crop CNN ownership | Primary paths |
|---|---|---|---|
| Dev 1 | Crop Health Analysis | Tomato and chilli: disease + quality CNNs (4 total) | `mobile/lib/features/crop_health/`, `backend/app/modules/crop_health/`, crop model files |
| Dev 2 | Produce Quality Assessment | Citrus: disease + quality CNNs (2 total) | `mobile/lib/features/produce_quality/`, `backend/app/modules/produce_quality/`, citrus model files |
| Dev 3 | Predictive Farming Analytics | Banana: disease + quality CNNs (2 total) | `mobile/lib/features/predictive_farming/`, `backend/app/modules/predictive_farming/`, banana model files |
| Dev 4 | Personalized Agricultural Agent | Roses: disease + quality CNNs (2 total) | `mobile/lib/features/agricultural_agent/`, `backend/app/modules/agricultural_agent/`, `ai/agent/`, rose model files |
| Dev 5 | Community and User Accounts | Chrysanthemum: disease + quality CNNs (2 total) | `mobile/lib/features/community/`, `backend/app/modules/community/`, chrysanthemum model files |

No crop is split between developers. The owner of a crop trains both its disease and quality CNNs. A feature may consume another module's model through the shared model contract, but it must not import that module's private implementation.

## Shared ownership

These areas are team-owned and must be changed through a reviewed pull request:

- `mobile/lib/core/` — theme, navigation, networking, and shared mobile utilities
- `backend/app/core/`, `backend/app/db/`, and `backend/app/shared/` — configuration, sessions, migrations, and shared backend utilities
- `shared/` — API schemas, constants, and the CNN model contract
- `docs/` — architecture and integration contracts
- `docker-compose.yml`, `.env.example`, and CI configuration

If a shared change is needed, open a separate pull request and explain which modules depend on it. Do not silently change shared types inside a feature pull request.

## Branches and pull requests

Use one branch per focused change:

```text
dev1/crop-health-camera
dev2/citrus-quality-model
dev3/weather-recommendations
dev4/agent-tools
dev5/community-feed
```

Open pull requests against `develop`. Keep pull requests small enough to review. Include:

1. The user-visible or API behavior changed.
2. Any updated contract or database migration.
3. Tests or validation commands run.
4. Any dependency on another pull request.

Never push directly to `main` or `develop`.

## Integration sequence

1. Rebase or merge the latest `develop` into the feature branch.
2. Run the relevant module checks and `python -m compileall backend/app`.
3. Confirm the API still follows `docs/api-contracts.md`.
4. Confirm CNN output still follows `shared/schemas/model_contract.json`.
5. Open the pull request and request review from the owner of any shared path touched.

Integration coordination rotates weekly. The coordinator checks compatibility and CI; they do not own or rewrite another developer's module.

## Avoiding conflicts

- Keep feature code inside the module's assigned folders.
- Do not create duplicate global theme colors, API clients, database sessions, or model response types.
- Do not edit another developer's feature folder without coordinating first.
- Do not commit secrets, datasets, trained weights, or generated build folders.
- Label development fixtures clearly when a dependent API or model is unfinished. In a demo, distinguish fixture evidence from live behavior.
