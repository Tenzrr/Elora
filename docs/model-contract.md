# Elora model contract direction

Follow the [finalized SRS](specifications/Elora_SRS.md), REQ-1/REQ-2, section 4.3 and BR-07/BR-08/BR-12, and the [dataset catalogue](datasets/Elora_Dataset_Catalog.md).

Six crops have twelve separately versioned server models. Six disease models additionally need approved Android variants. Use calibrated confidence, domain checks, a fixed 60% disease cutoff and separately validated quality thresholds. Unsupported outputs must abstain. Quality categories are not confidence-derived grades or shelf-life estimates.

The [assessment schema](../shared/schemas/model_contract.json) validates assessed and abstained results. Add job, manifest and synchronization schemas and fixtures as those APIs are implemented. Store model weights outside ordinary Git history.
