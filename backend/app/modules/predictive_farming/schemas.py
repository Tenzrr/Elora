from datetime import datetime
from typing import List, Literal, Optional
from pydantic import BaseModel, Field


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
