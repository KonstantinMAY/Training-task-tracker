import logging
from typing import Optional

from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from . import models
from .database import engine
from .routers import auth, users, tasks

logger = logging.getLogger(__name__)

# Создаем таблицы в БД
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="TaskTracker API")

# Настройка CORS для доступа с фронтенда
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # В продакшене укажите конкретный домен
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def error_payload(message: str, status_code: int, details: Optional[dict] = None) -> dict:
    return {
        "message": message,
        "code": str(status_code),
        "details": details or {},
    }

# Кастомный обработчик ошибок для приведения к формату из ТЗ
@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    detail = exc.detail
    if isinstance(detail, str):
        message = detail
        details = {}
    elif isinstance(detail, dict):
        message = detail.get("message") if isinstance(detail.get("message"), str) else "Ошибка запроса"
        details = {key: value for key, value in detail.items() if key != "message"}
    else:
        message = "Ошибка запроса"
        details = {}
    return JSONResponse(
        status_code=exc.status_code,
        content=error_payload(message, exc.status_code, details),
        headers=getattr(exc, "headers", None),
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    details: dict[str, list[str]] = {}
    for err in exc.errors():
        loc = [str(part) for part in err.get("loc", []) if part not in ("body", "query", "path")]
        field = ".".join(loc) if loc else "request"
        details.setdefault(field, []).append(str(err.get("msg", "Invalid value")))
    return JSONResponse(
        status_code=status.HTTP_400_BAD_REQUEST,
        content=error_payload("Некорректные данные запроса", status.HTTP_400_BAD_REQUEST, details),
    )

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.exception("Unhandled server error")
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content=error_payload("Internal Server Error", status.HTTP_500_INTERNAL_SERVER_ERROR),
    )

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(tasks.router)
