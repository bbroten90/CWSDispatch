// insert-sample-warehouses.js
const { Pool } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

// Database configuration
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: parseInt(process.env.DB_PORT || '5432'),
  ssl: process.env.NODE_ENV === 'production' ? {
    rejectUnauthorized: false
  } : undefined,
});

// Sample warehouses data
const sampleWarehouses = [
  {
    warehouse_id: 'WH001',
    name: 'Main Distribution Center',
    address: '123 Main Street',
    city: 'Winnipeg',
    province: 'MB',
    postal_code: 'R3C 0A1',
    latitude: 49.8951,
    longitude: -97.1384,
    loading_capacity: 20,
    storage_capacity: 5000,
    is_active: true
  },
  {
    warehouse_id: 'WH002',
    name: 'East Regional Warehouse',
    address: '456 Oak Avenue',
    city: 'Toronto',
    province: 'ON',
    postal_code: 'M5V 2H1',
    latitude: 43.6532,
    longitude: -79.3832,
    loading_capacity: 15,
    storage_capacity: 3500,
    is_active: true
  },
  {
    warehouse_id: 'WH003',
    name: 'West Coast Facility',
    address: '789 Pacific Blvd',
    city: 'Vancouver',
    province: 'BC',
    postal_code: 'V6B 5Z6',
    latitude: 49.2827,
    longitude: -123.1207,
    loading_capacity: 12,
    storage_capacity: 2800,
    is_active: true
  }
];

// Insert warehouses into the database
async function insertWarehouses() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    // Check if warehouses table exists
    const tableCheck = await client.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'warehouses'
      );
    `);
    
    if (!tableCheck.rows[0].exists) {
      console.log('Creating warehouses table...');
      
      // Create warehouses table if it doesn't exist
      await client.query(`
        CREATE TABLE warehouses (
          warehouse_id VARCHAR(10) PRIMARY KEY,
          name VARCHAR(100) NOT NULL,
          address VARCHAR(255),
          city VARCHAR(100) NOT NULL,
          province VARCHAR(2) NOT NULL,
          postal_code VARCHAR(10),
          latitude DECIMAL(10, 6),
          longitude DECIMAL(10, 6),
          loading_capacity INTEGER,
          storage_capacity INTEGER,
          is_active BOOLEAN DEFAULT TRUE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `);
    }
    
    // Insert sample warehouses
    for (const warehouse of sampleWarehouses) {
      // Check if warehouse already exists
      const existingWarehouse = await client.query(
        'SELECT warehouse_id FROM warehouses WHERE warehouse_id = $1',
        [warehouse.warehouse_id]
      );
      
      if (existingWarehouse.rows.length === 0) {
        // Insert new warehouse
        await client.query(
          `INSERT INTO warehouses 
           (warehouse_id, name, address, city, province, postal_code, 
            latitude, longitude, loading_capacity, storage_capacity, is_active) 
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
          [
            warehouse.warehouse_id,
            warehouse.name,
            warehouse.address,
            warehouse.city,
            warehouse.province,
            warehouse.postal_code,
            warehouse.latitude,
            warehouse.longitude,
            warehouse.loading_capacity,
            warehouse.storage_capacity,
            warehouse.is_active
          ]
        );
        console.log(`Inserted warehouse: ${warehouse.name}`);
      } else {
        console.log(`Warehouse ${warehouse.name} already exists, skipping...`);
      }
    }
    
    await client.query('COMMIT');
    console.log('All warehouses inserted successfully');
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error inserting warehouses:', error);
  } finally {
    client.release();
    pool.end();
  }
}

// Run the insertion function
insertWarehouses();
