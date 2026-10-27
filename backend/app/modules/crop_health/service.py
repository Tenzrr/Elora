import uuid
from typing import Dict, List, Literal, Tuple
from ai.models.crop_health_classifier import CropHealthClassifier
from app.modules.crop_health.schemas import (
    CropHealthAnalysisResponse,
    PredictionItem,
    RecoveryStep,
)


class CropHealthService:
    """Business logic and agronomic knowledge retrieval for Crop Health Analysis."""

    def __init__(self, classifier: CropHealthClassifier | None = None) -> None:
        self.classifier = classifier or CropHealthClassifier()

    # Agronomic dictionary mapping detected labels to botanical info, symptoms, and 3-step action plans
    KNOWLEDGE_BASE: Dict[str, Dict[str, object]] = {
        # Tomato Diseases
        "Early Blight": {
            "pathogen": "Alternaria solani",
            "severity": "moderate",
            "symptoms": ["Dark concentric target spots", "Yellow leaf margins", "Lower foliage dieback"],
            "steps": [
                ("shears", "Remove badly affected leaves", "Bag and discard infected foliage; clean and sanitize pruning shears with alcohol."),
                ("airflow", "Keep leaves dry & improve airflow", "Water strictly at the soil base in the morning; prune dense suckers to enhance ventilation."),
                ("expert", "Confirm before treating", "If brown spots spread to green stems, apply organic copper-based fungicide or ask a local extension officer."),
            ],
        },
        "Late Blight": {
            "pathogen": "Phytophthora infestans",
            "severity": "severe",
            "symptoms": ["Water-soaked dark lesions", "White fuzzy spore growth on undersides", "Rapid leaf collapse"],
            "steps": [
                ("shears", "Immediately prune blighted tissue", "Cut out affected foliage and fruit immediately; seal in airtight bags to prevent spore travel."),
                ("airflow", "Eliminate overhead sprinkler watering", "Ensure canopy dries quickly; keep foliage isolated from neighboring Solanaceae."),
                ("expert", "Consult agricultural specialist", "Late blight moves aggressively in cool, humid conditions; consider targeted protective bio-fungicide."),
            ],
        },
        "Septoria Leaf Spot": {
            "pathogen": "Septoria lycopersici",
            "severity": "moderate",
            "symptoms": ["Small circular grey-centered spots", "Tiny black fruiting specks (pycnidia)", "Premature leaf drop"],
            "steps": [
                ("shears", "Prune lower infected leaves", "Remove any leaves within 30cm of the soil level where fungal spores splash."),
                ("airflow", "Apply dry straw mulch", "Mulch around tomato stems to block rain-splashing from soil; improve row spacing."),
                ("expert", "Confirm and monitor weekly", "Inspect newly emerging canopy weekly for circular spotting before considering organic sprays."),
            ],
        },
        "Yellow Leaf Curl": {
            "pathogen": "Tomato Yellow Leaf Curl Virus (TYLCV)",
            "severity": "severe",
            "symptoms": ["Upward leaf curling", "Marginal chlorosis (yellowing)", "Severely stunted terminal growth"],
            "steps": [
                ("shears", "Isolate or rogue out infected plants", "Viruses cannot be cured; remove symptomatic plants to protect neighboring crops."),
                ("airflow", "Control whitefly vectors", "Install yellow sticky traps and apply insecticidal soap or neem oil against whiteflies."),
                ("expert", "Select resistant varieties", "Consult extension guides for TYLCV-resistant hybrids for subsequent planting cycles."),
            ],
        },
        "Healthy": {
            "pathogen": None,
            "severity": "healthy",
            "symptoms": ["Vibrant green foliage", "No visible lesions or chlorosis", "Strong turgor pressure"],
            "steps": [
                ("shears", "Routine maintenance", "Gently remove old, senescent bottom leaves touching moist soil to maintain vigor."),
                ("airflow", "Maintain steady watering schedule", "Keep soil consistently moist without waterlogging to support optimal fruit set."),
                ("expert", "Continue proactive monitoring", "Inspect foliage weekly to spot any emerging pests or environmental stress early."),
            ],
        },
        # Chilli Diseases
        "Anthracnose": {
            "pathogen": "Colletotrichum capsici",
            "severity": "moderate",
            "symptoms": ["Sunken dark circular lesions", "Orange/black spore rings", "Fruit and leaf rotting"],
            "steps": [
                ("shears", "Remove infected foliage & pods", "Prune diseased peppers and spotted leaves; disinfect cutting tools between plants."),
                ("airflow", "Improve sun exposure and drainage", "Ensure chilli beds have well-draining soil; avoid overhead evening watering."),
                ("expert", "Apply bio-fungicide if persistent", "Spray neem extract or copper hydroxide if lesions spread across fruit clusters."),
            ],
        },
        "Bacterial Leaf Spot": {
            "pathogen": "Xanthomonas campestris pv. vesicatoria",
            "severity": "moderate",
            "symptoms": ["Small water-soaked leaf spots", "Dark brown lesions with yellow halos", "Premature defoliation"],
            "steps": [
                ("shears", "Sanitize hands and cutting tools", "Do not handle wet plants; strip defoliated diseased leaves from bed floor."),
                ("airflow", "Avoid overhead irrigation", "Water at root drip line to eliminate leaf moisture necessary for bacterial ingress."),
                ("expert", "Confirm bacterial origin", "If symptoms progress, apply copper bactericide formulated for peppers."),
            ],
        },
        "Leaf Curl": {
            "pathogen": "Chilli Leaf Curl Virus (ChiLCV)",
            "severity": "severe",
            "symptoms": ["Upward leaf cupping", "Vein thickening", "Puckered, stunted shoot growth"],
            "steps": [
                ("shears", "Prune severely deformed stems", "Trim back non-productive distorted shoot tips to stimulate clean lateral growth."),
                ("airflow", "Suppress thrips and whiteflies", "Spray horticultural oil or dilute neem soap to suppress sap-sucking vector insects."),
                ("expert", "Plan crop rotation", "Avoid replanting peppers in the same bed in succession to break the viral vector cycle."),
            ],
        },
        "Phytophthora": {
            "pathogen": "Phytophthora capsici",
            "severity": "severe",
            "symptoms": ["Dark water-soaked stem collar", "Sudden irreversible wilting", "Root and crown rot"],
            "steps": [
                ("shears", "Immediately pull collapsed plants", "Remove entire root ball of collapsed plants; do not compost in home gardens."),
                ("airflow", "Improve bed elevation and drainage", "Construct raised beds and reduce irrigation volume to lower soil saturation."),
                ("expert", "Drench with bio-control agents", "Inoculate adjacent healthy soil with beneficial Trichoderma harzianum fungi."),
            ],
        },
    }

    async def analyze(
        self,
        image_bytes: bytes,
        crop_slug: str,
        task: Literal["disease", "quality"] = "disease",
    ) -> CropHealthAnalysisResponse:
        """Executes model inference and maps findings to authoritative recovery protocols."""
        model_result = self.classifier.predict(
            image_bytes=image_bytes,
            crop_slug=crop_slug,
            model_task=task,
        )

        label = model_result["label"]
        info = self.KNOWLEDGE_BASE.get(label, {
            "pathogen": None,
            "severity": "moderate" if label != "Healthy" else "healthy",
            "symptoms": ["Atypical leaf pigmentation", "Surface discoloration"],
            "steps": [
                ("shears", "Isolate affected leaf tissue", "Carefully prune damaged areas using sanitized shears."),
                ("airflow", "Optimize environmental airflow", "Ensure adequate spacing and avoid wetting leaf surfaces."),
                ("expert", "Consult an agronomist", "Confirm symptoms with local extension experts before applying treatments."),
            ],
        })

        # Build recovery step objects
        recovery_steps = [
            RecoveryStep(
                step_number=i + 1,
                icon=str(step[0]),
                title=str(step[1]),
                description=str(step[2]),
            )
            for i, step in enumerate(info["steps"])  # type: ignore[arg-type]
        ]

        top_preds = [
            PredictionItem(label=p["label"], confidence=float(p["confidence"]))
            for p in model_result.get("top_predictions", [])
        ]

        session_id = str(uuid.uuid4())
        crop = "tomato" if crop_slug.lower() == "tomato" else "chilli"

        return CropHealthAnalysisResponse(
            session_id=session_id,
            crop_slug=crop,  # type: ignore[arg-type]
            task=task,
            detected_label=label,
            botanical_pathogen=info.get("pathogen"),  # type: ignore[arg-type]
            confidence=float(model_result["confidence"]),
            severity_level=info.get("severity", "moderate"),  # type: ignore[arg-type]
            visible_symptoms=info.get("symptoms", []),  # type: ignore[arg-type]
            recovery_steps=recovery_steps,
            top_predictions=top_preds,
            advisory_footnote="Demo only. Other issues can look similar; a photo alone cannot confirm a disease.",
            model_version=model_result.get("model_version", "v1.0"),
            created_at=model_result.get("created_at", ""),
        )
