// test-import.js
const { Pool } = require('pg');
require('dotenv').config();

console.log('Environment variables:');
console.log('DB_HOST:', process.env.DB_HOST);
console.log('DB_USER:', process.env.DB_USER);
console.log('DB_NAME:', process.env.DB_NAME);
console.log('DB_PORT:', process.env.DB_PORT);

// Try to import the database connection
try {
  console.log('Trying to import backend-database-connection.ts...');
  const dbConnection = require('./src/config/backend-database-connection');
  console.log('Successfully imported backend-database-connection.ts');
  console.log('dbConnection:', dbConnection);
} catch (error) {
  console.error('Error importing backend-database-connection.ts:', error.message);
}

// Try to import the models
try {
  console.log('Trying to import driverModel.ts...');
  const driverModel = require('./src/models/driverModel');
  console.log('Successfully imported driverModel.ts');
  console.log('driverModel:', Object.keys(driverModel));
} catch (error) {
  console.error('Error importing driverModel.ts:', error.message);
}

// Try to import the controllers
try {
  console.log('Trying to import vehicleControllers.ts...');
  const vehicleControllers = require('./src/controllers/vehicleControllers');
  console.log('Successfully imported vehicleControllers.ts');
  console.log('vehicleControllers:', Object.keys(vehicleControllers));
} catch (error) {
  console.error('Error importing vehicleControllers.ts:', error.message);
}

// Try to import the routes
try {
  console.log('Trying to import vehicleRoutes.ts...');
  const vehicleRoutes = require('./src/routes/vehicleRoutes');
  console.log('Successfully imported vehicleRoutes.ts');
  console.log('vehicleRoutes:', vehicleRoutes);
} catch (error) {
  console.error('Error importing vehicleRoutes.ts:', error.message);
}
