import json
from pathlib import Path

from jsonschema import Draft202012Validator, FormatChecker


def test_interim_failure_fixture_is_explicit_and_rejects_fake_results():
    schema = json.loads(Path("shared/schemas/scan_job.json").read_text())
    Draft202012Validator.check_schema(schema)
    validator = Draft202012Validator(schema, format_checker=FormatChecker())
    fixture = json.loads(Path("shared/fixtures/interim_scan_failed.json").read_text())
    validator.validate(fixture)
    for bad in [{**fixture, "result": {"label_id": "healthy", "confidence": .99}},
                {**fixture, "image_retained": True}, {**fixture, "status": "completed"},
                {**fixture, "crop_slug": "citrus"}]:
        assert list(validator.iter_errors(bad))
    validator.validate({**fixture, "crop_slug": "citrus", "task": "quality", "subtype": "orange"})
