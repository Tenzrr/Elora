from datetime import datetime, timezone
from uuid import UUID
import httpx
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import fail
from app.db.models import CareLog, CareTask, Plant
from app.modules.predictive_farming.schemas import (
    CareTaskCreate,
    CurrentWeather,
    DailyForecast,
    FarmingAdvisory,
    WeatherForecastResponse,
    WeatherUnits,
)


OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast"
RAIN_DELAY_THRESHOLD_MM = 5.0
CACHE_TTL_SECONDS = 900.0  # 15 minutes (BR-03)
MAX_STALE_AGE_SECONDS = 7200.0  # 2 hours (BR-03)
MAX_DISPLAY_AGE_SECONDS = 86400.0  # 24 hours (BR-03)

# In-memory forecast cache: (round(lat, 4), round(lon, 4)) -> (retrieval_time, WeatherForecastResponse)
_forecast_cache: dict[tuple[float, float], tuple[datetime, WeatherForecastResponse]] = {}


def clear_forecast_cache() -> None:
    """Clear in-memory cache for deterministic test execution."""
    _forecast_cache.clear()


def evaluate_irrigation_advisory(
    precipitation_sum_mm: float,
    location_name: str,
    data_age_seconds: float = 0.0,
) -> FarmingAdvisory:
    """Evaluate explainable irrigation advice based on rainfall and data freshness (BR-03 / REQ-3.4)."""
    # Safety Check: Prohibit new recommendations if weather is older than 2 hours (BR-03)
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
    force_refresh: bool = False,
    client: httpx.AsyncClient | None = None,
) -> WeatherForecastResponse:
    """Fetch live weather from Open-Meteo with 15-min cache, stale marking, and 24h limit (BR-03)."""
    cache_key = (round(latitude, 4), round(longitude, 4))
    now = datetime.now(timezone.utc)

    # 1. Check in-memory cache for valid fresh data (< 15 mins) unless force_refresh requested
    if not force_refresh and cache_key in _forecast_cache:
        retrieval_time, cached = _forecast_cache[cache_key]
        age_seconds = (now - retrieval_time).total_seconds()
        if age_seconds <= CACHE_TTL_SECONDS:
            return cached

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
    except Exception as exc:
        # Fallback to cached data if Open-Meteo is unreachable (BR-03 stale fallback)
        if cache_key in _forecast_cache:
            retrieval_time, cached = _forecast_cache[cache_key]
            age_seconds = (now - retrieval_time).total_seconds()

            if age_seconds <= MAX_STALE_AGE_SECONDS:
                return cached.model_copy(update={"is_stale": True})

            if age_seconds <= MAX_DISPLAY_AGE_SECONDS:
                stale_advisory = evaluate_irrigation_advisory(
                    precipitation_sum_mm=cached.advisory.precipitation_expected_mm,
                    location_name=location_name,
                    data_age_seconds=age_seconds,
                )
                return cached.model_copy(update={"is_stale": True, "advisory": stale_advisory})

        raise exc
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

    today_rain_mm = daily_list[0].precipitation_sum if daily_list else 0.0
    advisory = evaluate_irrigation_advisory(
        precipitation_sum_mm=today_rain_mm,
        location_name=location_name,
        data_age_seconds=0.0,
    )

    result = WeatherForecastResponse(
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

    # Cache the fresh response
    _forecast_cache[cache_key] = (retrieval_time, result)
    return result


# --- Care Task & Care Log Service (REQ-3.5 / SAFE-5) ---


async def list_care_tasks(
    db: AsyncSession,
    user_id: UUID,
    plant_id: UUID | None = None,
    status: str | None = None,
) -> list[CareTask]:
    """List care tasks belonging to the user with optional plant and status filters."""
    query = select(CareTask).where(CareTask.user_id == user_id)
    if plant_id is not None:
        query = query.where(CareTask.plant_id == plant_id)
    if status is not None:
        query = query.where(CareTask.status == status)
    result = await db.scalars(query.order_by(CareTask.due_date.asc()))
    return list(result.all())


async def create_care_task(
    db: AsyncSession,
    user_id: UUID,
    task_in: CareTaskCreate,
) -> CareTask:
    """Create a new plant care task under ownership checks (REQ-3.5)."""
    # If plant_id is specified, verify ownership
    if task_in.plant_id is not None:
        plant = await db.scalar(
            select(Plant).where(Plant.id == task_in.plant_id, Plant.user_id == user_id)
        )
        if plant is None:
            fail(404, "NOT_FOUND", "Specified plant not found or does not belong to user.")

    task = CareTask(
        user_id=user_id,
        plant_id=task_in.plant_id,
        task_type=task_in.task_type,
        title=task_in.title,
        description=task_in.description,
        due_date=task_in.due_date,
        advisory_rationale=task_in.advisory_rationale,
    )
    db.add(task)
    await db.flush()
    return task


async def get_care_task(
    db: AsyncSession,
    user_id: UUID,
    task_id: UUID,
) -> CareTask:
    """Retrieve a single care task with ownership check."""
    task = await db.scalar(
        select(CareTask).where(CareTask.id == task_id, CareTask.user_id == user_id)
    )
    if task is None:
        fail(404, "NOT_FOUND", "Care task was not found.")
    return task


async def complete_care_task(
    db: AsyncSession,
    user_id: UUID,
    task_id: UUID,
    notes: str | None = None,
) -> CareTask:
    """Mark a task complete and record an actual care log (REQ-3.5, SAFE-5)."""
    task = await get_care_task(db, user_id, task_id)
    # SAFE-5: Idempotent replay protection
    if task.status == "completed":
        return task
    if task.status == "cancelled":
        fail(400, "INVALID_STATE", "Cannot complete a cancelled care task.")

    task.status = "completed"
    care_log = CareLog(
        task_id=task.id,
        user_id=user_id,
        plant_id=task.plant_id,
        action_taken="completed",
        notes=notes,
    )
    db.add(care_log)
    await db.flush()
    return task


async def skip_care_task(
    db: AsyncSession,
    user_id: UUID,
    task_id: UUID,
    notes: str | None = None,
) -> CareTask:
    """Mark a task skipped and record an actual care log (REQ-3.5, SAFE-5)."""
    task = await get_care_task(db, user_id, task_id)
    if task.status == "skipped":
        return task
    if task.status == "cancelled":
        fail(400, "INVALID_STATE", "Cannot skip a cancelled care task.")

    task.status = "skipped"
    care_log = CareLog(
        task_id=task.id,
        user_id=user_id,
        plant_id=task.plant_id,
        action_taken="skipped",
        notes=notes,
    )
    db.add(care_log)
    await db.flush()
    return task


async def cancel_care_task(
    db: AsyncSession,
    user_id: UUID,
    task_id: UUID,
) -> CareTask:
    """Cancel a scheduled care task (REQ-3.5)."""
    task = await get_care_task(db, user_id, task_id)
    task.status = "cancelled"
    await db.flush()
    return task


async def list_care_logs(
    db: AsyncSession,
    user_id: UUID,
    plant_id: UUID | None = None,
) -> list[CareLog]:
    """Retrieve actual care logs retained separately from recommendations (REQ-3.5)."""
    query = select(CareLog).where(CareLog.user_id == user_id)
    if plant_id is not None:
        query = query.where(CareLog.plant_id == plant_id)
    result = await db.scalars(query.order_by(CareLog.logged_at.desc()))
    return list(result.all())

