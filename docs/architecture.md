# Elora architecture

The [finalized SRS](specifications/Elora_SRS.md) and [implementation guidance](specifications/Elora_Implementation_Decisions.md) define the intended architecture: Android Flutter, FastAPI, Firebase identity, PostgreSQL/pgvector, twelve server crop models plus six downloadable Android disease variants, reviewed weather rules, LangGraph tools and community records.

Respect the [module ownership](../WORK_DISTRIBUTION.md). Shared profile/plant contracts, navigation/theme, networking, migrations and validation precede feature integration. Historical Garden architecture is reference material only. Cleanup does not deploy services or implement the authentication foundation.
