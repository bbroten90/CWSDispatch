// src/routes/index.ts
import express from 'express';
import reportRouter from './reportRoutes';

// Import JavaScript modules using require
// @ts-ignore - Ignore missing type declarations for JavaScript modules
const ordersRouter = require('./order-api');
// @ts-ignore - Ignore missing type declarations for JavaScript modules
const shipmentsRouter = require('./shipmentRoutes.js');
// @ts-ignore - Ignore missing type declarations for JavaScript modules
const vehiclesRouter = require('./vehicleRoutes.js');
// @ts-ignore - Ignore missing type declarations for JavaScript modules
const driversRouter = require('./driverRoutes.js');
// @ts-ignore - Ignore missing type declarations for JavaScript modules
const ratesRouter = require('./rateRoutes.js');
// @ts-ignore - Ignore missing type declarations for JavaScript modules
const optimizeRouter = require('./optimizeRoutes.js');
// @ts-ignore - Ignore missing type declarations for JavaScript modules
const customersRouter = require('./customers.js');
// @ts-ignore - Ignore missing type declarations for JavaScript modules
const productsRouter = require('./products.js');
// @ts-ignore - Ignore missing type declarations for JavaScript modules
const hazardsRouter = require('./hazards.js');

const router = express.Router();

// Health check endpoint
router.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Main API routes
router.use('/orders', ordersRouter);
router.use('/shipments', shipmentsRouter);
router.use('/vehicles', vehiclesRouter);
router.use('/drivers', driversRouter);
router.use('/rates', ratesRouter);
router.use('/optimize', optimizeRouter);
router.use('/customers', customersRouter);
router.use('/products', productsRouter);
router.use('/hazards', hazardsRouter);
router.use('/reports', reportRouter);

export default router;
