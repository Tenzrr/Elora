from fastapi import FastAPI

app = FastAPI(title="Garden API", version="0.1.0")


@app.get("/health", tags=["system"])
async def health() -> dict[str, str]:
    return {"status": "ok", "service": "garden-api"}


@app.get("/api/v1", tags=["system"])
async def api_info() -> dict[str, str]:
    return {"version": "v1", "docs": "/docs"}
