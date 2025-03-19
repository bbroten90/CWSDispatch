// src/controllers/rates.js
const { Pool } = require('pg');
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
 * Calculate shipping rate based on origin, destination, weight, and customer
 */
const calculateRate = async (req, res) => {
  const { originWarehouseId, destinationCity, destinationProvince, weightLbs, isTruckload, customerName } = req.body;
  
  // Input validation
  if (!originWarehouseId) {
    return res.status(400).json({ error: 'Origin warehouse is required' });
  }
  
  if (!destinationCity) {
    return res.status(400).json({ error: 'Destination city is required' });
  }
  
  if (!destinationProvince) {
    return res.status(400).json({ error: 'Destination province is required' });
  }
  
  if (!customerName) {
    return res.status(400).json({ error: 'Customer name is required' });
  }
  
  if (!isTruckload && (!weightLbs || weightLbs <= 0)) {
    return res.status(400).json({ error: 'Valid weight is required for non-truckload shipments' });
  }
  
  try {
    // Query the rate tables for this route with specific customer
    const rateQuery = `
      SELECT * FROM rate_tables 
      WHERE origin_warehouse_id = $1 
      AND LOWER(destination_city) = LOWER($2) 
      AND LOWER(destination_province) = LOWER($3)
      AND LOWER(customer_name) = LOWER($4)
      LIMIT 1
    `;
    
    const rateResult = await pool.query(rateQuery, [
      originWarehouseId,
      destinationCity,
      destinationProvince,
      customerName
    ]);
    
    // If no rate found with specific city, try with just the province and customer
    if (rateResult.rows.length === 0) {
      const provinceRateQuery = `
        SELECT * FROM rate_tables 
        WHERE origin_warehouse_id = $1 
        AND destination_city = '' 
        AND LOWER(destination_province) = LOWER($2)
        AND LOWER(customer_name) = LOWER($3)
        LIMIT 1
      `;
      
      const provinceRateResult = await pool.query(provinceRateQuery, [
        originWarehouseId,
        destinationProvince,
        customerName
      ]);
      
      // If still no rate, try default rates without specific customer
      if (provinceRateResult.rows.length === 0) {
        const defaultRateQuery = `
          SELECT * FROM rate_tables 
          WHERE origin_warehouse_id = $1 
          AND LOWER(destination_city) = LOWER($2) 
          AND LOWER(destination_province) = LOWER($3)
          AND (customer_name = '' OR customer_name IS NULL)
          LIMIT 1
        `;
        
        const defaultRateResult = await pool.query(defaultRateQuery, [
          originWarehouseId,
          destinationCity,
          destinationProvince
        ]);
        
        // If still no rate, check for province-only default rate
        if (defaultRateResult.rows.length === 0) {
          const defaultProvinceRateQuery = `
            SELECT * FROM rate_tables 
            WHERE origin_warehouse_id = $1 
            AND destination_city = '' 
            AND LOWER(destination_province) = LOWER($2)
            AND (customer_name = '' OR customer_name IS NULL)
            LIMIT 1
          `;
          
          const defaultProvinceRateResult = await pool.query(defaultProvinceRateQuery, [
            originWarehouseId,
            destinationProvince
          ]);
          
          if (defaultProvinceRateResult.rows.length === 0) {
            return res.status(404).json({ 
              error: 'Rate not found', 
              message: `No shipping rate found for ${originWarehouseId} to ${destinationCity}, ${destinationProvince} for customer ${customerName}` 
            });
          }
          
          rateResult.rows = defaultProvinceRateResult.rows;
        } else {
          rateResult.rows = defaultRateResult.rows;
        }
      } else {
        rateResult.rows = provinceRateResult.rows;
      }
    }
    
    const rateData = rateResult.rows[0];
    
    // For truckload rates, just return the TL rate
    if (isTruckload) {
      if (!rateData.tl_rate) {
        return res.status(404).json({ 
          error: 'Truckload rate not found', 
          message: `No truckload shipping rate found for this route` 
        });
      }
      
      return res.status(200).json({
        isTruckload: true,
        rate: null, // No per-pound rate for truckload
        totalCost: parseFloat(rateData.tl_rate),
        weightCategory: 'Truckload',
        rateDetails: {
          originWarehouseId,
          destinationCity,
          destinationProvince,
          customerName
        }
      });
    }
    
    // For regular LTL shipments, calculate based on weight
    let rate;
    let weightCategory;
    
    // Determine which weight bracket the shipment falls into
    if (weightLbs < 2000) {
      rate = parseFloat(rateData.weight_per_0_1999lbs);
      weightCategory = '0-1,999 lbs';
    } else if (weightLbs < 5000) {
      rate = parseFloat(rateData.weight_per_2000_4999lbs);
      weightCategory = '2,000-4,999 lbs';
    } else if (weightLbs < 10000) {
      rate = parseFloat(rateData.weight_per_5000_9999lbs);
      weightCategory = '5,000-9,999 lbs';
    } else if (weightLbs < 20000) {
      rate = parseFloat(rateData.weight_per_10000_19999lbs);
      weightCategory = '10,000-19,999 lbs';
    } else if (weightLbs < 30000) {
      rate = parseFloat(rateData.weight_per_20000_29999lbs);
      weightCategory = '20,000-29,999 lbs';
    } else if (weightLbs < 40000) {
      rate = parseFloat(rateData.weight_per_30000_39999lbs);
      weightCategory = '30,000-39,999 lbs';
    } else {
      rate = parseFloat(rateData.weight_over_4000lbs);
      weightCategory = '40,000+ lbs';
    }
    
    // Calculate total cost
    const totalCost = weightLbs * rate;
    
    // Check if truckload would be cheaper
    const tlRate = parseFloat(rateData.tl_rate || 0);
    if (tlRate > 0 && totalCost > tlRate) {
      return res.status(200).json({
        isTruckload: true,
        rate: null,
        totalCost: tlRate,
        weightCategory: 'Truckload (cheaper than LTL)',
        originalLtlCost: totalCost,
        rateDetails: {
          originWarehouseId,
          destinationCity,
          destinationProvince,
          customerName
        }
      });
    }
    
    // Return the calculated rate
    res.status(200).json({
      isTruckload: false,
      rate,
      totalCost,
      weightCategory,
      weightLbs,
      rateDetails: {
        originWarehouseId,
        destinationCity,
        destinationProvince,
        customerName,
        minWeightLb: parseFloat(rateData.min_weight_lb)
      }
    });
    
  } catch (err) {
    logger.error(`Error calculating rate: ${err.message}`);
    res.status(500).json({
      error: 'Failed to calculate rate',
      details: err.message
    });
  }
};

