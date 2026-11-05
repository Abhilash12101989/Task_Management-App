from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy import desc
from app.models import Task
from app.schemas import TaskCreate, TaskUpdate

def get_tasks(
    db: Session,
    skip: int = 0,
    limit: int = 100,
    completed: Optional[bool] = None,
    priority: Optional[str] = None,
    search: Optional[str] = None
) -> List[Task]:
    query = db.query(Task)
    if completed is not None:
        query = query.filter(Task.completed == completed)
    if priority and priority != "all":
        query = query.filter(Task.priority == priority)
    if search:
        query = query.filter(
            (Task.title.ilike(f"%{search}%")) | (Task.description.ilike(f"%{search}%"))
        )
    return query.order_by(desc(Task.created_at)).offset(skip).limit(limit).all()

def get_task(db: Session, task_id: int) -> Optional[Task]:
    return db.query(Task).filter(Task.id == task_id).first()

def create_task(db: Session, task_in: TaskCreate) -> Task:
    db_task = Task(
        title=task_in.title,
        description=task_in.description,
        priority=task_in.priority or "medium",
        category=task_in.category or "DevOps",
        completed=False
    )
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

def update_task(db: Session, task_id: int, task_in: TaskUpdate) -> Optional[Task]:
    db_task = get_task(db, task_id)
    if not db_task:
        return None
    
    if hasattr(task_in, "model_dump"):
        update_data = task_in.model_dump(exclude_unset=True)
    else:
        update_data = task_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_task, field, value)
    
    db.commit()
    db.refresh(db_task)
    return db_task

def delete_task(db: Session, task_id: int) -> bool:
    db_task = get_task(db, task_id)
    if not db_task:
        return False
    db.delete(db_task)
    db.commit()
    return True

def get_stats(db: Session) -> dict:
    total = db.query(Task).count()
    completed = db.query(Task).filter(Task.completed == True).count()
    pending = total - completed
    high_priority = db.query(Task).filter(Task.completed == False, Task.priority == "high").count()
    return {
        "total": total,
        "completed": completed,
        "pending": pending,
        "high_priority": high_priority
    }

