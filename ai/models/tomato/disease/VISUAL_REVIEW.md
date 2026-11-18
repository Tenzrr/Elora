# Visual review of original tomato images

The [review queue](visual_review_queue.csv) contains 50 randomly selected **retained raw originals per class** (300 rows total). `prepare_visual_review.py` regenerates the same queue from the committed manifest using seed 45. This is the minimum visual sample in the dataset intake procedure; it does not replace agronomy review or independent field testing.

## Open an image

Each `original_path` is relative to the extracted dataset folder. On Dev 1's machine, that folder is:

```text
C:\Users\Kaveesha Ginodh\Downloads\Tomato Leaf Disease Classification Dataset in Paki\Tomato Leaf Disease Classification Dataset in Paki
```

For example, a queue path beginning `Tomato Dataset/Dataset (raw)/...` sits under that folder. The `review_id` lets us discuss a row without confusing similar filenames. Do not change the path, hash, source label, or split columns while reviewing.

## Mark each row

Use `yes`, `no`, or `uncertain` in these three columns:

- `tomato_leaf_visible`: Is a tomato leaf sufficiently visible for the intended leaf task? A fruit-only or other-crop image is `no`.
- `label_plausible`: Does the displayed source label appear plausible from visible symptoms? Use `uncertain` whenever you cannot judge. A visual check is not a laboratory diagnosis.
- `rights_or_identifier_concern`: Is there a visible person, private identifier, watermark, or other reason to investigate image use? `no` does **not** prove ownership or permission.

Add your name in `reviewer` and explain `no` or `uncertain` entries in `notes`. An agronomy reviewer should resolve suspected disease-label errors. Keep the source licence and contributor attribution with any shared outputs.

For a first practice row, `TOM-001` visibly contains a spotted tomato-like leaf. `tomato_leaf_visible = yes` is reasonable. The early-blight label needs plant-pathology review, so `label_plausible = uncertain` is honest if you cannot verify the symptom pattern. No person or watermark is visible in that photo; this says nothing about who owns it. The queue is left blank for the human review record.

## Why this matters

The current classifier learned from folder labels. A mislabeled training photo teaches the wrong pattern; a mislabeled test photo can make a correct prediction appear wrong. The queue identifies review candidates without silently changing evidence. If review leads to exclusions or corrected labels, update the manifest and create a **new** model run and evaluation version. Preserve the current baseline as the comparison record. Do not pick a new model using the already-inspected test set.

After all 300 rows are marked, summarize counts of `no` and `uncertain` by class, document each resolution, and ask the agronomy reviewer to sign off on the label mapping. Until then, the 50-per-class audit remains open.
