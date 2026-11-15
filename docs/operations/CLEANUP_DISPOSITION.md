# Cleanup disposition

All pending work was backed up outside the repository before edits. Backup hashes and full Git history are held locally; no backup files or credentials are committed.

The Google Docs SRS remains unchanged. The source record identifies the exact paragraph snapshot. Report/design completion statements are preserved; the interim tracker records actual development status.

| Original pending path | Classification | Disposition |
|---|---|---|
| `.gitignore` | Repository hygiene | Retain local-output exclusions; remove stale personal-file exclusions |
| `AGENTS.md` | Current documentation / agent guidance | Reviewed and reconciled against finalized SRS |
| `README.md` | Current documentation / agent guidance | Reviewed and reconciled against finalized SRS |
| `WORK_DISTRIBUTION.md` | Current documentation / agent guidance | Reviewed and reconciled against finalized SRS |
| `docs/DEV1_FOUR_MONTH_NETWORK_PLAN.md` | Obsolete personal planning / temporary output | Removed from active tree; recoverable in external backup |
| `docs/README.md` | Current documentation / agent guidance | Reviewed and reconciled against finalized SRS |
| `docs/api-contracts.md` | Current documentation / agent guidance | Reviewed and reconciled against finalized SRS |
| `docs/architecture.md` | Current documentation / agent guidance | Reviewed and reconciled against finalized SRS |
| `docs/datasets/Elora_Dataset_Catalog.md` | Current documentation / agent guidance | Reviewed and reconciled against finalized SRS |
| `docs/dev1-four-month-network.png` | Obsolete personal planning / temporary output | Removed from active tree; recoverable in external backup |
| `docs/diagrams/01-system-overview.mmd` | Design assets | Preserved without content changes |
| `docs/diagrams/01-system-overview.png` | Design assets | Preserved without content changes |
| `docs/diagrams/01-system-overview.svg` | Design assets | Preserved without content changes |
| `docs/diagrams/02-crop-health-analysis.mmd` | Design assets | Preserved without content changes |
| `docs/diagrams/02-crop-health-analysis.png` | Design assets | Preserved without content changes |
| `docs/diagrams/02-crop-health-analysis.svg` | Design assets | Preserved without content changes |
| `docs/diagrams/03-produce-quality.mmd` | Design assets | Preserved without content changes |
| `docs/diagrams/03-produce-quality.png` | Design assets | Preserved without content changes |
| `docs/diagrams/03-produce-quality.svg` | Design assets | Preserved without content changes |
| `docs/diagrams/04-predictive-farming.mmd` | Design assets | Preserved without content changes |
| `docs/diagrams/04-predictive-farming.png` | Design assets | Preserved without content changes |
| `docs/diagrams/04-predictive-farming.svg` | Design assets | Preserved without content changes |
| `docs/diagrams/05-agricultural-assistant.mmd` | Design assets | Preserved without content changes |
| `docs/diagrams/05-agricultural-assistant.png` | Design assets | Preserved without content changes |
| `docs/diagrams/05-agricultural-assistant.svg` | Design assets | Preserved without content changes |
| `docs/diagrams/06-community-accounts.mmd` | Design assets | Preserved without content changes |
| `docs/diagrams/06-community-accounts.png` | Design assets | Preserved without content changes |
| `docs/diagrams/06-community-accounts.svg` | Design assets | Preserved without content changes |
| `docs/diagrams/class-descriptions.md` | Design assets | Preserved without content changes |
| `docs/figma-foundation.md` | Current documentation / agent guidance | Reviewed and reconciled against finalized SRS |
| `docs/model-contract.md` | Current documentation / agent guidance | Reviewed and reconciled against finalized SRS |
| `docs/reports/Elora_SRS_Draft.md` | Historical analysis | Archived at `docs/archive/Elora_SRS_Draft.md` |
| `docs/reports/Quality_Dataset_Label_Feasibility.md` | Analysis/report evidence | Preserved without content changes |
| `docs/reports/SRS_Preparation_Findings.md` | Historical analysis | Archived at `docs/archive/SRS_Preparation_Findings.md` |
| `docs/specifications/Elora_Implementation_Decisions.md` | Historical analysis | Archived at `docs/archive/Elora_Implementation_Decisions_pre_final.md`; current SRS/guidance replaces pre-final specifications |
| `docs/specifications/Elora_SRS.md` | Historical analysis | Archived at `docs/archive/Elora_SRS_pre_final.md`; current SRS/guidance replaces pre-final specifications |
| `docs/specifications/Garden_API_and_Integration_Contract.md` | Historical design specification | Retained with an explicit superseded notice |
| `docs/specifications/Garden_App_Flow_and_Screen_State_Specification.md` | Historical design specification | Retained with an explicit superseded notice |
| `docs/specifications/Garden_Backend_Schema_and_Data_Model.md` | Historical design specification | Retained with an explicit superseded notice |
| `docs/specifications/Garden_PRD.md` | Historical design specification | Retained with an explicit superseded notice |
| `docs/specifications/Garden_TRD.md` | Historical design specification | Retained with an explicit superseded notice |
| `docs/specifications/Garden_UI_UX_Design_Specification.md` | Historical design specification | Retained with an explicit superseded notice |
| `tmp/render_dev1_network_png.py` | Obsolete personal planning / temporary output | Removed from active tree; recoverable in external backup |

## Tracked premature implementation

October crop-health feature code, mock model predictions, feature-specific tests and Windows scaffolding are removed in the second cleanup PR. Android scaffolding, shared theme, database preparation, reports, screens and module boundaries are retained. Authentication, cloud provisioning and individual development remain outside cleanup.

## Merge sequence

1. Documentation baseline into `develop`.
2. Code cleanup based on merged baseline into `develop`.
3. Reviewed `develop` to `main` promotion.
4. Recheck unique commits/open PRs and retire redundant branches. No shared history rewrite.
