from uuid import uuid4
import httpx
import pytest
from pydantic import SecretStr

from ai.agent.formatters import sanitize_agronomic_text, to_sans_bold, to_sans_italic
from ai.agent.prompts.agronomist_system import is_greeting_query
from ai.agent.provider import (
    DEFAULT_FALLBACK_MESSAGE,
    GeminiAgentProvider,
    MockAgentProvider,
    get_agent_provider,
)
from app.core.config import Settings
from conftest import signed_in


@pytest.mark.asyncio
async def test_mock_provider_generation():
    provider = MockAgentProvider()
    result = await provider.generate_turn(
        prompt="How do I prepare soil for organic chillies?",
        system_prompt="You are an agricultural expert.",
        context="Plant: Chilli in greenhouse",
    )
    assert not result.fallback
    assert result.provider == "mock"
    assert "Agricultural guidance:" in result.text
    assert "soil moisture" in result.text


@pytest.mark.asyncio
async def test_gemini_provider_missing_key_bounded_fallback():
    provider = GeminiAgentProvider(api_key=None)
    result = await provider.generate_turn(
        prompt="Can you check my banana plant?",
        system_prompt="Agricultural system instructions",
    )
    assert result.fallback
    assert result.provider == "gemini"
    assert result.text == DEFAULT_FALLBACK_MESSAGE


@pytest.mark.asyncio
async def test_gemini_provider_successful_turn():
    def mock_handler(request: httpx.Request) -> httpx.Response:
        data = {
            "candidates": [
                {
                    "content": {
                        "parts": [
                            {"text": "Mulching helps preserve soil moisture during dry periods."}
                        ]
                    }
                }
            ]
        }
        return httpx.Response(200, json=data)

    transport = httpx.MockTransport(mock_handler)
    async with httpx.AsyncClient(transport=transport) as client:
        provider = GeminiAgentProvider(
            api_key="synthetic_test_key",
            client=client,
        )
        result = await provider.generate_turn(
            prompt="How to retain soil moisture?",
            system_prompt="Agricultural advice prompt",
        )
        assert not result.fallback
        assert result.provider == "gemini"
        assert "Mulching helps preserve soil moisture" in result.text


@pytest.mark.asyncio
async def test_gemini_provider_timeout_bounded_fallback():
    call_count = 0

    def mock_timeout_handler(request: httpx.Request) -> httpx.Response:
        nonlocal call_count
        call_count += 1
        raise httpx.ReadTimeout("Simulated provider timeout", request=request)

    transport = httpx.MockTransport(mock_timeout_handler)
    async with httpx.AsyncClient(transport=transport) as client:
        provider = GeminiAgentProvider(
            api_key="synthetic_test_key",
            timeout_seconds=0.1,
            max_retries=2,
            client=client,
        )
        result = await provider.generate_turn(
            prompt="What is the forecast impact on banana roots?",
            system_prompt="Agronomist instructions",
        )
        assert result.fallback
        assert result.provider == "gemini"
        assert result.text == DEFAULT_FALLBACK_MESSAGE
        assert call_count == 3


@pytest.mark.asyncio
async def test_gemini_provider_transient_error_retry_exhaustion():
    call_count = 0

    def mock_503_handler(request: httpx.Request) -> httpx.Response:
        nonlocal call_count
        call_count += 1
        return httpx.Response(503, text="Service Unavailable")

    transport = httpx.MockTransport(mock_503_handler)
    async with httpx.AsyncClient(transport=transport) as client:
        provider = GeminiAgentProvider(
            api_key="synthetic_test_key",
            max_retries=2,
            client=client,
        )
        result = await provider.generate_turn(
            prompt="Recommend organic fertiliser",
            system_prompt="System rules",
        )
        assert result.fallback
        assert result.text == DEFAULT_FALLBACK_MESSAGE
        assert call_count == 3


def test_provider_factory_selection():
    mock_settings = Settings(_env_file=None, app_env="test", llm_provider="mock")
    provider1 = get_agent_provider(mock_settings)
    assert isinstance(provider1, MockAgentProvider)

    gemini_settings = Settings(
        _env_file=None,
        app_env="test",
        llm_provider="gemini",
        gemini_api_key=SecretStr("test_secret"),
    )
    provider2 = get_agent_provider(gemini_settings)
    assert isinstance(provider2, GeminiAgentProvider)


def test_chat_route_end_to_end_turn(api):
    client, _, _ = api
    headers = signed_in(client, "alice")
    thread_id = str(uuid4())
    resp = client.post(
        "/api/v1/agricultural-agent/chat",
        headers=headers,
        json={
            "thread_id": thread_id,
            "message": "What is the recommended frequency for watering chilli plants?",
        },
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["thread_id"] == thread_id
    assert "soil moisture" in data["response"]


def test_chat_route_cross_user_isolation(api):
    client, _, _ = api
    alice = signed_in(client, "alice")
    bob = signed_in(client, "bob")

    bob_plant = client.post(
        "/api/v1/plants",
        headers=bob,
        json={"crop_slug": "chilli", "growing_area": "North plot"},
    ).json()
    bob_plant_id = bob_plant["id"]

    alice_chat = client.post(
        "/api/v1/agricultural-agent/chat",
        headers=alice,
        json={
            "plant_id": bob_plant_id,
            "message": "Provide care steps for this plant.",
        },
    )
    assert alice_chat.status_code == 200
    body = alice_chat.json()
    assert "Requested plant was not found in your garden." in body["response"]


def test_unicode_formatting_sanitization():
    raw_sample = "### 1. Water Management\n* **Morning Watering:** Check *soil moisture* depth.\n* Incorporate **compost**."
    sanitized = sanitize_agronomic_text(raw_sample, is_user_greeting=False)
    assert "#" not in sanitized
    assert "**" not in sanitized
    assert "*" not in sanitized
    assert "•" in sanitized
    assert "𝟭. 𝗪𝗮𝘁𝗲𝗿 𝗠𝗮𝗻𝗮𝗴𝗲𝗺𝗲𝗻𝘁" in sanitized
    assert "• 𝗠𝗼𝗿𝗻𝗶𝗻𝗴 𝗪𝗮𝘁𝗲𝗿𝗶𝗻𝗴:" in sanitized


def test_repetitive_greeting_stripping():
    sample = "Ayubowan! I am Elora.\n\n### 1. Tomato Pruning\n* Cut suckers."
    stripped = sanitize_agronomic_text(sample, is_user_greeting=False)
    assert "Ayubowan" not in stripped
    assert "I am Elora" not in stripped
    assert "𝟭. 𝗧𝗼𝗺𝗮𝘁𝗼 𝗣𝗿𝘂𝗻𝗶𝗻𝗴" in stripped

    preserved = sanitize_agronomic_text(sample, is_user_greeting=True)
    assert "Ayubowan" in preserved


def test_greeting_query_detection():
    assert is_greeting_query("hello")
    assert is_greeting_query("Hi there")
    assert is_greeting_query("Ayubowan")
    assert is_greeting_query("what can you do")
    assert not is_greeting_query("any info on tomato")
    assert not is_greeting_query("how to prune dead leaves")
