# Dev 2 · Produce Quality Assessment

**Dulaksha Dulan** · `dulakshadulan` · workspace `dev2` · Android **Quality**

Own the produce quality flow and train the citrus disease and quality CNNs. Work in `mobile/lib/features/produce_quality/`, `backend/app/modules/produce_quality/` and the citrus model directories under `ai/models/`. Coordinate the shared scan contract with Dev 1.

## Four-day plan

For current issue IDs, cross-developer blockers and capacity, use the [Dev 2 issue map](../dev2-issue-map.md) and [common CPM](../TEAM_DEPENDENCIES.md). The table below preserves the original four-day baseline; its technical paths do not account for one developer's limited hours.

| Task | Depends on | Planned window | Working days | Exit evidence |
| --- | --- | --- | ---: | --- |
| A · Confirm citrus subtype, request and result shape with Dev 1 | — | Nov 16 | 1 | Orange/lemon inputs and agreed categorical response fixture |
| B · Assess citrus data feasibility | A | Nov 17 | 1 | Sources, licences, class coverage and gaps for fresh/spoiled labels |
| C · Build citrus image selection/submission and result display | A | Nov 17–18 | 2 | Working flow with labelled fixture data, unsupported subtype and failure handling |
| D · Demonstrate the flow and submit one focused PR | B, C | Nov 19 | 1 | Android demo, fixture and data feasibility notes tied to REQ-2 |

Critical path **A → C → D**. Task B has one workday of scheduling flexibility. Shared fixture data lets the flow proceed while Dev 1 integrates scanning. A trained citrus CNN is later work.

## Issue #47 Citrus Data Feasibility & Contract Evidence

Status: [Issue #47](https://github.com/Tenzrr/Elora/issues/47) records the selected sources and agreed contract. The archives have not been downloaded, deduplicated, audited or trained. This is an acquisition starting point, not a validated Sri Lankan production model.

### Selected sources

| Use | Source | Source-reported coverage | Decision |
| --- | --- | --- | --- |
| `citrus-quality` | [Mendeley Data 6ps7gtp2wg/1](https://data.mendeley.com/datasets/6ps7gtp2wg/1), CC BY 4.0 | 16,000 images across eight fruits, 2,000 per fruit, with fresh and spoiled/non-fresh categories | Select only orange and lemon; nominal 4,000-image subset before audit. Map both quality labels explicitly to `fresh` and `spoiled`. |
| `citrus-disease` | [Mendeley Data 3f83gxmv57/2](https://data.mendeley.com/datasets/3f83gxmv57/2), CC BY 4.0; [TFDS `citrus_leaves`](https://www.tensorflow.org/datasets/catalog/citrus_leaves) | Original collection reports 759 fruit/leaf images; TFDS curates 594 leaf images into black spot, canker, greening and healthy | Use the curated four-class leaf task, not the original combined fruit/leaf task. Record the original-to-TFDS mapping and verify actual per-class counts and cultivars. |

### Contract evidence

- The interim scan contract is multipart `POST /api/v1/scans` with `crop_slug=citrus`, `task=quality`, and a required subtype of `orange` or `lemon`; responses follow `shared/schemas/model_contract.json`.
- Quality output is limited to `fresh` and `spoiled`. Lime, mandarin and unspecified citrus are unsupported and must return `422 INVALID_SUBTYPE`; they are not implied by orange/lemon coverage.
- The labelled fresh, spoiled and abstention fixtures under `shared/fixtures/` support UI and contract development but do not prove model accuracy, integration or field readiness.
- Appearance is not a food-safety certificate. This source does not support premium/standard/reject grading, exact defect area, firmness, sugar level, freshness scores or days remaining.

### Rights, audit and reproducibility

- Both selected datasets declare CC BY 4.0. Save the dataset page, DOI/version, licence text, attribution, author and access date; resolve conflicting permissions before use.
- Download archives to external data/artifact storage. Do not commit raw images or model weights to Git.
- Before training, generate `dataset_manifest.csv` with source ID, original path, SHA-256, crop, organ, source and normalized labels, original/augmented status, plant/session/group ID where available, provenance and intended split.
- Audit at least 50 random originals per class, or all if fewer, for organ, label meaning and image rights. Record exclusions and uncertain labels; review mappings with the agronomy reviewer.
- Deduplicate within and across sources, split original groups 70/15/15 before augmentation, and keep all derivatives of a plant/session in one split. Where grouping cannot be recovered, disclose residual leakage risk.
- For L1, retain the original-to-TFDS mapping and actual per-class counts. For Q2, verify the orange/lemon counts, balance and duplicates instead of treating the nominal 4,000-image total as audited coverage.

### Excluded and deferred candidates

| Candidate | Decision |
| --- | --- |
| Lime, mandarin and unspecified citrus | Excluded from Q2 input until separately validated; the UI/API must reject them rather than guess. |
| Melanose and citrus scab | Not launch labels for L1; the original combined fruit/leaf task is also not selected. |
| BDLemonLeaf | Reserve: confirm version licence, raw counts and 13-class taxonomy before any use. |
| LemonLENS | Reserve pending licence and class-map audit. |
| Citrus quality study / linked Kaggle dataset | Not selected: rights and accessible archive were not established; attention maps are not measured defect area. |
| Lemon varieties dataset | Not selected for quality: page description does not establish a ripeness taxonomy. |
| Fresh and rotten fruits | Reserve pending archive, licence, provenance and Q2 overlap checks. |

### Sri Lankan field and abstention gaps

- Neither source establishes Sri Lankan cultivar coverage, smartphone field performance or local post-harvest conditions. Treat both as external starting data, not local validation.
- Build a separate consented Sri Lankan phone-photo test set with at least 50 original images per class across at least three sites, with no training plants or sessions. Include unsupported crops/organs, blur, low light, clutter and non-plant images.
- Validate quality thresholds separately from the disease 60% calibrated cutoff. Report per-class metrics, calibration, abstention coverage and false acceptance of unsupported inputs on all evaluable images, not only accepted predictions.
- Abstain when the subtype, organ or domain is unsupported. An agronomy reviewer must approve the acceptance matrix and useful coverage before release; a failed gate needs improvement/retest or an explicit scope revision.

## After the interim

- **December–January.** Prepare citrus datasets and model baselines. Integrate the quality flow with the common job/result API. Use the SRS category mappings and show prediction confidence with separately validated quality thresholds.
- **February–March.** Verify real citrus and cross-crop results, abstention, offline photo queueing, and saving and reviewing results. Check that handling advice matches the quality task and unsupported measurements stay out of the UI.
- **April 2027.** Hand over feasibility decisions, citrus model evidence, and quality flow acceptance results.

Read the [team guide](../../../WORK_DISTRIBUTION.md), [interim tracker](../INTERIM_PLAN.md), [SRS](../../specifications/Elora_SRS.md) REQ-2 and BR-07/08, and [dataset catalogue](../../datasets/Elora_Dataset_Catalog.md).
