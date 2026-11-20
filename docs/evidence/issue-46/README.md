# Issue 46 — interim crop-health evidence handoff

Recorded 19 November 2026. Owner: Dev 1 (`Kavee-ginty`). This handoff joins
the independently merged upload/status work from [#44](https://github.com/Tenzrr/Elora/issues/44)
and tomato disease baseline from [#45](https://github.com/Tenzrr/Elora/issues/45).
It records the demonstrated interim slice against REQ-1.3 and REQ-1.4; it does
not assert that either full requirement is accepted.

## What the interim demo proves

1. A verified Firebase account selects Tomato / Disease and a leaf photo in the
   Android Scan tab. The API validates the upload, commits an owned PostgreSQL
   job and returns `202` with a UUID. Reading that UUID returns terminal
   `failed / MODEL_UNAVAILABLE`, `result=null` and `image_retained=false`.
   Retrying the unchanged operation returns the same UUID. The [#44 device and
   database record](../issue-44/README.md) distinguishes the live Android run
   from the earlier synthetic-identity database smoke and mock widget capture.
2. A separate training run produced a six-class tomato leaf disease baseline.
   Its [manifest](../../../ai/models/tomato/disease/evidence/dataset_manifest.csv)
   records 830 raw images, 60 exclusions and a photo-level stratified 538/116/116
   train/validation/test split. The [held-out evaluation](../../../ai/models/tomato/disease/evidence/evaluation.json)
   reports 77/116 correct (66.4% accuracy), 0.626 macro F1 and one inspected
   prediction error. The [model record](../../../ai/models/tomato/disease/README.md)
   gives the source, rights, preprocessing, class order, artifact link, SHA-256
   and limitations. The owner independently matched the downloaded ZIP's
   SHA-256 to that record.

| Requirement | Evidence | Interim conclusion |
| --- | --- | --- |
| [REQ-1.3](../../specifications/Elora_SRS.md) | [#44 upload/status evidence](../issue-44/README.md), [scan API contract](../../api-contracts.md), [merged API PR #102](https://github.com/Tenzrr/Elora/pull/102), [#45 baseline PR #98](https://github.com/Tenzrr/Elora/pull/98) | Owned job persistence and a separate versionable-model research artifact exist. The server does not run that model, retain the image, or persist an assessment. No offline variant is available. Full REQ-1.3 remains open. |
| [REQ-1.4](../../specifications/Elora_SRS.md) and AC-1.4 | [model evaluation](../../../ai/models/tomato/disease/evidence/evaluation.json), [assessment schema](../../../shared/schemas/model_contract.json), [Android unavailable-state capture](../issue-44/android-live-receipt.png) | The app honestly shows that analysis is unavailable. No label, calibrated confidence, uncertainty, model version, condition information or prediction disclaimer is displayed from a real result. AC-1.4 has not been executed; full REQ-1.4 remains open. |

The model's example `0.777` softmax score is **uncalibrated** and is not a
confidence value for the assessment contract. The saved test set has been
inspected, so future model selection needs validation data and final claims
need an independent field set. Plant/capture-session IDs were unavailable;
related-photo leakage across the split remains possible. No agronomy label
review or independent Sri Lankan field evaluation has been completed.

## Rehearsal sequence

1. Show the [Android receipt capture](../issue-44/android-live-receipt.png) and
   match its scan UUID to the [#44 live-run account](../issue-44/README.md).
   State that the status is `MODEL_UNAVAILABLE`, not a model prediction.
2. Show the [dataset audit and model evaluation](../../../ai/models/tomato/disease/README.md).
   State the 116-image internal test size, 66.4% accuracy, 0.626 macro F1 and
   unverified plant/session grouping. The model was run separately from the app.
3. Explain the integration gap: the upload discards image bytes after validation;
   no worker, private media storage, serving path, calibration or result display
   connects this checkpoint to a scan. Do not present the training prediction
   as the Android photo's diagnosis.

## Checks and next handoff

The #44 record lists backend, Flutter, CI and Android checks with their actual
scope. The #45 record contains saved-run artifacts rather than a deployed
inference test. This PR changes evidence only and corrects one stale model-README
sentence; it changes no API, database, model or mobile behavior. Verify this
handoff's links and figures against the source files and run `git diff --check`.

For [#51 integration](https://github.com/Tenzrr/Elora/issues/51), use the two
evidence paths as separate demo segments and disclose the gap above. Durable
scan execution and private image handling belong to [#53](https://github.com/Tenzrr/Elora/issues/53)
and [#54](https://github.com/Tenzrr/Elora/issues/54). A future result must satisfy
the shared assessment schema, domain checks, calibrated disease confidence and
the 60% disease cutoff before the UI can claim REQ-1.3/REQ-1.4 acceptance.
