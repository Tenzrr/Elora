from datetime import datetime, timezone
import httpx

from app.modules.predictive_farming.schemas import (
    CurrentWeather,
    DailyForecast,
    FarmingAdvisory,
    WeatherForecastResponse,
    WeatherUnits,
)

OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast"
RAIN_DELAY_THRESHOLD_MM = 5.0
MAX_STALE_AGE_SECONDS = 7200  # 2 hours in seconds (BR-03)


def evaluate_irrigation_advisory(
    precipitation_sum_mm: float,
    location_name: str,
    data_age_seconds: float = 0.0,
) -> FarmingAdvisory:
    """Evaluate explainable irrigation advice based on rainfall and data freshness (BR-03 / REQ-3.4)."""
    # Safety Check: Prohibit new recommendations if weather is older than 2 hours
    if data_age_seconds > MAX_STALE_AGE_SECONDS:
        return FarmingAdvisory(
            action="ADVISORY_WITHHELD",
            title="Advisory Withheld (Stale Weather)",
            reasoning=(
                f"Weather forecast data for {location_name} is older than 2 hours "
                f"({int(data_age_seconds // 60)} minutes old). Newly generated weather-dependent "
                "care advice is prohibited until fresh forecast data is retrieved."
            ),
            precipitation_expected_mm=precipitation_sum_mm,
            threshold_mm=RAIN_DELAY_THRESHOLD_MM,
        )

    # Agronomic Rule: If expected rain >= 5.0 mm, natural rain is sufficient
    if precipitation_sum_mm >= RAIN_DELAY_THRESHOLD_MM:
        return FarmingAdvisory(
            action="DELAY_IRRIGATION",
            title="Delay Irrigation",
            reasoning=(
                f"Forecast for {location_name} indicates {precipitation_sum_mm:.1f} mm of rainfall "
                f"in the next 24 hours (threshold: {RAIN_DELAY_THRESHOLD_MM:.1f} mm). "
                "Delay scheduled watering to avoid oversaturating soil and conserve water."
            ),
            precipitation_expected_mm=precipitation_sum_mm,
            threshold_mm=RAIN_DELAY_THRESHOLD_MM,
        )

    # Standard Rule: Rain is minimal or zero (< 5.0 mm), proceed with normal care
    return FarmingAdvisory(
        action="NORMAL_WATERING",
        title="Proceed with Normal Care",
        reasoning=(
            f"Forecast for {location_name} indicates minimal or no rainfall "
            f"({precipitation_sum_mm:.1f} mm expected, below the {RAIN_DELAY_THRESHOLD_MM:.1f} mm threshold). "
            "Proceed with your regular morning or evening watering routine."
        ),
        precipitation_expected_mm=precipitation_sum_mm,
        threshold_mm=RAIN_DELAY_THRESHOLD_MM,
    )


async def fetch_weather_forecast(
    latitude: float,
    longitude: float,
    location_name: str = "Colombo",
    client: httpx.AsyncClient | None = None,
) -> WeatherForecastResponse:
    """Fetch live weather from Open-Meteo and return a validated forecast with an explainable advisory."""
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "current": ["temperature_2m", "relative_humidity_2m", "wind_speed_10m", "precipitation", "weather_code"],
        "daily": [
            "temperature_2m_max",
            "temperature_2m_min",
            "precipitation_sum",
            "precipitation_probability_max",
            "weather_code",
        ],
        "timezone": "Asia/Colombo",
    }

    should_close_client = False
    if client is None:
        client = httpx.AsyncClient(timeout=10.0)
        should_close_client = True

    try:
        response = await client.get(OPEN_METEO_URL, params=params)
        response.raise_for_status()
        data = response.json()
    finally:
        if should_close_client:
            await client.aclose()

    retrieval_time = datetime.now(timezone.utc)
    current_raw = data.get("current", {})
    daily_raw = data.get("daily", {})

    current = CurrentWeather(
        temperature=float(current_raw.get("temperature_2m", 0.0)),
        relative_humidity=int(current_raw.get("relative_humidity_2m", 0)),
        wind_speed=float(current_raw.get("wind_speed_10m", 0.0)),
        precipitation=float(current_raw.get("precipitation", 0.0)),
        weather_code=int(current_raw.get("weather_code", 0)),
    )

    daily_list: list[DailyForecast] = []
    dates = daily_raw.get("time", [])
    t_max = daily_raw.get("temperature_2m_max", [])
    t_min = daily_raw.get("temperature_2m_min", [])
    p_sum = daily_raw.get("precipitation_sum", [])
    p_prob = daily_raw.get("precipitation_probability_max", [])
    w_code = daily_raw.get("weather_code", [])

    for i in range(len(dates)):
        daily_list.append(
            DailyForecast(
                date=dates[i],
                temperature_max=float(t_max[i]),
                temperature_min=float(t_min[i]),
                precipitation_sum=float(p_sum[i]),
                precipitation_probability_max=int(p_prob[i]) if p_prob and p_prob[i] is not None else None,
                weather_code=int(w_code[i]),
            )
        )

    # Use today's daily precipitation sum (index 0) for the 24-hour irrigation decision
    today_rain_mm = daily_list[0].precipitation_sum if daily_list else 0.0
    advisory = evaluate_irrigation_advisory(
        precipitation_sum_mm=today_rain_mm,
        location_name=location_name,
        data_age_seconds=0.0,
    )

    return WeatherForecastResponse(
        source="Open-Meteo",
        location_name=location_name,
        latitude=latitude,
        longitude=longitude,
        retrieval_time=retrieval_time,
        forecast_time=retrieval_time,
        is_stale=False,
        units=WeatherUnits(),
        current=current,
        daily=daily_list,
        advisory=advisory,
    )
