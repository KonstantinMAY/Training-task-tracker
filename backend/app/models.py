from sqlalchemy import Column, String, ForeignKey
from sqlalchemy.orm import relationship
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    avatar_color = Column(String, default="#facc15")
    avatar_image = Column(String, nullable=True) # Base64 строка

    tasks = relationship("Task", back_populates="owner", cascade="all, delete-orphan")

class Task(Base):
    __tablename__ = "tasks"

    id = Column(String, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, default="")
    status = Column(String, default="todo") # 'todo', 'in_progress', 'review', 'done'
    priority = Column(String, default="low") # 'low', 'medium', 'high'
    deadline = Column(String, nullable=True) # YYYY-MM-DD
    owner_id = Column(String, ForeignKey("users.id"))

    owner = relationship("User", back_populates="tasks")