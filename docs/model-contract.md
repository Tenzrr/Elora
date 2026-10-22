# CNN model contract

Every disease and quality CNN must expose the same inference boundary. The model receives an image URI, a crop slug, a task, and a model version. It returns a label, calibrated confidence, top predictions, and the model version. See `shared/schemas/model_contract.json`.

Model owners must commit the label map, preprocessing description, evaluation metrics, and export format with the model metadata. Large weights belong in the configured artifact store or Git LFS, not ordinary Git history.
