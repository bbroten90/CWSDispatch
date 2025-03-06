// src/routes/rateRoutes.ts
import { Router } from 'express';
import { 
  getAllRates, 
  getRate, 
  createNewRate, 
  updateExistingRate, 
  deleteExistingRate,
  getApplicableRate,
  calculateCost
} from '../controllers/rateController';

const router = Router();

// Get all rates
router.get('/', getAllRates);

// Find applicable rate
router.get('/applicable', getApplicableRate);

// Calculate shipping cost
router.post('/calculate', calculateCost);

// Get single rate
router.get('/:id', getRate);

// Create new rate
router.post('/', createNewRate);

// Update rate
router.patch('/:id', updateExistingRate);

// Delete rate
router.delete('/:id', deleteExistingRate);

export default router;
