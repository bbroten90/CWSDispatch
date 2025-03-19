// Script to run all SQL scripts to update the database schema and data
const fs = require('fs');
const { Pool } = require('pg');
const path = require('path');

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

// SQL files to run in order
const sqlFiles = [
  'add-stock-columns.sql',
  'update-warehouses.sql',
  'update-manufacturers.sql',
  'update-products.sql'
];

async function runSqlFile(filePath) {
  console.log(`Running SQL file: ${filePath}`);
  try {
    const sql = fs.readFileSync(filePath, 'utf8');
    const result = await pool.query(sql);
    console.log(`Successfully executed ${filePath}`);
    return result;
  } catch (error) {
    console.error(`Error executing ${filePath}:`, error);
    throw error;
  }
}

async function updateDatabase() {
  try {
    console.log('Starting database update...');
    
    // Run each SQL file in order
    for (const file of sqlFiles) {
      await runSqlFile(file);
    }
    
    console.log('Database update completed successfully!');
  } catch (error) {
    console.error('Database update failed:', error);
  } finally {
    // Close the connection pool
    await pool.end();
  }
}

// Run the update
updateDatabase();
