const fs = require('fs');
const { parse } = require('csv-parse');
const { Pool } = require('pg');

const pool = new Pool({
  host: '35.203.126.72',
  user: 'dispatch-admin',
  password: 'test123!!',
  database: 'dispatch-dashboard',
  port: 5432
});

// Import hazards from CSV
async function importHazards(filepath) {
  console.log(`Importing hazards from ${filepath}...`);
  
  const parser = fs
    .createReadStream(filepath)
    .pipe(parse({ columns: true, delimiter: ',', trim: true }));
  
  let count = 0;
  
  for await (const record of parser) {
    try {
      const hazardPk = record['Hazard PK'];
      if (!hazardPk) continue;
      
      // Check if this hazard already exists
      const existingResult = await pool.query(
        'SELECT hazard_pk FROM hazards WHERE hazard_pk = $1',
        [hazardPk]
      );
      
      const hazardData = {
        hazard_pk: hazardPk,
        hazard_code: record['Hazard Code'] || '',
        description1: record.Description1 || '',
        description2: record.Description2 || '',
        description3: record.Description3 || ''
      };
      
      if (existingResult.rows.length > 0) {
        // Update existing hazard
        await pool.query(
          `UPDATE hazards SET
           hazard_code = $2,
           description1 = $3,
           description2 = $4,
           description3 = $5,
           updated_at = NOW()
           WHERE hazard_pk = $1`,
          [
            hazardData.hazard_pk,
            hazardData.hazard_code,
            hazardData.description1,
            hazardData.description2,
            hazardData.description3
          ]
        );
        console.log(`Updated hazard: ${hazardData.hazard_code}`);
      } else {
        // Insert new hazard
        await pool.query(
          `INSERT INTO hazards (
            hazard_pk, hazard_code, description1, description2, description3, created_at, updated_at
          ) VALUES ($1, $2, $3, $4, $5, NOW(), NOW())`,
          [
            hazardData.hazard_pk,
            hazardData.hazard_code,
            hazardData.description1,
            hazardData.description2,
            hazardData.description3
          ]
        );
        console.log(`Imported hazard: ${hazardData.hazard_code}`);
      }
      
      count++;
      if (count % 10 === 0) {
        console.log(`Processed ${count} hazards...`);
      }
    } catch (error) {
      console.error(`Error with hazard ${record['Hazard PK']}:`, error.message);
    }
  }
  
  console.log(`Completed importing ${count} hazards.`);
}

// Import products from CSV
async function importProducts(filepath) {
  console.log(`Importing products from ${filepath}...`);
  
  const parser = fs
    .createReadStream(filepath)
    .pipe(parse({ columns: true, delimiter: ',', trim: true }));
  
  let count = 0;
  
  for await (const record of parser) {
    try {
      const productCode = record.ProductCode;
      if (!productCode) continue;
      
      // Find manufacturer ID if CustomerCode is provided
      let manufacturerId = null;
      if (record.CustomerCode) {
        try {
          const mfgResult = await pool.query(
            'SELECT manufacturer_id FROM manufacturers WHERE manufacturer_id = $1',
            [record.CustomerCode]
          );
          
          if (mfgResult.rows.length > 0) {
            manufacturerId = mfgResult.rows[0].manufacturer_id;
          }
        } catch (err) {
          console.log(`Manufacturer not found for code: ${record.CustomerCode}`);
        }
      }
      
      // Check if product exists already
      const existingResult = await pool.query(
        'SELECT product_id FROM products WHERE product_id = $1',
        [productCode]
      );
      
      // Check if there's a corresponding hazard
      let isDangerous = false;
      let tdgNumber = null;
      
      if (record.HazardPK && record.HazardPK !== '') {
        // Check if this hazard exists in our hazards table
        const hazardResult = await pool.query(
          'SELECT hazard_code FROM hazards WHERE hazard_pk = $1',
          [record.HazardPK]
        );
        
        if (hazardResult.rows.length > 0) {
          isDangerous = true;
          tdgNumber = hazardResult.rows[0].hazard_code;
        }
      }
      
      // Parse other fields from AllProducts.csv
      const weightKg = parseFloat(record.WeightPerUnit || 0);
      const requiresRefrigeration = record.Heat === 'True';
      const requiresHeating = record.Heat === 'True';
      const doNotShip = record.DoNotShip === 'True';
      const description = record.Description || '';
      
      // Calculate volume if possible (based on CubeValuePerUnit)
      let volumeCubicM = null;
      if (record.CubeValuePerUnit) {
        volumeCubicM = parseFloat(record.CubeValuePerUnit);
      }
      
      if (existingResult.rows.length > 0) {
        // Update existing product
        await pool.query(
          `UPDATE products SET
           manufacturer_id = $2,
           name = $3,
           description = $4,
           weight_kg = $5,
           volume_cubic_m = $6,
           requires_refrigeration = $7,
           requires_heating = $8,
           is_dangerous_good = $9,
           tdg_number = $10,
           updated_at = NOW()
           WHERE product_id = $1`,
          [
            productCode,
            manufacturerId,
            description,
            description,
            weightKg,
            volumeCubicM,
            requiresRefrigeration,
            requiresHeating,
            isDangerous || doNotShip, // either hazardous or marked as DoNotShip
            tdgNumber
          ]
        );
        console.log(`Updated product: ${productCode}`);
      } else {
        // Insert new product
        await pool.query(
          `INSERT INTO products (
            product_id, manufacturer_id, name, description, weight_kg, volume_cubic_m,
            requires_refrigeration, requires_heating, is_dangerous_good, tdg_number,
            created_at, updated_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())`,
          [
            productCode,
            manufacturerId,
            description,
            description,
            weightKg,
            volumeCubicM,
            requiresRefrigeration,
            requiresHeating,
            isDangerous || doNotShip, // either hazardous or marked as DoNotShip
            tdgNumber
          ]
        );
        console.log(`Imported product: ${productCode}`);
      }
      
      count++;
      if (count % 100 === 0) {
        console.log(`Processed ${count} products...`);
      }
    } catch (error) {
      console.error(`Error with product ${record.ProductCode}:`, error.message);
    }
  }
  
  console.log(`Completed importing ${count} products.`);
}

