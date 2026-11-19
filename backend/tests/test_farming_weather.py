from unittest.mock import AsyncMock, patch
import httpx
import pytest

from app.modules.predictive_farming.service import (
    clear_forecast_cache,
    evaluate_irrigation_advisory,
    fetch_weather_forecast,
)
from tests.conftest import signed_in

SAMPLE_OPEN_METEO_PAYLOAD = {
    "current": {
        "temperature_2m": 29.5,
        "relative_humidity_2m": 78,
        "wind_speed_10m": 12.0,
        "precipitation": 0.0,
        "weather_code": 1,
    },
    "daily": {
        "time": ["2026-11-18", "2026-11-19"],
        "temperature_2m_max": [31.0, 30.5],
        "temperature_2m_min": [25.0, 24.5],
        "precipitation_sum": [2.0, 6.5],
        "precipitation_probability_max": [40, 85],
        "weather_code": [1, 61],
    },
}


def make_mock_response():
    """Create httpx.Response with associated request so raise_for_status succeeds."""
    return httpx.Response(
        200,
        json=SAMPLE_OPEN_METEO_PAYLOAD,
        request=httpx.Request("GET", "https://api.open-meteo.com/v1/forecast"),
    )


@pytest.fixture(autouse=True)
def clean_cache():
    """Ensure in-memory cache is wiped before and after each test."""
    clear_forecast_cache()
    yield
    clear_forecast_cache()


def test_advisory_delay_irrigation_when_rain_exceeds_threshold():
    """BR-13 / REQ-3.4: Rain >= 5.0 mm must advise DELAY_IRRIGATION with explanation."""
    advisory = evaluate_irrigation_advisory(
        precipitation_sum_mm=8.2,
        location_name="Colombo",
        data_age_seconds=0.0,
    )
    assert advisory.action == "DELAY_IRRIGATION"
    assert advisory.title == "Delay Irrigation"
    assert "8.2 mm" in advisory.reasoning
    assert advisory.threshold_mm == 5.0
    assert advisory.precipitation_expected_mm == 8.2


def test_advisory_normal_watering_when_rain_below_threshold():
    """BR-13 / REQ-3.4: Rain < 5.0 mm must advise NORMAL_WATERING with explanation."""
    advisory = evaluate_irrigation_advisory(
        precipitation_sum_mm=1.2,
        location_name="Colombo",
        data_age_seconds=0.0,
    )
    assert advisory.action == "NORMAL_WATERING"
    assert advisory.title == "Proceed with Normal Care"
    assert "1.2 mm" in advisory.reasoning
    assert advisory.threshold_mm == 5.0


def test_advisory_withheld_when_weather_stale_over_two_hours():
    """BR-03 / REQ-3.6: Prohibit new recommendations when weather data is older than 2 hours."""
    advisory = evaluate_irrigation_advisory(
        precipitation_sum_mm=10.0,
        location_name="Kandy",
        data_age_seconds=7500.0,  # 2 hours 5 mins
    )
    assert advisory.action == "ADVISORY_WITHHELD"
    assert advisory.title == "Advisory Withheld (Stale Weather)"
    assert "older than 2 hours" in advisory.reasoning


@pytest.mark.asyncio
async def test_forecast_caching_serves_cached_data_within_15_minutes():
    """BR-03: Consecutive calls within 15 minutes must be served from cache without HTTP calls."""
    mock_client = AsyncMock()
    mock_client.get = AsyncMock(return_value=make_mock_response())

    # First fetch: should make an HTTP request and cache it
    first_result = await fetch_weather_forecast(
        latitude=6.9271,
        longitude=79.8612,
        location_name="Colombo",
        client=mock_client,
    )
    assert mock_client.get.call_count == 1
    assert first_result.current.temperature == 29.5
    assert first_result.is_stale is False

    # Second fetch: within 15 minutes should hit cache, NOT mock_client.get
    second_result = await fetch_weather_forecast(
        latitude=6.9271,
        longitude=79.8612,
        location_name="Colombo",
        client=mock_client,
    )
    assert mock_client.get.call_count == 1  # call count stayed 1!
    assert second_result.current.temperature == 29.5


def test_api_get_farming_weather_authenticated(api):
    """REQ-3.2: Endpoint requires auth and returns validated forecast response."""
    client, _, _ = api
    headers = signed_in(client, "alice")

    with patch("httpx.AsyncClient.get", new_callable=AsyncMock) as mock_get:
        mock_get.return_value = make_mock_response()
        response = client.get("/api/v1/farming/weather?location=Colombo", headers=headers)
        assert response.status_code == 200
        data = response.json()

        assert data["location_name"] == "Colombo"
        assert data["source"] == "Open-Meteo"
        assert data["units"]["temperature"] == "°C"
        assert data["units"]["precipitation"] == "mm"
        assert data["units"]["wind_speed"] == "km/h"
        assert data["units"]["humidity"] == "%"
        assert data["current"]["temperature"] == 29.5
        assert data["advisory"]["action"] == "NORMAL_WATERING"


def test_api_get_farming_weather_manual_location(api):
    """REQ-3.1: Manual location selection without GPS returns location-specific weather."""
    client, _, _ = api
    headers = signed_in(client, "alice")

    with patch("httpx.AsyncClient.get", new_callable=AsyncMock) as mock_get:
        mock_get.return_value = make_mock_response()
        response = client.get("/api/v1/farming/weather?location=Kandy", headers=headers)
        assert response.status_code == 200
        data = response.json()
        assert data["location_name"] == "Kandy"
        assert round(data["latitude"], 2) == 7.29
        assert round(data["longitude"], 2) == 80.63


def test_api_get_farming_weather_validates_coordinates(api):
    """FastAPI validation: out-of-bounds latitude rejected with HTTP 422."""
    client, _, _ = api
    headers = signed_in(client, "alice")

    response = client.get("/api/v1/farming/weather?latitude=999.0&longitude=80.0", headers=headers)
    assert response.status_code == 422
