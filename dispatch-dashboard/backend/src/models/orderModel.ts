// src/models/orderModel.ts
import { query } from '../config/backend-database-connection';
import { v4 as uuidv4 } from 'uuid';

export interface Order {
  id: string;
  order_number: string;
  customer_id: string;
  pickup_address: string;
  pickup_city: string;
  pickup_province: string;
  pickup_postal_code: string;
  pickup_date: Date;
  delivery_address: string;
  delivery_city: string;
  delivery_province: string;
  delivery_postal_code: string;
  delivery_date: Date;
  status: 'pending' | 'assigned' | 'in_transit' | 'delivered' | 'cancelled';
  total_weight: number;
  total_volume: number;
  special_instructions?: string;
  created_at: Date;
  updated_at: Date;
}

export interface CreateOrderDto {
  order_number: string;
  customer_id: string;
  pickup_address: string;
  pickup_city: string;
  pickup_province: string;
  pickup_postal_code: string;
  pickup_date: Date;
  delivery_address: string;
  delivery_city: string;
  delivery_province: string;
  delivery_postal_code: string;
  delivery_date: Date;
  total_weight: number;
  total_volume: number;
  special_instructions?: string;
}

export interface UpdateOrderDto {
  status?: 'pending' | 'assigned' | 'in_transit' | 'delivered' | 'cancelled';
  pickup_date?: Date;
  delivery_date?: Date;
  special_instructions?: string;
}

export interface OrderFilters {
  status?: string;
  customer_id?: string;
  start_date?: Date;
  end_date?: Date;
}

// Create a new order
export const createOrder = async (orderData: CreateOrderDto): Promise<Order> => {
  const id = uuidv4();
  const now = new Date();
  
  const result = await query(
    `INSERT INTO orders (
      id, order_number, customer_id, 
      pickup_address, pickup_city, pickup_province, pickup_postal_code, pickup_date,
      delivery_address, delivery_city, delivery_province, delivery_postal_code, delivery_date,
      status, total_weight, total_volume, special_instructions, created_at, updated_at
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19) 
    RETURNING *`,
    [
      id, orderData.order_number, orderData.customer_id,
      orderData.pickup_address, orderData.pickup_city, orderData.pickup_province, orderData.pickup_postal_code, orderData.pickup_date,
      orderData.delivery_address, orderData.delivery_city, orderData.delivery_province, orderData.delivery_postal_code, orderData.delivery_date,
      'pending', orderData.total_weight, orderData.total_volume, orderData.special_instructions || null, now, now
    ]
  );
  
  return result.rows[0];
};

// Get all orders with optional filters
export const getOrders = async (filters?: OrderFilters): Promise<Order[]> => {
  let queryText = 'SELECT * FROM orders';
  const queryParams: any[] = [];
  
  if (filters) {
    const conditions: string[] = [];
    
    if (filters.status) {
      conditions.push(`status = $${queryParams.length + 1}`);
      queryParams.push(filters.status);
    }
    
    if (filters.customer_id) {
      conditions.push(`customer_id = $${queryParams.length + 1}`);
      queryParams.push(filters.customer_id);
    }
    
    if (filters.start_date) {
      conditions.push(`pickup_date >= $${queryParams.length + 1}`);
      queryParams.push(filters.start_date);
    }
    
    if (filters.end_date) {
      conditions.push(`pickup_date <= $${queryParams.length + 1}`);
      queryParams.push(filters.end_date);
    }
    
    if (conditions.length > 0) {
      queryText += ' WHERE ' + conditions.join(' AND ');
    }
  }
  
  queryText += ' ORDER BY created_at DESC';
  
  const result = await query(queryText, queryParams);
  return result.rows;
};

// Get order by ID
export const getOrderById = async (id: string): Promise<Order | null> => {
  const result = await query('SELECT * FROM orders WHERE id = $1', [id]);
  return result.rows.length ? result.rows[0] : null;
};

// Update order
export const updateOrder = async (id: string, updateData: UpdateOrderDto): Promise<Order | null> => {
  // Build dynamic query based on provided fields
  const updates: string[] = [];
  const queryParams: any[] = [id];
  
  Object.entries(updateData).forEach(([key, value]) => {
    if (value !== undefined) {
      updates.push(`${key} = $${queryParams.length + 1}`);
      queryParams.push(value);
    }
  });
  
  // Always update the updated_at timestamp
  updates.push(`updated_at = $${queryParams.length + 1}`);
  queryParams.push(new Date());
  
  if (updates.length === 0) {
    // No updates to make
    return getOrderById(id);
  }
  
  const queryText = `
    UPDATE orders 
    SET ${updates.join(', ')} 
    WHERE id = $1 
    RETURNING *
  `;
  
  const result = await query(queryText, queryParams);
  return result.rows.length ? result.rows[0] : null;
};

// Delete order
export const deleteOrder = async (id: string): Promise<boolean> => {
  const result = await query('DELETE FROM orders WHERE id = $1 RETURNING id', [id]);
  return result.rows.length > 0;
};

