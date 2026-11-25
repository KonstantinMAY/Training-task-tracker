import os
import secrets
from typing import Optional

ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7  # 7 дней

# Известный ключ из старого кода. Его нельзя использовать ни в production, ни как тихий fallback.
_KNOWN_INSECURE_SECRET = "super_secret_key_change_in_production"


def resolve_secret_key(app_env: Optional[str], secret: Optional[str]) -> str:
    """Возвращает секрет JWT. В production ключ обязателен и не может быть значением по умолчанию."""
    env = (app_env or "development").strip().lower()
    value = secret.strip() if isinstance(secret, str) else ""
    insecure = not value or value == _KNOWN_INSECURE_SECRET

    if env == "production":
        if insecure:
            raise RuntimeError(
                "SECRET_KEY environment variable must be set to a unique value when APP_ENV=production"
            )
        return value

    if insecure:
        return secrets.token_urlsafe(32)
    return value


APP_ENV = os.getenv("APP_ENV", "development")
SECRET_KEY = resolve_secret_key(APP_ENV, os.getenv("SECRET_KEY"))
