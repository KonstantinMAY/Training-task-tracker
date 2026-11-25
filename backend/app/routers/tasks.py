import uuid
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from .. import auth, models, schemas
from ..database import get_db

router = APIRouter(prefix="/api/tasks", tags=["tasks"])

def _get_owned_task(db: Session, task_id: str, owner_id: str) -> models.Task:
    task = db.query(models.Task).filter(
        models.Task.id == task_id,
        models.Task.owner_id == owner_id,
    ).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@router.get("", response_model=list[schemas.TaskResponse])
def get_tasks(
    task_status: Optional[schemas.TaskStatus] = Query(default=None, alias="status"),
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db),
):
    query = db.query(models.Task).filter(models.Task.owner_id == current_user.id)
    if task_status is not None:
        query = query.filter(models.Task.status == task_status)
    return query.all()

@router.post("", response_model=schemas.TaskResponse, status_code=status.HTTP_201_CREATED)
def create_task(
    task: schemas.TaskCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    new_task = models.Task(
        id=str(uuid.uuid4()),
        title=task.title,
        description=task.description,
        priority=task.priority,
        status="todo",
        deadline=task.deadline,
        owner_id=current_user.id
    )
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return new_task

@router.get("/{task_id}", response_model=schemas.TaskResponse)
def get_task(
    task_id: str,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db),
):
    return _get_owned_task(db, task_id, current_user.id)

@router.patch("/{task_id}", response_model=schemas.TaskResponse)
def update_task(
    task_id: str,
    task_update: schemas.TaskUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    task = _get_owned_task(db, task_id, current_user.id)

    task.title = task_update.title
    task.description = task_update.description
    task.priority = task_update.priority
    if "deadline" in task_update.model_fields_set:
        task.deadline = task_update.deadline

    db.commit()
    db.refresh(task)
    return task

@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(
    task_id: str,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    task = _get_owned_task(db, task_id, current_user.id)

    db.delete(task)
    db.commit()
    return None

@router.patch("/{task_id}/status", response_model=schemas.TaskResponse)
def update_task_status(
    task_id: str,
    status_update: schemas.TaskStatusUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    task = _get_owned_task(db, task_id, current_user.id)

    task.status = status_update.status
    db.commit()
    db.refresh(task)
    return task
