# Dataset labels and feasible quality outputs for Elora

> Historical candidate review. The broader [dataset catalogue](../datasets/Elora_Dataset_Catalog.md) now selects starting sources for all twelve models, including newer rose-stage data and a provisional chrysanthemum bud/open-flower seed with mandatory additional collection. Use the catalogue with [SRS v1.0](../specifications/Elora_SRS.md).

Research date: 15 November 2026. Scope: the six quality/maturity models, following the user's request to base outputs on available dataset labels. This is a candidate-data review, not dataset selection or proof of trained-model performance. Repository pages and original papers were inspected; complete archives, annotations, duplicate rates and Sri Lankan field performance were not audited.

## Recommended output boundary

Use dataset-backed categorical condition, ripeness or flowering-stage labels. Report model confidence separately from quality. Do not promise numerical quality scores, physical defect percentages, precise harvest dates, remaining shelf-life or commercial grades solely from categorical labels. Such outputs need additional ground truth, methodology and validation.

## Crop and candidate mapping

| Crop | Candidate | Documented labels | Feasible output and qualification |
|---|---|---|---|
| Tomato | VegNet | Unripe, Ripe, Old, Dried, Damaged | Five-way visual condition/ripeness classification; practical initial candidate with the same label vocabulary as chilli |
| Tomato, optional finer maturity | NCHU tomato ripeness dataset | Breaker, Green, Lightred, Pink, Red, Turning | Six maturity stages, using bounding-box object annotations. Research-use access restrictions require review; no automatic damaged class |
| Chilli | VegNet, Chili Pepper subset | Unripe, Ripe, Old, Dried, Damaged | Five-way condition/ripeness classification. Does not establish Export/A/B grades or named disease causes |
| Citrus | Spoiled and fresh fruit inspection dataset, orange/lemon subsets | Fresh, non-fresh/spoiled | Binary visible condition; orange and lemon coverage does not establish lime coverage |
| Citrus, richer alternative | Citrus quality classification, author-linked dataset/paper | Bad quality, Medium quality, Good quality | Three subjective/expert-assigned external-quality classes; archive and dataset licence need verification. Do not rename as A/B/C/Reject |
| Banana | BananaImageBD v2 | Green, Semi-ripe, Ripe, Overripe | Four-stage visible ripeness classification; 820 original ripeness images reported |
| Banana, alternative | BananaID v1 | Unripe, Half-ripe, Ripe, Overripe | Four-stage ripeness classification; 1,960 original ripeness images reported. Different cultivars/capture conditions; do not merge labels without an explicit mapping |
| Roses | RoseBlooming | rose_small, rose_large | Two growth stages, not show/garden quality grades. 519 overhead farm images, two cultivars, COCO annotations; non-commercial research only |
| Chrysanthemum | F-YOLO tea chrysanthemum study | Budding Stage, Early Flowering Stage, Full-Bloom Stage | Study documents three labels, but a reusable archive with those annotations was not verified. Conditional target requiring acquisition or own annotation; not confirmed launch-ready |

VegNet combines ripeness and condition in mutually exclusive folders. A single-label classifier cannot establish both ripe and damaged independently for the same fruit without suitable multi-label annotations. Old, dried, damaged and spoiled must not be treated as interchangeable labels.

## Original source evidence