/**
 * Get all rate table entries
 */
const getRates = async (req, res) => {
  try {
    const query = `
      SELECT r.*, w.name as origin_warehouse_name
      FROM rate_tables r
      LEFT JOIN warehouses w ON r.origin_warehouse_id = w.warehouse_id
      ORDER BY r.customer_name, r.destination_province, r.destination_city
    `;
    
    const result = await pool.query(query);
    
    res.status(200).json(result.rows);
  } catch (err) {
    logger.error(`Error getting rates: ${err.message}`);
    res.status(500).json({
      error: 'Failed to retrieve rates',
      details: err.message
    });
  }
};

/**
 * Get a specific rate table entry by ID
 */
const getRateById = async (req, res) => {
  const { rateId } = req.params;
  
  try {
    const query = `
      SELECT r.*, w.name as origin_warehouse_name
      FROM rate_tables r
      LEFT JOIN warehouses w ON r.origin_warehouse_id = w.warehouse_id
      WHERE r.rate_id = $1
    `;
    
    const result = await pool.query(query, [rateId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Rate not found',
        details: `No rate found with ID ${rateId}`
      });
    }
    
    res.status(200).json(result.rows[0]);
  } catch (err) {
    logger.error(`Error getting rate: ${err.message}`);
    res.status(500).json({
      error: 'Failed to retrieve rate',
      details: err.message
    });
  }
};

/**
 * Create a new rate table entry
 */
