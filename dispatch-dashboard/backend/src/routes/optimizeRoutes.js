// src/routes/optimizeRoutes.js
const express = require('express');
const optimizeController = require('../controllers/Optimize');

const router = express.Router();

// Run optimization
router.post('/run', optimizeController.runOptimization);

// Get optimization results
router.get('/results', optimizeController.getOptimizationResults);

// Get optimization logs
router.get('/logs', optimizeController.getOptimizationLogs);

module.exports = router;
