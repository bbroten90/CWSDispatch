// src/controllers/productsController.js
const db = require('../config/backend-database-connection');

/**
 * Get all products
 * @route GET /api/products
 */
exports.getProducts = async (req, res) => {
  try {
    // Get query parameters for filtering
    const { hazardous, search } = req.query;
    
    let query = `
      SELECT p.*, h.hazard_code, h.description1 as hazard_description1, 
             h.description2 as hazard_description2, h.description3 as hazard_description3
      FROM products p
      LEFT JOIN hazards h ON p.tdg_number = h.hazard_code
    `;
    
    const queryParams = [];
    const conditions = [];
    
    // Add search condition if provided
    if (search) {
      const paramIndex = queryParams.length + 1;
      queryParams.push(`%${search}%`);
      queryParams.push(`%${search}%`);
      conditions.push(`(LOWER(p.product_id) LIKE LOWER($${paramIndex}) OR LOWER(p.description) LIKE LOWER($${paramIndex + 1}))`);
    }
    
    // Add hazardous filter if provided
    if (hazardous === 'true') {
      conditions.push('p.is_dangerous_good = true');
    } else if (hazardous === 'false') {
      conditions.push('p.is_dangerous_good = false');
    }
    
    // Add conditions to query
    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    
    // Add order by
    query += ' ORDER BY p.product_id';
    
    const result = await db.query(query, queryParams);
    
    // Convert weight_kg to weight_lbs for frontend and include warehouse information
    const productsWithLbs = await Promise.all(result.rows.map(async product => {
      // Get warehouse name if warehouse_id is present
      let warehouseName = null;
      if (product.warehouse_id) {
        const warehouseResult = await db.query('SELECT name FROM warehouses WHERE warehouse_id = $1', [product.warehouse_id]);
        if (warehouseResult.rows.length > 0) {
          warehouseName = warehouseResult.rows[0].name;
        }
      }
      
      return {
        ...product,
        weight_lbs: product.weight_kg * 2.20462, // Convert kg to lbs
        warehouse_name: warehouseName
      };
    }));
    
    res.json({ success: true, data: productsWithLbs });
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Get product by ID
 * @route GET /api/products/:productId
 */
exports.getProductById = async (req, res) => {
  try {
    const { productId } = req.params;
    
    const result = await db.query(`
      SELECT p.*, h.hazard_code, h.description1 as hazard_description1, 
             h.description2 as hazard_description2, h.description3 as hazard_description3
      FROM products p
      LEFT JOIN hazards h ON p.tdg_number = h.hazard_code
      WHERE p.product_id = $1
    `, [productId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Product not found' });
    }
    
    // Convert weight_kg to weight_lbs for frontend and include warehouse information
    const product = result.rows[0];
    
    // Get warehouse name if warehouse_id is present
    let warehouseName = null;
    if (product.warehouse_id) {
      const warehouseResult = await db.query('SELECT name FROM warehouses WHERE warehouse_id = $1', [product.warehouse_id]);
      if (warehouseResult.rows.length > 0) {
        warehouseName = warehouseResult.rows[0].name;
      }
    }
    
    const productWithLbs = {
      ...product,
      weight_lbs: product.weight_kg * 2.20462, // Convert kg to lbs
      warehouse_name: warehouseName
    };
    
    res.json({ success: true, data: productWithLbs });
  } catch (error) {
    console.error('Error fetching product:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Get hazardous products
 * @route GET /api/products/hazardous
 */
exports.getHazardousProducts = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT p.*, h.hazard_code, h.description1 as hazard_description1, 
             h.description2 as hazard_description2, h.description3 as hazard_description3
      FROM products p
      JOIN hazards h ON p.tdg_number = h.hazard_code
      WHERE p.is_dangerous_good = true
      ORDER BY p.product_id
    `);
    
    // Convert weight_kg to weight_lbs for frontend and include warehouse information
    const productsWithLbs = await Promise.all(result.rows.map(async product => {
      // Get warehouse name if warehouse_id is present
      let warehouseName = null;
      if (product.warehouse_id) {
        const warehouseResult = await db.query('SELECT name FROM warehouses WHERE warehouse_id = $1', [product.warehouse_id]);
        if (warehouseResult.rows.length > 0) {
          warehouseName = warehouseResult.rows[0].name;
        }
      }
      
      return {
        ...product,
        weight_lbs: product.weight_kg * 2.20462, // Convert kg to lbs
        warehouse_name: warehouseName
      };
    }));
    
    res.json({ success: true, data: productsWithLbs });
  } catch (error) {
    console.error('Error fetching hazardous products:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Create a new product
 * @route POST /api/products
 */
exports.createProduct = async (req, res) => {
  try {
    const {
      product_id,
      name,
      description,
      weight_kg,
      volume_cubic_m,
      requires_refrigeration,
      requires_heating,
      is_dangerous_good,
      tdg_number,
      hazard_pk,
      warehouse_id,
      customer_code,
      quantity_on_hand,
      location,
      do_not_ship,
      storage_charge_per_pallet,
      handling_charge_per_pallet,
      unit,
      units_per_pallet,
      pallet_stack_height,
      track_by_lot,
      str_group
    } = req.body;
    
    // Validate required fields
    if (!product_id || !name) {
      return res.status(400).json({
        success: false,
        error: 'product_id and name are required'
      });
    }
    
    // Start building the query
    let query = `
      INSERT INTO products (
        product_id, name, description, weight_kg, volume_cubic_m, 
        requires_refrigeration, requires_heating, is_dangerous_good, tdg_number,
        warehouse_id, customer_code, quantity_on_hand
    `;
    
    // Add optional fields if they exist in the table
    const columnCheck = await db.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'products'
    `);
    
    const columns = columnCheck.rows.map(row => row.column_name);
    
    if (columns.includes('location')) query += ', location';
    if (columns.includes('do_not_ship')) query += ', do_not_ship';
    if (columns.includes('storage_charge_per_pallet')) query += ', storage_charge_per_pallet';
    if (columns.includes('handling_charge_per_pallet')) query += ', handling_charge_per_pallet';
    if (columns.includes('unit')) query += ', unit';
    if (columns.includes('units_per_pallet')) query += ', units_per_pallet';
    if (columns.includes('pallet_stack_height')) query += ', pallet_stack_height';
    if (columns.includes('track_by_lot')) query += ', track_by_lot';
    if (columns.includes('str_group')) query += ', str_group';
    
    query += ') VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12';
    
    const params = [
      product_id,
      name,
      description,
      weight_kg || 0,
      volume_cubic_m || 0,
      requires_refrigeration || false,
      requires_heating || false,
      is_dangerous_good || false,
      tdg_number,
      warehouse_id,
      customer_code,
      quantity_on_hand || 0
    ];
    
    // Add optional parameters if their columns exist
    let paramIndex = 13;
    if (columns.includes('location')) {
      query += `, $${paramIndex++}`;
      params.push(location);
    }
    if (columns.includes('do_not_ship')) {
      query += `, $${paramIndex++}`;
      params.push(do_not_ship || false);
    }
    if (columns.includes('storage_charge_per_pallet')) {
      query += `, $${paramIndex++}`;
      params.push(storage_charge_per_pallet || 0);
    }
    if (columns.includes('handling_charge_per_pallet')) {
      query += `, $${paramIndex++}`;
      params.push(handling_charge_per_pallet || 0);
    }
    if (columns.includes('unit')) {
      query += `, $${paramIndex++}`;
      params.push(unit);
    }
    if (columns.includes('units_per_pallet')) {
      query += `, $${paramIndex++}`;
      params.push(units_per_pallet || 0);
    }
    if (columns.includes('pallet_stack_height')) {
      query += `, $${paramIndex++}`;
      params.push(pallet_stack_height || 0);
    }
    if (columns.includes('track_by_lot')) {
      query += `, $${paramIndex++}`;
      params.push(track_by_lot || false);
    }
    if (columns.includes('str_group')) {
      query += `, $${paramIndex++}`;
      params.push(str_group);
    }
    
    query += ') RETURNING *';
    
    const result = await db.query(query, params);
    
    // Convert weight_kg to weight_lbs for frontend
    const productWithLbs = {
      ...result.rows[0],
      weight_lbs: result.rows[0].weight_kg * 2.20462 // Convert kg to lbs
    };
    
    res.status(201).json({ success: true, data: productWithLbs });
  } catch (error) {
    console.error('Error creating product:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Update a product
 * @route PUT /api/products/:productId
 */
exports.updateProduct = async (req, res) => {
  try {
    const { productId } = req.params;
    const {
      name,
      description,
      weight_kg,
      volume_cubic_m,
      requires_refrigeration,
      requires_heating,
      is_dangerous_good,
      tdg_number,
      hazard_pk,
      warehouse_id,
      customer_code,
      quantity_on_hand,
      location,
      do_not_ship,
      storage_charge_per_pallet,
      handling_charge_per_pallet,
      unit,
      units_per_pallet,
      pallet_stack_height,
      track_by_lot,
      str_group
    } = req.body;
    
    // Check if product exists
    const checkResult = await db.query('SELECT product_id FROM products WHERE product_id = $1', [productId]);
    
    if (checkResult.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Product not found' });
    }
    
    // Start building the query
    let query = `
      UPDATE products SET
        name = $1, 
        description = $2, 
        weight_kg = $3, 
        volume_cubic_m = $4, 
        requires_refrigeration = $5, 
        requires_heating = $6, 
        is_dangerous_good = $7, 
        tdg_number = $8,
        warehouse_id = $9,
        customer_code = $10,
        quantity_on_hand = $11
    `;
    
    const params = [
      name,
      description,
      weight_kg || 0,
      volume_cubic_m || 0,
      requires_refrigeration || false,
      requires_heating || false,
      is_dangerous_good || false,
      tdg_number,
      warehouse_id,
      customer_code,
      quantity_on_hand || 0
    ];
    
    // Add optional fields if they exist in the table
    const columnCheck = await db.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'products'
    `);
    
    const columns = columnCheck.rows.map(row => row.column_name);
    
    let paramIndex = 13;
    if (columns.includes('location')) {
      query += `, location = $${paramIndex++}`;
      params.push(location);
    }
    if (columns.includes('do_not_ship')) {
      query += `, do_not_ship = $${paramIndex++}`;
      params.push(do_not_ship || false);
    }
    if (columns.includes('storage_charge_per_pallet')) {
      query += `, storage_charge_per_pallet = $${paramIndex++}`;
      params.push(storage_charge_per_pallet || 0);
    }
    if (columns.includes('handling_charge_per_pallet')) {
      query += `, handling_charge_per_pallet = $${paramIndex++}`;
      params.push(handling_charge_per_pallet || 0);
    }
    if (columns.includes('unit')) {
      query += `, unit = $${paramIndex++}`;
      params.push(unit);
    }
    if (columns.includes('units_per_pallet')) {
      query += `, units_per_pallet = $${paramIndex++}`;
      params.push(units_per_pallet || 0);
    }
    if (columns.includes('pallet_stack_height')) {
      query += `, pallet_stack_height = $${paramIndex++}`;
      params.push(pallet_stack_height || 0);
    }
    if (columns.includes('track_by_lot')) {
      query += `, track_by_lot = $${paramIndex++}`;
      params.push(track_by_lot || false);
    }
    if (columns.includes('str_group')) {
      query += `, str_group = $${paramIndex++}`;
      params.push(str_group);
    }
    
    query += `, updated_at = CURRENT_TIMESTAMP WHERE product_id = $${paramIndex} RETURNING *`;
    params.push(productId);
    
    const result = await db.query(query, params);
    
    // Convert weight_kg to weight_lbs for frontend
    const productWithLbs = {
      ...result.rows[0],
      weight_lbs: result.rows[0].weight_kg * 2.20462 // Convert kg to lbs
    };
    
    res.json({ success: true, data: productWithLbs });
  } catch (error) {
    console.error('Error updating product:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Delete a product
 * @route DELETE /api/products/:productId
 */
exports.deleteProduct = async (req, res) => {
  try {
    const { productId } = req.params;
    
    // Check if product exists
    const checkResult = await db.query('SELECT product_id FROM products WHERE product_id = $1', [productId]);
    
    if (checkResult.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Product not found' });
    }
    
    // Check if product is referenced by any order line items
    const lineItemResult = await db.query(
      'SELECT line_item_id FROM order_line_items WHERE product_id = $1 LIMIT 1',
      [productId]
    );
    
    if (lineItemResult.rows.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'Cannot delete product because it is referenced by one or more order line items'
      });
    }
    
    // Delete product
    await db.query('DELETE FROM products WHERE product_id = $1', [productId]);
    
    res.json({ success: true, message: 'Product deleted successfully' });
  } catch (error) {
    console.error('Error deleting product:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};