const createRate = async (req, res) => {
  const {
    customerName,
    destinationCity,
    destinationProvince,
    minWeightLb,
    weightPer0To1999lbs,
    weightPer2000To4999lbs,
    weightPer5000To9999lbs,
    weightPer10000To19999lbs,
    weightPer20000To29999lbs,
    weightPer30000To39999lbs,
    weightPerOver40000lbs,
    tlRate,
    originWarehouseId
  } = req.body;
  
  try {
    const query = `
      INSERT INTO rate_tables (
        customer_name,
        destination_city,
        destination_province,
        min_weight_lb,
        weight_per_0_1999lbs,
        weight_per_2000_4999lbs,
        weight_per_5000_9999lbs,
        weight_per_10000_19999lbs,
        weight_per_20000_29999lbs,
        weight_per_30000_39999lbs,
        weight_over_4000lbs,
        tl_rate,
        origin_warehouse_id
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      RETURNING *
    `;
    
    const result = await pool.query(query, [
      customerName,
      destinationCity,
      destinationProvince,
      minWeightLb,
      weightPer0To1999lbs,
      weightPer2000To4999lbs,
      weightPer5000To9999lbs,
      weightPer10000To19999lbs,
      weightPer20000To29999lbs,
      weightPer30000To39999lbs,
      weightPerOver40000lbs,
      tlRate,
      originWarehouseId
    ]);
    
    res.status(201).json(result.rows[0]);
  } catch (err) {
    logger.error(`Error creating rate: ${err.message}`);
    res.status(500).json({
      error: 'Failed to create rate',
      details: err.message
    });
  }
};

/**
 * Update an existing rate table entry
 */
const updateRate = async (req, res) => {
  const { rateId } = req.params;
  const {
    customerName,
    destinationCity,
    destinationProvince,
    minWeightLb,
    weightPer0To1999lbs,
    weightPer2000To4999lbs,
    weightPer5000To9999lbs,
    weightPer10000To19999lbs,
    weightPer20000To29999lbs,
    weightPer30000To39999lbs,
    weightPerOver40000lbs,
    tlRate,
    originWarehouseId
  } = req.body;
  
  try {
    const query = `
      UPDATE rate_tables
      SET customer_name = $1,
          destination_city = $2,
          destination_province = $3,
          min_weight_lb = $4,
          weight_per_0_1999lbs = $5,
          weight_per_2000_4999lbs = $6,
          weight_per_5000_9999lbs = $7,
          weight_per_10000_19999lbs = $8,
          weight_per_20000_29999lbs = $9,
          weight_per_30000_39999lbs = $10,
          weight_over_4000lbs = $11,
          tl_rate = $12,
          origin_warehouse_id = $13
      WHERE rate_id = $14
      RETURNING *
    `;
    
    const result = await pool.query(query, [
      customerName,
      destinationCity,
      destinationProvince,
      minWeightLb,
      weightPer0To1999lbs,
      weightPer2000To4999lbs,
      weightPer5000To9999lbs,
      weightPer10000To19999lbs,
      weightPer20000To29999lbs,
      weightPer30000To39999lbs,
      weightPerOver40000lbs,
      tlRate,
      originWarehouseId,
      rateId
    ]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Rate not found',
        details: `No rate found with ID ${rateId}`
      });
    }
    
    res.status(200).json(result.rows[0]);
  } catch (err) {
    logger.error(`Error updating rate: ${err.message}`);
    res.status(500).json({
      error: 'Failed to update rate',
      details: err.message
    });
  }
};

/**
 * Delete a rate table entry
 */
const deleteRate = async (req, res) => {
  const { rateId } = req.params;
  
  try {
    const query = 'DELETE FROM rate_tables WHERE rate_id = $1 RETURNING *';
    const result = await pool.query(query, [rateId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Rate not found',
        details: `No rate found with ID ${rateId}`
      });
    }
    
    res.status(200).json({
      message: 'Rate deleted successfully',
      deletedRate: result.rows[0]
    });
  } catch (err) {
    logger.error(`Error deleting rate: ${err.message}`);
    res.status(500).json({
      error: 'Failed to delete rate',
      details: err.message
    });
  }
};

/**
 * Import rates from CSV
 */
