// src/routes/driverRoutes.js
const express = require('express');
const driverController = require('../controllers/driverController');

const router = express.Router();

// Get all drivers
router.get('/', driverController.getAllDrivers);

// Get drivers with expiring licenses
router.get('/expiring-licenses', driverController.getDriverLicenseExpirations);

// Get driver details with current assignment
router.get('/:id/details', driverController.getDriverDetails);

// Get driver shipment history
router.get('/:id/history', driverController.getDriverHistory);

// Get driver performance metrics
router.get('/:id/metrics', driverController.getDriverMetrics);

// Get single driver
router.get('/:id', driverController.getDriver);

// Create new driver
router.post('/', driverController.createNewDriver);

// Update driver
router.patch('/:id', driverController.updateExistingDriver);

// Delete driver
router.delete('/:id', driverController.deleteExistingDriver);

module.exports = router;
