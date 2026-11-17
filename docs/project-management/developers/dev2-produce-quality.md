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

## After the interim

- **December–January.** Prepare citrus datasets and model baselines. Integrate the quality flow with the common job/result API. Use the SRS category mappings and show prediction confidence with separately validated quality thresholds.
- **February–March.** Verify real citrus and cross-crop results, abstention, offline photo queueing, and saving and reviewing results. Check that handling advice matches the quality task and unsupported measurements stay out of the UI.
- **April 2027.** Hand over feasibility decisions, citrus model evidence, and quality flow acceptance results.

Read the [team guide](../../../WORK_DISTRIBUTION.md), [interim tracker](../INTERIM_PLAN.md), [SRS](../../specifications/Elora_SRS.md) REQ-2 and BR-07/08, and [dataset catalogue](../../datasets/Elora_Dataset_Catalog.md).
