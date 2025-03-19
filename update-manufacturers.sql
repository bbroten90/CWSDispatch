-- Insert or update manufacturers based on the CSV data
-- This is a template - you'll need to run this with actual values

-- Bayer Crop Science (Roundup)
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (1100, 'Bayer Crop Science (Roundup)')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Bayer Crop Science (Roundup)', updated_at = CURRENT_TIMESTAMP;

-- Bayer Roundup (Shuttles)
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (1150, 'Bayer Roundup (Shuttles)')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Bayer Roundup (Shuttles)', updated_at = CURRENT_TIMESTAMP;

-- Interprovincial Co-Operative Ltd.
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (1700, 'Interprovincial Co-Operative Ltd.')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Interprovincial Co-Operative Ltd.', updated_at = CURRENT_TIMESTAMP;

-- Interprovincial Co-Operative Ltd. (Empties)/Shuttles
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (1701, 'Interprovincial Co-Operative Ltd. (Empties)/Shuttles')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Interprovincial Co-Operative Ltd. (Empties)/Shuttles', updated_at = CURRENT_TIMESTAMP;

-- Bayer Cropscience (Parts)
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (1911, 'Bayer Cropscience (Parts)')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Bayer Cropscience (Parts)', updated_at = CURRENT_TIMESTAMP;

-- Bayer Cropscience (Seed)
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (1930, 'Bayer Cropscience (Seed)')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Bayer Cropscience (Seed)', updated_at = CURRENT_TIMESTAMP;

-- Bayer Cropscience (Chem)
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (1940, 'Bayer Cropscience (Chem)')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Bayer Cropscience (Chem)', updated_at = CURRENT_TIMESTAMP;

-- Bayer Cropscience (Packaging)
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (1941, 'Bayer Cropscience (Packaging)')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Bayer Cropscience (Packaging)', updated_at = CURRENT_TIMESTAMP;

-- Bayer Cropscience (Shuttles)
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (1942, 'Bayer Cropscience (Shuttles)')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Bayer Cropscience (Shuttles)', updated_at = CURRENT_TIMESTAMP;

-- BASF Ag Specialties Ltd. (2-219 Revenue Rd)
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (2219, 'BASF Ag Specialties Ltd. (2-219 Revenue Rd)')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'BASF Ag Specialties Ltd. (2-219 Revenue Rd)', updated_at = CURRENT_TIMESTAMP;

-- Sipcam Agro
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (2525, 'Sipcam Agro')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Sipcam Agro', updated_at = CURRENT_TIMESTAMP;

-- AgResource/Cargill
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (2760, 'AgResource/Cargill')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'AgResource/Cargill', updated_at = CURRENT_TIMESTAMP;

-- BASF Canada (Shuttles)
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (2902, 'BASF Canada (Shuttles)')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'BASF Canada (Shuttles)', updated_at = CURRENT_TIMESTAMP;

-- Seed - BASF Agriculture Solutions Ontario LTD
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (2903, 'Seed - BASF Agriculture Solutions Ontario LTD')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Seed - BASF Agriculture Solutions Ontario LTD', updated_at = CURRENT_TIMESTAMP;

-- BASF Canada
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (2909, 'BASF Canada')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'BASF Canada', updated_at = CURRENT_TIMESTAMP;

-- BASF Canada (Packaging)
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (2931, 'BASF Canada (Packaging)')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'BASF Canada (Packaging)', updated_at = CURRENT_TIMESTAMP;

-- BASF Canada (Parts)
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (2990, 'BASF Canada (Parts)')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'BASF Canada (Parts)', updated_at = CURRENT_TIMESTAMP;

-- BASF Agriculture Specialties
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (2999, 'BASF Agriculture Specialties')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'BASF Agriculture Specialties', updated_at = CURRENT_TIMESTAMP;

-- Federated Co-operatives Ltd.
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (3000, 'Federated Co-operatives Ltd.')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Federated Co-operatives Ltd.', updated_at = CURRENT_TIMESTAMP;

-- Gowan Agro Canada
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (3343, 'Gowan Agro Canada')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Gowan Agro Canada', updated_at = CURRENT_TIMESTAMP;

-- Mansfield Oil
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (4400, 'Mansfield Oil')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Mansfield Oil', updated_at = CURRENT_TIMESTAMP;

-- CWS Logistics Ltd.
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (9000, 'CWS Logistics Ltd.')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'CWS Logistics Ltd.', updated_at = CURRENT_TIMESTAMP;

-- CWS - Disposal
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (9050, 'CWS - Disposal')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'CWS - Disposal', updated_at = CURRENT_TIMESTAMP;

-- Cws - Waste Water Tote
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (9051, 'Cws - Waste Water Tote')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Cws - Waste Water Tote', updated_at = CURRENT_TIMESTAMP;

-- Cws Inventory Test Account
INSERT INTO manufacturers (manufacturer_id, name) 
VALUES (9999, 'Cws Inventory Test Account')
ON CONFLICT (manufacturer_id) 
DO UPDATE SET name = 'Cws Inventory Test Account', updated_at = CURRENT_TIMESTAMP;
