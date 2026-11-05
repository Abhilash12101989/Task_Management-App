# 📋 Three-Tier Cloud Task Management App on Azure

> **Production-Minded End-to-End Azure DevOps & Cloud Infrastructure Project**  
> Built with **React (Vite)** + **Python (FastAPI)** + **PostgreSQL 16**, provisioned via **Terraform**, and automated through **Azure DevOps CI/CD Pipelines**.

---

## 🏗️ 1. Project Architecture

This application follows a classic enterprise **Three-Tier Architecture** distributed across two dedicated Azure Virtual Machines:

```text
                             ┌────────────────────────┐
                             │  Web Browser / Users   │
                             └───────────┬────────────┘
                                         │
                                   HTTP / HTTPS
                                         │
                                         ▼
 ┌─────────────────────────────────────────────────────────────────────────────────┐
 │ Azure Virtual Network (10.0.0.0/16)                                             │
 │                                                                                 │
 │  ┌───────────────────────────────────────────────────────────────────────────┐  │
 │  │ Subnet 1: Application Subnet (10.0.1.0/24)                                │  │
 │  │                                                                           │  │
 │  │  ┌─────────────────────────────────────────────────────────────────────┐  │  │
 │  │  │ VM 1: Application Server (Standard_B2s Ubuntu 22.04)                │  │  │
 │  │  │ Public IP Attached                                                  │  │  │
 │  │  │                                                                     │  │  │
 │  │  │  ┌─────────────────┐     ┌───────────────────────────────────────┐  │  │  │
 │  │  │  │  Nginx Server   │────▶│ React Frontend (Port 80 /var/www)     │  │  │  │
 │  │  │  │ (Reverse Proxy) │     └───────────────────────────────────────┘  │  │  │
 │  │  │  │                 │────▶│ FastAPI Backend (Uvicorn 127.0.0.1:8000)│  │  │  │
 │  │  │  └─────────────────┘     └───────────────────────────────────────┘  │  │  │
 │  │  └──────────────────────────────────────────┬──────────────────────────┘  │  │
 │  └─────────────────────────────────────────────┼─────────────────────────────┘  │
 │                                                │                                │
 │                                     Private Network (TCP 5432)                  │
 │                                 Allowed ONLY from 10.0.1.0/24                   │
 │                                                │                                │
 │  ┌─────────────────────────────────────────────▼─────────────────────────────┐  │
 │  │ Subnet 2: Database Subnet (10.0.2.0/24)                                   │  │
 │  │                                                                           │  │
 │  │  ┌─────────────────────────────────────────────────────────────────────┐  │  │
 │  │  │ VM 2: Database Server (Standard_B2s Ubuntu 22.04)                   │  │  │
 │  │  │ Private IP Only (No Public IP)                                      │  │  │
 │  │  │                                                                     │  │  │
 │  │  │  ┌───────────────────────────────────────────────────────────────┐  │  │  │
 │  │  │  │ PostgreSQL 16 (taskdb / taskuser)                             │  │  │  │
 │  │  │  │ pg_hba.conf: host taskdb taskuser 10.0.1.0/24 scram-sha-256   │  │  │  │
 │  │  │  └───────────────────────────────────────────────────────────────┘  │  │  │
 │  │  └─────────────────────────────────────────────────────────────────────┘  │  │
 │  └───────────────────────────────────────────────────────────────────────────┘  │
 └─────────────────────────────────────────────────────────────────────────────────┘
```

### Component Breakdown

| Tier | Component | Host | Technology | Details |
|---|---|---|---|---|
| **Tier 1: Presentation** | Web UI | VM 1 | React 18, Vite | Single Page Application served statically by Nginx from `/var/www/task-app` |
| **Tier 1: Web Proxy** | Reverse Proxy | VM 1 | Nginx | Routes `/` to React SPA and `/api/` to FastAPI uvicorn daemon |
| **Tier 2: Logic** | REST API | VM 1 | Python 3.11, FastAPI, SQLAlchemy | Runs as a managed `systemd` daemon (`task-backend.service`) |
| **Tier 3: Data** | Database | VM 2 | PostgreSQL 16 | Private database accessible only over port 5432 from VM1 Subnet |
| **Infrastructure** | Cloud IaC | Azure | Terraform (azurerm provider) | Automates VNet, Subnets, NSGs, NICs, Public IP, and VMs |
| **CI/CD** | Automation | Cloud | Azure DevOps Pipelines | YAML pipelines for Infra (Plan/Apply) and App (Build/Test/Deploy) |

