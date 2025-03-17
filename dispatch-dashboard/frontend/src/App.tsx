// src/App.tsx
import React from 'react';
import './App.css';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import { Package, Truck, BarChart2, Settings } from 'lucide-react';
import Dashboard from './pages/Dashboard';
import Orders from './pages/Orders';
import LoadBuilder from './pages/LoadBuilder';
import Shipments from './pages/Shipments';

function App() {
  return (
    <Router>
      <div className="flex h-screen">
        {/* Sidebar */}
        <div className="bg-gray-900 text-white w-16 md:w-64 flex flex-col">
          <div className="p-4 text-xl font-bold hidden md:block">
            Dispatch Dashboard
          </div>
          <nav className="flex-1 mt-6">
            <Link to="/" className="flex items-center px-4 py-3 text-gray-300 hover:bg-gray-800">
              <BarChart2 className="h-5 w-5 mr-3" />
              {/* src/App.tsx (continued) */}
              <span className="hidden md:block">Dashboard</span>
            </Link>
            <Link to="/orders" className="flex items-center px-4 py-3 text-gray-300 hover:bg-gray-800">
              <Package className="h-5 w-5 mr-3" />
              <span className="hidden md:block">Orders</span>
            </Link>
            <Link to="/shipments" className="flex items-center px-4 py-3 text-gray-300 hover:bg-gray-800">
              <Truck className="h-5 w-5 mr-3" />
              <span className="hidden md:block">Shipments</span>
            </Link>
            <Link to="/load-builder" className="flex items-center px-4 py-3 text-gray-300 hover:bg-gray-800">
              <Settings className="h-5 w-5 mr-3" />
              <span className="hidden md:block">Load Builder</span>
            </Link>
          </nav>
        </div>
        
        {/* Main Content */}
        <div className="flex-1 overflow-auto bg-gray-50">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/orders" element={<Orders />} />
            <Route path="/shipments" element={<Shipments />} />
            <Route path="/load-builder" element={<LoadBuilder />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;
