// order-api.js - Order Submission API for dispatch dashboard
const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const { v4: uuidv4 } = require('uuid');
const Joi = require('joi');

// Configure PostgreSQL connection
const pool = new Pool({
  // These would come from environment variables in production
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD ? String(process.env.DB_PASSWORD) : '',
  port: process.env.DB_PORT || 5432,
});

// Test database connection
pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

// Authentication middleware
const authenticateApiKey = async (req, res, next) => {
  // Check for internal request header (used by frontend)
  const internalRequest = req.headers['x-internal-request'];
  
  // If it's an internal request, bypass authentication
  if (internalRequest === 'true') {
    // For internal requests, we still need to set a manufacturer
    try {
      // Get the default manufacturer (first active one)
      const result = await pool.query(
        'SELECT manufacturer_id, name FROM manufacturers WHERE is_active = true LIMIT 1'
      );
      
      if (result.rows.length === 0) {
        return res.status(500).json({
          success: false,
          error: 'Server error',
          details: 'No active manufacturer found for internal request',
          timestamp: new Date().toISOString()
        });
      }
      
      // Add manufacturer to request for use in route handlers
      req.manufacturer = result.rows[0];
      return next();
    } catch (err) {
      console.error('Error getting default manufacturer:', err);
      return res.status(500).json({
        success: false,
        error: 'Server error',
        details: 'Error getting default manufacturer',
        timestamp: new Date().toISOString()
      });
    }
  }
  
  // For external requests, require API key authentication
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      error: 'Authentication failed',
      details: 'Missing or invalid API key',
      timestamp: new Date().toISOString()
    });
  }
  
  const apiKey = authHeader.split(' ')[1];
  
  try {
    // Check if the API key is valid and get the manufacturer
    const result = await pool.query(
      'SELECT manufacturer_id, name FROM manufacturers WHERE api_key = $1 AND is_active = true',
      [apiKey]
    );
    
    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: 'Authentication failed',
        details: 'Invalid API key',
        timestamp: new Date().toISOString()
      });
    }
    
    // Add manufacturer to request for use in route handlers
    req.manufacturer = result.rows[0];
    next();
  } catch (err) {
    console.error('Authentication error:', err);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      details: 'Error during authentication',
      timestamp: new Date().toISOString()
    });
  }
};

// Validation schema for order submission
const orderSchema = Joi.object({
  orderHeader: Joi.object({
    documentId: Joi.string().required(),
    manufacturer: Joi.string().required(),
    orderDate: Joi.date().iso().required(),
    poNumber: Joi.string().required(),
    shipmentDate: Joi.date().iso().required(),
    deliveryDate: Joi.date().iso().required()
  }).required(),
  
  shipment: Joi.object({
    shipFrom: Joi.string(),
    shipTo: Joi.object({
      companyName: Joi.string().required(),
      city: Joi.string().required(),
      province: Joi.string().required()
    }).required(),
    specialRequirements: Joi.string().allow(null, '')
  }).required(),
  
  lineItems: Joi.array().items(
    Joi.object({
      productId: Joi.string().required(),
      productName: Joi.string().required(),
      quantity: Joi.number().integer().positive().required(),
      weightKg: Joi.number().positive().required()
    })
  ).min(1).required(),
  
  totals: Joi.object({
    totalQuantity: Joi.number().integer().positive().required(),
    totalWeightKg: Joi.number().positive().required()
  }).required()
});

