from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from .. import auth, models, schemas
from ..database import get_db

router = APIRouter(prefix="/api/users", tags=["users"])

_MAX_AVATAR_LENGTH = 5 * 1024 * 1024

def _store_avatar_image(avatar_image: Optional[str]) -> Optional[str]:
    if avatar_image is None:
        return None
    if len(avatar_image) > _MAX_AVATAR_LENGTH:
        raise HTTPException(status_code=413, detail="Avatar image too large")
    if not avatar_image.startswith("data:image/"):
        raise HTTPException(status_code=415, detail="Unsupported avatar media type")
    header, separator, payload = avatar_image.partition(",")
    if separator != "," or ";base64" not in header or not payload.strip():
        raise HTTPException(status_code=400, detail="avatarImage must be a base64 image data URL")
    return avatar_image

@router.get("/me", response_model=schemas.UserResponse)
def get_profile(current_user: models.User = Depends(auth.get_current_user)):
    return current_user

@router.patch("/me", response_model=schemas.UserResponse)
def update_profile(
    profile_data: schemas.UserUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    fields_set = profile_data.model_fields_set

    if "avatarColor" in fields_set:
        if profile_data.avatarColor is None:
            raise HTTPException(status_code=400, detail="avatarColor cannot be null")
        current_user.avatar_color = profile_data.avatarColor

    if "avatarImage" in fields_set:
        current_user.avatar_image = _store_avatar_image(profile_data.avatarImage)

    db.commit()
    db.refresh(current_user)
    return current_user

@router.delete("/me/avatar", status_code=status.HTTP_204_NO_CONTENT)
def reset_avatar(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    current_user.avatar_image = None
    current_user.avatar_color = "#facc15"
    db.commit()
    return None
