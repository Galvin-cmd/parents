from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from backend.server import route


app = FastAPI(
    title="豆小宝家长端 API",
    version="0.1.0",
    description="FastAPI skeleton for the Douxiaobao parent app. Current routes wrap the existing mock API while preserving /api/v1 paths.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.api_route("/api/v1/{path:path}", methods=["GET", "POST", "PATCH", "OPTIONS"])
async def api_proxy(path: str, request: Request):
    body = None
    if request.method in {"POST", "PATCH"}:
        body = await request.json()
    status, payload = route(request.method, f"/api/v1/{path}?{request.url.query}", body)
    return JSONResponse(status_code=status, content=payload)


@app.get("/")
async def root():
    return {
        "name": "豆小宝家长端 API",
        "status": "ready",
        "docs": "/docs",
        "health": "/api/v1/health",
    }
