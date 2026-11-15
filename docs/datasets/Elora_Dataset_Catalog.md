# Elora dataset catalogue

Version 1.0 · Researched 15 November 2026 · Companion to [Elora SRS](../specifications/Elora_SRS.md)

This is the dataset acquisition plan for all five developers and twelve crop models. It replaces requests for developers to find and document their own starting datasets. Sources searched include Mendeley Data, Zenodo, original GitHub repositories, Kaggle, Roboflow Universe, Hugging Face, TensorFlow Datasets, university collections, and dataset links in original research papers. This is a broad search, not a claim to have exhausted the internet.

**Evidence boundary:** Dataset pages, repository descriptions, licences and original publications were inspected. Full archives have not been downloaded, deduplicated, audited or trained. Counts and labels below are source-reported, not independently verified. A public download or a hosting-site licence badge alone does not establish that every underlying image has appropriate rights. Every selected dataset must pass section 7 before use in a production model. “Selected” means the implementation starting point, not a validated launch model.

## Finalized SRS alignment

This catalogue supports the finalized SRS; it cannot change its requirements. Disease inference uses the fixed 60% calibrated cutoff plus input/domain checks. Quality thresholds are validated separately. Evaluate all twelve server models and six approved quantised Android disease variants under QUAL-1/BR-07/BR-08/BR-12; publish calibration, abstention coverage and unsupported-input acceptance as well as per-class metrics. The provisional SRS numeric targets are not achieved results. Android variants additionally need signed manifests, checksums, compatibility and sync evidence. More data/rights review remains required, particularly for chrysanthemum stages.

## 1. Assignment and launch output

| Developer | Model ID | Selected source | Intended categorical output | Readiness |
|---|---|---|---|---|
| Dev 1 | `tomato-disease` | T1 | Six leaf-condition classes | Acquisition/audit required |
| Dev 1 | `tomato-quality` | Q1, tomato subset | Unripe, ripe, old, dried, damaged | Acquisition/audit required |
| Dev 1 | `chilli-disease` | C1 | Six leaf-condition classes | Acquisition/audit required |
| Dev 1 | `chilli-quality` | Q1, chili-pepper subset | Unripe, ripe, old, dried, damaged | Acquisition/audit required |
| Dev 2 | `citrus-disease` | L1, TFDS curated leaf subset | Black spot, canker, greening, healthy | Acquisition/audit and variety validation required |
| Dev 2 | `citrus-quality` | Q2, orange and lemon subsets | Fresh / spoiled | Acquisition/audit; other citrus excluded pending validation |
| Dev 3 | `banana-disease` | B1 | Sigatoka, Cordana, Pestalotiopsis, healthy | Acquisition/audit required |
| Dev 3 | `banana-quality` | B2 | Unripe, half-ripe, ripe, overripe | Acquisition/audit required |
| Dev 4 | `roses-disease` | R1 | Black spot, downy mildew, insect affected, healthy | Acquisition/audit required |
| Dev 4 | `roses-quality` | R2 | Early, middle, final growth stage | Definitions and field validation required |
| Dev 5 | `chrysanthemum-disease` | H1 | Bacterial leaf condition, Septoria leaf spot, healthy | Acquisition/audit required |
| Dev 5 | `chrysanthemum-quality` | H2, annotated chrysanthemum objects only | Bud / open flower | **Small seed only: local collection and annotation required** |

One disease model and one quality model per crop are retained. Quality here means a supported visual category: it does not imply laboratory quality, food safety, shelf life or a commercial grade. Taxonomy and visual definitions must be reviewed before freezing the label map. Normalized API IDs may differ from source folder spelling; the mapping must be retained.

## 2. Dev 1 — Tomato and chilli

### T1. Tomato Leaf Disease Classification Dataset in Pakistan — selected

