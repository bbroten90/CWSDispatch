// src/routes/shipmentRoutes.js
const express = require('express');
const shipmentController = require('../controllers/shipmentController');

const router = express.Router();

// Get all shipments
router.get('/', shipmentController.getAllShipments);

// Get this week's shipment schedule
router.get('/week-schedule', shipmentController.getWeekSchedule);

// Get driver's active shipments
router.get('/driver/:driverId', shipmentController.getDriverShipments);

// Get shipment details with related information
router.get('/:id/details', shipmentController.getShipmentDetails);

// Update shipment status endpoint
router.patch('/:id/status', shipmentController.updateShipmentStatus);

// Get single shipment
router.get('/:id', shipmentController.getShipment);

// Create new shipment
router.post('/', shipmentController.createNewShipment);

// Update shipment
router.patch('/:id', shipmentController.updateExistingShipment);

// Delete shipment
router.delete('/:id', shipmentController.deleteExistingShipment);

module.exports = router;
