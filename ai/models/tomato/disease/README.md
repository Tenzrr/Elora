# Tomato leaf disease baseline (issue 45)

This directory contains the reproducible training notebook and the small evidence files from the recorded Kaggle run. The model is an **interim research baseline**, not a production diagnosis or an accepted field model. The saved `.keras` checkpoint remains outside ordinary Git; its artifact location and checksum still need to be recorded before handoff.

## Source and rights

- Dataset: [Tomato Leaf Disease Dataset from Real-Time Field Conditions in Pakistan, Mendeley Data version 2](https://data.mendeley.com/datasets/3mbnb82mxd/2), DOI `10.17632/3mbnb82mxd.2`.
- Listed contributors: Mohammad Naeem Malik, Syed Hashir Ali, and Hamid Ali.
- The included README and licence declare Creative Commons Attribution 4.0. Attribution and the source/version must accompany any shared derivative. Rights for every underlying image have not been independently established.
- Archive SHA-256: `2a2b36a8f972337f6d0e95e436835e55ffee5291fa07277157b40f0441f42f50`.
- The source describes 7,200 images. The archive contains 7,200 augmented images and **830 raw images**. This run uses raw images only.

## Input and model

- Supported input: a usable tomato **leaf** photo. Fruit, other crops/organs, blurry or otherwise unusable photos need a separate input/domain rejection step. This model alone does not implement that step.
- Six class IDs, in model output order: `early_blight`, `late_blight`, `septoria_leaf_spot`, `leaf_mold`, `yellow_leaf_curl_virus`, `healthy`.
- Image pipeline: RGB JPEG, resize with padding to 224 × 224, then rescale 0–255 pixels to −1–1 inside the Keras model. Serving must match this preprocessing and class order.
- TensorFlow 2.21.0, ImageNet MobileNetV2 feature extractor frozen, global average pooling, 0.2 dropout, six-class softmax head. Adam learning rate 0.001; sparse categorical cross-entropy; maximum 15 epochs; batch size 16; seed 45. The best validation-loss checkpoint was epoch 9 of 12 completed epochs.

## Dataset audit and split

The [manifest](evidence/dataset_manifest.csv) records all 830 raw paths, hashes, source and normalized labels, splits, and exclusion reasons. Exact SHA-256 duplicates and visually reviewed perceptual-hash near duplicates account for 60 exclusions, including images with conflicting labels. All 770 selected images decoded successfully. The remaining 770 originals were split into **538 train, 116 validation, and 116 test** images with stratification by source label.

Plant and capture-session IDs were unavailable, so `group_id` is blank and this is **not a verified plant/session-grouped split**. Related-photo leakage may remain. A sample visual review was performed, and a [50-originals-per-class review queue](VISUAL_REVIEW.md) is ready as a technical-screen and agronomy-review handoff; its 300 rows are not yet marked. Agronomy review is unavailable for the interim and remains an explicit limitation. Source disease names are visual annotations, not laboratory diagnoses. Dev 1 is not expected to diagnose the images.

## Recorded held-out result

The [evaluation](evidence/evaluation.json) and [training history](evidence/training_history.csv) are from the saved run. The 116-image internal test set gave **77/116 correct (66.4% accuracy)** and **0.626 macro F1**.

| Class | Precision | Recall | F1 | Test images |
|---|---:|---:|---:|---:|
| Early blight | 0.474 | 0.562 | 0.514 | 16 |
| Late blight | 0.615 | 0.533 | 0.571 | 15 |
| Septoria leaf spot | 0.667 | 0.720 | 0.692 | 25 |
| Leaf mold | 0.800 | 0.714 | 0.755 | 28 |
| Yellow leaf curl virus | 0.571 | 0.333 | 0.421 | 12 |
| Healthy | 0.720 | 0.900 | 0.800 | 20 |

One inspected test error was `Tomato_Early_blight_leaf/1723454506040.jpg`: the source label is early blight, while the model predicted Septoria leaf spot with a raw softmax score of 0.777. This score is **not calibrated confidence**. The test set has now been inspected; further model selection using its results would bias comparisons. Choose subsequent experiments on validation data and use a fresh independent field set for final claims.

## Limits and next evidence

This run has no independent Sri Lankan field evaluation, probability calibration, unsupported-input/fruit rejection result, or accepted-prediction coverage measurement. It does not satisfy the provisional `QUAL-1` release objectives. The fixed 60% disease cutoff must be applied to **calibrated** scores together with input/domain checks in a later model version. The issue 45 interim evidence can be reviewed without representing this baseline as release ready.

The [notebook](tomato_disease_baseline.ipynb) downloads the exact source archive, repeats the audit and split, trains the baseline, and writes the three evidence files plus a local `.keras` checkpoint. Run it in Kaggle with Internet access and a GPU. The contributor's [saved Kaggle notebook](https://www.kaggle.com/code/kaveeshaginodh/elora-tomato-disease-baseline) is the run reference; its page was not independently accessible from this environment. Record the external checkpoint location/checksum in the issue or PR before handoff.

The separate [EfficientNetB0 experiment](tomato_disease_efficientnet_experiment.ipynb) repeats the same data preparation, trains a head and a short fine-tuning stage, selects between them using validation macro F1, and writes exploratory test metrics. It is prepared for a Kaggle run; no results from it are claimed yet.
