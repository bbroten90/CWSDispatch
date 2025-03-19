// src/routes/rateRoutes.js
const express = require('express');
const rateController = require('../controllers/rates');

const router = express.Router();

// Get all rates
router.get('/', rateController.getRates);

// Get rate by ID
router.get('/:id', rateController.getRateById);

// Create new rate
router.post('/', rateController.createRate);

// Update rate
router.put('/:id', rateController.updateRate);

// Delete rate
router.delete('/:id', rateController.deleteRate);

// Calculate rate for a shipment
router.post('/calculate', rateController.calculateRate);

module.exports = router;
