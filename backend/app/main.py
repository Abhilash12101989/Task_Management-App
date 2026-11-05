import time
import logging
from datetime import datetime
from typing import List, Optional
from fastapi import FastAPI, Depends, HTTPException, Query, Request, Response, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

from app.config import settings
from app.database import get_db, init_db, check_db_connection
from app.schemas import (
    TaskCreate,
    TaskUpdate,
    TaskResponse,
    HealthResponse,
    StatsResponse,
)
import app.crud as crud

# Production Structured Logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO),
    format='{"timestamp":"%(asctime)s","level":"%(levelname)s","logger":"%(name)s","message":"%(message)s"}'
)
logger = logging.getLogger("task_app")

# Prometheus Metrics
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP Requests",
    ["method", "endpoint", "status_code"]
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP Request Latency in seconds",
    ["method", "endpoint"]
)

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Enterprise Three-Tier Task Management API (Scalable & High Availability)",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request Timing & Metrics Middleware
@app.middleware("http")
async def monitor_requests(request: Request, call_next):
    start_time = time.time()
    endpoint = request.url.path
    method = request.method
    
    try:
        response = await call_next(request)
        duration = time.time() - start_time
        response.headers["X-Process-Time"] = f"{duration:.4f}s"
        
        # Track metrics (exclude /metrics to avoid scrape feedback loop)
        if endpoint != "/metrics":
            REQUEST_COUNT.labels(method=method, endpoint=endpoint, status_code=response.status_code).inc()
            REQUEST_LATENCY.labels(method=method, endpoint=endpoint).observe(duration)
        
        return response
    except Exception as exc:
        duration = time.time() - start_time
        REQUEST_COUNT.labels(method=method, endpoint=endpoint, status_code=500).inc()
        logger.error(f"Unhandled exception during {method} {endpoint}: {exc}")
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"error": "InternalServerError", "message": "An unexpected error occurred. Please try again later."}
        )

@app.on_event("startup")
def on_startup():
    logger.info("Initializing database schema on startup...")
    init_db()

# ==============================================================================
# Observability & Health Endpoints (Kubernetes & Azure LB Ready)
# ==============================================================================

@app.get("/metrics", tags=["Observability"])
def metrics():
    """Prometheus metrics endpoint for Grafana / Azure Monitor."""
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/api/health", response_model=HealthResponse, tags=["Monitoring"])
def health_check():
    """General health check verifying DB connectivity."""
    db_ok = check_db_connection()
    return HealthResponse(
        status="healthy" if db_ok else "degraded",
        app_name=settings.APP_NAME,
        version=settings.APP_VERSION,
        environment=settings.ENVIRONMENT,
        database_connected=db_ok,
        timestamp=datetime.utcnow()
    )

@app.get("/api/health/live", tags=["Monitoring"])
def liveness_probe():
    """Kubernetes / Azure Load Balancer Liveness Probe: confirms process is alive."""
    return {"status": "alive"}

@app.get("/api/health/ready", tags=["Monitoring"])
def readiness_probe():
    """Readiness Probe: confirms process can serve traffic and connect to DB."""
    if not check_db_connection():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database connection not ready"
        )
    return {"status": "ready"}

@app.get("/", tags=["Root"])
def root():
    return {
        "message": "Task Management API - Production Ready",
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT,
        "docs": "/docs",
        "health": "/api/health",
        "metrics": "/metrics"
    }

# ==============================================================================
# Business Logic (Task CRUD)
# ==============================================================================

@app.get("/api/tasks/stats", response_model=StatsResponse, tags=["Tasks"])
def get_task_statistics(db: Session = Depends(get_db)):
    return crud.get_stats(db)

@app.get("/api/tasks", response_model=List[TaskResponse], tags=["Tasks"])
def list_tasks(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    completed: Optional[bool] = Query(None),
    priority: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    return crud.get_tasks(
        db,
        skip=skip,
        limit=limit,
        completed=completed,
        priority=priority,
        search=search
    )

@app.post("/api/tasks", response_model=TaskResponse, status_code=status.HTTP_201_CREATED, tags=["Tasks"])
def create_task(task_in: TaskCreate, db: Session = Depends(get_db)):
    return crud.create_task(db, task_in)

@app.get("/api/tasks/{task_id}", response_model=TaskResponse, tags=["Tasks"])
def get_task(task_id: int, db: Session = Depends(get_db)):
    task = crud.get_task(db, task_id)
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Task with ID {task_id} not found"
        )
    return task

@app.put("/api/tasks/{task_id}", response_model=TaskResponse, tags=["Tasks"])
def update_task(task_id: int, task_in: TaskUpdate, db: Session = Depends(get_db)):
    updated = crud.update_task(db, task_id, task_in)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Task with ID {task_id} not found"
        )
    return updated

@app.delete("/api/tasks/{task_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Tasks"])
def delete_task(task_id: int, db: Session = Depends(get_db)):
    deleted = crud.delete_task(db, task_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Task with ID {task_id} not found"
        )
    return None
