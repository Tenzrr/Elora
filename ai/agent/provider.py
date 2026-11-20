import asyncio
import logging
import re
import time
from dataclasses import dataclass
from typing import Protocol

import httpx

from app.core.config import Settings, get_settings

logger = logging.getLogger(__name__)

DEFAULT_FALLBACK_MESSAGE = (
    "The agricultural advisory service is temporarily unavailable. "
    "Recommended practice: inspect soil moisture, observe foliage changes, and verify plant conditions. "
    "Please try asking your question again in a moment."
)


@dataclass(frozen=True)
class ProviderTurnResult:
    text: str
    provider: str
    model: str
    fallback: bool
    duration_ms: int


class AgentProvider(Protocol):
    async def generate_turn(
        self,
        prompt: str,
        system_prompt: str,
        context: str | None = None,
    ) -> ProviderTurnResult: ...


class MockAgentProvider:
    def __init__(self, model_name: str = "mock_agronomist"):
        self.model_name = model_name

    def _generate_agronomic_response(self, prompt: str, context: str | None = None) -> str:
        lower = prompt.lower()
        context_note = f" {context}" if context else ""

        words = set(re.findall(r"\b\w+\b", lower))
        is_greeting = bool(words & {"hello", "hi", "hey", "greetings"}) or "good morning" in lower or "good afternoon" in lower
        is_who = any(phrase in lower for phrase in ("who are you", "what can you do", "help me", "introduce yourself"))

        is_yellow = any(word in lower for word in ("yellow", "yellowing", "chlorosis"))
        is_wilting = any(word in lower for word in ("wilt", "wilting", "droop", "drooping", "dying"))
        is_spots = any(word in lower for word in ("spot", "spots", "blight", "fungus", "mold", "mildew", "rust"))
        is_curl = any(word in lower for word in ("curl", "curling", "curled"))

        is_watering = any(word in lower for word in ("water", "watering", "irrigation", "moisture", "drought", "dry", "thirsty"))
        is_pest = any(word in lower for word in ("pest", "pests", "aphid", "aphids", "bug", "bugs", "insect", "insects", "caterpillar", "worm", "neem", "companion", "thrip", "thrips", "whitefly", "whiteflies", "mealybug", "mealybugs"))
        is_soil = any(word in lower for word in ("soil", "compost", "fertilizer", "fertiliser", "potting", "nutrient", "nutrients", "manure", "organic", "feed", "feeding"))
        is_pruning = any(word in lower for word in ("prune", "pruning", "dead leaf", "dead leaves", "cut", "trim", "trimming", "branch", "sucker"))
        is_sun = any(word in lower for word in ("sun", "sunlight", "shade", "shading", "light", "heat", "temperature"))

        is_tomato = "tomato" in lower
        is_chilli = "chilli" in lower or "chili" in lower or "pepper" in lower
        is_banana = "banana" in lower
        is_citrus = "citrus" in lower or "lime" in lower or "lemon" in lower or "orange" in lower
        is_rose = "rose" in lower or "roses" in lower

        has_specific_intent = any((
            is_yellow, is_wilting, is_spots, is_curl,
            is_watering, is_pest, is_soil, is_pruning, is_sun,
            is_tomato, is_chilli, is_banana, is_citrus, is_rose,
        ))

        if is_who and not has_specific_intent:
            return (
                "I am your Elora Agricultural Assistant. "
                "I can advise on crop disease diagnosis, organic pest prevention, soil nutrition, irrigation schedules, and plant care. "
                "Ask me about any plant or symptom in your garden."
            )

        if is_greeting and not context and not has_specific_intent:
            return (
                "Hello! I am your Elora Agricultural Assistant. "
                "I can advise on crop care, organic pest control, watering, and soil health. "
                "What crop or gardening question can I help you with today?"
            )

        guidance_parts: list[str] = []

        if is_yellow:
            guidance_parts.append(
                "Yellowing leaves usually point to overwatering, poor drainage, or nitrogen deficiency. Check root zone soil moisture depth before adding water, and incorporate well balanced organic compost to replenish soil nutrients."
            )
        elif is_wilting:
            guidance_parts.append(
                "Wilting can happen from either prolonged dry soil or suffocated waterlogged roots. Feel the soil two inches down: if completely dry, water thoroughly at the base; if saturated, withhold watering to allow oxygen into the root zone."
            )
        elif is_spots:
            guidance_parts.append(
                "Foliage spots often indicate fungal infection. Remove severely affected leaves with clean tools, avoid splashing water onto leaves, and ensure generous spacing for air circulation."
            )
        elif is_curl:
            guidance_parts.append(
                "Curling leaves on young foliage are frequently caused by sap sucking thrips or aphids. Inspect leaf undersides closely and apply diluted cold pressed neem oil spray during the cool evening hours."
            )

        if is_tomato:
            guidance_parts.append(
                "For tomato plants, inspect lower foliage for early blight, support heavy vines with stakes, and prevent blossom end rot by ensuring consistent soil moisture."
            )
        elif is_chilli:
            guidance_parts.append(
                "For chillies, maintain warm well drained soil, provide direct sun, and observe new growth for signs of thrips or leaf curl."
            )
        elif is_banana:
            guidance_parts.append(
                "For bananas, inspect pseudostems regularly, remove extra suckers to concentrate growth, and maintain generous organic mulch around the root zone."
            )
        elif is_citrus:
            guidance_parts.append(
                "For citrus trees, watch for leafminer trails on tender foliage, irrigate deeply once a week during dry weather, and prune water sprouts promptly."
            )
        elif is_rose:
            guidance_parts.append(
                "For roses, observe leaves for black spot or powdery mildew, clear fallen leaves, and ensure full sunlight with well drained fertile soil."
            )

        if is_watering and not (is_yellow or is_wilting):
            guidance_parts.append(
                "Water early in the morning at the base of the plant to keep leaves dry. Always check the top two inches of soil moisture before watering to prevent root rot."
            )

        if is_pest and not is_curl:
            guidance_parts.append(
                "For natural pest prevention, spray cold pressed neem oil solution during late afternoon or introduce companion plants like marigolds to deter harmful insects."
            )

        if is_soil and not is_yellow:
            guidance_parts.append(
                "Incorporate well rotted organic compost to improve soil moisture retention and microbial activity without resorting to synthetic chemical inputs."
            )

        if is_pruning:
            guidance_parts.append(
                "Use clean, sanitized pruning shears. Cut diseased or dead stems at a 45 degree angle just above a healthy leaf node to encourage vigorous new growth."
            )

        if is_sun:
            guidance_parts.append(
                "Ensure fruiting plants receive at least six hours of direct sunlight daily while protecting young seedlings from excessive midday heat."
            )

        if not guidance_parts:
            guidance_parts.append(
                "Inspect leaf surfaces regularly, verify soil moisture before watering, and ensure good air circulation between plants. For suspected diseases, capture clear photos in the Scan tab."
            )

        return f"Agricultural guidance: {' '.join(guidance_parts)}{context_note}"

    async def generate_turn(
        self,
        prompt: str,
        system_prompt: str,
        context: str | None = None,
    ) -> ProviderTurnResult:
        response_text = self._generate_agronomic_response(prompt, context)
        return ProviderTurnResult(
            text=response_text,
            provider="mock",
            model=self.model_name,
            fallback=False,
            duration_ms=2,
        )


