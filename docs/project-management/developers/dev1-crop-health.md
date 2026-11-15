# Dev 1 · Crop Health Analysis

**Athauda K. G.** · `Kavee-ginty` · workspace `dev1` · Android **Scan**

Own the shared disease-scan workflow and train the disease and quality CNNs for tomato and chilli. Work in `mobile/lib/features/crop_health/`, `backend/app/modules/crop_health/` and the corresponding crop model directories under `ai/models/`. Coordinate the first integration and development workspace handoffs.

## Four-day plan

| Task | Depends on | Planned window | Working days | Exit evidence |
| --- | --- | --- | ---: | --- |
| A · Confirm shared scan inputs and results with Dev 2; start the authenticated scan slice | — | Nov 16 | 1 | Agreed multipart inputs, validation and result shape |
| B · Prepare one tomato disease dataset and start the first training run | — | Nov 16 | 1 | Source, licence, labels, grouped split manifest and started run |
| C · Build the smallest photo upload/analysis slice against shared contracts | A | Nov 17–18 | 2 | Valid image accepted; invalid input rejected; unavailable or uncertain result handled |
| D · Train and evaluate one tomato disease CNN baseline | B | Nov 17–18 | 2 | Held-out metrics, confusion matrix, sample prediction and known limitations |
| E · Package the demo and submit one focused PR | C, D | Nov 19 | 1 | Pipeline and model evidence linked to requirements; connect inference if ready |

Critical paths **A → C → E** and **B → D → E**. If inference integration slips, show the trained model separately and demonstrate the upload path with its actual status. Explain the gap explicitly during the evaluation.

## After the interim

- **December–January.** Finish the durable server scan workflow, saved results and history with Devs 2 and 5. Progress the remaining tomato and chilli models and document data and model provenance.
- **February–March.** Coordinate independent model evaluation, versioned serving and signed Android disease model delivery. Verify abstention, local result sync and replay protection. Apply the 60% disease confidence cutoff alongside domain and image checks.
- **April 2027.** Hand over model and scan evidence, including evaluation limits, package compatibility and release gates.

Read the [team guide](../../../WORK_DISTRIBUTION.md), [interim tracker](../INTERIM_PLAN.md), [SRS](../../specifications/Elora_SRS.md) REQ-1 and BR-07/08/12, and [model contract](../../model-contract.md).
