// src/routes/vehicleRoutes.js
const express = require('express');
const vehicleController = require('../controllers/vehicleControllers');

const router = express.Router();

// Get all vehicles
router.get('/', vehicleController.getAllVehicles);

// Get vehicle statistics
router.get('/stats', vehicleController.getVehicleStats);

// Get vehicles due for maintenance
router.get('/maintenance-due', vehicleController.getMaintenanceDue);

// Get vehicle details with assignment information
router.get('/:id/details', vehicleController.getVehicleDetails);

// Get single vehicle
router.get('/:id', vehicleController.getVehicle);

// Create new vehicle
router.post('/', vehicleController.createNewVehicle);

// Update vehicle
router.patch('/:id', vehicleController.updateExistingVehicle);

// Delete vehicle
router.delete('/:id', vehicleController.deleteExistingVehicle);

module.exports = router;
