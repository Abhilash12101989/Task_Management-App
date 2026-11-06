# 📋 Three-Tier Cloud Task Management Application

> **Full-Stack Cloud-Native Web Application**  
> Built with **React 18 (Vite)** + **Python (FastAPI)** + **PostgreSQL 16**, fully containerized with **Docker** & **Docker Compose**, and reverse-proxied with **Nginx**.

---

## 🏗️ 1. Application Architecture

This application is designed as an enterprise **Three-Tier Architecture** that can run locally via Docker Compose or be deployed across cloud virtual machines (e.g. on Microsoft Azure):

```text
                             ┌────────────────────────┐
                             │  Web Browser / Users   │
                             └───────────┬────────────┘
                                         │
                                    HTTP / HTTPS
                                         │
                                         ▼
 ┌─────────────────────────────────────────────────────────────────────────────────┐
 │ Presentation & Logic Tier (Web / App)                                           │
 │                                                                                 │
 │  ┌───────────────────────────────────────────────────────────────────────────┐  │
 │  │ Nginx (Reverse Proxy)                                                     │  │
 │  │  ├── Port 80 / -> Serves React Production Single Page Application (SPA)   │  │
 │  │  └── Port 80 /api/* -> Proxies requests to FastAPI backend (Port 8000)    │  │
 │  └─────────────────────────────────────┬─────────────────────────────────────┘  │
 │                                        │                                        │
 │  ┌─────────────────────────────────────▼─────────────────────────────────────┐  │
 │  │ FastAPI REST API Backend (Python 3.11, Uvicorn, SQLAlchemy)               │  │
 │  │  ├── Interactive Swagger UI at /docs                                      │  │
 │  │  ├── Healthcheck endpoints at /api/health and /api/health/ready           │  │
 │  │  └── CRUD REST endpoints at /api/tasks                                    │  │
 │  └─────────────────────────────────────┬─────────────────────────────────────┘  │
 └────────────────────────────────────────┼────────────────────────────────────────┘
                                          │
                              SQL Connection (TCP 5432)
                                          │
 ┌────────────────────────────────────────▼────────────────────────────────────────┐
 │ Data Tier (Database)                                                            │
 │                                                                                 │
 │  ┌───────────────────────────────────────────────────────────────────────────┐  │
 │  │ PostgreSQL 16                                                             │  │
 │  │  ├── Database: taskdb                                                     │  │
 │  │  ├── User: taskuser                                                       │  │
 │  │  └── Schema & Seeds: database/init.sql                                    │  │
 │  └───────────────────────────────────────────────────────────────────────────┘  │
 └─────────────────────────────────────────────────────────────────────────────────┘
```

### Component Breakdown

| Tier | Component | Technology | Directory | Details |
|---|---|---|---|---|
| **Tier 1: Presentation** | Web UI | React 18, Vite | `frontend/` | Single Page Application with task dashboard, status filters, analytics cards, and demo fallback mode. |
| **Tier 1: Web Proxy** | Reverse Proxy | Nginx | `nginx/` | Routes `/` to React static bundle and reverse-proxies `/api/` to FastAPI uvicorn daemon. |
| **Tier 2: Logic** | REST API | Python 3.11, FastAPI, SQLAlchemy | `backend/` | High-performance asynchronous API, Pydantic data validation, Pytest test suite, and Swagger docs. |
| **Tier 3: Data** | Database | PostgreSQL 16 | `database/` | Relational storage for tasks, statuses, priorities, timestamps, and automated seed scripts. |
| **Containerization** | Orchestration | Docker & Compose | Root | Multi-stage Dockerfiles for frontend & backend with single-command `docker-compose.yml`. |

---

## 📁 2. Repository Structure

```text
.
├── frontend/                     # React + Vite Presentation Tier
│   ├── src/
│   │   ├── components/           # Header, TaskForm, TaskList, TaskStats
│   │   ├── services/api.js       # Axios API client with automatic offline demo fallback
│   │   ├── App.jsx               # Main React dashboard component
│   │   ├── App.css               # Clean modern responsive styling
│   │   └── main.jsx              # React DOM entry
│   ├── package.json
│   ├── vite.config.js
│   ├── Dockerfile                # Multi-stage production container
│   └── nginx.conf                # Nginx SPA config for Docker
│
├── backend/                      # Python FastAPI Application Tier
│   ├── app/
│   │   ├── config.py             # Environment settings & DB connection string
│   │   ├── database.py           # SQLAlchemy engine & session maker
│   │   ├── models.py             # Task database model
│   │   ├── schemas.py            # Pydantic validation schemas
│   │   ├── crud.py               # Database CRUD operations
│   │   └── main.py               # FastAPI app & REST endpoints
│   ├── tests/
│   │   └── test_main.py          # Pytest automated unit tests
│   ├── requirements.txt          # Python dependencies (FastAPI, uvicorn, psycopg2-binary, etc.)
│   ├── Dockerfile
│   └── .env.example
│
├── database/                     # PostgreSQL Configuration & Scripts
│   ├── init.sql                  # Schema DDL & initial seed tasks
│   ├── setup-db.sh               # Shell script to configure PostgreSQL on Linux
│   ├── backup-db.sh              # Automated database backup script (pg_dump)
│   └── restore-db.sh             # Database restore script
│
├── nginx/                        # Nginx Configuration
│   └── task-app-vm1.conf         # Site reverse-proxy configuration for VM deployment
│
├── docker-compose.yml            # 1-command local orchestration
├── .gitignore
└── README.md
```