---

## 📁 2. Repository Structure

```text
.
├── frontend/                     # React + Vite Presentation Tier
│   ├── src/
│   │   ├── components/           # Header, TaskForm, TaskList, TaskStats
│   │   ├── services/api.js       # API client with automatic offline demo fallback
│   │   ├── App.jsx               # Main container
│   │   ├── App.css               # Clean responsive styling
│   │   └── main.jsx              # React DOM entry
│   ├── package.json
│   ├── vite.config.js
│   ├── Dockerfile                # Multi-stage production container
│   └── nginx.conf                # Nginx SPA config for Docker
│
├── backend/                      # Python FastAPI Application Tier
│   ├── app/
│   │   ├── config.py             # Environment settings & DB URLs
│   │   ├── database.py           # SQLAlchemy engine & session maker
│   │   ├── models.py             # Task database model
│   │   ├── schemas.py            # Pydantic validation schemas
│   │   ├── crud.py               # Database CRUD operations
│   │   └── main.py               # FastAPI app & REST endpoints
│   ├── tests/
│   │   └── test_main.py          # Pytest unit tests
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
│
├── database/                     # PostgreSQL Configuration & Scripts
│   ├── init.sql                  # Schema DDL & initial seed tasks
│   ├── setup-db.sh               # Shell script to configure PostgreSQL on VM2
│   ├── backup-db.sh              # Automated database backup script (pg_dump)
│   └── restore-db.sh             # Database restore script
│
├── nginx/                        # VM 1 Nginx Configuration
│   └── task-app-vm1.conf         # Site configuration for reverse proxying to FastAPI
│
├── terraform/                    # Infrastructure as Code (Azure)
│   ├── main.tf                   # VNet, Subnets, NSGs, VM1, VM2, Public IP
│   ├── variables.tf              # Configurable variables
│   ├── outputs.tf                # Public IP, connection commands, outputs
│   ├── providers.tf              # AzureRM & TLS provider definitions
│   ├── terraform.tfvars.example  # Example variable values
│   ├── backend.tf.example        # Azure Blob Storage remote state config
│   └── scripts/
│       ├── setup-app-vm.sh       # Cloud-init for VM1 (Nginx + Python + systemd)
│       └── setup-db-vm.sh        # Cloud-init for VM2 (PostgreSQL + network access)
│
├── pipelines/                    # Azure DevOps Multi-Stage CI/CD
│   ├── azure-pipelines-infra.yml # Terraform Validate, Plan, Approval, Apply
│   └── azure-pipelines-app.yml   # Frontend build, backend test, VM deploy
│
├── docker-compose.yml            # 1-command local orchestration
└── README.md
```

---

## 🚀 3. Quickstart: Run Locally

You can test and run the full 3-tier application on your local machine using either Docker Compose or direct commands:

### Option A: 1-Command Run with Docker Compose
Starts PostgreSQL, FastAPI backend, and React frontend together:

```bash
docker-compose up --build
```

