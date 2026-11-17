from typing import Annotated
from fastapi import APIRouter, Depends, Query

from app.core.auth import Actor, current_actor
from app.modules.predictive_farming.schemas import WeatherForecastResponse
from app.modules.predictive_farming.service import fetch_weather_forecast

router = APIRouter(prefix="/api/v1/farming", tags=["predictive-farming"])

# Predefined coordinates for manual area selection (REQ-3.1)
PRESET_LOCATIONS = {
    "Colombo": (6.9271, 79.8612),
    "Kandy": (7.2906, 80.6337),
    "Gampaha": (7.0840, 79.9939),
    "Jaffna": (9.6615, 80.0255),
    "Matara": (5.9549, 80.5550),
}


@router.get("/weather", response_model=WeatherForecastResponse)
async def get_farming_weather(
    actor: Annotated[Actor, Depends(current_actor)],
    location: Annotated[str | None, Query(description="Preset location name (e.g. Colombo, Kandy)")] = None,
    latitude: Annotated[float | None, Query(ge=-90.0, le=90.0, description="Optional custom latitude")] = None,
    longitude: Annotated[float | None, Query(ge=-180.0, le=180.0, description="Optional custom longitude")] = None,
) -> WeatherForecastResponse:
    """Fetch live weather forecast and explainable care advisory for a selected location."""
    # Resolve location name and coordinates
    if location and location in PRESET_LOCATIONS:
        lat, lon = PRESET_LOCATIONS[location]
        resolved_name = location
    elif latitude is not None and longitude is not None:
        lat, lon = latitude, longitude
        resolved_name = location or f"{lat:.2f}, {lon:.2f}"
    else:
        # Default fallback to Colombo (Western Province)
        lat, lon = PRESET_LOCATIONS["Colombo"]
        resolved_name = "Colombo"

    return await fetch_weather_forecast(
        latitude=lat,
        longitude=lon,
        location_name=resolved_name,
    )
