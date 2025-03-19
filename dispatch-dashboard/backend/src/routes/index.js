// src/routes/index.js
const express = require('express');
const ordersRouter = require('./order-api');
const shipmentsRouter = require('./shipmentRoutes.js');
const vehiclesRouter = require('./vehicleRoutes.js');
const driversRouter = require('./driverRoutes.js');
const ratesRouter = require('./rateRoutes.js');
const optimizeRouter = require('./optimizeRoutes.js');
const customersRouter = require('./customers.js');
const productsRouter = require('./products.js');
const hazardsRouter = require('./hazards.js');
const warehousesRouter = require('./warehouses.js');
const manufacturersRouter = require('./manufacturers.js');
const reportRouter = require('./reportRoutes.js');

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
router.use('/warehouses', warehousesRouter);
router.use('/manufacturers', manufacturersRouter);
router.use('/reports', reportRouter);

module.exports = router;
