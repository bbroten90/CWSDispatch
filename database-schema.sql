-- Dispatch Dashboard Database Schema for Google Cloud SQL (PostgreSQL)

-- Warehouses
CREATE TABLE warehouses (
    warehouse_id SERIAL PRIMARY KEY,
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

-- Manufacturers (your major customers)
CREATE TABLE manufacturers (
    manufacturer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    api_key VARCHAR(255),
    contact_name VARCHAR(100),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    webhook_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles (trucks and trailers)
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    samsara_id VARCHAR(100), -- ID from Samsara API
    type VARCHAR(50) NOT NULL, -- 'TRUCK', 'TRAILER'
    license_plate VARCHAR(20),
    make VARCHAR(50),
    model VARCHAR(50),
    year INTEGER,
    max_weight_kg DECIMAL(10,2) NOT NULL,
    volume_capacity_cubic_m DECIMAL(10,2),
    has_refrigeration BOOLEAN DEFAULT FALSE,
    has_heating BOOLEAN DEFAULT FALSE,
    has_tdg_capacity BOOLEAN DEFAULT FALSE, -- Transportation of Dangerous Goods
    home_warehouse_id INTEGER REFERENCES warehouses(warehouse_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drivers
CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    samsara_id VARCHAR(100), -- ID from Samsara API
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    license_number VARCHAR(50),
    license_expiry DATE,
    home_warehouse_id INTEGER REFERENCES warehouses(warehouse_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customers (who receive shipments)
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    manufacturer_id INTEGER REFERENCES manufacturers(manufacturer_id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    weight_kg DECIMAL(10,2) NOT NULL,
    volume_cubic_m DECIMAL(10,2),
    requires_refrigeration BOOLEAN DEFAULT FALSE,
    requires_heating BOOLEAN DEFAULT FALSE,
    is_dangerous_good BOOLEAN DEFAULT FALSE,
    tdg_number VARCHAR(50), -- Transportation of Dangerous Goods number
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rate Tables
CREATE TABLE rate_tables (
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
);

-- Order Headers
CREATE TABLE order_headers (
    order_id SERIAL PRIMARY KEY,
    document_id VARCHAR(50) NOT NULL UNIQUE, -- External ID from manufacturer (PO-12345)
    manufacturer_id INTEGER REFERENCES manufacturers(manufacturer_id),
    order_date DATE NOT NULL,
    po_number VARCHAR(50),
    requested_shipment_date DATE,
    requested_delivery_date DATE,
    customer_id INTEGER REFERENCES customers(customer_id),
    special_requirements TEXT,
    status VARCHAR(50) DEFAULT 'RECEIVED', -- RECEIVED, SCHEDULED, LOADED, IN_TRANSIT, DELIVERED, CANCELLED
    total_quantity INTEGER,
    total_weight_kg DECIMAL(10,2),
    total_volume_cubic_m DECIMAL(10,2),
    estimated_revenue DECIMAL(10,2),
    actual_revenue DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order Line Items
CREATE TABLE order_line_items (
    line_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES order_headers(order_id),
    product_id VARCHAR(50) REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    weight_kg DECIMAL(10,2) NOT NULL,
    volume_cubic_m DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shipments (a single trip from warehouse to one or more customers)
CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,
    shipment_date DATE NOT NULL,
    origin_warehouse_id INTEGER REFERENCES warehouses(warehouse_id),
    truck_id INTEGER REFERENCES vehicles(vehicle_id),
    trailer_id INTEGER REFERENCES vehicles(vehicle_id),
    driver_id INTEGER REFERENCES drivers(driver_id),
    status VARCHAR(50) DEFAULT 'PLANNED', -- PLANNED, LOADING, LOADED, IN_TRANSIT, DELIVERED, CANCELLED
    total_distance_km DECIMAL(10,2),
    estimated_start_time TIMESTAMP,
    actual_start_time TIMESTAMP,
    estimated_completion_time TIMESTAMP,
    actual_completion_time TIMESTAMP,
    total_weight_kg DECIMAL(10,2),
    total_volume_cubic_m DECIMAL(10,2),
    total_revenue DECIMAL(10,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shipment Orders (maps orders to shipments)
CREATE TABLE shipment_orders (
    shipment_order_id SERIAL PRIMARY KEY,
    shipment_id INTEGER REFERENCES shipments(shipment_id),
    order_id INTEGER REFERENCES order_headers(order_id),
    stop_sequence INTEGER NOT NULL, -- Order of delivery stops
    estimated_arrival_time TIMESTAMP,
    actual_arrival_time TIMESTAMP,
    status VARCHAR(50) DEFAULT 'PLANNED', -- PLANNED, LOADED, DELIVERED, CANCELLED
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vehicle Availability
CREATE TABLE vehicle_availability (
    availability_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER REFERENCES vehicles(vehicle_id),
    date DATE NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (vehicle_id, date)
);

-- Driver Availability
CREATE TABLE driver_availability (
    availability_id SERIAL PRIMARY KEY,
    driver_id INTEGER REFERENCES drivers(driver_id),
    date DATE NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (driver_id, date)
);

-- API Logs
CREATE TABLE api_logs (
    log_id SERIAL PRIMARY KEY,
    request_type VARCHAR(50) NOT NULL, -- INCOMING, OUTGOING
    endpoint VARCHAR(255) NOT NULL,
    request_body TEXT,
    response_body TEXT,
    status_code INTEGER,
    ip_address VARCHAR(50),
    user_agent TEXT,
    duration_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Optimization Logs
CREATE TABLE optimization_logs (
    log_id SERIAL PRIMARY KEY,
    optimization_type VARCHAR(50) NOT NULL, -- ROUTING, LOADING
    input_parameters TEXT,
    output_result TEXT,
    execution_time_ms INTEGER,
    success BOOLEAN,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_order_headers_manufacturer ON order_headers(manufacturer_id);
CREATE INDEX idx_order_headers_customer ON order_headers(customer_id);
CREATE INDEX idx_order_headers_status ON order_headers(status);
CREATE INDEX idx_order_headers_dates ON order_headers(requested_shipment_date, requested_delivery_date);
CREATE INDEX idx_order_line_items_order ON order_line_items(order_id);
CREATE INDEX idx_shipments_dates ON shipments(shipment_date);
CREATE INDEX idx_shipments_warehouse ON shipments(origin_warehouse_id);
CREATE INDEX idx_shipments_status ON shipments(status);
CREATE INDEX idx_shipment_orders_shipment ON shipment_orders(shipment_id);
CREATE INDEX idx_shipment_orders_order ON shipment_orders(order_id);
CREATE INDEX idx_vehicle_availability_date ON vehicle_availability(date);
CREATE INDEX idx_driver_availability_date ON driver_availability(date);
