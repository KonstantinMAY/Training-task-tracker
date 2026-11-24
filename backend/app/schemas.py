from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Literal

TaskStatus = Literal['todo', 'in_progress', 'review', 'done']
TaskPriority = Literal['low', 'medium', 'high']

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
    avatarColor: Optional[str] = None
    avatarImage: Optional[str] = None

# --- Auth Schemas ---
class LoginRequest(BaseModel):
    email: EmailStr
    password: str

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

class TaskUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1)
    description: Optional[str] = None
    priority: Optional[TaskPriority] = None

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