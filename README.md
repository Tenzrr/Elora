# Elora

Elora is an Android-first Flutter application with a FastAPI backend for crop intelligence, farming advice, an agricultural assistant and community plant records. Five developers own vertical slices; six crops have twelve server models and approved offline Android disease variants.

## Start here

1. Read the [finalized SRS](docs/specifications/Elora_SRS.md) and its [source record](docs/specifications/Elora_SRS.source.json). Do not edit its requirements during cleanup.
2. Read [ownership](WORK_DISTRIBUTION.md), the [interim plan](docs/project-management/INTERIM_PLAN.md), and [agent instructions](AGENTS.md).
3. Use [implementation guidance](docs/specifications/Elora_Implementation_Decisions.md) and the [dataset catalogue](docs/datasets/Elora_Dataset_Catalog.md). They cannot override the SRS.
4. Follow [contribution rules](CONTRIBUTING.md). Feature PRs target `develop`.

## Repository status

Development day one is **15 November 2026**. Earlier analysis/report work is preserved. Report completion statements describe the intended submission state; the interim tracker records actual development evidence.

The October crop-health prototype, simulated predictions and Windows application have been removed. The app and API now provide neutral startup scaffolds. Authentication, shared hosting and the developer foundation follow cleanup; they are not implemented here.

## Layout and intended stack

- `mobile/`: Flutter Android client, shared theme and feature modules.
- `backend/`: FastAPI, database layer and feature modules.
- `ai/`: training, preprocessing, inference, agent tools and evaluation.
- `shared/`: integration contracts; current descriptive JSON needs reconciliation.
- `docs/`: finalized requirements, design references, research and delivery plan.

The SRS selects Flutter, FastAPI, PostgreSQL/pgvector, TensorFlow/Keras and Android disease variants, Firebase identity/messaging, LangChain/LangGraph/LangSmith, Google Cloud infrastructure and Open-Meteo. Generation, embedding and speech settings require benchmark approval; no specific provider model or embedding dimension is frozen here.

## Current scaffold startup

Use Python 3.12, Flutter 3.47.5 / Dart 3.13.4, Android SDK/JDK 17 (or a compatible newer JDK) and Docker Compose. This starts the scaffold, not the finalized feature system.

```powershell
python -m venv .venv
.\.venv\Scripts\python -m pip install -r backend/requirements.txt
Copy-Item .env.example .env
docker compose up -d db
.\.venv\Scripts\python -m uvicorn app.main:app --app-dir backend --reload
```

From `mobile/`, run `flutter pub get` and `flutter run`, selecting an Android emulator or phone. API diagnostic: `GET http://localhost:8000/health`. Environment loading and Firebase are subsequent foundation work; keep credentials out of Git.

## Checks and workflow

Install test dependencies with `python -m pip install -r backend/requirements-dev.txt`, then run `python -m pytest` from the repository root. Run `python -m compileall backend/app` and `docker compose config --quiet`. From `mobile/`, run `flutter analyze`, `flutter test` and `flutter build apk --debug`. CI runs these scaffold checks; report unavailable checks honestly.

Use [Tenzrr/Elora](https://github.com/Tenzrr/Elora). Integrate focused PRs into `develop`; `main` holds reviewed baselines. Do not force-push shared branches.
