# Elora API direction

The [finalized SRS](specifications/Elora_SRS.md), section 4.3, owns the public API inventory. Read the [implementation guidance](specifications/Elora_Implementation_Decisions.md) before integration.

Use Firebase identity and ownership checks; common scans use `/api/v1/scans`, multipart `image`, durable jobs and explicit abstention. The SRS adds model downloads/offline-result sync, farming estimates, assistant media and community rewards. Derive exact OpenAPI/schema fixtures before implementation. Historical module-specific analyze routes are not a compatibility obligation.

The current prototype and descriptive model JSON do not implement this contract. Authentication and feature APIs remain future work after cleanup.
