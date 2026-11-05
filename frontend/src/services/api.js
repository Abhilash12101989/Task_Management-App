const API_BASE = import.meta.env.VITE_API_URL || '/api';
const LOCAL_STORAGE_KEY = 'taskmanager_offline_tasks';

const INITIAL_FALLBACK_TASKS = [
  {
    id: 1,
    title: 'Configure Azure Virtual Network and Subnets',
    description: 'Set up 10.0.0.0/16 with Frontend Subnet (10.0.1.0/24) and DB Subnet (10.0.2.0/24).',
    priority: 'high',
    category: 'DevOps',
    completed: true,
    created_at: new Date(Date.now() - 86400000 * 2).toISOString(),
  },
  {
    id: 2,
    title: 'Deploy FastAPI Backend & Connect to PostgreSQL VM2',
    description: 'Verify SQLAlchemy connection string to VM2 private IP (10.0.2.4:5432).',
    priority: 'high',
    category: 'Backend',
    completed: false,
    created_at: new Date(Date.now() - 86400000).toISOString(),
  },
  {
    id: 3,
    title: 'Configure Nginx Reverse Proxy on VM1',
    description: 'Route root path / to React build and /api/ to FastAPI port 8000.',
    priority: 'medium',
    category: 'DevOps',
    completed: false,
    created_at: new Date().toISOString(),
  },
  {
    id: 4,
    title: 'Setup Azure DevOps CI/CD Pipelines',
    description: 'Configure infra-pipeline.yml for Terraform and app-pipeline.yml for automated build & deploy.',
    priority: 'low',
    category: 'CI/CD',
    completed: false,
    created_at: new Date().toISOString(),
  },
];

// Helper to get local tasks
const getLocalTasks = () => {
  try {
    const data = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (!data) {
      localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(INITIAL_FALLBACK_TASKS));
      return INITIAL_FALLBACK_TASKS;
    }
    return JSON.parse(data);
  } catch (e) {
    return INITIAL_FALLBACK_TASKS;
  }
};

const saveLocalTasks = (tasks) => {
  try {
    localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(tasks));
  } catch (e) {
    console.error('LocalStorage save error:', e);
  }
};

export const api = {
  // Check backend health
  async checkHealth() {
    try {
      const response = await fetch(`${API_BASE}/health`, {
        signal: AbortSignal.timeout(2500),
      });
      if (response.ok) {
        const data = await response.json();
        return { isOnline: true, data };
      }
      return { isOnline: false, error: 'Health endpoint returned non-200' };
    } catch (err) {
      return { isOnline: false, error: err.message };
    }
  },

  // Get all tasks
  async getTasks() {
    try {
      const response = await fetch(`${API_BASE}/tasks`, {
        signal: AbortSignal.timeout(3000),
      });
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
      const data = await response.json();
      return { data, source: 'backend' };
    } catch (err) {
      console.warn('Backend unavailable, using LocalStorage fallback:', err.message);
      return { data: getLocalTasks(), source: 'local' };
    }
  },

  // Create a task
  async createTask(taskData) {
    try {
      const response = await fetch(`${API_BASE}/tasks`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(taskData),
        signal: AbortSignal.timeout(4000),
      });
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
      const data = await response.json();
      return { data, source: 'backend' };
    } catch (err) {
      console.warn('Backend unavailable, creating task in LocalStorage:', err.message);
      const local = getLocalTasks();
      const newTask = {
        id: Date.now(),
        ...taskData,
        completed: false,
        created_at: new Date().toISOString(),
      };
      local.unshift(newTask);
      saveLocalTasks(local);
      return { data: newTask, source: 'local' };
    }
  },

  // Update a task (edit or toggle complete)
  async updateTask(id, updateData) {
    try {
      const response = await fetch(`${API_BASE}/tasks/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updateData),
        signal: AbortSignal.timeout(4000),
      });
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
      const data = await response.json();
      return { data, source: 'backend' };
    } catch (err) {
      console.warn('Backend unavailable, updating task in LocalStorage:', err.message);
      const local = getLocalTasks();
      const index = local.findIndex((t) => t.id === id);
      if (index !== -1) {
        local[index] = { ...local[index], ...updateData, updated_at: new Date().toISOString() };
        saveLocalTasks(local);
        return { data: local[index], source: 'local' };
      }
      throw new Error('Task not found in local storage');
    }
  },

  // Delete a task
  async deleteTask(id) {
    try {
      const response = await fetch(`${API_BASE}/tasks/${id}`, {
        method: 'DELETE',
        signal: AbortSignal.timeout(4000),
      });
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
      return { success: true, source: 'backend' };
    } catch (err) {
      console.warn('Backend unavailable, deleting task from LocalStorage:', err.message);
      let local = getLocalTasks();
      local = local.filter((t) => t.id !== id);
      saveLocalTasks(local);
      return { success: true, source: 'local' };
    }
  },
};

