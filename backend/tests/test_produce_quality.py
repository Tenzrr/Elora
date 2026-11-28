import json
from pathlib import Path

import pytest
from fastapi import HTTPException
from jsonschema import Draft202012Validator, FormatChecker

from app.modules.produce_quality import (
    FIXTURE_FILES,
    SUPPORTED_SUBTYPES,
    load_fixture,
    load_fixtures,
    validate_subtype,
)

ROOT = Path(__file__).resolve().parents[2]
MODEL_CONTRACT = ROOT / "shared/schemas/model_contract.json"
WARNING_PREFIX = "LABELLED FIXTURE (fixture-v0):"
EXPECTED = {
    "fresh": ("assessed", "fresh", 0.91),
    "spoiled": ("assessed", "spoiled", 0.88),
    "abstention": ("unable_to_assess", None, None),
}


@pytest.mark.parametrize(("name", "outcome", "label", "confidence"), [
    (name, *expected) for name, expected in EXPECTED.items()
])
def test_citrus_quality_fixture_metadata(name, outcome, label, confidence):
    fixture = load_fixture(name)
    assert fixture["crop_slug"] == "citrus"
    assert fixture["task"] == "quality"
    assert fixture["model_id"] == "citrus-quality-fixture"
    assert fixture["model_version"] == "fixture-v0"
    assert fixture["origin"] == "server"
    assert fixture["outcome"] == outcome
    assert fixture["label_id"] == label
    assert fixture["confidence"] == confidence
    assert fixture["warnings"][0].startswith(WARNING_PREFIX)
    if outcome == "unable_to_assess":
        assert fixture["reason"]
        assert fixture["top_predictions"] == []
    else:
        assert fixture["top_predictions"]
        assert fixture["top_predictions"][0]["label_id"] == label
        assert fixture["top_predictions"][0]["confidence"] == confidence


def test_all_citrus_quality_fixtures_match_model_contract():
    schema = json.loads(MODEL_CONTRACT.read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    validator = Draft202012Validator(schema, format_checker=FormatChecker())
    fixtures = load_fixtures()
    assert set(fixtures) == set(FIXTURE_FILES) == set(EXPECTED)
    for fixture in fixtures.values():
        validator.validate(fixture)


@pytest.mark.parametrize("subtype", sorted(SUPPORTED_SUBTYPES))
def test_supported_citrus_subtypes(subtype):
    assert validate_subtype(subtype) == subtype


@pytest.mark.parametrize("subtype", [None, "", "lime", "mandarin", "grapefruit", "ORANGE"])
def test_unsupported_citrus_subtypes_fail_with_422(subtype):
    with pytest.raises(HTTPException) as caught:
        validate_subtype(subtype)
    assert caught.value.status_code == 422
    assert caught.value.detail["code"] == "INVALID_SUBTYPE"


def test_unknown_fixture_name_is_rejected():
    with pytest.raises(KeyError):
        load_fixture("missing")
