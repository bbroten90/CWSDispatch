// src/controllers/optimize.js
const { spawn } = require('child_process');
const path = require('path');
const { Pool } = require('pg');
const fs = require('fs');
const logger = require('../utils/logger');

// Configure PostgreSQL connection
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432,
});

/**
 * Run the load optimization process for a specific date
 */
const runOptimization = async (req, res) => {
  const { date } = req.query;
  
  // Default to today if no date is provided
  const optimizationDate = date ? new Date(date) : new Date();
  
  try {
    // Format date for Python script
    const formattedDate = optimizationDate.toISOString().split('T')[0];
    
    // Log the optimization request
    logger.info(`Starting load optimization for date: ${formattedDate}`);
    
    // Record optimization start in database
    const startResult = await pool.query(
      `INSERT INTO optimization_logs
       (optimization_type, input_parameters, success, created_at)
       VALUES ($1, $2, $3, $4)
       RETURNING log_id`,
      [
        'LOADING_ROUTING',
        JSON.stringify({ date: formattedDate, requestedBy: req.user?.username || 'system' }),
        false, // Will be updated to true when complete
        new Date()
      ]
    );
    
    const logId = startResult.rows[0].log_id;
    
    // Call the Python script as a separate process
    const pythonScriptPath = path.join(__dirname, '../scripts/load_optimizer.py');
    
    // Ensure the script exists
    if (!fs.existsSync(pythonScriptPath)) {
      throw new Error(`Optimization script not found at path: ${pythonScriptPath}`);
    }
    
    const pythonProcess = spawn('python', [
      pythonScriptPath,
      '--date', formattedDate,
      '--log-id', logId.toString()
    ]);
    
    // Send immediate response since optimization can take time
    res.status(202).json({
      message: 'Optimization process started',
      date: formattedDate,
      logId: logId,
      status: 'RUNNING'
    });
    
    // Handle Python script output (optional)
    pythonProcess.stdout.on('data', (data) => {
      logger.info(`Optimizer output: ${data}`);
    });
    
    pythonProcess.stderr.on('data', (data) => {
      logger.error(`Optimizer error: ${data}`);
    });
    
    // Handle process completion
    pythonProcess.on('close', async (code) => {
      try {
        if (code === 0) {
          logger.info(`Optimization process completed successfully for date: ${formattedDate}`);
          
          // Update log record to mark as success
          await pool.query(
            `UPDATE optimization_logs
             SET success = true, 
                 output_result = $1,
                 execution_time_ms = EXTRACT(EPOCH FROM (now() - created_at)) * 1000
             WHERE log_id = $2`,
            [
              JSON.stringify({ status: 'COMPLETED', exitCode: code }),
              logId
            ]
          );
        } else {
          logger.error(`Optimization process failed with code ${code} for date: ${formattedDate}`);
          
          // Update log record to mark as failed
          await pool.query(
            `UPDATE optimization_logs
             SET error_message = $1,
                 execution_time_ms = EXTRACT(EPOCH FROM (now() - created_at)) * 1000
             WHERE log_id = $2`,
            [
              `Process exited with code ${code}`,
              logId
            ]
          );
        }
      } catch (err) {
        logger.error(`Error updating optimization log: ${err.message}`);
      }
    });
    
  } catch (err) {
    logger.error(`Error running optimization: ${err.message}`);
    
    res.status(500).json({
      error: 'Failed to start optimization process',
      details: err.message
    });
  }
};

/**
 * Get the results of a previous optimization run
 */
const getOptimizationResults = async (req, res) => {
  const { date, logId } = req.query;
  
  try {
    let query = `
      SELECT s.shipment_id, s.shipment_date, s.origin_warehouse_id, w.name as warehouse_name,
             s.truck_id, s.trailer_id, s.driver_id, 
             CONCAT(d.first_name, ' ', d.last_name) as driver_name,
             s.status, s.total_distance_km, s.total_weight_kg, s.total_revenue,
             s.estimated_start_time, s.estimated_completion_time,
             COUNT(so.order_id) as order_count
      FROM shipments s
      JOIN warehouses w ON s.origin_warehouse_id = w.warehouse_id
      LEFT JOIN drivers d ON s.driver_id = d.driver_id
      LEFT JOIN shipment_orders so ON s.shipment_id = so.shipment_id
    `;
    
    const queryParams = [];
    let whereClause = '';
    
    if (date) {
      queryParams.push(date);
      whereClause += ' WHERE s.shipment_date = $1';
    }
    
    if (logId) {
      const logResult = await pool.query(
        'SELECT input_parameters FROM optimization_logs WHERE log_id = $1',
        [logId]
      );
      
      if (logResult.rows.length > 0) {
        const params = logResult.rows[0].input_parameters;
        if (params && params.date) {
          queryParams.push(params.date);
          whereClause += whereClause ? ' AND s.shipment_date = $2' : ' WHERE s.shipment_date = $1';
        }
      }
    }
    
    query += whereClause + ' GROUP BY s.shipment_id, w.name, d.first_name, d.last_name ORDER BY s.shipment_id';
    
    const result = await pool.query(query, queryParams);
    
    // Get optimization log if logId is provided
    let optimizationLog = null;
    if (logId) {
      const logResult = await pool.query(
        'SELECT * FROM optimization_logs WHERE log_id = $1',
        [logId]
      );
      
      if (logResult.rows.length > 0) {
        optimizationLog = logResult.rows[0];
      }
    }
    
    res.status(200).json({
      results: result.rows,
      optimizationLog,
      count: result.rows.length
    });
    
  } catch (err) {
    logger.error(`Error getting optimization results: ${err.message}`);
    
    res.status(500).json({
      error: 'Failed to retrieve optimization results',
      details: err.message
    });
  }
};

/**
 * Get optimization log history
 */
const getOptimizationLogs = async (req, res) => {
  const { limit, offset } = req.query;
  
  try {
    const result = await pool.query(
      `SELECT log_id, optimization_type, input_parameters, output_result, 
              execution_time_ms, success, error_message, created_at
       FROM optimization_logs
       ORDER BY created_at DESC
       LIMIT $1 OFFSET $2`,
      [limit || 20, offset || 0]
    );
    
    // Get total count for pagination
    const countResult = await pool.query('SELECT COUNT(*) as total FROM optimization_logs');
    
    res.status(200).json({
      logs: result.rows,
      pagination: {
        total: parseInt(countResult.rows[0].total),
        limit: parseInt(limit || 20),
        offset: parseInt(offset || 0)
      }
    });
    
  } catch (err) {
    logger.error(`Error getting optimization logs: ${err.message}`);
    
    res.status(500).json({
      error: 'Failed to retrieve optimization logs',
      details: err.message
    });
  }
};

module.exports = {
  runOptimization,
  getOptimizationResults,
  getOptimizationLogs
};
