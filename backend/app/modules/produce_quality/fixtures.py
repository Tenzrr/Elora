"""Load labelled citrus quality fixtures and enforce supported subtypes."""

import json
from typing import Any

from app import REPO_ROOT
from app.core.errors import fail

SUPPORTED_SUBTYPES: frozenset[str] = frozenset({"orange", "lemon"})
FIXTURE_FILES: dict[str, str] = {
    "fresh": "citrus_quality_fresh.json",
    "spoiled": "citrus_quality_spoiled.json",
    "abstention": "citrus_quality_abstention.json",
}
FIXTURE_DIR = REPO_ROOT / "shared" / "fixtures"


def validate_subtype(subtype: str | None) -> str:
    """Return a supported citrus subtype or fail with the shared API error."""
    if not isinstance(subtype, str) or subtype not in SUPPORTED_SUBTYPES:
        fail(422, "INVALID_SUBTYPE", "Choose orange or lemon for citrus quality.")
    return subtype


def load_fixture(name: str) -> dict[str, Any]:
    """Load one labelled citrus quality fixture by its short name."""
    path = FIXTURE_DIR / FIXTURE_FILES[name]
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def load_fixtures() -> dict[str, dict[str, Any]]:
    """Load all labelled citrus quality fixtures keyed by short name."""
    return {name: load_fixture(name) for name in FIXTURE_FILES}
