// src/routes/customers.js
const express = require('express');
const customersController = require('../controllers/customersController');

const router = express.Router();

// GET /api/customers - Get all customers
router.get('/', customersController.getCustomers);

// GET /api/customers/:customerId - Get customer by ID
router.get('/:customerId', customersController.getCustomerById);

// POST /api/customers - Create a new customer
router.post('/', customersController.createCustomer);

// PUT /api/customers/:customerId - Update a customer
router.put('/:customerId', customersController.updateCustomer);

// DELETE /api/customers/:customerId - Delete a customer
router.delete('/:customerId', customersController.deleteCustomer);

module.exports = router;
