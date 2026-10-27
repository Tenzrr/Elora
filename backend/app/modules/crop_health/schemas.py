from datetime import datetime, timezone
from typing import List, Literal, Optional
from pydantic import BaseModel, Field


class PredictionItem(BaseModel):
    label: str = Field(..., description="Predicted class or defect label")
    confidence: float = Field(..., ge=0.0, le=1.0, description="Softmax confidence probability")


class RecoveryStep(BaseModel):
    step_number: int = Field(..., ge=1, le=5)
    icon: str = Field(..., description="Icon identifier: 'shears', 'airflow', 'expert'")
    title: str = Field(..., description="Short action summary")
    description: str = Field(..., description="Detailed cultural or biological instruction")


class CropHealthAnalysisResponse(BaseModel):
    session_id: str
    crop_slug: Literal["tomato", "chilli"]
    task: Literal["disease", "quality"]
    detected_label: str
    botanical_pathogen: Optional[str] = None
    confidence: float = Field(..., ge=0.0, le=1.0)
    severity_level: Literal["healthy", "low", "moderate", "severe"]
    visible_symptoms: List[str]
    recovery_steps: List[RecoveryStep]
    top_predictions: List[PredictionItem]
    advisory_footnote: str
    model_version: str
    created_at: str


class DiagnosisHistoryItem(BaseModel):
    session_id: str
    crop_slug: str
    task: str
    detected_label: str
    confidence: float
    severity_level: str
    created_at: str
