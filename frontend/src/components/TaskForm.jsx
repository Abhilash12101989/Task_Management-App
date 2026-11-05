import React, { useState, useEffect } from 'react';

export default function TaskForm({ onSaveTask, editingTask, onCancelEdit }) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [priority, setPriority] = useState('medium');
  const [category, setCategory] = useState('DevOps');

  useEffect(() => {
    if (editingTask) {
      setTitle(editingTask.title || '');
      setDescription(editingTask.description || '');
      setPriority(editingTask.priority || 'medium');
      setCategory(editingTask.category || 'DevOps');
    } else {
      setTitle('');
      setDescription('');
      setPriority('medium');
      setCategory('DevOps');
    }
  }, [editingTask]);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!title.trim()) {
      alert('Please enter a task title');
      return;
    }

    onSaveTask({
      title: title.trim(),
      description: description.trim(),
      priority,
      category,
    });

    if (!editingTask) {
      setTitle('');
      setDescription('');
      setPriority('medium');
      setCategory('DevOps');
    }
  };

  return (
    <form className="task-form-card" onSubmit={handleSubmit}>
      <div className="form-header">
        <h3>{editingTask ? '✏️ Edit Task' : '➕ Create New Task'}</h3>
        {editingTask && (
          <button type="button" className="btn-cancel" onClick={onCancelEdit}>
            Cancel
          </button>
        )}
      </div>

      <div className="form-group">
        <label htmlFor="task-title">Task Title *</label>
        <input
          id="task-title"
          type="text"
          placeholder="e.g. Provision Azure VM with Terraform..."
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          required
        />
      </div>

      <div className="form-group">
        <label htmlFor="task-desc">Description (Optional)</label>
        <textarea
          id="task-desc"
          rows="2"
          placeholder="Add details, links, or instructions..."
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />
      </div>

      <div className="form-row">
        <div className="form-group flex-1">
          <label htmlFor="task-priority">Priority</label>
          <select
            id="task-priority"
            value={priority}
            onChange={(e) => setPriority(e.target.value)}
          >
            <option value="low">🟢 Low</option>
            <option value="medium">🟡 Medium</option>
            <option value="high">🔴 High</option>
          </select>
        </div>

        <div className="form-group flex-1">
          <label htmlFor="task-category">Category</label>
          <select
            id="task-category"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
          >
            <option value="DevOps">☁️ DevOps / Azure</option>
            <option value="Backend">🐍 Backend (FastAPI)</option>
            <option value="Frontend">⚛️ Frontend (React)</option>
            <option value="Database">🐘 Database (PostgreSQL)</option>
            <option value="General">📌 General</option>
          </select>
        </div>

        <div className="form-actions-inline">
          <button type="submit" className="btn-primary">
            {editingTask ? 'Update Task' : 'Add Task'}
          </button>
        </div>
      </div>
    </form>
  );
}

