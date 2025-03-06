// src/routes/index.js
const express = require('express');
const ordersRouter = require('./orders');
const shipmentsRouter = require('./shipments');
const vehiclesRouter = require('./vehicles');
const driversRouter = require('./drivers');
const warehousesRouter = require('./warehouses');
const ratesRouter = require('./rates');
const optimizeRouter = require('../controllers/Optimize');

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
router.use('/warehouses', warehousesRouter);
router.use('/rates', ratesRouter);
router.use('/optimize', optimizeRouter);

module.exports = router;

// src/routes/orders.js
const express = require('express');
const { authenticateApiKey } = require('../middleware/auth');
const ordersController = require('../controllers/orders');

const router = express.Router();

// Public routes (for internal dashboard use)
router.get('/', ordersController.getOrders);
router.get('/:orderId', ordersController.getOrderById);
router.post('/internal', ordersController.createInternalOrder);
router.put('/:orderId', ordersController.updateOrder);
router.delete('/:orderId', ordersController.deleteOrder);

// External API routes (require API key)
router.post('/', authenticateApiKey, ordersController.submitExternalOrder);
router.get('/external/status/:documentId', authenticateApiKey, ordersController.getOrderStatus);

module.exports = router;

// src/routes/shipments.js
const express = require('express');
const shipmentsController = require('../controllers/shipments');

const router = express.Router();

router.get('/', shipmentsController.getShipments);
router.get('/:shipmentId', shipmentsController.getShipmentById);
router.post('/', shipmentsController.createShipment);
router.put('/:shipmentId', shipmentsController.updateShipment);
router.delete('/:shipmentId', shipmentsController.deleteShipment);

// Additional route for shipment orders
router.get('/:shipmentId/orders', shipmentsController.getShipmentOrders);
router.post('/:shipmentId/orders', shipmentsController.addOrderToShipment);
router.delete('/:shipmentId/orders/:orderId', shipmentsController.removeOrderFromShipment);

// Status update routes
router.put('/:shipmentId/status', shipmentsController.updateShipmentStatus);

module.exports = router;

// src/routes/vehicles.js
const express = require('express');
const vehiclesController = require('../controllers/vehicles');

const router = express.Router();

router.get('/', vehiclesController.getVehicles);
router.get('/available', vehiclesController.getAvailableVehicles);
router.get('/:vehicleId', vehiclesController.getVehicleById);
router.post('/', vehiclesController.createVehicle);
router.put('/:vehicleId', vehiclesController.updateVehicle);
router.delete('/:vehicleId', vehiclesController.deleteVehicle);

// Vehicle availability routes
router.get('/:vehicleId/availability', vehiclesController.getVehicleAvailability);
router.post('/:vehicleId/availability', vehiclesController.setVehicleAvailability);

// Samsara integration routes
router.get('/samsara/locations', vehiclesController.getSamsaraLocations);
router.post('/samsara/webhook', vehiclesController.handleSamsaraWebhook);

module.exports = router;

// src/routes/drivers.js
const express = require('express');
const driversController = require('../controllers/drivers');

const router = express.Router();

router.get('/', driversController.getDrivers);
router.get('/available', driversController.getAvailableDrivers);
router.get('/:driverId', driversController.getDriverById);
router.post('/', driversController.createDriver);
router.put('/:driverId', driversController.updateDriver);
router.delete('/:driverId', driversController.deleteDriver);

// Driver availability routes
router.get('/:driverId/availability', driversController.getDriverAvailability);
router.post('/:driverId/availability', driversController.setDriverAvailability);

module.exports = router;

// src/routes/warehouses.js
const express = require('express');
const warehousesController = require('../controllers/warehouses');

const router = express.Router();

router.get('/', warehousesController.getWarehouses);
router.get('/:warehouseId', warehousesController.getWarehouseById);
router.post('/', warehousesController.createWarehouse);
router.put('/:warehouseId', warehousesController.updateWarehouse);
router.delete('/:warehouseId', warehousesController.deleteWarehouse);

module.exports = router;

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

// Calculate rate for a specific shipment
router.post('/calculate', ratesController.calculateRate);

module.exports = router;

// src/routes/optimize.js
const express = require('express');
const optimizeController = require('../controllers/optimize');

const router = express.Router();

// Run optimization for a specific date
router.post('/', optimizeController.runOptimization);

// Get optimization results
router.get('/results', optimizeController.getOptimizationResults);
router.get('/logs', optimizeController.getOptimizationLogs);

module.exports = router;
