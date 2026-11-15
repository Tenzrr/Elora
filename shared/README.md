# Shared contracts

`schemas/model_contract.json` is an enforceable JSON Schema for assessment results, replacing the old descriptive contract. Validate with JSON Schema 2020-12 plus format checking. It covers calibrated assessed/abstained outcomes, a maximum of three alternatives, model/version, origin and attributed guidance. All six crops share the contract. On-device results are disease-only; assessed disease confidence must be at least 0.60 and input/domain checks still apply.

The schema does not prove model validity. Owners must supply signed manifests, exact class/preprocessing mappings, validation/calibration cards and approved Android variants. No model artifact or inference endpoint is included in this foundation.

HTTP job status and model-distribution endpoints remain assigned development work. Update their generated schemas/fixtures before implementation. The API OpenAPI document is generated from the running backend; regenerate after shared API changes.
