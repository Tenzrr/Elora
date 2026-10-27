import sys
from pathlib import Path

# Ensure repository root is on sys.path so 'ai', 'shared', etc. are accessible
REPO_ROOT = Path(__file__).resolve().parents[2]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from fastapi import FastAPI
from app.modules.crop_health.router import router as crop_health_router

app = FastAPI(title="Garden API", version="0.1.0")


@app.get("/health", tags=["system"])
async def health() -> dict[str, str]:
    return {"status": "ok", "service": "garden-api"}


@app.get("/api/v1", tags=["system"])
async def api_info() -> dict[str, str]:
    return {"version": "v1", "docs": "/docs"}


# Register module routers under /api/v1
app.include_router(crop_health_router, prefix="/api/v1")

