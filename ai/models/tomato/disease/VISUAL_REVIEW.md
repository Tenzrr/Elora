# Technical screen and agronomy review of tomato images

The [review queue](visual_review_queue.csv) contains 50 randomly selected **retained raw originals per source class** (300 rows total). `prepare_visual_review.py` regenerates the same queue from the committed manifest using seed 45. It is a handoff record, **not a request for Dev 1 to diagnose 300 leaves**. The source labels are included so a qualified agronomy reviewer can assess them. The queue does not replace independent field testing.

The notebook already checks all retained images for decode failures, exact duplicates, and candidate near duplicates. Codex can help with a separate technical screen for obvious wrong-organ images, unusable photos, visible people, and watermarks. Those checks cannot establish a disease diagnosis or image ownership.

## Open an image

Each `original_path` is relative to the extracted dataset folder. On Dev 1's machine, that folder is:

```text
C:\Users\Kaveesha Ginodh\Downloads\Tomato Leaf Disease Classification Dataset in Paki\Tomato Leaf Disease Classification Dataset in Paki
```

For example, a queue path beginning `Tomato Dataset/Dataset (raw)/...` sits under that folder. The `review_id` lets us discuss a row without confusing similar filenames. Do not change the path, hash, source label, or split columns while reviewing.

## Who fills which columns

- `leaf_visible`: Technical screen only. Use `yes`, `no`, or `uncertain` for whether a leaf is visible. This does not require identifying the crop or disease.
- `obvious_image_or_identifier_issue`: Technical screen only. Note blur, an image of fruit without a leaf, a visible person/identifier, a watermark, or another clear concern. Leave blank if no obvious issue is seen.
- `technical_reviewer` and `technical_notes`: Record who did that screen and why an image was flagged.
- `agronomy_label_assessment` and `agronomy_reviewer`: Reserved for a plant-pathology or agronomy reviewer to assess whether the source disease label fits the symptoms. Dev 1 should not guess these values.

For example, `TOM-001` visibly contains a spotted leaf. A technical reviewer can mark `leaf_visible = yes`. The early-blight label is **not** established by that observation; leave `agronomy_label_assessment` for the qualified reviewer. No visible watermark does not prove permission to use the image. Keep the source licence and contributor attribution with shared outputs.

## Why this matters

The current classifier learned from folder labels. A mislabeled training photo teaches the wrong pattern; a mislabeled test photo can make a correct prediction appear wrong. The queue identifies review candidates without silently changing evidence. If review leads to exclusions or corrected labels, update the manifest and create a **new** model run and evaluation version. Preserve the current baseline as the comparison record. Do not pick a new model using the already-inspected test set.

After technical screening, summarize clear image issues by source class. Ask a qualified reviewer to assess the disease labels and class definitions, prioritizing cross-label duplicate conflicts and errors from the model evaluation. Until that review is recorded, the label audit remains open. Dev 1 can explain the process and its limits without personally diagnosing leaves.
