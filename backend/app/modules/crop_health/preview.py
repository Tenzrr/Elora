"""Optional, non-persisted research preview of the recorded tomato baseline."""

import hashlib
from functools import lru_cache
from io import BytesIO
from pathlib import Path

from PIL import Image, ImageOps

LABELS = (
    "early_blight", "late_blight", "septoria_leaf_spot", "leaf_mold",
    "yellow_leaf_curl_virus", "healthy",
)
CHECKPOINT_SHA256 = "97eb4c15089fdc78ef25a7512f094310bf2ff6e2bcfb56c222193f0bfd2f80c3"


@lru_cache(maxsize=1)
def _model(path: str):
    import tensorflow as tf

    checkpoint = Path(path)
    if hashlib.sha256(checkpoint.read_bytes()).hexdigest() != CHECKPOINT_SHA256:
        raise ValueError("Tomato checkpoint checksum does not match the recorded baseline")
    return tf.keras.models.load_model(checkpoint, compile=False)


def predict_leaf(path: str, jpeg: bytes) -> str:
    import numpy as np
    import tensorflow as tf

    # Match the training notebook: RGB pixels in 0–255, then resize with padding.
    # The validated bytes are decoded directly to avoid a second lossy JPEG encode.
    image = np.asarray(ImageOps.exif_transpose(Image.open(BytesIO(jpeg))).convert("RGB"))
    batch = tf.expand_dims(tf.image.resize_with_pad(image, 224, 224), 0)
    scores = _model(path)(batch, training=False).numpy()[0]
    if scores.shape != (len(LABELS),) or not np.all(np.isfinite(scores)):
        raise ValueError("Tomato checkpoint returned invalid scores")
    return LABELS[int(np.argmax(scores))]
