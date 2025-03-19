-- Create a mapping table for locations to existing warehouse IDs
-- Based on the existing warehouses in the database:
-- 1210: CWS Regina
-- 250: CWS Henderson
-- 1664: CWS Winnipeg
-- 5625: CWS Calgary
-- 21335: CWS Edmonton

-- Create a mapping table to help with data import
CREATE TABLE IF NOT EXISTS location_warehouse_mapping (
  location_name VARCHAR(100) PRIMARY KEY,
  warehouse_id INTEGER REFERENCES warehouses(warehouse_id)
);

-- Insert mappings for each location in your CSV to your existing warehouse IDs
INSERT INTO location_warehouse_mapping (location_name, warehouse_id)
VALUES 
  ('Pettigrew', 1210), -- Map to CWS Regina (closest to Pettigrew)
  ('Regina', 1210),    -- Map to CWS Regina
  ('Winnipeg', 1664),  -- Map to CWS Winnipeg
  ('Calgary', 5625),   -- Map to CWS Calgary
  ('Edmonton', 21335)  -- Map to CWS Edmonton
ON CONFLICT (location_name) 
DO UPDATE SET 
  warehouse_id = EXCLUDED.warehouse_id;
