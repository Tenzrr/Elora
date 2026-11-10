# Elora architecture

> **Notice: Specification Migrated**  
> This overview has been migrated to the authoritative technical specification:  
> 👉 [Garden Technical Requirements Document (Garden_TRD.md)](specifications/Garden_TRD.md)

---

## Summary

The Garden platform is split into five vertical slices, coordinated through a shared infrastructure kernel:

| Developer | Module | Complete Crop Ownership | Primary Paths |
|---|---|---|---|
| **Dev 1** | Crop Health Analysis | Tomato and Chilli (4 CNNs) | `mobile/lib/features/crop_health/`, `backend/app/modules/crop_health/` |
| **Dev 2** | Produce Quality Assessment | Citrus (2 CNNs) | `mobile/lib/features/produce_quality/`, `backend/app/modules/produce_quality/` |
| **Dev 3** | Predictive Farming Analytics | Banana (2 CNNs) | `mobile/lib/features/predictive_farming/`, `backend/app/modules/predictive_farming/` |
| **Dev 4** | Personalized Agricultural Agent | Roses (2 CNNs) | `mobile/lib/features/agricultural_agent/`, `backend/app/modules/agricultural_agent/`, `ai/agent/` |
| **Dev 5** | Community and User Accounts | Chrysanthemum (2 CNNs) | `mobile/lib/features/community/`, `backend/app/modules/community/` |

For full system architecture, database specifications, AI authority boundaries, and quality requirements, refer to [specifications/Garden_TRD.md](specifications/Garden_TRD.md).
