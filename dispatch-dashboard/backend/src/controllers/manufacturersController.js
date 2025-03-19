// src/controllers/manufacturersController.js
const db = require('../config/backend-database-connection');

/**
 * Get all manufacturers
 * @route GET /api/manufacturers
 */
exports.getManufacturers = async (req, res) => {
  try {
    console.log('GET /api/manufacturers - Fetching all manufacturers');
    const result = await db.query('SELECT * FROM manufacturers ORDER BY name');
    console.log('Manufacturers fetched:', result.rows);
    res.json({ success: true, data: result.rows });
  } catch (error) {
    console.error('Error fetching manufacturers:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Get manufacturer by ID
 * @route GET /api/manufacturers/:manufacturerId
 */
exports.getManufacturerById = async (req, res) => {
  try {
    const { manufacturerId } = req.params;
    const result = await db.query('SELECT * FROM manufacturers WHERE manufacturer_id = $1', [manufacturerId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Manufacturer not found' });
    }
    
    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error fetching manufacturer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Create a new manufacturer
 * @route POST /api/manufacturers
 */
exports.createManufacturer = async (req, res) => {
  try {
    const {
      name,
      api_key,
      contact_name,
      contact_email,
      contact_phone,
      webhook_url,
      is_active
    } = req.body;
    
    // Validate required fields
    if (!name) {
      return res.status(400).json({
        success: false,
        error: 'name is required'
      });
    }
    
    const result = await db.query(
      `INSERT INTO manufacturers 
       (name, api_key, contact_name, contact_email, contact_phone, webhook_url, is_active) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) 
       RETURNING *`,
      [name, api_key, contact_name, contact_email, contact_phone, webhook_url, is_active ?? true]
    );
    
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error creating manufacturer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Update a manufacturer
 * @route PUT /api/manufacturers/:manufacturerId
 */
exports.updateManufacturer = async (req, res) => {
  try {
    const { manufacturerId } = req.params;
    const {
      name,
      api_key,
      contact_name,
      contact_email,
      contact_phone,
      webhook_url,
      is_active
    } = req.body;
    
    // Validate required fields
    if (!name) {
      return res.status(400).json({
        success: false,
        error: 'name is required'
      });
    }
    
    const result = await db.query(
      `UPDATE manufacturers 
       SET name = $1, 
           api_key = $2, 
           contact_name = $3, 
           contact_email = $4, 
           contact_phone = $5, 
           webhook_url = $6, 
           is_active = $7,
           updated_at = CURRENT_TIMESTAMP
       WHERE manufacturer_id = $8
       RETURNING *`,
      [name, api_key, contact_name, contact_email, contact_phone, webhook_url, is_active, manufacturerId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Manufacturer not found' });
    }
    
    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error updating manufacturer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Delete a manufacturer
 * @route DELETE /api/manufacturers/:manufacturerId
 */
exports.deleteManufacturer = async (req, res) => {
  try {
    const { manufacturerId } = req.params;
    
    // Check if manufacturer exists
    const checkResult = await db.query('SELECT manufacturer_id FROM manufacturers WHERE manufacturer_id = $1', [manufacturerId]);
    
    if (checkResult.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Manufacturer not found' });
    }
    
    // Check if manufacturer is referenced by any products
    const productResult = await db.query('SELECT product_id FROM products WHERE manufacturer_id = $1 LIMIT 1', [manufacturerId]);
    
    if (productResult.rows.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'Cannot delete manufacturer because it is referenced by one or more products'
      });
    }
    
    // Delete manufacturer
    await db.query('DELETE FROM manufacturers WHERE manufacturer_id = $1', [manufacturerId]);
    
    res.json({ success: true, message: 'Manufacturer deleted successfully' });
  } catch (error) {
    console.error('Error deleting manufacturer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};
