import React, { useState, useEffect, useCallback } from 'react';
import Header from './components/Header.jsx';
import TaskStats from './components/TaskStats.jsx';
import TaskForm from './components/TaskForm.jsx';
import TaskList from './components/TaskList.jsx';
import { api } from './services/api.js';
import './App.css';

export default function App() {
  const [tasks, setTasks] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isOnline, setIsOnline] = useState(false);
  const [backendInfo, setBackendInfo] = useState(null);
  const [editingTask, setEditingTask] = useState(null);
  const [toast, setToast] = useState(null);

  // Show toast notification
  const showToast = (message, type = 'info') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 3500);
  };

  // Check health and load tasks
  const refreshData = useCallback(async () => {
    setIsLoading(true);

    // 1. Check health
    const health = await api.checkHealth();
    setIsOnline(health.isOnline);
    if (health.isOnline) {
      setBackendInfo(health.data);
    } else {
      setBackendInfo(null);
    }

    // 2. Fetch tasks
    const result = await api.getTasks();
    setTasks(result.data || []);
    setIsLoading(false);

    if (result.source === 'backend') {
      showToast('Loaded tasks from PostgreSQL database', 'success');
    } else {
      showToast('Backend offline - using local demo storage', 'info');
    }
  }, []);

  useEffect(() => {
    refreshData();
  }, [refreshData]);

  // Create or update task
  const handleSaveTask = async (taskData) => {
    try {
      if (editingTask) {
        // Update
        const res = await api.updateTask(editingTask.id, taskData);
        setTasks((prev) =>
          prev.map((t) => (t.id === editingTask.id ? { ...t, ...res.data } : t))
        );
        setEditingTask(null);
        showToast('Task updated successfully!', 'success');
      } else {
        // Create
        const res = await api.createTask(taskData);
        setTasks((prev) => [res.data, ...prev]);
        showToast('Task created successfully!', 'success');
      }
    } catch (err) {
      console.error(err);
      showToast(`Error: ${err.message}`, 'error');
    }
  };

  // Toggle complete
  const handleToggleComplete = async (task) => {
    try {
      const updated = { completed: !task.completed };
      const res = await api.updateTask(task.id, updated);
      setTasks((prev) =>
        prev.map((t) => (t.id === task.id ? { ...t, completed: res.data.completed } : t))
      );
      showToast(
        task.completed ? 'Task marked as in progress' : 'Task completed! 🎉',
        'info'
      );
    } catch (err) {
      console.error(err);
      showToast(`Error: ${err.message}`, 'error');
    }
  };

  // Delete task
  const handleDeleteTask = async (id) => {
    if (!window.confirm('Are you sure you want to delete this task?')) return;
    try {
      await api.deleteTask(id);
      setTasks((prev) => prev.filter((t) => t.id !== id));
      if (editingTask && editingTask.id === id) {
        setEditingTask(null);
      }
      showToast('Task deleted', 'info');
    } catch (err) {
      console.error(err);
      showToast(`Error: ${err.message}`, 'error');
    }
  };

  return (
    <div className="app-container">
      {toast && (
        <div className={`toast toast-${toast.type}`}>
          {toast.message}
        </div>
      )}

      <Header
        isOnline={isOnline}
        backendInfo={backendInfo}
        onRefresh={refreshData}
      />

      <main className="app-main">
        <TaskStats tasks={tasks} />

        <div className="content-grid">
          <section className="section-form">
            <TaskForm
              onSaveTask={handleSaveTask}
              editingTask={editingTask}
              onCancelEdit={() => setEditingTask(null)}
            />

            <div className="info-card">
              <h4>☁️ Architecture Topology</h4>
              <ul>
                <li><strong>VM 1 (Application):</strong> Nginx + React + FastAPI</li>
                <li><strong>VM 2 (Database):</strong> PostgreSQL (Private Network)</li>
                <li><strong>Network:</strong> Azure VNet (10.0.0.0/16) + NSG rules</li>
                <li><strong>CI/CD:</strong> Azure DevOps multi-stage pipelines</li>
              </ul>
            </div>
          </section>

          <section className="section-list">
            <TaskList
              tasks={tasks}
              onToggleComplete={handleToggleComplete}
              onDeleteTask={handleDeleteTask}
              onEditTask={(task) => setEditingTask(task)}
              isLoading={isLoading}
            />
          </section>
        </div>
      </main>

      <footer className="app-footer">
        <p>Three-Tier Architecture Task Manager • Built for Azure & Azure DevOps CI/CD</p>
      </footer>
    </div>
  );
}

