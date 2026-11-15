import io

import pytest
from fastapi import HTTPException
from PIL import Image

from app.shared.images import validate_image


def test_decode_reencode_and_invalid_uploads():
    stream = io.BytesIO()
    image = Image.new("RGB", (32, 24))
    image.save(stream, "PNG")
    result = validate_image(stream.getvalue())
    with Image.open(io.BytesIO(result)) as decoded:
        assert decoded.format == "JPEG"
        assert decoded.size == (32, 24)
        assert not decoded.getexif()
    for data in [b"", b"fake", b"\\xff\\xd8\\xffbroken", b"a" * (10 * 1024 * 1024 + 1)]:
        with pytest.raises(HTTPException):
            validate_image(data)


def test_oversized_decoded_image_is_rejected():
    stream = io.BytesIO()
    Image.new("L", (5000, 4001)).save(stream, "PNG")
    with pytest.raises(HTTPException):
        validate_image(stream.getvalue())
