#!/bin/bash
# ==============================================================================
# Cloud-init provisioning script for VM 1 (Application Server)
# ==============================================================================
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo ">>> [1/6] Updating packages..."
apt-get update -y
apt-get install -y --no-install-recommends \
    nginx \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    libpq-dev \
    gcc

echo ">>> [2/6] Setting up application directories..."
mkdir -p /var/www/task-app
mkdir -p /opt/task-backend
chown -R azureuser:azureuser /var/www/task-app
chown -R azureuser:azureuser /opt/task-backend

echo ">>> [3/6] Setting up Python virtual environment for FastAPI backend..."
sudo -u azureuser python3 -m venv /opt/task-backend/venv
sudo -u azureuser /opt/task-backend/venv/bin/pip install --upgrade pip

cat << 'EOF' > /opt/task-backend/requirements.txt
fastapi>=0.104.0
uvicorn[standard]>=0.24.0
gunicorn>=21.2.0
pydantic>=2.4.0
pydantic-settings>=2.0.0
sqlalchemy>=2.0.0
psycopg2-binary>=2.9.9
python-dotenv>=1.0.0
prometheus-client>=0.19.0
tenacity>=8.2.3
EOF

sudo -u azureuser /opt/task-backend/venv/bin/pip install -r /opt/task-backend/requirements.txt

echo ">>> [4/6] Creating Backend Environment Configuration..."
cat << EOF > /opt/task-backend/.env
APP_NAME="Task Management API"
ENVIRONMENT="production"
DATABASE_URL="postgresql://taskuser:${DB_PASSWORD}@${DB_HOST}:5432/taskdb"
CORS_ORIGINS=["*"]
EOF
chown azureuser:azureuser /opt/task-backend/.env
chmod 600 /opt/task-backend/.env

echo ">>> [5/6] Creating Systemd Service for FastAPI backend..."
cat << 'EOF' > /etc/systemd/system/task-backend.service
[Unit]
Description=FastAPI Task Management Backend Service
After=network.target

[Service]
User=azureuser
Group=azureuser
WorkingDirectory=/opt/task-backend
EnvironmentFile=/opt/task-backend/.env
ExecStart=/opt/task-backend/venv/bin/gunicorn -c gunicorn_conf.py app.main:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable task-backend.service

echo ">>> [6/6] Configuring Nginx reverse proxy..."
cat << 'EOF' > /etc/nginx/sites-available/task-app
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/task-app;
    index index.html index.htm;

    gzip on;
    gzip_types text/plain text/css text/javascript application/json;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /docs {
        proxy_pass http://127.0.0.1:8000/docs;
        proxy_set_header Host $host;
    }

    location /openapi.json {
        proxy_pass http://127.0.0.1:8000/openapi.json;
        proxy_set_header Host $host;
    }
}
EOF

# Create a temporary welcome page until CI/CD deploys React build
cat << 'EOF' > /var/www/task-app/index.html
<!DOCTYPE html>
<html>
<head><title>Task Management App - Provisioned</title></head>
<body style="font-family:sans-serif;text-align:center;padding:50px;">
  <h1>🚀 VM 1 Application Server Provisioned!</h1>
  <p>Nginx & FastAPI backend configured. Waiting for Azure DevOps pipeline to deploy the React frontend build.</p>
</body>
</html>
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/task-app /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx
systemctl enable nginx

echo "✅ VM 1 provisioning complete!"

