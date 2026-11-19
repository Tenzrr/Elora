"""Create a repeatable 50-image-per-class visual review queue."""

import csv
import random
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
MANIFEST = HERE / "evidence" / "dataset_manifest.csv"
OUTPUT = HERE / "visual_review_queue.csv"
SEED = 45
SAMPLES_PER_CLASS = 50


def main() -> None:
    with MANIFEST.open(newline="", encoding="utf-8") as source:
        rows = list(csv.DictReader(source))

    by_label = defaultdict(list)
    for row in rows:
        if row["split"] != "excluded":
            by_label[row["label_id"]].append(row)

    rng = random.Random(SEED)
    selected = []
    for label in sorted(by_label):
        candidates = sorted(by_label[label], key=lambda row: row["original_path"])
        if len(candidates) < SAMPLES_PER_CLASS:
            raise ValueError(f"{label} has only {len(candidates)} eligible originals")
        selected.extend(rng.sample(candidates, SAMPLES_PER_CLASS))

    columns = [
        "review_id", "label_id", "source_label", "original_path", "sha256", "split",
        "leaf_visible", "obvious_image_or_identifier_issue", "technical_reviewer",
        "technical_notes", "agronomy_label_assessment", "agronomy_reviewer",
    ]
    with OUTPUT.open("w", newline="", encoding="utf-8") as destination:
        writer = csv.DictWriter(destination, fieldnames=columns)
        writer.writeheader()
        for number, row in enumerate(selected, start=1):
            writer.writerow({
                "review_id": f"TOM-{number:03d}",
                "label_id": row["label_id"],
                "source_label": row["source_label"],
                "original_path": row["original_path"],
                "sha256": row["sha256"],
                "split": row["split"],
            })

    print(f"Wrote {len(selected)} review rows to {OUTPUT}")
    for label in sorted(by_label):
        print(f"{label}: {SAMPLES_PER_CLASS} of {len(by_label[label])}")


if __name__ == "__main__":
    main()
