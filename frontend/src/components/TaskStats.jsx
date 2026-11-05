import React from 'react';

export default function TaskStats({ tasks }) {
  const total = tasks.length;
  const completed = tasks.filter((t) => t.completed).length;
  const pending = total - completed;
  const highPriority = tasks.filter((t) => !t.completed && t.priority === 'high').length;
  const progressPercent = total === 0 ? 0 : Math.round((completed / total) * 100);

  return (
    <div className="stats-grid">
      <div className="stat-card">
        <div className="stat-value">{total}</div>
        <div className="stat-label">Total Tasks</div>
      </div>
      <div className="stat-card stat-pending">
        <div className="stat-value">{pending}</div>
        <div className="stat-label">In Progress</div>
      </div>
      <div className="stat-card stat-completed">
        <div className="stat-value">{completed}</div>
        <div className="stat-label">Completed ({progressPercent}%)</div>
      </div>
      <div className="stat-card stat-high">
        <div className="stat-value">{highPriority}</div>
        <div className="stat-label">High Priority</div>
      </div>
    </div>
  );
}

