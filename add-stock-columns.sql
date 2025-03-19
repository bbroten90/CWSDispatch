-- Add stock level column to products table
ALTER TABLE products ADD COLUMN IF NOT EXISTS quantity_on_hand INTEGER DEFAULT 0;

-- Add warehouse_id column to products table (for location tracking)
ALTER TABLE products ADD COLUMN IF NOT EXISTS warehouse_id INTEGER REFERENCES warehouses(warehouse_id);

-- Add customer_code column to products table (to match with your CSV data)
ALTER TABLE products ADD COLUMN IF NOT EXISTS customer_code VARCHAR(50);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_products_warehouse ON products(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_products_manufacturer ON products(manufacturer_id);
CREATE INDEX IF NOT EXISTS idx_products_customer_code ON products(customer_code);
