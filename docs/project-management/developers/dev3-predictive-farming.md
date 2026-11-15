# Dev 3 · Predictive Farming Analytics

**Perera H.D.S** · `Dimanya-Perera` · workspace `dev3` · Android **Farming**

Own weather, advice and care planning. Train the banana disease and quality CNNs later. Work in `mobile/lib/features/predictive_farming/`, `backend/app/modules/predictive_farming/` and the banana model directories under `ai/models/`. Lead review of shared changes and coordinate the weather contract with Dev 4.

## Four-day plan

| Task | Depends on | Planned window | Working days | Exit evidence |
| --- | --- | --- | ---: | --- |
| A · Pick one test location and one explainable weather-based advisory | — | Nov 16 | 1 | Location input, forecast fields and draft rule inputs agreed |
| B · Fetch and display a real Open-Meteo forecast | A | Nov 17 | 1 | Weather response for the chosen location with source, retrieval/forecast times and units |
| C · Connect the advisory and handle unavailable or stale weather | B | Nov 18 | 1 | Android flow explains the rule inputs and withholds new advice when required |
| D · Demonstrate live and failure cases, then submit one focused PR | C | Nov 19 | 1 | Working demo, rule assumptions and failure evidence tied to REQ-3 |

Critical path **A → B → C → D**. Manual area selection can support the first flow. Preserve evidence of a real weather response and label any cached demo data with its retrieval time.

## After the interim

- **December–January.** Expand forecast and location handling, versioned care rules, task scheduling and care logs. Agree on notification boundaries with Dev 5. Prepare banana datasets and model baselines.
- **February–March.** Review care recommendations and implement supported harvest, irrigation, crop, market and regional features with the required inputs and approved methods. Verify stale-data handling, opt-in aggregation with Dev 5 and unavailable estimates. Evaluate the banana models.
- **April 2027.** Hand over agronomy and estimation evidence, source/method versions and banana model results.

Read the [team guide](../../../WORK_DISTRIBUTION.md), [interim tracker](../INTERIM_PLAN.md), and [SRS](../../specifications/Elora_SRS.md) REQ-3 and BR-03/13.