const importRates = async (req, res) => {
  const { csvData } = req.body;
  
  if (!csvData) {
    return res.status(400).json({ error: 'CSV data is required' });
  }
  
  try {
    // Process CSV data
    const lines = csvData.split('\n');
    const headers = lines[0].split(',').map(h => h.trim());
    
    // Start a transaction
    const client = await pool.connect();
    
    try {
      await client.query('BEGIN');
      
      let insertCount = 0;
      let errorCount = 0;
      const errors = [];
      
      // Process each line (skip header)
      for (let i = 1; i < lines.length; i++) {
        if (!lines[i].trim()) continue;
        
        try {
          const values = lines[i].split(',').map(v => v.trim());
          const rowData = {};
          
          headers.forEach((header, index) => {
            rowData[header] = values[index];
          });
          
          // Insert the row
          const query = `
            INSERT INTO rate_tables (
              customer_name,
              destination_city,
              destination_province,
              min_weight_lb,
              weight_per_0_1999lbs,
              weight_per_2000_4999lbs,
              weight_per_5000_9999lbs,
              weight_per_10000_19999lbs,
              weight_per_20000_29999lbs,
              weight_per_30000_39999lbs,
              weight_over_4000lbs,
              tl_rate,
              origin_warehouse_id
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
          `;
          
          await client.query(query, [
            rowData.customer_name || '',
            rowData.destination_city || '',
            rowData.destination_province || '',
            parseFloat(rowData.min_weight_lb || 0),
            parseFloat(rowData.weight_per_0_1999lbs || 0),
            parseFloat(rowData.weight_per_2000_4999lbs || 0),
            parseFloat(rowData.weight_per_5000_9999lbs || 0),
            parseFloat(rowData.weight_per_10000_19999lbs || 0),
            parseFloat(rowData.weight_per_20000_29999lbs || 0),
            parseFloat(rowData.weight_per_30000_39999lbs || 0),
            parseFloat(rowData.weight_over_4000lbs || 0),
            parseFloat(rowData.tl_rate || 0),
            rowData.origin_warehouse_id || ''
          ]);
          
          insertCount++;
        } catch (err) {
          errorCount++;
          errors.push({ line: i + 1, error: err.message });
        }
      }
      
      await client.query('COMMIT');
      
      res.status(200).json({
        message: 'Import completed',
        stats: {
          totalLines: lines.length - 1,
          inserted: insertCount,
          errors: errorCount
        },
        errors: errors.length > 0 ? errors : undefined
      });
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  } catch (err) {
    logger.error(`Error importing rates: ${err.message}`);
    res.status(500).json({
      error: 'Failed to import rates',
      details: err.message
    });
  }
};

/**
 * Export rates as CSV
 */
const exportRates = async (req, res) => {
  try {
    const query = `
      SELECT r.*, w.name as origin_warehouse_name
      FROM rate_tables r
      LEFT JOIN warehouses w ON r.origin_warehouse_id = w.warehouse_id
      ORDER BY r.customer_name, r.destination_province, r.destination_city
    `;
    
    const result = await pool.query(query);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'No rates found',
        details: 'No rates exist in the database to export'
      });
    }
    
    // Create CSV header
    const headers = [
      'customer_name',
      'destination_city',
      'destination_province',
      'min_weight_lb',
      'weight_per_0_1999lbs',
      'weight_per_2000_4999lbs',
      'weight_per_5000_9999lbs',
      'weight_per_10000_19999lbs',
      'weight_per_20000_29999lbs',
      'weight_per_30000_39999lbs',
      'weight_over_4000lbs',
      'tl_rate',
      'origin_warehouse_id',
      'origin_warehouse_name'
    ];
    
    // Create CSV content
    let csvContent = headers.join(',') + '\n';
    
    result.rows.forEach(row => {
      const values = headers.map(header => {
        const value = row[header];
        if (value === null || value === undefined) return '';
        // Wrap strings in quotes and handle any embedded quotes
        if (typeof value === 'string') return `"${value.replace(/"/g, '""')}"`;
        return value;
      });
      
      csvContent += values.join(',') + '\n';
    });
    
    // Set response headers for CSV download
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=rate_tables.csv');
    
    res.status(200).send(csvContent);
  } catch (err) {
    logger.error(`Error exporting rates: ${err.message}`);
    res.status(500).json({
      error: 'Failed to export rates',
      details: err.message
    });
  }
};

/**
 * Get distinct customer names
 */
const getCustomers = async (req, res) => {
  try {
    const query = `
      SELECT DISTINCT customer_name 
      FROM rate_tables 
      WHERE customer_name IS NOT NULL AND customer_name != ''
      ORDER BY customer_name
    `;
    
    const result = await pool.query(query);
    
    // Format as an array of customer objects
    const customers = result.rows.map((row, index) => ({
      customerId: `customer-${index + 1}`,
      name: row.customer_name
    }));
    
    res.status(200).json(customers);
  } catch (err) {
    logger.error(`Error getting customers: ${err.message}`);
    res.status(500).json({
      error: 'Failed to retrieve customers',
      details: err.message
    });
  }
};

module.exports = {
  calculateRate,
  getRates,
  getRateById,
  createRate,
  updateRate,
  deleteRate,
  importRates,
  exportRates,
  getCustomers
};
