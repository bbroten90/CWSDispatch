// src/routes/hazards.js
const express = require('express');
const hazardsController = require('../controllers/hazardsController');

const router = express.Router();

// GET /api/hazards - Get all hazards
router.get('/', hazardsController.getHazards);

// GET /api/hazards/:hazardPk - Get hazard by ID
router.get('/:hazardPk', hazardsController.getHazardById);

// GET /api/hazards/:hazardPk/products - Get products by hazard
router.get('/:hazardPk/products', hazardsController.getProductsByHazard);

// POST /api/hazards - Create a new hazard
router.post('/', hazardsController.createHazard);

// PUT /api/hazards/:hazardPk - Update a hazard
router.put('/:hazardPk', hazardsController.updateHazard);

// DELETE /api/hazards/:hazardPk - Delete a hazard
router.delete('/:hazardPk', hazardsController.deleteHazard);

module.exports = router;
