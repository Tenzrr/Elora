from datetime import datetime
from typing import List, Literal, Optional
from uuid import UUID
from pydantic import BaseModel, ConfigDict, Field


class WeatherUnits(BaseModel):
    temperature: str = "°C"
    precipitation: str = "mm"
    wind_speed: str = "km/h"
    humidity: str = "%"


class CurrentWeather(BaseModel):
    temperature: float = Field(..., description="Current temperature in degrees Celsius")
    relative_humidity: int = Field(..., description="Relative humidity percentage (0-100)")
    wind_speed: float = Field(..., description="Wind speed in kilometers per hour")
    precipitation: float = Field(..., description="Current precipitation in millimeters")
    weather_code: int = Field(..., description="WMO weather interpretation code")


class DailyForecast(BaseModel):
    date: str = Field(..., description="Forecast date formatted as YYYY-MM-DD")
    temperature_max: float = Field(..., description="Maximum temperature in degrees Celsius")
    temperature_min: float = Field(..., description="Minimum temperature in degrees Celsius")
    precipitation_sum: float = Field(..., description="Total forecasted precipitation in mm")
    precipitation_probability_max: Optional[int] = Field(
        None, description="Maximum probability of precipitation percentage"
    )
    weather_code: int = Field(..., description="WMO weather interpretation code")


class FarmingAdvisory(BaseModel):
    action: Literal["DELAY_IRRIGATION", "NORMAL_WATERING", "ADVISORY_WITHHELD"] = Field(
        ..., description="The recommended farming care action"
    )
    title: str = Field(..., description="Short user-friendly headline for the advisory")
    reasoning: str = Field(..., description="Detailed explanation of the rule basis and inputs")
    precipitation_expected_mm: float = Field(
        ..., description="Total rainfall expected in the next 24 hours used in the evaluation"
    )
    threshold_mm: float = Field(
        default=5.0, description="Rainfall threshold in mm that triggers delaying irrigation"
    )
    missing_context_notice: Optional[str] = Field(
        default="General field assumptions applied. Specific soil and pot context omitted.",
        description="Disclaimer detailing limits of optional context",
    )


class WeatherForecastResponse(BaseModel):
    source: str = Field(default="Open-Meteo", description="Name of the forecast data provider")
    location_name: str = Field(..., description="Human-readable name of the selected area")
    latitude: float = Field(..., description="Latitude coordinate of the location")
    longitude: float = Field(..., description="Longitude coordinate of the location")
    retrieval_time: datetime = Field(..., description="Timestamp when data was retrieved from provider")
    forecast_time: datetime = Field(..., description="Timestamp of the forecast model run")
    is_stale: bool = Field(default=False, description="True if cached data is older than 15 minutes")
    units: WeatherUnits = Field(default_factory=WeatherUnits, description="Explicit units of measurement")
    current: CurrentWeather = Field(..., description="Current weather metrics")
    daily: List[DailyForecast] = Field(..., description="7-day daily forecast breakdown")
    advisory: FarmingAdvisory = Field(..., description="Rule-based explainable farming advisory")


# --- Plant Care Tasks & Logs (REQ-3.5 / Issue #70) ---

TaskType = Literal["watering", "fertilizer", "pruning", "harvest", "pest_control"]
TaskStatus = Literal["pending", "completed", "skipped", "cancelled"]


class CareTaskCreate(BaseModel):
    plant_id: Optional[UUID] = Field(default=None, description="Optional plant ID the task is scheduled for")
    task_type: TaskType = Field(default="watering", description="Type of care task")
    title: str = Field(..., min_length=1, max_length=160, description="Short title for the task")
    description: Optional[str] = Field(default=None, max_length=1000, description="Care details or notes")
    due_date: datetime = Field(..., description="Scheduled due date/time for the task")
    advisory_rationale: Optional[str] = Field(
        default=None, max_length=500, description="Explainable weather advisory rationale if scheduled from advice"
    )


class CareTaskAction(BaseModel):
    notes: Optional[str] = Field(default=None, max_length=1000, description="Grower notes when completing/skipping")


class CareTaskView(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    plant_id: Optional[UUID] = None
    task_type: str
    title: str
    description: Optional[str] = None
    due_date: datetime
    status: str
    advisory_rationale: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class CareLogView(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    task_id: Optional[UUID] = None
    user_id: UUID
    plant_id: Optional[UUID] = None
    action_taken: str
    notes: Optional[str] = None
    logged_at: datetime

