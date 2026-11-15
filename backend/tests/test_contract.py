import copy
import json
from pathlib import Path

import pytest
from jsonschema import Draft202012Validator, FormatChecker


def test_assessment_and_abstention_contract():
    schema = json.loads(Path("shared/schemas/model_contract.json").read_text())
    Draft202012Validator.check_schema(schema)
    validator = Draft202012Validator(schema, format_checker=FormatChecker())
    result = {
        "scan_id": "7b78da34-f80b-4de5-8ccf-08f75ac50df2",
        "crop_slug": "tomato", "task": "disease", "model_id": "test-fixture",
        "model_version": "fixture-only", "origin": "server", "outcome": "assessed",
        "assessed_at": "2026-11-15T00:00:00Z", "label_id": "healthy", "confidence": .8,
        "top_predictions": [], "warnings": [], "guidance": [],
    }
    validator.validate(result)
    abstained = {**result, "outcome": "unable_to_assess", "label_id": None,
                 "confidence": None, "reason": "unsupported_input"}
    validator.validate(abstained)
    for bad in [{**result, "confidence": .59}, {**result, "origin": "on_device", "task": "quality"},
                {**abstained, "label_id": "healthy"}, {**result, "severity": "severe"}]:
        assert list(validator.iter_errors(bad))
