import React, { useState } from 'react';

export default function TaskList({
  tasks,
  onToggleComplete,
  onDeleteTask,
  onEditTask,
  isLoading,
}) {
  const [filter, setFilter] = useState('all'); // all | active | completed
  const [priorityFilter, setPriorityFilter] = useState('all');
  const [search, setSearch] = useState('');

  // Filter tasks
  const filteredTasks = tasks.filter((task) => {
    // Status filter
    if (filter === 'active' && task.completed) return false;
    if (filter === 'completed' && !task.completed) return false;

    // Priority filter
    if (priorityFilter !== 'all' && task.priority !== priorityFilter) return false;

    // Search filter
    if (search.trim()) {
      const q = search.toLowerCase();
      const matchTitle = (task.title || '').toLowerCase().includes(q);
      const matchDesc = (task.description || '').toLowerCase().includes(q);
      const matchCat = (task.category || '').toLowerCase().includes(q);
      if (!matchTitle && !matchDesc && !matchCat) return false;
    }

    return true;
  });

  return (
    <div className="task-list-section">
      <div className="list-toolbar">
        <div className="filter-tabs">
          <button
            className={`tab ${filter === 'all' ? 'active' : ''}`}
            onClick={() => setFilter('all')}
          >
            All ({tasks.length})
          </button>
          <button
            className={`tab ${filter === 'active' ? 'active' : ''}`}
            onClick={() => setFilter('active')}
          >
            Active ({tasks.filter((t) => !t.completed).length})
          </button>
          <button
            className={`tab ${filter === 'completed' ? 'active' : ''}`}
            onClick={() => setFilter('completed')}
          >
            Completed ({tasks.filter((t) => t.completed).length})
          </button>
        </div>

        <div className="filter-controls">
          <input
            type="text"
            className="search-input"
            placeholder="🔍 Search tasks..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />

          <select
            className="priority-select"
            value={priorityFilter}
            onChange={(e) => setPriorityFilter(e.target.value)}
          >
            <option value="all">All Priorities</option>
            <option value="high">🔴 High Only</option>
            <option value="medium">🟡 Medium Only</option>
            <option value="low">🟢 Low Only</option>
          </select>
        </div>
      </div>

      {isLoading ? (
        <div className="empty-state">
          <div className="spinner"></div>
          <p>Loading tasks from database...</p>
        </div>
      ) : filteredTasks.length === 0 ? (
        <div className="empty-state">
          <div className="empty-icon">📭</div>
          <h4>No tasks found</h4>
          <p>
            {tasks.length === 0
              ? 'No tasks created yet. Add one above to get started!'
              : 'Try adjusting your filters or search keywords.'}
          </p>
        </div>
      ) : (
        <ul className="task-items">
          {filteredTasks.map((task) => (
            <li
              key={task.id}
              className={`task-item ${task.completed ? 'task-completed' : ''}`}
            >
              <div className="task-checkbox-container">
                <input
                  type="checkbox"
                  id={`chk-${task.id}`}
                  checked={task.completed}
                  onChange={() => onToggleComplete(task)}
                />
              </div>

              <div className="task-content">
                <div className="task-header-line">
                  <span
                    className="task-title"
                    onClick={() => onToggleComplete(task)}
                  >
                    {task.title}
                  </span>
                  <div className="task-badges">
                    {task.category && (
                      <span className="badge badge-category">{task.category}</span>
                    )}
                    <span className={`badge badge-priority badge-${task.priority}`}>
                      {task.priority?.toUpperCase()}
                    </span>
                  </div>
                </div>

                {task.description && (
                  <p className="task-description">{task.description}</p>
                )}

                <div className="task-meta">
                  <span>
                    Created:{' '}
                    {task.created_at
                      ? new Date(task.created_at).toLocaleDateString(undefined, {
                          month: 'short',
                          day: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit',
                        })
                      : 'Just now'}
                  </span>
                </div>
              </div>

              <div className="task-actions">
                <button
                  className="btn-icon btn-edit"
                  onClick={() => onEditTask(task)}
                  title="Edit task"
                >
                  ✏️
                </button>
                <button
                  className="btn-icon btn-delete"
                  onClick={() => onDeleteTask(task.id)}
                  title="Delete task"
                >
                  🗑️
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

