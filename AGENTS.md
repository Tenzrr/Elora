# Elora agent instructions

These rules apply to coding agents and contributors working in this repository.

## Product and platform

Elora is a Flutter mobile app backed by a FastAPI service. Do not create a web frontend, desktop UI, or a second mobile framework unless the project owner explicitly changes the platform decision.

## Before editing

1. Read `README.md`, `WORK_DISTRIBUTION.md`, and the relevant file under `docs/`.
2. Identify the owning developer and module for the files being changed.
3. Check the current branch and working tree.
4. Search for existing shared utilities before creating a new one.

## Architecture rules

- Mobile UI belongs under `mobile/lib/`.
- Backend routes and feature logic belong under `backend/app/`.
- AI training, preprocessing, inference, and agent orchestration belong under `ai/`.
- Cross-module schemas and constants belong under `shared/`.
- Use the shared Flutter theme in `mobile/lib/core/theme/app_theme.dart`.
- Use the shared API/model contracts. Do not invent feature-specific versions of them.
- LangChain provides tools and retrieval, LangGraph manages agent state and transitions, and LangSmith provides tracing/evaluation. Keep agent tools typed and routed through backend services.

## Ownership and conflict prevention

- Change only the assigned module unless the task explicitly requires a shared change.
- Treat `mobile/lib/core/`, `backend/app/core/`, `backend/app/db/`, `backend/app/shared/`, `shared/`, `docs/`, CI, and Docker files as shared infrastructure.
- For shared infrastructure, make the smallest compatible change and document the impact in the pull request.
- Never import private code from another feature module. Call its API or use the shared contract.
- Do not move, rename, or reformat unrelated files.
- Do not overwrite another contributor's uncommitted work.

## CNN rules

Each crop owner trains both CNNs assigned to that crop. Every model must provide metadata, label maps, preprocessing details, evaluation metrics, and a versioned inference response matching `shared/schemas/model_contract.json`.

Do not commit large model weights or raw datasets to ordinary Git history. Store them through the team's agreed artifact storage or Git LFS.

## API and database rules

- Public endpoints use the `/api/v1` prefix.
- Update `docs/api-contracts.md` and the relevant schema before changing a public request or response.
- Database changes require a migration or an explicitly reviewed initialization change.
- Never put API keys or passwords in source files.

## Verification

Before submitting a change, run the smallest relevant checks. For backend changes, run:

```powershell
python -m compileall backend/app
docker compose config --quiet
```

For mobile changes, run `flutter analyze` and the relevant Flutter tests when Flutter is installed. If a tool is unavailable, report that clearly instead of claiming the check passed.

## Git workflow

Use a focused branch and pull request against `develop`. Do not force-push shared branches. Keep commits focused and describe contract changes explicitly.
