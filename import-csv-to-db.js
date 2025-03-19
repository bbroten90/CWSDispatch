// Script to import CSV data into the database
const fs = require('fs');
const { Pool } = require('pg');
const path = require('path');
const csv = require('csv-parser');

// Load database connection details from .env file
require('dotenv').config({ path: path.join(__dirname, 'dispatch-dashboard/backend/.env') });

// Create a connection pool
const pool = new Pool({
  host: process.env.DB_HOST || '35.203.126.72',
  user: process.env.DB_USER || 'dispatch-admin',
  password: process.env.DB_PASSWORD || 'test123!!',
  database: process.env.DB_NAME || 'dispatch-dashboard',
  port: process.env.DB_PORT || 5432
});

// Path to your CSV file
const csvFilePath = process.argv[2] || 'AllProducts.csv';

// Function to create the temporary table
async function createTempTable() {
  console.log('Creating temporary table...');
  
  const createTableQuery = `
    CREATE TEMPORARY TABLE temp_product_data (
      location VARCHAR(100),
      customer_code VARCHAR(50),
      product_id VARCHAR(50),
      description TEXT,
      weight_per_unit DECIMAL(10,2),
      requires_heating BOOLEAN,
      do_not_ship BOOLEAN,
      storage_charge_per_pallet DECIMAL(10,2),
      handling_charge_per_pallet DECIMAL(10,2),
      unit VARCHAR(50),
      units_per_pallet INTEGER,
      quantity_on_hand INTEGER,
      cube_value_per_unit DECIMAL(10,2),
      pallet_stack_height INTEGER,
      hazard_pk INTEGER,
      track_by_lot BOOLEAN,
      str_group VARCHAR(100)
    );
  `;
  
  await pool.query(createTableQuery);
  console.log('Temporary table created successfully');
}

// Function to import data from CSV
async function importCsvData() {
  console.log(`Importing data from ${csvFilePath}...`);
  
  const results = [];
  
  // Read the CSV file
  return new Promise((resolve, reject) => {
    fs.createReadStream(csvFilePath)
      .pipe(csv())
      .on('data', (data) => {
        // Convert CSV data to match our temp table structure
        const row = {
          location: data.Location,
          customer_code: data.CustomerCode,
          product_id: data.ProductCode,
          description: data.Description,
          weight_per_unit: parseFloat(data.WeightPerUnit) || 0,
          requires_heating: data.Heat === 'True' || data.Heat === 'true',
          do_not_ship: data.DoNotShip === 'True' || data.DoNotShip === 'true',
          storage_charge_per_pallet: parseFloat(data.StorageChargePerPallet) || 0,
          handling_charge_per_pallet: parseFloat(data.HandlingChargePerPallet) || 0,
          unit: data.Unit,
          units_per_pallet: parseInt(data.UnitsPerPallet) || 0,
          quantity_on_hand: parseInt(data.QuantityOnHand) || 0,
          cube_value_per_unit: parseFloat(data.CubeValuePerUnit) || 0,
          pallet_stack_height: parseInt(data.PalletStackHeight) || 0,
          hazard_pk: data.HazardPK ? parseInt(data.HazardPK) : null,
          track_by_lot: data.TrackByLot === 'True' || data.TrackByLot === 'true',
          str_group: data.strGroup
        };
        
        results.push(row);
      })
      .on('end', () => {
        console.log(`Read ${results.length} rows from CSV`);
        resolve(results);
      })
      .on('error', (error) => {
        reject(error);
      });
  });
}

