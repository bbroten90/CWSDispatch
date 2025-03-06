// src/routes/shipmentRoutes.ts
import { Router } from 'express';
import { 
  getAllShipments, 
  getShipment, 
  createNewShipment, 
  updateExistingShipment, 
  deleteExistingShipment,
  getShipmentDetails,
  getDriverShipments,
  getWeekSchedule,
  updateShipmentStatus
} from '../controllers/shipmentController';

const router = Router();

// Get all shipments
router.get('/', getAllShipments);

// Get this week's shipment schedule
router.get('/week-schedule', getWeekSchedule);

// Get driver's active shipments
router.get('/driver/:driverId', getDriverShipments);

// Get shipment details with related information
router.get('/:id/details', getShipmentDetails);

// Update shipment status endpoint
router.patch('/:id/status', updateShipmentStatus);

// Get single shipment
router.get('/:id', getShipment);

// Create new shipment
router.post('/', createNewShipment);

// Update shipment
router.patch('/:id', updateExistingShipment);

// Delete shipment
router.delete('/:id', deleteExistingShipment);

export default router;