- **Frontend:** Open [http://localhost:3000](http://localhost:3000)
- **FastAPI Docs:** Open [http://localhost:8000/docs](http://localhost:8000/docs)
- **API Health:** Open [http://localhost:8000/api/health](http://localhost:8000/api/health)

---

### Option B: Run Services Standalone

#### 1. Frontend:
```bash
cd frontend
npm install
npm run dev
```
- **Web UI:** Open [http://localhost:5173](http://localhost:5173) in your browser.
- *Note:* If the backend is not running, the frontend automatically falls back to interactive **Demo Mode** using browser `localStorage`.

#### 2. Backend:
```bash
cd backend
python -m venv venv
# Windows:
.\venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```
- **FastAPI Docs:** Open [http://localhost:8000/docs](http://localhost:8000/docs)
- **API Health:** Open [http://localhost:8000/api/health](http://localhost:8000/api/health)

#### 3. Run Backend Unit Tests:
```bash
cd backend
pytest tests/
```

---

## ☁️ 4. Reusable Parent-Child Terraform Architecture

The infrastructure is engineered using **reusable Parent-Child Terraform Modules** following HashiCorp best practices:

```text
terraform/
├── main.tf                    # Parent (Root) Module: orchestrates child modules
├── variables.tf               # Environment input variables
├── outputs.tf                 # Exports values exposed by child modules
├── providers.tf               # Cloud provider declarations
├── modules/                   # Reusable Child Modules
│   ├── networking/            # VNet, Subnets (App & DB), Resource Group
│   ├── security/              # Application & Database NSGs with network isolation
│   ├── database_vm/           # VM 2 (PostgreSQL) with private NIC & cloud-init
│   └── compute_app/           # VM 1 (React + FastAPI + Nginx) with Public IP & cloud-init
└── production/                # Scalable Production Stack (VMSS + Load Balancer + Key Vault)
```

### Module Responsibilities

| Child Module | Path | Responsibilities | Key Outputs |
|---|---|---|---|
| **`networking`** | `modules/networking/` | Provisions RG, VNet (`10.0.0.0/16`), App Subnet (`10.0.1.0/24`), DB Subnet (`10.0.2.0/24`) | `app_subnet_id`, `db_subnet_id`, `vnet_id` |
| **`security`** | `modules/security/` | Creates App NSG (80, 443, 22), DB NSG (5432 restricted to App Subnet), subnet associations | `app_nsg_id`, `db_nsg_id` |
| **`database_vm`** | `modules/database_vm/` | Provisions VM 2 in DB subnet with private IP only and runs `setup-db-vm.sh` | `private_ip_address`, `vm_id` |
| **`compute_app`** | `modules/compute_app/` | Provisions VM 1 in App subnet with Static Public IP and runs `setup-app-vm.sh` | `public_ip_address`, `vm_id` |

### Steps to Provision
1. Navigate to the terraform directory:
   ```bash
   cd terraform
   ```
2. Create your variable file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Initialize Terraform (loads child modules):
   ```bash
   terraform init
   ```
4. Validate & Plan:
   ```bash
   terraform validate
   terraform plan -out=tfplan
   ```
5. Apply the infrastructure:
   ```bash
   terraform apply tfplan
   ```

### Outputs
Once provisioned, Terraform prints:
- `app_vm_public_ip`: Public IP of VM 1 (accessible from browser)
- `app_url`: Application URL (e.g. `http://20.xxx.xxx.xxx`)
- `db_vm_private_ip`: Internal IP of VM 2 (e.g. `10.0.2.4`)
- `ssh_connect_app_vm`: SSH connection command to VM 1
- `ssh_connect_db_vm_via_jumpbox`: SSH command to VM 2 via VM 1 jumpbox

---

## 🔒 5. Security & Network Isolation

1. **Subnet Separation:**
   - VM 1 resides in `snet-app` (`10.0.1.0/24`).
   - VM 2 resides in `snet-db` (`10.0.2.0/24`).
2. **Network Security Group (NSG) Rules:**
   - **App NSG:** Inbound HTTP (80) & HTTPS (443) are allowed from the Internet. SSH (22) is restricted.
   - **DB NSG:** Inbound port 5432 (PostgreSQL) is allowed **strictly from `10.0.1.0/24`** (Application Subnet). All public inbound traffic is denied.
   - **Jumpbox SSH:** VM 2 has no public IP address. Administrators SSH to VM 2 by hopping through VM 1 (`ssh -J azureuser@<VM1_PUBLIC_IP> azureuser@<VM2_PRIVATE_IP>`).
3. **Database Access Control:**
   - PostgreSQL `pg_hba.conf` explicitly requires `scram-sha-256` or `md5` authentication restricted to CIDR `10.0.1.0/24`.

---

## 🔄 6. Azure DevOps CI/CD Pipelines

Two production-grade multi-stage YAML pipelines are included in `pipelines/`:

### Prerequisites in Azure DevOps
Before running the pipelines, configure these in **Project Settings**:
1. **Service Connection 1 (Azure Resource Manager):**
   - Name: `azure-service-connection`
   - Scope: Subscription or Resource Group (`rg-taskapp-dev`)
2. **Service Connection 2 (SSH):**
   - Name: `taskapp-vm1-ssh`
   - Host: `<VM1_PUBLIC_IP>` (from Terraform output)
   - Port: `22`
   - Username: `azureuser`
   - Private Key: Generated RSA key
3. **Environments (Pipelines -> Environments):**
   - `production-infra`: Add **Approvals and checks** -> Approvers (assign yourself or senior engineer).
   - `production-app`: Automated deployment environment for VM 1.

### Pipeline 1: Infrastructure as Code (`azure-pipelines-infra.yml`)
1. **Stage 1 (TerraformPlan):**
   - Runs `terraform init` with Azure Blob Storage remote state (`backendServiceArm`).
   - Runs `terraform validate`.
   - Generates and publishes the `tfplan` binary artifact.
2. **Stage 2 (TerraformApply):**
   - Protected by Azure DevOps **Environment Approval Check** (`production-infra`).
   - Requires manual engineer approval before running `terraform apply`.

### Pipeline 2: Application CI/CD (`azure-pipelines-app.yml`)
1. **Stage 1 (BuildAndTest):**
   - **Job 1 (Frontend):** Builds React production bundle with Vite (`npm ci`, `npm run build`), outputs `dist/`.
   - **Job 2 (Backend):** Installs Python dependencies, executes `pytest` with JUnit XML reporting, packages backend code into `tar.gz`.
2. **Stage 2 (DeployToVM):**
   - Securely copies React bundle to VM 1 `/var/www/task-app`.
   - Deploys backend code to VM 1 `/opt/task-backend`.
   - Restarts `task-backend.service` via `systemctl`.
   - Reloads Nginx.
   - Runs curl healthcheck smoke test against `http://127.0.0.1:8000/api/health`.

---

## 🔧 7. Operational Troubleshooting & Diagnostics

Common commands to inspect and debug services on the VMs:

| Target | Command | Purpose |
|---|---|---|
| **VM 1 Backend** | `sudo systemctl status task-backend.service` | Check if FastAPI uvicorn daemon is running |
| **VM 1 Logs** | `sudo journalctl -u task-backend.service -f -n 50` | Stream live backend application logs |
| **VM 1 Nginx** | `sudo nginx -t && sudo systemctl status nginx` | Test Nginx configuration and check status |
| **VM 1 Nginx Logs**| `sudo tail -f /var/log/nginx/error.log` | Inspect reverse proxy errors or 502 Bad Gateway |
| **VM 2 Database** | `sudo systemctl status postgresql` | Check PostgreSQL service status |
| **VM 2 DB Connect**| `psql -U taskuser -d taskdb -h localhost` | Test local database login |
| **VM 1 -> VM 2 DB**| `nc -zv <VM2_PRIVATE_IP> 5432` | Verify network connectivity between VM1 and VM2 |

---

## 💾 7. Database Backups & Recovery

- **Automated Daily Backups:** Configured on VM 2 via cron job executing `/usr/local/bin/backup-taskdb.sh` daily at 02:00 UTC.
- **Manual Backup:**
  ```bash
  ./database/backup-db.sh
  ```
- **Restore from Backup:**
  ```bash
  ./database/restore-db.sh /var/backups/taskdb/taskdb_backup_YYYYMMDD_HHMMSS.sql.gz
  ```

---

## 🏢 8. Enterprise Scalable Production Architecture (`terraform/production/`)

For mission-critical production workloads, this repository includes an enterprise-grade infrastructure implementation in `terraform/production/`:

```text
                                  ┌────────────────────────┐
                                  │  Web Users / Clients   │
                                  └───────────┬────────────┘
                                              │
                                              ▼
                             ┌─────────────────────────────────┐
                             │  Azure Standard Load Balancer   │
                             │  Public IP + Health Probe /80   │
                             └────────────────┬────────────────┘
                                              │
                       ┌──────────────────────┴──────────────────────┐
                       │                                             │
                       ▼                                             ▼
          ┌─────────────────────────┐                   ┌─────────────────────────┐
          │ VMSS Instance 1 (EastUS)│                   │ VMSS Instance 2 (EastUS)│
          │ Nginx + Gunicorn (2x+1) │                   │ Nginx + Gunicorn (2x+1) │
          │ FastAPI + React SPA     │                   │ FastAPI + React SPA     │
          └────────────┬────────────┘                   └────────────┬────────────┘
                       │                                             │
                       │           (Autoscale: 2 to 5 instances)     │
                       │              (Scale out when CPU > 75%)     │
                       └──────────────────────┬──────────────────────┘
                                              │
                                              ▼ (Private Link DNS)
                             ┌─────────────────────────────────┐
                             │ Azure Database for PostgreSQL   │
                             │ Flexible Server (Zone Redundant)│
                             │ Managed Backups + Key Vault Auth│
                             └─────────────────────────────────┘
```

### Production Architecture Highlights

1. **Zero Downtime Horizontal Autoscaling:**
   - **Azure Virtual Machine Scale Set (VMSS):** Runs between 2 (baseline HA) and 5 instances.
   - **Autoscale Rules:** Automatically scales out when CPU > 75% for 5 minutes, and scales in when CPU < 25%.
2. **Traffic Distribution & Health Probing:**
   - **Azure Standard Load Balancer:** Distributes traffic evenly across all healthy instances using `/healthz` HTTP probe.
3. **Enterprise Managed Database:**
   - **PostgreSQL Flexible Server:** Automated daily backups with point-in-time restore, private VNet integration via Private DNS Zone, and managed maintenance windows.
4. **Zero-Trust Secret Management:**
   - **Azure Key Vault:** Stores randomly generated 24-character cryptographic database passwords and SSH credentials.
5. **Observability & Metrics:**
   - **Prometheus Metrics (`/metrics`):** Real-time tracking of `http_requests_total`, request latency histogram, and status codes.
   - **Azure Log Analytics:** Centralized logging for VMSS diagnostic logs, Nginx access logs, and performance metrics.
6. **Automated CI/CD Rollback:**
   - If the post-deployment health check (`/api/health/ready`) fails, the pipeline immediately rolls back the application code and Nginx configuration to the previous stable release.

To deploy the production-grade scalable infrastructure:
```bash
cd terraform/production
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out=prodplan
terraform apply prodplan
```

---

## 💼 9. DevOps Interview Talking Points

When explaining this project in an Azure DevOps / Cloud Engineer interview:

1. **Why 2 VMs instead of 1?**
   - Separating presentation/logic from persistence adheres to the principle of least privilege: the database VM does not require a public IP, drastically reducing attack surface.
2. **How is state managed in Terraform?**
   - We configure Azure Blob Storage with blob lease locking to prevent concurrent state corruption when multiple engineers or CI/CD pipelines run.
3. **What are the production bottlenecks and next steps?**
   - **High Availability:** Replace single VM1 with an **Azure Virtual Machine Scale Set (VMSS)** behind an **Azure Application Gateway** or **Load Balancer**.
   - **Managed Database:** In enterprise production, migrate self-hosted VM2 PostgreSQL to **Azure Database for PostgreSQL Flexible Server** for built-in automated backups, multi-AZ high availability, and patch management.
   - **Secret Management:** Store database passwords and SSH keys in **Azure Key Vault** and fetch them during pipeline execution.

