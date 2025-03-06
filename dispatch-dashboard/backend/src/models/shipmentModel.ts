// src/models/shipmentModel.ts
import { query } from '../config/database';
import { v4 as uuidv4 } from 'uuid';

export interface Shipment {
  id: string;
  order_id: string;
  vehicle_id: string;
  driver_id: string;
  planned_departure: Date;
  planned_arrival: Date;
  actual_departure?: Date;
  actual_arrival?: Date;
  distance_miles: number;
  status: 'planned' | 'in_transit' | 'completed' | 'cancelled';
  notes?: string;
  created_at: Date;
  updated_at: Date;
}

export interface CreateShipmentDto {
  order_id: string;
  vehicle_id: string;
  driver_id: string;
  planned_departure: Date;
  planned_arrival: Date;
  distance_miles: number;
  notes?: string;
}

export interface UpdateShipmentDto {
  vehicle_id?: string;
  driver_id?: string;
  planned_departure?: Date;
  planned_arrival?: Date;
  actual_departure?: Date;
  actual_arrival?: Date;
  distance_miles?: number;
  status?: 'planned' | 'in_transit' | 'completed' | 'cancelled';
  notes?: string;
}

export interface ShipmentFilters {
  status?: string;
  driver_id?: string;
  vehicle_id?: string;
  start_date?: Date;
  end_date?: Date;
}

// Create a new shipment
export const createShipment = async (shipmentData: CreateShipmentDto): Promise<Shipment> => {
  const id = uuidv4();
  const now = new Date();
  
  const result = await query(
    `INSERT INTO shipments (
      id, order_id, vehicle_id, driver_id, 
      planned_departure, planned_arrival, distance_miles,
      status, notes, created_at, updated_at
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) 
    RETURNING *`,
    [
      id, shipmentData.order_id, shipmentData.vehicle_id, shipmentData.driver_id,
      shipmentData.planned_departure, shipmentData.planned_arrival, shipmentData.distance_miles,
      'planned', shipmentData.notes || null, now, now
    ]
  );
  
  // Update the order status to 'assigned'
  await query(
    `UPDATE orders SET status = 'assigned', updated_at = $1 WHERE id = $2`,
    [now, shipmentData.order_id]
  );
  
  return result.rows[0];
};

// Get all shipments with optional filters
export const getShipments = async (filters?: ShipmentFilters): Promise<Shipment[]> => {
  let queryText = 'SELECT * FROM shipments';
  const queryParams: any[] = [];
  
  if (filters) {
    const conditions: string[] = [];
    
    if (filters.status) {
      conditions.push(`status = $${queryParams.length + 1}`);
      queryParams.push(filters.status);
    }
    
    if (filters.driver_id) {
      conditions.push(`driver_id = $${queryParams.length + 1}`);
      queryParams.push(filters.driver_id);
    }
    
    if (filters.vehicle_id) {
      conditions.push(`vehicle_id = $${queryParams.length + 1}`);
      queryParams.push(filters.vehicle_id);
    }
    
    if (filters.start_date) {
      conditions.push(`planned_departure >= $${queryParams.length + 1}`);
      queryParams.push(filters.start_date);
    }
    
    if (filters.end_date) {
      conditions.push(`planned_departure <= $${queryParams.length + 1}`);
      queryParams.push(filters.end_date);
    }
    
    if (conditions.length > 0) {
      queryText += ' WHERE ' + conditions.join(' AND ');
    }
  }
  
  queryText += ' ORDER BY planned_departure';
  
  const result = await query(queryText, queryParams);
  return result.rows;
};

// Get shipment by ID
export const getShipmentById = async (id: string): Promise<Shipment | null> => {
  const result = await query('SELECT * FROM shipments WHERE id = $1', [id]);
  return result.rows.length ? result.rows[0] : null;
};