- [Mendeley Data, version 2](https://data.mendeley.com/datasets/3mbnb82mxd/2), CC BY 4.0.
- Reports 7,200 smartphone field images and six labels: Early Blight, Late Blight, Septoria Leaf Spot, Leaf Mold, Yellow Leaf Curl Virus, Healthy.
- Train the tomato leaf-condition classifier from original images. Natural backgrounds are useful; Pakistan collection does not establish Sri Lankan performance. Disease names represent visual annotation, not laboratory confirmation.
- Do not extend this model to tomato fruit disorders or add bacterial spot merely because an older specification lists it.

### C1. Chilli leaf image dataset — selected

- [Mendeley Data, version 1](https://data.mendeley.com/datasets/tm3v4zmh7c/1), CC BY 4.0.
- Reports 8,814 smartphone images from Bangladesh. Folder labels: `Bacterial_Spot`, `Cercospora_Leaf_Spot`, `Curl_Virus`, `Healthy_Leaf`, `Nutrient_Deficiency`, `Powdery_Mildew`.
- Preserve the nutrient-deficiency category as an apparent visual condition. The model cannot determine the deficient nutrient or prescribe its dosage from the class name.

### Q1. VegNet — selected for two separate quality models

- [Mendeley Data, version 1](https://data.mendeley.com/datasets/6nxnjbn9w6/1), CC BY 4.0.
- Reports 6,850 images across Bell Pepper, Tomato, Chili Pepper and New Mexico Chile, with Unripe, Ripe, Old, Dried and Damaged categories.
- Use only tomato images for `tomato-quality` and only the Chili Pepper subset for `chilli-quality`. The overall count is not the count available to either classifier. Audit crop/label folders and class balance first.
- Keep the source's single-label interpretation. One result cannot simultaneously establish ripeness and damage. “Old” is a visual label, not elapsed age. Green chilli may be intentionally harvested green; do not equate this label with market rejection.

### Alternatives and exclusions

| Source | Possible use | Decision / limitation |
|---|---|---|
| [Tomato field dataset](https://data.mendeley.com/datasets/jttrv2w27r/1) | Alternative visual leaf classes | Seven reported conditions include leaf miner and magnesium deficiency; review exact licence/archive before adding classes. |
| [Tomato leaf and fruit dataset](https://data.mendeley.com/datasets/9jxvtgh325/1) | Additional organ-specific images | CC BY 4.0; 3,500 originals and 24,500 augmented reported. Mixed fruit/leaf classes must not be flattened into one leaf taxonomy. |
| [Additional chilli data](https://data.mendeley.com/datasets/tf9dtfz9m6/1) | Supplementary training candidate | CC BY 4.0 listing; public description does not establish a complete usable class map. Reserve pending archive inspection. |
| [PlantVillage original repository](https://github.com/spMohanty/PlantVillage-Dataset) / [HF distribution](https://huggingface.co/datasets/mohanty/PlantVillage) | Controlled-background pretraining / comparison | Resolve original rights and provenance; a mirror's licence declaration is insufficient. Do not treat controlled leaf images as a field benchmark. |
| [NCHU tomato maturity collection](https://aidata.nchu.edu.tw/smarter/en/dataset/smarter_08_pmml02_0_gsdf_20240820_htry_jtyrkt) | Six maturity stages | Research-use restrictions prevent assuming unrestricted production use; not selected. |
| [Chilli disease dataset](https://data.mendeley.com/datasets/wzc6r6w5w5/1) | Alternative leaf images | Noncommercial-use restrictions reported; exclude until explicit compatible permission is obtained. |

## 3. Dev 2 — Citrus

### L1. Citrus leaves — selected curated subset

- [Original Mendeley dataset, version 2](https://data.mendeley.com/datasets/3f83gxmv57/2), CC BY 4.0; [TensorFlow Datasets curation](https://www.tensorflow.org/datasets/catalog/citrus_leaves).
- Original collection reports 759 fruit/leaf images. TFDS uses 594 leaf images in four classes: Black spot, Canker, Greening, Healthy. Its curation excludes the small melanose class and unsuitable images.
- Use the curated four-class leaf task, not the original combined fruit/leaf task. Record original-to-TFDS mapping and actual per-class counts. Melanose and citrus scab are not launch labels under this selection.
- Verify cultivars/species in acquisition and local tests. “Citrus” in a dataset title does not prove applicability to every orange, lemon, lime or mandarin variety. Expose supported varieties in model metadata; abstain on unsupported inputs.

### Q2. Spoiled and fresh fruit inspection — selected citrus subset

- [Mendeley Data, version 1](https://data.mendeley.com/datasets/6ps7gtp2wg/1), CC BY 4.0.
- Reports 16,000 images across eight fruits, 2,000 per fruit, with fresh and spoiled/non-fresh categories. Select orange and lemon images only and map the two quality labels explicitly.
- Train one citrus-quality model for those two supported fruit types. Require orange/lemon selection in the input flow; lime, mandarin and unspecified citrus are not implicitly supported.
- Appearance is not a food-safety certificate. This binary dataset does not support “premium/standard/reject”, exact defect area, firmness, sugar level or days remaining.

### Alternatives and exclusions

| Source | Possible use | Decision / limitation |
|---|---|---|
| [BDLemonLeaf](https://data.mendeley.com/datasets/643f5bbc2t/6) | Broader lemon visual conditions | Reserve: confirm the version's licence, raw counts and 13-class taxonomy; not permission to extend all citrus labels. |
| [LemonLENS](https://data.mendeley.com/datasets/ccwh64fr2r/2) | Lemon-specific recognition | Reserve requiring licence and class-map audit. |
| [Citrus quality original study](https://www.mdpi.com/2624-7402/7/9/286) and [linked Kaggle dataset](https://www.kaggle.com/datasets/moussaid/citrus-quality-classification) | Reported bad/medium/good task | Dataset rights and accessible archive were not established sufficiently for selection. Attention maps do not establish measured defect percentages. |
| [Lemon varieties dataset](https://data.mendeley.com/datasets/mygrsk3vyb/1) | Lemon variation / later reannotation | CC BY 4.0; 1,956 originals and eight classes reported. Page description alone does not establish a ripeness taxonomy. |
| [Fresh and rotten fruits](https://data.mendeley.com/datasets/bdd69gyhv8/1) | Supplementary fresh/rotten images | Reserve pending archive/licence/provenance audit and overlap checks with Q2. |

## 4. Dev 3 — Banana and weather

### B1. BananalSD — selected disease source

- [Mendeley Data, version 1](https://data.mendeley.com/datasets/9tb7k297ff/1), CC BY 4.0.
- Reports 937 original images and 1,600 augmented images, with Sigatoka, Cordana, Pestalotiopsis and Healthy labels; smartphone collection in Bangladesh and expert labelling are described.
- Split originals before augmentation. This selection does not support Fusarium/Panama wilt or banana bunchy top. Do not silently retain those labels from older documents.

### B2. BananaID — selected ripeness source

- [Mendeley Data, version 1](https://data.mendeley.com/datasets/h6n5srjjyw/1), CC BY 4.0.
- Reports 1,960 original ripeness images: Unripe 408, Half-ripe 488, Ripe 616, Overripe 448; 7,000 augmented images also supplied. Five Indonesian banana varieties are described.
- Use ripeness labels, not variety labels, for the quality head. Local Sri Lankan cultivars and different lighting require independent validation; no shelf-life estimate follows from ripeness alone.

### Alternatives and exclusions

| Source | Possible use | Decision / limitation |
|---|---|---|
| [BananaImageBD](https://data.mendeley.com/datasets/ptfscwtnyz/2) | External ripeness comparison | CC BY 4.0; 820 original ripeness images reported, plus a separate variety collection. Map Green/Semi-ripe/Ripe/Overripe only after definition review. |
| [Tanzania banana imagery](https://zenodo.org/records/7670326) / [original data paper](https://www.nature.com/articles/s41597-025-04456-4) | Larger healthy/black-Sigatoka/Fusarium collection | Paper reports 11,767 images. Dataset licence was not established from the inspected landing page; article licence does not automatically license its archive. Reserve pending rights confirmation. |
| [Banana field dataset](https://zenodo.org/records/7860962) | Bunchy top / black Sigatoka | Files are restricted; not an immediately open dataset. Permission would be needed. |
| [Removed banana dataset](https://data.mendeley.com/datasets/wzshm7ky49/1) | Previously published disease data | Removed at author request; exclude. |
| [Additional banana collection](https://data.mendeley.com/datasets/5nfjzntwd8/1) | Mixed fruit/leaf conditions | Reserve; inspect version changes, organs and label semantics before use. |
| [Day-indexed banana photos](https://data.mendeley.com/datasets/d5tczj7fs7/1) | Possible longitudinal research | Capture day is not ground truth for remaining edible shelf life. No numerical shelf-life output is approved. |

Weather is a provider integration, not a thirteenth crop model. Use the production Open-Meteo subscription and attributed forecasts specified in the implementation decisions. Weather-based care is a reviewed rule system, not a trained yield predictor.

## 5. Dev 4 — Roses and assistant

### R1. Rose leaf disease collection — selected

- [Mendeley Data, version 1](https://data.mendeley.com/datasets/mdtpp2cmj4/1), CC BY 4.0.
- Reports 2,048 original images: Black Spot 432, Downy Mildew 390, Insects Infected 431, Healthy 795; also 20,480 augmented images.
- Preserve “insect affected” as a general visual class, not identification of a particular pest. Powdery mildew and rust are not supported merely because they are common rose diseases.

### R2. High-resolution rose growth-stage imagery, Golap Gram — selected

- [Mendeley Data, version 1](https://data.mendeley.com/datasets/53vyvz5yyk/1), CC BY 4.0.
- Reports 565 natural field photos: Early Stage 98, Middle Stage 289, Final Stage 178.
- These are the three intended source classes. Before annotation freeze, inspect images and agree operational definitions with the reviewer. Do not rename “Final Stage” to senescence, freshness, full bloom or remaining vase life without supporting ground truth.
- Add local examples to address class imbalance and cultivar/background shift.

### Alternatives and exclusions

| Source | Possible use | Decision / limitation |
|---|---|---|
| [Related five-class rose leaves](https://data.mendeley.com/datasets/sfxcjwf6cb/1) | Possible mosaic-class expansion | CC BY 4.0, 4,725 processed images reported. Related authors/locations imply possible overlap with R1; not an independent test set. |
| [Rose healthy/dry/holes/black-spot leaves](https://data.mendeley.com/datasets/hmjtdzkfh3/2) | Alternate visible-condition task | CC BY 4.0; 3,113 originals and 15,500 augmented reported. Dryness and holes are not specific pathogen diagnoses. |
| [RoseVisuals](https://data.mendeley.com/datasets/f44jwtbfjg/5) | Petal freshness research | CC BY 4.0; 1,995 petal images, Fresh/Dry/Diseased. Detached petals are not whole-bloom stage labels. |
| [RoseBlooming original repository](https://github.com/dahlian00/RoseBlooming-Dataset) | Small/large bloom detection research | Explicit noncommercial restriction. A differently licensed mirror does not remove original restrictions. Not selected for production. |
| [Rose growth detection, Roboflow](https://universe.roboflow.com/meenal/rose-growth-stage-detection-jqjbs) | Additional annotation candidate | Mixed/ambiguous labels and provenance require checking. No automatic merge into R2. |
| [Four-stage rose detection, Roboflow](https://universe.roboflow.com/yolo-lmnpo/-zkger) | Additional stage candidate | Landing-page licence is insufficient evidence of image origins. Reserve only. |

The assistant's knowledge corpus is separate from image training data. Start with [Sri Lanka DoA crop production](https://doa.gov.lk/agriculture-production/), [HORDI tomato](https://doa.gov.lk/hordi-crop-tomato/), [DoA chilli resources](https://doa.gov.lk/fcrdi-downloads/), [DoA publications including banana](https://doa.gov.lk/naicc-books/), and [IWMI/DoA tomato guide](https://cgspace.cgiar.org/items/a410c23b-5f14-4a24-af55-6d6cf93dcc91). Review reuse rights before storing full text; public access is not blanket permission to scrape or redistribute. Where permission is unclear, use reviewed original summaries with citations and retain links. Flower/citrus advice needs suitable reviewed references; do not fill gaps with invented instructions.

## 6. Dev 5 — Chrysanthemum and community/accounts

### H1. Chrysanthemum leaf disease dataset — selected

- [Mendeley Data, version 1](https://data.mendeley.com/datasets/dmdwhx4cdd/1), CC BY 4.0.
- Reports 2,580 images: Bacterial Leaf 856, Septoria Leaf Spots 856, Healthy 868.
- Retain the source label and obtain a reviewer-approved description of the bacterial category. No additional chrysanthemum disease classes are inferred.
- [Related earlier collection](https://data.mendeley.com/datasets/y38k9mt7z8/1), CC BY 4.0, reports 2,700 originals plus 2,301 augmented. Check overlap and reconcile counts before considering it as supplementary data. Related collections must not be treated as independent validation.

### H2. Flowers detection — selected seed, insufficient alone

- [Roboflow Universe original project](https://universe.roboflow.com/manasa-b-p-tooaz/flowers-detection-huslj), landing page declares CC BY 4.0.
- Reports 190 images across chrysanthemum and star-jasmine. Detection classes include `chrysanthemum bud`, `chrysanthemum flower`, `star-jasmine bud`, `star-jasmine flower`, and a mixed class. The count is for the whole collection, not 190 examples per chrysanthemum class.
- Check original image rights and annotations. Extract only valid chrysanthemum bud/flower boxes, preserving source-image groups. Exclude star-jasmine and ambiguous mixed objects. Detection labels can seed cropped classification data; they are not automatically a ready-made classifier dataset.
- Intended launch output: **bud / open flower**. A separate early/full/senescent quality scale is unsupported by this source.
- **Required local collection:** target at least 300 distinct original images per class from at least 30 plants across three sites, with multiple phones/lighting conditions. These are project collection targets, not proof of sufficient accuracy. Collect independent test plants/sessions separately under section 7; increase data if validation fails. Obtain contributor permission and agronomy-reviewed annotations.

### Alternatives and exclusions

| Source | Possible use | Decision / limitation |
|---|---|---|
| [FlowerNet](https://data.mendeley.com/datasets/26nvt3t27m/1) | Possible reannotation pool | Landing page declares MIT; reports 291 chrysanthemum and 268 rose originals among five species. Species labels do not provide stages. Verify image rights, then manually annotate only if suitable. |
| [Chrysanthemum-only detection project](https://universe.roboflow.com/ttcs-5m6gn/chrysanthemum-gafur) | Species localization | Single Chrysanthemum class does not support bloom-stage classification. |
| [F-YOLO chrysanthemum paper](https://www.mdpi.com/2073-4395/11/5/834) | Stage annotation methods | Research reference; a verified openly licensed training archive was not established. |
| [Chrysanthemum phenotyping paper](https://www.frontiersin.org/journals/plant-science/articles/10.3389/fpls.2023.1134911/full) / [linked IEEE record](https://doi.org/10.21227/vc18-rv06) | Cultivar/phenotype research | Large collection described; do not assume stage labels or unrestricted rights without inspecting the archive and terms. |
| [BDFlower](https://data.mendeley.com/datasets/m8g2wynwyr/2) | Generic stage methodology | CC BY 4.0 and stage labels, but reported species do not include the required rose/chrysanthemum targets. Wrong-crop labels cannot train the two promised flower models. |

Community/accounts need no external ML training dataset: the launch feeds use crop tags, follows, recency and blocks. Do not introduce a recommender model.

## 7. Mandatory intake and evaluation procedure — every owner

1. Download the selected version into external data/artifact storage. Save its page, DOI/version, licence text, attribution, author and access date. Resolve contradictory permissions before use. Do not commit raw images or weights to Git.
2. Generate `dataset_manifest.csv` with source ID, original path, SHA-256, crop, organ, source label, normalized label, original/augmented status, plant/session/group ID where available, provenance and intended split. Remove corrupt files, people/identifiers and inappropriate images.
3. Audit at least 50 random originals per class, or all if fewer, for organ, annotation meaning and image rights. Record exclusions and uncertain labels. Review semantic class mappings with the agronomy reviewer.
4. Deduplicate within and across sources using exact hashes and perceptual similarity, with manual review of near matches. Related articles/mirrors are not new independent datasets.
5. Split original groups 70% training, 15% validation and 15% internal test, stratified where feasible. Keep every image of the same plant/session and all its augmented derivatives in one split. Generate new augmentation only after splitting and only for training. If source grouping cannot be recovered, disclose residual leakage risk and rely on a separately collected field test.
6. Build a separate, consented Sri Lankan phone-photo test set with at least 50 original images per class, at least three sites and no training plants/sessions. Include unsupported crops/organs, blur, low light, clutter and non-plant photos for abstention tests. This minimum is a collection floor; report uncertainty and increase samples where necessary.
7. Report class counts, confusion matrix, per-class precision/recall/F1, macro F1, calibration, abstention coverage and false acceptance of unsupported inputs. Report metrics on all evaluable test images as well as accepted predictions, so abstention cannot hide poor coverage. Do not present augmented-count accuracy as field accuracy.
8. Select decision/abstention thresholds using validation data; freeze model, preprocessing, thresholds and label map before the independent field evaluation. An agronomy reviewer must approve a numeric per-model/per-class acceptance matrix and useful coverage before public release. A failed gate requires improvement/retest or an explicit scope revision, not an unannounced missing model.
9. Publish a compact model card and machine-readable evaluation artifact. Record known varieties, regions, limitations, intended camera framing, training rights and model version. This can be generated from scripts; no developer essay is required.

## 8. Acquisition outcome

The search found credible, permissively declared starting datasets for eleven tasks and a small, provisional chrysanthemum-stage seed. None is a validated Sri Lankan production model. The twelve-model release commitment therefore still depends on licence/image audits, local collection, training, independent testing and reviewer approval. Unsupported classes, freshness scores, harvest dates and shelf-life numbers must not appear as promises in the SRS or UI.
