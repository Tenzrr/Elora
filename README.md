# Elora

Elora is a Flutter mobile app with a FastAPI backend for crop intelligence. This repository is organised so each developer can own a complete vertical slice: mobile UI, API/database work, and AI/model integration. Read `WORK_DISTRIBUTION.md` before starting work and `AGENTS.md` when using an AI coding agent.

## Stack

- Flutter/Dart mobile client
- FastAPI/Python backend
- PostgreSQL with `pgvector`
- TensorFlow/Keras, TensorFlow Lite, and OpenCV for computer vision
- Gemini or OpenAI for conversational AI
- LangChain for tools and retrieval
- LangGraph for stateful agent workflows
- LangSmith for tracing and evaluation
- Open-Meteo for weather data

## Repository layout

```text
mobile/       Flutter app, shared theme, networking, and feature slices
backend/      FastAPI app, database layer, and feature modules
ai/           CNN training/inference, preprocessing, agents, and evaluation
shared/       API/model contracts shared across services
docs/         architecture, contribution, UI, and integration contracts
```

## Local setup

1. Copy `.env.example` to `.env` and fill in local values.
2. Start PostgreSQL and pgvector with `docker compose up -d db`.
3. Run the API from `backend/` with `uvicorn app.main:app --reload`.
4. Run the Flutter app from `mobile/` with `flutter run`.

The GitHub remote is configured as `https://github.com/Tenzrr/Elora.git`.

## Parallel development rule

Developers work in feature branches and merge small pull requests into `develop`. The contracts in `docs/` and `shared/` are the integration boundary; update them before changing a public API or model output.
