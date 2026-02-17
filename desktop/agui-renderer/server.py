"""ag-ui Renderer — receives agent events and renders in Hyprland."""
from fastapi import FastAPI

app = FastAPI(title="Harmonix ag-ui Renderer")

@app.get("/health")
async def health():
    return {"status": "ok", "service": "agui-renderer"}

@app.post("/events")
async def receive_event(event: dict):
    return {"received": True, "event_type": event.get("type", "unknown")}
