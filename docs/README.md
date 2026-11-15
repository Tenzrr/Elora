# Elora documentation

## Authority

The [finalized SRS](specifications/Elora_SRS.md) is authoritative. Its [source record](specifications/Elora_SRS.source.json) identifies the unchanged Google Doc revision. The repository snapshot preserves every source paragraph in order; original layout, drawings and styling remain in Google Docs.

[Implementation guidance](specifications/Elora_Implementation_Decisions.md) and the [dataset catalogue](datasets/Elora_Dataset_Catalog.md) are subordinate. Resolve conflicts by following the finalized SRS and correcting supporting guidance. Do not modify the finalized requirements during cleanup.

## Working references

- [Shared development setup](operations/DEVELOPMENT_SETUP.md): Git/Flutter/Python locally, Supabase/Firebase and isolated workspaces; no local Docker required

- [Ownership](../WORK_DISTRIBUTION.md) and [November 16–19 interim plan](project-management/INTERIM_PLAN.md)
- [API direction](api-contracts.md), [model direction](model-contract.md), [architecture](architecture.md), and [UI references](figma-foundation.md)
- [Screen PNGs](screens/) and [class descriptions](diagrams/class-descriptions.md)
- [Cleanup disposition](operations/CLEANUP_DISPOSITION.md) and [historical archive](archive/README.md)
- [Preserved design report](reports/member5_detailed_system_and_ui_design.md) and [quality dataset research](reports/Quality_Dataset_Label_Feasibility.md)

Garden-named specifications are historical references only. Their auth, platform, model counts, scan routes and unsupported output metrics cannot override the final SRS. Diagram classes and sample screen values are design evidence, not completed implementation.

Reports retain their authored completion statements for submission purposes. Actual status belongs in the interim tracker and PR evidence. The [live interim report](https://docs.google.com/document/d/12-olpE7F1eYZEHgXh0AcgxZq0KpAGZ9D8-8xQEjyVLA/edit) remains unchanged.

Inspect the matching PNG before implementing mobile UI. Extend shared components for SRS-required localization, offline, safety and failure states. Feature owners use public contracts; shared navigation/theme, migrations, schemas and CI need an identified reviewer.
