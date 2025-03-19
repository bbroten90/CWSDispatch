// src/models/shipmentModel.ts
import { query } from '../config/backend-database-connection';
import { v4 as uuidv4 } from 'uuid';

export interface Shipment {
  shipment_id: number;
  shipment_date: Date;
  origin_warehouse_id: number;
  truck_id: number;
  trailer_id?: number;
  driver_id: number;
  status: string;
  total_distance_km: number;
  estimated_start_time: Date;
  actual_start_time?: Date;
  estimated_completion_time: Date;
  actual_completion_time?: Date;
  total_weight_kg: number;
  total_volume_cubic_m: number;
  total_revenue: number;
  notes?: string;
  created_at: Date;
  updated_at: Date;
}

export interface CreateShipmentDto {
  shipment_date: Date;
  origin_warehouse_id: number;
  truck_id: number;
  trailer_id?: number;
  driver_id: number;
  total_distance_km: number;
  estimated_start_time: Date;
  estimated_completion_time: Date;
  total_weight_kg: number;
  total_volume_cubic_m: number;
  total_revenue: number;
  notes?: string;
}

export interface UpdateShipmentDto {
  shipment_date?: Date;
  origin_warehouse_id?: number;
  truck_id?: number;
  trailer_id?: number;
  driver_id?: number;
  status?: string;
  total_distance_km?: number;
  estimated_start_time?: Date;
  actual_start_time?: Date;
  estimated_completion_time?: Date;
  actual_completion_time?: Date;
  total_weight_kg?: number;
  total_volume_cubic_m?: number;
  total_revenue?: number;
  notes?: string;
}

export interface ShipmentFilters {
  status?: string;
  driver_id?: number;
  truck_id?: number;
  trailer_id?: number;
  origin_warehouse_id?: number;
  start_date?: Date;
  end_date?: Date;
}

// Create a new shipment
export const createShipment = async (shipmentData: CreateShipmentDto): Promise<Shipment> => {
  const now = new Date();
  
  const result = await query(
    `INSERT INTO shipments (
      shipment_date, origin_warehouse_id, truck_id, trailer_id, driver_id, 
      total_distance_km, estimated_start_time, estimated_completion_time,
      total_weight_kg, total_volume_cubic_m, total_revenue,
      status, notes, created_at, updated_at
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15) 
    RETURNING *`,
    [
      shipmentData.shipment_date, 
      shipmentData.origin_warehouse_id, 
      shipmentData.truck_id, 
      shipmentData.trailer_id || null, 
      shipmentData.driver_id,
      shipmentData.total_distance_km, 
      shipmentData.estimated_start_time, 
      shipmentData.estimated_completion_time,
      shipmentData.total_weight_kg, 
      shipmentData.total_volume_cubic_m, 
      shipmentData.total_revenue,
      'PLANNED', 
      shipmentData.notes || null, 
      now, 
      now
    ]
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
    
    if (filters.truck_id) {
      conditions.push(`truck_id = $${queryParams.length + 1}`);
      queryParams.push(filters.truck_id);
    }
    
    if (filters.trailer_id) {
      conditions.push(`trailer_id = $${queryParams.length + 1}`);
      queryParams.push(filters.trailer_id);
    }
    
    if (filters.origin_warehouse_id) {
      conditions.push(`origin_warehouse_id = $${queryParams.length + 1}`);
      queryParams.push(filters.origin_warehouse_id);
    }
    
    if (filters.start_date) {
      conditions.push(`shipment_date >= $${queryParams.length + 1}`);
      queryParams.push(filters.start_date);
    }
    
    if (filters.end_date) {
      conditions.push(`shipment_date <= $${queryParams.length + 1}`);
      queryParams.push(filters.end_date);
    }
    
    if (conditions.length > 0) {
      queryText += ' WHERE ' + conditions.join(' AND ');
    }
  }
  
  queryText += ' ORDER BY shipment_date';
  
  const result = await query(queryText, queryParams);
  return result.rows;
};

// Get shipment by ID
export const getShipmentById = async (id: number): Promise<Shipment | null> => {
  const result = await query('SELECT * FROM shipments WHERE shipment_id = $1', [id]);
  return result.rows.length ? result.rows[0] : null;
};

// Update shipment
export const updateShipment = async (id: number, updateData: UpdateShipmentDto): Promise<Shipment | null> => {
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
    WHERE shipment_id = $1 
    RETURNING *
  `;
  
  const result = await query(queryText, queryParams);
  
  
  return result.rows.length ? result.rows[0] : null;
};

// Delete shipment
export const deleteShipment = async (id: number): Promise<boolean> => {
  // Delete the shipment
  const result = await query('DELETE FROM shipments WHERE shipment_id = $1 RETURNING shipment_id', [id]);
  
  return result.rows.length > 0;
};

// Get shipment with detailed information
export const getShipmentWithDetails = async (id: number): Promise<any> => {
  const result = await query(`
    SELECT 
      s.*,
      w.name as warehouse_name,
      v1.license_plate as truck_plate, v1.make as truck_make, v1.model as truck_model,
      v2.license_plate as trailer_plate,
      d.first_name as driver_first_name, d.last_name as driver_last_name, d.phone as driver_phone
    FROM shipments s
    JOIN warehouses w ON s.origin_warehouse_id = w.warehouse_id
    JOIN vehicles v1 ON s.truck_id = v1.vehicle_id
    LEFT JOIN vehicles v2 ON s.trailer_id = v2.vehicle_id
    JOIN drivers d ON s.driver_id = d.driver_id
    WHERE s.shipment_id = $1
  `, [id]);
  
  return result.rows.length ? result.rows[0] : null;
};

// Get active shipments for a driver
export const getDriverActiveShipments = async (driverId: number): Promise<any[]> => {
  const result = await query(`
    SELECT 
      s.*,
      w.name as warehouse_name,
      v1.license_plate as truck_plate
    FROM shipments s
    JOIN warehouses w ON s.origin_warehouse_id = w.warehouse_id
    JOIN vehicles v1 ON s.truck_id = v1.vehicle_id
    WHERE s.driver_id = $1 AND s.status IN ('PLANNED', 'LOADING', 'LOADED', 'IN_TRANSIT')
    ORDER BY s.shipment_date, s.estimated_start_time
  `, [driverId]);
  
  return result.rows;
};

// Get this week's shipments
export const getWeekShipments = async (): Promise<any[]> => {
  const result = await query(`
    SELECT 
      s.shipment_id, s.shipment_date, s.estimated_start_time, s.estimated_completion_time, s.status,
      w.name as warehouse_name,
      v1.license_plate as truck_plate,
      d.first_name as driver_first_name, d.last_name as driver_last_name
    FROM shipments s
    JOIN warehouses w ON s.origin_warehouse_id = w.warehouse_id
    JOIN vehicles v1 ON s.truck_id = v1.vehicle_id
    JOIN drivers d ON s.driver_id = d.driver_id
    WHERE 
      s.shipment_date >= DATE_TRUNC('week', CURRENT_DATE)
      AND s.shipment_date < DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '1 week'
    ORDER BY s.shipment_date, s.estimated_start_time
  `);
  
  return result.rows;
};
