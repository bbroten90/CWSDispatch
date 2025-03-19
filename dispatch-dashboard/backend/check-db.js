// check-db.js
const { Pool } = require('pg');
require('dotenv').config();

console.log('Environment variables:');
console.log('DB_HOST:', process.env.DB_HOST);
console.log('DB_USER:', process.env.DB_USER);
console.log('DB_NAME:', process.env.DB_NAME);
console.log('DB_PORT:', process.env.DB_PORT);

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

console.log('Pool created');

// Test database connection
pool.on('connect', () => {
  console.log('Connected to the database');
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

async function checkDatabase() {
  console.log('Checking database...');
  
  try {
    // Check connection
    const connectionResult = await pool.query('SELECT NOW()');
    console.log('Database connection successful. Current time:', connectionResult.rows[0].now);
    
    // Check if warehouses table exists
    const tableCheckResult = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'warehouses'
      );
    `);
    
    console.log('Warehouses table exists:', tableCheckResult.rows[0].exists);
    
    if (tableCheckResult.rows[0].exists) {
      // Check warehouses count
      const warehousesCountResult = await pool.query('SELECT COUNT(*) FROM warehouses');
      console.log('Number of warehouses:', warehousesCountResult.rows[0].count);
      
      // Get warehouses
      const warehousesResult = await pool.query('SELECT * FROM warehouses');
      console.log('Warehouses:', JSON.stringify(warehousesResult.rows, null, 2));
    }
    
    // Check other tables
    const tablesResult = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    
    console.log('Tables in database:', tablesResult.rows.map(row => row.table_name));
    
  } catch (error) {
    console.error('Error checking database:', error);
  } finally {
    await pool.end();
    console.log('Pool has ended');
  }
}

checkDatabase();
