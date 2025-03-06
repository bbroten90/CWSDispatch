// src/routes/rateRoutes.ts
import { Router } from 'express';
import { 
  getRates, 
  getRateById, 
  createRate, 
  updateRate, 
  deleteRate,
  calculateRate,
  importRates,
  exportRates,
  getCustomers
} from '../controllers/rates';

const router = Router();

// Get all rates
router.get('/', getRates);

// Get customers for rate selection
router.get('/customers', getCustomers);

// Calculate shipping rate
router.post('/calculate', calculateRate);

// Import/export rates
router.post('/import', importRates);
router.get('/export', exportRates);

// Get single rate
router.get('/:rateId', getRateById);

// Create new rate
router.post('/', createRate);

// Update rate
router.put('/:rateId', updateRate);

// Delete rate
router.delete('/:rateId', deleteRate);

export default router;
