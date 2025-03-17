// src/controllers/customersController.js
const db = require('../config/backend-database-connection');

/**
 * Get all customers
 * @route GET /api/customers
 */
exports.getCustomers = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM customers ORDER BY company_name');
    res.json({ success: true, data: result.rows });
  } catch (error) {
    console.error('Error fetching customers:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Get customer by ID
 * @route GET /api/customers/:customerId
 */
exports.getCustomerById = async (req, res) => {
  try {
    const { customerId } = req.params;
    const result = await db.query('SELECT * FROM customers WHERE customer_id = $1', [customerId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Customer not found' });
    }
    
    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error fetching customer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Create a new customer
 * @route POST /api/customers
 */
exports.createCustomer = async (req, res) => {
  try {
    const {
      customer_id,
      company_name,
      contact_name,
      address,
      city,
      province,
      postal_code,
      contact_phone,
      contact_email
    } = req.body;
    
    // Validate required fields
    if (!customer_id || !company_name || !city || !province) {
      return res.status(400).json({
        success: false,
        error: 'customer_id, company_name, city, and province are required'
      });
    }
    
    const result = await db.query(
      `INSERT INTO customers 
       (customer_id, company_name, contact_name, address, city, province, postal_code, contact_phone, contact_email) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
       RETURNING *`,
      [customer_id, company_name, contact_name, address, city, province, postal_code, contact_phone, contact_email]
    );
    
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error creating customer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Update a customer
 * @route PUT /api/customers/:customerId
 */
exports.updateCustomer = async (req, res) => {
  try {
    const { customerId } = req.params;
    const {
      company_name,
      contact_name,
      address,
      city,
      province,
      postal_code,
      contact_phone,
      contact_email
    } = req.body;
    
    // Validate required fields
    if (!company_name || !city || !province) {
      return res.status(400).json({
        success: false,
        error: 'company_name, city, and province are required'
      });
    }
    
    const result = await db.query(
      `UPDATE customers 
       SET company_name = $1, 
           contact_name = $2, 
           address = $3, 
           city = $4, 
           province = $5, 
           postal_code = $6, 
           contact_phone = $7, 
           contact_email = $8,
           updated_at = CURRENT_TIMESTAMP
       WHERE customer_id = $9
       RETURNING *`,
      [company_name, contact_name, address, city, province, postal_code, contact_phone, contact_email, customerId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Customer not found' });
    }
    
    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Error updating customer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/**
 * Delete a customer
 * @route DELETE /api/customers/:customerId
 */
exports.deleteCustomer = async (req, res) => {
  try {
    const { customerId } = req.params;
    
    // Check if customer exists
    const checkResult = await db.query('SELECT customer_id FROM customers WHERE customer_id = $1', [customerId]);
    
    if (checkResult.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Customer not found' });
    }
    
    // Check if customer is referenced by any orders
    const orderResult = await db.query('SELECT order_id FROM order_headers WHERE customer_id = $1 LIMIT 1', [customerId]);
    
    if (orderResult.rows.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'Cannot delete customer because it is referenced by one or more orders'
      });
    }
    
    // Delete customer
    await db.query('DELETE FROM customers WHERE customer_id = $1', [customerId]);
    
    res.json({ success: true, message: 'Customer deleted successfully' });
  } catch (error) {
    console.error('Error deleting customer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};
