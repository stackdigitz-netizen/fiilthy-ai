from pathlib import Path
import sys
import traceback

from fastapi import FastAPI
from fastapi.responses import JSONResponse


app = FastAPI()

BACKEND_DIR = Path(__file__).resolve().parent.parent / "ceo" / "backend"

if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

try:
    from server import app as backend_app
except Exception as import_error:
    error_detail = traceback.format_exc()

    @app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"])
    async def crash_handler(path: str = ""):
        return JSONResponse(
            status_code=500,
            content={"error": str(import_error), "traceback": error_detail},
        )
else:
    app = backend_app