---

## 🚀 3. Quickstart: Run Locally

### Option A: 1-Command Run with Docker Compose (Recommended)
Starts PostgreSQL, FastAPI backend, and React frontend together:

```bash
docker-compose up --build
```

- **Frontend Application:** Open [http://localhost:3000](http://localhost:3000)
- **FastAPI Interactive Docs (Swagger):** Open [http://localhost:8000/docs](http://localhost:8000/docs)
- **API Healthcheck:** Open [http://localhost:8000/api/health](http://localhost:8000/api/health)

*(To stop the containers: `docker-compose down`)*

---

### Option B: Run Services Standalone (Developer Mode)

#### 1. Database (PostgreSQL)
Start a local PostgreSQL container:
```bash
docker run --name task-postgres -e POSTGRES_DB=taskdb -e POSTGRES_USER=taskuser -e POSTGRES_PASSWORD=taskpassword -p 5432:5432 -v $(pwd)/database/init.sql:/docker-entrypoint-initdb.d/init.sql -d postgres:16-alpine
```

#### 2. Backend (FastAPI):
```bash
cd backend

# Create & activate virtual environment
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

# Install dependencies & run
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```
- API Docs: [http://localhost:8000/docs](http://localhost:8000/docs)

#### 3. Run Backend Unit Tests:
```bash
cd backend
pytest tests/
```

#### 4. Frontend (React):
```bash
cd frontend
npm install
npm run dev
```
- Web UI: [http://localhost:5173](http://localhost:5173)

---

## 📡 4. REST API Specification

| Method | Endpoint | Description | Sample Payload / Response |
|---|---|---|---|
| `GET` | `/api/health` | Service health status | `{"status": "healthy", "service": "task-management-api"}` |
| `GET` | `/api/health/ready` | Database connection readiness probe | `{"status": "ready", "database": "connected"}` |
| `GET` | `/api/tasks` | List all tasks (supports `?status=&priority=&search=`) | `[{"id": 1, "title": "Setup CI/CD", "status": "in_progress", ...}]` |
| `POST` | `/api/tasks` | Create a new task | `{"title": "Audit NSG rules", "priority": "high"}` |
| `GET` | `/api/tasks/{id}` | Get task details by ID | Task object |
| `PUT` | `/api/tasks/{id}` | Update task title, status, or priority | `{"status": "completed"}` |
| `DELETE` | `/api/tasks/{id}`| Delete a task | `{"detail": "Task deleted successfully"}` |

---

## 🛠️ 5. Cloud Architecture Blueprint (For Your Custom Terraform & Pipelines)

When you build your own **Terraform IaC** and **CI/CD Pipelines**, you can use the following specifications:

### Target Infrastructure Architecture (Phase 1: Azure VM + PaaS)
1. **Virtual Network (VNet):** `10.0.0.0/16` (Region: Central India)
   - **App Subnet (`snet-app`):** `10.0.1.0/24` (Hosts Private Application VM)
   - **Database Subnet (`snet-db`):** `10.0.2.0/28` (Delegated to `Microsoft.DBforPostgreSQL/flexibleServers`)
   - **Bastion Subnet (`AzureBastionSubnet`):** `10.0.3.0/26` (Hosts Azure Bastion Host)
2. **Network Security Groups (NSGs):**
   - **App NSG:** Inbound HTTP (Port 80) and HTTPS (Port 443); SSH (Port 22) **strictly restricted to AzureBastionSubnet (`10.0.3.0/26`)**.
3. **Application VM (Private Compute):**
   - OS: Ubuntu 22.04 LTS (`Standard_B2s`)
   - Networking: **Private IP only** (No Public IP).
   - Authentication: SSH Public Key authentication only (`disable_password_authentication = true`).
   - Administration: Accessible securely via **Azure Bastion** (`bas-taskmanagement-dev`).
   - Workload: Runs Docker containers (Nginx reverse proxy, React SPA, and FastAPI REST API).
4. **Database Tier (PaaS):**
   - Service: Azure Database for PostgreSQL Flexible Server with private VNet integration.
   - Networking: Private DNS Zone (`privatelink.postgres.database.azure.com`) linked to VNet; public network access disabled.
5. **Outbound Connectivity:**
   - Azure NAT Gateway attached to `snet-app` for secure outbound internet access (package installs, container image pulls).

### Recommended CI/CD Pipeline Stages
- **Infrastructure Pipeline:**
  - `terraform init` -> `terraform validate` -> `terraform plan` -> `Manual Approval` -> `terraform apply`
- **Application Pipeline:**
  - **Build & Test Stage:**
    - Frontend: `npm ci` && `npm run build` -> Artifact: `dist/`
    - Backend: `pip install -r requirements.txt` && `pytest` -> Artifact: backend bundle
  - **Deploy Stage:**
    - SSH/SCP deployment to VM 1, restart systemd service, reload Nginx, and execute healthcheck curl.
