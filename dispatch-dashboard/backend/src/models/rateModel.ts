// src/models/rateModel.ts
import { query } from '../config/database';
import { v4 as uuidv4 } from 'uuid';

export interface Rate {
  id: string;
  origin_region: string; // First 3 characters of Canadian postal code (FSA)
  destination_region: string; // First 3 characters of Canadian postal code (FSA)
  rate_per_mile: number;
  rate_per_pound: number;
  base_rate: number;
  effective_date: Date;
  expiration_date?: Date;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface CreateRateDto {
  origin_region: string;
  destination_region: string;
  rate_per_mile: number;
  rate_per_pound: number;
  base_rate: number;
  effective_date: Date;
  expiration_date?: Date;
  is_active: boolean;
}

export interface UpdateRateDto {
  rate_per_mile?: number;
  rate_per_pound?: number;
  base_rate?: number;
  expiration_date?: Date;
  is_active?: boolean;
}

export interface RateFilters {
  origin_region?: string;
  destination_region?: string;
  is_active?: boolean;
  effective_after?: Date;
  expiring_before?: Date;
}

// Create a new rate
export const createRate = async (rateData: CreateRateDto): Promise<Rate> => {
  const id = uuidv4();
  const now = new Date();
  
  const result = await query(
    `INSERT INTO rates (
      id, origin_region, destination_region, 
      rate_per_mile, rate_per_pound, base_rate,
      effective_date, expiration_date, is_active, created_at, updated_at
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) 
    RETURNING *`,
    [
      id, rateData.origin_region, rateData.destination_region,
      rateData.rate_per_mile, rateData.rate_per_pound, rateData.base_rate,
      rateData.effective_date, rateData.expiration_date || null, rateData.is_active, now, now
    ]
  );
  
  return result.rows[0];
};

// Get all rates with optional filters
export const getRates = async (filters?: RateFilters): Promise<Rate[]> => {
  let queryText = 'SELECT * FROM rates';
  const queryParams: any[] = [];
  
  if (filters) {
    const conditions: string[] = [];
    
    if (filters.origin_region) {
      conditions.push(`origin_region = $${queryParams.length + 1}`);
      queryParams.push(filters.origin_region);
    }
    
    if (filters.destination_region) {
      conditions.push(`destination_region = $${queryParams.length + 1}`);
      queryParams.push(filters.destination_region);
    }
    
    if (filters.is_active !== undefined) {
      conditions.push(`is_active = $${queryParams.length + 1}`);
      queryParams.push(filters.is_active);
    }
    
    if (filters.effective_after) {
      conditions.push(`effective_date >= $${queryParams.length + 1}`);
      queryParams.push(filters.effective_after);
    }
    
    if (filters.expiring_before) {
      conditions.push(`(expiration_date IS NULL OR expiration_date <= $${queryParams.length + 1})`);
      queryParams.push(filters.expiring_before);
    }
    
    if (conditions.length > 0) {
      queryText += ' WHERE ' + conditions.join(' AND ');
    }
  }
  
  queryText += ' ORDER BY origin_region, destination_region, effective_date DESC';
  
  const result = await query(queryText, queryParams);
  return result.rows;
};

// Get rate by ID
export const getRateById = async (id: string): Promise<Rate | null> => {
  const result = await query('SELECT * FROM rates WHERE id = $1', [id]);
  return result.rows.length ? result.rows[0] : null;
};

// Update rate
export const updateRate = async (id: string, updateData: UpdateRateDto): Promise<Rate | null> => {
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
    return getRateById(id);
  }
  
  const queryText = `
    UPDATE rates 
    SET ${updates.join(', ')} 
    WHERE id = $1 
    RETURNING *
  `;
  
  const result = await query(queryText, queryParams);
  return result.rows.length ? result.rows[0] : null;
};

// Delete rate
export const deleteRate = async (id: string): Promise<boolean> => {
  const result = await query('DELETE FROM rates WHERE id = $1 RETURNING id', [id]);
  return result.rows.length > 0;
};

// Find applicable rate
export const findApplicableRate = async (
  originPostalCode: string,
  destinationPostalCode: string,
  date: Date = new Date()
): Promise<Rate | null> => {
  // Extract FSA (first three characters) from postal codes
  const originRegion = originPostalCode.substr(0, 3).toUpperCase();
  const destinationRegion = destinationPostalCode.substr(0, 3).toUpperCase();
  
  const result = await query(`
    SELECT * FROM rates
    WHERE origin_region = $1
      AND destination_region = $2
      AND effective_date <= $3
      AND (expiration_date IS NULL OR expiration_date >= $3)
      AND is_active = true
    ORDER BY effective_date DESC
    LIMIT 1
  `, [originRegion, destinationRegion, date]);
  
  return result.rows.length ? result.rows[0] : null;
};

// Calculate shipping cost
export const calculateShippingCost = async (
  originPostalCode: string,
  destinationPostalCode: string,
  weight: number,
  distanceMiles: number,
  date: Date = new Date()
): Promise<{ cost: number; rate: Rate | null; }> => {
  const rate = await findApplicableRate(originPostalCode, destinationPostalCode, date);
  
  if (!rate) {
    return { cost: 0, rate: null };
  }
  
  const cost = rate.base_rate + (rate.rate_per_mile * distanceMiles) + (rate.rate_per_pound * weight);
  
  return { cost, rate };
};
