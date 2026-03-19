import React from 'react';
import { BrowserRouter as Router, Route, Routes, Link } from 'react-router-dom';
import Dashboard from './components/Dashboard';
import Employees from './components/Employees';
import AccessLogs from './components/AccessLogs';
import Alerts from './components/Alerts';
import './App.css';

function App() {
  return (
    <Router>
      <div className="App">
        <header>
          <h1>Enterprise Data Breach Prevention System</h1>
          <nav>
            <Link to="/">Dashboard</Link>
            <Link to="/employees">Employees</Link>
            <Link to="/access-logs">Access Logs</Link>
            <Link to="/alerts">Alerts</Link>
          </nav>
        </header>
        <main>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/employees" element={<Employees />} />
            <Route path="/access-logs" element={<AccessLogs />} />
            <Route path="/alerts" element={<Alerts />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;
