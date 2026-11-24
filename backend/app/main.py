from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from .database import engine
from . import models
from .routers import auth, users, tasks

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

# Кастомный обработчик ошибок для приведения к формату из ТЗ
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    if hasattr(exc, "status_code"):
        status_code = exc.status_code
        detail = exc.detail
    else:
        status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
        detail = "Internal Server Error"

    return JSONResponse(
        status_code=status_code,
        content={
            "message": detail if isinstance(detail, str) else "Ошибка запроса",
            "code": str(status_code),
            "details": detail if isinstance(detail, dict) else {}
        }
    )

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(tasks.router)