// src/routes/driverRoutes.ts
import { Router } from 'express';
import { 
  getAllDrivers, 
  getDriver, 
  createNewDriver, 
  updateExistingDriver, 
  deleteExistingDriver,
  getDriverDetails,
  getDriverLicenseExpirations,
  getDriverHistory,
  getDriverMetrics
} from '../controllers/driverController';

const router = Router();

// Get all drivers
router.get('/', getAllDrivers);

// Get drivers with expiring licenses
router.get('/expiring-licenses', getDriverLicenseExpirations);

// Get driver details with current assignment
router.get('/:id/details', getDriverDetails);

// Get driver shipment history
router.get('/:id/history', getDriverHistory);

// Get driver performance metrics
router.get('/:id/metrics', getDriverMetrics);

// Get single driver
router.get('/:id', getDriver);

// Create new driver
router.post('/', createNewDriver);

// Update driver
router.patch('/:id', updateExistingDriver);

// Delete driver
router.delete('/:id', deleteExistingDriver);

export default router;
