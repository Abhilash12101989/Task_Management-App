import os
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

os.environ["DATABASE_URL"] = "sqlite:///./test.db"
os.environ["ENVIRONMENT"] = "testing"

from app.database import Base, get_db
from app.main import app

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture(autouse=True)
def setup_database():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)
    if os.path.exists("./test.db"):
        try:
            os.remove("./test.db")
        except Exception:
            pass

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "metrics" in data
    assert "X-Process-Time" in response.headers

def test_health_and_probes():
    # General health
    res_health = client.get("/api/health")
    assert res_health.status_code == 200
    assert "database_connected" in res_health.json()

    # Liveness probe
    res_live = client.get("/api/health/live")
    assert res_live.status_code == 200
    assert res_live.json() == {"status": "alive"}

    # Readiness probe
    res_ready = client.get("/api/health/ready")
    assert res_ready.status_code == 200
    assert res_ready.json() == {"status": "ready"}

def test_metrics_endpoint():
    response = client.get("/metrics")
    assert response.status_code == 200
    assert b"http_requests_total" in response.content

def test_create_and_get_task():
    payload = {
        "title": "Configure Azure Scale Set",
        "description": "Autoscale VMSS between 2 and 5 instances based on CPU",
        "priority": "high",
        "category": "DevOps"
    }
    response = client.post("/api/tasks", json=payload)
    assert response.status_code == 201
    created = response.json()
    assert created["title"] == payload["title"]
    assert created["completed"] is False
    assert "id" in created

    task_id = created["id"]
    get_res = client.get(f"/api/tasks/{task_id}")
    assert get_res.status_code == 200
    assert get_res.json()["title"] == payload["title"]

def test_update_and_delete_task():
    create_res = client.post("/api/tasks", json={"title": "Temporary Task"})
    task_id = create_res.json()["id"]

    update_res = client.put(f"/api/tasks/{task_id}", json={"completed": True, "priority": "low"})
    assert update_res.status_code == 200
    assert update_res.json()["completed"] is True

    del_res = client.delete(f"/api/tasks/{task_id}")
    assert del_res.status_code == 204

    get_again = client.get(f"/api/tasks/{task_id}")
    assert get_again.status_code == 404
