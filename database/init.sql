-- PostgreSQL Schema Initialization for Task Management App

CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(50) DEFAULT 'medium' NOT NULL,
    category VARCHAR(50) DEFAULT 'DevOps' NOT NULL,
    completed BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at DESC);

-- Initial seed data
INSERT INTO tasks (title, description, priority, category, completed)
VALUES 
    ('Provision Azure Virtual Network', 'Create 10.0.0.0/16 VNet with App Subnet (10.0.1.0/24) and DB Subnet (10.0.2.0/24).', 'high', 'DevOps', true),
    ('Deploy PostgreSQL on VM2', 'Install and configure PostgreSQL 16 on database VM with restricted network access.', 'high', 'Database', true),
    ('Deploy FastAPI Backend on VM1', 'Run FastAPI uvicorn daemon connected to VM2 private IP at 10.0.2.4:5432.', 'high', 'Backend', false),
    ('Configure Nginx Reverse Proxy on VM1', 'Configure reverse proxy to serve React frontend at / and forward /api/ to FastAPI port 8000.', 'medium', 'DevOps', false),
    ('Set up Azure DevOps CI/CD Pipelines', 'Configure infrastructure YAML pipeline and application build & deployment pipeline.', 'high', 'CI/CD', false),
    ('Implement Automated Database Backups', 'Configure daily cron job using pg_dump with retention policy and Azure blob sync.', 'medium', 'Database', false)
ON CONFLICT DO NOTHING;

