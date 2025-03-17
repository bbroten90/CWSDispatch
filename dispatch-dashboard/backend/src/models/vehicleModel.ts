// src/models/vehicleModel.ts
import { query } from '../config/backend-database-connection';
import { v4 as uuidv4 } from 'uuid';

export interface Vehicle {
  id: string;
  vehicle_number: string;
  type: string;
  make: string;
  model: string;
  year: number;
  vin: string;
  plate_number: string;
  capacity_weight: number;
  capacity_volume: number;
  status: 'active' | 'maintenance' | 'out_of_service';
  notes?: string;
  last_maintenance_date?: Date;
  next_maintenance_date?: Date;
  created_at: Date;
  updated_at: Date;
}

export interface CreateVehicleDto {
  vehicle_number: string;
  type: string;
  make: string;
  model: string;
  year: number;
  vin: string;
  plate_number: string;
  capacity_weight: number;
  capacity_volume: number;
  status: 'active' | 'maintenance' | 'out_of_service';
  notes?: string;
  last_maintenance_date?: Date;
  next_maintenance_date?: Date;
}

export interface UpdateVehicleDto {
  type?: string;
  make?: string;
  model?: string;
  year?: number;
  plate_number?: string;
  capacity_weight?: number;
  capacity_volume?: number;
  status?: 'active' | 'maintenance' | 'out_of_service';
  notes?: string;
  last_maintenance_date?: Date;
  next_maintenance_date?: Date;
}

export interface VehicleFilters {
  status?: string;
  type?: string;
  available?: boolean;
}

// Create a new vehicle
export const createVehicle = async (vehicleData: CreateVehicleDto): Promise<Vehicle> => {
  const id = uuidv4();
  const now = new Date();
  
  const result = await query(
    `INSERT INTO vehicles (
      id, vehicle_number, type, make, model, year, vin, plate_number,
      capacity_weight, capacity_volume, status, notes,
      last_maintenance_date, next_maintenance_date, created_at, updated_at
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16) 
    RETURNING *`,
    [
      id, vehicleData.vehicle_number, vehicleData.type, vehicleData.make,
      vehicleData.model, vehicleData.year, vehicleData.vin, vehicleData.plate_number,
      vehicleData.capacity_weight, vehicleData.capacity_volume, vehicleData.status, 
      vehicleData.notes || null, vehicleData.last_maintenance_date || null, 
      vehicleData.next_maintenance_date || null, now, now
    ]
  );
  
  return result.rows[0];
};

// Get all vehicles with optional filters
export const getVehicles = async (filters?: VehicleFilters): Promise<Vehicle[]> => {
  let queryText = 'SELECT * FROM vehicles';
  const queryParams: any[] = [];
  
  if (filters) {
    const conditions: string[] = [];
    
    if (filters.status) {
      conditions.push(`status = $${queryParams.length + 1}`);
      queryParams.push(filters.status);
    }
    
    if (filters.type) {
      conditions.push(`type = $${queryParams.length + 1}`);
      queryParams.push(filters.type);
    }
    
    if (filters.available === true) {
      // This assumes a vehicle is available if it's active and not assigned to an active shipment
      conditions.push(`status = 'active' AND id NOT IN (
        SELECT vehicle_id FROM shipments
        WHERE status IN ('planned', 'in_transit')
      )`);
    }
    
    if (conditions.length > 0) {
      queryText += ' WHERE ' + conditions.join(' AND ');
    }
  }
  
  queryText += ' ORDER BY vehicle_number';
  
  const result = await query(queryText, queryParams);
  return result.rows;
};

// Get vehicle by ID
export const getVehicleById = async (id: string): Promise<Vehicle | null> => {
  const result = await query('SELECT * FROM vehicles WHERE id = $1', [id]);
  return result.rows.length ? result.rows[0] : null;
};

// Update vehicle
export const updateVehicle = async (id: string, updateData: UpdateVehicleDto): Promise<Vehicle | null> => {
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
    return getVehicleById(id);
  }
  
  const queryText = `
    UPDATE vehicles
    SET ${updates.join(', ')} 
    WHERE id = $1 
    RETURNING *
  `;
  
  const result = await query(queryText, queryParams);
  return result.rows.length ? result.rows[0] : null;
};

// Delete vehicle
export const deleteVehicle = async (id: string): Promise<boolean> => {
  const result = await query('DELETE FROM vehicles WHERE id = $1 RETURNING id', [id]);
  return result.rows.length > 0;
};

// Get vehicle with current assignment status
export const getVehicleWithAssignmentStatus = async (id: string): Promise<any> => {
  const result = await query(`
    SELECT v.*, 
           s.id as current_shipment_id, 
           s.status as shipment_status,
           o.id as order_id,
           o.order_number,
           d.id as driver_id,
           d.first_name as driver_first_name,
           d.last_name as driver_last_name
    FROM vehicles v
    LEFT JOIN shipments s ON v.id = s.vehicle_id AND s.status IN ('planned', 'in_transit')
    LEFT JOIN orders o ON s.order_id = o.id
    LEFT JOIN drivers d ON s.driver_id = d.id
    WHERE v.id = $1
  `, [id]);
  
  return result.rows.length ? result.rows[0] : null;
};

// Get vehicle types and counts
export const getVehicleTypeStats = async (): Promise<any[]> => {
  const result = await query(`
    SELECT 
      type,
      COUNT(*) as total,
      SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active,
      SUM(CASE WHEN status = 'maintenance' THEN 1 ELSE 0 END) as in_maintenance,
      SUM(CASE WHEN status = 'out_of_service' THEN 1 ELSE 0 END) as out_of_service
    FROM vehicles
    GROUP BY type
    ORDER BY total DESC
  `);
  
  return result.rows;
};

// Get vehicles due for maintenance
export const getVehiclesDueForMaintenance = async (days: number = 7): Promise<Vehicle[]> => {
  const result = await query(`
    SELECT * FROM vehicles
    WHERE next_maintenance_date IS NOT NULL
    AND next_maintenance_date BETWEEN CURRENT_DATE AND (CURRENT_DATE + interval '${days} days')
    ORDER BY next_maintenance_date
  `);
  
  return result.rows;
};
