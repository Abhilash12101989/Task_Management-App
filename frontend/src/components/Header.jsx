import React from 'react';

export default function Header({ isOnline, backendInfo, onRefresh }) {
  return (
    <header className="app-header">
      <div className="header-brand">
        <div className="logo-icon">📋</div>
        <div>
          <h1>Task Management App</h1>
          <p className="subtitle">3-Tier Cloud Architecture on Azure (React • FastAPI • PostgreSQL)</p>
        </div>
      </div>

      <div className="header-status">
        <div
          className={`status-badge ${isOnline ? 'status-online' : 'status-offline'}`}
          title={isOnline ? 'FastAPI Backend & PostgreSQL Connected' : 'Running in Local Storage Demo Mode'}
        >
          <span className="status-dot"></span>
          <span>
            {isOnline ? (
              <>
                <strong>Live:</strong> {backendInfo?.database_connected ? 'FastAPI + PostgreSQL' : 'FastAPI Connected'}
              </>
            ) : (
              <>
                <strong>Demo Mode:</strong> Offline / Local
              </>
            )}
          </span>
        </div>
        <button className="btn-refresh" onClick={onRefresh} title="Refresh tasks and check connection">
          🔄
        </button>
      </div>
    </header>
  );
}