class GeminiAgentProvider:
    def __init__(
        self,
        api_key: str | None,
        model_name: str = "gemini-3.8-flash",
        timeout_seconds: float = 18.0,
        max_retries: int = 2,
        client: httpx.AsyncClient | None = None,
        fallback_models: list[str] | None = None,
    ):
        self.api_key = api_key
        self.model_name = model_name
        self.timeout_seconds = timeout_seconds
        self.max_retries = max_retries
        self._external_client = client
        self.fallback_models = list(fallback_models) if fallback_models else []

    async def generate_turn(
        self,
        prompt: str,
        system_prompt: str,
        context: str | None = None,
    ) -> ProviderTurnResult:
        start_time = time.perf_counter()

        if not self.api_key:
            logger.warning("Gemini provider configured without valid API key. Falling back to safe guidance.")
            return ProviderTurnResult(
                text=DEFAULT_FALLBACK_MESSAGE,
                provider="gemini",
                model=self.model_name,
                fallback=True,
                duration_ms=0,
            )

        full_user_content = f"{context}\n\nQuestion: {prompt}" if context else prompt
        payload = {
            "systemInstruction": {
                "parts": [{"text": system_prompt}]
            },
            "contents": [
                {
                    "role": "user",
                    "parts": [{"text": full_user_content}],
                }
            ],
            "generationConfig": {
                "temperature": 0.2,
                "maxOutputTokens": 800,
                "thinkingConfig": {
                    "thinkingBudget": 0,
                },
            },
        }

        models_to_try = [self.model_name]
        for alt_model in self.fallback_models:
            if alt_model not in models_to_try:
                models_to_try.append(alt_model)

        async_client = self._external_client or httpx.AsyncClient(timeout=self.timeout_seconds)
        should_close = self._external_client is None

        try:
            for current_model in models_to_try:
                url = (
                    f"https://generativelanguage.googleapis.com/v1beta/models/{current_model}:generateContent"
                    f"?key={self.api_key}"
                )
                retries_remaining = self.max_retries
                while True:
                    try:
                        response = await async_client.post(url, json=payload)
                        if response.status_code == 200:
                            data = response.json()
                            candidates = data.get("candidates", [])
                            if candidates:
                                parts = candidates[0].get("content", {}).get("parts", [])
                                if parts and "text" in parts[0]:
                                    elapsed = int((time.perf_counter() - start_time) * 1000)
                                    return ProviderTurnResult(
                                        text=parts[0]["text"].strip(),
                                        provider="gemini",
                                        model=current_model,
                                        fallback=False,
                                        duration_ms=elapsed,
                                    )
                            break

                        if response.status_code in (404, 429):
                            logger.warning("Gemini model %s unavailable (status %s)", current_model, response.status_code)
                            break

                        if response.status_code in (500, 502, 503, 504) and retries_remaining > 0:
                            retries_remaining -= 1
                            await asyncio.sleep(1.0)
                            continue
                        break
                    except (httpx.TimeoutException, httpx.NetworkError) as net_err:
                        if retries_remaining > 0:
                            retries_remaining -= 1
                            await asyncio.sleep(1.0)
                            continue
                        logger.warning("Gemini network error: %s", type(net_err).__name__)
                        break
                    except Exception as exc:
                        logger.warning("Gemini generation unexpected error: %s", type(exc).__name__)
                        break
        finally:
            if should_close:
                await async_client.aclose()

        elapsed_ms = int((time.perf_counter() - start_time) * 1000)
        return ProviderTurnResult(
            text=DEFAULT_FALLBACK_MESSAGE,
            provider="gemini",
            model=self.model_name,
            fallback=True,
            duration_ms=elapsed_ms,
        )


def get_agent_provider(settings: Settings | None = None) -> AgentProvider:
    cfg = settings or get_settings()
    if cfg.llm_provider == "gemini":
        key = cfg.gemini_api_key.get_secret_value() if cfg.gemini_api_key else None
        return GeminiAgentProvider(
            api_key=key,
            model_name=cfg.gemini_model,
            timeout_seconds=cfg.llm_timeout_seconds,
            max_retries=cfg.llm_max_retries,
            fallback_models=["gemini-3-flash-preview", "gemini-3.1-flash-lite-preview"],
        )
    return MockAgentProvider()
