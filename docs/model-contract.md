# Garden CNN Model Contract

> **Notice: Specification Migrated**  
> This specification has been migrated to the authoritative technical specifications:  
> 👉 [Garden Technical Requirements Document (Garden_TRD.md)](specifications/Garden_TRD.md)  
> 👉 [Garden API and Integration Contract (Garden_API_and_Integration_Contract.md)](specifications/Garden_API_and_Integration_Contract.md)  
> 👉 Machine-Readable Schema: [`shared/schemas/model_contract.json`](../shared/schemas/model_contract.json)

---

## Summary

Every disease and quality CNN model across the 5 crops (Tomato, Chilli, Citrus, Banana, Roses, Chrysanthemum — 10 models total) must adhere to the unified inference contract defined in `shared/schemas/model_contract.json`.

Models receive:
- `image_uri`: string
- `crop_slug`: `tomato` | `chilli` | `citrus` | `banana` | `roses` | `chrysanthemum`
- `model_task`: `disease` | `quality`
- `model_version`: string

Models return:
- `crop_slug`: string
- `task`: `disease` | `quality`
- `label`: string
- `confidence`: float (0..1)
- `top_predictions`: array of `{ label: string, confidence: number }`
- `model_version`: string
- `created_at`: ISO-8601 timestamp

Trained weights must be stored via Git LFS or external artifact buckets, never as ordinary Git commits.
