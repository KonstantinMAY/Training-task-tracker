import uuid
from datetime import datetime, timedelta, timezone

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from . import models
from .config import ACCESS_TOKEN_EXPIRE_MINUTES, ALGORITHM, SECRET_KEY
from .database import get_db

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def _unauthorized() -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

class JWTBearer:
    """Bearer-аутентификация. Отсутствие и неверный формат заголовка дают 401, как в контракте."""

    async def __call__(self, request: Request) -> HTTPAuthorizationCredentials:
        authorization = request.headers.get("Authorization")
        if not authorization:
            raise _unauthorized()
        scheme, _, token = authorization.partition(" ")
        if scheme.lower() != "bearer" or not token.strip():
            raise _unauthorized()
        return HTTPAuthorizationCredentials(scheme=scheme, credentials=token.strip())

security = JWTBearer()

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire, "jti": str(uuid.uuid4())})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def revoke_token(token: str, db: Session) -> None:
    """Отзывает текущий JWT до истечения его срока. Повторное использование даёт 401."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        raise _unauthorized()
    jti = payload.get("jti")
    exp = payload.get("exp")
    if not isinstance(jti, str) or not jti or not isinstance(exp, (int, float)):
        raise _unauthorized()

    now = int(datetime.now(timezone.utc).timestamp())
    db.query(models.RevokedToken).filter(models.RevokedToken.expires_at < now).delete(synchronize_session=False)
    already_revoked = db.query(models.RevokedToken).filter(models.RevokedToken.jti == jti).first()
    if already_revoked is None:
        db.add(models.RevokedToken(jti=jti, expires_at=int(exp)))
    db.commit()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    token = credentials.credentials
    credentials_exception = _unauthorized()
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        jti = payload.get("jti")
        if user_id is None or not isinstance(jti, str) or not jti:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    revoked = db.query(models.RevokedToken).filter(models.RevokedToken.jti == jti).first()
    if revoked is not None:
        raise credentials_exception

    user = db.query(models.User).filter(models.User.id == user_id).first()
    if user is None:
        raise credentials_exception
    return user
