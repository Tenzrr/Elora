import logging
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

    async def generate_turn(
        self,
        prompt: str,
        system_prompt: str,
        context: str | None = None,
    ) -> ProviderTurnResult:
        context_clause = f"{context} " if context else ""
        response_text = (
            "Welcome to Elora Agricultural Assistant. "
            f"Agricultural guidance: {context_clause}"
            "Inspect leaf surfaces, monitor soil moisture before watering, and maintain clean tools. "
            "For specific disease diagnosis, share clear photos through crop scanning."
        )
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
        model_name: str = "gemini-2.5-flash",
        timeout_seconds: float = 15.0,
        max_retries: int = 2,
        client: httpx.AsyncClient | None = None,
    ):
        self.api_key = api_key
        self.model_name = model_name
        self.timeout_seconds = timeout_seconds
        self.max_retries = max_retries
        self._external_client = client

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
        url = (
            f"https://generativelanguage.googleapis.com/v1beta/models/{self.model_name}:generateContent"
            f"?key={self.api_key}"
        )
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
            },
        }

        retries_remaining = self.max_retries
        async_client = self._external_client or httpx.AsyncClient(timeout=self.timeout_seconds)
        should_close = self._external_client is None

        try:
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
                                    model=self.model_name,
                                    fallback=False,
                                    duration_ms=elapsed,
                                )
                        break

                    if response.status_code in (429, 500, 502, 503, 504) and retries_remaining > 0:
                        retries_remaining -= 1
                        continue
                    break
                except (httpx.TimeoutException, httpx.NetworkError) as net_err:
                    if retries_remaining > 0:
                        retries_remaining -= 1
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
        )
    return MockAgentProvider()
