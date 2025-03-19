# Stock Management Integration

This document outlines the changes made to add stock management capabilities to the dispatch dashboard system.

## Overview

The following changes have been implemented:

1. Added new columns to the products table:
   - `quantity_on_hand` - Tracks current inventory levels
   - `warehouse_id` - References the warehouse where the product is stored
   - `customer_code` - Maps to manufacturer IDs from the original CSV data

2. Updated the products controller to:
   - Include warehouse information when fetching products
   - Support the new columns in CRUD operations
   - Convert weights from kg to lbs for frontend display

3. Created SQL scripts to:
   - Add the new columns to the database schema
   - Create mappings between CSV location names and existing warehouse IDs
   - Update manufacturers data based on customer codes
   - Update existing products and insert new ones without duplication

## Files Created/Modified

- `add-stock-columns.sql` - Adds new columns to the products table
- `update-warehouses.sql` - Creates mappings between CSV locations and existing warehouse IDs
- `update-manufacturers.sql` - Updates manufacturer data based on customer codes
- `update-products.sql` - Updates existing products and inserts new ones without duplication
- `update-database.js` - Script to run all SQL scripts in order
- `import-csv-to-db.js` - Node.js script to import CSV data into the database
- `dispatch-dashboard/backend/src/controllers/productsController.js` - Updated to handle new columns and convert weights

## How to Run the Update

1. Make sure you have Node.js and npm installed
2. Install required dependencies:
   ```
   npm install pg dotenv
   ```
3. Run the update script:
   ```
   node update-database.js
   ```

## Weight Unit Conversion

The system now automatically converts weights from kilograms (stored in the database) to pounds (displayed in the frontend). This conversion happens in the backend API, so no changes are needed in the frontend components.

## Warehouse and Manufacturer Integration

Products are now linked to warehouses and manufacturers:

- Each product is assigned to a specific warehouse via the `warehouse_id` column
- The system maps location names from your CSV (like "Calgary", "Edmonton") to your existing warehouse IDs
- Products are linked to manufacturers via the `customer_code` column, which corresponds to the manufacturer ID
- The frontend displays the warehouse name along with the product details

## CSV Data Import

The original CSV data has the following structure:
```
Location,CustomerCode,ProductCode,Description,WeightPerUnit,Heat,DoNotShip,StorageChargePerPallet,HandlingChargePerPallet,Unit,UnitsPerPallet,QuantityOnHand,CubeValuePerUnit,PalletStackHeight,HazardPK,TrackByLot,strGroup
```

The SQL scripts handle this data as follows:

1. The `update-warehouses.sql` script maps location names to your existing warehouse IDs:
   - "Pettigrew" → CWS Regina (ID: 1210)
   - "Regina" → CWS Regina (ID: 1210)
   - "Winnipeg" → CWS Winnipeg (ID: 1664)
   - "Calgary" → CWS Calgary (ID: 5625)
   - "Edmonton" → CWS Edmonton (ID: 21335)

2. The `update-products.sql` script:
   - Creates a temporary table to hold the CSV data
   - Updates existing products with new information (warehouse, stock, etc.)
   - Inserts new products only if they don't already exist
   - Converts weights from pounds (in CSV) to kilograms (for database storage)

## How to Import Your CSV Data

We've created a Node.js script to make it easy to import your CSV data:

1. Install the required dependencies:
   ```
   npm install pg dotenv csv-parser
   ```

2. Run the schema update script first:
   ```
   node update-database.js
   ```
   This will add the necessary columns and create the mappings.

3. Import your CSV data:
   ```
   node import-csv-to-db.js AllProducts.csv
   ```
   This will:
   - Read your CSV file
   - Update existing products with new information (warehouse, stock, etc.)
   - Insert new products only if they don't already exist
   - Convert weights from pounds (in CSV) to kilograms (for database storage)

The script is designed to handle large CSV files efficiently by:
- Processing data in batches
- Using transactions for better performance and error handling
- Providing progress updates during the import process

## Next Steps

After importing your data, consider these additional features:

1. Add stock level validation when creating orders
2. Implement inventory adjustment functionality
3. Add reporting features for inventory management
