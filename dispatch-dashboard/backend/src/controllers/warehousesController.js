// src/controllers/warehousesController.js
const db = require('../config/backend-database-connection');

/**
 * Get all warehouses
 * @route GET /api/warehouses
 */
exports.getWarehouses = async (req, res) => {
  try {
    console.log('GET /api/warehouses - Fetching all warehouses');
    const result = await db.query('SELECT * FROM warehouses ORDER BY name');
    console.log('Warehouses fetched:', result.rows);
    res.json({ success: true, data: result.rows });
  } catch (error) {
    console.error('Error fetching warehouses:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Get warehouse by ID
 * @route GET /api/warehouses/:warehouseId
 */
exports.getWarehouseById = async (req, res) => {
  try {
    const { warehouseId } = req.params;
    const result = await db.query('SELECT * FROM warehouses WHERE warehouse_id = $1', [warehouseId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Warehouse not found' });
    }
    
    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error fetching warehouse:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Create a new warehouse
 * @route POST /api/warehouses
 */
exports.createWarehouse = async (req, res) => {
  try {
    const {
      name,
      address,
      city,
      province,
      postal_code,
      latitude,
      longitude,
      loading_capacity,
      storage_capacity,
      is_active
    } = req.body;
    
    // Validate required fields
    if (!name || !city || !province) {
      return res.status(400).json({
        success: false,
        error: 'name, city, and province are required'
      });
    }
    
    const result = await db.query(
      `INSERT INTO warehouses 
       (name, address, city, province, postal_code, latitude, longitude, loading_capacity, storage_capacity, is_active) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) 
       RETURNING *`,
      [name, address, city, province, postal_code, latitude, longitude, loading_capacity, storage_capacity, is_active ?? true]
    );
    
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error creating warehouse:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Update a warehouse
 * @route PUT /api/warehouses/:warehouseId
 */
exports.updateWarehouse = async (req, res) => {
  try {
    const { warehouseId } = req.params;
    const {
      name,
      address,
      city,
      province,
      postal_code,
      latitude,
      longitude,
      loading_capacity,
      storage_capacity,
      is_active
    } = req.body;
    
    // Validate required fields
    if (!name || !city || !province) {
      return res.status(400).json({
        success: false,
        error: 'name, city, and province are required'
      });
    }
    
    const result = await db.query(
      `UPDATE warehouses 
       SET name = $1, 
           address = $2, 
           city = $3, 
           province = $4, 
           postal_code = $5, 
           latitude = $6, 
           longitude = $7, 
           loading_capacity = $8, 
           storage_capacity = $9, 
           is_active = $10,
           updated_at = CURRENT_TIMESTAMP
       WHERE warehouse_id = $11
       RETURNING *`,
      [name, address, city, province, postal_code, latitude, longitude, loading_capacity, storage_capacity, is_active, warehouseId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Warehouse not found' });
    }
    
    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error updating warehouse:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Delete a warehouse
 * @route DELETE /api/warehouses/:warehouseId
 */
exports.deleteWarehouse = async (req, res) => {
  try {
    const { warehouseId } = req.params;
    
    // Check if warehouse exists
    const checkResult = await db.query('SELECT warehouse_id FROM warehouses WHERE warehouse_id = $1', [warehouseId]);
    
    if (checkResult.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Warehouse not found' });
    }
    
    // Check if warehouse is referenced by any vehicles
    const vehicleResult = await db.query('SELECT vehicle_id FROM vehicles WHERE home_warehouse_id = $1 LIMIT 1', [warehouseId]);
    
    if (vehicleResult.rows.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'Cannot delete warehouse because it is referenced by one or more vehicles'
      });
    }
    
    // Check if warehouse is referenced by any drivers
    const driverResult = await db.query('SELECT driver_id FROM drivers WHERE home_warehouse_id = $1 LIMIT 1', [warehouseId]);
    
    if (driverResult.rows.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'Cannot delete warehouse because it is referenced by one or more drivers'
      });
    }
    
    // Check if warehouse is referenced by any shipments
    const shipmentResult = await db.query('SELECT shipment_id FROM shipments WHERE origin_warehouse_id = $1 LIMIT 1', [warehouseId]);
    
    if (shipmentResult.rows.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'Cannot delete warehouse because it is referenced by one or more shipments'
      });
    }
    
    // Delete warehouse
    await db.query('DELETE FROM warehouses WHERE warehouse_id = $1', [warehouseId]);
    
    res.json({ success: true, message: 'Warehouse deleted successfully' });
  } catch (error) {
    console.error('Error deleting warehouse:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};
