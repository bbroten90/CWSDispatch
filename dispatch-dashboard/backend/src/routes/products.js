// src/routes/products.js
const express = require('express');
const productsController = require('../controllers/productsController');
const { Pool } = require('pg');

const router = express.Router();

// Configure PostgreSQL connection
const pool = new Pool({
  // These would come from environment variables in production
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432,
});

// Authentication middleware for internal requests
const checkInternalRequest = async (req, res, next) => {
  // Check for internal request header (used by frontend)
  const internalRequest = req.headers['x-internal-request'] === 'true';
  
  if (internalRequest) {
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

// GET /api/products - Get all products
router.get('/', productsController.getProducts);

// GET /api/products/hazardous - Get hazardous products
router.get('/hazardous', productsController.getHazardousProducts);

// GET /api/products/:productId - Get product by ID
router.get('/:productId', productsController.getProductById);

// POST /api/products - Create a new product
router.post('/', productsController.createProduct);

// PUT /api/products/:productId - Update a product
router.put('/:productId', productsController.updateProduct);

// DELETE /api/products/:productId - Delete a product
router.delete('/:productId', productsController.deleteProduct);

module.exports = router;
