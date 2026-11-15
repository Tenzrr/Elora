# Elora

Elora is an Android-first Flutter application with a FastAPI backend for crop intelligence, farming advice, an agricultural assistant and community plant records. Five developers own vertical slices; six crops have twelve server models and approved offline Android disease variants.

## Start here

1. Open the [team guide](WORK_DISTRIBUTION.md) for ownership, deadlines, and your individual development plan. Agents also read [AGENTS.md](AGENTS.md).
2. Follow the [development setup guide](docs/operations/DEVELOPMENT_SETUP.md) to install tools, submit your Android SHA-1, and verify your workspace.
3. Read the [finalized SRS](docs/specifications/Elora_SRS.md) and its [source record](docs/specifications/Elora_SRS.source.json). Use the [implementation guidance](docs/specifications/Elora_Implementation_Decisions.md) and [dataset catalogue](docs/datasets/Elora_Dataset_Catalog.md) as supporting references.
4. Follow [contribution rules](CONTRIBUTING.md). Feature PRs target `develop`.

## Repository status

Development day one is **15 November 2026**. Earlier analysis/report work is preserved. Report completion statements describe the intended submission state; the interim tracker records actual development evidence.

The foundation provides Firebase identity, profiles and owned plants, Android navigation and localization, image validation, and isolated Supabase workspaces. Each developer runs FastAPI locally. Hosted APIs and branch previews are follow-up work.

## Layout and intended stack

- `mobile/`: Flutter Android client, shared theme and feature modules.
- `backend/`: FastAPI, database layer and feature modules.
- `ai/`: training, preprocessing, inference, agent tools and evaluation.
- `shared/`: integration contracts and assessment result schema.
- `docs/`: finalized requirements, design references, research and delivery plan.

The SRS selects Flutter, FastAPI, PostgreSQL/pgvector, TensorFlow/Keras and Android disease variants, Firebase identity/messaging, LangChain/LangGraph/LangSmith, Google Cloud infrastructure and Open-Meteo. Generation, embedding and speech settings require benchmark approval; no specific provider model or embedding dimension is frozen here.

## Shared development startup

Use Git, Python 3.12 and Flutter 3.47.5 / Dart 3.13.4 with the Android SDK and JDK 17. Each developer runs FastAPI locally against Firebase and their assigned Supabase schema. **No local Docker or PostgreSQL is required.** Installation commands, private configuration and verification are in the [shared development setup guide](docs/operations/DEVELOPMENT_SETUP.md).

## Checks and workflow

Run `python -m pytest` and `python -m compileall backend/app` from the root. Unit tests need no cloud credentials; disposable PostgreSQL integration runs in CI. From `mobile/`, run `flutter analyze`, `flutter test` and `flutter build apk --debug`. Report unavailable checks honestly. Python dependency sources are compiled into universal hashed lockfiles; ordinary developers install with pip and do not need uv.

Use [Tenzrr/Elora](https://github.com/Tenzrr/Elora). Integrate focused PRs into `develop`; `main` holds reviewed baselines. Do not force-push shared branches.
