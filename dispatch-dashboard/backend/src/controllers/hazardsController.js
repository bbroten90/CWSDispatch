// src/controllers/hazardsController.js
const db = require('../config/backend-database-connection');

/**
 * Get all hazards
 * @route GET /api/hazards
 */
exports.getHazards = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM hazards ORDER BY hazard_pk');
    res.json({ success: true, data: result.rows });
  } catch (error) {
    console.error('Error fetching hazards:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Get hazard by ID
 * @route GET /api/hazards/:hazardPk
 */
exports.getHazardById = async (req, res) => {
  try {
    const { hazardPk } = req.params;
    const result = await db.query('SELECT * FROM hazards WHERE hazard_pk = $1', [hazardPk]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Hazard not found' });
    }
    
    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error fetching hazard:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Get products by hazard
 * @route GET /api/hazards/:hazardPk/products
 */
exports.getProductsByHazard = async (req, res) => {
  try {
    const { hazardPk } = req.params;
    
    // First check if hazard exists
    const hazardResult = await db.query('SELECT * FROM hazards WHERE hazard_pk = $1', [hazardPk]);
    
    if (hazardResult.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Hazard not found' });
    }
    
    // Get products with this hazard
    const productsResult = await db.query(
      'SELECT * FROM products WHERE hazard_pk = $1 ORDER BY product_id',
      [hazardPk]
    );
    
    res.json({ 
      success: true, 
      data: {
        hazard: hazardResult.rows[0],
        products: productsResult.rows
      }
    });
  } catch (error) {
    console.error('Error fetching products by hazard:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Create a new hazard
 * @route POST /api/hazards
 */
exports.createHazard = async (req, res) => {
  try {
    const { hazard_pk, hazard_code, description1, description2, description3 } = req.body;
    
    // Validate required fields
    if (!hazard_pk || !hazard_code) {
      return res.status(400).json({
        success: false,
        error: 'hazard_pk and hazard_code are required'
      });
    }
    
    // Check if hazard_pk already exists
    const checkResult = await db.query('SELECT hazard_pk FROM hazards WHERE hazard_pk = $1', [hazard_pk]);
    
    if (checkResult.rows.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'A hazard with this hazard_pk already exists'
      });
    }
    
    const result = await db.query(
      `INSERT INTO hazards 
       (hazard_pk, hazard_code, description1, description2, description3) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING *`,
      [hazard_pk, hazard_code, description1, description2, description3]
    );
    
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error creating hazard:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Update a hazard
 * @route PUT /api/hazards/:hazardPk
 */
exports.updateHazard = async (req, res) => {
  try {
    const { hazardPk } = req.params;
    const { hazard_code, description1, description2, description3 } = req.body;
    
    // Validate required fields
    if (!hazard_code) {
      return res.status(400).json({
        success: false,
        error: 'hazard_code is required'
      });
    }
    
    // Check if hazard exists
    const checkResult = await db.query('SELECT hazard_pk FROM hazards WHERE hazard_pk = $1', [hazardPk]);
    
    if (checkResult.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Hazard not found' });
    }
    
    const result = await db.query(
      `UPDATE hazards 
       SET hazard_code = $1, 
           description1 = $2, 
           description2 = $3, 
           description3 = $4,
           updated_at = CURRENT_TIMESTAMP
       WHERE hazard_pk = $5
       RETURNING *`,
      [hazard_code, description1, description2, description3, hazardPk]
    );
    
    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error updating hazard:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Delete a hazard
 * @route DELETE /api/hazards/:hazardPk
 */
exports.deleteHazard = async (req, res) => {
  try {
    const { hazardPk } = req.params;
    
    // Check if hazard exists
    const checkResult = await db.query('SELECT hazard_pk FROM hazards WHERE hazard_pk = $1', [hazardPk]);
    
    if (checkResult.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Hazard not found' });
    }
    
    // Check if hazard is referenced by any products
    const productResult = await db.query(
      'SELECT product_id FROM products WHERE hazard_pk = $1 LIMIT 1',
      [hazardPk]
    );
    
    if (productResult.rows.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'Cannot delete hazard because it is referenced by one or more products'
      });
    }
    
    // Delete hazard
    await db.query('DELETE FROM hazards WHERE hazard_pk = $1', [hazardPk]);
    
    res.json({ success: true, message: 'Hazard deleted successfully' });
  } catch (error) {
    console.error('Error deleting hazard:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};
