from typing import Literal
from fastapi import APIRouter, File, Form, HTTPException, UploadFile, status
from app.modules.crop_health.schemas import CropHealthAnalysisResponse
from app.modules.crop_health.service import CropHealthService

router = APIRouter(prefix="/crop-health", tags=["crop-health"])
service = CropHealthService()


@router.get("/health", summary="Health check for Crop Health Analysis service")
async def crop_health_health() -> dict[str, str]:
    return {"status": "ok", "module": "crop-health", "crops": "tomato,chilli"}


@router.post(
    "/analyze",
    response_model=CropHealthAnalysisResponse,
    summary="Analyze crop leaf photo for disease diagnosis or produce quality grading",
)
async def analyze_crop(
    file: UploadFile = File(..., description="Captured plant photo (JPEG or PNG)"),
    crop_slug: str = Form("tomato", description="Target crop: 'tomato' or 'chilli'"),
    task: Literal["disease", "quality"] = Form("disease", description="Inference task: 'disease' or 'quality'"),
) -> CropHealthAnalysisResponse:
    crop = crop_slug.strip().lower()
    if crop not in ["tomato", "chilli"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Crop '{crop_slug}' is not supported by Crop Health module. Supported: tomato, chilli.",
        )

    # Validate file type
    if file.content_type not in ["image/jpeg", "image/png", "image/webp", "application/octet-stream"]:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Uploaded file must be a JPEG or PNG image.",
        )

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Uploaded image file is empty.",
        )

    response = await service.analyze(
        image_bytes=image_bytes,
        crop_slug=crop,
        task=task,
    )
    return response
