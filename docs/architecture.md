# Elora architecture

The application is split into five vertical slices. Each slice owns its Flutter screens, FastAPI routes, database queries, and AI integration. Shared infrastructure stays deliberately small: authentication, database session management, API schemas, model contracts, theme tokens, and observability.

## Feature ownership

| Developer | Module | Complete crop ownership |
|---|---|---|
| Dev 1 | Crop Health Analysis | Tomato and chilli: disease + quality CNNs (4 total) |
| Dev 2 | Produce Quality Assessment | Citrus: disease + quality CNNs (2 total) |
| Dev 3 | Predictive Farming Analytics | Banana: disease + quality CNNs (2 total) |
| Dev 4 | Personalized Agricultural Agent | Roses: disease + quality CNNs (2 total) |
| Dev 5 | Community and User Accounts | Chrysanthemum: disease + quality CNNs (2 total) |

Model ownership stays with the crop owner. A feature may call another developer's model through the shared model contract rather than importing private module code.

## Agentic AI boundary

LangChain provides tools and retrievers, LangGraph owns the stateful workflow, and LangSmith provides tracing and evaluation. The agent must call backend tools through typed functions; it should not access database tables directly.