// Log API requests and responses
const logApiTransaction = async (req, type, endpoint, requestBody, responseBody, statusCode) => {
  try {
    await pool.query(
      `INSERT INTO api_logs 
       (request_type, endpoint, request_body, response_body, status_code, ip_address, user_agent, created_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        type,
        endpoint,
        JSON.stringify(requestBody),
        JSON.stringify(responseBody),
        statusCode,
        req.ip,
        req.get('user-agent'),
        new Date()
      ]
    );
  } catch (err) {
    console.error('Error logging API transaction:', err);
  }
};

// Calculate estimated revenue based on rate tables
const calculateRevenue = async (warehouseId, destinationCity, destinationProvince, weightKg) => {
  try {
    const result = await pool.query(
      `SELECT rate_per_100kg 
       FROM rate_tables 
       WHERE origin_warehouse_id = $1 
       AND destination_city = $2 
       AND destination_province = $3 
       AND min_weight_kg <= $4 
       AND max_weight_kg >= $4 
       AND current_date BETWEEN effective_date AND COALESCE(expiry_date, '9999-12-31')
       ORDER BY effective_date DESC 
       LIMIT 1`,
      [warehouseId, destinationCity, destinationProvince, weightKg]
    );
    
    if (result.rows.length === 0) {
      // Default rate if no rate table entry found
      return weightKg * 0.25; // $0.25 per kg as fallback
    }
    
    const ratePerHundredKg = result.rows[0].rate_per_100kg;
    return (weightKg / 100) * ratePerHundredKg;
  } catch (err) {
    console.error('Error calculating revenue:', err);
    return null;
  }
};

// GET /api/orders - Get all orders with optional filters
router.get('/', authenticateApiKey, async (req, res) => {
  try {
    // Extract and validate query parameters
    const filters = {};
    
    if (req.query.status) filters.status = req.query.status;
    if (req.query.customer_id) filters.customer_id = req.query.customer_id;
    if (req.query.warehouse_id) filters.warehouse_id = req.query.warehouse_id;
    if (req.query.start_date) filters.start_date = new Date(req.query.start_date);
    if (req.query.end_date) filters.end_date = new Date(req.query.end_date);
    
    // Query to get orders with filters
    let queryText = `
      SELECT oh.order_id, oh.document_id as order_number, 
             c.company_name as customer_name, 
             '' as warehouse_name,
             c.city as delivery_city, 
             c.province as delivery_province,
             oh.requested_shipment_date as pickup_date,
             oh.requested_delivery_date as delivery_date,
             oh.total_weight_kg * 2.20462 as total_weight, -- Convert kg to lbs
             CEIL(oh.total_quantity / 10) as pallets, -- Estimate pallets based on quantity
             CASE 
               WHEN oh.status = 'RECEIVED' THEN 'pending'
               WHEN oh.status = 'ASSIGNED' THEN 'assigned'
               WHEN oh.status = 'IN_TRANSIT' THEN 'in_transit'
               WHEN oh.status = 'DELIVERED' THEN 'delivered'
               WHEN oh.status = 'CANCELLED' THEN 'cancelled'
               ELSE 'pending'
             END as status
      FROM order_headers oh
      LEFT JOIN customers c ON oh.customer_id = c.customer_id
    `;
    
    const queryParams = [];
    const conditions = [];
    
    // Add filter conditions
    if (filters.status) {
      queryParams.push(filters.status.toUpperCase());
      conditions.push(`oh.status = $${queryParams.length}`);
    }
    
    if (filters.customer_id) {
      queryParams.push(filters.customer_id);
      conditions.push(`oh.customer_id = $${queryParams.length}`);
    }
    
    // Warehouse filter is handled differently since we're not joining with warehouses table
    if (filters.warehouse_id) {
      // We'll handle this in the application logic instead
    }
    
    if (filters.start_date) {
      queryParams.push(filters.start_date);
      conditions.push(`oh.requested_shipment_date >= $${queryParams.length}`);
    }
    
    if (filters.end_date) {
      queryParams.push(filters.end_date);
      conditions.push(`oh.requested_shipment_date <= $${queryParams.length}`);
    }
    
    // Add WHERE clause if there are conditions
    if (conditions.length > 0) {
      queryText += ' WHERE ' + conditions.join(' AND ');
    }
    
    // Add ORDER BY
    queryText += ' ORDER BY oh.created_at DESC';
    
    // Execute the query
    const ordersResult = await pool.query(queryText, queryParams);
    
    // Get line items for each order
    let orders = [];
    try {
      orders = await Promise.all(ordersResult.rows.map(async (order) => {
        try {
          // Query to get line items with product and hazard information
          const lineItemsQuery = `
            SELECT oli.product_id, p.name as product_name, 
                  oli.quantity, oli.weight_kg * 2.20462 as weight_lbs,
                  h.hazard_code, h.description1 as hazard_description1,
                  h.description2 as hazard_description2, h.description3 as hazard_description3
            FROM order_line_items oli
            LEFT JOIN products p ON oli.product_id = p.product_id
            LEFT JOIN hazards h ON p.hazard_pk = h.hazard_pk
            WHERE oli.order_id = $1
          `;
          
          const lineItemsResult = await pool.query(lineItemsQuery, [order.order_id]);
          
          // Add line items to order
          return {
            ...order,
            line_items: lineItemsResult.rows
          };
        } catch (err) {
          console.error(`Error fetching line items for order ${order.order_id}:`, err);
          // Return the order without line items if there's an error
          return {
            ...order,
            line_items: []
          };
        }
      }));
    } catch (err) {
      console.error('Error processing orders:', err);
      // If Promise.all fails, just return the orders without line items
      orders = ordersResult.rows.map(order => ({
        ...order,
        line_items: []
      }));
    }
    
    // Log the API transaction
    const response = {
      success: true,
      data: {
        orders
      },
      timestamp: new Date().toISOString()
    };
    
    await logApiTransaction(req, 'OUTGOING', '/api/orders', req.query, response, 200);
    
    return res.status(200).json(response);
  } catch (err) {
    console.error('Error fetching orders:', err);
    
    const response = {
      success: false,
      error: 'Server error',
      details: 'An error occurred while fetching orders',
      timestamp: new Date().toISOString()
    };
    
    await logApiTransaction(req, 'OUTGOING', '/api/orders', req.query, response, 500);
    
    return res.status(500).json(response);
  }
});

// POST /api/orders - Submit a new order
router.post('/', authenticateApiKey, async (req, res) => {
  // Validate request body
  const { error, value } = orderSchema.validate(req.body);
  
  if (error) {
    const response = {
      success: false,
      error: 'Invalid request format',
      details: error.details[0].message,
      timestamp: new Date().toISOString()
    };
    
    await logApiTransaction(req, 'INCOMING', '/api/orders', req.body, response, 400);
    
    return res.status(400).json(response);
  }
  
  const orderData = value;
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    // Check for duplicate order
    const duplicateCheck = await client.query(
      'SELECT order_id FROM order_headers WHERE document_id = $1',
      [orderData.orderHeader.documentId]
    );
    
    if (duplicateCheck.rows.length > 0) {
      const response = {
        success: false,
        error: 'Duplicate order',
        details: `An order with document ID '${orderData.orderHeader.documentId}' already exists`,
        timestamp: new Date().toISOString()
      };
      
      await logApiTransaction(req, 'INCOMING', '/api/orders', req.body, response, 409);
      
      return res.status(409).json(response);
    }
    
    // Find or create customer
    let customerId;
    const customerResult = await client.query(
      'SELECT customer_id FROM customers WHERE company_name = $1 AND city = $2 AND province = $3',
      [
        orderData.shipment.shipTo.companyName,
        orderData.shipment.shipTo.city,
        orderData.shipment.shipTo.province
      ]
    );
    
    if (customerResult.rows.length > 0) {
      customerId = customerResult.rows[0].customer_id;
    } else {
      const newCustomer = await client.query(
        `INSERT INTO customers 
         (company_name, city, province, created_at, updated_at) 
         VALUES ($1, $2, $3, $4, $5) 
         RETURNING customer_id`,
        [
          orderData.shipment.shipTo.companyName,
          orderData.shipment.shipTo.city,
          orderData.shipment.shipTo.province,
          new Date(),
          new Date()
        ]
      );
      
      customerId = newCustomer.rows[0].customer_id;
    }
    
    // Find warehouse based on shipFrom
    const warehouseResult = await client.query(
      'SELECT warehouse_id FROM warehouses WHERE name ILIKE $1 OR name ILIKE $2 LIMIT 1',
      [`%${orderData.shipment.shipFrom}%`, `${orderData.shipment.shipFrom}%`]
    );
    
    let warehouseId = null;
    if (warehouseResult.rows.length > 0) {
      warehouseId = warehouseResult.rows[0].warehouse_id;
    }
    
    // Calculate estimated revenue
    let estimatedRevenue = null;
    if (warehouseId) {
      estimatedRevenue = await calculateRevenue(
        warehouseId,
        orderData.shipment.shipTo.city,
        orderData.shipment.shipTo.province,
        orderData.totals.totalWeightKg
      );
    }
    
    // Create order header
    const orderResult = await client.query(
      `INSERT INTO order_headers
       (document_id, manufacturer_id, order_date, po_number, requested_shipment_date, 
        requested_delivery_date, customer_id, special_requirements, status, 
        total_quantity, total_weight_kg, estimated_revenue, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
       RETURNING order_id`,
      [
        orderData.orderHeader.documentId,
        req.manufacturer.manufacturer_id,
        orderData.orderHeader.orderDate,
        orderData.orderHeader.poNumber,
        orderData.orderHeader.shipmentDate,
        orderData.orderHeader.deliveryDate,
        customerId,
        orderData.shipment.specialRequirements || null,
        'RECEIVED',
        orderData.totals.totalQuantity,
        orderData.totals.totalWeightKg,
        estimatedRevenue,
        new Date(),
        new Date()
      ]
    );
    
    const orderId = orderResult.rows[0].order_id;
    
    // Create order line items
    for (const item of orderData.lineItems) {
      // Check if product exists
      let productExists = await client.query(
        'SELECT product_id FROM products WHERE product_id = $1',
        [item.productId]
      );
      
      // Create product if it doesn't exist
      if (productExists.rows.length === 0) {
        await client.query(
          `INSERT INTO products
           (product_id, manufacturer_id, name, weight_kg, is_active, created_at, updated_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [
            item.productId,
            req.manufacturer.manufacturer_id,
            item.productName,
            item.weightKg / item.quantity, // Weight per single unit
            true,
            new Date(),
            new Date()
          ]
        );
      }
      
      // Add order line item
      await client.query(
        `INSERT INTO order_line_items
         (order_id, product_id, quantity, weight_kg, created_at, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [
          orderId,
          item.productId,
          item.quantity,
          item.weightKg,
          new Date(),
          new Date()
        ]
      );
    }
    
    await client.query('COMMIT');
    
    // Generate CWS order ID (prefixed internal ID)
    const cwsOrderId = `CWS-${String(orderId).padStart(8, '0')}`;
    
    const response = {
      success: true,
      orderId: cwsOrderId,
      message: 'Order successfully received',
      timestamp: new Date().toISOString()
    };
    
    await logApiTransaction(req, 'INCOMING', '/api/orders', req.body, response, 201);
    
    return res.status(201).json(response);
    
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error processing order:', err);
    
    const response = {
      success: false,
      error: 'Server error',
      details: 'An error occurred while processing the order',
      timestamp: new Date().toISOString()
    };
    
    await logApiTransaction(req, 'INCOMING', '/api/orders', req.body, response, 500);
    
    return res.status(500).json(response);
  } finally {
    client.release();
  }
});

module.exports = router;
