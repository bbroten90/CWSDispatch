// src/routes/products.js
const express = require('express');
const productsController = require('../controllers/productsController');

const router = express.Router();

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
