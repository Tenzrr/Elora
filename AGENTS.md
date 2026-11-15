# Elora agent instructions

These rules apply to coding agents and contributors working in this repository.

## Product and platform

Elora is a Flutter mobile app backed by a FastAPI service. Do not create a web frontend, desktop UI, or a second mobile framework unless the project owner explicitly changes the platform decision.

## Before editing

1. Start with the [team guide](WORK_DISTRIBUTION.md) for project scope, shared rules, milestones, and links to the five developer plans. Use the [setup guide](docs/operations/DEVELOPMENT_SETUP.md) for tools, workspaces and Firebase onboarding.
2. Identify the owning developer and module for the files being changed. Read their plan and the relevant contracts before proposing changes.
3. Check the current branch and working tree.
4. Search for existing shared utilities before creating a new one.

### Specification baseline

Read `docs/specifications/Elora_SRS.md`, its source record, subordinate implementation/dataset guidance, and `docs/project-management/INTERIM_PLAN.md` before implementing a slice. The finalized SRS is immutable during repository cleanup and supersedes historical drafts, Garden specifications and prototype behaviour. Correct supporting guidance rather than rewriting its requirements. Reconcile affected schemas/migrations before feature integration. The SRS and report completion wording do not prove implementation; actual status requires PR/test/demo evidence. Six crops require twelve server models and six approved Android disease variants. Follow the SRS's provider benchmarks, 60% disease cutoff, reviewed farming estimates, speech/files, and posting XP rules.

## Architecture rules

- Mobile UI belongs under `mobile/lib/`.
- Backend routes and feature logic belong under `backend/app/`.
- AI training, preprocessing, inference, and agent orchestration belong under `ai/`.
- Cross-module schemas and constants belong under `shared/`.
- Use the shared Flutter theme in `mobile/lib/core/theme/app_theme.dart`.
- Use the shared API/model contracts. Do not invent feature-specific versions of them.
- LangChain provides tools and retrieval, LangGraph manages agent state and transitions, and LangSmith provides tracing/evaluation. Keep agent tools typed and routed through backend services.

## UI/UX design fidelity and screen authorities

All UI implementations, Flutter screens, widgets, color palettes, and interaction patterns must strictly conform to the authoritative design screens in `docs/screens/` and the official Figma project:
- **Figma Reference**: [My Garden Figma (Dev Mode)](https://www.figma.com/design/i3Jq3mO3o724r7J8JjkKLv/My-Garden?m=dev)
- **Authoritative Screen Inventory**:
  1. `docs/screens/Mobile app.png` — Home screen with user header, Level/XP progress pill (`650 / 1000 XP • Level 2`), 5 isometric garden crop blocks, and deep-green bottom navigation with raised center Scan button.
  2. `docs/screens/Block selected.png` — Selected garden block with highlighted glow and slide-up bottom sheet of plant checkup cards with condition status.
  3. `docs/screens/Plant 1 details.png` — Plant profile hero view, condition summary, and "A little care, next" horizontal care cards (Next watering, Next fertilizer).
  4. `docs/screens/Scan camera.png` — Camera viewfinder with alignment reticle, 1x zoom indicator, flash toggle, gallery upload, and camera flip.
  5. `docs/screens/Crop diagnosis results.png` — Scan diagnosis result view with sample photo, diagnosis card, symptom chips, 3-step recovery action list, and "Scan again" / "Save result" buttons.
  6. `docs/screens/Garden AI chat.png` — AI assistant conversational interface with message bubbles (cream for assistant, leaf green for user), pill input bar with camera upload, and send action.
  7. `docs/screens/Community.png` — Social community feed with "For You / Following" segmented pill tabs, "+" create post button, author cards with "+ Follow", crop tags, and engagement bar.

**Mandatory Pre-Implementation Rule for Agents**:
Before creating or editing any mobile screen or UI widget, coding agents **must inspect the matching PNG in `docs/screens/`**. Do not invent arbitrary layout, button arrangements, navigation icons, or color tokens that contradict these reference screens. When the Figma board or PNGs specify visual behavior, follow them strictly.

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
python -m pytest
```

The legacy Compose file is archived; no local Docker/database is required. Use the shared development guide and CI's disposable PostgreSQL check instead of running Compose locally. For mobile changes, run `flutter analyze` and relevant Flutter tests. If a tool is unavailable, report that clearly instead of claiming the check passed.

## Git workflow

Use a focused branch and pull request against `develop`. Do not force-push shared branches. Keep commits focused and describe contract changes explicitly.
