from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy.ext.hybrid import hybrid_property
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

    @hybrid_property
    def avatarColor(self):
        return self.avatar_color or "#facc15"

    @avatarColor.setter
    def avatarColor(self, value):
        self.avatar_color = value

    @hybrid_property
    def avatarImage(self):
        return self.avatar_image

    @avatarImage.setter
    def avatarImage(self, value):
        self.avatar_image = value

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

class RevokedToken(Base):
    __tablename__ = "revoked_tokens"

    jti = Column(String, primary_key=True)
    expires_at = Column(Integer, nullable=False, index=True)