// Import customers from CSV
async function importCustomers(filepath) {
  console.log(`Importing customers from ${filepath}...`);
  
  const parser = fs
    .createReadStream(filepath)
    .pipe(parse({ columns: true, delimiter: ',', trim: true }));
  
  let count = 0;
  
  for await (const record of parser) {
    try {
      const customerNumber = record.CustomerNumber;
      if (!customerNumber) continue;
      
      // Check if customer exists already
      const checkQuery = `
        SELECT customer_id FROM customers 
        WHERE customer_id = $1::integer
      `;
      
      const existingResult = await pool.query(checkQuery, [customerNumber]);
      
      const customerData = {
        customer_id: customerNumber,
        company_name: record.Company || '',
        contact_name: record.Name || '',
        address: record.Address || '',
        city: record.City || '',
        province: record.Prov || '',
        postal_code: record['Postal Code'] || '',
        contact_phone: record.Phone || '',
        // Additional fields from your actual data
        status: record.Status || 'Active'
      };
      
      if (existingResult.rows.length > 0) {
        // Update existing customer
        const updateQuery = `
          UPDATE customers SET
           company_name = $2,
           contact_name = $3,
           address = $4,
           city = $5,
           province = $6,
           postal_code = $7,
           contact_phone = $8,
           updated_at = NOW()
           WHERE customer_id = $1::integer
        `;
        
        await pool.query(updateQuery, [
          customerData.customer_id,
          customerData.company_name,
          customerData.contact_name,
          customerData.address,
          customerData.city,
          customerData.province,
          customerData.postal_code,
          customerData.contact_phone
        ]);
        console.log(`Updated customer: ${customerData.company_name}`);
      } else {
        // Insert new customer
        const insertQuery = `
          INSERT INTO customers (
            customer_id, company_name, contact_name, address, city, province,
            postal_code, contact_phone, created_at, updated_at
          ) VALUES ($1::integer, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())
        `;
        
        await pool.query(insertQuery, [
          customerData.customer_id,
          customerData.company_name,
          customerData.contact_name,
          customerData.address,
          customerData.city,
          customerData.province,
          customerData.postal_code,
          customerData.contact_phone
        ]);
        console.log(`Imported customer: ${customerData.company_name}`);
      }
      
      count++;
      if (count % 10 === 0) {
        console.log(`Processed ${count} customers...`);
      }
    } catch (error) {
      console.error(`Error with customer ${record.CustomerNumber}:`, error.message);
      console.error(error);
    }
  }
  
  console.log(`Completed importing ${count} customers.`);
}

// Main function to run all imports
async function importAll() {
  try {
    console.log("Starting data import...");
    
    // First check database connection
    try {
      const result = await pool.query('SELECT NOW()');
      console.log("Database connection successful. Current time:", result.rows[0].now);
    } catch (error) {
      console.error("Failed to connect to database:", error.message);
      console.error("Full error:", error);
      return;
    }
    
    // Define file paths - adjust these to your actual file locations
    const HAZARDS_FILE = 'HazardList.csv';
    const PRODUCTS_FILE = 'AllProducts.csv';
    const CUSTOMERS_FILE = 'CustomerList.csv';
    
    // Check if files exist
    console.log(`HazardList.csv exists: ${fs.existsSync(HAZARDS_FILE)}`);
    console.log(`AllProducts.csv exists: ${fs.existsSync(PRODUCTS_FILE)}`);
    console.log(`CustomerList.csv exists: ${fs.existsSync(CUSTOMERS_FILE)}`);
    
    // Import in the correct order:
    // 1. Hazards (since products may reference them)
    if (fs.existsSync(HAZARDS_FILE)) {
      await importHazards(HAZARDS_FILE);
    } else {
      console.log("Hazards file not found. Skipping hazards import.");
    }
    
    // 2. Products
    if (fs.existsSync(PRODUCTS_FILE)) {
      await importProducts(PRODUCTS_FILE);
    } else {
      console.log("Products file not found. Skipping products import.");
    }
    
    // 3. Customers
    if (fs.existsSync(CUSTOMERS_FILE)) {
      await importCustomers(CUSTOMERS_FILE);
    } else {
      console.log("Customers file not found. Skipping customers import.");
    }
    
    console.log("All data import attempts completed!");
  } catch (error) {
    console.error("Fatal error during import:", error);
  } finally {
    await pool.end();
  }
}

// Run the import
importAll();