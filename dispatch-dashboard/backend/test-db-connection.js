// test-db-connection.js
const { Pool } = require('pg');
require('dotenv').config();

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

// Test database connection
pool.connect((err, client, release) => {
  if (err) {
    console.error('Error connecting to the database:', err.message);
    return;
  }
  
  console.log('Successfully connected to the database');
  
  // Test query
  client.query('SELECT NOW()', (err, result) => {
    release();
    
    if (err) {
      console.error('Error executing query:', err.message);
      return;
    }
    
    console.log('Database time:', result.rows[0].now);
    
    // Test customers table
    client.query('SELECT COUNT(*) FROM customers', (err, result) => {
      if (err) {
        console.error('Error querying customers table:', err.message);
      } else {
        console.log('Number of customers:', result.rows[0].count);
      }
      
      // Test products table
      client.query('SELECT COUNT(*) FROM products', (err, result) => {
        if (err) {
          console.error('Error querying products table:', err.message);
        } else {
          console.log('Number of products:', result.rows[0].count);
        }
        
        // Test hazards table
        client.query('SELECT COUNT(*) FROM hazards', (err, result) => {
          if (err) {
            console.error('Error querying hazards table:', err.message);
          } else {
            console.log('Number of hazards:', result.rows[0].count);
          }
          
          // Close the pool
          pool.end(() => {
            console.log('Database pool has ended');
          });
        });
      });
    });
  });
});