// Function to insert data into the temporary table
async function insertDataIntoTempTable(data) {
  console.log('Inserting data into temporary table...');
  
  // Use a transaction for better performance and error handling
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    // Insert data in batches for better performance
    const batchSize = 1000;
    let count = 0;
    
    for (let i = 0; i < data.length; i += batchSize) {
      const batch = data.slice(i, i + batchSize);
      
      for (const row of batch) {
        const insertQuery = `
          INSERT INTO temp_product_data (
            location, customer_code, product_id, description, weight_per_unit,
            requires_heating, do_not_ship, storage_charge_per_pallet, handling_charge_per_pallet,
            unit, units_per_pallet, quantity_on_hand, cube_value_per_unit, pallet_stack_height,
            hazard_pk, track_by_lot, str_group
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)
        `;
        
        const values = [
          row.location,
          row.customer_code,
          row.product_id,
          row.description,
          row.weight_per_unit,
          row.requires_heating,
          row.do_not_ship,
          row.storage_charge_per_pallet,
          row.handling_charge_per_pallet,
          row.unit,
          row.units_per_pallet,
          row.quantity_on_hand,
          row.cube_value_per_unit,
          row.pallet_stack_height,
          row.hazard_pk,
          row.track_by_lot,
          row.str_group
        ];
        
        await client.query(insertQuery, values);
        count++;
      }
      
      console.log(`Inserted ${count} rows so far...`);
    }
    
    await client.query('COMMIT');
    console.log(`Successfully inserted ${count} rows into temporary table`);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// Function to update existing products and insert new ones
async function updateAndInsertProducts() {
  console.log('Updating existing products and inserting new ones...');
  
  // Update existing products
  const updateQuery = `
    UPDATE products p
    SET 
      warehouse_id = (SELECT warehouse_id FROM location_warehouse_mapping WHERE location_name = t.location),
      customer_code = t.customer_code,
      quantity_on_hand = t.quantity_on_hand,
      manufacturer_id = t.customer_code::integer, -- Convert customer_code to integer for manufacturer_id
      weight_kg = t.weight_per_unit / 2.20462, -- Convert weight from lbs to kg for storage
      volume_cubic_m = t.cube_value_per_unit,
      requires_heating = t.requires_heating,
      do_not_ship = t.do_not_ship,
      storage_charge_per_pallet = t.storage_charge_per_pallet,
      handling_charge_per_pallet = t.handling_charge_per_pallet,
      unit = t.unit,
      units_per_pallet = t.units_per_pallet,
      pallet_stack_height = t.pallet_stack_height,
      track_by_lot = t.track_by_lot,
      str_group = t.str_group,
      updated_at = CURRENT_TIMESTAMP
    FROM temp_product_data t
    WHERE p.product_id = t.product_id;
  `;
  
  const updateResult = await pool.query(updateQuery);
  console.log(`Updated ${updateResult.rowCount} existing products`);
  
  // Insert new products
  const insertQuery = `
    INSERT INTO products (
      product_id, name, description, weight_kg, volume_cubic_m,
      requires_refrigeration, requires_heating, is_dangerous_good, 
      warehouse_id, customer_code, quantity_on_hand,
      manufacturer_id, do_not_ship, storage_charge_per_pallet,
      handling_charge_per_pallet, unit, units_per_pallet,
      pallet_stack_height, track_by_lot, str_group
    )
    SELECT 
      t.product_id,
      t.description, -- Use description as name if no separate name field
      t.description,
      t.weight_per_unit / 2.20462, -- Convert weight from lbs to kg
      t.cube_value_per_unit,
      false, -- Assuming no refrigeration by default
      t.requires_heating,
      false, -- Assuming not dangerous by default
      (SELECT warehouse_id FROM location_warehouse_mapping WHERE location_name = t.location),
      t.customer_code,
      t.quantity_on_hand,
      t.customer_code::integer, -- Convert customer_code to integer for manufacturer_id
      t.do_not_ship,
      t.storage_charge_per_pallet,
      t.handling_charge_per_pallet,
      t.unit,
      t.units_per_pallet,
      t.pallet_stack_height,
      t.track_by_lot,
      t.str_group
    FROM temp_product_data t
    WHERE NOT EXISTS (
      SELECT 1 FROM products p WHERE p.product_id = t.product_id
    );
  `;
  
  const insertResult = await pool.query(insertQuery);
  console.log(`Inserted ${insertResult.rowCount} new products`);
}

// Function to drop the temporary table
async function dropTempTable() {
  console.log('Dropping temporary table...');
  await pool.query('DROP TABLE IF EXISTS temp_product_data;');
  console.log('Temporary table dropped');
}

// Main function to run the import process
async function importCsvToDb() {
  try {
    console.log('Starting CSV import process...');
    
    // Create the temporary table
    await createTempTable();
    
    // Import data from CSV
    const data = await importCsvData();
    
    // Insert data into the temporary table
    await insertDataIntoTempTable(data);
    
    // Update existing products and insert new ones
    await updateAndInsertProducts();
    
    // Drop the temporary table
    await dropTempTable();
    
    console.log('CSV import process completed successfully!');
  } catch (error) {
    console.error('Error importing CSV data:', error);
  } finally {
    // Close the connection pool
    await pool.end();
  }
}

// Run the import process
importCsvToDb();
