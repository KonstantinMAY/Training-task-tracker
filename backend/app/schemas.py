from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, EmailStr, Field, field_validator

TaskStatus = Literal["todo", "in_progress", "review", "done"]
TaskPriority = Literal["low", "medium", "high"]

def _strip_required_text(value):
    if isinstance(value, str):
        return value.strip()
    return value

def _normalize_deadline(value):
    if value is None or value == "":
        return None
    if not isinstance(value, str):
        raise ValueError("deadline must be a date in YYYY-MM-DD format")
    try:
        datetime.strptime(value, "%Y-%m-%d")
    except ValueError as exc:
        raise ValueError("deadline must be a date in YYYY-MM-DD format") from exc
    return value

# --- User Schemas ---
class UserBase(BaseModel):
    email: EmailStr

class UserCreate(UserBase):
    password: str = Field(..., min_length=3)

class UserResponse(UserBase):
    id: str
    avatarColor: str
    avatarImage: Optional[str] = None

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    avatarColor: Optional[str] = Field(default=None, pattern=r"^#[0-9A-Fa-f]{6}$")
    avatarImage: Optional[str] = None

    @field_validator("avatarImage", mode="before")
    @classmethod
    def empty_avatar_means_absent(cls, value):
        if value == "":
            return None
        return value

# --- Auth Schemas ---
class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=3)

class TokenResponse(BaseModel):
    user: UserResponse
    access_token: str
    token_type: str = "bearer"

# --- Task Schemas ---
class TaskCreate(BaseModel):
    title: str = Field(..., min_length=1)
    description: str = ""
    priority: TaskPriority = "low"
    deadline: Optional[str] = None

    @field_validator("title", mode="before")
    @classmethod
    def strip_title(cls, value):
        return _strip_required_text(value)

    @field_validator("deadline", mode="before")
    @classmethod
    def validate_deadline(cls, value):
        return _normalize_deadline(value)

class TaskUpdate(BaseModel):
    title: str = Field(..., min_length=1)
    description: str
    priority: TaskPriority
    deadline: Optional[str] = None

    @field_validator("title", mode="before")
    @classmethod
    def strip_title(cls, value):
        return _strip_required_text(value)

    @field_validator("deadline", mode="before")
    @classmethod
    def validate_deadline(cls, value):
        return _normalize_deadline(value)

class TaskStatusUpdate(BaseModel):
    status: TaskStatus

class TaskResponse(BaseModel):
    id: str
    title: str
    description: str
    status: TaskStatus
    priority: TaskPriority
    deadline: Optional[str] = None

    class Config:
        from_attributes = True
