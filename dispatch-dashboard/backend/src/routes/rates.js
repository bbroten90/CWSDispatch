// src/routes/rates.js
const express = require('express');
const ratesController = require('../controllers/rates');

const router = express.Router();

router.get('/', ratesController.getRates);
router.get('/:rateId', ratesController.getRateById);
router.post('/', ratesController.createRate);
router.put('/:rateId', ratesController.updateRate);
router.delete('/:rateId', ratesController.deleteRate);

// Bulk operations
router.post('/import', ratesController.importRates);
router.get('/export', ratesController.exportRates);

// Get customers for rate selection
router.get('/customers', ratesController.getCustomers);

// Calculate rate for a specific shipment
router.post('/calculate', ratesController.calculateRate);

module.exports = router;
