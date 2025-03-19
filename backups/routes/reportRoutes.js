// src/routes/reportRoutes.js
const express = require('express');
const reportModel = require('../models/reportModel');

const router = express.Router();

// Get delivery performance report
router.get('/delivery-performance', async (req, res) => {
  try {
    const { startDate, endDate, customerId } = req.query;
    
    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Start date and end date are required' });
    }
    
    const result = await reportModel.getDeliveryPerformance(
      new Date(startDate),
      new Date(endDate),
      customerId
    );
    
    res.status(200).json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get vehicle utilization report
router.get('/vehicle-utilization', async (req, res) => {
  try {
    const { startDate, endDate, vehicleId } = req.query;
    
    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Start date and end date are required' });
    }
    
    const result = await reportModel.getVehicleUtilization(
      new Date(startDate),
      new Date(endDate),
      vehicleId
    );
    
    res.status(200).json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get driver performance report
router.get('/driver-performance', async (req, res) => {
  try {
    const { startDate, endDate, driverId } = req.query;
    
    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Start date and end date are required' });
    }
    
    const result = await reportModel.getDriverPerformance(
      new Date(startDate),
      new Date(endDate),
      driverId
    );
    
    res.status(200).json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get revenue by region report
router.get('/revenue-by-region', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Start date and end date are required' });
    }
    
    const result = await reportModel.getRevenueByRegion(
      new Date(startDate),
      new Date(endDate)
    );
    
    res.status(200).json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get monthly trends report
router.get('/monthly-trends', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Start date and end date are required' });
    }
    
    const result = await reportModel.getMonthlyTrends(
      new Date(startDate),
      new Date(endDate)
    );
    
    res.status(200).json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
