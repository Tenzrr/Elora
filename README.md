# Elora

Elora is an Android-first Flutter application with a FastAPI backend for crop intelligence, farming advice, an agricultural assistant and community plant records. Five developers own vertical slices; six crops have twelve server models and approved offline Android disease variants.

## Start here

1. Read the [finalized SRS](docs/specifications/Elora_SRS.md) and its [source record](docs/specifications/Elora_SRS.source.json). Do not edit its requirements during cleanup.
2. Read [ownership](WORK_DISTRIBUTION.md), the [interim plan](docs/project-management/INTERIM_PLAN.md), and [agent instructions](AGENTS.md).
3. Use [implementation guidance](docs/specifications/Elora_Implementation_Decisions.md) and the [dataset catalogue](docs/datasets/Elora_Dataset_Catalog.md). They cannot override the SRS.
4. Follow [contribution rules](CONTRIBUTING.md). Feature PRs target `develop`.

## Repository status

Development day one is **15 November 2026**. Earlier analysis/report work is preserved. Report completion statements describe the intended submission state; the interim tracker records actual development evidence.

The October prototype and Windows application have been removed. The foundation branch adds Firebase identity, profiles/owned plants, Android navigation/localization, image helpers and isolated hosted-development database workspaces. Live service verification and billable hosting are separate gates; this is not completed individual feature work.

## Layout and intended stack

- `mobile/`: Flutter Android client, shared theme and feature modules.
- `backend/`: FastAPI, database layer and feature modules.
- `ai/`: training, preprocessing, inference, agent tools and evaluation.
- `shared/`: integration contracts; current descriptive JSON needs reconciliation.
- `docs/`: finalized requirements, design references, research and delivery plan.

The SRS selects Flutter, FastAPI, PostgreSQL/pgvector, TensorFlow/Keras and Android disease variants, Firebase identity/messaging, LangChain/LangGraph/LangSmith, Google Cloud infrastructure and Open-Meteo. Generation, embedding and speech settings require benchmark approval; no specific provider model or embedding dimension is frozen here.

## Shared development startup

Use Git, Python 3.12 and Flutter 3.47.5 / Dart 3.13.4 with Android SDK/JDK 17 (or a compatible newer JDK). **No local Docker or PostgreSQL is required.** Follow the [shared development setup guide](docs/operations/DEVELOPMENT_SETUP.md) for Supabase/Firebase, private configuration and per-developer workspaces. The finalized SRS deployment target remains unchanged; Supabase is development-only.

```powershell
python -m venv .venv
.\.venv\Scripts\python -m pip install --require-hashes -r backend/requirements.lock
# Receive your scoped development configuration; follow the setup guide.
.\.venv\Scripts\python -m uvicorn app.main:app --app-dir backend --reload
```

From `mobile/`, run `flutter pub get --enforce-lockfile` and `flutter run --dart-define-from-file=config/dev.json`. Select an Android emulator or phone. API diagnostic: `GET http://localhost:8000/health`. Missing cloud configuration produces a setup screen, not simulated data. Keep credentials out of Git.

## Checks and workflow

Run `python -m pytest` and `python -m compileall backend/app` from the root. Unit tests need no cloud credentials; disposable PostgreSQL integration runs in CI. From `mobile/`, run `flutter analyze`, `flutter test` and `flutter build apk --debug`. Report unavailable checks honestly. Python dependency sources are compiled into universal hashed lockfiles; ordinary developers install with pip and do not need uv.

Use [Tenzrr/Elora](https://github.com/Tenzrr/Elora). Integrate focused PRs into `develop`; `main` holds reviewed baselines. Do not force-push shared branches.
