import io
import warnings

from PIL import Image, ImageOps, UnidentifiedImageError

from app.core.errors import fail

MAX_BYTES = 10 * 1024 * 1024
MAX_PIXELS = 20_000_000
Image.MAX_IMAGE_PIXELS = MAX_PIXELS


def validate_image(data: bytes):
    if not data or len(data) > MAX_BYTES:
        fail(422, "INVALID_IMAGE", "Image must contain at most 10 MiB.")
    signatures = (
        data.startswith(b"\xff\xd8\xff"),
        data.startswith(b"\x89PNG\r\n\x1a\n"),
        data.startswith(b"RIFF") and data[8:12] == b"WEBP",
    )
    if not any(signatures):
        fail(422, "INVALID_IMAGE", "Use a decoded JPEG, PNG or WebP image.")
    try:
        with warnings.catch_warnings():
            warnings.simplefilter("error", Image.DecompressionBombWarning)
            with Image.open(io.BytesIO(data)) as source:
                if source.format not in {"JPEG", "PNG", "WEBP"}:
                    raise ValueError("Unsupported image format")
                if source.width * source.height > MAX_PIXELS or getattr(source, "n_frames", 1) != 1:
                    raise ValueError("Image dimensions or animation are unsupported")
                source.verify()
            with Image.open(io.BytesIO(data)) as source:
                image = ImageOps.exif_transpose(source).convert("RGB")
                image.load()
                output = io.BytesIO()
                image.save(output, format="JPEG", quality=90)
                return output.getvalue()
    except (UnidentifiedImageError, OSError, ValueError, Image.DecompressionBombError,
            Image.DecompressionBombWarning):
        fail(422, "INVALID_IMAGE", "The image could not be safely decoded.")
