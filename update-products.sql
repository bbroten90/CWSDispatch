-- Update products with warehouse_id, customer_code, and quantity_on_hand
-- This script handles both updating existing products and inserting new ones

-- Step 1: Create a temporary table to hold CSV data
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

-- Step 2: Import data from CSV
-- In a real implementation, you would use a COPY command or another method to import the CSV
-- For this example, we'll insert a few sample rows based on your CSV data
INSERT INTO temp_product_data (
  location, customer_code, product_id, description, weight_per_unit, 
  requires_heating, do_not_ship, storage_charge_per_pallet, handling_charge_per_pallet,
  unit, units_per_pallet, quantity_on_hand, cube_value_per_unit, pallet_stack_height,
  hazard_pk, track_by_lot, str_group
)
VALUES 
  ('Pettigrew', '1100', 'DECANT', 'Monsanto Decant', 1.00, false, false, 0.00, 0.250, 'Ltrs', 1, 0, 0.0000, 3, NULL, true, NULL),
  ('Regina', '1100', 'DECANT', 'Monsanto Decant', 1.00, false, false, 0.00, 0.000, 'Ltrs', 1, 0, 0.0000, 3, NULL, true, NULL),
  ('Pettigrew', '1100', '01054185G', 'Round Up Transorb *10L Decant*', 668.70, false, false, 0.00, 143.550, 'Ltr Tote', 1, 450, 0.7330, 3, NULL, true, NULL),
  ('Calgary', '1100', '10503620', 'Round Up Transorb HC', 14.88, false, false, 0.00, 0.000, '10 Ltr Jug', 72, 1398, 0.1020, 3, NULL, true, NULL),
  ('Calgary', '1100', '10503620-3', 'Round Up Transorb HC', 14.88, false, false, 0.00, 0.000, '10 Ltr Jug', 72, 0, 0.1019, 3, NULL, true, NULL);
  
-- You would add more rows here from your CSV file

-- Step 3: Update existing products
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

-- Step 4: Insert new products that don't exist yet
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

-- Step 5: Drop the temporary table when done
DROP TABLE temp_product_data;

-- Note: In a real implementation, you would:
-- 1. Use a COPY command to import the CSV file into the temp table
-- 2. Add error handling and transaction management
-- 3. Consider using a batch process for large datasets
