-- Enhanced Database Schema for Dispatch Dashboard

-- Warehouses (shipping locations)
CREATE TABLE warehouses (
    warehouse_id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    loading_capacity INTEGER, -- Number of trucks that can be loaded simultaneously
    storage_capacity DECIMAL(10,2), -- in cubic meters
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Manufacturers (your major customers that provide product)
CREATE TABLE manufacturers (
    manufacturer_id VARCHAR(36) PRIMARY KEY,
    code INTEGER UNIQUE,
    name VARCHAR(100) NOT NULL UNIQUE,
    api_key VARCHAR(255),
    contact_name VARCHAR(100),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    webhook_url VARCHAR(255),
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hazardous Materials Table
CREATE TABLE hazard_codes (
    hazard_pk INTEGER PRIMARY KEY,
    hazard_code VARCHAR(20) NOT NULL,
    description1 TEXT,
    description2 TEXT,
    description3 TEXT,
    timestamp VARCHAR(36)
);

-- Vehicles (trucks and trailers)
CREATE TABLE vehicles (
    vehicle_id VARCHAR(36) PRIMARY KEY,
    vehicle_number VARCHAR(50) NOT NULL UNIQUE,
    type VARCHAR(50) NOT NULL, -- 'TRUCK', 'TRAILER'
    make VARCHAR(50),
    model VARCHAR(50),
    year INTEGER,
    vin VARCHAR(50),
    plate_number VARCHAR(20),
    capacity_weight DECIMAL(10,2) NOT NULL, -- in kg
    capacity_volume DECIMAL(10,2), -- in cubic meters
    has_refrigeration BOOLEAN DEFAULT FALSE,
    has_heating BOOLEAN DEFAULT FALSE,
    has_tdg_capacity BOOLEAN DEFAULT FALSE, -- Transportation of Dangerous Goods
    home_warehouse_id VARCHAR(36) REFERENCES warehouses(warehouse_id),
    status VARCHAR(20) DEFAULT 'active', -- active, maintenance, out_of_service
    next_maintenance_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drivers
CREATE TABLE drivers (
    id VARCHAR(36) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    license_number VARCHAR(50),
    license_expiry DATE,
    status VARCHAR(20) DEFAULT 'active', -- active, inactive, on_leave
    notes TEXT,
    home_warehouse_id VARCHAR(36) REFERENCES warehouses(warehouse_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customers (shipping destinations)
CREATE TABLE customers (
    customer_id VARCHAR(36) PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    province VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    contact_name VARCHAR(100),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    certification_number VARCHAR(100),
    status VARCHAR(50),
    fax VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE products (
    product_code VARCHAR(50) PRIMARY KEY,
    manufacturer_id VARCHAR(36) REFERENCES manufacturers(manufacturer_id),
    description TEXT NOT NULL,
    weight_per_unit DECIMAL(10,2) NOT NULL,
    requires_heat BOOLEAN DEFAULT FALSE,
    do_not_ship BOOLEAN DEFAULT FALSE,
    storage_charge_per_pallet DECIMAL(10,2),
    handling_charge_per_pallet DECIMAL(10,2),
    unit VARCHAR(20),
    units_per_pallet INTEGER,
    cube_value_per_unit DECIMAL(10,3),
    pallet_stack_height DECIMAL(10,2),
    hazard_fk INTEGER REFERENCES hazard_codes(hazard_pk),
    track_by_lot BOOLEAN DEFAULT FALSE,
    product_group VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rate Tables
CREATE TABLE rate_tables (
    rate_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100), -- manufacturer name
    destination_city VARCHAR(100) NOT NULL,
    destination_province VARCHAR(50) NOT NULL,
    min_weight_lb DECIMAL(10,2) NOT NULL,
    weight_per_0_1999lbs DECIMAL(10,4) NOT NULL,
    weight_per_2000_4999lbs DECIMAL(10,4) NOT NULL,
    weight_per_5000_9999lbs DECIMAL(10,4) NOT NULL,
    weight_per_10000_19999lbs DECIMAL(10,4) NOT NULL,
    weight_per_20000_29999lbs DECIMAL(10,4),
    weight_per_30000_39999lbs DECIMAL(10,4),
    weight_over_40000lbs DECIMAL(10,4),
    tl_rate DECIMAL(10,2), -- Truckload rate
    origin_warehouse_id VARCHAR(36) REFERENCES warehouses(warehouse_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_code VARCHAR(50) REFERENCES products(product_code),
    warehouse_id VARCHAR(36) REFERENCES warehouses(warehouse_id),
    quantity_on_hand INTEGER NOT NULL DEFAULT 0,
    lot_number VARCHAR(50),
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_code, warehouse_id, lot_number)
);

-- Order Headers
CREATE TABLE orders (
    id VARCHAR(36) PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    manufacturer_id VARCHAR(36) REFERENCES manufacturers(manufacturer_id),
    customer_id VARCHAR(36) REFERENCES customers(customer_id),
    status VARCHAR(50) DEFAULT 'pending', -- pending, assigned, in_transit, delivered, cancelled
    pickup_warehouse_id VARCHAR(36) REFERENCES warehouses(warehouse_id),
    pickup_date DATE NOT NULL,
    delivery_date DATE NOT NULL,
    delivery_address VARCHAR(255) NOT NULL,
    delivery_city VARCHAR(100) NOT NULL,
    delivery_province VARCHAR(50) NOT NULL,
    delivery_postal_code VARCHAR(20) NOT NULL,
    total_weight DECIMAL(10,2) NOT NULL, -- in kg
    total_pallets INTEGER NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order Line Items
CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id VARCHAR(36) REFERENCES orders(id),
    product_code VARCHAR(50) REFERENCES products(product_code),
    quantity INTEGER NOT NULL,
    weight DECIMAL(10,2) NOT NULL, -- in kg
    pallets DECIMAL(10,2) NOT NULL,
    lot_number VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shipments
CREATE TABLE shipments (
    id VARCHAR(36) PRIMARY KEY,
    shipment_number VARCHAR(50) NOT NULL UNIQUE,
    origin_warehouse_id VARCHAR(36) REFERENCES warehouses(warehouse_id),
    vehicle_id VARCHAR(36) REFERENCES vehicles(vehicle_id),
    driver_id VARCHAR(36) REFERENCES drivers(id),
    status VARCHAR(20) DEFAULT 'planned', -- planned, in_transit, completed, cancelled
    planned_date DATE NOT NULL,
    planned_departure TIMESTAMP,
    planned_arrival TIMESTAMP,
    actual_departure TIMESTAMP,
    actual_arrival TIMESTAMP,
    total_distance_km DECIMAL(10,2),
    total_weight DECIMAL(10,2),
    total_pallets INTEGER,
    total_revenue DECIMAL(10,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shipment Orders (maps orders to shipments)
CREATE TABLE shipment_orders (
    id SERIAL PRIMARY KEY,
    shipment_id VARCHAR(36) REFERENCES shipments(id),
    order_id VARCHAR(36) REFERENCES orders(id),
    stop_sequence INTEGER NOT NULL, -- Order of delivery stops
    status VARCHAR(20) DEFAULT 'planned', -- planned, loaded, delivered, cancelled
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (shipment_id, order_id)
);

-- Vehicle Availability
CREATE TABLE vehicle_availability (
    id SERIAL PRIMARY KEY,
    vehicle_id VARCHAR(36) REFERENCES vehicles(vehicle_id),
    date DATE NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (vehicle_id, date)
);

-- Driver Availability
CREATE TABLE driver_availability (
    id SERIAL PRIMARY KEY,
    driver_id VARCHAR(36) REFERENCES drivers(id),
    date DATE NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (driver_id, date)
);

-- Optimization Logs
CREATE TABLE optimization_logs (
    log_id VARCHAR(36) PRIMARY KEY,
    optimization_type VARCHAR(50) NOT NULL, -- ROUTING, LOADING
    input_parameters JSONB,
    output_result JSONB,
    status VARCHAR(20) DEFAULT 'running', -- running, success, error
    execution_time_ms INTEGER,
    success BOOLEAN,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_orders_manufacturer ON orders(manufacturer_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_dates ON orders(pickup_date, delivery_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_shipments_dates ON shipments(planned_date);
CREATE INDEX idx_shipments_warehouse ON shipments(origin_warehouse_id);
CREATE INDEX idx_shipments_status ON shipments(status);
CREATE INDEX idx_shipment_orders_shipment ON shipment_orders(shipment_id);
CREATE INDEX idx_shipment_orders_order ON shipment_orders(order_id);
CREATE INDEX idx_vehicle_availability_date ON vehicle_availability(date);
CREATE INDEX idx_driver_availability_date ON driver_availability(date);
CREATE INDEX idx_products_manufacturer ON products(manufacturer_id);
CREATE INDEX idx_inventory_warehouse ON inventory(warehouse_id);
CREATE INDEX idx_inventory_product ON inventory(product_code);
CREATE INDEX idx_hazard_code ON hazard_codes(hazard_code);
