// src/routes/warehouses.js
const express = require('express');
const warehousesController = require('../controllers/warehousesController');
const { Pool } = require('pg');

const router = express.Router();

// Configure PostgreSQL connection
const pool = new Pool({
  // These would come from environment variables in production
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD ? String(process.env.DB_PASSWORD) : '',
  port: process.env.DB_PORT || 5432,
});

// Test database connection
pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

// Authentication middleware for internal requests
const checkInternalRequest = async (req, res, next) => {
  // Check for internal request header (used by frontend)
  const internalRequest = req.headers['x-internal-request'];
  
  if (internalRequest === 'true') {
    // For internal requests, bypass authentication
    return next();
  }
  
  // For external requests, require API key authentication
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      error: 'Authentication failed',
      details: 'Missing or invalid API key',
      timestamp: new Date().toISOString()
    });
  }
  
  const apiKey = authHeader.split(' ')[1];
  
  try {
    // Check if the API key is valid
    const result = await pool.query(
      'SELECT manufacturer_id FROM manufacturers WHERE api_key = $1 AND is_active = true',
      [apiKey]
    );
    
    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: 'Authentication failed',
        details: 'Invalid API key',
        timestamp: new Date().toISOString()
      });
    }
    
    next();
  } catch (err) {
    console.error('Authentication error:', err);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      details: 'Error during authentication',
      timestamp: new Date().toISOString()
    });
  }
};

// Apply authentication middleware to all routes
router.use(checkInternalRequest);

// GET /api/warehouses - Get all warehouses
router.get('/', warehousesController.getWarehouses);

// GET /api/warehouses/:warehouseId - Get warehouse by ID
router.get('/:warehouseId', warehousesController.getWarehouseById);

// POST /api/warehouses - Create a new warehouse
router.post('/', warehousesController.createWarehouse);

// PUT /api/warehouses/:warehouseId - Update a warehouse
router.put('/:warehouseId', warehousesController.updateWarehouse);

// DELETE /api/warehouses/:warehouseId - Delete a warehouse
router.delete('/:warehouseId', warehousesController.deleteWarehouse);

module.exports = router;
