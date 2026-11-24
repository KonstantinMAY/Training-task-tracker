from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import schemas, models, auth
from ..database import get_db

router = APIRouter(prefix="/api/users", tags=["users"])

@router.get("/me", response_model=schemas.UserResponse)
def get_profile(current_user: models.User = Depends(auth.get_current_user)):
    return current_user

@router.patch("/me", response_model=schemas.UserResponse)
def update_profile(
    profile_data: schemas.UserUpdate, 
    current_user: models.User = Depends(auth.get_current_user), 
    db: Session = Depends(get_db)
):
    # Валидация размера Base64 картинки (примерно 5 MB)
    if profile_data.avatarImage and len(profile_data.avatarImage) > 5 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="Avatar image too large")

    if profile_data.avatarColor is not None:
        current_user.avatar_color = profile_data.avatarColor
    if profile_data.avatarImage is not None:
        current_user.avatar_image = profile_data.avatarImage
        
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