// Update shipment
export const updateShipment = async (id: string, updateData: UpdateShipmentDto): Promise<Shipment | null> => {
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
    return getShipmentById(id);
  }
  
  const queryText = `
    UPDATE shipments 
    SET ${updates.join(', ')} 
    WHERE id = $1 
    RETURNING *
  `;
  
  const result = await query(queryText, queryParams);
  
  // If the shipment status has changed, update the order status accordingly
  if (updateData.status && result.rows.length > 0) {
    const shipment = result.rows[0];
    
    let orderStatus: string;
    switch (updateData.status) {
      case 'in_transit':
        orderStatus = 'in_transit';
        break;
      case 'completed':
        orderStatus = 'delivered';
        break;
      case 'cancelled':
        orderStatus = 'cancelled';
        break;
      default:
        orderStatus = 'assigned';
    }
    
    await query(
      `UPDATE orders SET status = $1, updated_at = $2 WHERE id = $3`,
      [orderStatus, new Date(), shipment.order_id]
    );
  }
  
  return result.rows.length ? result.rows[0] : null;
};

// Delete shipment
export const deleteShipment = async (id: string): Promise<boolean> => {
  // First, get the shipment to get the order_id
  const shipment = await getShipmentById(id);
  if (!shipment) {
    return false;
  }
  
  // Then, delete the shipment
  const result = await query('DELETE FROM shipments WHERE id = $1 RETURNING id', [id]);
  
  // If successful, update the order status back to 'pending'
  if (result.rows.length > 0 && shipment.status !== 'completed') {
    await query(
      `UPDATE orders SET status = 'pending', updated_at = $1 WHERE id = $2`,
      [new Date(), shipment.order_id]
    );
  }
  
  return result.rows.length > 0;
};

// Get shipment with detailed information
export const getShipmentWithDetails = async (id: string): Promise<any> => {
  const result = await query(`
    SELECT 
      s.*,
      o.order_number, o.customer_id, o.total_weight, o.total_volume,
      o.pickup_address, o.pickup_city, o.pickup_province, o.pickup_postal_code,
      o.delivery_address, o.delivery_city, o.delivery_province, o.delivery_postal_code,
      v.vehicle_number, v.type as vehicle_type, v.make, v.model,
      d.first_name as driver_first_name, d.last_name as driver_last_name, d.phone as driver_phone
    FROM shipments s
    JOIN orders o ON s.order_id = o.id
    JOIN vehicles v ON s.vehicle_id = v.id
    JOIN drivers d ON s.driver_id = d.id
    WHERE s.id = $1
  `, [id]);
  
  return result.rows.length ? result.rows[0] : null;
};

// Get active shipments for a driver
export const getDriverActiveShipments = async (driverId: string): Promise<any[]> => {
  const result = await query(`
    SELECT 
      s.*,
      o.order_number, o.pickup_address, o.pickup_city, o.pickup_province, o.pickup_postal_code,
      o.delivery_address, o.delivery_city, o.delivery_province, o.delivery_postal_code,
      v.vehicle_number
    FROM shipments s
    JOIN orders o ON s.order_id = o.id
    JOIN vehicles v ON s.vehicle_id = v.id
    WHERE s.driver_id = $1 AND s.status IN ('planned', 'in_transit')
    ORDER BY s.planned_departure
  `, [driverId]);
  
  return result.rows;
};

// Get this week's shipments
export const getWeekShipments = async (): Promise<any[]> => {
  const result = await query(`
    SELECT 
      s.id, s.planned_departure, s.planned_arrival, s.status,
      o.order_number,
      o.pickup_city, o.pickup_province,
      o.delivery_city, o.delivery_province,
      v.vehicle_number,
      d.first_name as driver_first_name, d.last_name as driver_last_name
    FROM shipments s
    JOIN orders o ON s.order_id = o.id
    JOIN vehicles v ON s.vehicle_id = v.id
    JOIN drivers d ON s.driver_id = d.id
    WHERE 
      s.planned_departure >= DATE_TRUNC('week', CURRENT_DATE)
      AND s.planned_departure < DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '1 week'
    ORDER BY s.planned_departure
  `);
  
  return result.rows;
};