// Get order with shipment details
export const getOrderWithShipmentDetails = async (id: string): Promise<any> => {
  const result = await query(`
    SELECT o.*, 
           s.id as shipment_id, 
           s.status as shipment_status,
           v.id as vehicle_id, 
           v.vehicle_number,
           d.id as driver_id,
           d.first_name as driver_first_name,
           d.last_name as driver_last_name,
           c.company_name as customer_name,
           c.address as customer_address,
           c.city as customer_city,
           c.province as customer_province,
           c.postal_code as customer_postal_code,
           c.contact_name as customer_contact_name,
           c.contact_phone as customer_contact_phone,
           c.contact_email as customer_contact_email,
           oli.product_id,
           p.name as product_name,
           p.description as product_description,
           p.weight_kg as product_weight,
           p.volume_cubic_m as product_volume,
           p.requires_heating as product_requires_heating,
           p.is_dangerous_good as product_is_dangerous,
           h.hazard_pk,
           h.hazard_code,
           h.description1 as hazard_description1,
           h.description2 as hazard_description2,
           h.description3 as hazard_description3
    FROM orders o
    LEFT JOIN shipments s ON o.id = s.order_id
    LEFT JOIN vehicles v ON s.vehicle_id = v.id
    LEFT JOIN drivers d ON s.driver_id = d.id
    LEFT JOIN customers c ON o.customer_id = c.customer_id
    LEFT JOIN order_line_items oli ON o.id = oli.order_id
    LEFT JOIN products p ON oli.product_id = p.product_id
    LEFT JOIN hazards h ON p.hazard_pk = h.hazard_pk
    WHERE o.id = $1
  `, [id]);
  
  if (result.rows.length === 0) {
    return null;
  }
  
  // Group line items with products and hazards
  const order = result.rows[0];
  order.line_items = result.rows
    .filter((row: any) => row.product_id) // Only include rows with products
    .map((row: any) => ({
      product_id: row.product_id,
      product_name: row.product_name,
      product_description: row.product_description,
      product_weight: row.product_weight,
      product_volume: row.product_volume,
      product_requires_heating: row.product_requires_heating,
      product_is_dangerous: row.product_is_dangerous,
      hazard_pk: row.hazard_pk,
      hazard_code: row.hazard_code,
      hazard_description1: row.hazard_description1,
      hazard_description2: row.hazard_description2,
      hazard_description3: row.hazard_description3
    }));
  
  // Remove duplicate product fields from the main order object
  delete order.product_id;
  delete order.product_name;
  delete order.product_description;
  delete order.product_weight;
  delete order.product_volume;
  delete order.product_requires_heating;
  delete order.product_is_dangerous;
  delete order.hazard_pk;
  delete order.hazard_code;
  delete order.hazard_description1;
  delete order.hazard_description2;
  delete order.hazard_description3;
  
  return order;
};

// Get all orders with product and hazard information
export const getOrdersWithProductInfo = async (filters?: OrderFilters): Promise<any[]> => {
  let queryText = `
    SELECT o.*,
           c.company_name as customer_name,
           oli.product_id,
           p.name as product_name,
           p.description as product_description,
           p.is_dangerous_good as product_is_dangerous,
           h.hazard_code,
           h.description1 as hazard_description1
    FROM orders o
    LEFT JOIN customers c ON o.customer_id = c.customer_id
    LEFT JOIN order_line_items oli ON o.id = oli.order_id
    LEFT JOIN products p ON oli.product_id = p.product_id
    LEFT JOIN hazards h ON p.hazard_pk = h.hazard_pk
  `;
  
  const queryParams: any[] = [];
  
  if (filters) {
    const conditions: string[] = [];
    
    if (filters.status) {
      conditions.push(`o.status = $${queryParams.length + 1}`);
      queryParams.push(filters.status);
    }
    
    if (filters.customer_id) {
      conditions.push(`o.customer_id = $${queryParams.length + 1}`);
      queryParams.push(filters.customer_id);
    }
    
    if (filters.start_date) {
      conditions.push(`o.pickup_date >= $${queryParams.length + 1}`);
      queryParams.push(filters.start_date);
    }
    
    if (filters.end_date) {
      conditions.push(`o.pickup_date <= $${queryParams.length + 1}`);
      queryParams.push(filters.end_date);
    }
    
    if (conditions.length > 0) {
      queryText += ' WHERE ' + conditions.join(' AND ');
    }
  }
  
  queryText += ' ORDER BY o.created_at DESC';
  
  const result = await query(queryText, queryParams);
  
  // Group orders with their products
  const ordersMap = new Map();
  
  result.rows.forEach((row: any) => {
    if (!ordersMap.has(row.id)) {
      // Create a new order entry
      const order: any = { ...row };
      order.line_items = [];
      
      // Add product if it exists
      if (row.product_id) {
        order.line_items.push({
          product_id: row.product_id,
          product_name: row.product_name,
          product_description: row.product_description,
          product_is_dangerous: row.product_is_dangerous,
          hazard_code: row.hazard_code,
          hazard_description1: row.hazard_description1
        });
      }
      
      // Remove product fields from the main order object
      delete order.product_id;
      delete order.product_name;
      delete order.product_description;
      delete order.product_is_dangerous;
      delete order.hazard_code;
      delete order.hazard_description1;
      
      ordersMap.set(row.id, order);
    } else if (row.product_id) {
      // Add product to existing order
      const order = ordersMap.get(row.id);
      
      // Check if this product is already in the line items
      const existingProduct = order.line_items.find(
        (item: any) => item.product_id === row.product_id
      );
      
      if (!existingProduct) {
        order.line_items.push({
          product_id: row.product_id,
          product_name: row.product_name,
          product_description: row.product_description,
          product_is_dangerous: row.product_is_dangerous,
          hazard_code: row.hazard_code,
          hazard_description1: row.hazard_description1
        });
      }
    }
  });
  
  return Array.from(ordersMap.values());
};
