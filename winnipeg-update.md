# Winnipeg Warehouse Mapping Update

## Changes Made

1. Added Winnipeg to the warehouse location mappings in `update-warehouses.sql`:
   ```sql
   ('Winnipeg', 1664),  -- Map to CWS Winnipeg
   ```

2. Updated the README_STOCK_MANAGEMENT.md documentation to include Winnipeg in the mapping list:
   ```
   - "Winnipeg" → CWS Winnipeg (ID: 1664)
   ```

## Impact

This update ensures that products with "Winnipeg" as their location in your CSV file will be correctly mapped to the CWS Winnipeg warehouse (ID: 1664) in your database.

## No Changes Needed to Import Script

The `import-csv-to-db.js` script doesn't need any changes because it:
1. Reads the location from the CSV file
2. Uses the location_warehouse_mapping table to find the corresponding warehouse_id
3. Since we've updated the mapping table to include Winnipeg, the script will automatically handle Winnipeg locations correctly

## How to Apply the Update

1. The changes have already been applied to the files in your project.
2. When you run the update and import scripts, they will now correctly handle Winnipeg locations:
   ```
   node update-database.js
   node import-csv-to-db.js AllProducts.csv
   ```