1. [VegNet v1, Mendeley Data](https://data.mendeley.com/datasets/6nxnjbn9w6/1): four vegetable subsets, five condition labels per vegetable, 6,850 images overall; CC BY 4.0. The total is not the count for tomato or chilli individually.
2. [NCHU tomato ripeness dataset](https://aidata.nchu.edu.tw/smarter/en/dataset/smarter_08_pmml02_0_gsdf_20240820_htry_jtyrkt): six documented classes in YOLO format; access/licensing text restricts use to permitted academic research. Not the default unrestricted deployment dataset.
3. [Spoiled and fresh fruit inspection v1, Mendeley Data](https://data.mendeley.com/datasets/6ps7gtp2wg/1): eight fruit types including orange/lemon, 2,000 images per fruit, half fresh and half non-fresh/spoiled; CC BY 4.0.
4. [Citrus quality original paper](https://www.mdpi.com/2624-7402/7/9/286): three labels and [author-linked Kaggle data](https://www.kaggle.com/datasets/moussaid/citrus-quality-classification). The Kaggle page did not expose readable file metadata through this review. The paper explicitly distinguishes attention coverage from measured fruit properties; Grad-CAM coverage is not a validated defect-area measurement.
5. [BananaImageBD v2](https://data.mendeley.com/datasets/ptfscwtnyz/2): four ripeness labels and original/augmented counts; CC BY 4.0.
6. [BananaID v1](https://data.mendeley.com/datasets/h6n5srjjyw/1): four ripeness labels and five banana varieties; CC BY 4.0.
7. [RoseBlooming author repository](https://github.com/dahlian00/RoseBlooming-Dataset): two labels, 519 images, COCO format, linked dataset and explicit non-commercial research restriction. User-facing wording such as early/later bloom needs a documented mapping against annotation definitions.
8. [Tea chrysanthemum F-YOLO paper](https://www.mdpi.com/2073-4395/11/5/834): its table reports budding/early/full-bloom annotations. The data availability statement does not establish downloadable access; do not list the dataset as acquired.
9. [Public tea chrysanthemum outdoor-scene dataset paper](https://www.frontiersin.org/journals/plant-science/articles/10.3389/fpls.2023.1134911/full): links [deposited data DOI](https://doi.org/10.21227/vc18-rv06), six tea types and 18,000 annotated images. Published text does not verify the required flowering-stage label vocabulary. A flower detection/cultivar dataset is not automatically a bloom-stage dataset.
10. [BDFlower dataset v2](https://data.mendeley.com/datasets/m8g2wynwyr/2) and [original paper](https://pmc.ncbi.nlm.nih.gov/articles/PMC13123495/): early/mid/full stages for eight species, but the paper's species list includes neither roses nor chrysanthemums. Exclude as direct evidence for those two crop models.

## Outputs the reviewed categorical labels do not establish

- Exact harvest time, days to maturity or remaining shelf-life: require longitudinal outcome data, capture time and relevant storage/growing conditions. A ripe label alone does not provide a number of days.
- Sugar content, acidity, sugar-acid balance, taste, internal quality or food safety: require corresponding measurements/validation beyond visual categories.
- Percentage physically damaged: requires appropriate defect/fruit segmentation masks or measured area ground truth. Classifier confidence and explanation heatmaps are not substitutes.
- Grade A/B/C/Reject, export/domestic grade, exhibition/commercial-cut grade: require an explicit grading rubric and matching ground-truth labels. Three quality classes cannot supply four grades by renaming.
- Seven banana stages: four-stage source labels do not establish seven distinct targets.
- Rose pristine/pest-damaged/spent-bloom classes or chrysanthemum exhibition/imperfect grades: not supported by the verified candidate flower-stage labels.
- Healthy plant or disease absence: fruit/flower quality labels do not establish overall plant health; disease inference remains a separate task.

## SRS changes recommended for review

Replace the universal A/B/C/Reject quality vocabulary and mandatory numeric ripeness/defect/shelf-life outputs with a crop-specific class identifier and plain-language label. Keep crop, task, model version, timestamp, class probabilities/confidence and uncertainty state. Add optional fields only after the training data and validation support them.

Suggested requirement: The system shall classify visual condition, ripeness or flowering stage using the approved label map for the selected crop and model version. It shall not display an unvalidated numerical estimate or commercial grade as a model result.

For flowers, explicitly call the initial capability flowering-stage assessment. RoseBlooming remains conditional on permitted use, annotation preparation and local testing. Chrysanthemum quality-model acceptance depends on obtaining and validating stage-labelled data. The user's six-crop/twelve-model scope is retained; this gap is a delivery dependency, not an implicit crop removal.

## Data acceptance checks before final selection

Confirm access and permitted use, inspect actual class directories/annotation files, count original images per class, group related plant/fruit/video captures before splitting, keep augmented derivatives out of different evaluation splits, review ambiguous labels and independently test Sri Lankan cultivars under smartphone field conditions. Detection annotations may be used to prepare instance crops for classification; this does not automatically create defect masks or new labels.

For this review, no full dataset was downloaded and no training, benchmark or licence suitability determination was performed. Access and dataset-card labels are candidates for engineering review, not a deployment guarantee.
