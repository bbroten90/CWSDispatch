--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: api_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_logs (
    log_id integer NOT NULL,
    request_type character varying(50) NOT NULL,
    endpoint character varying(255) NOT NULL,
    request_body text,
    response_body text,
    status_code integer,
    ip_address character varying(50),
    user_agent text,
    duration_ms integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: api_logs_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_logs_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_logs_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_logs_log_id_seq OWNED BY public.api_logs.log_id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    customer_id integer NOT NULL,
    company_name character varying(100) NOT NULL,
    address character varying(255),
    city character varying(100) NOT NULL,
    province character varying(50) NOT NULL,
    postal_code character varying(20),
    latitude numeric(10,6),
    longitude numeric(10,6),
    contact_name character varying(100),
    contact_email character varying(100),
    contact_phone character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_customer_id_seq OWNED BY public.customers.customer_id;


--
-- Name: driver_availability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.driver_availability (
    availability_id integer NOT NULL,
    driver_id integer,
    date date NOT NULL,
    is_available boolean DEFAULT true,
    reason character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: driver_availability_availability_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.driver_availability_availability_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: driver_availability_availability_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.driver_availability_availability_id_seq OWNED BY public.driver_availability.availability_id;


--
-- Name: drivers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drivers (
    driver_id integer NOT NULL,
    samsara_id character varying(100),
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(100),
    phone character varying(20),
    license_number character varying(50),
    license_expiry date,
    home_warehouse_id integer,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: drivers_driver_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drivers_driver_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drivers_driver_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drivers_driver_id_seq OWNED BY public.drivers.driver_id;


--
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.manufacturers (
    manufacturer_id integer NOT NULL,
    name character varying(100) NOT NULL,
    api_key character varying(255),
    contact_name character varying(100),
    contact_email character varying(100),
    contact_phone character varying(20),
    webhook_url character varying(255),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: manufacturers_manufacturer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.manufacturers_manufacturer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: manufacturers_manufacturer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.manufacturers_manufacturer_id_seq OWNED BY public.manufacturers.manufacturer_id;


--
-- Name: optimization_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.optimization_logs (
    log_id integer NOT NULL,
    optimization_type character varying(50) NOT NULL,
    input_parameters text,
    output_result text,
    execution_time_ms integer,
    success boolean,
    error_message text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: optimization_logs_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.optimization_logs_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: optimization_logs_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.optimization_logs_log_id_seq OWNED BY public.optimization_logs.log_id;


--
-- Name: order_headers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_headers (
    order_id integer NOT NULL,
    document_id character varying(50) NOT NULL,
    manufacturer_id integer,
    order_date date NOT NULL,
    po_number character varying(50),
    requested_shipment_date date,
    requested_delivery_date date,
    customer_id integer,
    special_requirements text,
    status character varying(50) DEFAULT 'RECEIVED'::character varying,
    total_quantity integer,
    total_weight_kg numeric(10,2),
    total_volume_cubic_m numeric(10,2),
    estimated_revenue numeric(10,2),
    actual_revenue numeric(10,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: order_headers_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_headers_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_headers_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_headers_order_id_seq OWNED BY public.order_headers.order_id;


--
-- Name: order_line_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_line_items (
    line_item_id integer NOT NULL,
    order_id integer,
    product_id character varying(50),
    quantity integer NOT NULL,
    weight_kg numeric(10,2) NOT NULL,
    volume_cubic_m numeric(10,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: order_line_items_line_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_line_items_line_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_line_items_line_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_line_items_line_item_id_seq OWNED BY public.order_line_items.line_item_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    product_id character varying(50) NOT NULL,
    manufacturer_id integer,
    name character varying(255) NOT NULL,
    description text,
    weight_kg numeric(10,2) NOT NULL,
    volume_cubic_m numeric(10,2),
    requires_refrigeration boolean DEFAULT false,
    requires_heating boolean DEFAULT false,
    is_dangerous_good boolean DEFAULT false,
    tdg_number character varying(50),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: rate_tables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rate_tables (
    rate_id integer NOT NULL,
    destination_city character varying(255),
    destination_province character varying(10),
    min_weight_lb numeric(10,2),
    weight_per_0_1999lbs numeric(10,2),
    weight_per_2000_4999lbs numeric(10,2),
    weight_per_5000_9999lbs numeric(10,2),
    weight_per_10000_19999lbs numeric(10,2),
    weight_per_20000_29999lbs numeric(10,2),
    weight_per_30000_39999lbs numeric(10,2),
    weight_over_4000lbs numeric(10,2),
    tl_rate numeric(10,2),
    origin_warehouse_id character varying(255),
    customer_name character varying(255)
);


--
-- Name: rate_tables_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rate_tables_rate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rate_tables_rate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rate_tables_rate_id_seq OWNED BY public.rate_tables.rate_id;


--
-- Name: shipment_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipment_orders (
    shipment_order_id integer NOT NULL,
    shipment_id integer,
    order_id integer,
    stop_sequence integer NOT NULL,
    estimated_arrival_time timestamp without time zone,
    actual_arrival_time timestamp without time zone,
    status character varying(50) DEFAULT 'PLANNED'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: shipment_orders_shipment_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shipment_orders_shipment_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shipment_orders_shipment_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shipment_orders_shipment_order_id_seq OWNED BY public.shipment_orders.shipment_order_id;


--
-- Name: shipments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments (
    shipment_id integer NOT NULL,
    shipment_date date NOT NULL,
    origin_warehouse_id integer,
    truck_id integer,
    trailer_id integer,
    driver_id integer,
    status character varying(50) DEFAULT 'PLANNED'::character varying,
    total_distance_km numeric(10,2),
    estimated_start_time timestamp without time zone,
    actual_start_time timestamp without time zone,
    estimated_completion_time timestamp without time zone,
    actual_completion_time timestamp without time zone,
    total_weight_kg numeric(10,2),
    total_volume_cubic_m numeric(10,2),
    total_revenue numeric(10,2),
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: shipments_shipment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shipments_shipment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shipments_shipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shipments_shipment_id_seq OWNED BY public.shipments.shipment_id;


--
-- Name: vehicle_availability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_availability (
    availability_id integer NOT NULL,
    vehicle_id integer,
    date date NOT NULL,
    is_available boolean DEFAULT true,
    reason character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: vehicle_availability_availability_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicle_availability_availability_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicle_availability_availability_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicle_availability_availability_id_seq OWNED BY public.vehicle_availability.availability_id;


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicles (
    vehicle_id integer NOT NULL,
    samsara_id character varying(100),
    type character varying(50) NOT NULL,
    license_plate character varying(20),
    make character varying(50),
    model character varying(50),
    year integer,
    max_weight_kg numeric(10,2) NOT NULL,
    volume_capacity_cubic_m numeric(10,2),
    has_refrigeration boolean DEFAULT false,
    has_heating boolean DEFAULT false,
    has_tdg_capacity boolean DEFAULT false,
    home_warehouse_id integer,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicles_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicles_vehicle_id_seq OWNED BY public.vehicles.vehicle_id;


--
-- Name: warehouses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.warehouses (
    warehouse_id integer NOT NULL,
    name character varying(100) NOT NULL,
    address character varying(255) NOT NULL,
    city character varying(100) NOT NULL,
    province character varying(50) NOT NULL,
    postal_code character varying(20) NOT NULL,
    latitude numeric(10,6),
    longitude numeric(10,6),
    loading_capacity integer,
    storage_capacity numeric(10,2),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.warehouses_warehouse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.warehouses_warehouse_id_seq OWNED BY public.warehouses.warehouse_id;


--
-- Name: api_logs log_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_logs ALTER COLUMN log_id SET DEFAULT nextval('public.api_logs_log_id_seq'::regclass);


--
-- Name: customers customer_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN customer_id SET DEFAULT nextval('public.customers_customer_id_seq'::regclass);


--
-- Name: driver_availability availability_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_availability ALTER COLUMN availability_id SET DEFAULT nextval('public.driver_availability_availability_id_seq'::regclass);


--
-- Name: drivers driver_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drivers ALTER COLUMN driver_id SET DEFAULT nextval('public.drivers_driver_id_seq'::regclass);


--
-- Name: manufacturers manufacturer_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manufacturers ALTER COLUMN manufacturer_id SET DEFAULT nextval('public.manufacturers_manufacturer_id_seq'::regclass);


--
-- Name: optimization_logs log_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.optimization_logs ALTER COLUMN log_id SET DEFAULT nextval('public.optimization_logs_log_id_seq'::regclass);


--
-- Name: order_headers order_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_headers ALTER COLUMN order_id SET DEFAULT nextval('public.order_headers_order_id_seq'::regclass);


--
-- Name: order_line_items line_item_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_items ALTER COLUMN line_item_id SET DEFAULT nextval('public.order_line_items_line_item_id_seq'::regclass);


--
-- Name: rate_tables rate_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rate_tables ALTER COLUMN rate_id SET DEFAULT nextval('public.rate_tables_rate_id_seq'::regclass);


--
-- Name: shipment_orders shipment_order_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipment_orders ALTER COLUMN shipment_order_id SET DEFAULT nextval('public.shipment_orders_shipment_order_id_seq'::regclass);


--
-- Name: shipments shipment_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments ALTER COLUMN shipment_id SET DEFAULT nextval('public.shipments_shipment_id_seq'::regclass);


--
-- Name: vehicle_availability availability_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_availability ALTER COLUMN availability_id SET DEFAULT nextval('public.vehicle_availability_availability_id_seq'::regclass);


--
-- Name: vehicles vehicle_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN vehicle_id SET DEFAULT nextval('public.vehicles_vehicle_id_seq'::regclass);


--
-- Name: warehouses warehouse_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouses ALTER COLUMN warehouse_id SET DEFAULT nextval('public.warehouses_warehouse_id_seq'::regclass);


--
-- Data for Name: api_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.api_logs (log_id, request_type, endpoint, request_body, response_body, status_code, ip_address, user_agent, duration_ms, created_at) FROM stdin;
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customers (customer_id, company_name, address, city, province, postal_code, latitude, longitude, contact_name, contact_email, contact_phone, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: driver_availability; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.driver_availability (availability_id, driver_id, date, is_available, reason, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: drivers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.drivers (driver_id, samsara_id, first_name, last_name, email, phone, license_number, license_expiry, home_warehouse_id, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: manufacturers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.manufacturers (manufacturer_id, name, api_key, contact_name, contact_email, contact_phone, webhook_url, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: optimization_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.optimization_logs (log_id, optimization_type, input_parameters, output_result, execution_time_ms, success, error_message, created_at) FROM stdin;
\.


--
-- Data for Name: order_headers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_headers (order_id, document_id, manufacturer_id, order_date, po_number, requested_shipment_date, requested_delivery_date, customer_id, special_requirements, status, total_quantity, total_weight_kg, total_volume_cubic_m, estimated_revenue, actual_revenue, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: order_line_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_line_items (line_item_id, order_id, product_id, quantity, weight_kg, volume_cubic_m, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (product_id, manufacturer_id, name, description, weight_kg, volume_cubic_m, requires_refrigeration, requires_heating, is_dangerous_good, tdg_number, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: rate_tables; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rate_tables (rate_id, destination_city, destination_province, min_weight_lb, weight_per_0_1999lbs, weight_per_2000_4999lbs, weight_per_5000_9999lbs, weight_per_10000_19999lbs, weight_per_20000_29999lbs, weight_per_30000_39999lbs, weight_over_4000lbs, tl_rate, origin_warehouse_id, customer_name) FROM stdin;
1	Acadia Valley	AB	195.57	17.35	15.72	10.84	7.05	4.61	3.59	2.71	1084.13	Calgary	BASF
2	Airdrie	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
3	Alix	AB	195.57	8.73	7.91	5.45	3.54	2.32	1.81	1.36	545.38	Calgary	BASF
4	Alliance	AB	195.57	13.84	12.54	8.65	5.62	3.68	2.86	2.16	864.86	Calgary	BASF
5	Amisk	AB	195.57	15.08	13.67	9.43	6.13	4.01	3.12	2.36	942.67	Calgary	BASF
6	Andrew	AB	195.57	12.43	11.27	7.77	5.05	3.30	2.57	1.94	777.03	Calgary	BASF
7	Athabasca	AB	195.57	14.18	12.85	8.86	5.76	3.77	2.93	2.21	885.98	Calgary	BASF
8	Balzac	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
9	Barons	AB	195.57	8.23	7.46	5.14	3.34	2.19	1.70	1.29	514.34	Calgary	BASF
10	Barrhead	AB	195.57	12.85	11.65	8.03	5.22	3.41	2.66	2.01	803.39	Calgary	BASF
11	Bashaw	AB	195.57	8.87	8.04	5.54	3.60	2.36	1.84	1.39	554.38	Calgary	BASF
12	Bassano	AB	195.57	6.50	5.89	4.06	2.64	1.73	1.34	1.01	382.96	Calgary	BASF
13	Bay Tree	AB	221.18	22.12	20.04	13.82	8.99	5.88	4.58	3.46	1382.35	Calgary	BASF
14	Beaverlodge	AB	357.60	35.76	32.41	22.35	14.53	9.50	7.40	5.59	2234.97	Calgary	BASF
15	Beiseker	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
16	Benalto	AB	195.57	8.44	7.65	5.27	3.43	2.24	1.75	1.32	527.39	Calgary	BASF
17	Bentley	AB	195.57	8.08	7.32	5.05	3.28	2.15	1.67	1.26	504.90	Calgary	BASF
18	Blackfalds	AB	195.57	7.39	6.70	4.62	3.00	1.96	1.53	1.16	462.16	Calgary	BASF
19	Blackie	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
20	Bon Accord	AB	195.57	9.01	8.17	5.63	3.66	2.39	1.87	1.41	563.37	Calgary	BASF
21	Bonnyville	AB	195.72	19.57	17.74	12.23	7.95	5.20	4.05	3.06	1223.24	Calgary	BASF
22	Bow Island	AB	195.57	16.82	15.24	10.51	6.83	4.47	3.48	2.63	1051.12	Calgary	BASF
23	Boyle	AB	195.57	14.18	12.85	8.86	5.76	3.77	2.93	2.21	885.98	Calgary	BASF
24	Brooks	AB	195.57	8.87	8.04	5.54	3.60	2.36	1.84	1.39	554.38	Calgary	BASF
25	Burdett	AB	195.57	15.46	14.01	9.66	6.28	4.11	3.20	2.42	966.25	Calgary	BASF
26	Calgary	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Calgary	BASF
27	Calmar	AB	195.57	7.97	7.22	4.98	3.24	2.12	1.65	1.25	498.15	Calgary	BASF
28	Camrose	AB	195.57	8.91	8.07	5.57	3.62	2.37	1.84	1.39	556.62	Calgary	BASF
29	Carbon	AB	195.57	5.85	5.30	3.65	2.38	1.55	1.21	0.91	365.46	Calgary	BASF
30	Cardston	AB	195.57	11.39	10.32	7.12	4.63	3.02	2.36	1.78	711.61	Calgary	BASF
31	Carseland	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
32	Carstairs	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
33	Castor	AB	195.57	12.74	11.55	7.96	5.18	3.39	2.64	1.99	796.49	Calgary	BASF
34	Clandonald	AB	195.57	18.25	16.54	11.41	7.41	4.85	3.78	2.85	1140.72	Calgary	BASF
35	Claresholm	AB	195.57	6.42	5.82	4.01	2.61	1.71	1.33	1.00	401.44	Calgary	BASF
36	Clyde	AB	195.57	10.71	9.70	6.69	4.35	2.84	2.22	1.67	669.08	Calgary	BASF
37	Coaldale	AB	195.57	11.16	10.11	6.97	4.53	2.96	2.31	1.74	697.47	Calgary	BASF
38	Cochrane	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
39	Consort	AB	195.57	16.59	15.04	10.37	6.74	4.41	3.43	2.59	1036.98	Calgary	BASF
40	Coronation	AB	195.57	13.61	12.34	8.51	5.53	3.62	2.82	2.13	850.72	Calgary	BASF
41	Cranford	AB	195.57	12.33	11.18	7.71	5.01	3.28	2.55	1.93	763.17	Calgary	BASF
42	Cremona	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
43	Crossfield	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
44	Cypress County	AB	195.57	14.18	12.85	8.86	5.76	3.77	2.93	2.22	886.08	Calgary	BASF
45	Czar	AB	195.57	16.89	15.31	10.56	6.86	4.49	3.50	2.64	1055.84	Calgary	BASF
46	Daysland	AB	195.57	10.89	9.86	6.80	4.42	2.89	2.25	1.70	680.32	Calgary	BASF
47	Debolt	AB	305.85	30.59	27.72	19.12	12.43	8.12	6.33	4.78	1911.57	Calgary	BASF
48	Delburne	AB	195.57	8.80	7.97	5.50	3.57	2.34	1.82	1.37	549.88	Calgary	BASF
49	Delia	AB	195.57	9.01	8.17	5.63	3.66	2.39	1.87	1.41	563.37	Calgary	BASF
50	Dewberry	AB	195.57	18.78	17.02	11.74	7.63	4.99	3.89	2.93	1173.72	Calgary	BASF
51	Diamond City	AB	195.57	9.66	8.76	6.04	3.92	2.56	2.00	1.51	603.85	Calgary	BASF
52	Dickson (Spruceview)	AB	195.57	7.36	6.67	4.60	2.99	1.95	1.52	1.15	459.92	Calgary	BASF
53	Didsbury	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
54	Drayton Valley	AB	195.57	10.89	9.86	6.80	4.42	2.89	2.25	1.70	680.32	Calgary	BASF
55	Drumheller	AB	195.57	6.85	6.21	4.28	2.78	1.82	1.42	1.07	404.18	Calgary	BASF
56	Dunmore	AB	195.57	14.63	13.26	9.14	5.94	3.89	3.03	2.29	862.55	Calgary	BASF
57	Eaglesham	AB	347.76	34.78	31.52	21.73	14.13	9.24	7.20	5.43	2173.50	Calgary	BASF
58	Eckville	AB	195.57	8.98	8.14	5.61	3.65	2.38	1.86	1.40	561.12	Calgary	BASF
59	Edberg	AB	195.57	9.34	8.46	5.84	3.79	2.48	1.93	1.46	583.61	Calgary	BASF
60	Edgerton	AB	195.57	17.80	16.13	11.12	7.23	4.73	3.68	2.78	1112.42	Calgary	BASF
61	Edmonton	AB	195.57	7.39	6.70	4.62	3.00	1.96	1.53	1.15	435.62	Calgary	BASF
62	Enchant	AB	195.57	12.52	11.34	7.82	5.09	3.32	2.59	1.96	782.35	Calgary	BASF
63	Ervick	AB	195.57	8.51	7.71	5.32	3.46	2.26	1.76	1.33	531.89	Calgary	BASF
64	Evansburg	AB	195.57	12.00	10.88	7.50	4.88	3.19	2.48	1.88	750.04	Calgary	BASF
65	Fairview	AB	389.67	38.97	35.31	24.35	15.83	10.35	8.06	6.09	2435.43	Calgary	BASF
66	Falher	AB	321.25	32.12	29.11	20.08	13.05	8.53	6.65	5.02	2007.79	Calgary	BASF
67	Foremost	AB	195.57	15.99	14.49	9.99	6.50	4.25	3.31	2.50	999.25	Calgary	BASF
68	Forestburg	AB	195.57	11.17	10.13	6.98	4.54	2.97	2.31	1.75	698.32	Calgary	BASF
69	Fort MacLeod	AB	195.57	8.15	7.39	5.09	3.31	2.16	1.69	1.27	509.39	Calgary	BASF
70	Fort Saskatchewan	AB	195.57	8.69	7.88	5.43	3.53	2.31	1.80	1.36	543.13	Calgary	BASF
71	Fort Vermilion	AB	352.69	35.62	32.28	22.26	14.47	9.46	7.37	5.57	2204.31	Calgary	BASF
72	Galahad	AB	195.57	11.89	10.78	7.43	4.83	3.16	2.46	1.86	743.30	Calgary	BASF
73	Girouxville	AB	327.23	32.72	29.66	20.45	13.29	8.69	6.77	5.11	2045.21	Calgary	BASF
74	Gleichen	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
75	Glendon	AB	195.57	18.25	16.54	11.41	7.41	4.85	3.78	2.85	1140.72	Calgary	BASF
76	Grande Prairie	AB	334.93	33.49	30.35	20.93	13.61	8.90	6.93	5.23	2093.32	Calgary	BASF
77	Grassy Lake	AB	195.57	14.86	13.46	9.29	6.04	3.95	3.07	2.32	928.52	Calgary	BASF
78	Greenway	AB	195.57	5.92	5.36	3.70	2.40	1.57	1.23	0.92	369.95	Calgary	BASF
79	Grimshaw	AB	364.01	36.40	32.99	22.75	14.79	9.67	7.53	5.69	2275.07	Calgary	BASF
80	Guy	AB	307.99	30.80	27.91	19.25	12.51	8.18	6.37	4.81	1924.93	Calgary	BASF
81	Hairy Hill	AB	195.57	12.86	11.66	8.04	5.23	3.42	2.66	2.01	804.02	Calgary	BASF
82	Halkirk	AB	195.57	11.73	10.63	7.33	4.76	3.11	2.43	1.83	732.83	Calgary	BASF
83	Hanna	AB	195.57	10.63	9.63	6.64	4.32	2.82	2.20	1.66	626.85	Calgary	BASF
84	Heisler	AB	195.57	11.23	10.18	7.02	4.56	2.98	2.33	1.76	702.18	Calgary	BASF
85	Herronton	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
86	High Level	AB	505.99	50.60	45.86	31.62	20.56	13.44	10.47	7.91	3162.43	Calgary	BASF
87	High Prairie	AB	283.19	28.32	25.66	17.70	11.50	7.52	5.86	4.42	1769.91	Calgary	BASF
88	High River	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
89	Hines Creek	AB	398.22	39.82	36.09	24.89	16.18	10.58	8.24	6.22	2488.89	Calgary	BASF
90	Holden	AB	195.57	10.67	9.67	6.67	4.33	2.83	2.21	1.67	666.83	Calgary	BASF
91	Hussar	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
92	Hythe	AB	367.43	36.74	33.30	22.96	14.93	9.76	7.60	5.74	2296.45	Calgary	BASF
93	Innisfail	AB	195.57	5.92	5.36	3.70	2.40	1.57	1.23	0.92	369.95	Calgary	BASF
94	Innisfree	AB	195.57	13.51	12.25	8.45	5.49	3.59	2.80	2.11	844.50	Calgary	BASF
95	Irma	AB	195.57	14.44	13.09	9.03	5.87	3.84	2.99	2.26	902.59	Calgary	BASF
96	Iron Springs	AB	195.57	10.56	9.57	6.60	4.29	2.80	2.18	1.65	659.74	Calgary	BASF
97	Killam	AB	195.57	12.50	11.33	7.82	5.08	3.32	2.59	1.95	781.53	Calgary	BASF
98	Kirriemuir	AB	195.57	18.33	16.61	11.45	7.45	4.87	3.79	2.86	1145.43	Calgary	BASF
99	Kitscoty	AB	195.57	18.14	16.44	11.34	7.37	4.82	3.75	2.83	1133.64	Calgary	BASF
100	Kneehill County	AB	195.57	5.34	4.84	3.34	2.17	1.42	1.11	0.83	333.97	Calgary	BASF
101	La Glace	AB	355.46	35.55	32.21	22.22	14.44	9.44	7.36	5.55	2221.61	Calgary	BASF
102	Lac La Biche	AB	195.57	17.84	16.16	11.15	7.25	4.74	3.69	2.79	1114.78	Calgary	BASF
103	Lacombe	AB	195.57	7.29	6.60	4.55	2.96	1.94	1.51	1.14	455.42	Calgary	BASF
104	LaCrete	AB	455.10	45.51	41.24	28.44	18.49	12.09	9.42	7.11	2844.37	Calgary	BASF
105	Lamont	AB	195.57	10.27	9.31	6.42	4.17	2.73	2.13	1.61	642.09	Calgary	BASF
106	Lavoy	AB	195.57	12.36	11.20	7.73	5.02	3.28	2.56	1.93	772.53	Calgary	BASF
107	Leduc	AB	195.57	7.32	6.64	4.58	2.97	1.95	1.52	1.14	457.67	Calgary	BASF
108	Legal	AB	195.57	9.73	8.82	6.08	3.95	2.59	2.01	1.52	608.35	Calgary	BASF
109	Lethbridge	AB	195.57	9.27	8.40	5.79	3.77	2.46	2.03	1.45	577.36	Calgary	BASF
110	Linden	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
111	Lloydminster	AB	195.57	19.12	17.33	11.95	7.77	5.08	3.96	2.99	1194.94	Calgary	BASF
112	Lomond	AB	195.57	8.51	7.71	5.32	3.46	2.26	1.76	1.33	531.89	Calgary	BASF
113	Lougheed	AB	195.57	13.88	12.57	8.67	5.64	3.69	2.87	2.17	867.22	Calgary	BASF
114	Lyalta	AB	195.57	5.44	4.93	3.40	2.22	1.45	1.13	0.85	336.82	Calgary	BASF
115	Magrath	AB	195.57	12.06	10.93	7.54	4.90	3.20	2.50	1.89	754.05	Calgary	BASF
116	Mallaig	AB	195.57	16.57	15.02	10.36	6.73	4.40	3.43	2.59	1035.67	Calgary	BASF
117	Manning	AB	403.35	40.34	36.55	25.21	16.39	10.71	8.35	6.30	2520.96	Calgary	BASF
118	Marwayne	AB	195.57	19.01	17.22	11.88	7.72	5.05	3.93	2.97	1187.87	Calgary	BASF
119	Mayerthorpe	AB	195.57	12.27	11.12	7.67	4.98	3.26	2.54	1.92	766.69	Calgary	BASF
120	McLennan	AB	309.70	30.97	28.07	19.36	12.58	8.23	6.41	4.84	1935.62	Calgary	BASF
121	Medicine Hat	AB	195.57	14.18	12.85	8.86	5.76	3.77	2.93	2.22	886.08	Calgary	BASF
122	Milk River	AB	195.57	14.40	13.05	9.00	5.85	3.83	2.98	2.25	900.23	Calgary	BASF
123	Milo	AB	195.57	6.78	6.15	4.24	2.76	1.80	1.40	1.06	423.93	Calgary	BASF
124	Minburn	AB	195.57	14.16	12.83	8.85	5.75	3.76	2.93	2.21	884.99	Calgary	BASF
125	Morinville	AB	195.57	8.80	7.97	5.50	3.57	2.34	1.82	1.37	549.88	Calgary	BASF
126	Mossleigh	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
127	Mundare	AB	195.57	10.99	9.96	6.87	4.47	2.92	2.28	1.72	687.07	Calgary	BASF
128	Myrnam	AB	195.57	15.17	13.75	9.48	6.16	4.03	3.14	2.37	947.96	Calgary	BASF
129	Nampa	AB	336.64	33.66	30.51	21.04	13.68	8.94	6.97	5.26	2104.01	Calgary	BASF
130	Nanton	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
131	Neerlandia	AB	195.57	13.85	12.55	8.65	5.62	3.68	2.87	2.16	865.33	Calgary	BASF
132	New Dayton	AB	195.57	12.52	11.34	7.82	5.09	3.32	2.59	1.96	782.35	Calgary	BASF
133	New Norway	AB	195.57	8.69	7.88	5.43	3.53	2.31	1.80	1.36	543.13	Calgary	BASF
134	Nisku	AB	195.57	7.32	6.64	4.58	2.97	1.95	1.52	1.14	457.67	Calgary	BASF
135	Nobleford	AB	195.57	8.65	7.84	5.41	3.52	2.30	1.79	1.35	540.88	Calgary	BASF
136	Okotoks	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
137	Olds	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
138	Onoway	AB	195.57	10.09	9.15	6.31	4.10	2.68	2.09	1.58	630.84	Calgary	BASF
139	Oyen	AB	195.57	16.06	14.56	10.04	6.53	4.27	3.32	2.51	1003.97	Calgary	BASF
140	Paradise Valley	AB	195.72	19.57	17.74	12.23	7.95	5.20	4.05	3.06	1223.24	Calgary	BASF
141	Peers	AB	195.57	15.24	13.81	9.52	6.19	4.05	3.15	2.38	952.46	Calgary	BASF
142	Penhold	AB	195.57	6.42	5.82	4.01	2.61	1.71	1.33	1.00	401.44	Calgary	BASF
143	Picture Butte	AB	195.57	9.95	9.02	6.22	4.04	2.64	2.06	1.56	622.02	Calgary	BASF
144	Pincher Creek	AB	195.57	10.63	9.63	6.64	4.32	2.82	2.20	1.66	664.46	Calgary	BASF
145	Ponoka	AB	195.57	7.47	6.77	4.67	3.03	1.98	1.55	1.17	466.66	Calgary	BASF
146	Provost	AB	195.57	18.18	16.47	11.36	7.38	4.83	3.76	2.84	1136.00	Calgary	BASF
147	Raymond	AB	195.57	11.99	10.87	7.49	4.87	3.18	2.48	1.87	749.34	Calgary	BASF
148	Red Deer	AB	195.57	7.21	6.54	4.51	2.93	1.92	1.49	1.13	450.92	Calgary	BASF
149	Rimbey	AB	195.57	8.47	7.68	5.30	3.44	2.25	1.75	1.32	529.64	Calgary	BASF
150	Rivercourse	AB	206.28	20.63	18.69	12.89	8.38	5.48	4.27	3.22	1289.25	Calgary	BASF
151	Rocky Mountain House	AB	195.57	11.05	10.01	6.90	4.49	2.93	2.29	1.73	690.39	Calgary	BASF
152	Rocky View	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Calgary	BASF
153	Rolling Hills	AB	195.57	11.31	10.25	7.07	4.59	3.00	2.34	1.77	706.90	Calgary	BASF
154	Rosalind	AB	195.57	10.24	9.28	6.40	4.16	2.72	2.12	1.60	639.84	Calgary	BASF
155	Rosebud (Kneehill County)	AB	195.57	5.34	4.84	3.34	2.17	1.42	1.11	0.83	333.97	Calgary	BASF
156	Rosedale	AB	195.57	7.07	6.41	4.42	2.87	1.88	1.46	1.10	441.92	Calgary	BASF
157	Rycroft	AB	367.00	36.70	33.26	22.94	14.91	9.75	7.60	5.73	2293.78	Calgary	BASF
158	Ryley	AB	195.57	10.74	9.73	6.71	4.36	2.85	2.22	1.68	671.33	Calgary	BASF
159	Scandia	AB	195.57	10.38	9.41	6.49	4.22	2.76	2.15	1.62	648.84	Calgary	BASF
160	Sedgewick	AB	195.57	13.57	12.30	8.48	5.51	3.61	2.81	2.12	848.36	Calgary	BASF
161	Sexsmith	AB	340.92	34.09	30.90	21.31	13.85	9.06	7.06	5.33	2130.74	Calgary	BASF
162	Silver Valley	AB	394.37	39.44	35.74	24.65	16.02	10.48	8.16	6.16	2464.83	Calgary	BASF
163	Slave Lake	AB	195.57	19.35	17.53	12.09	7.86	5.14	4.00	3.02	1209.09	Calgary	BASF
164	Smoky Lake	AB	195.57	12.40	11.23	7.75	5.04	3.29	2.57	1.94	774.78	Calgary	BASF
165	Spirit River	AB	371.28	37.13	33.65	23.21	15.08	9.86	7.68	5.80	2320.50	Calgary	BASF
166	Spruce Grove	AB	195.57	8.47	7.68	5.30	3.44	2.25	1.75	1.32	529.64	Calgary	BASF
167	Spruce View	AB	195.57	7.29	6.60	4.55	2.96	1.94	1.51	1.14	455.42	Calgary	BASF
168	St Albert	AB	195.57	7.93	7.19	4.96	3.22	2.11	1.64	1.24	495.90	Calgary	BASF
169	St Isidore	AB	345.19	34.52	31.28	21.57	14.02	9.17	7.14	5.39	2157.46	Calgary	BASF
170	St Paul	AB	195.57	17.04	15.45	10.65	6.92	4.53	3.53	2.66	1065.27	Calgary	BASF
171	Standard	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Calgary	BASF
172	Stanmore	AB	195.57	12.14	11.01	7.58	4.93	3.23	2.51	1.90	758.77	Calgary	BASF
173	Stettler	AB	195.57	9.77	8.85	6.11	3.97	2.60	2.02	1.53	610.60	Calgary	BASF
174	Stirling	AB	195.57	11.91	10.80	7.45	4.84	3.16	2.47	1.86	744.62	Calgary	BASF
175	Stony Plain	AB	195.57	8.76	7.94	5.48	3.56	2.33	1.81	1.37	547.63	Calgary	BASF
176	Strathmore	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Calgary	BASF
177	Strome	AB	195.57	11.60	10.52	7.25	4.71	3.08	2.40	1.81	725.30	Calgary	BASF
178	Sturgeon County	AB	195.57	9.73	8.82	6.08	3.95	2.59	2.01	1.52	608.35	Calgary	BASF
179	Sturgeon Valley	AB	195.57	8.26	7.48	5.16	3.35	2.19	1.71	1.29	516.14	Calgary	BASF
180	Sunnybrook	AB	195.57	8.91	8.07	5.57	3.62	2.37	1.84	1.39	556.62	Calgary	BASF
181	Sylvan Lake	AB	195.57	8.04	7.29	5.03	3.27	2.14	1.66	1.26	502.65	Calgary	BASF
182	Taber	AB	195.57	13.42	12.16	8.39	5.45	3.57	2.78	2.10	793.49	Calgary	BASF
183	Thorhild	AB	195.57	10.96	9.93	6.85	4.45	2.91	2.27	1.71	684.82	Calgary	BASF
184	Three Hills	AB	195.57	6.57	5.95	4.10	2.67	1.74	1.36	1.03	387.20	Calgary	BASF
185	Tofield	AB	195.57	9.91	8.98	6.20	4.03	2.63	2.05	1.55	619.60	Calgary	BASF
186	Torrington	AB	195.57	5.85	5.30	3.65	2.38	1.55	1.21	0.91	344.77	Calgary	BASF
187	Trochu	AB	195.57	7.14	6.47	4.46	2.90	1.90	1.48	1.12	446.42	Calgary	BASF
188	Turin	AB	195.57	11.39	10.32	7.12	4.63	3.02	2.36	1.78	711.61	Calgary	BASF
189	Two Hills	AB	195.57	13.58	12.31	8.49	5.52	3.61	2.81	2.12	849.00	Calgary	BASF
190	Valleyview	AB	277.20	27.72	25.12	17.32	11.26	7.36	5.74	4.33	1732.49	Calgary	BASF
191	Vauxhall	AB	195.57	11.91	10.80	7.45	4.84	3.16	2.47	1.86	744.62	Calgary	BASF
192	Vegreville	AB	195.57	11.71	10.61	7.32	4.76	3.11	2.42	1.83	732.05	Calgary	BASF
193	Vermilion	AB	195.57	15.67	14.20	9.79	6.37	4.16	3.24	2.45	979.45	Calgary	BASF
194	Veteran	AB	195.57	14.82	13.43	9.26	6.02	3.94	3.07	2.32	926.17	Calgary	BASF
195	Viking	AB	195.57	12.07	10.94	7.55	4.90	3.21	2.50	1.89	754.54	Calgary	BASF
196	Vulcan	AB	195.57	6.35	5.76	3.97	2.58	1.69	1.31	0.99	374.47	Calgary	BASF
197	Wainwright	AB	195.57	16.21	14.69	10.13	6.59	4.31	3.36	2.53	1013.40	Calgary	BASF
198	Wanham	AB	349.04	34.90	31.63	21.82	14.18	9.27	7.22	5.45	2181.52	Calgary	BASF
199	Warburg	AB	195.57	9.09	8.23	5.68	3.69	2.41	1.88	1.42	567.87	Calgary	BASF
200	Warner	AB	195.57	13.50	12.23	8.44	5.48	3.59	2.79	2.11	843.65	Calgary	BASF
201	Waskatenau	AB	195.57	11.68	10.58	7.30	4.74	3.10	2.42	1.82	729.98	Calgary	BASF
202	Westlock	AB	195.57	11.07	10.03	6.92	4.50	2.94	2.29	1.73	691.57	Calgary	BASF
203	Wetaskiwin	AB	195.57	7.50	6.80	4.69	3.05	1.99	1.55	1.17	468.91	Calgary	BASF
204	Whitecourt	AB	195.57	15.89	14.40	9.93	6.45	4.22	3.29	2.48	992.94	Calgary	BASF
205	Willow Springs	AB	195.57	9.01	8.17	5.63	3.66	2.39	1.87	1.41	563.37	Calgary	BASF
206	Winfield	AB	195.57	8.80	7.97	5.50	3.57	2.34	1.82	1.37	549.88	Calgary	BASF
207	Dawson Creek	BC	453.28	45.33	38.44	26.28	17.00	11.07	8.63	6.54	2561.40	Calgary	BASF
208	Delta	BC	577.30	57.73	49.68	34.03	22.04	14.36	11.20	8.48	3336.51	Calgary	BASF
209	Fort St. John	BC	496.05	49.60	42.32	28.95	18.73	12.21	9.52	7.21	2828.68	Calgary	BASF
210	Grindrod	BC	329.27	32.93	27.21	18.53	11.96	7.78	6.07	4.61	1786.29	Calgary	BASF
211	Kamloops	BC	390.85	39.08	32.79	22.37	14.46	9.41	7.34	5.57	2171.17	Calgary	BASF
212	Kelowna	BC	382.30	38.23	32.01	21.84	14.11	9.19	7.16	5.44	2117.72	Calgary	BASF
213	Keremeos	BC	443.88	44.39	37.59	25.69	16.61	10.82	8.44	6.40	2502.60	Calgary	BASF
214	Naramata	BC	402.82	40.28	33.87	23.12	14.95	9.73	7.59	5.76	2246.01	Calgary	BASF
215	Oliver	BC	438.74	43.87	37.13	25.37	16.41	10.68	8.33	6.32	2470.53	Calgary	BASF
216	Penticton	BC	419.07	41.91	35.34	24.14	15.61	10.16	7.93	6.01	2347.58	Calgary	BASF
217	Prince George	BC	534.11	53.41	45.77	31.33	20.28	13.22	10.31	7.81	3066.56	Calgary	BASF
218	Rolla	BC	457.99	45.80	38.87	26.57	17.19	11.20	8.73	6.62	2590.80	Calgary	BASF
219	Vernon	BC	358.35	35.83	29.84	20.34	13.14	8.55	6.67	5.06	1968.04	Calgary	BASF
220	Altamont	MB	345.12	34.51	28.64	19.52	12.60	8.20	6.40	4.85	1885.40	Calgary	BASF
221	Altona	MB	360.32	36.03	30.02	20.47	13.22	8.60	6.71	5.09	1980.36	Calgary	BASF
222	Angusville	MB	361.48	36.15	30.12	20.54	13.27	8.63	6.73	5.11	1987.64	Calgary	BASF
223	Arborg	MB	379.28	37.93	31.74	21.65	13.99	9.11	7.10	5.39	2098.90	Calgary	BASF
224	Arnaud	MB	359.66	35.97	29.96	20.43	13.19	8.58	6.70	5.08	1976.23	Calgary	BASF
225	Baldur	MB	347.28	34.73	28.84	19.65	12.69	8.25	6.44	4.89	1898.86	Calgary	BASF
226	Beausejour	MB	351.73	35.17	29.24	19.93	12.87	8.37	6.53	4.96	1926.69	Calgary	BASF
227	Benito	MB	380.72	38.07	31.87	21.74	14.05	9.14	7.13	5.41	2107.89	Calgary	BASF
228	Binscarth	MB	361.86	36.19	30.16	20.56	13.28	8.64	6.74	5.12	1990.00	Calgary	BASF
229	Birch River	MB	414.67	41.47	34.94	23.86	15.43	10.05	7.83	5.94	2320.08	Calgary	BASF
230	Birtle	MB	367.90	36.79	30.71	20.94	13.53	8.80	6.87	5.21	2027.72	Calgary	BASF
231	Boissevain	MB	395.06	39.51	33.17	22.64	14.63	9.52	7.43	5.63	2197.48	Calgary	BASF
232	Brandon	MB	367.14	36.71	30.64	20.89	13.50	8.78	6.85	5.20	2023.01	Calgary	BASF
233	Brunkild	MB	342.15	34.22	28.37	19.33	12.48	8.12	6.33	4.81	1866.82	Calgary	BASF
234	Carberry	MB	327.62	32.76	27.06	18.42	11.89	7.73	6.03	4.58	1775.99	Calgary	BASF
235	Carman	MB	340.83	34.08	28.25	19.25	12.43	8.08	6.31	4.79	1858.57	Calgary	BASF
236	Cartwright	MB	395.06	39.51	33.17	22.64	14.63	9.52	7.43	5.63	2197.48	Calgary	BASF
237	Crystal City	MB	364.12	36.41	30.36	20.70	13.37	8.70	6.79	5.15	2004.14	Calgary	BASF
238	Cypress River	MB	335.88	33.59	27.80	18.94	12.23	7.95	6.20	4.71	1827.60	Calgary	BASF
239	Darlingford	MB	353.05	35.31	29.36	20.01	12.92	8.41	6.56	4.98	1934.95	Calgary	BASF
240	Dauphin	MB	389.02	38.90	32.62	22.26	14.39	9.36	7.30	5.54	2159.76	Calgary	BASF
241	Deloraine	MB	399.21	39.92	33.54	22.90	14.80	9.63	7.51	5.70	2223.41	Calgary	BASF
242	Dencross	MB	351.73	35.17	29.24	19.93	12.87	8.37	6.53	4.96	1926.69	Calgary	BASF
243	Domain	MB	338.52	33.85	28.04	19.10	12.33	8.02	6.26	4.75	1844.12	Calgary	BASF
244	Dominion City	MB	363.62	36.36	30.32	20.67	13.35	8.69	6.78	5.14	2001.01	Calgary	BASF
245	Dufrost	MB	355.69	35.57	29.60	20.18	13.03	8.48	6.61	5.02	1951.46	Calgary	BASF
246	Dugald	MB	334.89	33.49	27.71	18.88	12.19	7.93	6.18	4.69	1821.41	Calgary	BASF
247	Dunrea	MB	387.89	38.79	32.52	22.19	14.34	9.33	7.28	5.52	2152.68	Calgary	BASF
248	Elgin	MB	384.12	38.41	32.18	21.95	14.19	9.23	7.20	5.46	2129.11	Calgary	BASF
249	Elie	MB	326.30	32.63	26.94	18.34	11.84	7.70	6.01	4.56	1767.74	Calgary	BASF
250	Elkhorn	MB	350.54	35.05	29.13	19.86	12.82	8.34	6.51	4.94	1919.27	Calgary	BASF
251	Elm Creek	MB	334.56	33.46	27.68	18.86	12.17	7.92	6.18	4.69	1819.34	Calgary	BASF
252	Emerson	MB	369.90	36.99	30.89	21.07	13.61	8.86	6.91	5.24	2040.23	Calgary	BASF
253	Fannystelle	MB	332.90	33.29	27.53	18.75	12.11	7.87	6.14	4.66	1809.02	Calgary	BASF
254	Fisher Branch	MB	394.11	39.41	33.08	22.58	14.59	9.50	7.41	5.62	2191.55	Calgary	BASF
255	Fork River	MB	409.77	40.98	34.50	23.56	15.23	9.91	7.73	5.86	2289.43	Calgary	BASF
256	Forrest	MB	368.65	36.87	30.77	20.99	13.56	8.82	6.88	5.22	2032.44	Calgary	BASF
1763	Macklin	SK	325.95	31.08	25.53	17.37	11.21	7.29	5.69	4.32	1671.02	Lethbridge	BASF
258	Franklin	MB	376.19	37.62	31.46	21.46	13.87	9.02	7.04	5.34	2079.59	Calgary	BASF
259	Gilbert Plains	MB	382.23	38.22	32.00	21.84	14.11	9.18	7.16	5.43	2117.32	Calgary	BASF
260	Gimli	MB	362.63	36.26	30.23	20.61	13.31	8.66	6.76	5.13	1994.81	Calgary	BASF
261	Gladstone	MB	334.89	33.49	27.71	18.88	12.19	7.93	6.18	4.69	1821.41	Calgary	BASF
262	Glenboro	MB	384.87	38.49	32.24	22.00	14.22	9.25	7.22	5.48	2133.82	Calgary	BASF
263	Glossop (Newdale)	MB	372.80	37.28	31.15	21.25	13.73	8.93	6.97	5.29	2058.37	Calgary	BASF
264	Goodlands	MB	404.11	40.41	33.99	23.20	15.00	9.76	7.62	5.78	2254.06	Calgary	BASF
265	Grandview	MB	375.06	37.51	31.36	21.39	13.82	8.99	7.01	5.32	2072.52	Calgary	BASF
266	Gretna	MB	363.29	36.33	30.29	20.65	13.34	8.68	6.77	5.14	1998.94	Calgary	BASF
267	Griswold	MB	365.26	36.53	30.47	20.77	13.42	8.73	6.81	5.17	2011.22	Calgary	BASF
268	Grosse Isle	MB	335.55	33.55	27.77	18.92	12.21	7.94	6.20	4.71	1825.54	Calgary	BASF
269	Gunton	MB	345.12	34.51	28.64	19.52	12.60	8.20	6.40	4.85	1885.40	Calgary	BASF
270	Hamiota	MB	373.93	37.39	31.25	21.32	13.77	8.96	6.99	5.30	2065.45	Calgary	BASF
271	Hargrave	MB	357.33	35.73	29.75	20.28	13.10	8.52	6.65	5.05	1961.71	Calgary	BASF
272	Hartney	MB	382.23	38.22	32.00	21.84	14.11	9.18	7.16	5.43	2117.32	Calgary	BASF
273	High Bluff	MB	331.58	33.16	27.41	18.67	12.05	7.84	6.11	4.64	1800.77	Calgary	BASF
274	Holland	MB	335.88	33.59	27.80	18.94	12.23	7.95	6.20	4.71	1827.60	Calgary	BASF
275	Homewood	MB	340.50	34.05	28.22	19.23	12.41	8.07	6.30	4.78	1856.50	Calgary	BASF
276	Inglis	MB	363.37	36.34	30.30	20.66	13.34	8.68	6.77	5.14	1999.43	Calgary	BASF
277	Kane	MB	348.76	34.88	28.97	19.74	12.75	8.29	6.47	4.91	1908.11	Calgary	BASF
278	Kemnay	MB	364.88	36.49	30.43	20.75	13.41	8.72	6.80	5.16	2008.86	Calgary	BASF
279	Kenton	MB	370.54	37.05	30.95	21.11	13.64	8.87	6.92	5.25	2044.23	Calgary	BASF
280	Kenville	MB	390.53	39.05	32.76	22.35	14.45	9.40	7.33	5.56	2169.19	Calgary	BASF
281	Killarney	MB	398.45	39.85	33.47	22.85	14.77	9.61	7.50	5.69	2218.70	Calgary	BASF
282	Landmark	MB	342.48	34.25	28.40	19.35	12.50	8.13	6.34	4.81	1868.89	Calgary	BASF
283	Laurier	MB	411.28	41.13	34.64	23.65	15.29	9.95	7.76	5.89	2298.86	Calgary	BASF
284	Letellier	MB	362.63	36.26	30.23	20.61	13.31	8.66	6.76	5.13	1994.81	Calgary	BASF
285	Lowe Farm	MB	348.76	34.88	28.97	19.74	12.75	8.29	6.47	4.91	1908.11	Calgary	BASF
286	Lundar	MB	362.30	36.23	30.20	20.59	13.30	8.65	6.75	5.12	1992.75	Calgary	BASF
287	MacGregor	MB	325.97	32.60	26.91	18.32	11.82	7.69	6.00	4.56	1765.67	Calgary	BASF
288	Manitou	MB	352.06	35.21	29.27	19.95	12.88	8.38	6.54	4.96	1928.75	Calgary	BASF
289	Mariapolis	MB	346.60	34.66	28.78	19.61	12.66	8.24	6.43	4.88	1894.65	Calgary	BASF
290	Marquette	MB	330.92	33.09	27.36	18.63	12.03	7.82	6.10	4.63	1796.64	Calgary	BASF
291	Mather	MB	395.06	39.51	33.17	22.64	14.63	9.52	7.43	5.63	2197.48	Calgary	BASF
292	McCreary	MB	403.73	40.37	33.95	23.18	14.98	9.75	7.61	5.77	2251.71	Calgary	BASF
293	Meadows	MB	331.58	33.16	27.41	18.67	12.05	7.84	6.11	4.64	1800.77	Calgary	BASF
294	Medora	MB	394.30	39.43	33.10	22.59	14.60	9.50	7.41	5.62	2192.76	Calgary	BASF
295	Melita	MB	393.17	39.32	33.00	22.52	14.55	9.47	7.39	5.61	2185.69	Calgary	BASF
296	Miami	MB	345.45	34.55	28.67	19.54	12.62	8.21	6.40	4.86	1887.47	Calgary	BASF
297	Miniota	MB	371.29	37.13	31.01	21.15	13.67	8.89	6.94	5.26	2048.94	Calgary	BASF
298	Minitonas	MB	404.86	40.49	34.06	23.25	15.03	9.78	7.63	5.79	2258.78	Calgary	BASF
299	Minnedosa	MB	376.57	37.66	31.49	21.48	13.88	9.03	7.05	5.35	2081.95	Calgary	BASF
300	Minto	MB	383.74	38.37	32.14	21.93	14.17	9.22	7.19	5.46	2126.75	Calgary	BASF
301	Morden	MB	356.68	35.67	29.69	20.24	13.07	8.50	6.63	5.04	1957.66	Calgary	BASF
302	Morris	MB	352.06	35.21	29.27	19.95	12.88	8.38	6.54	4.96	1928.75	Calgary	BASF
303	Neepawa	MB	335.22	33.52	27.74	18.90	12.20	7.93	6.19	4.70	1823.47	Calgary	BASF
304	Nesbitt	MB	380.34	38.03	31.83	21.72	14.03	9.13	7.12	5.41	2105.53	Calgary	BASF
305	Newdale	MB	373.18	37.32	31.18	21.27	13.74	8.94	6.98	5.29	2060.73	Calgary	BASF
306	Ninga	MB	400.72	40.07	33.68	22.99	14.86	9.67	7.55	5.72	2232.84	Calgary	BASF
307	Niverville	MB	341.49	34.15	28.31	19.29	12.46	8.10	6.32	4.80	1862.70	Calgary	BASF
308	Notre Dame De Lourdes	MB	341.82	34.18	28.34	19.31	12.47	8.11	6.33	4.80	1864.76	Calgary	BASF
309	Oak Bluff	MB	331.25	33.13	27.38	18.65	12.04	7.83	6.11	4.64	1798.70	Calgary	BASF
310	Oak River	MB	373.18	37.32	31.18	21.27	13.74	8.94	6.98	5.29	2060.73	Calgary	BASF
311	Oakbank	MB	339.51	33.95	28.13	19.17	12.37	8.05	6.28	4.77	1850.31	Calgary	BASF
312	Oakville	MB	326.96	32.70	27.00	18.38	11.86	7.72	6.02	4.57	1771.86	Calgary	BASF
313	Petersfield	MB	356.37	35.64	29.66	20.22	13.06	8.50	6.63	5.03	1955.72	Calgary	BASF
314	Pierson	MB	395.81	39.58	33.24	22.68	14.66	9.54	7.44	5.65	2202.19	Calgary	BASF
315	Pilot Mound	MB	361.43	36.14	30.12	20.54	13.27	8.63	6.73	5.11	1987.30	Calgary	BASF
316	Pine Falls	MB	376.83	37.68	31.52	21.50	13.89	9.04	7.05	5.35	2083.58	Calgary	BASF
317	Plum Coulee	MB	358.34	35.83	29.84	20.34	13.14	8.55	6.67	5.06	1967.98	Calgary	BASF
318	Plumas	MB	342.15	34.22	28.37	19.33	12.48	8.12	6.33	4.81	1866.82	Calgary	BASF
319	Portage La Prairie	MB	325.64	32.56	26.88	18.30	11.81	7.68	5.99	4.55	1763.61	Calgary	BASF
320	Rathwell	MB	335.88	33.59	27.80	18.94	12.23	7.95	6.20	4.71	1827.60	Calgary	BASF
321	Reston	MB	380.34	38.03	31.83	21.72	14.03	9.13	7.12	5.41	2105.53	Calgary	BASF
322	River Hills	MB	368.91	36.89	30.80	21.00	13.57	8.83	6.89	5.23	2034.04	Calgary	BASF
323	Rivers	MB	372.80	37.28	31.15	21.25	13.73	8.93	6.97	5.29	2058.37	Calgary	BASF
324	Roblin	MB	352.81	35.28	29.34	20.00	12.91	8.40	6.55	4.97	1933.42	Calgary	BASF
325	Roland	MB	348.10	34.81	28.91	19.70	12.72	8.28	6.46	4.90	1903.98	Calgary	BASF
326	Rosenort	MB	350.08	35.01	29.09	19.83	12.80	8.33	6.50	4.93	1916.37	Calgary	BASF
327	Rossburn	MB	370.16	37.02	30.91	21.08	13.62	8.86	6.91	5.25	2041.87	Calgary	BASF
328	Rosser	MB	332.90	33.29	27.53	18.75	12.11	7.87	6.14	4.66	1809.02	Calgary	BASF
329	Russell	MB	351.30	35.13	29.20	19.90	12.85	8.36	6.52	4.95	1923.99	Calgary	BASF
330	Selkirk	MB	342.15	34.22	28.37	19.33	12.48	8.12	6.33	4.81	1866.82	Calgary	BASF
331	Shoal Lake	MB	373.93	37.39	31.25	21.32	13.77	8.96	6.99	5.30	2065.45	Calgary	BASF
332	Sifton	MB	400.34	40.03	33.65	22.97	14.85	9.66	7.54	5.72	2230.49	Calgary	BASF
333	Snowflake	MB	368.84	36.88	30.79	21.00	13.57	8.83	6.89	5.23	2033.62	Calgary	BASF
334	Somerset	MB	345.45	34.55	28.67	19.54	12.62	8.21	6.40	4.86	1887.47	Calgary	BASF
335	Souris	MB	372.80	37.28	31.15	21.25	13.73	8.93	6.97	5.29	2058.37	Calgary	BASF
336	St Claude	MB	334.89	33.49	27.71	18.88	12.19	7.93	6.18	4.69	1821.41	Calgary	BASF
337	St Jean Baptiste	MB	356.68	35.67	29.69	20.24	13.07	8.50	6.63	5.04	1957.66	Calgary	BASF
338	St Joseph	MB	364.61	36.46	30.41	20.73	13.39	8.72	6.80	5.16	2007.20	Calgary	BASF
339	St Leon	MB	345.45	34.55	28.67	19.54	12.62	8.21	6.40	4.86	1887.47	Calgary	BASF
340	Starbuck	MB	332.90	33.29	27.53	18.75	12.11	7.87	6.14	4.66	1809.02	Calgary	BASF
341	Ste Agathe	MB	340.17	34.02	28.19	19.21	12.40	8.07	6.29	4.78	1854.44	Calgary	BASF
342	Ste Anne	MB	347.11	34.71	28.82	19.64	12.68	8.25	6.44	4.89	1897.79	Calgary	BASF
343	Ste Rose Du Lac	MB	389.02	38.90	32.62	22.26	14.39	9.36	7.30	5.54	2159.76	Calgary	BASF
344	Steinbach	MB	353.71	35.37	29.42	20.05	12.95	8.43	6.57	4.99	1939.08	Calgary	BASF
345	Stonewall	MB	336.87	33.69	27.89	19.00	12.27	7.98	6.22	4.73	1833.79	Calgary	BASF
346	Strathclair	MB	373.93	37.39	31.25	21.32	13.77	8.96	6.99	5.30	2065.45	Calgary	BASF
347	Swan Lake	MB	350.31	35.03	29.11	19.84	12.81	8.34	6.50	4.94	1917.81	Calgary	BASF
348	Swan River	MB	397.70	39.77	33.41	22.80	14.74	9.59	7.48	5.68	2213.98	Calgary	BASF
349	Teulon	MB	355.03	35.50	29.54	20.14	13.01	8.46	6.60	5.01	1947.29	Calgary	BASF
350	The Pas	MB	505.59	50.56	43.18	29.55	19.12	12.46	9.72	7.36	2888.29	Calgary	BASF
351	Treherne	MB	336.21	33.62	27.83	18.96	12.24	7.96	6.21	4.72	1829.67	Calgary	BASF
352	Turtle Mountain	MB	401.47	40.15	33.75	23.04	14.89	9.69	7.56	5.74	2237.56	Calgary	BASF
353	Virden	MB	363.37	36.34	30.30	20.66	13.34	8.68	6.77	5.14	1999.43	Calgary	BASF
354	Warren	MB	334.22	33.42	27.65	18.84	12.16	7.91	6.17	4.68	1817.28	Calgary	BASF
355	Waskada	MB	402.22	40.22	33.82	23.09	14.92	9.71	7.58	5.75	2242.28	Calgary	BASF
356	Wawanesa	MB	379.97	38.00	31.80	21.69	14.02	9.12	7.12	5.40	2103.17	Calgary	BASF
357	Wellwood	MB	239.03	16.71	12.51	8.39	5.37	3.47	2.71	2.07	772.72	Calgary	BASF
358	Westbourne	MB	334.56	33.46	27.68	18.86	12.17	7.92	6.18	4.69	1819.34	Calgary	BASF
359	Winkler	MB	356.02	35.60	29.63	20.20	13.05	8.49	6.62	5.03	1953.53	Calgary	BASF
360	Winnipeg	MB	239.03	20.67	16.10	10.87	6.98	4.52	3.53	2.69	1020.22	Calgary	BASF
361	Abbey	SK	257.74	25.77	20.72	14.06	9.05	5.88	4.59	3.49	1339.27	Calgary	BASF
362	Aberdeen	SK	321.50	32.15	26.50	18.04	11.64	7.57	5.91	4.49	1737.73	Calgary	BASF
363	Abernethy	SK	249.67	24.97	19.99	13.55	8.72	5.66	4.42	3.36	1288.81	Calgary	BASF
364	Alameda	SK	338.85	33.88	28.07	19.12	12.35	8.03	6.27	4.76	1846.18	Calgary	BASF
365	Albertville	SK	365.26	36.53	30.47	20.77	13.42	8.73	6.81	5.17	2011.22	Calgary	BASF
366	Antler	SK	372.42	37.24	31.12	21.22	13.71	8.92	6.96	5.28	2056.02	Calgary	BASF
367	Arborfield	SK	391.28	39.13	32.83	22.40	14.48	9.42	7.35	5.58	2173.90	Calgary	BASF
368	Archerwill	SK	350.92	35.09	29.17	19.88	12.84	8.35	6.52	4.95	1921.63	Calgary	BASF
369	Assiniboia	SK	239.03	23.14	18.33	12.41	7.98	5.18	4.04	3.08	1174.52	Calgary	BASF
370	Avonlea	SK	239.03	22.32	17.60	11.90	7.65	4.96	3.87	2.95	1123.66	Calgary	BASF
371	Aylsham	SK	392.04	39.20	32.89	22.45	14.51	9.44	7.37	5.59	2178.62	Calgary	BASF
372	Balcarres	SK	244.05	24.41	19.48	13.20	8.50	5.51	4.30	3.28	1253.71	Calgary	BASF
373	Balgonie	SK	239.03	21.73	17.06	11.53	7.41	4.80	3.75	2.86	1086.50	Calgary	BASF
374	Bankend	SK	270.81	27.08	21.91	14.87	9.58	6.22	4.86	3.69	1420.92	Calgary	BASF
375	Beechy	SK	269.82	26.98	21.82	14.81	9.54	6.20	4.84	3.68	1414.72	Calgary	BASF
376	Bengough	SK	239.76	23.98	19.09	12.93	8.32	5.40	4.21	3.21	1226.88	Calgary	BASF
377	Biggar	SK	266.42	26.64	21.51	14.60	9.41	6.11	4.77	3.62	1393.50	Calgary	BASF
378	Birch Hills	SK	347.15	34.71	28.83	19.64	12.69	8.25	6.44	4.89	1898.05	Calgary	BASF
379	Bjorkdale	SK	380.72	38.07	31.87	21.74	14.05	9.14	7.13	5.41	2107.89	Calgary	BASF
380	Blaine Lake	SK	317.72	31.77	26.16	17.80	11.49	7.47	5.83	4.43	1714.15	Calgary	BASF
381	Bracken	SK	281.89	28.19	22.91	15.56	10.03	6.52	5.09	3.87	1490.17	Calgary	BASF
382	Bredenbury	SK	325.27	32.53	26.84	18.28	11.80	7.67	5.98	4.54	1761.30	Calgary	BASF
383	Briercrest	SK	239.03	21.99	17.30	11.69	7.52	4.87	3.80	2.90	1103.01	Calgary	BASF
384	Broadview	SK	268.50	26.85	21.70	14.73	9.49	6.16	4.81	3.66	1406.47	Calgary	BASF
385	Broderick	SK	241.90	24.19	19.29	13.07	8.41	5.46	4.26	3.24	1240.25	Calgary	BASF
386	Brooksby	SK	372.05	37.20	31.08	21.20	13.70	8.91	6.95	5.28	2053.66	Calgary	BASF
387	Bruno	SK	324.89	32.49	26.81	18.25	11.78	7.66	5.98	4.54	1758.95	Calgary	BASF
388	Buchanan	SK	340.74	34.07	28.24	19.24	12.42	8.08	6.30	4.79	1857.97	Calgary	BASF
389	Cabri	SK	245.30	24.53	19.60	13.28	8.55	5.55	4.33	3.29	1261.47	Calgary	BASF
390	Canora	SK	339.60	33.96	28.14	19.17	12.38	8.05	6.28	4.77	1850.90	Calgary	BASF
391	Canwood	SK	356.96	35.70	29.71	20.26	13.08	8.51	6.64	5.04	1959.35	Calgary	BASF
392	Carievale	SK	385.25	38.52	32.28	22.02	14.23	9.26	7.23	5.48	2136.18	Calgary	BASF
393	Carlyle	SK	286.00	28.60	23.28	15.82	10.20	6.63	5.17	3.93	1515.88	Calgary	BASF
394	Carnduff	SK	353.56	35.36	29.41	20.04	12.95	8.42	6.57	4.99	1938.13	Calgary	BASF
395	Carrot River	SK	402.60	40.26	33.85	23.11	14.94	9.72	7.58	5.75	2244.63	Calgary	BASF
396	Central Butte	SK	239.03	22.13	17.42	11.78	7.57	4.91	3.83	2.92	1111.35	Calgary	BASF
397	Ceylon	SK	244.71	24.47	19.54	13.24	8.52	5.53	4.32	3.29	1257.84	Calgary	BASF
398	Choiceland	SK	369.78	36.98	30.88	21.06	13.60	8.85	6.91	5.24	2039.51	Calgary	BASF
399	Churchbridge	SK	329.42	32.94	27.22	18.54	11.96	7.78	6.07	4.61	1787.24	Calgary	BASF
400	Clavet	SK	316.21	31.62	26.02	17.71	11.43	7.43	5.80	4.40	1704.72	Calgary	BASF
401	Codette	SK	389.78	38.98	32.69	22.31	14.42	9.38	7.32	5.55	2164.47	Calgary	BASF
402	Colgate	SK	262.72	26.27	21.17	14.37	9.25	6.01	4.69	3.57	1370.35	Calgary	BASF
403	Colonsay	SK	316.21	31.62	26.02	17.71	11.43	7.43	5.80	4.40	1704.72	Calgary	BASF
404	Congress	SK	239.03	23.10	18.30	12.39	7.97	5.17	4.03	3.07	1172.42	Calgary	BASF
405	Consul	SK	269.82	26.98	21.82	14.81	9.54	6.20	4.84	3.68	1414.72	Calgary	BASF
406	Corman Park	SK	306.78	30.68	25.17	17.12	11.05	7.18	5.60	4.26	1645.78	Calgary	BASF
407	Corning	SK	277.74	27.77	22.54	15.31	9.87	6.41	5.00	3.80	1464.28	Calgary	BASF
408	Coronach	SK	280.00	28.00	22.74	15.45	9.96	6.47	5.05	3.84	1478.38	Calgary	BASF
409	Craik	SK	239.03	23.22	18.41	12.46	8.01	5.20	4.06	3.09	1179.40	Calgary	BASF
410	Creelman	SK	255.28	25.53	20.50	13.90	8.95	5.81	4.54	3.45	1323.90	Calgary	BASF
411	Crooked River	SK	375.44	37.54	31.39	21.41	13.83	9.00	7.02	5.33	2074.88	Calgary	BASF
412	Cudworth	SK	335.08	33.51	27.73	18.89	12.19	7.93	6.19	4.70	1822.60	Calgary	BASF
413	Cupar	SK	239.10	23.91	19.03	12.89	8.30	5.38	4.20	3.20	1222.75	Calgary	BASF
414	Cut knife	SK	290.94	29.09	23.73	16.13	10.40	6.76	5.27	4.01	1546.75	Calgary	BASF
415	Davidson	SK	239.03	23.55	18.70	12.66	8.15	5.28	4.13	3.14	1200.04	Calgary	BASF
416	Debden	SK	368.65	36.87	30.77	20.99	13.56	8.82	6.88	5.22	2032.44	Calgary	BASF
417	Delisle	SK	256.23	25.62	20.59	13.96	8.99	5.84	4.56	3.47	1329.84	Calgary	BASF
418	Delmas	SK	288.68	28.87	23.53	15.99	10.31	6.70	5.23	3.97	1532.61	Calgary	BASF
419	Denzil	SK	253.97	25.40	20.38	13.82	8.90	5.78	4.51	3.43	1315.70	Calgary	BASF
420	Dinsmore	SK	271.32	27.13	21.95	14.90	9.60	6.24	4.87	3.70	1424.15	Calgary	BASF
421	Domremy	SK	346.77	34.68	28.79	19.62	12.67	8.24	6.43	4.88	1895.69	Calgary	BASF
422	Drake	SK	265.52	26.55	21.43	14.54	9.37	6.08	4.75	3.61	1387.90	Calgary	BASF
423	Duperow	SK	267.93	26.79	21.65	14.69	9.47	6.15	4.80	3.65	1402.93	Calgary	BASF
424	Eastend	SK	261.14	26.11	21.03	14.27	9.19	5.97	4.66	3.54	1360.49	Calgary	BASF
425	Eatonia	SK	249.82	24.98	20.01	13.56	8.73	5.67	4.42	3.37	1289.76	Calgary	BASF
426	Ebenezer	SK	325.65	32.56	26.88	18.30	11.81	7.68	5.99	4.55	1763.66	Calgary	BASF
427	Edam	SK	304.52	30.45	24.96	16.98	10.95	7.12	5.55	4.22	1631.63	Calgary	BASF
428	Edenwold	SK	239.03	22.46	17.72	11.98	7.71	5.00	3.90	2.97	1131.92	Calgary	BASF
429	Elfros	SK	254.62	25.46	20.44	13.86	8.93	5.79	4.52	3.44	1319.77	Calgary	BASF
430	Elrose	SK	281.13	28.11	22.84	15.52	10.00	6.50	5.07	3.85	1485.45	Calgary	BASF
431	Estevan	SK	284.61	28.46	23.16	15.73	10.14	6.59	5.14	3.91	1507.21	Calgary	BASF
432	Eston	SK	256.23	25.62	20.59	13.96	8.99	5.84	4.56	3.47	1329.84	Calgary	BASF
433	Eyebrow	SK	239.03	22.13	17.42	11.78	7.57	4.91	3.83	2.92	1111.35	Calgary	BASF
434	Fairlight	SK	347.15	34.71	28.83	19.64	12.69	8.25	6.44	4.89	1898.05	Calgary	BASF
435	Fielding	SK	307.16	30.72	25.20	17.14	11.06	7.19	5.61	4.26	1648.13	Calgary	BASF
436	Fillmore	SK	247.03	24.70	19.75	13.39	8.62	5.59	4.36	3.32	1272.29	Calgary	BASF
437	Foam Lake	SK	285.01	28.50	23.19	15.76	10.16	6.60	5.15	3.92	1509.69	Calgary	BASF
438	Fox Valley	SK	243.03	24.30	19.39	13.14	8.46	5.49	4.28	3.26	1247.32	Calgary	BASF
257	Foxwarren	MB	303.77	30.38	24.89	16.93	10.92	7.10	5.54	4.21	1626.91	Calgary	BASF
440	Francis	SK	239.03	23.15	18.35	12.42	7.99	5.18	4.04	3.08	1175.27	Calgary	BASF
441	Frontier	SK	276.98	27.70	22.47	15.26	9.83	6.39	4.98	3.79	1459.52	Calgary	BASF
442	Gerald	SK	345.64	34.56	28.69	19.55	12.62	8.21	6.41	4.86	1888.62	Calgary	BASF
443	Glaslyn	SK	313.57	31.36	25.78	17.54	11.32	7.36	5.74	4.36	1688.21	Calgary	BASF
444	Glenavon	SK	253.63	25.36	20.35	13.80	8.89	5.77	4.50	3.43	1313.58	Calgary	BASF
445	Goodeve	SK	277.20	27.72	22.49	15.27	9.84	6.39	4.99	3.79	1460.89	Calgary	BASF
446	Govan	SK	250.00	25.00	20.02	13.57	8.74	5.67	4.43	3.37	1290.87	Calgary	BASF
447	Grand Coulee	SK	239.03	20.71	16.13	10.89	6.99	4.53	3.54	2.70	1022.51	Calgary	BASF
448	Gravelbourg	SK	239.03	22.53	17.78	12.03	7.74	5.02	3.92	2.98	1136.62	Calgary	BASF
449	Gray	SK	239.03	22.09	17.39	11.75	7.56	4.90	3.82	2.91	1109.21	Calgary	BASF
450	Grenfell	SK	258.26	25.83	20.77	14.09	9.07	5.89	4.60	3.50	1342.48	Calgary	BASF
451	Griffin	SK	257.93	25.79	20.74	14.07	9.06	5.88	4.59	3.49	1340.42	Calgary	BASF
452	Gronlid	SK	314.33	31.43	25.85	17.59	11.35	7.38	5.76	4.37	1692.93	Calgary	BASF
453	Gull Lake	SK	239.03	22.87	18.09	12.24	7.87	5.11	3.99	3.04	1157.73	Calgary	BASF
454	Hafford	SK	313.57	31.36	25.78	17.54	11.32	7.36	5.74	4.36	1688.21	Calgary	BASF
455	Hague	SK	322.25	32.23	26.57	18.09	11.67	7.59	5.92	4.50	1742.44	Calgary	BASF
456	Hamlin	SK	309.80	30.98	25.44	17.31	11.17	7.26	5.66	4.30	1664.64	Calgary	BASF
457	Hanley	SK	251.65	25.17	20.17	13.67	8.81	5.71	4.46	3.39	1301.19	Calgary	BASF
458	Hazenmore	SK	256.23	25.62	20.59	13.96	8.99	5.84	4.56	3.47	1329.84	Calgary	BASF
459	Hazlet	SK	240.01	24.00	19.12	12.95	8.33	5.41	4.22	3.21	1228.46	Calgary	BASF
460	Herbert	SK	239.03	20.71	16.13	10.89	6.99	4.53	3.54	2.70	1022.51	Calgary	BASF
461	Hodgeville	SK	243.41	24.34	19.42	13.16	8.47	5.50	4.29	3.27	1249.68	Calgary	BASF
462	Hoey	SK	350.54	35.05	29.13	19.86	12.82	8.34	6.51	4.94	1919.27	Calgary	BASF
463	Hudson Bay	SK	412.79	41.28	34.77	23.75	15.35	9.99	7.80	5.91	2308.29	Calgary	BASF
464	Humboldt	SK	323.76	32.38	26.71	18.18	11.73	7.63	5.95	4.52	1751.87	Calgary	BASF
465	Imperial	SK	244.71	24.47	19.54	13.24	8.52	5.53	4.32	3.29	1257.84	Calgary	BASF
466	Indian Head	SK	239.03	23.55	18.70	12.66	8.15	5.28	4.13	3.14	1200.04	Calgary	BASF
467	Invermay	SK	342.62	34.26	28.42	19.36	12.50	8.13	6.34	4.82	1869.76	Calgary	BASF
468	Ituna	SK	260.57	26.06	20.98	14.23	9.17	5.95	4.65	3.53	1356.93	Calgary	BASF
469	Kamsack	SK	353.94	35.39	29.44	20.07	12.96	8.43	6.58	4.99	1940.49	Calgary	BASF
470	Kelso	SK	347.15	34.71	28.83	19.64	12.69	8.25	6.44	4.89	1898.05	Calgary	BASF
471	Kelvington	SK	345.64	34.56	28.69	19.55	12.62	8.21	6.41	4.86	1888.62	Calgary	BASF
472	Kerrobert	SK	262.65	26.26	21.17	14.36	9.25	6.01	4.69	3.57	1369.92	Calgary	BASF
473	Kindersley	SK	242.28	24.23	19.32	13.09	8.42	5.47	4.27	3.25	1242.61	Calgary	BASF
474	Kinistino	SK	350.54	35.05	29.13	19.86	12.82	8.34	6.51	4.94	1919.27	Calgary	BASF
475	Kipling	SK	278.74	27.87	22.63	15.37	9.91	6.43	5.02	3.82	1470.47	Calgary	BASF
476	Kisbey	SK	276.75	27.68	22.45	15.24	9.83	6.38	4.98	3.79	1458.08	Calgary	BASF
477	Kronau	SK	239.03	21.60	16.94	11.45	7.36	4.77	3.72	2.84	1078.24	Calgary	BASF
478	Krydor	SK	295.09	29.51	24.11	16.39	10.57	6.87	5.36	4.07	1572.69	Calgary	BASF
479	Kyle	SK	261.14	26.11	21.03	14.27	9.19	5.97	4.66	3.54	1360.49	Calgary	BASF
480	Lafleche	SK	249.82	24.98	20.01	13.56	8.73	5.67	4.42	3.37	1289.76	Calgary	BASF
481	Lajord	SK	239.03	22.06	17.36	11.73	7.54	4.89	3.82	2.91	1107.14	Calgary	BASF
482	Lake Alma	SK	270.81	27.08	21.91	14.87	9.58	6.22	4.86	3.69	1420.92	Calgary	BASF
483	Lake Lenore	SK	337.72	33.77	27.97	19.05	12.30	8.00	6.24	4.74	1839.11	Calgary	BASF
484	Lampman	SK	290.34	29.03	23.68	16.09	10.38	6.74	5.26	4.00	1543.01	Calgary	BASF
485	Landis	SK	275.47	27.55	22.33	15.16	9.77	6.35	4.95	3.77	1450.09	Calgary	BASF
486	Langbank	SK	325.65	32.56	26.88	18.30	11.81	7.68	5.99	4.55	1763.66	Calgary	BASF
487	Langenburg	SK	336.59	33.66	27.87	18.98	12.26	7.97	6.22	4.72	1832.03	Calgary	BASF
488	Langham	SK	306.78	30.68	25.17	17.12	11.05	7.18	5.60	4.26	1645.78	Calgary	BASF
489	Lanigan	SK	283.36	28.34	23.04	15.66	10.09	6.56	5.12	3.89	1499.37	Calgary	BASF
490	Lashburn	SK	253.22	25.32	20.31	13.77	8.87	5.76	4.49	3.42	1310.98	Calgary	BASF
491	Leader	SK	249.82	24.98	20.01	13.56	8.73	5.67	4.42	3.37	1289.76	Calgary	BASF
492	Leask	SK	327.15	32.72	27.01	18.39	11.87	7.72	6.02	4.57	1773.09	Calgary	BASF
493	Lemberg	SK	256.61	25.66	20.62	13.98	9.01	5.85	4.56	3.47	1332.16	Calgary	BASF
494	Leoville	SK	347.90	34.79	28.89	19.69	12.72	8.27	6.45	4.90	1902.77	Calgary	BASF
495	Leross	SK	261.89	26.19	21.10	14.31	9.22	5.99	4.67	3.55	1365.19	Calgary	BASF
496	Leroy	SK	282.70	28.27	22.98	15.62	10.07	6.54	5.10	3.88	1495.24	Calgary	BASF
497	Lestock	SK	264.86	26.49	21.37	14.50	9.34	6.07	4.73	3.60	1383.77	Calgary	BASF
498	Lewvan	SK	239.03	23.38	18.55	12.56	8.08	5.24	4.09	3.12	1189.72	Calgary	BASF
499	Liberty	SK	239.03	23.55	18.70	12.66	8.15	5.28	4.13	3.14	1200.04	Calgary	BASF
500	Limerick	SK	239.03	23.07	18.27	12.37	7.95	5.16	4.03	3.07	1170.31	Calgary	BASF
501	Lintlaw	SK	355.45	35.54	29.58	20.16	13.02	8.47	6.61	5.02	1949.92	Calgary	BASF
502	Lipton	SK	243.06	24.31	19.39	13.14	8.46	5.49	4.28	3.26	1247.52	Calgary	BASF
503	Lloydminsters	SK	239.03	23.89	19.01	12.88	8.29	5.38	4.20	3.19	1221.39	Calgary	BASF
504	Loreburn	SK	239.03	23.55	18.70	12.66	8.15	5.28	4.13	3.14	1200.04	Calgary	BASF
505	Lucky Lake	SK	269.44	26.94	21.78	14.79	9.53	6.19	4.83	3.67	1412.36	Calgary	BASF
506	Lumsden	SK	239.03	21.93	17.24	11.65	7.49	4.85	3.79	2.89	1098.89	Calgary	BASF
507	Luseland	SK	266.80	26.68	21.54	14.62	9.42	6.12	4.77	3.63	1395.86	Calgary	BASF
508	Macklin	SK	241.90	24.19	19.29	13.07	8.41	5.46	4.26	3.24	1240.25	Calgary	BASF
509	Macoun	SK	273.50	27.35	22.15	15.04	9.69	6.30	4.91	3.74	1437.73	Calgary	BASF
510	Maidstone	SK	264.16	26.42	21.30	14.46	9.31	6.05	4.72	3.59	1379.36	Calgary	BASF
511	Major	SK	255.86	25.59	20.55	13.94	8.98	5.83	4.55	3.46	1327.49	Calgary	BASF
512	Mankota	SK	270.95	27.09	21.92	14.88	9.59	6.23	4.86	3.70	1421.79	Calgary	BASF
513	Maple Creek	SK	239.03	23.36	18.54	12.55	8.07	5.24	4.09	3.11	1188.38	Calgary	BASF
514	Marengo	SK	239.03	23.10	18.30	12.38	7.96	5.17	4.03	3.07	1171.88	Calgary	BASF
515	Marsden	SK	241.15	24.11	19.22	13.02	8.38	5.44	4.24	3.23	1235.54	Calgary	BASF
516	Marshall	SK	247.18	24.72	19.77	13.40	8.62	5.60	4.37	3.32	1273.26	Calgary	BASF
517	Maryfield	SK	352.81	35.28	29.34	20.00	12.91	8.40	6.55	4.97	1933.42	Calgary	BASF
518	Maymont	SK	306.78	30.68	25.17	17.12	11.05	7.18	5.60	4.26	1645.78	Calgary	BASF
519	McLean	SK	239.03	22.39	17.66	11.94	7.68	4.98	3.89	2.96	1127.79	Calgary	BASF
520	Meadow Lake	SK	326.02	32.60	26.91	18.32	11.83	7.69	6.00	4.56	1766.02	Calgary	BASF
521	Meath Park	SK	368.27	36.83	30.74	20.96	13.54	8.81	6.87	5.22	2030.08	Calgary	BASF
522	Medstead	SK	326.02	32.60	26.91	18.32	11.83	7.69	6.00	4.56	1766.02	Calgary	BASF
523	Melfort	SK	353.18	35.32	29.37	20.02	12.93	8.41	6.56	4.98	1935.77	Calgary	BASF
524	Melville	SK	267.17	26.72	21.58	14.64	9.44	6.13	4.78	3.64	1398.22	Calgary	BASF
525	Meota	SK	320.74	32.07	26.43	17.99	11.61	7.55	5.89	4.47	1733.01	Calgary	BASF
526	Mervin	SK	296.22	29.62	24.21	16.46	10.62	6.90	5.38	4.09	1579.76	Calgary	BASF
527	Midale	SK	262.88	26.29	21.19	14.38	9.26	6.01	4.69	3.57	1371.38	Calgary	BASF
528	Middle Lake	SK	341.49	34.15	28.31	19.29	12.46	8.10	6.32	4.80	1862.68	Calgary	BASF
529	Milden	SK	243.03	24.30	19.39	13.14	8.46	5.49	4.28	3.26	1247.32	Calgary	BASF
530	Milestone	SK	239.03	22.19	17.48	11.82	7.60	4.93	3.85	2.93	1115.40	Calgary	BASF
531	Montmartre	SK	244.05	24.41	19.48	13.20	8.50	5.51	4.30	3.28	1253.71	Calgary	BASF
532	Moose Jaw	SK	239.03	20.74	16.16	10.91	7.01	4.54	3.54	2.70	1024.57	Calgary	BASF
533	Moosomin	SK	332.81	33.28	27.53	18.75	12.10	7.87	6.14	4.66	1808.46	Calgary	BASF
534	Morse	SK	239.03	20.74	16.16	10.91	7.01	4.54	3.54	2.70	1024.57	Calgary	BASF
535	Mossbank	SK	239.03	22.23	17.51	11.84	7.61	4.93	3.85	2.93	1117.47	Calgary	BASF
536	Naicam	SK	335.08	33.51	27.73	18.89	12.19	7.93	6.19	4.70	1822.60	Calgary	BASF
537	Neilburg	SK	247.18	24.72	19.77	13.40	8.62	5.60	4.37	3.32	1273.26	Calgary	BASF
538	Neville	SK	247.18	24.72	19.77	13.40	8.62	5.60	4.37	3.32	1273.26	Calgary	BASF
539	Nipawin	SK	380.34	38.03	31.83	21.72	14.03	9.13	7.12	5.41	2105.53	Calgary	BASF
540	Nokomis	SK	258.34	25.83	20.78	14.09	9.08	5.89	4.60	3.50	1342.97	Calgary	BASF
541	Norquay	SK	362.61	36.26	30.23	20.61	13.31	8.66	6.76	5.13	1994.72	Calgary	BASF
542	North Battleford	SK	304.52	30.45	24.96	16.98	10.95	7.12	5.55	4.22	1631.63	Calgary	BASF
543	Odessa	SK	239.03	23.35	18.52	12.54	8.07	5.23	4.08	3.11	1187.65	Calgary	BASF
544	Ogema	SK	239.03	23.32	18.49	12.52	8.05	5.22	4.08	3.11	1185.59	Calgary	BASF
545	Osler	SK	314.71	31.47	25.89	17.62	11.37	7.39	5.77	4.38	1695.29	Calgary	BASF
546	Oungre	SK	271.14	27.11	21.94	14.89	9.60	6.23	4.86	3.70	1422.99	Calgary	BASF
547	Outlook	SK	242.28	24.23	19.32	13.09	8.42	5.47	4.27	3.25	1242.61	Calgary	BASF
548	Oxbow	SK	339.98	34.00	28.18	19.20	12.39	8.06	6.29	4.77	1853.25	Calgary	BASF
549	Pangman	SK	239.03	23.84	18.97	12.85	8.27	5.36	4.19	3.19	1218.62	Calgary	BASF
550	Paradise Hill	SK	269.06	26.91	21.75	14.76	9.51	6.18	4.82	3.67	1410.01	Calgary	BASF
551	Parkside	SK	339.60	33.96	28.14	19.17	12.38	8.05	6.28	4.77	1850.90	Calgary	BASF
552	Paynton	SK	277.36	27.74	22.50	15.28	9.85	6.40	4.99	3.80	1461.87	Calgary	BASF
553	Peesane	SK	356.96	35.70	29.71	20.26	13.08	8.51	6.64	5.04	1959.35	Calgary	BASF
554	Pelly	SK	368.65	36.87	30.77	20.99	13.56	8.82	6.88	5.22	2032.44	Calgary	BASF
555	Pense	SK	239.03	20.77	16.19	10.93	7.02	4.55	3.55	2.71	1026.63	Calgary	BASF
556	Perdue	SK	266.42	26.64	21.51	14.60	9.41	6.11	4.77	3.62	1393.50	Calgary	BASF
557	Pilot Butte	SK	239.03	21.40	16.76	11.32	7.28	4.71	3.68	2.81	1065.86	Calgary	BASF
558	Plenty	SK	255.86	25.59	20.55	13.94	8.98	5.83	4.55	3.46	1327.49	Calgary	BASF
559	Ponteix	SK	256.23	25.62	20.59	13.96	8.99	5.84	4.56	3.47	1329.84	Calgary	BASF
560	Porcupine Plain	SK	375.82	37.58	31.42	21.44	13.85	9.01	7.03	5.33	2077.24	Calgary	BASF
561	Prairie River	SK	401.85	40.18	33.78	23.06	14.91	9.70	7.57	5.74	2239.92	Calgary	BASF
562	Prince Albert	SK	349.03	34.90	29.00	19.76	12.76	8.30	6.48	4.92	1909.84	Calgary	BASF
563	Quill Lake	Sk	329.04	32.90	27.18	18.51	11.95	7.77	6.06	4.60	1784.88	Calgary	BASF
564	Rabbit Lake	SK	339.98	34.00	28.18	19.20	12.39	8.06	6.29	4.77	1853.25	Calgary	BASF
565	Radisson	SK	306.78	30.68	25.17	17.12	11.05	7.18	5.60	4.26	1645.78	Calgary	BASF
566	Radville	SK	254.29	25.43	20.41	13.84	8.91	5.78	4.52	3.44	1317.71	Calgary	BASF
567	Rama	SK	348.28	34.83	28.93	19.71	12.73	8.28	6.46	4.90	1905.12	Calgary	BASF
568	Raymore	SK	251.65	25.17	20.17	13.67	8.81	5.71	4.46	3.39	1301.19	Calgary	BASF
569	Redvers	SK	363.37	36.34	30.30	20.66	13.34	8.68	6.77	5.14	1999.43	Calgary	BASF
570	Regina	SK	239.03	16.95	12.73	8.54	5.47	3.53	2.76	2.11	743.12	Calgary	BASF
571	Rhein	SK	333.19	33.32	27.56	18.77	12.12	7.88	6.15	4.67	1810.82	Calgary	BASF
572	Riceton	SK	239.03	22.49	17.75	12.00	7.72	5.00	3.91	2.98	1133.98	Calgary	BASF
573	Richardson	SK	239.03	21.00	16.40	11.07	7.11	4.61	3.60	2.74	1041.08	Calgary	BASF
574	Ridgedale	SK	381.10	38.11	31.90	21.77	14.06	9.15	7.14	5.42	2110.24	Calgary	BASF
575	Rocanville	SK	344.13	34.41	28.55	19.45	12.56	8.17	6.37	4.84	1879.19	Calgary	BASF
576	Rockhaven	SK	299.99	30.00	24.55	16.70	10.77	7.00	5.46	4.15	1603.34	Calgary	BASF
577	Rose Valley	SK	343.00	34.30	28.45	19.38	12.52	8.14	6.35	4.82	1872.12	Calgary	BASF
578	Rosetown	SK	241.90	24.19	19.29	13.07	8.41	5.46	4.26	3.24	1240.25	Calgary	BASF
579	Rosthern	SK	331.30	33.13	27.39	18.65	12.04	7.83	6.11	4.64	1799.03	Calgary	BASF
580	Rouleau	SK	239.03	21.70	17.03	11.51	7.40	4.79	3.74	2.85	1084.44	Calgary	BASF
581	Rowatt	SK	239.03	20.90	16.31	11.01	7.07	4.58	3.58	2.73	1034.89	Calgary	BASF
582	Saskatoon	SK	239.03	20.77	16.19	10.93	7.02	4.55	3.55	2.71	1026.74	Calgary	BASF
583	Sceptre	Sk	249.44	24.94	19.97	13.54	8.72	5.66	4.42	3.36	1287.40	Calgary	BASF
584	Sedley	SK	239.03	22.62	17.87	12.09	7.77	5.04	3.93	3.00	1142.24	Calgary	BASF
585	Shamrock	SK	239.03	21.76	17.09	11.55	7.42	4.81	3.76	2.86	1088.56	Calgary	BASF
586	Shaunavon	SK	253.59	25.36	20.35	13.80	8.88	5.77	4.50	3.42	1313.34	Calgary	BASF
587	Shellbrook	SK	346.02	34.60	28.72	19.57	12.64	8.22	6.41	4.87	1890.98	Calgary	BASF
588	Simpson	SK	250.00	25.00	20.02	13.57	8.74	5.67	4.43	3.37	1290.87	Calgary	BASF
589	Sintaluta	SK	242.73	24.27	19.36	13.12	8.44	5.48	4.28	3.25	1245.45	Calgary	BASF
590	Southey	SK	239.03	23.05	18.26	12.35	7.95	5.15	4.02	3.06	1169.07	Calgary	BASF
591	Spalding	SK	330.55	33.05	27.32	18.61	12.01	7.81	6.09	4.63	1794.31	Calgary	BASF
592	Speers	SK	315.46	31.55	25.95	17.66	11.40	7.41	5.78	4.39	1700.00	Calgary	BASF
593	Spiritwood	SK	332.81	33.28	27.53	18.75	12.10	7.87	6.14	4.66	1808.46	Calgary	BASF
594	St Brieux	SK	349.41	34.94	29.03	19.78	12.78	8.31	6.48	4.92	1912.20	Calgary	BASF
595	St. Walburg	SK	280.00	28.00	22.74	15.45	9.96	6.47	5.05	3.84	1478.38	Calgary	BASF
596	Star City	SK	360.73	36.07	30.06	20.49	13.24	8.61	6.72	5.10	1982.93	Calgary	BASF
597	Stewart Valley	SK	243.79	24.38	19.46	13.18	8.49	5.51	4.30	3.27	1252.04	Calgary	BASF
598	Stockholm	SK	328.66	32.87	27.15	18.49	11.93	7.76	6.05	4.60	1782.52	Calgary	BASF
599	Stoughton	SK	263.21	26.32	21.22	14.40	9.28	6.02	4.70	3.57	1373.44	Calgary	BASF
600	Strasbourg	SK	239.03	23.88	19.00	12.87	8.28	5.37	4.19	3.19	1220.68	Calgary	BASF
601	Strongfield	SK	266.42	26.64	21.51	14.60	9.41	6.11	4.77	3.62	1393.50	Calgary	BASF
602	Sturgis	SK	358.47	35.85	29.85	20.35	13.14	8.55	6.67	5.06	1968.78	Calgary	BASF
603	Swift Current	SK	239.03	22.95	18.16	12.29	7.90	5.13	4.00	3.05	1162.45	Calgary	BASF
604	Theodore	SK	328.29	32.83	27.12	18.46	11.92	7.75	6.05	4.59	1780.17	Calgary	BASF
605	Tisdale	SK	366.39	36.64	30.57	20.85	13.47	8.76	6.84	5.19	2018.29	Calgary	BASF
606	Tompkins	SK	239.03	22.91	18.13	12.26	7.89	5.12	3.99	3.04	1160.09	Calgary	BASF
607	Torquay	SK	277.88	27.79	22.55	15.31	9.87	6.41	5.00	3.80	1465.10	Calgary	BASF
608	Tribune	SK	268.44	26.84	21.69	14.72	9.49	6.16	4.81	3.66	1406.14	Calgary	BASF
609	Tugaske	SK	239.03	22.57	17.82	12.05	7.75	5.02	3.92	2.99	1138.73	Calgary	BASF
610	Turtleford	SK	291.69	29.17	23.80	16.18	10.43	6.78	5.29	4.02	1551.47	Calgary	BASF
611	Tuxford	SK	239.03	21.43	16.79	11.34	7.29	4.72	3.69	2.81	1067.92	Calgary	BASF
612	Unity	SK	261.14	26.11	21.03	14.27	9.19	5.97	4.66	3.54	1360.49	Calgary	BASF
613	Valparaiso	SK	364.88	36.49	30.43	20.75	13.41	8.72	6.80	5.16	2008.86	Calgary	BASF
614	Vanscoy	SK	259.25	25.93	20.86	14.15	9.11	5.92	4.62	3.51	1348.71	Calgary	BASF
615	Vibank	SK	239.03	22.82	18.05	12.21	7.85	5.09	3.98	3.03	1154.62	Calgary	BASF
616	Viscount	SK	316.21	31.62	26.02	17.71	11.43	7.43	5.80	4.40	1704.72	Calgary	BASF
617	Wadena	SK	324.89	32.49	26.81	18.25	11.78	7.66	5.98	4.54	1758.95	Calgary	BASF
618	Wakaw	SK	339.23	33.92	28.11	19.15	12.36	8.04	6.27	4.76	1848.54	Calgary	BASF
619	Waldheim	SK	326.40	32.64	26.95	18.35	11.84	7.70	6.01	4.56	1768.38	Calgary	BASF
620	Waldron	SK	280.91	28.09	22.82	15.50	9.99	6.49	5.07	3.85	1484.05	Calgary	BASF
621	Wapella	Sk	288.31	28.83	23.49	15.97	10.29	6.69	5.22	3.97	1530.34	Calgary	BASF
622	Watrous	SK	259.91	25.99	20.92	14.19	9.14	5.93	4.63	3.52	1352.80	Calgary	BASF
623	Watson	SK	286.66	28.67	23.34	15.86	10.23	6.64	5.19	3.94	1520.01	Calgary	BASF
624	Wawota	SK	342.62	34.26	28.42	19.36	12.50	8.13	6.34	4.82	1869.76	Calgary	BASF
625	Weyburn	SK	244.71	24.47	19.54	13.24	8.52	5.53	4.32	3.29	1257.84	Calgary	BASF
626	White City	SK	239.03	21.47	16.82	11.36	7.30	4.73	3.70	2.82	1069.99	Calgary	BASF
627	White Star	SK	353.18	35.32	29.37	20.02	12.93	8.41	6.56	4.98	1935.77	Calgary	BASF
628	Whitewood	SK	278.40	27.84	22.60	15.35	9.89	6.43	5.01	3.81	1468.40	Calgary	BASF
629	Wilcox	Sk	239.03	21.73	17.06	11.53	7.41	4.80	3.75	2.86	1086.50	Calgary	BASF
630	Wilkie	SK	280.00	28.00	22.74	15.45	9.96	6.47	5.05	3.84	1478.38	Calgary	BASF
631	Wiseton	SK	271.32	27.13	21.95	14.90	9.60	6.24	4.87	3.70	1424.15	Calgary	BASF
632	Wolseley	SK	248.35	24.83	19.87	13.47	8.67	5.63	4.39	3.34	1280.55	Calgary	BASF
633	Woodrow	SK	250.20	25.02	20.04	13.58	8.75	5.68	4.43	3.37	1292.12	Calgary	BASF
634	Wymark	SK	240.77	24.08	19.18	12.99	8.36	5.43	4.24	3.22	1233.18	Calgary	BASF
635	Wynyard	SK	278.74	27.87	22.63	15.37	9.91	6.43	5.02	3.82	1470.47	Calgary	BASF
636	Yellow Creek 	SK	298.11	29.81	24.38	16.58	10.69	6.95	5.42	4.12	1591.55	Calgary	BASF
637	Yellow Grass	SK	239.03	23.58	18.73	12.68	8.16	5.29	4.13	3.15	1202.10	Calgary	BASF
638	Yorkton	SK	282.70	28.27	22.98	15.62	10.07	6.54	5.10	3.88	1495.24	Calgary	BASF
639	Acadia Valley	AB	197.60	19.76	17.91	12.35	8.03	5.25	4.09	3.09	1235.02	Edmonton	BASF
640	Airdrie	AB	195.57	7.25	6.57	4.53	2.95	1.93	1.50	1.13	453.17	Edmonton	BASF
641	Alix	AB	195.57	7.93	7.19	4.96	3.22	2.11	1.64	1.24	495.90	Edmonton	BASF
642	Alliance	AB	195.57	11.84	10.73	7.40	4.81	3.14	2.45	1.85	739.91	Edmonton	BASF
643	Amisk	AB	195.57	12.14	11.00	7.59	4.93	3.22	2.51	1.90	758.77	Edmonton	BASF
644	Andrew	AB	195.57	5.78	5.23	3.61	2.35	1.53	1.20	0.90	360.96	Edmonton	BASF
645	Athabasca	AB	195.57	7.27	6.59	4.54	2.95	1.93	1.50	1.14	454.42	Edmonton	BASF
646	Balzac	AB	195.57	7.32	6.64	4.58	2.97	1.95	1.52	1.14	457.67	Edmonton	BASF
647	Barons	AB	195.57	15.23	13.80	9.52	6.19	4.05	3.15	2.38	951.89	Edmonton	BASF
648	Barrhead	AB	195.57	6.02	5.46	3.76	2.45	1.60	1.25	0.94	376.47	Edmonton	BASF
649	Bashaw	AB	195.57	6.57	5.95	4.10	2.67	1.74	1.36	1.03	387.20	Edmonton	BASF
650	Bassano	AB	195.57	13.01	11.79	8.13	5.28	3.46	2.69	2.03	813.02	Edmonton	BASF
651	Bay Tree	AB	195.57	12.92	11.71	8.08	5.25	3.43	2.67	2.02	807.70	Edmonton	BASF
652	Beaverlodge	AB	278.05	27.81	25.20	17.38	11.30	7.39	5.75	4.34	1639.47	Edmonton	BASF
653	Beiseker	AB	195.57	8.80	7.97	5.50	3.57	2.34	1.82	1.37	549.88	Edmonton	BASF
654	Benalto	AB	195.57	8.29	7.52	5.18	3.37	2.20	1.72	1.30	518.39	Edmonton	BASF
655	Bentley	AB	195.57	7.29	6.60	4.55	2.96	1.94	1.51	1.14	455.42	Edmonton	BASF
656	Blackfalds	AB	195.57	6.85	6.21	4.28	2.78	1.82	1.42	1.07	428.43	Edmonton	BASF
657	Blackie	AB	195.57	10.38	9.41	6.49	4.22	2.76	2.15	1.62	648.84	Edmonton	BASF
658	Bon Accord 	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
659	Bonnyville	AB	195.57	11.99	10.87	7.49	4.87	3.18	2.48	1.87	749.34	Edmonton	BASF
660	Bow Island	AB	236.46	23.65	21.43	14.78	9.61	6.28	4.89	3.69	1477.87	Edmonton	BASF
661	Boyle	AB	195.57	7.34	6.66	4.59	2.98	1.95	1.52	1.15	459.00	Edmonton	BASF
662	Brooks	AB	195.57	15.38	13.94	9.61	6.25	4.09	3.18	2.40	961.45	Edmonton	BASF
663	Burdett	AB	222.88	22.29	20.20	13.93	9.05	5.92	4.61	3.48	1392.99	Edmonton	BASF
664	Calgary	AB	195.57	7.25	6.57	4.53	2.95	1.93	1.50	1.13	453.17	Edmonton	BASF
665	Calmar	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
666	Camrose	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Edmonton	BASF
667	Carbon	AB	195.57	9.48	8.59	5.93	3.85	2.52	1.96	1.48	592.61	Edmonton	BASF
668	Cardston	AB	195.57	18.59	16.85	11.62	7.55	4.94	3.85	2.90	1161.94	Edmonton	BASF
669	Carseland	AB	195.57	9.99	9.05	6.24	4.06	2.65	2.07	1.56	624.10	Edmonton	BASF
670	Carstairs	AB	195.57	7.32	6.64	4.58	2.97	1.95	1.52	1.14	457.67	Edmonton	BASF
671	Castor	AB	195.57	11.01	9.98	6.88	4.47	2.92	2.28	1.72	649.09	Edmonton	BASF
672	Clandonald	AB	195.57	11.23	10.18	7.02	4.56	2.98	2.33	1.76	702.18	Edmonton	BASF
673	Claresholm	AB	195.57	13.40	12.15	8.38	5.45	3.56	2.77	2.09	837.76	Edmonton	BASF
674	Clyde	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
675	Coaldale	AB	195.57	18.36	16.64	11.48	7.46	4.88	3.80	2.87	1147.79	Edmonton	BASF
676	Cochrane	AB	195.57	8.33	7.55	5.21	3.38	2.21	1.72	1.30	520.64	Edmonton	BASF
677	Consort	AB	195.57	16.70	15.14	10.44	6.79	4.44	3.46	2.61	1044.05	Edmonton	BASF
678	Coronation	AB	195.57	12.37	11.21	7.73	5.02	3.28	2.56	1.93	772.91	Edmonton	BASF
679	Cremona	AB	195.57	8.22	7.45	5.14	3.34	2.18	1.70	1.28	513.89	Edmonton	BASF
680	Crossfield	AB	195.57	7.29	6.60	4.55	2.96	1.94	1.51	1.14	455.42	Edmonton	BASF
681	Cypress County	AB	209.68	20.97	19.00	13.10	8.52	5.57	4.34	3.28	1310.47	Edmonton	BASF
682	Czar	AB	195.57	14.18	12.85	8.86	5.76	3.77	2.93	2.22	886.08	Edmonton	BASF
683	Daysland	AB	195.57	6.71	6.08	4.19	2.73	1.78	1.39	1.05	419.43	Edmonton	BASF
684	Debolt	AB	226.74	22.67	20.55	14.17	9.21	6.02	4.69	3.54	1417.10	Edmonton	BASF
685	Delburne	AB	195.57	9.16	8.30	5.72	3.72	2.43	1.90	1.43	572.37	Edmonton	BASF
686	Delia	AB	195.57	11.86	10.75	7.41	4.82	3.15	2.45	1.85	741.05	Edmonton	BASF
687	Dewberry	AB	195.57	11.76	10.66	7.35	4.78	3.12	2.43	1.84	735.19	Edmonton	BASF
688	Diamond City	AB	195.57	17.05	15.45	10.65	6.92	4.53	3.53	2.66	1065.27	Edmonton	BASF
689	Dickson	AB	195.57	8.44	7.65	5.27	3.43	2.24	1.75	1.32	527.39	Edmonton	BASF
690	Didsbury	AB	195.57	7.47	6.77	4.67	3.03	1.98	1.55	1.17	466.66	Edmonton	BASF
691	Drayton Valley	AB	195.57	7.00	6.34	4.37	2.84	1.86	1.45	1.09	437.42	Edmonton	BASF
692	Drumheller	AB	195.57	10.71	9.70	6.69	4.35	2.84	2.22	1.67	669.08	Edmonton	BASF
693	Dunmore	AB	214.58	21.46	19.45	13.41	8.72	5.70	4.44	3.35	1341.12	Edmonton	BASF
694	Eaglesham	AB	268.65	26.86	24.35	16.79	10.91	7.14	5.56	4.20	1679.03	Edmonton	BASF
695	Eckville	AB	195.57	8.80	7.97	5.50	3.57	2.34	1.82	1.37	549.88	Edmonton	BASF
696	Edberg	AB	195.57	6.06	5.49	3.79	2.46	1.61	1.25	0.95	357.51	Edmonton	BASF
697	Edgerton	AB	195.57	13.65	12.37	8.53	5.54	3.63	2.82	2.13	853.08	Edmonton	BASF
698	Edmonton	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Edmonton	BASF
699	Enchant	AB	195.57	19.35	17.53	12.09	7.86	5.14	4.00	3.02	1209.09	Edmonton	BASF
700	Ervick	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
701	Evansburg	AB	195.57	5.34	4.84	3.34	2.17	1.42	1.11	0.83	333.97	Edmonton	BASF
702	Fairview	AB	310.55	31.06	28.14	19.41	12.62	8.25	6.43	4.85	1940.97	Edmonton	BASF
703	Falher	AB	242.13	24.21	21.94	15.13	9.84	6.43	5.01	3.78	1427.66	Edmonton	BASF
704	Foremost	AB	228.16	22.82	20.68	14.26	9.27	6.06	4.72	3.56	1426.00	Edmonton	BASF
705	Forestburg	AB	195.57	8.44	7.65	5.27	3.43	2.24	1.75	1.32	527.39	Edmonton	BASF
706	Fort MacLeod	AB	195.57	15.06	13.65	9.41	6.12	4.00	3.12	2.35	941.21	Edmonton	BASF
707	Fort Saskatchewan	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Edmonton	BASF
708	Fort Vermilion	AB	306.73	30.98	28.08	19.36	12.58	8.22	6.41	4.85	1917.04	Edmonton	BASF
709	Galahad	AB	195.57	9.16	8.30	5.72	3.72	2.43	1.90	1.43	572.37	Edmonton	BASF
710	Girouxville	AB	248.12	24.81	22.49	15.51	10.08	6.59	5.13	3.88	1550.74	Edmonton	BASF
711	Gleichen	AB	195.57	11.07	10.03	6.92	4.50	2.94	2.29	1.73	691.57	Edmonton	BASF
712	Glendon	AB	195.57	10.63	9.63	6.64	4.32	2.82	2.20	1.66	664.46	Edmonton	BASF
713	Grande Prairie	AB	255.82	25.58	23.18	15.99	10.39	6.80	5.29	4.00	1598.85	Edmonton	BASF
714	Grassy Lake	AB	216.84	21.68	19.65	13.55	8.81	5.76	4.49	3.39	1355.27	Edmonton	BASF
715	Grimshaw	AB	284.90	28.49	25.82	17.81	11.57	7.57	5.90	4.45	1780.60	Edmonton	BASF
716	Guy	AB	228.45	22.84	20.70	14.28	9.28	6.07	4.73	3.57	1346.97	Edmonton	BASF
717	Hairy Hill	AB	195.57	6.21	5.63	3.88	2.52	1.65	1.28	0.97	387.95	Edmonton	BASF
718	Halkirk	AB	195.57	10.03	9.09	6.27	4.07	2.66	2.08	1.57	626.74	Edmonton	BASF
719	Hanna	AB	195.57	13.65	12.37	8.53	5.54	3.63	2.82	2.13	853.08	Edmonton	BASF
720	Heisler	AB	195.57	8.22	7.45	5.14	3.34	2.18	1.70	1.28	513.57	Edmonton	BASF
721	High Level	AB	426.87	42.69	38.69	26.68	17.34	11.34	8.83	6.67	2667.97	Edmonton	BASF
722	High Prairie	AB	201.08	20.11	18.22	12.57	8.17	5.34	4.16	3.14	1256.73	Edmonton	BASF
723	High River	AB	195.57	10.13	9.18	6.33	4.12	2.69	2.10	1.58	633.09	Edmonton	BASF
724	Hines Creek	AB	319.11	31.91	28.92	19.94	12.96	8.48	6.60	4.99	1994.42	Edmonton	BASF
725	Holden	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
726	Hussar	AB	195.57	11.57	10.48	7.23	4.70	3.07	2.39	1.81	723.05	Edmonton	BASF
727	Hythe	AB	288.32	28.83	26.13	18.02	11.71	7.66	5.97	4.50	1801.98	Edmonton	BASF
728	Innisfail	AB	195.57	7.32	6.64	4.58	2.97	1.95	1.52	1.14	457.67	Edmonton	BASF
729	Innisfree	AB	195.57	6.85	6.21	4.28	2.78	1.82	1.42	1.07	428.43	Edmonton	BASF
730	Irma	AB	195.57	9.95	9.02	6.22	4.04	2.64	2.06	1.56	622.02	Edmonton	BASF
731	Iron Springs	AB	195.57	17.76	16.10	11.10	7.22	4.72	3.68	2.78	1110.07	Edmonton	BASF
732	Joffre	AB	195.57	7.14	6.48	4.47	2.90	1.90	1.48	1.12	446.42	Edmonton	BASF
733	Killam	AB	195.57	9.23	8.36	5.77	3.75	2.45	1.91	1.44	544.21	Edmonton	BASF
734	Kirriemuir	AB	195.57	18.40	16.68	11.50	7.48	4.89	3.81	2.88	1150.15	Edmonton	BASF
735	Kitscoty	AB	195.57	11.16	10.11	6.97	4.53	2.96	2.31	1.74	697.47	Edmonton	BASF
736	La Glace	AB	276.34	27.63	25.04	17.27	11.23	7.34	5.72	4.32	1727.14	Edmonton	BASF
737	Lac La Biche	AB	195.57	10.78	9.77	6.74	4.38	2.86	2.23	1.68	673.89	Edmonton	BASF
738	Lacombe	AB	195.57	6.14	5.56	3.83	2.49	1.63	1.27	0.96	361.74	Edmonton	BASF
739	LaCrete	AB	374.70	37.47	33.96	23.42	15.22	9.95	7.75	5.85	2209.33	Edmonton	BASF
740	Lamont	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
741	Lavoy	AB	195.57	5.70	5.17	3.56	2.32	1.51	1.18	0.89	356.46	Edmonton	BASF
742	Leduc	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
743	Legal	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Edmonton	BASF
744	Lethbridge	AB	195.57	17.69	16.03	11.05	7.18	4.70	3.66	2.76	1105.35	Edmonton	BASF
745	Linden	AB	195.57	8.65	7.84	5.41	3.52	2.30	1.79	1.35	540.88	Edmonton	BASF
746	Lloydminster	AB	195.57	12.14	11.00	7.59	4.93	3.22	2.51	1.90	758.77	Edmonton	BASF
747	Lomond	AB	195.57	15.02	13.61	9.39	6.10	3.99	3.11	2.35	938.96	Edmonton	BASF
748	Lougheed	AB	195.57	10.25	9.29	6.41	4.17	2.72	2.12	1.60	640.88	Edmonton	BASF
749	Magrath	AB	195.57	19.27	17.46	12.04	7.83	5.12	3.99	3.01	1204.37	Edmonton	BASF
750	Mallaig	AB	195.57	9.30	8.43	5.81	3.78	2.47	1.93	1.45	581.36	Edmonton	BASF
751	Manning	AB	324.24	32.42	29.38	20.26	13.17	8.61	6.71	5.07	2026.50	Edmonton	BASF
752	Marwayne	AB	195.57	11.99	10.87	7.49	4.87	3.18	2.48	1.87	749.34	Edmonton	BASF
753	Mayerthorpe	AB	195.57	7.27	6.59	4.54	2.95	1.93	1.50	1.14	454.42	Edmonton	BASF
754	McLennan	AB	227.59	22.76	20.63	14.22	9.25	6.05	4.71	3.56	1422.45	Edmonton	BASF
755	Medicine Hat	AB	209.68	20.97	19.00	13.10	8.52	5.57	4.34	3.28	1310.47	Edmonton	BASF
756	Milk River	AB	216.09	21.61	19.58	13.51	8.78	5.74	4.47	3.38	1350.55	Edmonton	BASF
757	Milo	AB	195.57	13.30	12.05	8.31	5.40	3.53	2.75	2.08	831.01	Edmonton	BASF
758	Minburn	AB	195.57	7.57	6.86	4.73	3.08	2.01	1.57	1.18	473.41	Edmonton	BASF
759	Morinville	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
760	Mossleigh	AB	195.57	11.07	10.03	6.92	4.50	2.94	2.29	1.73	691.57	Edmonton	BASF
761	Mundare	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
762	Myrnam	AB	195.57	8.51	7.71	5.32	3.46	2.26	1.76	1.33	531.89	Edmonton	BASF
763	Nampa	AB	257.53	25.75	23.34	16.10	10.46	6.84	5.33	4.02	1609.54	Edmonton	BASF
764	Nanton	AB	195.57	11.42	10.35	7.14	4.64	3.03	2.36	1.79	714.06	Edmonton	BASF
765	Neerlandia	AB	195.57	7.05	6.39	4.41	2.86	1.87	1.46	1.10	440.66	Edmonton	BASF
766	New Dayton	AB	197.23	19.72	17.87	12.33	8.01	5.24	4.08	3.08	1232.67	Edmonton	BASF
767	New Norway	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
768	Nisku	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
769	Nobleford	AB	195.57	15.53	14.07	9.70	6.31	4.12	3.21	2.43	970.45	Edmonton	BASF
770	Okotoks	AB	195.57	9.01	8.17	5.63	3.66	2.39	1.87	1.41	563.37	Edmonton	BASF
771	Olds	AB	195.57	7.50	6.80	4.69	3.05	1.99	1.55	1.17	468.91	Edmonton	BASF
772	Onoway	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
773	Oyen	AB	195.57	18.52	16.78	11.57	7.52	4.92	3.83	2.89	1157.22	Edmonton	BASF
774	Paradise Valley	AB	195.57	12.59	11.41	7.87	5.12	3.35	2.61	1.97	787.06	Edmonton	BASF
775	Peers	AB	195.57	8.58	7.78	5.36	3.49	2.28	1.78	1.34	536.38	Edmonton	BASF
776	Penhold	AB	195.57	7.18	6.51	4.49	2.92	1.91	1.49	1.12	448.67	Edmonton	BASF
777	Picture Butte	AB	195.57	17.16	15.55	10.72	6.97	4.56	3.55	2.68	1072.34	Edmonton	BASF
778	Pincher Creek	AB	195.57	17.84	16.16	11.15	7.25	4.74	3.69	2.79	1114.78	Edmonton	BASF
779	Ponoka	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Edmonton	BASF
780	Provost	AB	195.57	16.06	14.56	10.04	6.53	4.27	3.32	2.51	947.14	Edmonton	BASF
781	Raymond	AB	195.57	19.19	17.40	12.00	7.80	5.10	3.97	3.00	1199.66	Edmonton	BASF
782	Red Deer (Red Deer County)	AB	195.57	7.32	6.64	4.58	2.97	1.95	1.52	1.14	431.76	Edmonton	BASF
783	Rimbey	AB	195.57	6.85	6.21	4.28	2.78	1.82	1.42	1.07	428.43	Edmonton	BASF
784	Rivercourse	AB	195.57	13.65	12.37	8.53	5.54	3.63	2.82	2.13	853.08	Edmonton	BASF
785	Rocky Mountain House	AB	195.57	10.86	9.84	6.79	4.41	2.88	2.25	1.70	678.61	Edmonton	BASF
786	Rocky View	AB	195.57	7.54	6.83	4.71	3.06	2.00	1.56	1.18	471.16	Edmonton	BASF
787	Rolling Hills	AB	195.57	18.10	16.40	11.31	7.35	4.81	3.75	2.83	1131.29	Edmonton	BASF
788	Rosalind	AB	195.57	6.64	6.02	4.15	2.70	1.76	1.37	1.04	414.93	Edmonton	BASF
789	Rosebud	AB	195.57	10.60	9.60	6.62	4.31	2.81	2.19	1.66	662.33	Edmonton	BASF
790	Rosedale	AB	195.57	10.92	9.90	6.83	4.44	2.90	2.26	1.71	682.57	Edmonton	BASF
791	Rycroft	AB	287.46	28.75	26.05	17.97	11.68	7.64	5.95	4.49	1796.64	Edmonton	BASF
792	Ryley	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
793	Scandia	AB	195.57	15.60	14.14	9.75	6.33	4.14	3.23	2.43	974.95	Edmonton	BASF
794	Sedgewick	AB	195.57	10.18	9.22	6.36	4.14	2.70	2.11	1.59	600.16	Edmonton	BASF
795	Sexsmith	AB	261.80	26.18	23.73	16.36	10.64	6.95	5.42	4.09	1636.27	Edmonton	BASF
796	Sherwood Park	AB	195.57	5.30	4.80	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
797	Silver Valley	AB	315.69	31.57	28.61	19.73	12.82	8.39	6.53	4.93	1973.04	Edmonton	BASF
798	Slave Lake	AB	195.57	12.29	11.14	7.68	4.99	3.26	2.54	1.92	768.20	Edmonton	BASF
799	Smoky Lake	AB	195.57	5.70	5.17	3.56	2.32	1.51	1.18	0.89	356.46	Edmonton	BASF
800	Spirit River	AB	291.74	29.17	26.44	18.23	11.85	7.75	6.04	4.56	1823.36	Edmonton	BASF
801	Spruce Grove	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
802	Spruce View	AB	195.57	8.33	7.55	5.21	3.38	2.21	1.72	1.30	520.64	Edmonton	BASF
803	St Albert	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Edmonton	BASF
804	St Isidore	AB	266.08	26.61	24.11	16.63	10.81	7.07	5.51	4.16	1663.00	Edmonton	BASF
805	St Paul	AB	195.57	10.03	9.09	6.27	4.07	2.66	2.08	1.57	626.74	Edmonton	BASF
806	Standard	AB	195.57	10.89	9.86	6.80	4.42	2.89	2.25	1.70	680.32	Edmonton	BASF
807	Stettler	AB	195.57	8.51	7.71	5.32	3.46	2.26	1.76	1.33	501.78	Edmonton	BASF
808	Stirling	AB	195.57	19.12	17.33	11.95	7.77	5.08	3.96	2.99	1194.94	Edmonton	BASF
809	Stony Plain	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
810	Strathmore	AB	195.57	9.48	8.59	5.93	3.85	2.52	1.96	1.48	592.61	Edmonton	BASF
811	Strome	AB	195.57	7.43	6.73	4.64	3.02	1.97	1.54	1.16	464.41	Edmonton	BASF
812	Sturgeon County	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
813	Sturgeon Valley	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
814	Sunnybrook	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
815	Sylvan Lake	AB	195.57	7.79	7.06	4.87	3.16	2.07	1.61	1.22	486.90	Edmonton	BASF
816	Taber	AB	202.51	20.25	18.35	12.66	8.23	5.38	4.19	3.16	1265.67	Edmonton	BASF
817	Thorhild	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
818	Three Hills	AB	195.57	9.16	8.30	5.72	3.72	2.43	1.90	1.43	572.37	Edmonton	BASF
819	Tofield	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
820	Torrington	AB	195.57	8.55	7.74	5.34	3.47	2.27	1.77	1.34	534.13	Edmonton	BASF
821	Trochu	AB	195.57	9.16	8.30	5.72	3.72	2.43	1.90	1.43	572.37	Edmonton	BASF
822	Turin	AB	195.57	18.14	16.44	11.34	7.37	4.82	3.75	2.83	1133.64	Edmonton	BASF
823	Two Hills	AB	195.57	6.93	6.28	4.33	2.81	1.84	1.43	1.08	432.93	Edmonton	BASF
824	Valleyview	AB	197.66	19.77	17.91	12.35	8.03	5.25	4.09	3.09	1235.35	Edmonton	BASF
825	Vauxhall	AB	195.57	18.74	16.98	11.71	7.61	4.98	3.88	2.93	1171.37	Edmonton	BASF
826	Vegreville	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
827	Vermilion	AB	195.57	9.01	8.17	5.63	3.66	2.39	1.87	1.41	531.48	Edmonton	BASF
828	Veteran	AB	195.57	13.57	12.30	8.48	5.51	3.61	2.81	2.12	848.36	Edmonton	BASF
829	Viking	AB	195.57	7.57	6.86	4.73	3.08	2.01	1.57	1.18	446.61	Edmonton	BASF
830	Vulcan	AB	195.57	12.86	11.66	8.04	5.23	3.42	2.66	2.01	804.02	Edmonton	BASF
831	Wainwright	AB	195.57	12.14	11.00	7.59	4.93	3.22	2.51	1.90	715.82	Edmonton	BASF
832	Wanham	AB	269.50	26.95	24.42	16.84	10.95	7.16	5.58	4.21	1684.38	Edmonton	BASF
833	Warburg	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
834	Warner	AB	207.03	20.70	18.76	12.94	8.41	5.50	4.28	3.23	1293.97	Edmonton	BASF
835	Waskatenau	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
836	Wembley	AB	227.23	22.95	20.80	14.34	9.32	6.10	4.75	3.59	1420.16	Edmonton	BASF
837	Westlock	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Edmonton	BASF
838	Wetaskiwin	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
839	Whitecourt	AB	195.57	9.23	8.36	5.77	3.75	2.45	1.91	1.44	576.87	Edmonton	BASF
840	Willow Springs	AB	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Edmonton	BASF
841	Winfield	AB	195.57	5.85	5.30	3.65	2.38	1.55	1.21	0.91	365.46	Edmonton	BASF
842	Dawson Creek	BC	373.74	37.37	31.24	21.31	13.77	8.96	6.99	5.30	1947.42	Edmonton	BASF
843	Fort St. John	BC	416.51	41.65	35.11	23.98	15.50	10.09	7.87	5.97	2331.54	Edmonton	BASF
844	Rolla	BC	378.87	37.89	31.70	21.63	13.97	9.09	7.09	5.38	2096.34	Edmonton	BASF
845	Altamont	MB	347.36	34.74	28.84	19.66	12.69	8.26	6.44	4.89	1899.38	Edmonton	BASF
846	Altona	MB	357.02	35.70	29.72	20.26	13.09	8.51	6.64	5.04	1959.72	Edmonton	BASF
847	Angusville	MB	349.03	34.90	29.00	19.76	12.76	8.30	6.48	4.92	1909.84	Edmonton	BASF
848	Arborg	MB	351.12	35.11	29.19	19.89	12.85	8.36	6.52	4.95	1922.90	Edmonton	BASF
849	Arnaud	MB	356.35	35.64	29.66	20.22	13.06	8.50	6.63	5.03	1955.59	Edmonton	BASF
850	Austin	MB	328.52	29.04	26.32	18.15	11.80	7.71	6.01	4.54	1797.00	Edmonton	BASF
851	Baldur	MB	359.00	35.90	29.90	20.38	13.17	8.57	6.68	5.07	1972.13	Edmonton	BASF
852	Beausejour	MB	348.43	34.84	28.94	19.72	12.74	8.29	6.46	4.91	1906.05	Edmonton	BASF
853	Benito	MB	357.33	35.73	29.75	20.28	13.10	8.52	6.65	5.05	1961.71	Edmonton	BASF
854	Binscarth	MB	349.03	34.90	29.00	19.76	12.76	8.30	6.48	4.92	1909.84	Edmonton	BASF
855	Birch River	MB	391.28	39.13	32.83	22.40	14.48	9.42	7.35	5.58	2173.90	Edmonton	BASF
856	Birtle	MB	358.84	35.88	29.89	20.37	13.16	8.56	6.68	5.07	1971.14	Edmonton	BASF
857	Boissevain	MB	406.00	40.60	34.16	23.32	15.08	9.81	7.65	5.81	2265.85	Edmonton	BASF
858	Brandon	MB	371.29	37.13	31.01	21.15	13.67	8.89	6.94	5.26	2048.94	Edmonton	BASF
859	Brunkild	MB	338.85	33.88	28.07	19.12	12.35	8.03	6.27	4.76	1846.18	Edmonton	BASF
860	Carberry	MB	328.94	32.89	27.18	18.51	11.95	7.77	6.06	4.60	1784.25	Edmonton	BASF
861	Carman	MB	337.20	33.72	27.92	19.02	12.28	7.99	6.23	4.73	1835.86	Edmonton	BASF
862	Cartwright	MB	404.49	40.45	34.02	23.23	15.01	9.77	7.62	5.78	2256.42	Edmonton	BASF
863	Crystal City	MB	368.93	36.89	30.80	21.00	13.57	8.83	6.89	5.23	2034.20	Edmonton	BASF
864	Cypress River	MB	337.20	33.72	27.92	19.02	12.28	7.99	6.23	4.73	1835.86	Edmonton	BASF
865	Darlingford	MB	352.39	35.24	29.30	19.97	12.90	8.39	6.55	4.97	1930.82	Edmonton	BASF
866	Dauphin	MB	370.54	37.05	30.95	21.11	13.64	8.87	6.92	5.25	2044.23	Edmonton	BASF
867	Deloraine	MB	407.51	40.75	34.30	23.42	15.14	9.85	7.69	5.83	2275.28	Edmonton	BASF
868	Dencross	MB	348.43	34.84	28.94	19.72	12.74	8.29	6.46	4.91	1906.05	Edmonton	BASF
869	Domain	MB	335.22	33.52	27.74	18.90	12.20	7.93	6.19	4.70	1823.47	Edmonton	BASF
870	Dominion City	MB	359.99	36.00	29.99	20.45	13.21	8.59	6.70	5.09	1978.30	Edmonton	BASF
871	Dufrost	MB	352.39	35.24	29.30	19.97	12.90	8.39	6.55	4.97	1930.82	Edmonton	BASF
872	Dugald	MB	331.58	33.16	27.41	18.67	12.05	7.84	6.11	4.64	1800.77	Edmonton	BASF
873	Dunrea	MB	398.83	39.88	33.51	22.87	14.78	9.62	7.51	5.69	2221.06	Edmonton	BASF
874	Elgin	MB	392.42	39.24	32.93	22.47	14.52	9.45	7.37	5.59	2180.97	Edmonton	BASF
875	Elie	MB	322.66	32.27	26.61	18.11	11.69	7.60	5.93	4.50	1745.03	Edmonton	BASF
876	Elkhorn	MB	359.22	35.92	29.92	20.40	13.18	8.57	6.69	5.07	1973.50	Edmonton	BASF
877	Elm Creek	MB	331.25	33.13	27.38	18.65	12.04	7.83	6.11	4.64	1798.70	Edmonton	BASF
878	Emerson	MB	366.59	36.66	30.59	20.86	13.47	8.77	6.84	5.19	2019.59	Edmonton	BASF
879	Fannystelle	MB	329.60	32.96	27.24	18.55	11.97	7.79	6.07	4.61	1788.38	Edmonton	BASF
880	Fisher Branch	MB	357.63	35.76	29.78	20.30	13.11	8.53	6.65	5.05	1963.57	Edmonton	BASF
881	Fork River	MB	391.28	39.13	32.83	22.40	14.48	9.42	7.35	5.58	2173.90	Edmonton	BASF
882	Forrest	MB	369.03	36.90	30.81	21.01	13.57	8.83	6.89	5.23	2034.80	Edmonton	BASF
883	Foxwarren	MB	354.69	35.47	29.51	20.11	12.99	8.45	6.59	5.00	1945.20	Edmonton	BASF
884	Franklin	MB	361.48	36.15	30.12	20.54	13.27	8.63	6.73	5.11	1987.64	Edmonton	BASF
885	Gilbert Plains	MB	363.75	36.37	30.33	20.68	13.36	8.69	6.78	5.15	2001.79	Edmonton	BASF
886	Gimli	MB	359.33	35.93	29.93	20.40	13.18	8.57	6.69	5.08	1974.17	Edmonton	BASF
887	Gladstone	MB	322.33	32.23	26.58	18.09	11.68	7.59	5.92	4.50	1742.96	Edmonton	BASF
888	Glenboro	MB	386.76	38.68	32.42	22.12	14.29	9.30	7.26	5.51	2145.61	Edmonton	BASF
889	Glossop (Newdale)	MB	360.35	36.04	30.02	20.47	13.22	8.60	6.71	5.09	1980.57	Edmonton	BASF
890	Goodlands	MB	412.79	41.28	34.77	23.75	15.35	9.99	7.80	5.91	2308.29	Edmonton	BASF
891	Grandview	MB	356.58	35.66	29.68	20.23	13.07	8.50	6.63	5.03	1956.99	Edmonton	BASF
892	Gretna	MB	359.99	36.00	29.99	20.45	13.21	8.59	6.70	5.09	1978.30	Edmonton	BASF
893	Griswold	MB	373.55	37.36	31.22	21.29	13.76	8.95	6.98	5.30	2063.09	Edmonton	BASF
894	Grosse Isle	MB	332.24	33.22	27.47	18.71	12.08	7.86	6.13	4.65	1804.89	Edmonton	BASF
895	Gunton	MB	341.82	34.18	28.34	19.31	12.47	8.11	6.33	4.80	1864.76	Edmonton	BASF
896	Hamiota	MB	369.40	36.94	30.84	21.03	13.59	8.84	6.90	5.23	2037.15	Edmonton	BASF
897	Hargrave	MB	366.01	36.60	30.53	20.82	13.45	8.75	6.83	5.18	2015.94	Edmonton	BASF
898	Hartney	MB	390.91	39.09	32.79	22.38	14.46	9.41	7.34	5.57	2171.54	Edmonton	BASF
899	High Bluff	MB	328.28	32.83	27.12	18.46	11.92	7.75	6.05	4.59	1780.12	Edmonton	BASF
900	Holland	MB	335.22	33.52	27.74	18.90	12.20	7.93	6.19	4.70	1823.47	Edmonton	BASF
901	Homewood	MB	337.20	33.72	27.92	19.02	12.28	7.99	6.23	4.73	1835.86	Edmonton	BASF
902	Inglis	MB	351.30	35.13	29.20	19.90	12.85	8.36	6.52	4.95	1923.99	Edmonton	BASF
903	Kane	MB	345.45	34.55	28.67	19.54	12.62	8.21	6.40	4.86	1887.47	Edmonton	BASF
904	Kemnay	MB	373.18	37.32	31.18	21.27	13.74	8.94	6.98	5.29	2060.73	Edmonton	BASF
905	Kenton	MB	375.44	37.54	31.39	21.41	13.83	9.00	7.02	5.33	2074.88	Edmonton	BASF
906	Kenville	MB	367.14	36.71	30.64	20.89	13.50	8.78	6.85	5.20	2023.01	Edmonton	BASF
907	Killarney	MB	409.01	40.90	34.43	23.51	15.20	9.89	7.72	5.85	2284.71	Edmonton	BASF
908	Landmark	MB	339.18	33.92	28.10	19.15	12.36	8.04	6.27	4.76	1848.25	Edmonton	BASF
909	Laurier	MB	372.05	37.20	31.08	21.20	13.70	8.91	6.95	5.28	2053.66	Edmonton	BASF
910	Letellier	MB	359.33	35.93	29.93	20.40	13.18	8.57	6.69	5.08	1974.17	Edmonton	BASF
911	Lowe Farm	MB	343.47	34.35	28.49	19.41	12.54	8.15	6.36	4.83	1875.08	Edmonton	BASF
912	Lundar	MB	331.58	33.16	27.41	18.67	12.05	7.84	6.11	4.64	1800.77	Edmonton	BASF
913	MacGregor	MB	325.64	32.56	26.88	18.30	11.81	7.68	5.99	4.55	1763.61	Edmonton	BASF
914	Manitou	MB	351.40	35.14	29.21	19.91	12.86	8.36	6.53	4.95	1924.63	Edmonton	BASF
915	Mariapolis	MB	360.71	36.07	30.05	20.49	13.24	8.61	6.72	5.10	1982.83	Edmonton	BASF
916	Marquette	MB	327.62	32.76	27.06	18.42	11.89	7.73	6.03	4.58	1775.99	Edmonton	BASF
917	Mather	MB	404.49	40.45	34.02	23.23	15.01	9.77	7.62	5.78	2256.42	Edmonton	BASF
918	McCreary	MB	370.54	37.05	30.95	21.11	13.64	8.87	6.92	5.25	2044.23	Edmonton	BASF
919	Meadows	MB	328.28	32.83	27.12	18.46	11.92	7.75	6.05	4.59	1780.12	Edmonton	BASF
920	Medora	MB	402.98	40.30	33.89	23.13	14.95	9.73	7.59	5.76	2246.99	Edmonton	BASF
921	Melita	MB	401.85	40.18	33.78	23.06	14.91	9.70	7.57	5.74	2239.92	Edmonton	BASF
922	Miami	MB	344.79	34.48	28.61	19.50	12.59	8.19	6.39	4.85	1883.34	Edmonton	BASF
923	Miniota	MB	368.65	36.87	30.77	20.99	13.56	8.82	6.88	5.22	2032.44	Edmonton	BASF
924	Minitonas	MB	381.85	38.19	31.97	21.81	14.09	9.17	7.16	5.43	2114.96	Edmonton	BASF
925	Minnedosa	MB	360.73	36.07	30.06	20.49	13.24	8.61	6.72	5.10	1982.93	Edmonton	BASF
926	Minto	MB	397.32	39.73	33.37	22.78	14.72	9.58	7.48	5.67	2211.63	Edmonton	BASF
927	Morden	MB	353.38	35.34	29.39	20.03	12.94	8.42	6.57	4.98	1937.01	Edmonton	BASF
928	Morris	MB	348.76	34.88	28.97	19.74	12.75	8.29	6.47	4.91	1908.11	Edmonton	BASF
929	Neepawa	MB	322.33	32.23	26.58	18.09	11.68	7.59	5.92	4.50	1742.96	Edmonton	BASF
930	Nesbitt	MB	389.40	38.94	32.65	22.28	14.40	9.37	7.31	5.55	2162.11	Edmonton	BASF
931	Newdale	MB	360.73	36.07	30.06	20.49	13.24	8.61	6.72	5.10	1982.93	Edmonton	BASF
932	Ninga	MB	412.03	41.20	34.71	23.70	15.32	9.97	7.78	5.90	2303.58	Edmonton	BASF
933	Niverville	MB	338.19	33.82	28.01	19.08	12.32	8.01	6.25	4.75	1842.05	Edmonton	BASF
934	Notre Dame De Lourdes	MB	340.83	34.08	28.25	19.25	12.43	8.08	6.31	4.79	1858.57	Edmonton	BASF
935	Oak Bluff	MB	327.95	32.79	27.09	18.44	11.91	7.74	6.04	4.59	1778.06	Edmonton	BASF
936	Oak River	MB	370.16	37.02	30.91	21.08	13.62	8.86	6.91	5.25	2041.87	Edmonton	BASF
937	Oakbank	MB	336.21	33.62	27.83	18.96	12.24	7.96	6.21	4.72	1829.67	Edmonton	BASF
938	Oakville	MB	323.66	32.37	26.70	18.17	11.73	7.63	5.95	4.52	1751.22	Edmonton	BASF
939	Petersfield	MB	357.97	35.80	29.81	20.32	13.12	8.54	6.66	5.06	1965.71	Edmonton	BASF
940	Pierson	MB	404.49	40.45	34.02	23.23	15.01	9.77	7.62	5.78	2256.42	Edmonton	BASF
941	Pilot Mound	MB	365.85	36.58	30.52	20.81	13.44	8.75	6.82	5.18	2014.94	Edmonton	BASF
942	Pine Falls	MB	373.53	37.35	31.22	21.29	13.76	8.95	6.98	5.30	2062.94	Edmonton	BASF
943	Plum Coulee	MB	355.03	35.50	29.54	20.14	13.01	8.46	6.60	5.01	1947.33	Edmonton	BASF
944	Plumas	MB	329.27	32.93	27.21	18.53	11.96	7.78	6.07	4.61	1786.31	Edmonton	BASF
945	Portage La Prairie	MB	322.33	32.23	26.58	18.09	11.68	7.59	5.92	4.50	1742.96	Edmonton	BASF
946	Rathwell	MB	335.22	33.52	27.74	18.90	12.20	7.93	6.19	4.70	1823.47	Edmonton	BASF
947	Reston	MB	388.64	38.86	32.59	22.24	14.37	9.35	7.30	5.53	2157.40	Edmonton	BASF
948	River Hills	MB	365.60	36.56	30.50	20.80	13.43	8.74	6.82	5.17	2013.39	Edmonton	BASF
949	Rivers	MB	369.40	36.94	30.84	21.03	13.59	8.84	6.90	5.23	2037.15	Edmonton	BASF
950	Roblin	MB	334.32	33.43	27.66	18.84	12.16	7.91	6.17	4.69	1817.89	Edmonton	BASF
951	Roland	MB	344.79	34.48	28.61	19.50	12.59	8.19	6.39	4.85	1883.34	Edmonton	BASF
952	Rosenort	MB	346.78	34.68	28.79	19.62	12.67	8.24	6.43	4.88	1895.73	Edmonton	BASF
953	Rossburn	MB	358.09	35.81	29.82	20.33	13.13	8.54	6.66	5.06	1966.42	Edmonton	BASF
954	Rosser	MB	329.60	32.96	27.24	18.55	11.97	7.79	6.07	4.61	1788.38	Edmonton	BASF
955	Russell	MB	338.85	33.88	28.07	19.12	12.35	8.03	6.27	4.76	1846.18	Edmonton	BASF
956	Selkirk	MB	338.52	33.85	28.04	19.10	12.33	8.02	6.26	4.75	1844.12	Edmonton	BASF
957	Shoal Lake	MB	361.48	36.15	30.12	20.54	13.27	8.63	6.73	5.11	1987.64	Edmonton	BASF
958	Sifton	MB	381.85	38.19	31.97	21.81	14.09	9.17	7.16	5.43	2114.96	Edmonton	BASF
959	Snowflake	MB	373.73	37.37	31.23	21.30	13.76	8.96	6.99	5.30	2064.17	Edmonton	BASF
960	Somerset	MB	344.79	34.48	28.61	19.50	12.59	8.19	6.39	4.85	1883.34	Edmonton	BASF
961	Souris	MB	381.48	38.15	31.94	21.79	14.08	9.16	7.15	5.42	2112.60	Edmonton	BASF
962	St Claude	MB	331.58	33.16	27.41	18.67	12.05	7.84	6.11	4.64	1800.77	Edmonton	BASF
963	St Jean Baptiste	MB	353.38	35.34	29.39	20.03	12.94	8.42	6.57	4.98	1937.01	Edmonton	BASF
964	St Joseph	MB	361.31	36.13	30.11	20.53	13.26	8.63	6.73	5.11	1986.56	Edmonton	BASF
965	St Leon	MB	345.12	34.51	28.64	19.52	12.60	8.20	6.40	4.85	1885.40	Edmonton	BASF
966	Starbuck	MB	329.60	32.96	27.24	18.55	11.97	7.79	6.07	4.61	1788.38	Edmonton	BASF
967	Ste Agathe	MB	336.87	33.69	27.89	19.00	12.27	7.98	6.22	4.73	1833.79	Edmonton	BASF
968	Ste Anne	MB	343.80	34.38	28.52	19.43	12.55	8.16	6.37	4.83	1877.15	Edmonton	BASF
969	Ste Rose Du Lac	MB	370.54	37.05	30.95	21.11	13.64	8.87	6.92	5.25	2044.23	Edmonton	BASF
970	Steinbach	MB	350.41	35.04	29.12	19.85	12.82	8.34	6.50	4.94	1918.43	Edmonton	BASF
971	Stonewall	MB	333.56	33.36	27.59	18.79	12.13	7.89	6.16	4.67	1813.15	Edmonton	BASF
972	Strathclair	MB	361.48	36.15	30.12	20.54	13.27	8.63	6.73	5.11	1987.64	Edmonton	BASF
973	Swan Lake	MB	354.55	35.45	29.50	20.11	12.99	8.45	6.59	5.00	1944.30	Edmonton	BASF
974	Swan River	MB	374.31	37.43	31.29	21.34	13.79	8.97	7.00	5.31	2067.81	Edmonton	BASF
975	Teulon	MB	356.60	35.66	29.68	20.23	13.07	8.50	6.63	5.03	1957.15	Edmonton	BASF
976	The Pas	MB	448.62	44.86	38.02	25.99	16.81	10.95	8.54	6.47	2532.27	Edmonton	BASF
977	Treherne	MB	335.55	33.55	27.77	18.92	12.21	7.94	6.20	4.71	1825.54	Edmonton	BASF
978	Turtle Mountain	MB	410.15	41.01	34.53	23.58	15.24	9.92	7.74	5.87	2291.79	Edmonton	BASF
979	Virden	MB	372.05	37.20	31.08	21.20	13.70	8.91	6.95	5.28	2053.66	Edmonton	BASF
980	Warren	MB	330.92	33.09	27.36	18.63	12.03	7.82	6.10	4.63	1796.64	Edmonton	BASF
981	Waskada	MB	410.52	41.05	34.57	23.60	15.26	9.93	7.75	5.88	2294.14	Edmonton	BASF
982	Wawanesa	MB	389.02	38.90	32.62	22.26	14.39	9.36	7.30	5.54	2159.76	Edmonton	BASF
983	Wellwood	MB	327.95	32.79	27.09	18.44	11.91	7.74	6.04	4.59	1778.06	Edmonton	BASF
984	Westbourne	MB	322.33	32.23	26.58	18.09	11.68	7.59	5.92	4.50	1742.96	Edmonton	BASF
985	Winkler	MB	352.72	35.27	29.33	19.99	12.91	8.40	6.55	4.97	1932.88	Edmonton	BASF
986	Winnipeg	MB	260.59	26.06	20.98	14.23	9.17	5.95	4.65	3.53	1357.04	Edmonton	BASF
987	Abbey	SK	281.51	28.15	22.88	15.54	10.02	6.51	5.08	3.86	1487.81	Edmonton	BASF
988	Aberdeen	SK	251.71	25.17	20.18	13.68	8.81	5.72	4.46	3.40	1301.55	Edmonton	BASF
989	Abernethy	SK	253.96	25.40	20.38	13.82	8.90	5.78	4.51	3.43	1315.64	Edmonton	BASF
990	Alameda	SK	364.12	36.41	30.36	20.70	13.37	8.70	6.79	5.15	2004.15	Edmonton	BASF
991	Albertville	SK	295.47	29.55	24.14	16.41	10.59	6.88	5.37	4.08	1575.04	Edmonton	BASF
992	Antler	SK	381.10	38.11	31.90	21.77	14.06	9.15	7.14	5.42	2110.24	Edmonton	BASF
993	Arborfield	SK	321.50	32.15	26.50	18.04	11.64	7.57	5.91	4.49	1737.73	Edmonton	BASF
994	Archerwill	SK	290.94	29.09	23.73	16.13	10.40	6.76	5.27	4.01	1546.75	Edmonton	BASF
995	Assiniboia	SK	272.01	27.20	22.02	14.95	9.63	6.26	4.88	3.71	1428.47	Edmonton	BASF
996	Avonlea	SK	239.03	23.78	18.91	12.81	8.24	5.35	4.17	3.18	1214.49	Edmonton	BASF
997	Aylsham	SK	321.87	32.19	26.54	18.06	11.66	7.58	5.91	4.49	1740.08	Edmonton	BASF
998	Balcarres	SK	248.68	24.87	19.90	13.49	8.68	5.64	4.40	3.35	1282.61	Edmonton	BASF
999	Balgonie	SK	239.03	22.46	17.72	11.98	7.71	5.00	3.90	2.97	1131.92	Edmonton	BASF
1000	Bankend	SK	241.74	24.17	19.27	13.06	8.40	5.45	4.26	3.24	1239.26	Edmonton	BASF
1001	Battleford	SK	239.03	23.40	18.57	12.57	8.09	5.25	4.09	3.12	1190.74	Edmonton	BASF
1002	Beechy	SK	273.21	27.32	22.12	15.02	9.68	6.29	4.91	3.73	1435.94	Edmonton	BASF
1003	Bengough	SK	268.17	26.82	21.67	14.71	9.48	6.15	4.80	3.65	1404.41	Edmonton	BASF
1004	Biggar	SK	247.94	24.79	19.83	13.44	8.65	5.62	4.38	3.34	1277.97	Edmonton	BASF
1005	Birch Hills	SK	277.36	27.74	22.50	15.28	9.85	6.40	4.99	3.80	1461.87	Edmonton	BASF
1006	Bjorkdale	SK	310.93	31.09	25.54	17.38	11.21	7.29	5.69	4.32	1671.71	Edmonton	BASF
1007	Blaine Lake	SK	247.56	24.76	19.80	13.42	8.64	5.61	4.38	3.33	1275.62	Edmonton	BASF
1008	Bracken	SK	349.79	34.98	29.06	19.81	12.79	8.32	6.49	4.93	1914.55	Edmonton	BASF
1009	Bredenbury	SK	311.69	31.17	25.61	17.43	11.24	7.31	5.70	4.33	1676.43	Edmonton	BASF
1010	Briercrest	SK	239.03	23.45	18.61	12.60	8.11	5.26	4.11	3.13	1193.85	Edmonton	BASF
1011	Broadview	SK	275.76	27.58	22.36	15.18	9.78	6.36	4.96	3.77	1451.89	Edmonton	BASF
1012	Broderick	SK	248.31	24.83	19.87	13.47	8.67	5.63	4.39	3.34	1280.33	Edmonton	BASF
1013	Brooksby	SK	302.26	30.23	24.76	16.84	10.86	7.06	5.51	4.18	1617.48	Edmonton	BASF
1014	Bruno	SK	255.10	25.51	20.48	13.89	8.95	5.81	4.53	3.45	1322.77	Edmonton	BASF
1015	Buchanan	SK	305.28	30.53	25.03	17.03	10.98	7.14	5.57	4.23	1636.35	Edmonton	BASF
1016	Cabri	SK	281.13	28.11	22.84	15.52	10.00	6.50	5.07	3.85	1485.45	Edmonton	BASF
1017	Canora	SK	315.08	31.51	25.92	17.64	11.38	7.40	5.77	4.39	1697.65	Edmonton	BASF
1018	Canwood	SK	287.17	28.72	23.39	15.89	10.25	6.66	5.20	3.95	1523.18	Edmonton	BASF
1019	Carievale	SK	393.92	39.39	33.06	22.57	14.59	9.49	7.41	5.62	2190.41	Edmonton	BASF
1020	Carlyle	SK	307.80	30.78	25.26	17.18	11.09	7.21	5.62	4.27	1652.13	Edmonton	BASF
1021	Carnduff	SK	382.99	38.30	32.07	21.88	14.14	9.20	7.18	5.45	2122.03	Edmonton	BASF
1022	Carrot River	SK	332.81	33.28	27.53	18.75	12.10	7.87	6.14	4.66	1808.46	Edmonton	BASF
1023	Central Butte	SK	239.03	23.81	18.94	12.83	8.26	5.36	4.18	3.18	1216.56	Edmonton	BASF
1024	Ceylon	SK	259.91	25.99	20.92	14.19	9.14	5.93	4.63	3.52	1352.80	Edmonton	BASF
1025	Choiceland	SK	299.99	30.00	24.55	16.70	10.77	7.00	5.46	4.15	1603.34	Edmonton	BASF
1026	Churchbridge	SK	316.97	31.70	26.09	17.76	11.46	7.45	5.81	4.41	1709.43	Edmonton	BASF
1027	Clavet	SK	246.43	24.64	19.70	13.35	8.59	5.58	4.35	3.31	1268.54	Edmonton	BASF
1028	Codette	SK	319.61	31.96	26.33	17.92	11.57	7.52	5.87	4.46	1725.94	Edmonton	BASF
1029	Colgate	SK	280.92	28.09	22.82	15.50	9.99	6.49	5.07	3.85	1484.12	Edmonton	BASF
1030	Colonsay	SK	246.43	24.64	19.70	13.35	8.59	5.58	4.35	3.31	1268.54	Edmonton	BASF
1031	Congress	SK	266.19	26.62	21.49	14.58	9.40	6.10	4.76	3.62	1392.08	Edmonton	BASF
1032	Consul	SK	338.09	33.81	28.01	19.08	12.32	8.01	6.25	4.74	1841.47	Edmonton	BASF
1033	Corman Park	SK	239.03	23.70	18.84	12.76	8.21	5.33	4.16	3.17	1209.60	Edmonton	BASF
1034	Corning	SK	285.01	28.50	23.19	15.76	10.16	6.60	5.15	3.92	1509.69	Edmonton	BASF
1035	Coronach	SK	316.59	31.66	26.06	17.73	11.44	7.44	5.80	4.41	1707.08	Edmonton	BASF
1036	Craik	SK	239.03	21.43	16.79	11.34	7.29	4.72	3.69	2.81	1067.92	Edmonton	BASF
1037	Creelman	SK	260.90	26.09	21.01	14.25	9.18	5.96	4.65	3.54	1358.99	Edmonton	BASF
1038	Crooked River	SK	305.65	30.57	25.06	17.05	11.00	7.15	5.58	4.24	1638.70	Edmonton	BASF
1039	Cudworth	SK	264.91	26.49	21.37	14.50	9.34	6.07	4.74	3.60	1384.07	Edmonton	BASF
1040	Cupar	SK	239.03	23.38	18.55	12.56	8.08	5.24	4.09	3.12	1189.72	Edmonton	BASF
1041	Cut knife	SK	239.03	22.12	17.41	11.77	7.57	4.90	3.83	2.92	1110.58	Edmonton	BASF
1042	Davidson	SK	239.03	21.40	16.76	11.32	7.28	4.71	3.68	2.81	1065.86	Edmonton	BASF
1043	Debden	SK	298.86	29.89	24.45	16.63	10.72	6.97	5.44	4.13	1596.26	Edmonton	BASF
1044	Delisle	SK	255.10	25.51	20.48	13.89	8.95	5.81	4.53	3.45	1322.77	Edmonton	BASF
1045	Delmas	SK	239.03	21.89	17.20	11.63	7.47	4.84	3.78	2.88	1096.43	Edmonton	BASF
1046	Denzil	SK	239.03	23.40	18.57	12.57	8.09	5.25	4.09	3.12	1190.74	Edmonton	BASF
1047	Dinsmore	SK	253.97	25.40	20.38	13.82	8.90	5.78	4.51	3.43	1315.70	Edmonton	BASF
1048	Domremy	SK	276.98	27.70	22.47	15.26	9.83	6.39	4.98	3.79	1459.52	Edmonton	BASF
1049	Drake	SK	239.03	22.23	17.51	11.84	7.61	4.93	3.85	2.93	1117.47	Edmonton	BASF
1050	Duperow	SK	248.69	24.87	19.90	13.49	8.69	5.64	4.40	3.35	1282.69	Edmonton	BASF
1051	Eastend	SK	329.04	32.90	27.18	18.51	11.95	7.77	6.06	4.60	1784.88	Edmonton	BASF
1052	Eatonia	SK	277.74	27.77	22.54	15.31	9.87	6.41	5.00	3.80	1464.23	Edmonton	BASF
1053	Ebenezer	SK	306.41	30.64	25.13	17.10	11.03	7.17	5.59	4.25	1643.42	Edmonton	BASF
1054	Edam	SK	239.03	23.47	18.64	12.62	8.12	5.27	4.11	3.13	1195.45	Edmonton	BASF
1055	Edenwold	SK	239.03	23.18	18.38	12.44	8.00	5.19	4.05	3.08	1177.33	Edmonton	BASF
1056	Elfros	SK	241.08	24.11	19.21	13.01	8.38	5.43	4.24	3.23	1235.13	Edmonton	BASF
1057	Elrose	SK	270.19	27.02	21.85	14.83	9.56	6.21	4.84	3.68	1417.08	Edmonton	BASF
1058	Estevan	SK	303.52	30.35	24.87	16.92	10.91	7.09	5.53	4.20	1625.38	Edmonton	BASF
1059	Eston	SK	275.47	27.55	22.33	15.16	9.77	6.35	4.95	3.77	1450.09	Edmonton	BASF
1060	Eyebrow	SK	239.03	23.37	18.54	12.55	8.07	5.24	4.09	3.11	1188.74	Edmonton	BASF
1061	Fairlight	SK	355.82	35.58	29.61	20.19	13.04	8.48	6.62	5.02	1952.28	Edmonton	BASF
1062	Fielding	SK	239.03	23.70	18.84	12.76	8.21	5.33	4.16	3.17	1209.60	Edmonton	BASF
1063	Fillmore	SK	254.95	25.50	20.47	13.88	8.94	5.80	4.53	3.45	1321.84	Edmonton	BASF
1064	Foam Lake	SK	248.68	24.87	19.90	13.49	8.68	5.64	4.40	3.35	1282.61	Edmonton	BASF
1065	Fox Valley	SK	285.66	28.57	23.25	15.80	10.19	6.62	5.16	3.93	1513.74	Edmonton	BASF
1066	Francis	SK	239.43	23.94	19.06	12.91	8.31	5.39	4.21	3.20	1224.81	Edmonton	BASF
1067	Frontier	SK	344.88	34.49	28.62	19.50	12.59	8.19	6.39	4.85	1883.90	Edmonton	BASF
1068	Gerald	SK	335.08	33.51	27.73	18.89	12.19	7.93	6.19	4.70	1822.60	Edmonton	BASF
1069	Glaslyn	SK	243.79	24.38	19.46	13.18	8.49	5.51	4.30	3.27	1252.04	Edmonton	BASF
1070	Glenavon	SK	260.90	26.09	21.01	14.25	9.18	5.96	4.65	3.54	1358.99	Edmonton	BASF
1071	Goodeve	SK	266.53	26.65	21.52	14.60	9.41	6.11	4.77	3.63	1394.22	Edmonton	BASF
1072	Govan	SK	239.03	22.23	17.51	11.84	7.61	4.93	3.85	2.93	1117.47	Edmonton	BASF
1073	Grand Coulee	SK	239.03	22.16	17.45	11.80	7.58	4.92	3.84	2.92	1113.34	Edmonton	BASF
1074	Gravelbourg	SK	276.47	27.65	22.42	15.23	9.81	6.37	4.97	3.78	1456.29	Edmonton	BASF
1075	Gray	SK	239.03	22.92	18.14	12.27	7.89	5.12	4.00	3.04	1160.82	Edmonton	BASF
1076	Grenfell	SK	265.52	26.55	21.43	14.54	9.37	6.08	4.75	3.61	1387.90	Edmonton	BASF
1077	Griffin	SK	272.13	27.21	22.03	14.95	9.64	6.26	4.88	3.71	1429.18	Edmonton	BASF
1078	Gronlid	SK	294.71	29.47	24.07	16.37	10.55	6.86	5.35	4.07	1570.33	Edmonton	BASF
1079	Gull Lake	SK	296.98	29.70	24.28	16.51	10.65	6.92	5.40	4.10	1584.48	Edmonton	BASF
1080	Hafford	SK	243.79	24.38	19.46	13.18	8.49	5.51	4.30	3.27	1252.04	Edmonton	BASF
1081	Hague	SK	252.46	25.25	20.24	13.73	8.84	5.74	4.48	3.41	1306.27	Edmonton	BASF
1082	Hamlin	SK	240.01	24.00	19.12	12.95	8.33	5.41	4.22	3.21	1228.46	Edmonton	BASF
1083	Hanley	SK	239.03	21.43	16.79	11.34	7.29	4.72	3.69	2.81	1067.92	Edmonton	BASF
1084	Hazenmore	SK	324.51	32.45	26.77	18.23	11.77	7.65	5.97	4.53	1756.59	Edmonton	BASF
1085	Hazlet	SK	308.29	30.83	25.30	17.21	11.11	7.22	5.63	4.28	1655.21	Edmonton	BASF
1086	Herbert	SK	243.39	24.34	19.42	13.16	8.47	5.50	4.29	3.27	1249.58	Edmonton	BASF
1087	Hodgeville	SK	290.94	29.09	23.73	16.13	10.40	6.76	5.27	4.01	1546.75	Edmonton	BASF
1088	Hoey	SK	280.38	28.04	22.77	15.47	9.97	6.48	5.06	3.84	1480.74	Edmonton	BASF
1089	Hudson Bay	SK	343.00	34.30	28.45	19.38	12.52	8.14	6.35	4.82	1872.12	Edmonton	BASF
1090	Humboldt	SK	253.97	25.40	20.38	13.82	8.90	5.78	4.51	3.43	1315.70	Edmonton	BASF
1091	Imperial	SK	239.03	22.09	17.39	11.75	7.56	4.90	3.82	2.91	1109.21	Edmonton	BASF
1092	Indian Head	SK	242.73	24.27	19.36	13.12	8.44	5.48	4.28	3.25	1245.45	Edmonton	BASF
1093	Invermay	SK	299.24	29.92	24.48	16.65	10.74	6.98	5.45	4.14	1598.62	Edmonton	BASF
1094	Ituna	SK	248.02	24.80	19.84	13.45	8.66	5.62	4.39	3.34	1278.48	Edmonton	BASF
1095	Kamsack	SK	330.55	33.05	27.32	18.61	12.01	7.81	6.09	4.63	1794.31	Edmonton	BASF
1096	Kelso	SK	360.73	36.07	30.06	20.49	13.24	8.61	6.72	5.10	1982.93	Edmonton	BASF
1097	Kelvington	SK	300.37	30.04	24.59	16.72	10.78	7.01	5.47	4.16	1605.69	Edmonton	BASF
1098	Kerrobert	SK	256.61	25.66	20.62	13.98	9.01	5.85	4.56	3.47	1332.20	Edmonton	BASF
1099	Kindersley	SK	259.63	25.96	20.89	14.17	9.13	5.93	4.63	3.52	1351.06	Edmonton	BASF
1100	Kinistino	SK	280.76	28.08	22.81	15.49	9.99	6.49	5.06	3.85	1483.09	Edmonton	BASF
1101	Kipling	SK	286.00	28.60	23.28	15.82	10.20	6.63	5.17	3.93	1515.88	Edmonton	BASF
1102	Kisbey	SK	282.37	28.24	22.95	15.59	10.05	6.53	5.10	3.87	1493.18	Edmonton	BASF
1103	Kronau	SK	239.03	22.39	17.66	11.94	7.68	4.98	3.89	2.96	1127.79	Edmonton	BASF
1104	Krydor	SK	248.69	24.87	19.90	13.49	8.69	5.64	4.40	3.35	1282.69	Edmonton	BASF
1105	Kyle	SK	270.57	27.06	21.89	14.86	9.57	6.22	4.85	3.69	1419.44	Edmonton	BASF
1106	Lafleche	SK	318.10	31.81	26.19	17.83	11.50	7.48	5.84	4.43	1716.51	Edmonton	BASF
1107	Lajord	SK	239.03	22.85	18.08	12.23	7.87	5.10	3.98	3.03	1156.69	Edmonton	BASF
1108	Lake Alma	SK	286.00	28.60	23.28	15.82	10.20	6.63	5.17	3.93	1515.88	Edmonton	BASF
1109	Lake Lenore	SK	267.55	26.76	21.61	14.67	9.45	6.14	4.79	3.64	1400.57	Edmonton	BASF
1110	Lampman	SK	302.15	30.22	24.75	16.83	10.86	7.06	5.51	4.18	1616.82	Edmonton	BASF
1111	Landis	SK	253.59	25.36	20.35	13.80	8.88	5.77	4.50	3.42	1313.34	Edmonton	BASF
1112	Langbank	SK	336.21	33.62	27.83	18.96	12.24	7.96	6.21	4.72	1829.68	Edmonton	BASF
1113	Langenburg	SK	324.14	32.41	26.74	18.21	11.75	7.64	5.96	4.53	1754.23	Edmonton	BASF
1114	Langham	SK	239.03	23.70	18.84	12.76	8.21	5.33	4.16	3.17	1209.60	Edmonton	BASF
1115	Lanigan	SK	239.03	22.23	17.51	11.84	7.61	4.93	3.85	2.93	1117.47	Edmonton	BASF
1116	Lashburn	SK	239.03	18.34	13.99	9.41	6.03	3.90	3.05	2.33	874.81	Edmonton	BASF
1117	Leader	SK	281.13	28.11	22.84	15.52	10.00	6.50	5.07	3.85	1485.45	Edmonton	BASF
1118	Leask	SK	259.63	25.96	20.89	14.17	9.13	5.93	4.63	3.52	1351.06	Edmonton	BASF
1119	Lemberg	SK	261.23	26.12	21.04	14.27	9.19	5.97	4.66	3.54	1361.06	Edmonton	BASF
1120	Leoville	SK	277.74	27.77	22.54	15.31	9.87	6.41	5.00	3.80	1464.23	Edmonton	BASF
1121	Leross	SK	242.73	24.27	19.36	13.12	8.44	5.48	4.28	3.25	1245.45	Edmonton	BASF
1122	Leroy	SK	239.03	23.71	18.85	12.77	8.22	5.33	4.16	3.17	1210.36	Edmonton	BASF
1123	Lestock	SK	240.42	24.04	19.15	12.97	8.35	5.42	4.23	3.22	1231.00	Edmonton	BASF
1124	Lewvan	SK	240.75	24.08	19.18	12.99	8.36	5.43	4.24	3.22	1233.07	Edmonton	BASF
1125	Liberty	SK	239.03	22.13	17.42	11.78	7.57	4.91	3.83	2.92	1111.27	Edmonton	BASF
1126	Limerick	SK	278.52	27.85	22.61	15.35	9.90	6.43	5.02	3.81	1469.13	Edmonton	BASF
1127	Lintlaw	SK	310.18	31.02	25.48	17.33	11.18	7.27	5.67	4.31	1667.00	Edmonton	BASF
1128	Lipton	SK	241.41	24.14	19.24	13.03	8.39	5.44	4.25	3.23	1237.20	Edmonton	BASF
1129	Lloydminsters	SK	239.03	16.91	12.69	8.51	5.45	3.52	2.75	2.10	785.21	Edmonton	BASF
1130	Loreburn	SK	239.03	22.46	17.72	11.98	7.71	5.00	3.90	2.97	1131.92	Edmonton	BASF
1131	Lucky Lake	SK	272.83	27.28	22.09	15.00	9.67	6.28	4.90	3.73	1433.58	Edmonton	BASF
1132	Lumsden	SK	239.03	21.40	16.76	11.32	7.28	4.71	3.68	2.81	1065.86	Edmonton	BASF
1133	Luseland	SK	248.31	24.83	19.87	13.47	8.67	5.63	4.39	3.34	1280.33	Edmonton	BASF
1134	Macklin	SK	239.03	22.19	17.48	11.82	7.60	4.92	3.85	2.93	1115.29	Edmonton	BASF
1135	Macoun	SK	291.88	29.19	23.82	16.19	10.44	6.78	5.29	4.02	1552.61	Edmonton	BASF
1136	Maidstone	SK	239.03	19.40	14.95	10.07	6.46	4.18	3.27	2.49	940.82	Edmonton	BASF
1137	Major	SK	256.61	25.66	20.62	13.98	9.01	5.85	4.56	3.47	1332.20	Edmonton	BASF
1138	Mankota	SK	339.23	33.92	28.11	19.15	12.36	8.04	6.27	4.76	1848.54	Edmonton	BASF
1139	Maple Creek	SK	301.88	30.19	24.72	16.81	10.85	7.05	5.50	4.18	1615.13	Edmonton	BASF
1140	Marengo	SK	255.10	25.51	20.48	13.89	8.95	5.81	4.53	3.45	1322.77	Edmonton	BASF
1141	Marsden	SK	239.03	19.85	15.36	10.35	6.65	4.30	3.36	2.56	969.11	Edmonton	BASF
1142	Marshall	SK	239.03	17.74	13.44	9.03	5.79	3.74	2.92	2.23	837.08	Edmonton	BASF
1143	Maryfield	SK	361.48	36.15	30.12	20.54	13.27	8.63	6.73	5.11	1987.64	Edmonton	BASF
1144	Maymont	SK	239.03	23.70	18.84	12.76	8.21	5.33	4.16	3.17	1209.60	Edmonton	BASF
1145	McLean	SK	239.03	23.08	18.29	12.37	7.96	5.16	4.03	3.07	1171.14	Edmonton	BASF
1146	Meadow Lake	SK	255.86	25.59	20.55	13.94	8.98	5.83	4.55	3.46	1327.49	Edmonton	BASF
1147	Meath Park	SK	298.11	29.81	24.38	16.58	10.69	6.95	5.42	4.12	1591.55	Edmonton	BASF
1148	Medstead	SK	255.86	25.59	20.55	13.94	8.98	5.83	4.55	3.46	1327.49	Edmonton	BASF
1149	Melfort	SK	283.40	28.34	23.05	15.66	10.10	6.56	5.12	3.89	1499.60	Edmonton	BASF
1150	Melville	SK	263.87	26.39	21.28	14.44	9.30	6.04	4.71	3.59	1377.57	Edmonton	BASF
1151	Meota	SK	250.58	25.06	20.07	13.61	8.76	5.69	4.44	3.38	1294.48	Edmonton	BASF
1152	Mervin	SK	239.03	22.64	17.89	12.10	7.78	5.04	3.94	3.00	1143.58	Edmonton	BASF
1153	Midale	SK	277.41	27.74	22.51	15.28	9.85	6.40	4.99	3.80	1462.21	Edmonton	BASF
1154	Middle Lake	SK	271.32	27.13	21.95	14.90	9.60	6.24	4.87	3.70	1424.15	Edmonton	BASF
1155	Milden	SK	251.33	25.13	20.14	13.65	8.79	5.71	4.45	3.39	1299.19	Edmonton	BASF
1156	Milestone	SK	239.03	23.71	18.85	12.77	8.22	5.33	4.16	3.17	1210.36	Edmonton	BASF
1157	Montmartre	SK	251.32	25.13	20.14	13.65	8.79	5.71	4.45	3.39	1299.13	Edmonton	BASF
1158	Moose Jaw	SK	239.03	22.19	17.48	11.82	7.60	4.93	3.85	2.93	1115.40	Edmonton	BASF
1159	Moosomin	SK	341.11	34.11	28.28	19.27	12.44	8.09	6.31	4.79	1860.33	Edmonton	BASF
1160	Morse	SK	243.72	24.37	19.45	13.18	8.48	5.50	4.30	3.27	1251.65	Edmonton	BASF
1161	Mossbank	SK	250.00	25.00	20.02	13.57	8.74	5.67	4.43	3.37	1290.87	Edmonton	BASF
1162	Naicam	SK	272.46	27.25	22.06	14.98	9.65	6.27	4.89	3.72	1431.22	Edmonton	BASF
1163	Neilburg	SK	239.03	20.46	15.90	10.73	6.89	4.46	3.49	2.66	1006.84	Edmonton	BASF
1164	Neville	SK	315.46	31.55	25.95	17.66	11.40	7.41	5.78	4.39	1700.00	Edmonton	BASF
1165	Nipawin	SK	310.56	31.06	25.51	17.36	11.20	7.28	5.68	4.31	1669.35	Edmonton	BASF
1166	Nokomis	SK	239.03	22.85	18.07	12.23	7.87	5.10	3.98	3.03	1156.63	Edmonton	BASF
1167	Norquay	SK	338.47	33.85	28.04	19.10	12.33	8.02	6.26	4.75	1843.82	Edmonton	BASF
1168	North Battleford	SK	239.03	23.47	18.64	12.62	8.12	5.27	4.11	3.13	1195.45	Edmonton	BASF
1169	Odessa	SK	240.75	24.08	19.18	12.99	8.36	5.43	4.24	3.22	1233.07	Edmonton	BASF
1170	Ogema	SK	262.22	26.22	21.13	14.34	9.23	6.00	4.68	3.56	1367.25	Edmonton	BASF
1171	Osler	SK	244.92	24.49	19.56	13.25	8.53	5.54	4.32	3.29	1259.11	Edmonton	BASF
1172	Oungre	SK	283.69	28.37	23.07	15.68	10.11	6.57	5.12	3.89	1501.43	Edmonton	BASF
1173	Outlook	SK	253.59	25.36	20.35	13.80	8.88	5.77	4.50	3.42	1313.34	Edmonton	BASF
1174	Oxbow	SK	370.16	37.02	30.91	21.08	13.62	8.86	6.91	5.25	2041.87	Edmonton	BASF
1175	Pangman	SK	253.63	25.36	20.35	13.80	8.89	5.77	4.50	3.43	1313.58	Edmonton	BASF
1176	Paradise Hill	SK	239.03	19.93	15.42	10.40	6.68	4.32	3.38	2.58	973.83	Edmonton	BASF
1177	Parkside	SK	269.82	26.98	21.82	14.81	9.54	6.20	4.84	3.68	1414.72	Edmonton	BASF
1178	Pasqua	SK	239.03	22.12	17.42	11.78	7.57	4.91	3.84	2.92	1111.27	Edmonton	BASF
1179	Paynton	SK	239.03	20.76	16.18	10.92	7.01	4.54	3.55	2.71	1025.70	Edmonton	BASF
1180	Peesane	SK	287.17	28.72	23.39	15.89	10.25	6.66	5.20	3.95	1523.18	Edmonton	BASF
1181	Pelly	SK	344.51	34.45	28.59	19.48	12.58	8.18	6.38	4.85	1881.55	Edmonton	BASF
1182	Pense	SK	239.03	22.23	17.51	11.84	7.61	4.93	3.85	2.93	1117.47	Edmonton	BASF
1183	Perdue	SK	246.80	24.68	19.73	13.37	8.61	5.59	4.36	3.32	1270.90	Edmonton	BASF
1184	Pilot Butte	SK	239.03	18.05	16.35	11.28	7.33	4.79	3.74	2.82	1116.66	Edmonton	BASF
1185	Plenty	SK	256.61	25.66	20.62	13.98	9.01	5.85	4.56	3.47	1332.20	Edmonton	BASF
1186	Ponteix	SK	324.51	32.45	26.77	18.23	11.77	7.65	5.97	4.53	1756.59	Edmonton	BASF
1187	Porcupine Plain	SK	315.08	31.51	25.92	17.64	11.38	7.40	5.77	4.39	1697.65	Edmonton	BASF
1188	Prairie River	SK	331.68	33.17	27.42	18.68	12.06	7.84	6.12	4.64	1801.38	Edmonton	BASF
1189	Prince Albert	SK	279.25	27.92	22.67	15.40	9.93	6.45	5.03	3.83	1473.66	Edmonton	BASF
1190	Quill Lake	Sk	266.42	26.64	21.51	14.60	9.41	6.11	4.77	3.62	1393.50	Edmonton	BASF
1191	Rabbit Lake	SK	270.19	27.02	21.85	14.83	9.56	6.21	4.84	3.68	1417.08	Edmonton	BASF
1192	Radisson	SK	239.03	23.70	18.84	12.76	8.21	5.33	4.16	3.17	1209.60	Edmonton	BASF
1193	Radville	SK	269.49	26.95	21.79	14.79	9.53	6.19	4.83	3.67	1412.67	Edmonton	BASF
1194	Rama	SK	304.90	30.49	25.00	17.00	10.97	7.13	5.56	4.23	1633.99	Edmonton	BASF
1195	Raymore	SK	239.03	22.49	17.75	12.00	7.72	5.00	3.91	2.98	1133.98	Edmonton	BASF
1196	Redvers	SK	372.05	37.20	31.08	21.20	13.70	8.91	6.95	5.28	2053.66	Edmonton	BASF
1197	Regina	SK	239.03	18.76	14.36	9.67	6.20	4.01	3.13	2.39	849.72	Edmonton	BASF
1198	Rhein	SK	313.95	31.40	25.82	17.57	11.34	7.37	5.75	4.37	1690.57	Edmonton	BASF
1199	Riceton	SK	239.03	23.45	18.61	12.60	8.11	5.26	4.11	3.13	1193.85	Edmonton	BASF
1200	Richardson	SK	239.03	21.80	17.12	11.57	7.44	4.82	3.76	2.87	1090.63	Edmonton	BASF
1201	Ridgedale	SK	310.93	31.09	25.54	17.38	11.21	7.29	5.69	4.32	1671.71	Edmonton	BASF
1202	Rocanville	SK	340.74	34.07	28.24	19.24	12.42	8.08	6.30	4.79	1857.97	Edmonton	BASF
1203	Rockhaven	SK	239.03	23.02	18.23	12.33	7.93	5.15	4.02	3.06	1167.16	Edmonton	BASF
1204	Rose Valley	SK	297.73	29.77	24.35	16.55	10.68	6.94	5.41	4.11	1589.19	Edmonton	BASF
1205	Rosetown	SK	250.20	25.02	20.04	13.58	8.75	5.68	4.43	3.37	1292.12	Edmonton	BASF
1206	Rosthern	SK	261.14	26.11	21.03	14.27	9.19	5.97	4.66	3.54	1360.49	Edmonton	BASF
1207	Rouleau	SK	239.03	23.15	18.35	12.42	7.99	5.18	4.04	3.08	1175.27	Edmonton	BASF
1208	Rowatt	SK	239.03	21.90	17.21	11.63	7.48	4.85	3.78	2.88	1096.82	Edmonton	BASF
1209	Saskatoon	SK	239.03	15.63	11.53	7.71	4.93	3.18	2.49	1.90	665.22	Edmonton	BASF
1210	Sceptre	Sk	281.13	28.11	22.84	15.52	10.00	6.50	5.07	3.85	1485.45	Edmonton	BASF
1211	Sedley	SK	239.03	23.38	18.55	12.56	8.08	5.24	4.09	3.12	1189.72	Edmonton	BASF
1212	Shamrock	SK	259.25	25.92	20.86	14.15	9.11	5.92	4.62	3.51	1348.67	Edmonton	BASF
1213	Shaunavon	SK	321.50	32.15	26.50	18.04	11.64	7.57	5.91	4.49	1737.73	Edmonton	BASF
1214	Shellbrook	SK	276.23	27.62	22.40	15.21	9.80	6.37	4.97	3.78	1454.80	Edmonton	BASF
1215	Simpson	SK	239.03	22.09	17.39	11.75	7.56	4.90	3.82	2.91	1109.21	Edmonton	BASF
1216	Sintaluta	SK	250.00	25.00	20.02	13.57	8.74	5.67	4.43	3.37	1290.87	Edmonton	BASF
1217	Southey	SK	239.03	22.52	17.78	12.02	7.73	5.01	3.91	2.98	1136.04	Edmonton	BASF
1218	Spalding	SK	267.93	26.79	21.65	14.69	9.47	6.15	4.80	3.65	1402.93	Edmonton	BASF
1219	Speers	SK	245.30	24.53	19.60	13.28	8.55	5.55	4.33	3.29	1261.47	Edmonton	BASF
1220	Spiritwood	SK	263.03	26.30	21.20	14.39	9.27	6.02	4.70	3.57	1372.28	Edmonton	BASF
1221	St Brieux	SK	279.62	27.96	22.71	15.42	9.94	6.46	5.04	3.83	1476.02	Edmonton	BASF
1222	St. Walburg	SK	239.03	20.98	16.38	11.06	7.11	4.60	3.60	2.74	1039.85	Edmonton	BASF
1223	Star City	SK	290.94	29.09	23.73	16.13	10.40	6.76	5.27	4.01	1546.75	Edmonton	BASF
1224	Stewart Valley	SK	270.57	27.06	21.89	14.86	9.57	6.22	4.85	3.69	1419.44	Edmonton	BASF
1225	Stockholm	SK	321.12	32.11	26.47	18.02	11.63	7.56	5.90	4.48	1735.37	Edmonton	BASF
1226	Stoughton	SK	270.81	27.08	21.91	14.87	9.58	6.22	4.86	3.69	1420.92	Edmonton	BASF
1227	Strasbourg	SK	239.03	22.29	17.57	11.88	7.64	4.95	3.87	2.95	1121.59	Edmonton	BASF
1228	Strongfield	SK	248.69	24.87	19.90	13.49	8.69	5.64	4.40	3.35	1282.69	Edmonton	BASF
1229	Sturgis	SK	324.14	32.41	26.74	18.21	11.75	7.64	5.96	4.53	1754.23	Edmonton	BASF
1230	Swift Current	SK	297.73	29.77	24.35	16.55	10.68	6.94	5.41	4.11	1589.19	Edmonton	BASF
1231	Theodore	SK	293.20	29.32	23.94	16.27	10.49	6.82	5.32	4.04	1560.90	Edmonton	BASF
1232	Tisdale	SK	296.60	29.66	24.24	16.48	10.63	6.91	5.39	4.10	1582.12	Edmonton	BASF
1233	Tompkins	SK	297.35	29.74	24.31	16.53	10.66	6.93	5.41	4.11	1586.83	Edmonton	BASF
1234	Torquay	SK	296.67	29.67	24.25	16.49	10.63	6.91	5.39	4.10	1582.57	Edmonton	BASF
1235	Tribune	SK	287.08	28.71	23.38	15.89	10.24	6.66	5.19	3.95	1522.64	Edmonton	BASF
1236	Tugaske	SK	239.03	23.33	18.51	12.53	8.06	5.23	4.08	3.11	1186.60	Edmonton	BASF
1237	Turtleford	SK	239.03	22.19	17.48	11.82	7.60	4.92	3.85	2.93	1115.29	Edmonton	BASF
1238	Tuxford	SK	239.03	22.13	17.42	11.78	7.57	4.91	3.83	2.92	1111.27	Edmonton	BASF
1239	Unity	SK	239.03	23.40	18.57	12.57	8.09	5.25	4.09	3.12	1190.74	Edmonton	BASF
1240	Valparaiso	SK	294.71	29.47	24.07	16.37	10.55	6.86	5.35	4.07	1570.33	Edmonton	BASF
1241	Vanscoy	SK	250.58	25.06	20.07	13.61	8.76	5.69	4.44	3.38	1294.48	Edmonton	BASF
1242	Vibank	SK	239.03	23.55	18.70	12.66	8.15	5.28	4.13	3.14	1200.04	Edmonton	BASF
1243	Viscount	SK	246.43	24.64	19.70	13.35	8.59	5.58	4.35	3.31	1268.54	Edmonton	BASF
1244	Wadena	SK	280.00	28.00	22.74	15.45	9.96	6.47	5.05	3.84	1478.38	Edmonton	BASF
1245	Wakaw	SK	269.06	26.91	21.75	14.76	9.51	6.18	4.82	3.67	1410.01	Edmonton	BASF
1246	Waldheim	SK	256.61	25.66	20.62	13.98	9.01	5.85	4.56	3.47	1332.20	Edmonton	BASF
1247	Waldron	SK	280.58	28.06	22.79	15.48	9.98	6.48	5.06	3.85	1481.98	Edmonton	BASF
1248	Wapella	Sk	297.23	29.72	24.30	16.52	10.66	6.93	5.40	4.11	1586.07	Edmonton	BASF
1249	Watrous	SK	239.03	22.09	17.39	11.75	7.56	4.90	3.82	2.91	1109.21	Edmonton	BASF
1250	Watson	SK	239.03	23.15	18.35	12.42	7.99	5.18	4.04	3.08	1175.27	Edmonton	BASF
1251	Wawota	SK	352.81	35.28	29.34	20.00	12.91	8.40	6.55	4.97	1933.42	Edmonton	BASF
1252	Weyburn	SK	258.92	25.89	20.83	14.13	9.10	5.91	4.61	3.51	1346.61	Edmonton	BASF
1253	White City	SK	239.03	22.16	17.45	11.80	7.58	4.92	3.84	2.92	1113.34	Edmonton	BASF
1254	White Star	SK	283.40	28.34	23.05	15.66	10.10	6.56	5.12	3.89	1499.60	Edmonton	BASF
1255	Whitewood	SK	287.65	28.77	23.43	15.92	10.27	6.67	5.21	3.96	1526.21	Edmonton	BASF
1256	Wilcox	Sk	239.03	23.18	18.38	12.44	8.00	5.19	4.05	3.08	1177.33	Edmonton	BASF
1257	Wilkie	SK	258.12	25.81	20.76	14.08	9.07	5.89	4.59	3.50	1341.63	Edmonton	BASF
1258	Wiseton	SK	258.88	25.89	20.83	14.13	9.10	5.91	4.61	3.51	1346.35	Edmonton	BASF
1259	Wolseley	SK	255.61	25.56	20.53	13.92	8.97	5.82	4.54	3.46	1325.96	Edmonton	BASF
1260	Woodrow	SK	318.48	31.85	26.23	17.85	11.52	7.49	5.84	4.44	1718.86	Edmonton	BASF
1261	Wymark	SK	309.05	30.90	25.37	17.26	11.14	7.24	5.65	4.29	1659.92	Edmonton	BASF
1262	Wynyard	SK	239.03	23.51	18.67	12.64	8.13	5.28	4.12	3.14	1197.97	Edmonton	BASF
1263	Yellow Creek 	SK	278.49	27.85	22.60	15.35	9.90	6.43	5.02	3.81	1468.95	Edmonton	BASF
1264	Yellow Grass	SK	250.99	25.10	20.11	13.63	8.78	5.70	4.45	3.38	1297.06	Edmonton	BASF
1265	Yorkton	SK	266.51	26.65	21.52	14.60	9.41	6.11	4.77	3.63	1394.09	Edmonton	BASF
1266	Acadia Valley	AB	325.95	20.27	18.37	12.67	8.24	5.39	4.20	3.17	1267.16	Lethbridge	BASF
1267	Airdrie	AB	217.30	11.35	10.29	7.10	4.61	3.02	2.35	1.77	709.64	Lethbridge	BASF
1268	Alix	AB	325.95	16.75	15.18	10.47	6.80	4.45	3.47	2.62	1046.85	Lethbridge	BASF
1269	Alliance	AB	325.95	18.66	16.91	11.66	7.58	4.96	3.86	2.92	1166.00	Lethbridge	BASF
1270	Amisk	AB	325.95	20.63	18.70	12.89	8.38	5.48	4.27	3.22	1289.49	Lethbridge	BASF
1271	Andrew	AB	325.95	21.89	19.84	13.68	8.89	5.82	4.53	3.42	1368.33	Lethbridge	BASF
1272	Athabasca	AB	325.95	23.82	21.59	14.89	9.68	6.33	4.93	3.72	1488.94	Lethbridge	BASF
1273	Balzac	AB	217.30	10.92	9.90	6.83	4.44	2.90	2.26	1.71	682.66	Lethbridge	BASF
1274	Barons	AB	217.30	10.10	9.16	6.32	4.11	2.68	2.09	1.58	631.54	Lethbridge	BASF
1275	Barrhead	AB	325.95	22.50	20.39	14.06	9.14	5.98	4.66	3.52	1406.41	Lethbridge	BASF
1276	Bashaw	AB	325.95	16.64	15.08	10.40	6.76	4.42	3.44	2.60	1040.11	Lethbridge	BASF
1277	Bassano	AB	217.30	12.43	11.27	7.77	5.05	3.30	2.57	1.94	777.08	Lethbridge	BASF
1278	Bay Tree	AB	422.88	42.29	38.32	26.43	17.18	11.23	8.75	6.61	2642.99	Lethbridge	BASF
1279	Beaverlodge	AB	489.50	48.95	44.36	30.59	19.89	13.00	10.13	7.65	3059.36	Lethbridge	BASF
1280	Beiseker	AB	217.30	12.25	11.10	7.66	4.98	3.25	2.54	1.91	765.84	Lethbridge	BASF
1281	Benalto	AB	217.30	17.90	16.22	11.19	7.27	4.75	3.70	2.80	1118.79	Lethbridge	BASF
1282	Bentley	AB	217.30	17.54	15.90	10.96	7.13	4.66	3.63	2.74	1096.31	Lethbridge	BASF
1283	Blackfalds	AB	217.30	16.46	14.92	10.29	6.69	4.37	3.41	2.57	1028.87	Lethbridge	BASF
1284	Blackie	AB	217.30	9.99	9.05	6.24	4.06	2.65	2.07	1.56	624.21	Lethbridge	BASF
1285	Bonnyville	AB	325.95	24.81	22.48	15.50	10.08	6.59	5.13	3.88	1550.42	Lethbridge	BASF
1286	Bow Island	AB	217.30	15.24	13.81	9.52	6.19	4.05	3.15	2.38	952.43	Lethbridge	BASF
1287	Boyle	AB	325.95	16.05	14.54	10.03	6.52	4.26	3.32	2.51	1002.93	Lethbridge	BASF
1288	Brooks	AB	217.30	12.61	11.43	7.88	5.12	3.35	2.61	1.97	788.32	Lethbridge	BASF
1289	Burdett	AB	217.30	14.34	13.00	8.96	5.83	3.81	2.97	2.24	896.23	Lethbridge	BASF
1290	Calgary	AB	195.57	9.84	8.92	6.15	4.00	2.61	2.04	1.54	615.22	Lethbridge	BASF
1291	Calmar	AB	325.95	17.43	15.80	10.90	7.08	4.63	3.61	2.72	1089.57	Lethbridge	BASF
1292	Camrose	AB	325.95	18.33	16.61	11.46	7.45	4.87	3.79	2.86	1145.77	Lethbridge	BASF
1293	Carbon	AB	217.30	13.37	12.12	8.36	5.43	3.55	2.77	2.09	835.53	Lethbridge	BASF
1294	Cardston	AB	217.30	11.97	10.84	7.48	4.86	3.18	2.48	1.87	747.86	Lethbridge	BASF
1295	Carseland	AB	217.30	10.24	9.28	6.40	4.16	2.72	2.12	1.60	639.95	Lethbridge	BASF
1296	Carstairs	AB	325.95	12.86	11.66	8.04	5.23	3.42	2.66	2.01	804.06	Lethbridge	BASF
1297	Castor	AB	325.95	17.58	15.93	10.99	7.14	4.67	3.64	2.75	1098.56	Lethbridge	BASF
1298	Clandonald	AB	325.95	10.20	9.25	6.38	4.15	2.71	2.11	1.59	637.70	Lethbridge	BASF
1299	Claresholm	AB	217.30	9.77	8.86	6.11	3.97	2.60	2.02	1.53	610.73	Lethbridge	BASF
1300	Clyde	AB	217.30	8.62	7.81	5.39	3.50	2.29	1.78	1.35	538.79	Lethbridge	BASF
1301	Coaldale	AB	217.30	23.97	21.72	14.98	9.74	6.37	4.96	3.75	1498.11	Lethbridge	BASF
1302	Cochrane	AB	325.95	8.17	7.40	5.11	3.32	2.17	1.69	1.28	510.66	Lethbridge	BASF
1303	Consort	AB	217.30	13.33	12.08	8.33	5.42	3.54	2.76	2.08	833.28	Lethbridge	BASF
1304	Coronation	AB	325.95	19.93	18.07	12.46	8.10	5.30	4.13	3.11	1245.93	Lethbridge	BASF
1305	Cremona	AB	217.30	14.52	13.16	9.07	5.90	3.86	3.00	2.27	907.47	Lethbridge	BASF
1306	Crossfield	AB	217.30	12.07	10.94	7.55	4.90	3.21	2.50	1.89	754.60	Lethbridge	BASF
1307	Cypress County	AB	325.95	15.31	13.88	9.57	6.22	4.07	3.17	2.39	956.93	Lethbridge	BASF
1308	Czar	AB	325.95	21.77	19.73	13.61	8.84	5.78	4.51	3.40	1360.56	Lethbridge	BASF
1309	Daysland	AB	325.95	17.47	15.83	10.92	7.10	4.64	3.62	2.73	1091.81	Lethbridge	BASF
1310	Debolt	AB	435.64	43.56	39.48	27.23	17.70	11.57	9.02	6.81	2722.77	Lethbridge	BASF
1311	Delburne	AB	325.95	16.43	14.89	10.27	6.67	4.36	3.40	2.57	1026.62	Lethbridge	BASF
1312	Delia	AB	325.95	16.21	14.69	10.13	6.59	4.31	3.35	2.53	1013.13	Lethbridge	BASF
1313	Dewberry	AB	325.95	23.44	21.24	14.65	9.52	6.23	4.85	3.66	1465.00	Lethbridge	BASF
1314	Dickson	AB	325.95	16.82	15.24	10.51	6.83	4.47	3.48	2.63	1051.35	Lethbridge	BASF
1315	Didsbury	AB	325.95	13.94	12.64	8.72	5.66	3.70	2.89	2.18	871.50	Lethbridge	BASF
1316	Drayton Valley	AB	325.95	19.70	17.85	12.31	8.00	5.23	4.08	3.08	1231.20	Lethbridge	BASF
1317	Drumheller	AB	325.95	14.45	13.09	9.03	5.87	3.84	2.99	2.26	902.98	Lethbridge	BASF
1318	Dunmore	AB	217.30	15.71	14.23	9.82	6.38	4.17	3.25	2.45	981.66	Lethbridge	BASF
1319	Eaglesham	AB	479.26	47.93	43.43	29.95	19.47	12.73	9.92	7.49	2995.38	Lethbridge	BASF
1320	Eckville	AB	325.95	17.76	16.10	11.10	7.22	4.72	3.68	2.78	1110.27	Lethbridge	BASF
1321	Edberg	AB	325.95	17.07	15.47	10.67	6.94	4.54	3.53	2.67	1067.09	Lethbridge	BASF
1322	Edgerton	AB	325.95	23.21	21.04	14.51	9.43	6.17	4.80	3.63	1450.91	Lethbridge	BASF
1323	Edmonton	AB	325.95	13.89	12.59	8.68	5.64	3.69	2.87	2.17	868.11	Lethbridge	BASF
1324	Enchant	AB	325.95	12.58	11.40	7.86	5.11	3.34	2.60	1.97	786.41	Lethbridge	BASF
1325	Ervick	AB	325.95	8.17	7.40	5.11	3.32	2.17	1.69	1.28	510.66	Lethbridge	BASF
1326	Evansburg	AB	325.95	19.85	17.99	12.41	8.06	5.27	4.11	3.10	1240.72	Lethbridge	BASF
1327	Fairview	AB	522.88	52.29	47.39	32.68	21.24	13.89	10.82	8.17	3267.99	Lethbridge	BASF
1328	Falher	AB	451.67	45.17	40.93	28.23	18.35	12.00	9.35	7.06	2822.91	Lethbridge	BASF
1329	Foremost	AB	325.95	15.28	13.84	9.55	6.21	4.06	3.16	2.39	954.78	Lethbridge	BASF
1330	Forestburg	AB	325.95	17.86	16.19	11.17	7.26	4.75	3.70	2.79	1116.54	Lethbridge	BASF
1331	Fort MacLeod	AB	217.30	10.10	9.15	6.31	4.10	2.68	2.09	1.58	630.96	Lethbridge	BASF
1332	Fort Saskatchewan	AB	325.95	18.15	16.45	11.35	7.37	4.82	3.76	2.84	1134.53	Lethbridge	BASF
1333	Galahad	AB	325.95	17.61	15.96	11.01	7.16	4.68	3.65	2.75	1100.81	Lethbridge	BASF
1334	Girouxville	AB	457.90	45.79	41.50	28.62	18.60	12.16	9.48	7.15	2861.86	Lethbridge	BASF
1335	Gleichen	AB	217.30	10.71	9.71	6.69	4.35	2.85	2.22	1.67	669.46	Lethbridge	BASF
1336	Glendon	AB	325.95	23.52	21.32	14.70	9.56	6.25	4.87	3.68	1470.12	Lethbridge	BASF
1337	Grande Prairie	AB	465.91	46.59	42.22	29.12	18.93	12.38	9.64	7.28	2911.93	Lethbridge	BASF
1338	Grassy Lake	AB	217.30	13.76	12.47	8.60	5.59	3.66	2.85	2.15	860.26	Lethbridge	BASF
1339	Grimshaw	AB	496.17	49.62	44.97	31.01	20.16	13.18	10.27	7.75	3101.08	Lethbridge	BASF
1340	Guy	AB	437.42	43.74	39.64	27.34	17.77	11.62	9.05	6.83	2733.90	Lethbridge	BASF
1341	Hairy Hill	AB	325.95	19.74	17.88	12.33	8.02	5.24	4.08	3.08	1233.44	Lethbridge	BASF
1342	Halkirk	AB	325.95	17.47	15.83	10.92	7.10	4.64	3.62	2.73	1091.81	Lethbridge	BASF
1343	Hanna	AB	325.95	16.10	14.59	10.06	6.54	4.28	3.33	2.52	1006.39	Lethbridge	BASF
1344	High Level	AB	624.35	62.44	56.58	39.02	25.36	16.58	12.92	9.76	3902.22	Lethbridge	BASF
1345	High Prairie	AB	404.04	40.40	36.62	25.25	16.41	10.73	8.36	6.31	2525.27	Lethbridge	BASF
1346	High River	AB	217.30	9.84	8.92	6.15	4.00	2.61	2.04	1.54	615.22	Lethbridge	BASF
1347	Hines Creek	AB	412.27	41.23	37.36	25.77	16.75	10.95	8.53	6.44	2576.66	Lethbridge	BASF
1348	Holden	AB	325.95	17.83	16.16	11.14	7.24	4.74	3.69	2.79	1114.30	Lethbridge	BASF
1349	Hussar	AB	325.95	12.51	11.33	7.82	5.08	3.32	2.59	1.95	781.58	Lethbridge	BASF
1350	Hythe	AB	478.37	47.84	43.35	29.90	19.43	12.71	9.90	7.47	2989.82	Lethbridge	BASF
1351	Innisfail	AB	325.95	15.35	13.91	9.59	6.23	4.08	3.18	2.40	959.18	Lethbridge	BASF
1352	Innisfree	AB	325.95	19.38	17.56	12.11	7.87	5.15	4.01	3.03	1210.96	Lethbridge	BASF
1353	Irma	AB	325.95	19.74	17.88	12.33	8.02	5.24	4.08	3.08	1233.44	Lethbridge	BASF
1354	Iron Springs	AB	217.30	10.85	9.83	6.78	4.41	2.88	2.25	1.70	678.17	Lethbridge	BASF
1355	Killam	AB	325.95	18.40	16.68	11.50	7.48	4.89	3.81	2.88	1150.26	Lethbridge	BASF
1356	Kirriemuir	AB	325.95	23.22	21.05	14.52	9.43	6.17	4.81	3.63	1451.51	Lethbridge	BASF
1357	Kitscoty	AB	325.95	23.19	21.01	14.49	9.42	6.16	4.80	3.62	1449.26	Lethbridge	BASF
1358	La Glace	AB	467.24	46.72	42.34	29.20	18.98	12.41	9.67	7.30	2920.27	Lethbridge	BASF
1359	Lac La Biche	AB	325.95	9.99	9.05	6.24	4.06	2.65	2.07	1.56	624.21	Lethbridge	BASF
1360	Lacombe	AB	325.95	16.75	15.18	10.47	6.80	4.45	3.47	2.62	1046.85	Lethbridge	BASF
1361	Lacrete	AB	590.97	59.10	53.56	36.94	24.01	15.70	12.23	9.23	3693.59	Lethbridge	BASF
1362	Lamont	AB	325.95	19.74	17.88	12.33	8.02	5.24	4.08	3.08	1233.44	Lethbridge	BASF
1363	Lavoy	AB	325.95	18.51	16.78	11.57	7.52	4.92	3.83	2.89	1157.01	Lethbridge	BASF
1364	Leduc	AB	325.95	16.75	15.18	10.47	6.80	4.45	3.47	2.62	1046.85	Lethbridge	BASF
1365	Legal	AB	325.95	19.20	17.40	12.00	7.80	5.10	3.97	3.00	1199.72	Lethbridge	BASF
1366	Lethbridge	AB	217.30	9.84	8.92	6.15	4.00	2.61	2.04	1.54	615.22	Lethbridge	BASF
1367	Linden	AB	217.30	13.30	12.05	8.31	5.40	3.53	2.75	2.08	831.04	Lethbridge	BASF
1368	Lloydminster	AB	325.95	24.12	21.86	15.08	9.80	6.41	4.99	3.77	1507.71	Lethbridge	BASF
1369	Lomond	AB	217.30	11.07	10.03	6.92	4.50	2.94	2.29	1.73	691.66	Lethbridge	BASF
1370	Lougheed	AB	217.30	19.20	17.40	12.00	7.80	5.10	3.97	3.00	1199.72	Lethbridge	BASF
1371	Magrath	AB	325.95	11.35	10.29	7.10	4.61	3.02	2.35	1.77	709.64	Lethbridge	BASF
1372	Mallaig	AB	325.95	22.65	20.53	14.16	9.20	6.02	4.69	3.54	1415.54	Lethbridge	BASF
1373	Manning	AB	537.57	53.76	48.72	33.60	21.84	14.28	11.13	8.40	3359.78	Lethbridge	BASF
1374	Marwayne	AB	325.95	24.02	21.76	15.01	9.76	6.38	4.97	3.75	1500.96	Lethbridge	BASF
1375	Mayerthorpe	AB	325.95	23.75	21.52	14.84	9.65	6.31	4.92	3.71	1484.35	Lethbridge	BASF
1376	McLennan	AB	345.54	34.55	31.31	21.60	14.04	9.18	7.15	5.40	2159.65	Lethbridge	BASF
1377	Medicine Hat	AB	217.30	15.31	13.88	9.57	6.22	4.07	3.17	2.39	956.93	Lethbridge	BASF
1378	Milk River	AB	325.95	13.85	12.55	8.65	5.62	3.68	2.87	2.16	865.38	Lethbridge	BASF
1379	Milo	AB	217.30	11.50	10.42	7.19	4.67	3.05	2.38	1.80	718.63	Lethbridge	BASF
1380	Morinville	AB	325.95	18.26	16.55	11.41	7.42	4.85	3.78	2.85	1141.27	Lethbridge	BASF
1381	Mossleigh	AB	217.30	10.20	9.25	6.38	4.15	2.71	2.11	1.59	637.70	Lethbridge	BASF
1382	Mundare	AB	325.95	20.45	18.54	12.78	8.31	5.43	4.23	3.20	1278.41	Lethbridge	BASF
1383	Myrnam	AB	325.95	21.17	19.19	13.23	8.60	5.62	4.38	3.31	1323.37	Lethbridge	BASF
1384	Nampa	AB	448.11	44.81	40.61	28.01	18.20	11.90	9.27	7.00	2800.66	Lethbridge	BASF
1385	Nanton	AB	217.30	9.84	8.92	6.15	4.00	2.61	2.04	1.54	615.22	Lethbridge	BASF
1386	Neerlandia	AB	325.95	23.49	21.29	14.68	9.54	6.24	4.86	3.67	1468.31	Lethbridge	BASF
1387	New Dayton	AB	325.95	12.18	11.04	7.61	4.95	3.24	2.52	1.90	761.35	Lethbridge	BASF
1388	New Norway	AB	325.95	16.68	15.11	10.42	6.78	4.43	3.45	2.61	1042.36	Lethbridge	BASF
1389	Nisku	AB	325.95	16.79	15.21	10.49	6.82	4.46	3.47	2.62	1049.10	Lethbridge	BASF
1390	Nobleford	AB	217.30	9.84	8.92	6.15	4.00	2.61	2.04	1.54	615.22	Lethbridge	BASF
1391	Okotoks	AB	217.30	9.92	8.99	6.20	4.03	2.63	2.05	1.55	619.72	Lethbridge	BASF
1392	Olds	AB	325.95	14.30	12.96	8.94	5.81	3.80	2.96	2.23	893.98	Lethbridge	BASF
1393	Onoway	AB	325.95	8.17	7.40	5.11	3.32	2.17	1.69	1.28	510.66	Lethbridge	BASF
1394	Oyen	AB	325.95	20.67	18.73	12.92	8.40	5.49	4.28	3.23	1291.78	Lethbridge	BASF
1395	Paradise Valley	AB	325.95	23.27	21.09	14.55	9.45	6.18	4.82	3.64	1454.55	Lethbridge	BASF
1396	Peers	AB	325.95	9.12	8.27	5.70	3.71	2.42	1.89	1.43	570.26	Lethbridge	BASF
1397	Penhold	AB	325.95	15.89	14.40	9.93	6.45	4.22	3.29	2.48	992.90	Lethbridge	BASF
1398	Picture Butte	AB	217.30	10.24	9.28	6.40	4.16	2.72	2.12	1.60	639.95	Lethbridge	BASF
1399	Pincher Creek	AB	217.30	12.45	11.28	7.78	5.06	3.31	2.58	1.95	778.26	Lethbridge	BASF
1400	Ponoka	AB	325.95	16.89	15.31	10.56	6.86	4.49	3.50	2.64	1055.85	Lethbridge	BASF
1401	Provost	AB	325.95	23.24	21.06	14.52	9.44	6.17	4.81	3.63	1452.26	Lethbridge	BASF
1402	Raymond	AB	217.30	11.28	10.22	7.05	4.58	3.00	2.33	1.76	705.15	Lethbridge	BASF
1403	Red Deer	AB	325.95	16.68	15.11	10.42	6.78	4.43	3.45	2.61	1042.36	Lethbridge	BASF
1404	Rimbey	AB	325.95	17.94	16.26	11.21	7.29	4.76	3.71	2.80	1121.04	Lethbridge	BASF
1405	Rivercourse	AB	325.95	23.76	21.54	14.85	9.65	6.31	4.92	3.71	1485.23	Lethbridge	BASF
1406	Rocky Mountain House	AB	325.95	10.02	9.08	6.26	4.07	2.66	2.07	1.57	626.46	Lethbridge	BASF
1407	Rocky View	AB	217.30	10.99	9.96	6.87	4.47	2.92	2.28	1.72	687.16	Lethbridge	BASF
1408	Rolling Hills	AB	217.30	12.94	11.72	8.09	5.26	3.44	2.68	2.02	808.56	Lethbridge	BASF
1409	Rosalind	AB	325.95	18.08	16.39	11.30	7.35	4.80	3.74	2.83	1130.03	Lethbridge	BASF
1410	Rosebud	AB	217.30	12.40	11.24	7.75	5.04	3.29	2.57	1.94	774.84	Lethbridge	BASF
1411	Rosedale	AB	325.95	14.45	13.09	9.03	5.87	3.84	2.99	2.26	902.98	Lethbridge	BASF
1412	Rycroft	AB	499.29	49.93	45.25	31.21	20.28	13.26	10.33	7.80	3120.56	Lethbridge	BASF
1413	Ryley	AB	325.95	17.61	15.96	11.01	7.16	4.68	3.65	2.75	1100.81	Lethbridge	BASF
1414	Sedgewick	AB	325.95	18.91	17.14	11.82	7.68	5.02	3.91	2.95	1181.74	Lethbridge	BASF
1415	Sexsmith	AB	472.14	47.21	42.79	29.51	19.18	12.54	9.77	7.38	2950.87	Lethbridge	BASF
1416	Silver Valley	AB	423.60	42.36	38.39	26.47	17.21	11.25	8.77	6.62	2647.48	Lethbridge	BASF
1417	Slave Lake	AB	325.95	10.71	9.70	6.69	4.35	2.84	2.22	1.67	669.18	Lethbridge	BASF
1418	Smoky Lake	AB	325.95	20.67	18.73	12.92	8.40	5.49	4.28	3.23	1291.89	Lethbridge	BASF
1419	Spirit River	AB	503.74	50.37	45.65	31.48	20.46	13.38	10.43	7.87	3148.37	Lethbridge	BASF
1420	Spruce Grove	AB	325.95	17.94	16.26	11.21	7.29	4.76	3.71	2.80	1121.04	Lethbridge	BASF
1421	Spruce View	AB	325.95	8.48	7.68	5.30	3.44	2.25	1.75	1.32	529.80	Lethbridge	BASF
1422	St Albert	AB	325.95	27.94	25.32	17.46	11.35	7.42	5.78	4.37	1746.01	Lethbridge	BASF
1423	St Isidore	AB	466.35	46.64	42.26	29.15	18.95	12.39	9.65	7.29	2914.71	Lethbridge	BASF
1424	St Paul	AB	325.95	21.61	19.58	13.50	8.78	5.74	4.47	3.38	1350.34	Lethbridge	BASF
1425	Standard	AB	217.30	11.50	10.42	7.19	4.67	3.05	2.38	1.80	718.63	Lethbridge	BASF
1426	Stettler	AB	325.95	17.43	15.80	10.90	7.08	4.63	3.61	2.72	1089.57	Lethbridge	BASF
1427	Stirling	AB	325.95	11.32	10.26	7.07	4.60	3.01	2.34	1.77	707.39	Lethbridge	BASF
1428	Stony Plain	AB	325.95	18.22	16.52	11.39	7.40	4.84	3.77	2.85	1139.02	Lethbridge	BASF
1429	Strathmore	AB	217.30	10.28	9.31	6.42	4.17	2.73	2.13	1.61	642.20	Lethbridge	BASF
1430	Strome	AB	325.95	17.83	16.16	11.14	7.24	4.74	3.69	2.79	1114.30	Lethbridge	BASF
1431	Sturgeon County	AB	325.95	18.17	16.47	11.36	7.38	4.83	3.76	2.84	1136.14	Lethbridge	BASF
1432	Sturgeon Valley	AB	325.95	17.72	16.06	11.08	7.20	4.71	3.67	2.77	1107.55	Lethbridge	BASF
1433	Sunnybrook	AB	325.95	8.17	7.40	5.11	3.32	2.17	1.69	1.28	510.66	Lethbridge	BASF
1434	Sylvan Lake	AB	325.95	17.51	15.86	10.94	7.11	4.65	3.62	2.74	1094.06	Lethbridge	BASF
1435	Taber	AB	217.30	12.40	11.24	7.75	5.04	3.29	2.57	1.94	774.84	Lethbridge	BASF
1436	Thorhild	AB	325.95	20.42	18.50	12.76	8.30	5.42	4.23	3.19	1276.16	Lethbridge	BASF
1437	Three Hills	AB	325.95	14.12	12.80	8.83	5.74	3.75	2.92	2.21	882.74	Lethbridge	BASF
1438	Tofield	AB	325.95	8.17	7.40	5.11	3.32	2.17	1.69	1.28	510.66	Lethbridge	BASF
1439	Torrington	AB	325.95	14.48	13.13	9.05	5.88	3.85	3.00	2.26	905.22	Lethbridge	BASF
1440	Trochu	AB	325.95	14.66	13.29	9.16	5.96	3.89	3.03	2.29	916.46	Lethbridge	BASF
1441	Turin	AB	325.95	11.39	10.32	7.12	4.63	3.03	2.36	1.78	711.89	Lethbridge	BASF
1442	Two Hills	AB	325.95	19.66	17.82	12.29	7.99	5.22	4.07	3.07	1228.95	Lethbridge	BASF
1443	Valleyview	AB	386.24	38.62	35.00	24.14	15.69	10.26	7.99	6.04	2414.00	Lethbridge	BASF
1444	Vauxhall	AB	217.30	12.43	11.27	7.77	5.05	3.30	2.57	1.94	777.08	Lethbridge	BASF
1445	Vegreville	AB	325.95	18.40	16.68	11.50	7.48	4.89	3.81	2.88	1150.26	Lethbridge	BASF
1446	Vermilion	AB	325.95	21.53	19.51	13.46	8.75	5.72	4.46	3.36	1345.85	Lethbridge	BASF
1447	Veteran	AB	325.95	19.66	17.82	12.29	7.99	5.22	4.07	3.07	1228.95	Lethbridge	BASF
1448	Viking	AB	325.95	18.37	16.65	11.48	7.46	4.88	3.80	2.87	1148.02	Lethbridge	BASF
1449	Vulcan	AB	217.30	10.20	9.25	6.38	4.15	2.71	2.11	1.59	637.70	Lethbridge	BASF
1450	Wainwright	AB	325.95	21.81	19.76	13.63	8.86	5.79	4.51	3.41	1362.85	Lethbridge	BASF
1451	Wanham	AB	480.15	48.02	43.51	30.01	19.51	12.75	9.94	7.50	3000.94	Lethbridge	BASF
1452	Warburg	AB	325.95	17.76	16.09	11.10	7.21	4.72	3.67	2.77	1109.80	Lethbridge	BASF
1453	Warner	AB	217.30	12.72	11.53	7.95	5.17	3.38	2.63	1.99	795.07	Lethbridge	BASF
1454	Waskatenau	AB	325.95	21.33	19.33	13.33	8.66	5.67	4.41	3.33	1333.05	Lethbridge	BASF
1455	Westlock	AB	325.95	20.53	18.60	12.83	8.34	5.45	4.25	3.21	1282.90	Lethbridge	BASF
1456	Wetaskiwin	AB	325.95	16.97	15.37	10.60	6.89	4.51	3.51	2.65	1060.34	Lethbridge	BASF
1457	Whitecourt	AB	325.95	9.45	8.56	5.90	3.84	2.51	1.96	1.48	590.49	Lethbridge	BASF
1458	Winfield	AB	325.95	8.17	7.40	5.11	3.32	2.17	1.69	1.28	510.66	Lethbridge	BASF
1459	Dawson Creek	BC	543.67	58.71	50.57	34.64	22.43	14.63	11.40	8.64	3397.94	Lethbridge	BASF
1460	Delta	BC	672.74	71.62	62.27	42.71	27.68	18.05	14.07	10.65	4204.64	Lethbridge	BASF
1461	Fort St. John	BC	588.18	63.16	54.61	37.42	24.24	15.81	12.32	9.33	3676.11	Lethbridge	BASF
1462	Grindrod	BC	414.60	45.81	38.88	26.58	17.19	11.20	8.73	6.62	2591.25	Lethbridge	BASF
1463	Kamloops	BC	478.69	52.21	44.69	30.58	19.79	12.90	10.06	7.62	2991.81	Lethbridge	BASF
1464	Kelowna	BC	469.79	51.32	43.88	30.02	19.43	12.66	9.87	7.48	2936.18	Lethbridge	BASF
1465	Keremeos	BC	533.88	57.73	49.69	34.03	22.04	14.37	11.20	8.48	3336.74	Lethbridge	BASF
1466	Naramata	BC	491.15	53.46	45.81	31.36	20.30	13.23	10.32	7.82	3069.70	Lethbridge	BASF
1467	Oliver	BC	528.54	57.20	49.20	33.70	21.82	14.22	11.09	8.40	3303.36	Lethbridge	BASF
1468	Penticton	BC	508.06	55.15	47.35	32.42	20.99	13.68	10.67	8.08	3175.41	Lethbridge	BASF
1469	Prince George	BC	627.79	67.12	58.20	39.90	25.85	16.86	13.14	9.95	3923.69	Lethbridge	BASF
1470	Rolla	BC	548.57	59.20	51.02	34.95	22.63	14.76	11.50	8.71	3428.54	Lethbridge	BASF
1471	Vernon	BC	444.86	48.83	41.62	28.47	18.42	12.00	9.36	7.09	2780.40	Lethbridge	BASF
1472	Altamont	MB	388.86	43.23	36.54	24.97	16.15	10.51	8.20	6.22	2430.39	Lethbridge	BASF
1473	Altona	MB	404.06	44.75	37.92	25.92	16.76	10.92	8.51	6.45	2525.35	Lethbridge	BASF
1474	Angusville	MB	374.27	41.77	35.22	24.05	15.55	10.13	7.90	5.99	2339.19	Lethbridge	BASF
1475	Arborg	MB	425.20	46.87	39.84	27.24	17.62	11.48	8.95	6.78	2657.47	Lethbridge	BASF
1476	Arnaud	MB	403.40	44.69	37.86	25.87	16.74	10.90	8.50	6.44	2521.22	Lethbridge	BASF
1477	Baldur	MB	393.16	43.66	36.93	25.24	16.32	10.63	8.29	6.28	2457.23	Lethbridge	BASF
1478	Beausejour	MB	395.47	43.89	37.14	25.38	16.41	10.69	8.34	6.32	2471.68	Lethbridge	BASF
1479	Benito	MB	391.47	43.49	36.78	25.13	16.25	10.58	8.25	6.26	2446.69	Lethbridge	BASF
1480	Binscarth	MB	374.61	41.81	35.25	24.08	15.57	10.14	7.90	5.99	2341.30	Lethbridge	BASF
1481	Birch River	MB	421.82	46.53	39.53	27.03	17.48	11.39	8.88	6.73	2636.39	Lethbridge	BASF
1482	Birtle	MB	380.00	42.35	35.74	24.41	15.79	10.28	8.02	6.08	2375.02	Lethbridge	BASF
1483	Boissevain	MB	404.29	44.77	37.94	25.93	16.77	10.92	8.52	6.46	2526.79	Lethbridge	BASF
1484	Brandon	MB	371.69	41.51	34.99	23.89	15.45	10.06	7.84	5.95	2323.05	Lethbridge	BASF
1485	Brunkild	MB	385.89	42.94	36.28	24.78	16.02	10.43	8.14	6.17	2411.81	Lethbridge	BASF
1486	Carberry	MB	371.36	41.48	34.96	23.87	15.43	10.05	7.84	5.94	2320.98	Lethbridge	BASF
1487	Carman	MB	384.57	42.80	36.16	24.70	15.97	10.40	8.11	6.15	2403.56	Lethbridge	BASF
1488	Cartwright	MB	404.29	44.77	37.94	25.93	16.77	10.92	8.52	6.46	2526.79	Lethbridge	BASF
1489	Crystal City	MB	410.02	45.35	38.46	26.29	17.00	11.08	8.64	6.55	2562.62	Lethbridge	BASF
1490	Cypress River	MB	379.61	42.31	35.71	24.39	15.77	10.27	8.01	6.07	2372.59	Lethbridge	BASF
1491	Darlingford	MB	396.79	44.02	37.26	25.46	16.47	10.72	8.36	6.34	2479.94	Lethbridge	BASF
1492	Dauphin	MB	398.89	44.23	37.45	25.59	16.55	10.78	8.41	6.37	2493.06	Lethbridge	BASF
1493	Deloraine	MB	408.00	45.15	38.28	26.16	16.92	11.02	8.60	6.52	2549.97	Lethbridge	BASF
1494	Domain	MB	382.26	42.57	35.95	24.55	15.88	10.34	8.06	6.11	2389.10	Lethbridge	BASF
1495	Dominion City	MB	407.36	45.08	38.22	26.12	16.90	11.01	8.58	6.51	2546.00	Lethbridge	BASF
1496	Douglas	MB	370.04	41.35	34.84	23.79	15.38	10.01	7.81	5.92	2312.72	Lethbridge	BASF
1497	Dufrost	MB	399.43	44.29	37.50	25.63	16.57	10.79	8.42	6.38	2496.45	Lethbridge	BASF
1498	Dugald	MB	378.62	42.21	35.62	24.33	15.73	10.24	7.99	6.06	2366.40	Lethbridge	BASF
1499	Dunrea	MB	397.88	44.13	37.36	25.53	16.51	10.75	8.39	6.36	2486.74	Lethbridge	BASF
1500	Elgin	MB	394.51	43.80	37.06	25.32	16.37	10.66	8.32	6.31	2465.66	Lethbridge	BASF
1501	Elie	MB	370.04	41.35	34.84	23.79	15.38	10.01	7.81	5.92	2312.72	Lethbridge	BASF
1502	Elkhorn	MB	364.49	40.80	34.34	23.44	15.16	9.87	7.70	5.84	2278.06	Lethbridge	BASF
1503	Elm Creek	MB	378.29	42.18	35.59	24.31	15.72	10.23	7.98	6.05	2364.33	Lethbridge	BASF
1504	Emerson	MB	413.63	45.71	38.79	26.51	17.15	11.17	8.71	6.60	2585.22	Lethbridge	BASF
1505	Fannystelle	MB	376.64	42.01	35.44	24.20	15.65	10.19	7.95	6.03	2354.01	Lethbridge	BASF
1506	Fisher Branch	MB	440.03	48.35	41.18	28.16	18.22	11.87	9.26	7.02	2750.21	Lethbridge	BASF
1507	Fork River	MB	417.44	46.09	39.13	26.75	17.31	11.27	8.79	6.66	2608.99	Lethbridge	BASF
1508	Forrest	MB	373.01	41.65	35.11	23.98	15.50	10.09	7.87	5.97	2331.30	Lethbridge	BASF
1509	Foxwarren	MB	371.69	41.51	34.99	23.89	15.45	10.06	7.84	5.95	2323.05	Lethbridge	BASF
1510	Franklin	MB	379.61	42.31	35.71	24.39	15.77	10.27	8.01	6.07	2372.59	Lethbridge	BASF
1511	Gilbert Plains	MB	392.82	43.63	36.90	25.21	16.31	10.62	8.28	6.28	2455.12	Lethbridge	BASF
1512	Gimli	MB	406.37	44.98	38.13	26.06	16.86	10.98	8.56	6.49	2539.80	Lethbridge	BASF
1513	Gladstone	MB	378.62	42.21	35.62	24.33	15.73	10.24	7.99	6.06	2366.40	Lethbridge	BASF
1514	Glenboro	MB	387.21	43.07	36.39	24.86	16.08	10.47	8.17	6.19	2420.07	Lethbridge	BASF
1515	Glossop (Newdale)	MB	376.64	42.01	35.44	24.20	15.65	10.19	7.95	6.03	2354.01	Lethbridge	BASF
1516	Goodlands	MB	412.38	45.58	38.68	26.44	17.10	11.14	8.69	6.58	2577.37	Lethbridge	BASF
1517	Grandview	MB	386.41	42.99	36.32	24.81	16.05	10.45	8.15	6.18	2415.07	Lethbridge	BASF
1518	Gretna	MB	407.03	45.05	38.19	26.10	16.88	11.00	8.58	6.50	2543.93	Lethbridge	BASF
1519	Griswold	MB	370.04	41.35	34.84	23.79	15.38	10.01	7.81	5.92	2312.72	Lethbridge	BASF
1520	Grosse Isle	MB	379.28	42.27	35.68	24.37	15.76	10.26	8.00	6.07	2370.53	Lethbridge	BASF
1521	Gunton	MB	388.86	43.23	36.54	24.97	16.15	10.51	8.20	6.22	2430.39	Lethbridge	BASF
1522	Hamiota	MB	377.63	42.11	35.53	24.26	15.69	10.22	7.97	6.04	2360.20	Lethbridge	BASF
1523	Hargrave	MB	363.10	40.66	34.21	23.36	15.10	9.83	7.67	5.81	2269.37	Lethbridge	BASF
1524	Hartney	MB	392.82	43.63	36.90	25.21	16.31	10.62	8.28	6.28	2455.12	Lethbridge	BASF
1525	High Bluff	MB	375.32	41.88	35.32	24.12	15.60	10.15	7.92	6.01	2345.75	Lethbridge	BASF
1526	Holland	MB	379.61	42.31	35.71	24.39	15.77	10.27	8.01	6.07	2372.59	Lethbridge	BASF
1527	Homewood	MB	384.24	42.77	36.13	24.68	15.96	10.39	8.10	6.14	2401.49	Lethbridge	BASF
1528	Howden	MB	374.99	41.85	35.29	24.10	15.58	10.15	7.91	6.00	2343.69	Lethbridge	BASF
1529	Inglis	MB	368.38	41.18	34.69	23.69	15.31	9.97	7.78	5.90	2302.40	Lethbridge	BASF
1530	Kane	MB	392.50	43.60	36.87	25.19	16.29	10.61	8.27	6.27	2453.10	Lethbridge	BASF
1531	Kemnay	MB	369.71	41.32	34.81	23.77	15.37	10.01	7.80	5.92	2310.66	Lethbridge	BASF
1532	Kenton	MB	374.66	41.81	35.26	24.08	15.57	10.14	7.91	6.00	2341.62	Lethbridge	BASF
1533	Kenville	MB	392.17	43.56	36.84	25.17	16.28	10.60	8.27	6.27	2451.04	Lethbridge	BASF
1534	Killarney	MB	407.32	45.08	38.22	26.12	16.90	11.00	8.58	6.51	2545.76	Lethbridge	BASF
1535	Landmark	MB	386.22	42.97	36.31	24.80	16.04	10.44	8.15	6.18	2413.88	Lethbridge	BASF
1536	Laurier	MB	410.33	45.38	38.49	26.31	17.02	11.08	8.64	6.55	2564.57	Lethbridge	BASF
1537	Letellier	MB	406.37	44.98	38.13	26.06	16.86	10.98	8.56	6.49	2539.80	Lethbridge	BASF
1538	Lowe Farm	MB	392.50	43.60	36.87	25.19	16.29	10.61	8.27	6.27	2453.10	Lethbridge	BASF
1539	Lundar	MB	406.04	44.95	38.10	26.04	16.84	10.97	8.56	6.49	2537.74	Lethbridge	BASF
1540	MacGregor	MB	369.71	41.32	34.81	23.77	15.37	10.01	7.80	5.92	2310.66	Lethbridge	BASF
1541	Manitou	MB	395.80	43.93	37.17	25.40	16.43	10.70	8.34	6.33	2473.74	Lethbridge	BASF
1542	Mariapolis	MB	392.48	43.59	36.87	25.19	16.29	10.61	8.27	6.27	2453.01	Lethbridge	BASF
1543	Marquette	MB	374.66	41.81	35.26	24.08	15.57	10.14	7.91	6.00	2341.62	Lethbridge	BASF
1544	Mather	MB	396.13	43.96	37.20	25.42	16.44	10.71	8.35	6.33	2475.81	Lethbridge	BASF
1545	McCreary	MB	403.73	44.72	37.89	25.90	16.75	10.91	8.51	6.45	2523.29	Lethbridge	BASF
1546	Meadows	MB	375.32	41.88	35.32	24.12	15.60	10.15	7.92	6.01	2345.75	Lethbridge	BASF
1547	Medora	MB	395.47	43.89	37.14	25.38	16.41	10.69	8.34	6.32	2471.68	Lethbridge	BASF
1548	Melita	MB	402.60	44.61	37.79	25.83	16.70	10.88	8.48	6.43	2516.25	Lethbridge	BASF
1549	Miami	MB	389.19	43.27	36.57	24.99	16.16	10.52	8.21	6.22	2432.46	Lethbridge	BASF
1550	Miniota	MB	375.32	41.88	35.32	24.12	15.60	10.15	7.92	6.01	2345.75	Lethbridge	BASF
1551	Minitonas	MB	413.05	45.65	38.74	26.48	17.13	11.16	8.70	6.60	2581.59	Lethbridge	BASF
1552	Minnedosa	MB	379.94	42.34	35.74	24.41	15.78	10.28	8.02	6.08	2374.65	Lethbridge	BASF
1553	Minto	MB	394.17	43.76	37.03	25.30	16.36	10.65	8.31	6.30	2463.55	Lethbridge	BASF
1554	Morden	MB	400.42	44.39	37.59	25.69	16.61	10.82	8.44	6.40	2502.64	Lethbridge	BASF
1555	Morris	MB	395.80	43.93	37.17	25.40	16.43	10.70	8.34	6.33	2473.74	Lethbridge	BASF
1556	Neepawa	MB	378.95	42.24	35.65	24.35	15.74	10.25	7.99	6.06	2368.46	Lethbridge	BASF
1557	Nesbitt	MB	383.25	42.67	36.04	24.62	15.92	10.36	8.08	6.13	2395.30	Lethbridge	BASF
1558	Newdale	MB	376.97	42.04	35.47	24.22	15.66	10.20	7.95	6.03	2356.08	Lethbridge	BASF
1559	Ninga	MB	401.08	44.45	37.65	25.73	16.64	10.84	8.45	6.41	2506.77	Lethbridge	BASF
1560	Niverville	MB	385.23	42.87	36.22	24.74	16.00	10.42	8.12	6.16	2407.68	Lethbridge	BASF
1561	Notre Dame de Lourdes	MB	385.56	42.90	36.25	24.76	16.01	10.43	8.13	6.17	2409.75	Lethbridge	BASF
1562	Oak Bluff	MB	374.99	41.85	35.29	24.10	15.58	10.15	7.91	6.00	2343.69	Lethbridge	BASF
1563	Oak River	MB	376.97	42.04	35.47	24.22	15.66	10.20	7.95	6.03	2356.08	Lethbridge	BASF
1564	Oakbank	MB	383.25	42.67	36.04	24.62	15.92	10.36	8.08	6.13	2395.30	Lethbridge	BASF
1565	Oakner	MB	379.29	42.28	35.68	24.37	15.75	10.26	8.00	6.06	2370.53	Lethbridge	BASF
1566	Oakville	MB	370.70	41.42	34.90	23.83	15.41	10.03	7.82	5.93	2316.85	Lethbridge	BASF
1567	Petersfield	MB	402.26	44.57	37.76	25.80	16.69	10.87	8.48	6.43	2514.14	Lethbridge	BASF
1568	Pierson	MB	404.96	44.84	38.00	25.97	16.80	10.94	8.53	6.47	2531.00	Lethbridge	BASF
1569	Pilot Mound	MB	407.32	45.08	38.22	26.12	16.90	11.00	8.58	6.51	2545.76	Lethbridge	BASF
1570	Pine Falls	MB	420.57	46.40	39.42	26.95	17.43	11.36	8.86	6.71	2628.57	Lethbridge	BASF
1571	Plum Coulee	MB	402.07	44.55	37.74	25.79	16.68	10.86	8.47	6.42	2512.97	Lethbridge	BASF
1572	Plumas	MB	385.89	42.94	36.28	24.78	16.02	10.43	8.14	6.17	2411.81	Lethbridge	BASF
1573	Portage La Prairie	MB	369.38	41.28	34.78	23.75	15.35	10.00	7.80	5.91	2308.60	Lethbridge	BASF
1574	Rathwell	MB	379.61	42.31	35.71	24.39	15.77	10.27	8.01	6.07	2372.59	Lethbridge	BASF
1575	Reston	MB	391.13	43.46	36.75	25.11	16.24	10.57	8.25	6.25	2444.58	Lethbridge	BASF
1576	River Hills	MB	412.64	45.61	38.70	26.45	17.11	11.15	8.69	6.59	2579.03	Lethbridge	BASF
1577	Rivers	MB	376.64	42.01	35.44	24.20	15.65	10.19	7.95	6.03	2354.01	Lethbridge	BASF
1578	Roblin	MB	366.51	41.00	34.52	23.57	15.24	9.92	7.74	5.87	2290.71	Lethbridge	BASF
1579	Roland	MB	391.84	43.53	36.81	25.15	16.27	10.59	8.26	6.26	2448.97	Lethbridge	BASF
1580	Rosenort	MB	393.82	43.73	36.99	25.28	16.35	10.65	8.30	6.29	2461.36	Lethbridge	BASF
1581	Rossburn	MB	374.33	41.78	35.23	24.06	15.55	10.13	7.90	5.99	2339.56	Lethbridge	BASF
1582	Rosser	MB	376.64	42.01	35.44	24.20	15.65	10.19	7.95	6.03	2354.01	Lethbridge	BASF
1583	Russell	MB	365.16	40.86	34.40	23.49	15.18	9.88	7.71	5.85	2282.28	Lethbridge	BASF
1584	Selkirk	MB	385.89	42.94	36.28	24.78	16.02	10.43	8.14	6.17	2411.81	Lethbridge	BASF
1585	Shoal Lake	MB	377.63	42.11	35.53	24.26	15.69	10.22	7.97	6.04	2360.20	Lethbridge	BASF
1586	Sifton	MB	400.75	44.42	37.62	25.71	16.63	10.83	8.45	6.40	2504.71	Lethbridge	BASF
1587	Snowflake	MB	414.74	45.82	38.89	26.58	17.20	11.20	8.74	6.62	2592.13	Lethbridge	BASF
1588	Somerset	MB	389.19	43.27	36.57	24.99	16.16	10.52	8.21	6.22	2432.46	Lethbridge	BASF
1589	Souris	MB	376.64	42.01	35.44	24.20	15.65	10.19	7.95	6.03	2354.01	Lethbridge	BASF
1590	St Claude	MB	378.62	42.21	35.62	24.33	15.73	10.24	7.99	6.06	2366.40	Lethbridge	BASF
1591	St Jean Baptiste	MB	400.42	44.39	37.59	25.69	16.61	10.82	8.44	6.40	2502.64	Lethbridge	BASF
1592	St Joseph	MB	408.35	45.18	38.31	26.18	16.94	11.03	8.60	6.52	2552.19	Lethbridge	BASF
1593	St Leon	MB	389.19	43.27	36.57	24.99	16.16	10.52	8.21	6.22	2432.46	Lethbridge	BASF
1594	Starbuck	MB	376.64	42.01	35.44	24.20	15.65	10.19	7.95	6.03	2354.01	Lethbridge	BASF
1595	Ste Agathe	MB	383.91	42.74	36.10	24.66	15.94	10.38	8.10	6.14	2399.43	Lethbridge	BASF
1596	Ste Anne	MB	390.84	43.43	36.72	25.09	16.23	10.57	8.24	6.25	2442.78	Lethbridge	BASF
1597	Ste Rose du Lac	MB	398.89	44.23	37.45	25.59	16.55	10.78	8.41	6.37	2493.06	Lethbridge	BASF
1598	Steinbach	MB	397.45	44.09	37.32	25.50	16.49	10.74	8.38	6.35	2484.06	Lethbridge	BASF
1599	Stonewall	MB	380.61	42.41	35.80	24.45	15.81	10.29	8.03	6.09	2378.78	Lethbridge	BASF
1600	Strathclair	MB	377.63	42.11	35.53	24.26	15.69	10.22	7.97	6.04	2360.20	Lethbridge	BASF
1601	Swan Lake	MB	396.19	43.97	37.21	25.42	16.44	10.71	8.35	6.33	2476.20	Lethbridge	BASF
1602	Swan River	MB	406.65	45.01	38.16	26.08	16.87	10.99	8.57	6.50	2541.54	Lethbridge	BASF
1603	Teulon	MB	400.91	44.44	37.64	25.72	16.63	10.83	8.45	6.41	2505.71	Lethbridge	BASF
1604	The Pas	MB	492.91	53.64	45.97	31.47	20.37	13.28	10.35	7.84	3080.66	Lethbridge	BASF
1605	Treherne	MB	379.94	42.34	35.74	24.41	15.78	10.28	8.02	6.08	2374.65	Lethbridge	BASF
1606	Turtle Mountain	MB	401.74	44.52	37.71	25.77	16.67	10.86	8.47	6.42	2510.90	Lethbridge	BASF
1607	Virden	MB	368.38	41.18	34.69	23.69	15.31	9.97	7.78	5.90	2302.40	Lethbridge	BASF
1608	Warren	MB	377.96	42.14	35.56	24.29	15.70	10.22	7.97	6.05	2362.27	Lethbridge	BASF
1609	Waskada	MB	410.69	45.42	38.52	26.33	17.03	11.09	8.65	6.56	2566.83	Lethbridge	BASF
1610	Wawanesa	MB	382.92	42.64	36.01	24.60	15.90	10.36	8.08	6.12	2393.23	Lethbridge	BASF
1611	Wellwood	MB	325.95	25.43	20.41	13.84	8.91	5.78	4.52	3.44	1317.71	Lethbridge	BASF
1612	Westbourne	MB	378.29	42.18	35.59	24.31	15.72	10.23	7.98	6.05	2364.33	Lethbridge	BASF
1613	Winkler	MB	399.76	44.32	37.53	25.65	16.59	10.80	8.43	6.39	2498.52	Lethbridge	BASF
1614	Winnipeg	MB	325.95	33.12	27.38	18.64	12.04	7.83	6.11	4.64	1798.16	Lethbridge	BASF
1615	Abbey	SK	325.95	32.50	26.82	18.26	11.78	7.66	5.98	4.54	1759.54	Lethbridge	BASF
1616	Aberdeen	SK	332.04	37.55	31.40	21.42	13.84	9.00	7.02	5.33	2075.28	Lethbridge	BASF
1617	Abernethy	SK	325.95	33.72	27.92	19.02	12.28	7.99	6.23	4.73	1835.57	Lethbridge	BASF
1618	Alameda	SK	354.04	39.75	33.39	22.79	14.73	9.59	7.48	5.67	2212.72	Lethbridge	BASF
1619	Albertville	SK	377.64	42.11	35.53	24.27	15.69	10.22	7.97	6.04	2360.27	Lethbridge	BASF
1620	Antler	SK	384.05	42.75	36.11	24.67	15.95	10.39	8.10	6.14	2400.32	Lethbridge	BASF
1621	Arborfield	SK	400.91	44.44	37.64	25.72	16.63	10.83	8.45	6.41	2505.71	Lethbridge	BASF
1622	Archerwill	SK	364.83	40.83	34.37	23.46	15.17	9.88	7.70	5.84	2280.17	Lethbridge	BASF
1623	Assiniboia	SK	325.95	32.06	26.42	17.98	11.61	7.55	5.89	4.47	1732.14	Lethbridge	BASF
1624	Avonlea	SK	325.95	31.07	25.52	17.37	11.20	7.28	5.68	4.32	1670.26	Lethbridge	BASF
1625	Aylsham	SK	393.87	43.73	37.00	25.28	16.35	10.65	8.30	6.30	2461.70	Lethbridge	BASF
1626	Balcarres	SK	325.95	33.15	27.41	18.67	12.05	7.84	6.11	4.64	1800.45	Lethbridge	BASF
1627	Balgonie	SK	325.95	30.48	24.98	16.99	10.96	7.13	5.56	4.22	1633.07	Lethbridge	BASF
1628	Bankend	SK	325.95	35.83	29.84	20.34	13.14	8.55	6.67	5.06	1967.82	Lethbridge	BASF
1629	Battleford	SK	325.95	36.00	29.99	20.44	13.21	8.59	6.70	5.09	1978.16	Lethbridge	BASF
1630	Beechy	SK	325.95	33.58	27.80	18.93	12.22	7.95	6.20	4.71	1826.99	Lethbridge	BASF
1631	Bengough	SK	325.95	32.72	27.02	18.40	11.88	7.72	6.02	4.58	1773.58	Lethbridge	BASF
1632	Biggar	SK	325.95	32.72	27.02	18.40	11.88	7.72	6.02	4.58	1773.58	Lethbridge	BASF
1633	Birch Hills	SK	361.46	40.49	34.06	23.25	15.03	9.79	7.63	5.79	2259.09	Lethbridge	BASF
1634	Bjorkdale	SK	383.95	42.74	36.10	24.66	15.95	10.38	8.10	6.14	2399.71	Lethbridge	BASF
1635	Blaine Lake	SK	328.74	37.22	31.10	21.21	13.70	8.92	6.96	5.28	2054.61	Lethbridge	BASF
1636	Bracken	SK	325.95	34.08	28.25	19.25	12.43	8.08	6.31	4.79	1858.30	Lethbridge	BASF
1637	Bredenbury	SK	335.35	37.88	31.69	21.62	13.97	9.09	7.09	5.38	2095.94	Lethbridge	BASF
1638	Briercrest	SK	325.95	30.74	25.22	17.16	11.07	7.20	5.61	4.27	1649.60	Lethbridge	BASF
1639	Broadview	SK	325.95	35.60	29.63	20.20	13.04	8.49	6.62	5.02	1953.36	Lethbridge	BASF
1640	Broderick	SK	325.95	30.57	25.07	17.06	11.00	7.15	5.58	4.24	1639.26	Lethbridge	BASF
1641	Brooksby	SK	383.71	42.72	36.08	24.64	15.94	10.38	8.09	6.14	2398.21	Lethbridge	BASF
1642	Bruno	SK	335.02	37.85	31.67	21.60	13.96	9.08	7.09	5.38	2093.88	Lethbridge	BASF
1643	Buchanan	SK	355.72	39.92	33.54	22.90	14.80	9.63	7.51	5.70	2223.26	Lethbridge	BASF
1644	Cabri	SK	325.95	31.39	25.81	17.56	11.33	7.37	5.75	4.37	1689.99	Lethbridge	BASF
1645	Canora	SK	354.71	39.82	33.45	22.83	14.76	9.61	7.49	5.68	2216.94	Lethbridge	BASF
1646	Canwood	SK	363.12	40.66	34.21	23.36	15.10	9.83	7.67	5.82	2269.52	Lethbridge	BASF
1647	Carievale	SK	395.52	43.90	37.15	25.38	16.42	10.69	8.34	6.32	2471.98	Lethbridge	BASF
1648	Carlyle	SK	330.06	37.35	31.22	21.29	13.76	8.95	6.98	5.30	2062.88	Lethbridge	BASF
1649	Carnduff	SK	367.19	41.06	34.58	23.61	15.26	9.94	7.75	5.88	2294.93	Lethbridge	BASF
1650	Carrot River	SK	411.03	45.45	38.55	26.35	17.05	11.10	8.66	6.56	2568.94	Lethbridge	BASF
1651	Central Butte	SK	325.95	31.05	25.50	17.35	11.20	7.28	5.68	4.31	1668.91	Lethbridge	BASF
1652	Ceylon	SK	325.95	33.22	27.47	18.71	12.08	7.85	6.13	4.65	1804.58	Lethbridge	BASF
1653	Choiceland	SK	374.36	41.78	35.23	24.06	15.56	10.13	7.90	5.99	2339.78	Lethbridge	BASF
1654	Churchbridge	SK	345.60	38.91	32.62	22.26	14.39	9.36	7.30	5.54	2160.03	Lethbridge	BASF
1655	Clavet	SK	327.42	37.09	30.98	21.13	13.65	8.88	6.93	5.26	2046.35	Lethbridge	BASF
1656	Codette	SK	391.89	43.53	36.82	25.16	16.27	10.59	8.26	6.26	2449.30	Lethbridge	BASF
1657	Colgate	SK	325.95	35.20	29.26	19.94	12.88	8.38	6.54	4.96	1928.17	Lethbridge	BASF
1658	Colonsay	SK	327.42	37.09	30.98	21.13	13.65	8.88	6.93	5.26	2046.35	Lethbridge	BASF
1659	Congress	SK	325.95	32.03	26.39	17.96	11.59	7.54	5.88	4.47	1730.03	Lethbridge	BASF
1660	Consul	SK	325.95	33.02	27.29	18.58	12.00	7.80	6.09	4.62	1792.18	Lethbridge	BASF
1661	Corman Park	SK	325.95	36.26	30.23	20.61	13.31	8.66	6.76	5.13	1994.69	Lethbridge	BASF
1662	Corning	SK	325.95	36.53	30.47	20.77	13.42	8.73	6.81	5.17	2011.22	Lethbridge	BASF
1663	Coronach	SK	325.95	34.49	28.62	19.50	12.59	8.19	6.39	4.85	1883.90	Lethbridge	BASF
1664	Craik	SK	325.95	31.96	26.33	17.92	11.57	7.52	5.87	4.46	1726.05	Lethbridge	BASF
1665	Creelman	SK	325.95	34.28	28.43	19.37	12.51	8.14	6.35	4.82	1870.70	Lethbridge	BASF
1666	Crooked River	SK	386.75	43.02	36.35	24.83	16.06	10.46	8.16	6.18	2417.18	Lethbridge	BASF
1667	Cudworth	SK	343.95	38.74	32.47	22.16	14.32	9.32	7.27	5.52	2149.67	Lethbridge	BASF
1668	Cupar	SK	325.95	32.66	26.96	18.36	11.85	7.70	6.01	4.56	1769.45	Lethbridge	BASF
1669	Cut knife	SK	325.95	35.47	29.51	20.11	12.99	8.45	6.59	5.00	1945.03	Lethbridge	BASF
1670	Davidson	SK	325.95	32.29	26.63	18.13	11.70	7.61	5.94	4.51	1746.72	Lethbridge	BASF
1671	Debden	SK	373.37	41.68	35.14	24.00	15.52	10.10	7.88	5.98	2333.58	Lethbridge	BASF
1672	Delisle	SK	325.95	31.83	26.21	17.84	11.51	7.49	5.84	4.44	1717.79	Lethbridge	BASF
1673	Delmas	SK	325.95	34.67	28.79	19.62	12.67	8.24	6.43	4.88	1895.50	Lethbridge	BASF
1674	Denzil	SK	325.95	31.63	26.03	17.72	11.43	7.43	5.80	4.40	1705.39	Lethbridge	BASF
1675	Dinsmore	SK	325.95	33.15	27.41	18.67	12.05	7.84	6.11	4.64	1800.45	Lethbridge	BASF
1676	Domremy	SK	354.20	39.77	33.40	22.80	14.74	9.59	7.48	5.68	2213.73	Lethbridge	BASF
1677	Drake	SK	325.95	35.30	29.36	20.01	12.92	8.41	6.56	4.98	1934.76	Lethbridge	BASF
1678	Duperow	SK	325.95	32.86	27.14	18.48	11.93	7.76	6.05	4.60	1781.85	Lethbridge	BASF
1679	Eastend	SK	325.95	32.26	26.60	18.11	11.69	7.60	5.93	4.50	1744.65	Lethbridge	BASF
1680	Eatonia	SK	325.95	31.27	25.70	17.49	11.28	7.34	5.72	4.35	1682.66	Lethbridge	BASF
1681	Ebenezer	SK	342.23	38.57	32.32	22.05	14.25	9.28	7.23	5.49	2138.95	Lethbridge	BASF
1682	Edam	SK	325.95	36.06	30.05	20.49	13.23	8.61	6.72	5.10	1982.29	Lethbridge	BASF
1683	Edenwold	SK	325.95	31.20	25.64	17.45	11.26	7.32	5.71	4.34	1678.53	Lethbridge	BASF
1684	Elfros	SK	325.95	34.21	28.37	19.33	12.48	8.12	6.33	4.81	1866.57	Lethbridge	BASF
1685	Elrose	SK	325.95	34.01	28.19	19.20	12.40	8.06	6.29	4.78	1854.17	Lethbridge	BASF
1686	Estevan	SK	330.43	37.39	31.25	21.31	13.77	8.96	6.99	5.30	2065.18	Lethbridge	BASF
1687	Eston	SK	325.95	31.83	26.21	17.84	11.51	7.49	5.84	4.44	1717.79	Lethbridge	BASF
1688	Eyebrow	SK	325.95	31.05	25.50	17.35	11.20	7.28	5.68	4.31	1668.91	Lethbridge	BASF
1689	Fairlight	SK	354.53	39.80	33.43	22.82	14.75	9.60	7.49	5.68	2215.79	Lethbridge	BASF
1690	Fielding	SK	325.95	36.29	30.26	20.63	13.33	8.67	6.76	5.13	1996.75	Lethbridge	BASF
1691	Fillmore	SK	325.95	33.45	27.68	18.85	12.17	7.92	6.18	4.69	1819.04	Lethbridge	BASF
1692	Foam Lake	SK	329.07	37.25	31.13	21.23	13.72	8.93	6.96	5.28	2056.68	Lethbridge	BASF
1693	Fox Valley	SK	325.95	31.18	25.63	17.44	11.25	7.31	5.71	4.33	1677.34	Lethbridge	BASF
1694	Francis	SK	325.95	31.90	26.27	17.88	11.54	7.50	5.85	4.45	1721.92	Lethbridge	BASF
1695	Frontier	SK	325.95	34.22	28.38	19.33	12.48	8.12	6.33	4.81	1867.04	Lethbridge	BASF
1696	Gerald	SK	360.11	40.36	33.94	23.17	14.98	9.75	7.60	5.77	2250.66	Lethbridge	BASF
1697	Glaslyn	SK	331.44	37.49	31.34	21.38	13.81	8.99	7.01	5.32	2071.50	Lethbridge	BASF
1698	Glenavon	SK	325.95	34.11	28.28	19.27	12.44	8.09	6.31	4.79	1860.37	Lethbridge	BASF
1699	Goodeve	SK	325.95	36.65	30.58	20.85	13.47	8.76	6.84	5.19	2018.80	Lethbridge	BASF
1700	Govan	SK	325.95	33.75	27.95	19.04	12.29	7.99	6.24	4.74	1837.64	Lethbridge	BASF
1701	Grand Coulee	SK	325.95	29.45	24.05	16.35	10.55	6.85	5.35	4.06	1569.01	Lethbridge	BASF
1702	Gravelbourg	SK	325.95	31.45	25.87	17.60	11.36	7.39	5.76	4.38	1694.20	Lethbridge	BASF
1703	Gray	SK	325.95	30.84	25.31	17.22	11.11	7.22	5.63	4.28	1655.80	Lethbridge	BASF
1704	Grenfell	SK	325.95	34.57	28.70	19.56	12.63	8.21	6.41	4.86	1889.30	Lethbridge	BASF
1705	Griffin	SK	325.95	34.54	28.67	19.54	12.61	8.21	6.40	4.86	1887.23	Lethbridge	BASF
1706	Gronlid	SK	325.95	36.92	30.83	21.02	13.58	8.84	6.89	5.23	2036.02	Lethbridge	BASF
1707	Gull Lake	SK	325.95	29.42	24.02	16.33	10.53	6.84	5.34	4.06	1566.94	Lethbridge	BASF
1708	Hafford	SK	325.95	36.86	30.77	20.98	13.55	8.82	6.88	5.22	2031.88	Lethbridge	BASF
1709	Hague	SK	332.71	37.62	31.46	21.46	13.86	9.02	7.04	5.34	2079.41	Lethbridge	BASF
1710	Hamlin	SK	325.95	36.53	30.47	20.77	13.42	8.73	6.81	5.17	2011.22	Lethbridge	BASF
1711	Hanley	SK	325.95	33.91	28.10	19.14	12.36	8.04	6.27	4.76	1847.97	Lethbridge	BASF
1712	Hazenmore	SK	325.95	32.36	26.69	18.17	11.73	7.63	5.95	4.52	1751.11	Lethbridge	BASF
1713	Hazlet	SK	325.95	30.91	25.38	17.27	11.14	7.24	5.65	4.29	1660.48	Lethbridge	BASF
1714	Hepburn	SK	325.95	33.73	28.08	19.15	12.37	8.05	6.27	4.77	1852.36	Lethbridge	BASF
1715	Herbert	SK	325.95	29.45	24.05	16.35	10.55	6.85	5.35	4.06	1569.01	Lethbridge	BASF
1716	Hodgeville	SK	325.95	30.71	25.19	17.14	11.06	7.19	5.61	4.26	1647.53	Lethbridge	BASF
1717	Hoey	SK	357.50	40.10	33.70	23.01	14.87	9.68	7.55	5.73	2234.39	Lethbridge	BASF
1718	Hudson Bay	SK	412.06	45.55	38.65	26.42	17.09	11.13	8.68	6.58	2575.35	Lethbridge	BASF
1719	Humboldt	SK	334.03	37.75	31.58	21.54	13.92	9.06	7.06	5.36	2087.68	Lethbridge	BASF
1720	Imperial	SK	325.95	33.22	27.47	18.71	12.08	7.85	6.13	4.65	1804.58	Lethbridge	BASF
1721	Indian Head	SK	325.95	32.29	26.63	18.13	11.70	7.61	5.94	4.51	1746.72	Lethbridge	BASF
1722	Invermay	SK	350.56	39.40	33.07	22.57	14.59	9.50	7.41	5.62	2191.00	Lethbridge	BASF
1723	Ituna	SK	325.95	34.81	28.91	19.70	12.72	8.28	6.46	4.90	1903.77	Lethbridge	BASF
1724	Kamsack	SK	367.53	41.10	34.61	23.63	15.28	9.95	7.76	5.88	2297.03	Lethbridge	BASF
1725	Kelso	SK	354.53	39.80	33.43	22.82	14.75	9.60	7.49	5.68	2215.79	Lethbridge	BASF
1726	Kelvington	SK	353.20	39.67	33.31	22.74	14.70	9.57	7.46	5.66	2207.53	Lethbridge	BASF
1727	Kerrobert	SK	325.95	32.94	27.21	18.53	11.96	7.78	6.07	4.61	1786.94	Lethbridge	BASF
1728	Kindersley	SK	325.95	30.61	25.10	17.08	11.02	7.16	5.59	4.24	1641.33	Lethbridge	BASF
1729	Kinistino	SK	364.49	40.80	34.34	23.44	15.16	9.87	7.70	5.84	2278.06	Lethbridge	BASF
1730	Kipling	SK	325.95	36.62	30.56	20.84	13.46	8.76	6.83	5.18	2017.42	Lethbridge	BASF
1731	Kisbey	SK	325.95	36.43	30.38	20.71	13.38	8.71	6.79	5.15	2005.02	Lethbridge	BASF
1732	Kronau	SK	325.95	30.34	24.86	16.91	10.91	7.09	5.53	4.20	1624.80	Lethbridge	BASF
1733	Krydor	SK	325.95	35.24	29.30	19.97	12.90	8.39	6.54	4.97	1930.63	Lethbridge	BASF
1734	Kyle	SK	325.95	32.80	27.09	18.45	11.91	7.74	6.04	4.59	1778.51	Lethbridge	BASF
1735	Lafleche	SK	325.95	31.79	26.18	17.82	11.50	7.47	5.83	4.43	1715.28	Lethbridge	BASF
1736	Lajord	SK	325.95	30.81	25.28	17.20	11.10	7.21	5.63	4.28	1653.73	Lethbridge	BASF
1737	Lake Alma	SK	325.95	35.83	29.84	20.34	13.14	8.55	6.67	5.06	1967.82	Lethbridge	BASF
1738	Lake Lenore	SK	346.26	38.97	32.68	22.30	14.41	9.38	7.32	5.55	2164.13	Lethbridge	BASF
1739	Lampman	SK	336.16	37.96	31.77	21.67	14.00	9.11	7.11	5.39	2101.01	Lethbridge	BASF
1740	Landis	SK	325.95	33.52	27.74	18.89	12.20	7.93	6.19	4.70	1823.18	Lethbridge	BASF
1741	Langbank	SK	342.23	38.57	32.32	22.05	14.25	9.28	7.23	5.49	2138.95	Lethbridge	BASF
1742	Langenburg	SK	352.01	39.55	33.20	22.66	14.65	9.54	7.44	5.64	2200.08	Lethbridge	BASF
1743	Langham	SK	325.95	36.26	30.23	20.61	13.31	8.66	6.76	5.13	1994.69	Lethbridge	BASF
1744	Lanigan	SK	327.42	37.09	30.98	21.13	13.65	8.88	6.93	5.26	2046.35	Lethbridge	BASF
1745	Lashburn	SK	325.95	31.57	25.97	17.68	11.41	7.42	5.79	4.39	1701.26	Lethbridge	BASF
1746	Leader	SK	325.95	31.79	26.18	17.82	11.50	7.47	5.83	4.43	1715.28	Lethbridge	BASF
1747	Leask	SK	337.00	38.05	31.84	21.73	14.04	9.14	7.13	5.41	2106.27	Lethbridge	BASF
1748	Lemberg	SK	325.95	34.41	28.55	19.45	12.56	8.17	6.37	4.84	1878.97	Lethbridge	BASF
1749	Leoville	SK	355.19	39.86	33.49	22.86	14.78	9.62	7.50	5.69	2219.93	Lethbridge	BASF
1750	Leross	SK	325.95	34.94	29.03	19.78	12.78	8.31	6.48	4.92	1912.03	Lethbridge	BASF
1751	Leroy	SK	326.75	37.02	30.92	21.08	13.62	8.86	6.91	5.25	2042.22	Lethbridge	BASF
1752	Lestock	SK	325.95	35.24	29.30	19.97	12.90	8.39	6.54	4.97	1930.63	Lethbridge	BASF
1753	Lewvan	SK	325.95	32.13	26.48	18.03	11.63	7.56	5.90	4.48	1736.39	Lethbridge	BASF
1754	Liberty	SK	325.95	32.29	26.63	18.13	11.70	7.61	5.94	4.51	1746.72	Lethbridge	BASF
1755	Limerick	SK	325.95	31.99	26.36	17.94	11.58	7.53	5.87	4.46	1727.93	Lethbridge	BASF
1756	Lintlaw	SK	361.80	40.53	34.09	23.28	15.05	9.80	7.64	5.79	2261.26	Lethbridge	BASF
1757	Lipton	SK	325.95	33.05	27.32	18.61	12.01	7.81	6.09	4.63	1794.25	Lethbridge	BASF
1758	Lloydminsters	SK	325.95	30.31	24.83	16.89	10.90	7.08	5.53	4.20	1622.73	Lethbridge	BASF
1759	Loreburn	SK	325.95	32.29	26.63	18.13	11.70	7.61	5.94	4.51	1746.72	Lethbridge	BASF
1760	Lucky Lake	SK	325.95	33.54	27.76	18.91	12.21	7.94	6.19	4.70	1824.89	Lethbridge	BASF
1761	Lumsden	SK	325.95	30.67	25.16	17.12	11.04	7.18	5.60	4.25	1645.46	Lethbridge	BASF
1762	Luseland	SK	325.95	33.31	27.55	18.76	12.11	7.88	6.15	4.67	1810.13	Lethbridge	BASF
1764	Macoun	SK	325.95	36.28	30.24	20.62	13.32	8.67	6.76	5.13	1995.62	Lethbridge	BASF
1765	Maidstone	SK	325.95	32.52	26.84	18.27	11.80	7.67	5.98	4.54	1761.18	Lethbridge	BASF
1766	Major	SK	325.95	31.80	26.18	17.82	11.50	7.48	5.83	4.43	1715.72	Lethbridge	BASF
1767	Mankota	SK	325.95	33.68	27.89	19.00	12.26	7.98	6.22	4.72	1833.32	Lethbridge	BASF
1768	Maple Creek	SK	325.95	29.85	24.41	16.60	10.71	6.96	5.43	4.13	1593.80	Lethbridge	BASF
1769	Marengo	SK	325.95	29.62	24.20	16.46	10.61	6.90	5.38	4.09	1579.34	Lethbridge	BASF
1770	Marsden	SK	325.95	31.01	25.47	17.33	11.18	7.27	5.67	4.31	1666.80	Lethbridge	BASF
1771	Marshall	SK	325.95	31.04	25.49	17.34	11.19	7.27	5.68	4.31	1668.19	Lethbridge	BASF
1772	Maryfield	SK	359.49	40.29	33.88	23.13	14.95	9.73	7.59	5.76	2246.79	Lethbridge	BASF
1773	Maymont	SK	325.95	36.26	30.23	20.61	13.31	8.66	6.76	5.13	1994.69	Lethbridge	BASF
1774	McLean	SK	325.95	31.14	25.58	17.41	11.23	7.30	5.70	4.33	1674.39	Lethbridge	BASF
1775	Meadow Lake	SK	342.57	38.60	32.35	22.07	14.26	9.28	7.24	5.49	2141.06	Lethbridge	BASF
1776	Meath Park	SK	373.04	41.65	35.11	23.98	15.50	10.09	7.87	5.97	2331.51	Lethbridge	BASF
1777	Medstead	SK	342.57	38.60	32.35	22.07	14.26	9.28	7.24	5.49	2141.06	Lethbridge	BASF
1778	Melfort	SK	359.82	40.33	33.91	23.15	14.97	9.74	7.60	5.76	2248.86	Lethbridge	BASF
1779	Melville	SK	325.95	35.47	29.51	20.11	12.99	8.45	6.59	5.00	1945.09	Lethbridge	BASF
1780	Meota	SK	331.38	37.48	31.34	21.37	13.81	8.99	7.01	5.32	2071.15	Lethbridge	BASF
1781	Mervin	SK	325.95	35.94	29.93	20.41	13.18	8.58	6.69	5.08	1974.54	Lethbridge	BASF
1782	Midale	SK	325.95	35.04	29.12	19.85	12.82	8.34	6.50	4.94	1918.23	Lethbridge	BASF
1783	Middle Lake	SK	349.57	39.30	32.98	22.51	14.55	9.47	7.39	5.60	2184.80	Lethbridge	BASF
1784	Milden	SK	325.95	30.67	25.16	17.12	11.04	7.18	5.60	4.25	1645.46	Lethbridge	BASF
1785	Milestone	SK	325.95	30.94	25.40	17.28	11.15	7.25	5.66	4.30	1662.00	Lethbridge	BASF
1786	Montmartre	SK	325.95	33.15	27.41	18.67	12.05	7.84	6.11	4.64	1800.45	Lethbridge	BASF
1787	Moose Jaw	SK	325.95	29.48	24.08	16.37	10.56	6.86	5.35	4.07	1571.07	Lethbridge	BASF
1788	Moosomin	SK	341.96	38.54	32.29	22.04	14.24	9.27	7.23	5.48	2137.27	Lethbridge	BASF
1789	Morse	SK	325.95	29.48	24.08	16.37	10.56	6.86	5.35	4.07	1571.07	Lethbridge	BASF
1790	Mossbank	SK	325.95	30.97	25.43	17.30	11.16	7.26	5.66	4.30	1664.06	Lethbridge	BASF
1791	Naicam	SK	343.95	38.74	32.47	22.16	14.32	9.32	7.27	5.52	2149.67	Lethbridge	BASF
1792	Neilburg	SK	325.95	31.55	25.96	17.67	11.40	7.41	5.78	4.39	1700.52	Lethbridge	BASF
1793	Neville	SK	325.95	31.04	25.49	17.34	11.19	7.27	5.68	4.31	1668.19	Lethbridge	BASF
1794	Nipawin	SK	391.13	43.46	36.75	25.11	16.24	10.57	8.25	6.25	2444.58	Lethbridge	BASF
1795	Nokomis	SK	325.95	34.76	28.86	19.67	12.70	8.26	6.45	4.89	1900.77	Lethbridge	BASF
1796	Norquay	SK	368.08	41.15	34.66	23.67	15.30	9.96	7.77	5.89	2300.52	Lethbridge	BASF
1797	North Battleford	SK	325.95	36.06	30.05	20.49	13.23	8.61	6.72	5.10	1982.29	Lethbridge	BASF
1798	Odessa	SK	325.95	32.10	26.45	18.01	11.62	7.56	5.89	4.48	1734.32	Lethbridge	BASF
1799	Ogema	SK	325.95	32.06	26.42	17.99	11.61	7.55	5.89	4.47	1732.25	Lethbridge	BASF
1800	Osler	SK	326.09	36.96	30.86	21.04	13.60	8.85	6.90	5.24	2038.08	Lethbridge	BASF
1801	Ounger	SK	325.95	35.86	29.87	20.36	13.15	8.56	6.67	5.07	1969.89	Lethbridge	BASF
1802	Outlook	SK	325.95	30.61	25.10	17.08	11.02	7.16	5.59	4.24	1641.33	Lethbridge	BASF
1803	Oxbow	SK	355.05	39.85	33.48	22.85	14.77	9.62	7.50	5.69	2219.05	Lethbridge	BASF
1804	Pangman	SK	325.95	32.59	26.90	18.32	11.82	7.69	6.00	4.55	1765.32	Lethbridge	BASF
1805	Paradise Hill	SK	325.95	33.51	27.73	18.89	12.20	7.93	6.19	4.70	1822.78	Lethbridge	BASF
1806	Parkside	SK	347.91	39.14	32.83	22.41	14.48	9.43	7.35	5.58	2174.47	Lethbridge	BASF
1807	Paynton	SK	325.95	33.68	27.89	19.00	12.27	7.98	6.22	4.73	1833.51	Lethbridge	BASF
1808	Peesane	SK	370.22	41.37	34.86	23.80	15.39	10.02	7.81	5.93	2313.90	Lethbridge	BASF
1809	Pelly	SK	380.68	42.41	35.80	24.46	15.81	10.30	8.03	6.09	2379.24	Lethbridge	BASF
1810	Pense	SK	325.95	29.52	24.11	16.39	10.57	6.87	5.36	4.07	1573.14	Lethbridge	BASF
1811	Perdue	SK	325.95	32.72	27.02	18.40	11.88	7.72	6.02	4.58	1773.58	Lethbridge	BASF
1812	Pilot Butte	SK	325.95	30.24	24.77	16.85	10.87	7.06	5.51	4.19	1618.60	Lethbridge	BASF
1813	Plenty	SK	325.95	31.80	26.18	17.82	11.50	7.48	5.83	4.43	1715.72	Lethbridge	BASF
1814	Ponteix	SK	325.95	32.36	26.69	18.17	11.73	7.63	5.95	4.52	1751.11	Lethbridge	BASF
1815	Porcupine Plain	SK	387.09	43.05	36.38	24.86	16.07	10.47	8.16	6.19	2419.29	Lethbridge	BASF
1816	Prairie River	SK	410.36	45.38	38.49	26.31	17.02	11.08	8.64	6.55	2564.73	Lethbridge	BASF
1817	Prince Albert	SK	356.18	39.96	33.58	22.92	14.82	9.65	7.52	5.71	2226.13	Lethbridge	BASF
1818	Quill Lake	Sk	338.66	38.21	31.99	21.83	14.11	9.18	7.16	5.43	2116.61	Lethbridge	BASF
1819	Rabbit Lake	SK	355.05	39.85	33.48	22.85	14.77	9.62	7.50	5.69	2219.05	Lethbridge	BASF
1820	Radisson	SK	325.95	36.26	30.23	20.61	13.31	8.66	6.76	5.13	1994.69	Lethbridge	BASF
1821	Radville	SK	325.95	34.18	28.34	19.31	12.47	8.11	6.33	4.80	1864.50	Lethbridge	BASF
1822	Rama	SK	362.47	40.59	34.15	23.32	15.07	9.81	7.65	5.80	2265.42	Lethbridge	BASF
1823	Raymore	SK	325.95	33.91	28.10	19.14	12.36	8.04	6.27	4.76	1847.97	Lethbridge	BASF
1824	Redvers	SK	368.74	41.22	34.72	23.71	15.33	9.98	7.78	5.90	2304.65	Lethbridge	BASF
1825	Regina	SK	325.95	23.89	19.01	12.88	8.29	5.37	4.20	3.19	1221.23	Lethbridge	BASF
1826	Rhein	SK	348.98	39.24	32.93	22.47	14.52	9.45	7.37	5.59	2181.11	Lethbridge	BASF
1827	Riceton	SK	325.95	31.24	25.67	17.47	11.27	7.33	5.72	4.34	1680.59	Lethbridge	BASF
1828	Richardson	SK	325.95	29.75	24.32	16.54	10.67	6.93	5.41	4.11	1587.60	Lethbridge	BASF
1829	Ridgedale	SK	391.81	43.53	36.81	25.15	16.26	10.59	8.26	6.26	2448.80	Lethbridge	BASF
1830	Rocanville	SK	351.88	39.53	33.19	22.66	14.64	9.53	7.43	5.64	2199.26	Lethbridge	BASF
1831	Rockhaven	SK	325.95	36.28	30.24	20.62	13.32	8.67	6.76	5.13	1995.62	Lethbridge	BASF
1832	Rose Valley	SK	357.75	40.12	33.72	23.02	14.88	9.69	7.56	5.73	2235.91	Lethbridge	BASF
1833	Rosetown	SK	325.95	30.57	25.07	17.06	11.00	7.15	5.58	4.24	1639.26	Lethbridge	BASF
1834	Rosthern	SK	340.64	38.41	32.17	21.95	14.19	9.23	7.20	5.46	2129.01	Lethbridge	BASF
1835	Rouleau	SK	325.95	30.44	24.95	16.97	10.95	7.12	5.55	4.22	1631.00	Lethbridge	BASF
1836	Rowatt	SK	325.95	29.65	24.23	16.48	10.63	6.91	5.39	4.09	1581.41	Lethbridge	BASF
1837	Saskatoon	SK	325.95	25.32	20.31	13.77	8.87	5.76	4.49	3.42	1310.69	Lethbridge	BASF
1838	Sceptre	Sk	325.95	31.76	26.14	17.79	11.48	7.47	5.82	4.42	1713.17	Lethbridge	BASF
1839	Sedley	SK	325.95	31.37	25.79	17.55	11.33	7.36	5.74	4.36	1688.86	Lethbridge	BASF
1840	Shamrock	SK	325.95	30.51	25.01	17.01	10.98	7.13	5.57	4.23	1635.13	Lethbridge	BASF
1841	Shaunavon	SK	325.95	32.13	26.48	18.03	11.63	7.56	5.90	4.48	1736.36	Lethbridge	BASF
1842	Shellbrook	SK	353.54	39.70	33.34	22.76	14.71	9.58	7.47	5.67	2209.60	Lethbridge	BASF
1843	Simpson	SK	325.95	33.75	27.95	19.04	12.29	7.99	6.24	4.74	1837.64	Lethbridge	BASF
1844	Sintaluta	SK	325.95	33.02	27.29	18.58	12.00	7.80	6.09	4.62	1792.18	Lethbridge	BASF
1845	Southey	SK	325.95	31.80	26.18	17.82	11.50	7.48	5.83	4.43	1715.72	Lethbridge	BASF
1846	Spalding	SK	339.98	38.34	32.11	21.91	14.16	9.22	7.19	5.45	2124.87	Lethbridge	BASF
1847	Speers	SK	326.75	37.02	30.92	21.08	13.62	8.86	6.91	5.25	2042.22	Lethbridge	BASF
1848	Spiritwood	SK	348.64	39.21	32.90	22.45	14.51	9.45	7.37	5.59	2179.00	Lethbridge	BASF
1849	St Brieux	SK	356.51	40.00	33.61	22.94	14.83	9.65	7.53	5.71	2228.19	Lethbridge	BASF
1850	St. Walburg	SK	325.95	33.91	28.10	19.14	12.36	8.04	6.27	4.76	1847.97	Lethbridge	BASF
1851	Star City	SK	366.43	40.99	34.51	23.56	15.23	9.92	7.74	5.87	2290.19	Lethbridge	BASF
1852	Stewart Valley	SK	325.95	31.25	25.69	17.48	11.28	7.33	5.72	4.35	1681.55	Lethbridge	BASF
1853	Stockholm	SK	344.93	38.84	32.56	22.22	14.36	9.35	7.29	5.53	2155.81	Lethbridge	BASF
1854	Stoughton	SK	325.95	35.07	29.15	19.87	12.83	8.35	6.51	4.94	1920.30	Lethbridge	BASF
1855	Strasbourg	SK	325.95	32.62	26.93	18.34	11.84	7.70	6.00	4.56	1767.38	Lethbridge	BASF
1856	Strongfield	SK	325.95	32.72	27.02	18.40	11.88	7.72	6.02	4.58	1773.58	Lethbridge	BASF
1857	Sturgis	SK	371.57	41.50	34.98	23.89	15.44	10.05	7.84	5.95	2322.33	Lethbridge	BASF
1858	Swift Current	SK	325.95	29.48	24.08	16.37	10.56	6.86	5.35	4.07	1571.07	Lethbridge	BASF
1859	Theodore	SK	344.59	38.81	32.53	22.20	14.35	9.34	7.28	5.53	2153.70	Lethbridge	BASF
1860	Tisdale	SK	371.39	41.48	34.96	23.87	15.44	10.05	7.84	5.94	2321.18	Lethbridge	BASF
1861	Tompkins	SK	325.95	29.45	24.05	16.35	10.55	6.85	5.35	4.06	1569.01	Lethbridge	BASF
1862	Torquay	SK	325.95	36.71	30.64	20.89	13.50	8.78	6.85	5.20	2023.02	Lethbridge	BASF
1863	Tribune	SK	325.95	35.77	29.78	20.30	13.11	8.53	6.66	5.05	1964.00	Lethbridge	BASF
1864	Tugaske	SK	325.95	31.49	25.90	17.63	11.37	7.39	5.77	4.38	1696.31	Lethbridge	BASF
1865	Turtleford	SK	325.95	35.53	29.57	20.16	13.02	8.47	6.61	5.01	1949.25	Lethbridge	BASF
1866	Tuxford	SK	325.95	30.18	24.71	16.81	10.84	7.05	5.50	4.18	1614.47	Lethbridge	BASF
1867	Unity	SK	325.95	32.80	27.09	18.45	11.91	7.74	6.04	4.59	1778.51	Lethbridge	BASF
1868	Valparaiso	SK	370.07	41.35	34.84	23.79	15.38	10.01	7.81	5.92	2312.92	Lethbridge	BASF
1869	Vanscoy	SK	325.95	32.10	26.45	18.01	11.62	7.56	5.89	4.48	1734.32	Lethbridge	BASF
1870	Vibank	SK	325.95	31.57	25.97	17.68	11.41	7.42	5.79	4.39	1701.26	Lethbridge	BASF
1871	Viscount	SK	327.42	37.09	30.98	21.13	13.65	8.88	6.93	5.26	2046.35	Lethbridge	BASF
1872	Wadena	SK	335.02	37.85	31.67	21.60	13.96	9.08	7.09	5.38	2093.88	Lethbridge	BASF
1873	Wakaw	SK	347.58	39.10	32.80	22.39	14.47	9.42	7.35	5.57	2172.40	Lethbridge	BASF
1874	Waldheim	SK	336.34	37.98	31.78	21.68	14.01	9.12	7.11	5.40	2102.14	Lethbridge	BASF
1875	Waldron	SK	326.72	37.02	30.91	21.08	13.62	8.86	6.91	5.25	2041.99	Lethbridge	BASF
1876	Wapella	Sk	332.38	37.58	31.43	21.44	13.85	9.01	7.03	5.33	2077.34	Lethbridge	BASF
1877	Watrous	SK	325.95	34.74	28.85	19.66	12.70	8.26	6.44	4.89	1899.63	Lethbridge	BASF
1878	Watson	SK	330.72	37.42	31.28	21.33	13.78	8.97	7.00	5.31	2067.01	Lethbridge	BASF
1879	Wawota	SK	350.56	39.40	33.07	22.57	14.59	9.50	7.41	5.62	2191.00	Lethbridge	BASF
1880	Weyburn	SK	325.95	33.22	27.47	18.71	12.08	7.85	6.13	4.65	1804.58	Lethbridge	BASF
1881	White City	SK	325.95	30.21	24.74	16.83	10.86	7.05	5.50	4.18	1616.53	Lethbridge	BASF
1882	White Star	SK	359.82	40.33	33.91	23.15	14.97	9.74	7.60	5.76	2248.86	Lethbridge	BASF
1883	Whitewood	SK	325.95	36.59	30.53	20.82	13.45	8.75	6.83	5.18	2015.35	Lethbridge	BASF
1884	Wilcox	Sk	325.95	30.48	24.98	16.99	10.96	7.13	5.56	4.22	1633.07	Lethbridge	BASF
1885	Wilkie	SK	325.95	34.49	28.62	19.50	12.59	8.19	6.39	4.85	1883.90	Lethbridge	BASF
1886	Wiseton	SK	325.95	33.15	27.41	18.67	12.05	7.84	6.11	4.64	1800.45	Lethbridge	BASF
1887	Wolseley	SK	325.95	33.58	27.80	18.94	12.23	7.95	6.20	4.71	1827.31	Lethbridge	BASF
1888	Woodrow	SK	325.95	31.82	26.21	17.84	11.51	7.48	5.84	4.43	1717.39	Lethbridge	BASF
1889	Wymark	SK	325.95	30.48	24.98	16.99	10.96	7.13	5.56	4.22	1633.07	Lethbridge	BASF
1890	Wynyard	SK	325.95	36.62	30.56	20.84	13.46	8.76	6.83	5.18	2017.42	Lethbridge	BASF
1891	Yellow Creek	SK	325.95	35.50	29.54	20.13	13.00	8.46	6.60	5.01	1947.16	Lethbridge	BASF
1892	Yellow Grass	SK	325.95	32.33	26.66	18.15	11.71	7.62	5.94	4.51	1748.78	Lethbridge	BASF
1893	Yorkton	SK	326.75	37.02	30.92	21.08	13.62	8.86	6.91	5.25	2042.22	Lethbridge	BASF
1894	Acadia Valley	AB	248.51	24.85	19.95	13.53	8.71	5.66	4.41	3.36	1320.41	Regina	BASF
1895	Airdrie	AB	233.20	21.62	17.03	11.51	7.06	4.80	3.75	2.85	1113.66	Regina	BASF
1896	Alix	AB	257.91	25.79	20.80	14.12	8.76	5.90	4.61	3.51	1380.62	Regina	BASF
1897	Alliance	AB	287.52	28.75	23.49	15.97	9.96	6.69	5.22	3.97	1570.33	Regina	BASF
1898	Amisk	AB	251.83	25.18	20.25	13.74	8.51	5.74	4.48	3.41	1341.63	Regina	BASF
1899	Andrew	AB	233.20	22.68	17.99	12.17	7.49	5.08	3.97	3.02	1181.46	Regina	BASF
1900	Athabasca	AB	266.44	26.64	21.58	14.65	9.10	6.13	4.78	3.64	1435.23	Regina	BASF
1901	Balzac	AB	233.20	21.23	16.67	11.26	6.90	4.69	3.66	2.79	1088.24	Regina	BASF
1902	Barons	AB	233.20	22.73	18.03	12.20	7.51	5.09	3.98	3.03	1184.55	Regina	BASF
1903	Barrhead	AB	265.76	26.58	21.51	14.61	9.07	6.11	4.77	3.63	1430.91	Regina	BASF
1904	Bashaw	AB	253.61	25.36	20.41	13.85	8.58	5.79	4.52	3.44	1353.07	Regina	BASF
1905	Bassano	AB	233.20	20.57	16.07	10.85	6.63	4.52	3.53	2.69	1045.86	Regina	BASF
1906	Bay Tree	AB	317.44	31.74	26.20	17.84	11.17	7.49	5.84	4.44	1761.98	Regina	BASF
1907	Beaverlodge	AB	520.25	52.02	44.58	30.51	19.41	12.87	10.04	7.60	3061.21	Regina	BASF
1908	Beiseker	AB	233.20	22.15	17.51	11.84	7.28	4.94	3.86	2.94	1147.56	Regina	BASF
1909	Benalto	AB	276.43	27.64	22.48	15.27	9.51	6.40	4.99	3.79	1499.26	Regina	BASF
1910	Bentley	AB	273.12	27.31	22.18	15.07	9.37	6.31	4.92	3.74	1478.07	Regina	BASF
1911	Blackfalds	AB	266.84	26.68	21.61	14.67	9.12	6.14	4.79	3.64	1437.82	Regina	BASF
1912	Blackie	AB	233.20	21.56	16.97	11.47	7.04	4.78	3.73	2.84	1109.43	Regina	BASF
1913	Bon Accord	AB	212.00	18.24	16.53	11.40	7.41	4.85	3.92	2.85	1168.75	Regina	BASF
1914	Bonnyville	AB	270.60	27.06	21.95	14.91	9.27	6.24	4.87	3.70	1461.87	Regina	BASF
1915	Bow Island	AB	249.25	24.92	20.02	13.57	8.40	5.67	4.43	3.37	1325.13	Regina	BASF
1916	Boyle	AB	257.33	25.73	20.75	14.08	8.73	5.89	4.60	3.50	1376.89	Regina	BASF
1917	Brooks	AB	233.20	20.66	16.16	10.91	6.67	4.54	3.55	2.70	1052.22	Regina	BASF
1918	Burdett	AB	245.20	24.52	19.65	13.32	8.24	5.57	4.35	3.31	1299.19	Regina	BASF
1919	CALGARY	AB	233.20	17.28	13.09	8.80	5.30	3.64	2.85	2.18	788.22	Regina	BASF
1920	Calmar	AB	233.20	23.28	18.52	12.55	7.73	5.24	4.09	3.11	1219.60	Regina	BASF
1921	Camrose	AB	233.20	23.15	18.40	12.46	7.68	5.20	4.06	3.09	1211.12	Regina	BASF
1922	Carbon	AB	233.20	23.05	18.32	12.40	7.64	5.18	4.04	3.08	1204.77	Regina	BASF
1923	Cardston	AB	221.20	22.12	20.05	13.83	8.99	5.88	4.73	3.46	1417.08	Regina	BASF
1924	Carseland	AB	233.20	21.46	16.88	11.41	7.00	4.75	3.71	2.83	1103.07	Regina	BASF
1925	Carstairs	AB	233.20	23.01	18.29	12.38	7.63	5.17	4.03	3.07	1202.65	Regina	BASF
1926	Castor	AB	276.48	27.65	22.49	15.28	9.51	6.40	4.99	3.80	1499.60	Regina	BASF
1927	Clandonald	AB	212.00	18.24	16.53	11.40	7.41	4.85	3.92	2.85	1168.75	Regina	BASF
1928	Claresholm	AB	233.20	22.35	17.69	11.97	7.36	4.99	3.90	2.97	1160.27	Regina	BASF
1929	Clyde	AB	200.63	20.06	18.18	12.54	8.15	5.33	4.30	3.13	1285.28	Regina	BASF
1930	Coaldale	AB	233.20	22.70	18.00	12.18	7.50	5.08	3.97	3.02	1182.39	Regina	BASF
1931	Cochrane	AB	212.00	17.71	16.05	11.07	7.20	4.71	3.81	2.77	1134.85	Regina	BASF
1932	Consort	AB	268.39	26.84	21.75	14.77	9.18	6.18	4.83	3.67	1447.73	Regina	BASF
1933	Coronation	AB	259.55	25.96	20.95	14.22	8.82	5.95	4.64	3.53	1391.14	Regina	BASF
1934	Cremona	AB	214.55	19.34	17.52	12.08	7.85	5.14	4.15	3.02	1238.66	Regina	BASF
1935	Crossfield	AB	233.20	22.29	17.63	11.93	7.33	4.97	3.88	2.96	1156.04	Regina	BASF
1936	Cypress County	AB	233.20	22.35	17.68	11.96	7.36	4.99	3.90	2.97	1160.09	Regina	BASF
1937	Czar	AB	258.08	25.81	20.82	14.13	8.76	5.91	4.61	3.51	1381.71	Regina	BASF
1938	Daysland	AB	236.08	23.61	18.82	12.75	7.87	5.32	4.16	3.16	1240.78	Regina	BASF
1939	Debolt	AB	448.98	42.78	38.77	26.74	17.38	11.36	9.00	6.68	2740.48	Regina	BASF
1940	Delburne	AB	258.57	25.86	20.86	14.16	8.78	5.92	4.62	3.52	1384.85	Regina	BASF
1941	Delia	AB	241.04	24.10	19.27	13.06	8.07	5.46	4.26	3.24	1272.56	Regina	BASF
1942	Dewberry	AB	244.83	24.48	19.62	13.30	8.22	5.56	4.34	3.30	1296.84	Regina	BASF
1943	Dickson	AB	266.51	26.65	21.58	14.65	9.10	6.13	4.79	3.64	1435.70	Regina	BASF
1944	Didsbury	AB	236.74	23.67	18.88	12.79	7.90	5.34	4.17	3.17	1245.02	Regina	BASF
1945	Drayton Valley	AB	271.47	27.15	22.03	14.96	9.31	6.26	4.89	3.72	1467.48	Regina	BASF
1946	Drumheller	AB	233.20	22.48	17.81	12.05	7.41	5.03	3.92	2.99	1168.75	Regina	BASF
1947	Dunmore	AB	233.20	22.31	17.65	11.94	7.34	4.98	3.89	2.96	1157.73	Regina	BASF
1948	Eaglesham	AB	510.65	51.07	43.71	29.91	19.02	12.62	9.84	7.45	2999.74	Regina	BASF
1949	Eckville	AB	281.39	28.14	22.93	15.58	9.71	6.53	5.09	3.87	1531.04	Regina	BASF
1950	Edberg	AB	242.37	24.24	19.39	13.14	8.12	5.49	4.29	3.26	1281.04	Regina	BASF
1951	Edgerton	AB	244.10	24.41	19.55	13.25	8.19	5.54	4.32	3.29	1292.12	Regina	BASF
1952	EDMONTON	AB	233.20	18.30	14.01	9.43	5.71	3.91	3.06	2.33	849.72	Regina	BASF
1953	Enchant	AB	255.14	25.51	20.55	13.94	8.64	5.83	4.55	3.46	1362.85	Regina	BASF
1954	Ervick	AB	212.00	18.87	17.10	11.80	7.67	5.01	4.05	2.95	1209.00	Regina	BASF
1955	Evansburg	AB	255.93	25.59	20.62	13.99	8.67	5.85	4.57	3.47	1367.90	Regina	BASF
1956	Fairview	AB	551.96	55.20	47.45	32.49	20.70	13.72	10.69	8.10	3264.35	Regina	BASF
1957	Falher	AB	484.78	48.48	41.36	28.30	17.97	11.93	9.30	7.05	2673.61	Regina	BASF
1958	Foremost	AB	255.87	25.59	20.62	13.99	8.67	5.85	4.57	3.47	1367.57	Regina	BASF
1959	Forestburg	AB	248.32	24.83	19.93	13.52	8.37	5.65	4.41	3.36	1244.50	Regina	BASF
1960	Fort MacLeod	AB	233.20	22.55	17.87	12.09	7.44	5.04	3.94	3.00	1172.99	Regina	BASF
1961	Fort Saskatchewan	AB	233.20	21.79	17.18	11.61	7.13	4.84	3.78	2.88	1124.26	Regina	BASF
1962	Fort Vermilion	AB	485.93	49.08	41.88	28.65	18.54	12.08	9.42	7.13	2841.32	Regina	BASF
1963	Galahad	AB	276.85	27.69	22.52	15.30	9.52	6.41	5.00	3.80	1501.96	Regina	BASF
1964	Girouxville	AB	490.63	49.06	41.89	28.66	18.21	12.09	9.42	7.14	2871.45	Regina	BASF
1965	Gleichen	AB	233.20	20.63	16.13	10.89	6.66	4.53	3.54	2.70	1050.10	Regina	BASF
1966	Glendon	AB	265.07	26.51	21.45	14.56	9.05	6.09	4.76	3.62	1426.51	Regina	BASF
1967	Grande Prairie	AB	498.55	49.86	42.61	29.16	18.53	12.30	9.59	7.27	2922.23	Regina	BASF
1968	Grassy Lake	AB	245.20	24.52	19.65	13.32	8.24	5.57	4.35	3.31	1299.19	Regina	BASF
1969	Grimshaw	AB	526.92	52.69	45.18	30.93	19.68	13.05	10.18	7.71	3103.98	Regina	BASF
1970	Guy	AB	471.85	47.19	40.19	27.49	17.45	11.59	9.04	6.85	2751.17	Regina	BASF
1971	Hairy Hill	AB	233.20	22.52	17.84	12.07	7.43	5.04	3.93	2.99	1170.87	Regina	BASF
1972	Halkirk	AB	275.38	27.54	22.39	15.21	9.46	6.37	4.97	3.78	1492.53	Regina	BASF
1973	Hanna	AB	261.39	26.14	21.12	14.33	8.90	6.00	4.68	3.56	1402.93	Regina	BASF
1974	High Level	AB	665.02	66.50	57.70	39.56	25.29	16.72	13.03	9.87	3988.67	Regina	BASF
1975	High Prairie	AB	444.73	44.47	37.73	25.79	16.34	10.87	8.47	6.42	2577.44	Regina	BASF
1976	High River	AB	233.20	21.86	17.24	11.66	7.16	4.86	3.79	2.89	1128.49	Regina	BASF
1977	Hines Creek	AB	560.30	56.03	48.21	33.02	21.04	13.94	10.87	8.23	3317.80	Regina	BASF
1978	Holden	AB	233.20	21.13	16.58	11.20	6.86	4.67	3.64	2.78	1081.88	Regina	BASF
1979	Hussar	AB	233.20	20.70	16.19	10.93	6.69	4.55	3.55	2.71	1054.34	Regina	BASF
1980	Hythe	AB	529.84	52.98	45.45	31.11	19.80	13.13	10.24	7.75	3122.69	Regina	BASF
1981	Innisfail	AB	253.28	25.33	20.38	13.83	8.57	5.78	4.51	3.43	1350.95	Regina	BASF
1982	Innisfree	AB	233.20	21.29	16.73	11.30	6.93	4.71	3.68	2.80	1092.48	Regina	BASF
1983	Irma	AB	236.74	23.67	18.88	12.79	7.89	5.34	4.17	3.17	1244.97	Regina	BASF
1984	Iron Springs	AB	247.78	24.78	19.88	13.48	8.34	5.64	4.40	3.35	1315.70	Regina	BASF
1985	Killam	AB	243.69	24.37	19.51	13.23	8.18	5.53	4.31	3.28	1289.51	Regina	BASF
1986	Kirriemuir	AB	213.11	21.31	19.31	13.32	8.66	5.66	4.56	3.33	1365.21	Regina	BASF
1987	Kitscoty	AB	233.20	23.20	18.45	12.49	7.70	5.22	4.07	3.10	1214.32	Regina	BASF
1988	La Glace	AB	518.16	51.82	44.39	30.38	19.33	12.82	9.99	7.57	3047.85	Regina	BASF
1989	Lac La Biche	AB	271.48	25.03	22.68	15.64	10.17	6.65	5.33	3.91	1603.34	Regina	BASF
1990	Lacombe	AB	265.85	26.58	21.52	14.61	9.08	6.12	4.77	3.63	1431.46	Regina	BASF
1991	LaCrete	AB	614.12	61.41	53.08	36.38	23.23	15.37	11.98	9.07	3662.59	Regina	BASF
1992	Lamont	AB	233.20	21.66	17.06	11.53	7.08	4.81	3.75	2.86	1115.78	Regina	BASF
1993	Lavoy	AB	233.20	21.33	16.76	11.33	6.94	4.72	3.68	2.81	1094.59	Regina	BASF
1994	Leduc	AB	233.20	22.68	17.99	12.17	7.49	5.08	3.97	3.02	1181.46	Regina	BASF
1995	Legal	AB	234.10	23.41	18.64	12.63	7.79	5.27	4.12	3.13	1228.07	Regina	BASF
1996	Lethbridge	AB	242.62	24.26	19.42	13.16	8.13	5.50	4.29	3.27	1210.08	Regina	BASF
1997	Linden	AB	233.20	23.11	18.37	12.44	7.67	5.19	4.05	3.09	1209.00	Regina	BASF
1998	Lloydminster	AB	233.20	23.12	18.38	12.45	7.67	5.20	4.06	3.09	1209.60	Regina	BASF
1999	Lomond	AB	190.80	17.78	16.11	11.11	7.22	4.72	3.83	2.78	1139.09	Regina	BASF
2000	Lougheed	AB	260.66	26.07	21.05	14.29	8.87	5.98	4.67	3.55	1398.22	Regina	BASF
2001	Magrath	AB	256.98	25.70	20.72	14.06	8.72	5.88	4.59	3.49	1374.64	Regina	BASF
2002	Mallaig	AB	198.64	19.86	18.00	12.42	8.07	5.28	4.26	3.10	1272.56	Regina	BASF
2003	Manning	AB	564.89	56.49	48.62	33.30	21.23	14.06	10.96	8.30	3347.20	Regina	BASF
2004	Marwayne	AB	240.42	24.04	19.22	13.02	8.04	5.44	4.25	3.23	1268.54	Regina	BASF
2005	Mayerthorpe	AB	277.23	27.72	22.55	15.32	9.54	6.42	5.01	3.81	1504.39	Regina	BASF
2006	McLennan	AB	470.18	47.02	40.04	27.38	17.38	11.54	9.00	6.82	2740.48	Regina	BASF
2007	Medicine Hat	AB	233.20	22.35	17.68	11.96	7.36	4.99	3.90	2.97	1160.09	Regina	BASF
2008	Milk River	AB	268.39	26.84	21.75	14.77	9.18	6.18	4.83	3.67	1447.73	Regina	BASF
2009	Milo	AB	233.20	22.12	17.48	11.82	7.26	4.93	3.85	2.93	1145.44	Regina	BASF
2010	Morinville	AB	233.20	22.52	17.84	12.07	7.43	5.04	3.93	2.99	1170.87	Regina	BASF
2011	Mossleigh	AB	233.20	21.33	16.76	11.33	6.94	4.72	3.68	2.81	1094.59	Regina	BASF
2012	Mundare	AB	233.20	21.36	16.79	11.35	6.95	4.73	3.69	2.81	1096.71	Regina	BASF
2013	Myrnam	AB	233.20	22.29	17.63	11.93	7.33	4.97	3.88	2.96	1156.04	Regina	BASF
2014	Nampa	AB	499.80	49.98	42.72	29.23	18.58	12.33	9.61	7.28	2930.25	Regina	BASF
2015	Nanton	AB	233.20	22.85	18.14	12.28	7.56	5.12	4.00	3.05	1192.05	Regina	BASF
2016	Neerlandia	AB	274.87	27.49	22.34	15.18	9.44	6.36	4.96	3.77	1489.26	Regina	BASF
2017	New Dayton	AB	256.98	25.70	20.72	14.06	8.72	5.88	4.59	3.49	1374.64	Regina	BASF
2018	New Norway	AB	238.40	23.84	19.03	12.90	7.96	5.39	4.20	3.20	1255.61	Regina	BASF
2019	Nisku	AB	190.80	17.98	16.29	11.24	7.30	4.78	3.87	2.81	1151.80	Regina	BASF
2020	Nobleford	AB	233.20	22.35	17.69	11.97	7.36	4.99	3.90	2.97	1160.27	Regina	BASF
2021	Okotoks	AB	233.20	22.19	17.54	11.86	7.29	4.95	3.86	2.94	1149.68	Regina	BASF
2022	Olds	AB	243.36	24.34	19.48	13.21	8.16	5.52	4.31	3.28	1287.39	Regina	BASF
2023	Onoway	AB	217.20	19.60	17.76	12.25	7.96	5.21	4.20	3.06	1255.61	Regina	BASF
2024	Oyen	AB	245.57	24.56	19.68	13.34	8.25	5.58	4.35	3.31	1301.55	Regina	BASF
2025	Paradise Valley	AB	244.10	24.41	19.55	13.25	8.19	5.54	4.32	3.29	1292.12	Regina	BASF
2026	Peers	AB	264.49	24.33	22.05	15.21	9.88	6.46	5.18	3.80	1558.58	Regina	BASF
2027	Penhold	AB	257.91	25.79	20.80	14.12	8.76	5.90	4.61	3.51	1380.62	Regina	BASF
2028	Picture Butte	AB	243.73	24.37	19.52	13.23	8.18	5.53	4.31	3.28	1289.76	Regina	BASF
2029	Pincher Creek	AB	267.28	26.73	21.65	14.70	9.14	6.15	4.80	3.65	1440.66	Regina	BASF
2030	Ponoka	AB	267.50	26.75	21.67	14.72	9.14	6.16	4.81	3.66	1442.06	Regina	BASF
2031	Provost	AB	256.61	25.66	20.68	14.03	8.70	5.87	4.58	3.48	1372.28	Regina	BASF
2032	Raymond	AB	210.90	21.09	19.11	13.18	8.57	5.60	4.51	3.30	1351.06	Regina	BASF
2033	Red Deer	AB	265.19	26.52	21.46	14.57	9.05	6.10	4.76	3.62	1427.23	Regina	BASF
2034	Rimbey	AB	276.76	27.68	22.51	15.29	9.52	6.41	5.00	3.80	1501.38	Regina	BASF
2035	Rivercourse	AB	203.17	20.32	18.41	12.70	8.25	5.40	4.35	3.17	1301.55	Regina	BASF
2036	Rocky Mountain House	AB	281.19	28.12	25.48	17.57	11.42	7.47	5.97	4.39	1801.38	Regina	BASF
2037	Rocky View	AB	233.20	21.29	16.73	11.30	6.93	4.71	3.68	2.80	1030.64	Regina	BASF
2038	Rolling Hills	AB	237.84	23.78	18.98	12.86	7.94	5.37	4.19	3.19	1252.04	Regina	BASF
2039	Rosalind	AB	240.05	24.01	19.18	13.00	8.03	5.43	4.24	3.23	1266.21	Regina	BASF
2040	Rosebud	AB	233.20	22.09	17.45	11.80	7.25	4.92	3.84	2.93	1143.32	Regina	BASF
2041	Rosedale	AB	233.20	22.48	17.81	12.05	7.41	5.03	3.92	2.99	1168.75	Regina	BASF
2042	Rycroft	AB	529.43	52.94	45.41	31.09	19.79	13.12	10.23	7.75	3120.02	Regina	BASF
2043	Ryley	AB	233.20	21.92	17.30	11.70	7.18	4.88	3.81	2.90	1132.73	Regina	BASF
2044	Scandia	AB	233.20	21.83	17.20	11.64	7.14	4.85	3.78	2.88	1126.37	Regina	BASF
2045	Sedgewick	AB	262.87	26.29	21.25	14.43	8.96	6.04	4.71	3.58	1412.36	Regina	BASF
2046	Sexsmith	AB	503.98	50.40	43.10	29.50	18.75	12.44	9.70	7.35	2956.97	Regina	BASF
2047	Silver Valley	AB	553.63	55.36	47.60	32.60	20.77	13.76	10.73	8.13	3275.04	Regina	BASF
2048	Slave Lake	AB	323.00	30.18	27.35	18.86	12.26	8.02	6.39	4.72	1933.42	Regina	BASF
2049	Smoky Lake	AB	233.77	23.38	18.61	12.61	7.77	5.26	4.11	3.13	1225.95	Regina	BASF
2050	Spirit River	AB	533.60	53.36	45.79	31.35	19.95	13.23	10.31	7.81	3146.74	Regina	BASF
2051	Spruce Grove	AB	233.20	22.45	17.78	12.03	7.40	5.02	3.92	2.98	1166.63	Regina	BASF
2052	Spruce View	AB	223.45	22.34	20.25	13.97	9.08	5.94	4.77	3.49	1431.46	Regina	BASF
2053	St Albert	AB	233.20	21.76	17.15	11.59	7.12	4.83	3.77	2.87	1122.14	Regina	BASF
2054	St Isidore	AB	508.57	50.86	43.52	29.78	18.94	12.56	9.80	7.42	2986.38	Regina	BASF
2055	St Paul	AB	257.71	25.77	20.78	14.10	8.75	5.90	4.60	3.50	1379.36	Regina	BASF
2056	Standard	AB	233.20	21.19	16.64	11.24	6.89	4.68	3.66	2.79	1086.12	Regina	BASF
2057	Stettler	AB	252.29	25.23	20.29	13.76	8.53	5.76	4.49	3.42	1344.60	Regina	BASF
2058	Stirling	AB	251.09	25.11	20.18	13.69	8.48	5.72	4.47	3.40	1336.92	Regina	BASF
2059	Stony Plain	AB	233.20	22.72	18.02	12.19	7.51	5.09	3.97	3.02	1183.58	Regina	BASF
2060	Strathmore	AB	233.20	20.60	16.10	10.87	6.65	4.53	3.53	2.69	1047.98	Regina	BASF
2061	Strome	AB	238.40	23.84	19.03	12.90	7.96	5.39	4.20	3.20	1255.61	Regina	BASF
2062	Sturgeon County	AB	254.77	25.48	20.52	13.92	8.63	5.82	4.54	3.46	1360.49	Regina	BASF
2063	Sturgeon Valley	AB	393.84	39.38	33.12	22.61	14.28	9.52	7.42	5.63	2251.39	Regina	BASF
2064	Sunnybrook	AB	223.48	20.23	18.33	12.64	8.22	5.37	4.33	3.16	1295.87	Regina	BASF
2065	Sylvan Lake	AB	272.79	27.28	22.15	15.05	9.36	6.30	4.92	3.74	1475.96	Regina	BASF
2066	Taber	AB	245.57	24.56	19.68	13.34	8.25	5.58	4.35	3.31	1227.88	Regina	BASF
2067	Thorhild	AB	234.10	23.41	18.64	12.63	7.79	5.27	4.12	3.13	1228.07	Regina	BASF
2068	Three Hills	AB	237.08	23.71	18.91	12.81	7.91	5.35	4.18	3.18	1176.55	Regina	BASF
2069	Tofield	AB	212.00	17.68	16.02	11.05	7.18	4.70	3.81	2.76	1132.73	Regina	BASF
2070	Torrington	AB	241.04	24.10	19.27	13.06	8.07	5.46	4.26	3.24	1272.56	Regina	BASF
2071	Trochu	AB	242.37	24.24	19.39	13.14	8.12	5.49	4.29	3.26	1281.04	Regina	BASF
2072	Turin	AB	233.20	22.58	17.90	12.11	7.45	5.05	3.94	3.00	1175.10	Regina	BASF
2073	Two Hills	AB	233.20	22.45	17.78	12.03	7.40	5.02	3.92	2.98	1166.63	Regina	BASF
2074	Valleyview	AB	441.81	44.18	37.47	25.61	16.23	10.79	8.41	6.38	2558.73	Regina	BASF
2075	Vauxhall	AB	238.58	23.86	19.05	12.91	7.97	5.39	4.21	3.20	1256.75	Regina	BASF
2076	Vegreville	AB	233.20	21.29	16.73	11.30	6.93	4.71	3.68	2.80	1092.48	Regina	BASF
2077	Vermilion	AB	233.20	21.29	16.73	11.30	6.93	4.71	3.68	2.80	1030.64	Regina	BASF
2078	Veteran	AB	217.15	21.72	19.68	13.57	8.82	5.77	4.64	3.39	1391.14	Regina	BASF
2079	Viking	AB	233.20	22.85	18.14	12.28	7.56	5.12	4.00	3.05	1192.05	Regina	BASF
2080	Vulcan	AB	233.20	22.02	17.39	11.76	7.22	4.90	3.83	2.92	1139.09	Regina	BASF
2081	Wainwright	AB	240.78	24.08	19.25	13.05	8.06	5.45	4.25	3.24	1270.90	Regina	BASF
2082	Wanham	AB	511.90	51.19	43.82	29.99	19.07	12.65	9.86	7.47	3007.76	Regina	BASF
2083	Warburg	AB	248.65	24.87	19.96	13.54	8.38	5.66	4.42	3.36	1321.29	Regina	BASF
2084	Warner	AB	259.55	25.96	20.95	14.22	8.82	5.95	4.64	3.53	1391.14	Regina	BASF
2085	Waskatenau	AB	234.39	23.44	18.67	12.65	7.80	5.28	4.12	3.14	1229.94	Regina	BASF
2086	Wembley	AB	452.35	45.69	38.96	26.65	17.24	11.23	8.76	6.64	2641.63	Regina	BASF
2087	Westlock	AB	246.34	24.63	19.75	13.39	8.28	5.60	4.37	3.32	1306.46	Regina	BASF
2088	Wetaskiwin	AB	241.37	24.14	19.30	13.08	8.08	5.47	4.27	3.25	1274.68	Regina	BASF
2089	Whitecourt	AB	297.98	27.68	25.08	17.30	11.24	7.35	5.88	4.32	1773.09	Regina	BASF
2090	Winfield	AB	240.35	21.91	19.86	13.70	8.90	5.82	4.68	3.42	1403.92	Regina	BASF
2091	Dawson Creek	BC	567.81	56.78	48.89	33.48	21.34	14.14	11.02	8.35	3365.91	Regina	BASF
2092	Fort St. John	BC	588.33	56.71	51.40	35.45	23.04	15.06	11.89	8.86	3633.19	Regina	BASF
2093	Rolla	BC	551.62	53.04	48.07	33.15	21.55	14.09	11.13	8.29	3397.99	Regina	BASF
2094	Altamont	MB	233.20	18.19	13.92	9.37	5.67	3.89	3.04	2.32	893.97	Regina	BASF
2095	Altona	MB	233.20	19.63	15.22	10.27	6.25	4.27	3.33	2.54	985.93	Regina	BASF
2096	Angusville	MB	233.20	18.04	13.78	9.27	5.61	3.85	3.00	2.29	834.19	Regina	BASF
2097	Arborg	MB	233.20	21.13	16.58	11.20	6.86	4.67	3.64	2.78	1082.05	Regina	BASF
2098	Arnaud	MB	233.20	19.57	15.16	10.23	6.23	4.25	3.32	2.53	981.94	Regina	BASF
2099	Austin	MB	233.20	16.38	12.28	8.24	4.93	3.41	2.66	2.04	778.02	Regina	BASF
2100	Baldur	MB	233.20	20.14	15.68	10.58	6.46	4.40	3.44	2.62	1018.63	Regina	BASF
2101	Basswood	MB	233.20	18.67	14.35	9.66	5.86	4.01	3.13	2.39	924.32	Regina	BASF
2102	Beausejour	MB	233.20	18.82	14.48	9.76	5.92	4.05	3.17	2.42	933.96	Regina	BASF
2103	Benito	MB	233.20	19.96	15.52	10.47	6.38	4.35	3.40	2.59	1006.84	Regina	BASF
2104	Binscarth	MB	233.20	18.12	13.85	9.32	5.64	3.87	3.02	2.31	888.95	Regina	BASF
2105	Birch River	MB	233.20	23.27	18.52	12.54	7.73	5.23	4.09	3.11	1219.03	Regina	BASF
2106	Birtle	MB	233.20	18.71	14.38	9.69	5.88	4.02	3.14	2.40	926.68	Regina	BASF
2107	Boissevain	MB	233.20	21.32	16.75	11.32	6.94	4.72	3.68	2.81	1094.07	Regina	BASF
2108	Brandon	MB	233.20	18.59	14.28	9.62	5.83	3.99	3.12	2.38	867.55	Regina	BASF
2109	Brunkild	MB	233.20	17.91	13.66	9.19	5.55	3.81	2.98	2.27	875.98	Regina	BASF
2110	Carberry	MB	233.20	16.54	12.42	8.33	5.00	3.45	2.69	2.06	788.02	Regina	BASF
2111	Carman	MB	233.20	17.76	13.52	9.10	5.49	3.77	2.95	2.25	865.98	Regina	BASF
2112	Cartwright	MB	233.20	21.32	16.75	11.32	6.94	4.72	3.68	2.81	1094.07	Regina	BASF
2113	Crystal City	MB	233.20	19.70	15.28	10.31	6.28	4.29	3.35	2.55	990.29	Regina	BASF
2114	Cypress River	MB	233.20	17.29	13.10	8.80	5.30	3.65	2.85	2.18	836.00	Regina	BASF
2115	Darlingford	MB	233.20	18.94	14.60	9.84	5.97	4.09	3.19	2.44	941.95	Regina	BASF
2116	Dauphin	MB	233.20	20.77	16.25	10.98	6.71	4.57	3.57	2.72	1058.71	Regina	BASF
2117	Deloraine	MB	233.20	21.72	17.12	11.57	7.10	4.82	3.77	2.87	1120.01	Regina	BASF
2118	Dencross	MB	190.80	14.58	13.21	9.11	5.92	3.87	3.17	2.28	933.96	Regina	BASF
2119	Domain	MB	233.20	17.57	13.35	8.98	5.42	3.72	2.91	2.22	853.99	Regina	BASF
2120	Dominion City	MB	212.00	15.67	14.20	9.79	6.37	4.16	3.39	2.45	1003.93	Regina	BASF
2121	Douglas	MB	233.20	16.54	12.42	8.33	5.00	3.45	2.69	2.06	743.82	Regina	BASF
2122	Dufrost	MB	233.20	19.16	14.80	9.97	6.06	4.14	3.24	2.47	955.95	Regina	BASF
2123	Dugald	MB	190.80	12.99	11.77	8.12	5.28	3.45	2.84	2.03	832.00	Regina	BASF
2124	Dunrea	MB	233.20	20.62	16.12	10.88	6.65	4.53	3.54	2.70	1049.28	Regina	BASF
2125	Elgin	MB	233.20	20.25	15.78	10.65	6.50	4.43	3.46	2.64	1025.70	Regina	BASF
2126	Elie	MB	233.20	16.38	12.28	8.24	4.93	3.41	2.66	2.04	778.02	Regina	BASF
2127	Elkhorn	MB	233.20	17.01	12.85	8.63	5.19	3.57	2.79	2.13	818.22	Regina	BASF
2128	Elm Creek	MB	233.20	17.16	12.99	8.72	5.25	3.61	2.82	2.16	828.00	Regina	BASF
2129	Emerson	MB	212.00	16.30	14.77	10.18	6.62	4.33	3.52	2.55	1043.91	Regina	BASF
2130	Fannystelle	MB	233.20	17.04	12.87	8.65	5.20	3.58	2.80	2.14	820.00	Regina	BASF
2131	Fisher Branch	MB	233.20	22.53	17.85	12.08	7.43	5.04	3.93	3.00	1171.78	Regina	BASF
2132	Fork River	MB	233.20	22.75	18.05	12.22	7.52	5.10	3.98	3.03	1186.02	Regina	BASF
2133	Forrest	MB	233.20	18.74	14.41	9.71	5.89	4.03	3.15	2.40	929.03	Regina	BASF
2134	Foxwarren	MB	212.00	14.39	13.04	8.99	5.85	3.82	3.13	2.25	921.96	Regina	BASF
2135	Franklin	MB	233.20	19.55	15.15	10.22	6.22	4.25	3.32	2.53	980.90	Regina	BASF
2136	Gilbert Plains	MB	233.20	20.10	15.65	10.56	6.44	4.39	3.43	2.62	958.74	Regina	BASF
2137	Gimli	MB	212.00	15.58	14.12	9.74	6.33	4.14	3.37	2.43	997.93	Regina	BASF
2138	Gladstone	MB	233.20	17.23	13.04	8.76	5.28	3.63	2.84	2.17	832.00	Regina	BASF
2139	Glenboro	MB	233.20	20.36	15.88	10.72	6.55	4.46	3.48	2.66	1032.77	Regina	BASF
2140	Glossop (Newdale)	MB	212.00	14.91	13.51	9.32	6.06	3.96	3.23	2.33	954.97	Regina	BASF
2141	Goodlands	MB	233.20	22.20	17.55	11.87	7.30	4.95	3.87	2.94	1150.66	Regina	BASF
2142	Grandview	MB	233.20	19.37	14.98	10.10	6.15	4.20	3.28	2.50	969.11	Regina	BASF
2143	Gretna	MB	233.20	19.91	15.47	10.44	6.37	4.34	3.39	2.59	1003.93	Regina	BASF
2144	Griswold	MB	233.20	18.41	14.11	9.50	5.76	3.94	3.08	2.35	907.81	Regina	BASF
2145	Grosse Isle	MB	233.20	17.26	13.07	8.78	5.29	3.64	2.84	2.17	834.00	Regina	BASF
2146	Gunton	MB	233.20	18.19	13.92	9.37	5.67	3.89	3.04	2.32	893.97	Regina	BASF
2147	Hamiota	MB	233.20	19.29	14.91	10.06	6.12	4.18	3.26	2.49	964.40	Regina	BASF
2148	Hargrave	MB	233.20	17.67	13.45	9.04	5.46	3.75	2.93	2.24	860.66	Regina	BASF
2149	Hartney	MB	233.20	20.10	15.65	10.56	6.44	4.39	3.43	2.62	1016.27	Regina	BASF
2150	High Bluff	MB	233.20	16.92	12.76	8.57	5.15	3.55	2.77	2.12	812.01	Regina	BASF
2151	Holland	MB	233.20	17.32	13.13	8.82	5.31	3.65	2.86	2.18	838.00	Regina	BASF
2152	Homewood	MB	233.20	17.73	13.49	9.08	5.48	3.76	2.94	2.25	863.98	Regina	BASF
2153	Inglis	MB	233.20	18.26	13.98	9.41	5.70	3.91	3.05	2.33	847.53	Regina	BASF
2154	Kane	MB	212.00	14.27	12.93	8.92	5.80	3.79	3.10	2.23	913.96	Regina	BASF
2155	Kemnay	MB	233.20	18.37	14.08	9.48	5.74	3.93	3.07	2.35	905.46	Regina	BASF
2156	Kenton	MB	233.20	18.96	14.61	9.85	5.98	4.09	3.20	2.44	943.18	Regina	BASF
2157	Kenville	MB	233.20	20.91	16.38	11.07	6.77	4.61	3.60	2.74	1068.14	Regina	BASF
2158	Killarney	MB	233.20	21.69	17.08	11.55	7.09	4.81	3.76	2.86	1117.65	Regina	BASF
2159	Landmark	MB	233.20	17.95	13.69	9.21	5.57	3.82	2.98	2.28	877.98	Regina	BASF
2160	Lauder	MB	233.20	17.63	13.41	9.02	5.44	3.74	2.92	2.23	857.99	Regina	BASF
2161	Laurier	MB	233.20	22.90	18.18	12.31	7.58	5.14	4.01	3.05	1195.45	Regina	BASF
2162	Letellier	MB	233.20	19.85	15.42	10.40	6.34	4.33	3.38	2.58	999.93	Regina	BASF
2163	Lowe Farm	MB	233.20	18.51	14.20	9.56	5.80	3.97	3.10	2.37	913.96	Regina	BASF
2164	Lundar	MB	233.20	19.82	15.39	10.38	6.33	4.32	3.37	2.57	997.93	Regina	BASF
2165	MacGregor	MB	233.20	16.38	12.28	8.24	4.93	3.41	2.66	2.04	778.02	Regina	BASF
2166	Manitou	MB	233.20	18.85	14.51	9.78	5.94	4.06	3.17	2.42	935.95	Regina	BASF
2167	Mariapolis	MB	233.20	18.04	13.78	9.27	5.61	3.85	3.00	2.29	884.26	Regina	BASF
2168	Mather	MB	190.80	17.08	15.48	10.67	6.94	4.54	3.68	2.67	1094.07	Regina	BASF
2169	McCreary	MB	190.80	17.96	16.28	11.23	7.30	4.77	3.87	2.81	1150.66	Regina	BASF
2170	Marquette/Meadows	MB	233.20	16.88	12.73	8.55	5.14	3.54	2.77	2.11	810.01	Regina	BASF
2171	Medora	MB	190.80	17.04	15.44	10.65	6.92	4.53	3.68	2.66	1091.72	Regina	BASF
2172	Melita	MB	233.20	21.17	16.62	11.23	6.88	4.68	3.65	2.78	1023.25	Regina	BASF
2173	Miami	MB	233.20	18.19	13.92	9.37	5.67	3.89	3.04	2.32	893.97	Regina	BASF
2174	Miniota	MB	233.20	19.00	14.65	9.87	6.00	4.10	3.20	2.44	945.54	Regina	BASF
2175	Minitonas	MB	233.20	19.98	15.54	10.49	6.40	4.36	3.41	2.60	1008.64	Regina	BASF
2176	Minnedosa	MB	233.20	19.51	15.11	10.19	6.21	4.24	3.31	2.52	978.55	Regina	BASF
2177	Minto	MB	233.20	20.21	15.75	10.63	6.49	4.42	3.45	2.63	1023.34	Regina	BASF
2178	Mollard	MB	233.20	17.91	13.66	9.19	5.55	3.82	2.98	2.28	875.98	Regina	BASF
2179	Morden	MB	233.20	19.26	14.88	10.03	6.10	4.17	3.26	2.48	961.94	Regina	BASF
2180	Morris	MB	233.20	18.85	14.51	9.78	5.94	4.06	3.17	2.42	935.95	Regina	BASF
2181	Neepawa	MB	233.20	17.26	13.07	8.78	5.29	3.64	2.84	2.17	834.00	Regina	BASF
2182	Nesbitt	MB	233.20	19.88	15.45	10.42	6.35	4.34	3.39	2.58	1002.12	Regina	BASF
2183	Newdale	MB	233.20	19.22	14.85	10.01	6.09	4.16	3.25	2.48	959.68	Regina	BASF
2184	Ninga	MB	212.00	17.67	16.01	11.04	7.18	4.69	3.80	2.76	1131.80	Regina	BASF
2185	Niverville	MB	233.20	17.85	13.61	9.15	5.53	3.80	2.97	2.26	871.98	Regina	BASF
2186	Notre Dame De Lourdes	MB	233.20	17.88	13.64	9.17	5.54	3.80	2.97	2.27	873.98	Regina	BASF
2187	Oak Bluff	MB	233.20	16.88	12.73	8.55	5.14	3.54	2.77	2.11	810.01	Regina	BASF
2188	Oak River	MB	233.20	19.22	14.85	10.01	6.09	4.16	3.25	2.48	959.68	Regina	BASF
2189	Oakbank	MB	233.20	16.10	12.02	8.06	4.82	3.33	2.60	1.99	760.03	Regina	BASF
2190	Oakner	MB	233.20	17.10	12.93	8.69	5.23	3.60	2.81	2.15	824.00	Regina	BASF
2191	Oakville	MB	233.20	16.48	12.36	8.30	4.97	3.43	2.68	2.05	784.02	Regina	BASF
2192	Petersfield	MB	233.20	18.97	14.62	9.85	5.98	4.09	3.20	2.44	943.39	Regina	BASF
2193	Pierson	MB	233.20	21.43	16.85	11.39	6.98	4.75	3.71	2.82	1101.15	Regina	BASF
2194	Pilot Mound	MB	233.20	19.41	15.02	10.13	6.16	4.21	3.29	2.51	971.94	Regina	BASF
2195	Pine Falls	MB	212.00	16.95	15.36	10.59	6.89	4.50	3.66	2.65	1085.89	Regina	BASF
2196	Plum Coulee	MB	233.20	19.44	15.05	10.15	6.18	4.22	3.29	2.51	973.94	Regina	BASF
2197	Plumas	MB	233.20	17.91	13.66	9.19	5.55	3.81	2.98	2.27	875.98	Regina	BASF
2198	Portage La Prairie	MB	233.20	16.35	12.25	8.22	4.92	3.40	2.66	2.03	776.02	Regina	BASF
2199	Rathwell	MB	233.20	17.32	13.13	8.82	5.31	3.65	2.86	2.18	838.00	Regina	BASF
2200	Reston	MB	233.20	19.88	15.45	10.42	6.35	4.34	3.39	2.58	1002.12	Regina	BASF
2201	River Hills	MB	233.20	20.44	15.95	10.77	6.58	4.48	3.50	2.67	1037.91	Regina	BASF
2202	Rivers	MB	233.20	19.18	14.81	9.99	6.07	4.15	3.24	2.47	957.33	Regina	BASF
2203	Roblin	MB	233.20	17.23	13.05	8.77	5.28	3.63	2.84	2.17	785.25	Regina	BASF
2204	Roland	MB	233.20	18.48	14.17	9.54	5.78	3.96	3.09	2.36	911.96	Regina	BASF
2205	Rosenort	MB	233.20	18.66	14.34	9.66	5.86	4.01	3.13	2.39	923.96	Regina	BASF
2206	Rossburn	MB	233.20	18.93	14.58	9.83	5.97	4.08	3.19	2.43	940.82	Regina	BASF
2207	Rosser	MB	233.20	17.01	12.84	8.63	5.19	3.57	2.79	2.13	771.70	Regina	BASF
2208	Russell	MB	233.20	17.09	12.91	8.68	5.22	3.59	2.81	2.14	822.94	Regina	BASF
2209	Selkirk	MB	233.20	17.88	13.64	9.17	5.54	3.80	2.97	2.27	873.98	Regina	BASF
2210	Shoal Lake	MB	233.20	19.29	14.91	10.06	6.12	4.18	3.26	2.49	964.40	Regina	BASF
2211	Sifton	MB	212.00	17.63	15.98	11.02	7.16	4.68	3.80	2.75	1129.44	Regina	BASF
2212	Snowflake	MB	233.20	20.14	15.68	10.59	6.46	4.40	3.44	2.62	1018.84	Regina	BASF
2213	Somerset	MB	233.20	18.23	13.95	9.39	5.68	3.90	3.04	2.32	895.97	Regina	BASF
2214	Souris	MB	233.20	19.18	14.81	9.99	6.07	4.15	3.24	2.47	957.33	Regina	BASF
2215	Springfield	MB	233.20	16.10	12.02	8.06	4.82	3.33	2.60	1.99	760.03	Regina	BASF
2216	St Claude	MB	233.20	17.23	13.04	8.76	5.28	3.63	2.84	2.17	832.00	Regina	BASF
2217	St Jean Baptiste	MB	233.20	19.29	14.91	10.05	6.11	4.18	3.26	2.49	963.94	Regina	BASF
2218	St Joseph	MB	233.20	20.04	15.59	10.52	6.42	4.38	3.42	2.61	1011.92	Regina	BASF
2219	St Leon	MB	233.20	18.23	13.95	9.39	5.68	3.90	3.04	2.32	895.97	Regina	BASF
2220	Starbuck	MB	233.20	17.04	12.87	8.65	5.20	3.58	2.80	2.14	820.00	Regina	BASF
2221	Ste Agathe	MB	233.20	17.73	13.49	9.08	5.48	3.76	2.94	2.25	863.98	Regina	BASF
2222	Ste Anne	MB	233.20	18.38	14.09	9.49	5.75	3.94	3.08	2.35	905.97	Regina	BASF
2223	Ste Rose Du Lac	MB	233.20	20.77	16.25	10.98	6.71	4.57	3.57	2.72	1058.71	Regina	BASF
2224	Steinbach	MB	233.20	19.01	14.65	9.88	6.00	4.10	3.20	2.44	945.95	Regina	BASF
2225	Stonewall	MB	233.20	17.38	13.18	8.86	5.34	3.67	2.87	2.19	841.99	Regina	BASF
2226	Strathclair	MB	233.20	19.26	14.88	10.03	6.10	4.17	3.26	2.48	962.04	Regina	BASF
2227	Swan Lake	MB	233.20	18.36	14.07	9.47	5.74	3.93	3.07	2.34	904.65	Regina	BASF
2228	Swan River	MB	233.20	21.58	16.98	11.48	7.04	4.79	3.74	2.85	1047.71	Regina	BASF
2229	Teulon	MB	233.20	18.84	14.50	9.77	5.93	4.06	3.17	2.42	935.23	Regina	BASF
2230	The Pas	MB	321.02	32.10	26.52	18.06	11.32	7.58	5.91	4.49	1784.88	Regina	BASF
2231	Treherne	MB	233.20	17.32	13.13	8.82	5.31	3.65	2.86	2.18	838.00	Regina	BASF
2232	Turtle Mountain	MB	212.00	17.74	16.08	11.09	7.21	4.71	3.82	2.77	1136.51	Regina	BASF
2233	Virden	MB	233.20	18.26	13.98	9.41	5.70	3.91	3.05	2.33	898.38	Regina	BASF
2234	Warren	MB	212.00	12.89	11.68	8.06	5.24	3.42	2.82	2.01	826.00	Regina	BASF
2235	Waskada	MB	233.20	22.02	17.38	11.76	7.22	4.90	3.83	2.92	1138.87	Regina	BASF
2236	Wawanesa	MB	233.20	19.88	15.45	10.42	6.35	4.34	3.39	2.58	1002.12	Regina	BASF
2237	Wellwood	MB	233.20	16.98	12.82	8.61	5.17	3.56	2.78	2.13	816.00	Regina	BASF
2238	Westbourne	MB	233.20	17.16	12.99	8.72	5.25	3.61	2.82	2.16	828.00	Regina	BASF
2239	Winkler	MB	233.20	19.22	14.85	10.01	6.09	4.16	3.25	2.48	905.61	Regina	BASF
2240	Winnipeg	MB	233.20	13.55	9.71	6.47	3.78	2.65	2.08	1.59	562.72	Regina	BASF
2241	Abbey	SK	190.80	15.58	14.12	9.73	6.33	4.14	3.37	2.43	997.82	Regina	BASF
2242	Aberdeen	SK	190.80	13.44	12.18	8.40	5.46	3.57	2.93	2.10	861.07	Regina	BASF
2243	Abernethy	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2244	Admiral	SK	190.80	13.42	12.16	8.39	5.45	3.57	2.93	2.10	859.86	Regina	BASF
2245	Alameda	SK	190.80	11.16	10.11	6.97	4.53	2.96	2.46	1.74	674.43	Regina	BASF
2246	Albertville	SK	190.80	18.96	17.18	11.85	7.70	5.04	4.07	2.96	1214.73	Regina	BASF
2247	Antler	SK	190.80	14.40	13.05	9.00	5.85	3.82	3.13	2.25	922.37	Regina	BASF
2248	Arborfield	SK	190.80	16.68	15.12	10.42	6.78	4.43	3.60	2.61	1068.55	Regina	BASF
2249	Archerwill	SK	190.80	12.26	11.11	7.66	4.98	3.26	2.69	1.92	785.63	Regina	BASF
2250	Assiniboia	SK	190.80	7.50	6.80	4.69	3.05	1.99	1.70	1.17	453.54	Regina	BASF
2251	Avonlea	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2252	Aylsham	SK	190.80	16.75	15.18	10.47	6.81	4.45	3.62	2.62	1073.27	Regina	BASF
2253	Balcarres	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2254	Balgonie	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2255	Bankend	SK	190.80	6.59	5.97	4.12	2.68	1.75	1.51	1.03	422.21	Regina	BASF
2256	Battleford	SK	190.80	18.96	17.18	11.85	7.70	5.03	4.07	2.96	1214.32	Regina	BASF
2257	Beechy	SK	190.80	13.74	12.45	8.58	5.58	3.65	2.99	2.15	879.93	Regina	BASF
2258	Bengough	SK	212.00	6.27	5.68	3.92	2.55	1.67	1.45	0.98	401.57	Regina	BASF
2259	Biggar	SK	190.80	16.53	14.98	10.33	6.72	4.39	3.57	2.58	999.17	Regina	BASF
2260	Birch Hills	SK	190.80	15.21	13.78	9.50	6.18	4.04	3.30	2.38	974.24	Regina	BASF
2261	Bjorkdale	SK	212.00	15.28	13.85	9.55	6.21	4.06	3.31	2.39	978.96	Regina	BASF
2262	Blaine Lake	SK	190.80	15.94	14.45	9.96	6.48	4.24	3.45	2.49	1021.40	Regina	BASF
2263	Bracken	SK	190.80	18.45	16.72	11.53	7.49	4.90	3.97	2.88	1181.72	Regina	BASF
2264	Bredenbury	SK	190.80	8.59	7.78	5.37	3.49	2.28	1.93	1.34	550.20	Regina	BASF
2265	Briercrest	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2266	Broadview	SK	190.80	6.40	5.80	4.00	2.60	1.70	1.47	1.00	409.83	Regina	BASF
2267	Broderick	SK	212.00	10.64	9.65	6.65	4.32	2.83	2.35	1.66	681.89	Regina	BASF
2268	Brooksby	SK	190.80	15.06	13.65	9.41	6.12	4.00	3.27	2.35	964.81	Regina	BASF
2269	Bruno	SK	190.80	11.75	10.65	7.34	4.77	3.12	2.58	1.84	752.62	Regina	BASF
2270	Buchanan	SK	190.80	11.31	10.25	7.07	4.59	3.00	2.49	1.77	724.33	Regina	BASF
2271	Cabri	SK	190.80	14.32	12.98	8.95	5.82	3.80	3.11	2.24	865.71	Regina	BASF
2272	Canora	SK	190.80	11.16	10.11	6.97	4.53	2.96	2.46	1.74	674.43	Regina	BASF
2273	Canwood	SK	197.71	19.77	17.92	12.36	8.03	5.25	4.24	3.09	1266.60	Regina	BASF
2274	Carievale	SK	190.80	15.65	14.18	9.78	6.36	4.16	3.39	2.45	1002.54	Regina	BASF
2275	Carlyle	SK	190.80	8.14	7.37	5.09	3.31	2.16	1.83	1.27	491.79	Regina	BASF
2276	Carnduff	SK	190.80	13.07	11.85	8.17	5.31	3.47	2.85	2.04	790.09	Regina	BASF
2277	Carrot River	SK	190.80	17.78	16.12	11.11	7.22	4.72	3.83	2.78	1139.28	Regina	BASF
2278	Central Butte	SK	190.80	7.11	6.44	4.44	2.89	1.89	1.62	1.11	429.71	Regina	BASF
2279	Ceylon	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2280	Choiceland	SK	190.80	16.75	15.18	10.47	6.81	4.45	3.62	2.62	1073.27	Regina	BASF
2281	Churchbridge	SK	190.80	10.20	9.25	6.38	4.14	2.71	2.26	1.59	653.59	Regina	BASF
2282	Clavet	SK	190.80	12.78	11.58	7.99	5.19	3.39	2.79	2.00	772.30	Regina	BASF
2283	Codette	SK	190.80	16.53	14.98	10.33	6.72	4.39	3.57	2.58	1059.12	Regina	BASF
2284	Colgate	SK	190.80	6.19	5.61	3.87	2.51	1.64	1.43	0.97	396.53	Regina	BASF
2285	Colonsay	SK	190.80	11.16	10.11	6.97	4.53	2.96	2.46	1.74	714.90	Regina	BASF
2286	Congress	SK	190.80	6.91	6.26	4.32	2.81	1.84	1.58	1.08	442.86	Regina	BASF
2287	Consul	SK	217.52	21.75	19.71	13.60	8.84	5.78	4.65	3.40	1393.50	Regina	BASF
2288	Corman Park	SK	190.80	10.46	9.48	6.54	4.25	2.78	2.31	1.63	632.02	Regina	BASF
2289	Corning	SK	190.80	7.30	6.62	4.56	2.97	1.94	1.66	1.14	467.63	Regina	BASF
2290	Coronach	SK	190.80	10.06	9.11	6.28	4.08	2.67	2.23	1.57	644.16	Regina	BASF
2291	Craik	SK	190.80	5.04	4.57	3.15	2.05	1.34	1.19	0.79	323.13	Regina	BASF
2292	Creelman	SK	190.80	5.11	4.63	3.19	2.08	1.36	1.21	0.80	327.25	Regina	BASF
2293	Crooked River	SK	190.80	15.13	13.72	9.46	6.15	4.02	3.28	2.36	969.53	Regina	BASF
2294	Cudworth	SK	190.80	13.59	12.31	8.49	5.52	3.61	2.96	2.12	870.50	Regina	BASF
2295	Cupar	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2296	Cut knife	SK	190.80	18.96	17.18	11.85	7.70	5.04	4.07	2.96	1145.97	Regina	BASF
2297	Davidson	SK	190.80	6.20	5.62	3.88	2.52	1.65	1.43	0.97	374.95	Regina	BASF
2298	Debden	SK	214.58	21.46	19.45	13.41	8.72	5.70	4.59	3.35	1374.64	Regina	BASF
2299	Delisle	SK	190.80	13.74	12.45	8.58	5.58	3.65	2.99	2.15	879.93	Regina	BASF
2300	Delmas	SK	190.80	18.41	16.68	11.51	7.48	4.89	3.96	2.88	1179.36	Regina	BASF
2301	Denzil	SK	201.39	20.14	18.25	12.59	8.18	5.35	4.32	3.15	1290.18	Regina	BASF
2302	Dinsmore	SK	190.80	12.41	11.25	7.76	5.04	3.30	2.72	1.94	795.06	Regina	BASF
2303	Domremy	SK	190.80	15.13	13.72	9.46	6.15	4.02	3.28	2.36	969.53	Regina	BASF
2304	Drake	SK	190.80	6.91	6.26	4.32	2.81	1.84	1.58	1.08	442.86	Regina	BASF
2305	Duperow	SK	190.80	16.24	14.72	10.15	6.60	4.31	3.51	2.54	1040.26	Regina	BASF
2306	Eastend	SK	190.80	18.29	16.58	11.43	7.43	4.86	3.93	2.86	1171.88	Regina	BASF
2307	Eatonia	SK	199.92	19.99	18.12	12.50	8.12	5.31	4.29	3.12	1280.74	Regina	BASF
2308	Ebenezer	SK	190.80	9.83	8.91	6.15	4.00	2.61	2.18	1.54	630.02	Regina	BASF
2309	Edam	SK	198.45	19.84	17.98	12.40	8.06	5.27	4.26	3.10	1271.31	Regina	BASF
2310	Edenwold	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2311	Elfros	SK	190.80	7.75	7.02	4.84	3.15	2.06	1.75	1.21	496.53	Regina	BASF
2312	Elrose	SK	190.80	16.46	14.92	10.29	6.69	4.37	3.55	2.57	1054.40	Regina	BASF
2313	Estevan	SK	190.80	8.36	7.58	5.22	3.40	2.22	1.88	1.31	535.51	Regina	BASF
2314	Eston	SK	190.80	18.45	16.72	11.53	7.49	4.90	3.97	2.88	1181.72	Regina	BASF
2315	Eyebrow	SK	190.80	6.12	5.55	3.83	2.49	1.63	1.42	0.96	392.32	Regina	BASF
2316	Fairlight	SK	190.80	11.90	10.78	7.43	4.83	3.16	2.61	1.86	762.05	Regina	BASF
2317	Fielding	SK	190.80	15.94	14.45	9.96	6.48	4.24	3.45	2.49	1021.40	Regina	BASF
2318	Fillmore	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2319	Flaxcombe	SK	212.00	18.89	17.12	11.81	7.67	5.02	4.06	2.95	1210.01	Regina	BASF
2320	Foam Lake	SK	190.80	8.01	7.26	5.01	3.25	2.13	1.81	1.25	484.64	Regina	BASF
2321	Fox Valley	SK	192.93	19.29	17.48	12.06	7.84	5.12	4.14	3.01	1235.95	Regina	BASF
2322	Francis	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2323	Frontier	SK	191.82	19.18	17.38	11.99	7.79	5.10	4.12	3.00	1228.87	Regina	BASF
2324	Gerald	SK	190.80	11.75	10.65	7.34	4.77	3.12	2.58	1.84	752.62	Regina	BASF
2325	Glaslyn	SK	203.97	20.40	18.48	12.75	8.29	5.42	4.37	3.19	1306.68	Regina	BASF
2326	Glenavon	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2327	Goodeve	SK	190.80	6.91	6.26	4.32	2.81	1.84	1.58	1.08	442.86	Regina	BASF
2328	Govan	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2329	Grand Coulee	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2330	Gravelbourg	SK	190.80	7.90	7.16	4.94	3.21	2.10	1.78	1.23	477.38	Regina	BASF
2331	Gray	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2332	Grenfell	SK	190.80	5.37	4.86	3.35	2.18	1.43	1.26	0.84	324.31	Regina	BASF
2333	Griffin	SK	190.80	6.01	5.45	3.76	2.44	1.60	1.39	0.94	363.26	Regina	BASF
2334	Gronlid	SK	190.80	12.84	11.64	8.03	5.22	3.41	2.81	2.01	822.70	Regina	BASF
2335	Gull Lake	SK	190.80	13.88	12.58	8.68	5.64	3.69	3.02	2.17	839.02	Regina	BASF
2336	Hafford	SK	190.80	16.83	15.25	10.52	6.84	4.47	3.63	2.63	1077.98	Regina	BASF
2337	Hague	SK	190.80	14.32	12.98	8.95	5.82	3.80	3.11	2.24	917.66	Regina	BASF
2338	Hamlin	SK	190.80	18.92	17.15	11.83	7.69	5.03	4.06	2.96	1212.37	Regina	BASF
2339	Hanley	SK	190.80	8.33	7.55	5.21	3.38	2.21	1.87	1.30	533.69	Regina	BASF
2340	Hazenmore	SK	190.80	11.58	10.49	7.24	4.70	3.08	2.54	1.81	699.87	Regina	BASF
2341	Hazlet	SK	190.80	14.25	12.91	8.91	5.79	3.79	3.10	2.23	912.94	Regina	BASF
2342	Hepburn	SK	190.80	14.41	13.06	9.01	5.85	3.83	3.15	2.25	923.26	Regina	BASF
2343	Herbert	SK	190.80	8.33	7.55	5.21	3.38	2.21	1.87	1.30	503.48	Regina	BASF
2344	Hodgeville	SK	190.80	9.98	9.05	6.24	4.06	2.65	2.21	1.56	639.45	Regina	BASF
2345	Hoey	SK	190.80	15.50	14.05	9.69	6.30	4.12	3.36	2.42	993.10	Regina	BASF
2346	Hudson Bay	SK	190.80	18.51	16.78	11.57	7.52	4.92	3.98	2.89	1186.02	Regina	BASF
2347	Humboldt	SK	190.80	10.50	9.51	6.56	4.26	2.79	2.32	1.64	634.39	Regina	BASF
2348	Imperial	SK	190.80	5.95	5.39	3.72	2.42	1.58	1.38	0.93	380.93	Regina	BASF
2349	Indian Head	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2350	Invermay	SK	190.80	11.45	10.38	7.16	4.65	3.04	2.52	1.79	692.22	Regina	BASF
2351	Ituna	SK	190.80	5.62	5.10	3.51	2.28	1.49	1.31	0.88	360.28	Regina	BASF
2352	Kamsack	SK	190.80	12.56	11.38	7.85	5.10	3.34	2.75	1.96	758.95	Regina	BASF
2353	Kelso	SK	190.80	11.90	10.78	7.43	4.83	3.16	2.61	1.86	762.05	Regina	BASF
2354	Kelvington	SK	190.80	11.75	10.65	7.34	4.77	3.12	2.58	1.84	752.62	Regina	BASF
2355	Kerrobert	SK	198.45	19.84	17.98	12.40	8.06	5.27	4.26	3.10	1271.31	Regina	BASF
2356	Kincaid	SK	190.80	9.88	8.95	6.17	4.01	2.62	2.19	1.54	632.78	Regina	BASF
2357	Kindersley	SK	190.80	18.15	16.45	11.34	7.37	4.82	3.91	2.84	1097.04	Regina	BASF
2358	Kinistino	SK	190.80	14.55	13.18	9.09	5.91	3.86	3.16	2.27	931.80	Regina	BASF
2359	Kipling	SK	190.80	7.36	6.67	4.60	2.99	1.96	1.67	1.15	471.76	Regina	BASF
2360	Kisbey	SK	190.80	7.17	6.50	4.48	2.91	1.90	1.63	1.12	459.37	Regina	BASF
2361	Kronau	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2362	Krydor	SK	190.80	16.97	15.38	10.61	6.90	4.51	3.66	2.65	1087.41	Regina	BASF
2363	Kyle	SK	190.80	14.55	13.18	9.09	5.91	3.86	3.16	2.27	931.80	Regina	BASF
2364	Lafleche	SK	190.80	9.76	8.85	6.10	3.97	2.59	2.17	1.53	625.30	Regina	BASF
2365	Lajord	SK	190.80	5.51	5.00	3.45	2.24	1.46	1.29	0.86	333.12	Regina	BASF
2366	Lake Alma	SK	190.80	7.87	7.13	4.92	3.20	2.09	1.78	1.23	504.35	Regina	BASF
2367	Lake Lenore	SK	190.80	11.67	10.58	7.30	4.74	3.10	2.56	1.82	747.90	Regina	BASF
2368	Lampman	SK	190.80	8.23	7.46	5.14	3.34	2.19	1.85	1.29	527.08	Regina	BASF
2369	Landis	SK	190.80	18.08	16.38	11.30	7.34	4.80	3.89	2.82	1158.14	Regina	BASF
2370	Langbank	SK	190.80	9.83	8.91	6.15	4.00	2.61	2.18	1.54	630.02	Regina	BASF
2371	Langenburg	SK	190.80	10.86	9.85	6.79	4.41	2.89	2.40	1.70	656.64	Regina	BASF
2372	Langham	SK	190.80	13.81	12.51	8.63	5.61	3.67	3.01	2.16	884.65	Regina	BASF
2373	Lanigan	SK	190.80	7.36	6.67	4.60	2.99	1.96	1.67	1.15	471.76	Regina	BASF
2374	Lashburn	SK	190.80	18.37	16.65	11.48	7.46	4.88	3.95	2.87	1177.01	Regina	BASF
2375	Leader	SK	190.80	18.30	16.58	11.44	7.43	4.86	3.94	2.86	1172.29	Regina	BASF
2376	Leask	SK	190.80	17.12	15.52	10.70	6.96	4.55	3.69	2.68	1096.84	Regina	BASF
2377	Lemberg	SK	190.80	5.24	4.75	3.27	2.13	1.39	1.23	0.82	335.51	Regina	BASF
2378	Leoville	SK	216.11	21.61	19.59	13.51	8.78	5.74	4.62	3.38	1384.48	Regina	BASF
2379	Leross	SK	190.80	5.75	5.21	3.60	2.34	1.53	1.34	0.90	368.54	Regina	BASF
2380	Leroy	SK	190.80	7.75	7.02	4.84	3.15	2.06	1.75	1.21	496.53	Regina	BASF
2381	Lestock	SK	190.80	6.01	5.45	3.76	2.44	1.60	1.39	0.94	385.06	Regina	BASF
2382	Lewvan	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2383	Liberty	SK	190.80	5.04	4.57	3.15	2.05	1.34	1.19	0.79	323.13	Regina	BASF
2384	Limerick	SK	190.80	8.10	7.34	5.06	3.29	2.15	1.82	1.27	518.66	Regina	BASF
2385	Lintlaw	SK	212.00	12.71	11.51	7.94	5.16	3.37	2.78	1.99	813.92	Regina	BASF
2386	Lipton	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2387	Lloydminsters	SK	190.80	18.37	16.65	11.48	7.46	4.88	3.95	2.87	1177.01	Regina	BASF
2388	Loreburn	SK	212.00	8.01	7.26	5.01	3.25	2.13	1.81	1.25	513.05	Regina	BASF
2389	Lucky Lake	SK	190.80	12.34	11.18	7.71	5.01	3.28	2.70	1.93	790.34	Regina	BASF
2390	Lumsden	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2391	Luseland	SK	202.50	20.25	18.35	12.66	8.23	5.38	4.34	3.16	1297.25	Regina	BASF
2392	Macklin	SK	211.33	21.13	19.15	13.21	8.59	5.61	4.52	3.30	1353.83	Regina	BASF
2393	Macoun	SK	190.80	7.11	6.44	4.44	2.89	1.89	1.62	1.11	429.47	Regina	BASF
2394	Maidstone	SK	190.80	18.37	16.65	11.48	7.46	4.88	3.95	2.87	1177.01	Regina	BASF
2395	Major	SK	208.39	20.84	18.88	13.02	8.47	5.54	4.46	3.26	1334.97	Regina	BASF
2396	Mankota	SK	190.80	13.96	12.65	8.72	5.67	3.71	3.04	2.18	894.08	Regina	BASF
2397	Maple Creek	SK	190.80	17.71	16.05	11.07	7.19	4.70	3.81	2.77	1134.57	Regina	BASF
2398	Marengo	SK	190.80	18.89	17.12	11.81	7.67	5.02	4.06	2.95	1210.01	Regina	BASF
2399	Marsden	SK	191.46	19.15	17.35	11.97	7.78	5.09	4.11	2.99	1226.52	Regina	BASF
2400	Marshall	SK	190.80	18.37	16.65	11.48	7.46	4.88	3.95	2.87	1177.01	Regina	BASF
2401	Maryfield	SK	190.80	12.48	11.31	7.80	5.07	3.32	2.73	1.95	754.50	Regina	BASF
2402	Maymont	SK	190.80	16.53	14.98	10.33	6.72	4.39	3.57	2.58	1059.12	Regina	BASF
2403	McLean	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2404	Meadow Lake	SK	230.84	23.08	20.92	14.43	9.38	6.13	4.93	3.61	1478.79	Regina	BASF
2405	Meath Park	SK	196.91	19.69	17.85	12.31	8.00	5.23	4.22	3.08	1261.47	Regina	BASF
2406	Medstead	SK	216.11	21.61	19.59	13.51	8.78	5.74	4.62	3.38	1384.48	Regina	BASF
2407	Melfort	SK	190.80	13.22	11.98	8.26	5.37	3.51	2.88	2.07	798.99	Regina	BASF
2408	Melville	SK	190.80	6.27	5.68	3.92	2.55	1.67	1.45	0.98	378.84	Regina	BASF
2409	Meota	SK	199.92	19.99	18.12	12.50	8.12	5.31	4.29	3.12	1280.74	Regina	BASF
2410	Mervin	SK	198.45	19.84	17.98	12.40	8.06	5.27	4.26	3.10	1271.31	Regina	BASF
2411	Midale	SK	190.80	7.04	6.38	4.40	2.86	1.87	1.60	1.10	450.68	Regina	BASF
2412	Middle Lake	SK	190.80	12.19	11.05	7.62	4.95	3.24	2.67	1.90	780.91	Regina	BASF
2413	Milden	SK	190.80	12.63	11.45	7.89	5.13	3.36	2.76	1.97	809.20	Regina	BASF
2414	Milestone	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2415	Montmartre	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2416	Moose Jaw	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2417	Moosomin	SK	190.80	10.50	9.51	6.56	4.26	2.79	2.32	1.64	634.39	Regina	BASF
2418	Morse	SK	190.80	7.82	7.08	4.88	3.17	2.08	1.77	1.22	500.66	Regina	BASF
2419	Mossbank	SK	190.80	5.95	5.39	3.72	2.42	1.58	1.38	0.93	380.93	Regina	BASF
2420	Naicam	SK	190.80	10.72	9.71	6.70	4.35	2.85	2.37	1.67	686.60	Regina	BASF
2421	Neilburg	SK	191.46	19.15	17.35	11.97	7.78	5.09	4.11	2.99	1226.52	Regina	BASF
2422	Neville	SK	190.80	12.78	11.58	7.99	5.19	3.39	2.79	2.00	818.63	Regina	BASF
2423	Nipawin	SK	190.80	16.97	15.38	10.61	6.90	4.51	3.66	2.65	1087.41	Regina	BASF
2424	Nokomis	SK	190.80	5.82	5.27	3.64	2.36	1.55	1.35	0.91	372.67	Regina	BASF
2425	Norquay	SK	190.80	13.44	12.18	8.40	5.46	3.57	2.93	2.10	812.33	Regina	BASF
2426	North Battleford	SK	190.80	18.41	16.68	11.51	7.48	4.89	3.96	2.88	1112.61	Regina	BASF
2427	Odessa	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2428	Ogema	SK	190.80	5.04	4.57	3.15	2.05	1.34	1.19	0.79	323.13	Regina	BASF
2429	Osler	SK	190.80	13.59	12.31	8.49	5.52	3.61	2.96	2.12	870.50	Regina	BASF
2430	Oungre	SK	190.80	7.30	6.62	4.56	2.97	1.94	1.66	1.14	467.63	Regina	BASF
2431	Outlook	SK	190.80	11.16	10.11	6.97	4.53	2.96	2.46	1.74	714.90	Regina	BASF
2432	Oxbow	SK	190.80	11.75	10.65	7.34	4.77	3.12	2.58	1.84	752.62	Regina	BASF
2433	Pangman	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2434	Paradise Hill	SK	201.03	20.10	18.22	12.56	8.17	5.34	4.31	3.14	1287.82	Regina	BASF
2435	Parkside	SK	190.80	18.08	16.38	11.30	7.34	4.80	3.89	2.82	1158.14	Regina	BASF
2436	Pasqua	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2437	Paynton	SK	190.80	18.96	17.18	11.85	7.70	5.03	4.07	2.96	1214.32	Regina	BASF
2438	Peesane	SK	190.80	13.33	12.08	8.33	5.42	3.54	2.91	2.08	854.00	Regina	BASF
2439	Pelly	SK	190.80	14.03	12.71	8.77	5.70	3.73	3.05	2.19	898.80	Regina	BASF
2440	Pense	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2441	Perdue	SK	190.80	15.13	13.72	9.46	6.15	4.02	3.28	2.36	969.53	Regina	BASF
2442	Pilot Butte	SK	190.80	5.00	4.54	3.13	2.04	1.33	1.19	0.78	320.52	Regina	BASF
2443	Plenty	SK	190.80	17.56	15.92	10.98	7.14	4.67	3.78	2.74	1125.14	Regina	BASF
2444	Ponteix	SK	190.80	14.03	12.71	8.77	5.70	3.73	3.05	2.19	898.80	Regina	BASF
2445	Porcupine Plain	SK	190.80	14.69	13.32	9.18	5.97	3.90	3.19	2.30	941.23	Regina	BASF
2446	Prairie River	SK	190.80	17.71	16.05	11.07	7.19	4.70	3.81	2.77	1134.57	Regina	BASF
2447	Prince Albert	SK	190.80	17.27	15.65	10.79	7.02	4.59	3.72	2.70	1043.66	Regina	BASF
2448	Quill Lake	Sk	190.80	10.13	9.18	6.33	4.11	2.69	2.24	1.58	648.88	Regina	BASF
2449	Rabbit Lake	SK	218.69	21.87	19.82	13.67	8.88	5.81	4.67	3.42	1400.99	Regina	BASF
2450	Radisson	SK	190.80	15.35	13.92	9.60	6.24	4.08	3.33	2.40	983.67	Regina	BASF
2451	Radville	SK	190.80	5.75	5.21	3.60	2.34	1.53	1.34	0.90	347.68	Regina	BASF
2452	Rama	SK	190.80	12.04	10.91	7.53	4.89	3.20	2.64	1.88	771.48	Regina	BASF
2453	Raymore	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2454	Redvers	SK	190.80	13.51	12.25	8.45	5.49	3.59	2.95	2.11	816.78	Regina	BASF
2455	Reed Lake	SK	190.80	7.82	7.08	4.88	3.17	2.08	1.77	1.22	500.66	Regina	BASF
2456	Regina	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2457	Rhein	SK	190.80	10.57	9.58	6.61	4.29	2.81	2.34	1.65	677.17	Regina	BASF
2458	Riceton	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2459	Richardson	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2460	Ridgedale	SK	190.80	15.65	14.18	9.78	6.36	4.16	3.39	2.45	1002.54	Regina	BASF
2461	Rocanville	SK	190.80	11.60	10.51	7.25	4.71	3.08	2.55	1.81	743.19	Regina	BASF
2462	Rockhaven	SK	194.40	19.44	17.62	12.15	7.90	5.16	4.17	3.04	1245.38	Regina	BASF
2463	Rose Valley	SK	190.80	11.53	10.45	7.20	4.68	3.06	2.53	1.80	738.47	Regina	BASF
2464	Rosetown	SK	190.80	14.32	12.98	8.95	5.82	3.80	3.11	2.24	865.71	Regina	BASF
2465	Rosthern	SK	190.80	15.21	13.78	9.50	6.18	4.04	3.30	2.38	974.24	Regina	BASF
2466	Rouleau	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2467	Rowatt	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2468	Saskatoon	SK	190.80	8.56	7.76	5.35	3.48	2.28	1.92	1.34	517.63	Regina	BASF
2469	Sceptre	Sk	190.80	17.34	15.72	10.84	7.05	4.61	3.74	2.71	1110.99	Regina	BASF
2470	Sedley	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2471	Shamrock	SK	190.80	7.17	6.50	4.48	2.91	1.90	1.63	1.12	459.37	Regina	BASF
2472	Shaunavon	SK	190.80	16.31	14.78	10.19	6.63	4.33	3.52	2.55	985.82	Regina	BASF
2473	Shellbrook	SK	190.80	18.74	16.98	11.71	7.61	4.98	4.03	2.93	1200.58	Regina	BASF
2474	Simpson	SK	190.80	6.46	5.86	4.04	2.63	1.72	1.49	1.01	413.96	Regina	BASF
2475	Sintaluta	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2476	Southey	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2477	Spalding	SK	190.80	10.78	9.77	6.74	4.38	2.86	2.38	1.69	690.91	Regina	BASF
2478	Speers	SK	190.80	17.78	16.12	11.11	7.22	4.72	3.83	2.78	1139.28	Regina	BASF
2479	Spiritwood	SK	201.39	20.14	18.25	12.59	8.18	5.35	4.32	3.15	1290.18	Regina	BASF
2480	St Brieux	SK	190.80	12.85	11.65	8.03	5.22	3.41	2.81	2.01	823.35	Regina	BASF
2481	St. Walburg	SK	200.66	20.07	18.18	12.54	8.15	5.33	4.30	3.14	1285.46	Regina	BASF
2482	Star City	SK	190.80	14.47	13.11	9.04	5.88	3.84	3.14	2.26	926.68	Regina	BASF
2483	Stewart Valley	SK	190.80	12.85	11.65	8.03	5.22	3.41	2.81	2.01	823.35	Regina	BASF
2484	Stockholm	SK	190.80	10.13	9.18	6.33	4.11	2.69	2.24	1.58	648.88	Regina	BASF
2485	Stoughton	SK	190.80	5.88	5.33	3.68	2.39	1.56	1.37	0.92	376.80	Regina	BASF
2486	Strasbourg	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2487	Strongfield	SK	190.80	9.54	8.65	5.96	3.88	2.53	2.12	1.49	611.16	Regina	BASF
2488	Sturgis	SK	190.80	13.00	11.78	8.12	5.28	3.45	2.84	2.03	832.78	Regina	BASF
2489	Swift Current	SK	190.80	11.53	10.45	7.20	4.68	3.06	2.53	1.80	696.67	Regina	BASF
2490	Theodore	SK	190.80	10.06	9.11	6.28	4.08	2.67	2.23	1.57	644.16	Regina	BASF
2491	Tisdale	SK	190.80	14.25	12.91	8.91	5.79	3.79	3.10	2.23	861.27	Regina	BASF
2492	Tompkins	SK	190.80	15.50	14.04	9.68	6.30	4.12	3.36	2.42	992.69	Regina	BASF
2493	Torquay	SK	190.80	7.70	6.98	4.81	3.13	2.05	1.74	1.20	493.39	Regina	BASF
2494	Tribune	SK	190.80	6.78	6.15	4.24	2.75	1.80	1.55	1.06	434.43	Regina	BASF
2495	Tugaske	SK	190.80	6.58	5.97	4.12	2.67	1.75	1.51	1.03	421.80	Regina	BASF
2496	Tullis	SK	190.80	11.53	10.45	7.20	4.68	3.06	2.53	1.80	738.47	Regina	BASF
2497	Turtleford	SK	198.45	19.84	17.98	12.40	8.06	5.27	4.26	3.10	1271.31	Regina	BASF
2498	Tuxford	SK	212.00	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2499	Unity	SK	203.23	20.32	18.42	12.70	8.26	5.40	4.35	3.18	1301.96	Regina	BASF
2500	Val Marie	SK	190.80	15.72	14.25	9.83	6.39	4.18	3.40	2.46	1007.25	Regina	BASF
2501	Valparaiso	SK	212.00	14.32	12.98	8.95	5.82	3.80	3.11	2.24	917.66	Regina	BASF
2502	Vanscoy	SK	190.80	13.59	12.31	8.49	5.52	3.61	2.96	2.12	870.50	Regina	BASF
2503	Vibank	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2504	Viscount	SK	190.80	10.42	9.45	6.51	4.23	2.77	2.31	1.63	667.74	Regina	BASF
2505	Wadena	SK	190.80	9.76	8.85	6.10	3.97	2.59	2.17	1.53	589.91	Regina	BASF
2506	Wakaw	SK	190.80	14.40	13.05	9.00	5.85	3.82	3.13	2.25	922.37	Regina	BASF
2507	Waldheim	SK	190.80	14.91	13.52	9.32	6.06	3.96	3.23	2.33	955.38	Regina	BASF
2508	Waldron	SK	190.80	7.31	6.62	4.57	2.97	1.94	1.66	1.14	468.13	Regina	BASF
2509	Wapella	Sk	190.80	9.47	8.58	5.92	3.85	2.51	2.11	1.48	606.44	Regina	BASF
2510	Watrous	SK	190.80	7.43	6.73	4.64	3.02	1.97	1.69	1.16	475.89	Regina	BASF
2511	Watson	SK	190.80	8.14	7.37	5.09	3.31	2.16	1.83	1.27	521.30	Regina	BASF
2512	Wawota	SK	190.80	11.45	10.38	7.16	4.65	3.04	2.52	1.79	733.76	Regina	BASF
2513	Weyburn	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2514	White City	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2515	White Star	SK	190.80	17.78	16.12	11.11	7.22	4.72	3.83	2.78	1139.28	Regina	BASF
2516	Whitewood	SK	190.80	7.36	6.67	4.60	2.99	1.96	1.67	1.15	471.76	Regina	BASF
2517	Wilcox	Sk	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2518	Wilkie	SK	208.39	20.84	18.88	13.02	8.47	5.54	4.46	3.26	1334.97	Regina	BASF
2519	Wiseton	SK	190.80	13.07	11.85	8.17	5.31	3.47	2.85	2.04	837.50	Regina	BASF
2520	Wolseley	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	320.52	Regina	BASF
2521	Woodrow	SK	190.80	10.28	9.31	6.42	4.17	2.73	2.28	1.61	658.31	Regina	BASF
2522	Wymark	SK	190.80	12.63	11.45	7.89	5.13	3.36	2.76	1.97	763.40	Regina	BASF
2523	Wynyard	SK	190.80	7.36	6.67	4.60	2.99	1.96	1.67	1.15	471.76	Regina	BASF
2524	Yellow Creek 	SK	190.80	15.06	13.65	9.41	6.12	4.00	3.27	2.35	964.81	Regina	BASF
2525	Yellow Grass	SK	190.80	5.00	4.53	3.13	2.03	1.33	1.18	0.78	302.38	Regina	BASF
2526	Yorkton	SK	190.80	7.75	7.02	4.84	3.15	2.06	1.75	1.21	468.42	Regina	BASF
3541	Ste Agathe	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3630	Elfros	SK	233.20	20.66	16.16	10.91	7.01	4.54	3.55	2.70	1052.22	Winnipeg	BASF
3631	Elrose	SK	315.36	31.54	26.01	17.71	11.43	7.43	5.80	4.40	1748.63	Winnipeg	BASF
3632	Estevan	SK	233.20	19.83	15.40	10.39	6.67	4.32	3.37	2.57	998.55	Winnipeg	BASF
3633	Eston	SK	333.25	33.33	27.63	18.82	12.16	7.91	6.17	4.68	1863.28	Winnipeg	BASF
3634	Eyebrow	SK	233.20	23.21	18.46	12.50	8.04	5.22	4.07	3.10	1215.11	Winnipeg	BASF
3635	Fairlight	SK	233.20	17.45	13.24	8.90	5.71	3.69	2.88	2.20	846.27	Winnipeg	BASF
3636	Fielding	SK	333.25	33.33	27.63	18.82	12.16	7.91	6.17	4.68	1863.28	Winnipeg	BASF
3637	Fillmore	SK	233.20	17.55	13.33	8.97	5.75	3.72	2.90	2.22	852.64	Winnipeg	BASF
3638	Foam Lake	SK	233.20	20.40	15.92	10.75	6.90	4.47	3.49	2.66	1035.24	Winnipeg	BASF
3639	Fox Valley	SK	346.68	34.67	28.85	19.66	12.70	8.26	6.45	4.89	1949.27	Winnipeg	BASF
3640	Francis	SK	233.20	18.18	13.90	9.36	6.00	3.88	3.03	2.32	892.98	Winnipeg	BASF
3641	Frontier	SK	345.66	34.57	28.76	19.60	12.66	8.24	6.42	4.88	1942.77	Winnipeg	BASF
3642	Gerald	SK	233.20	18.17	13.90	9.35	6.00	3.88	3.03	2.31	892.43	Winnipeg	BASF
3643	Glaslyn	SK	346.34	34.63	28.82	19.64	12.69	8.25	6.44	4.89	1947.10	Winnipeg	BASF
3644	Glenavon	SK	233.20	17.72	13.48	9.07	5.81	3.76	2.94	2.24	863.26	Winnipeg	BASF
3645	Goodeve	SK	233.20	18.95	14.60	9.84	6.31	4.09	3.19	2.44	942.24	Winnipeg	BASF
3646	Govan	SK	233.20	21.46	16.88	11.41	7.33	4.75	3.71	2.83	1103.18	Winnipeg	BASF
3647	Grand Coulee	SK	233.20	18.08	13.81	9.30	5.96	3.86	3.01	2.30	886.61	Winnipeg	BASF
3648	Gravelbourg	SK	250.33	25.03	20.12	13.64	8.79	5.70	4.45	3.39	1332.06	Winnipeg	BASF
3542	Ste Anne	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3543	Ste Rose Du Lac	MB	190.80	12.09	10.95	7.55	4.91	3.21	2.50	1.89	774.36	Winnipeg	BASF
3544	Steinbach	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3545	Stonewall	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3546	Strathclair	MB	190.80	11.15	10.10	6.97	4.53	2.96	2.31	1.74	673.68	Winnipeg	BASF
3547	Swan Lake	MB	190.80	7.13	6.46	4.45	2.89	1.89	1.47	1.11	456.46	Winnipeg	BASF
3548	Swan River	MB	190.80	18.84	17.07	11.77	7.65	5.00	3.90	2.94	1206.70	Winnipeg	BASF
3549	Teulon	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3550	The Pas	MB	250.93	25.09	22.74	15.68	10.19	6.67	5.19	3.92	1607.54	Winnipeg	BASF
3551	Treherne	MB	190.80	5.76	5.22	3.60	2.34	1.53	1.19	0.90	348.30	Winnipeg	BASF
3552	Turtle Mountain	MB	190.80	14.54	13.18	9.09	5.91	3.86	3.01	2.27	931.77	Winnipeg	BASF
3553	Virden	MB	190.80	12.25	11.10	7.66	4.98	3.25	2.54	1.91	740.33	Winnipeg	BASF
3554	Warren	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3555	Waskada	MB	190.80	15.20	13.77	9.50	6.17	4.04	3.15	2.37	918.47	Winnipeg	BASF
3556	Wawanesa	MB	190.80	10.24	9.28	6.40	4.16	2.72	2.12	1.60	618.80	Winnipeg	BASF
3557	Wellwood	MB	190.80	7.90	7.16	4.94	3.21	2.10	1.64	1.23	506.33	Winnipeg	BASF
3558	Westbourne	MB	190.80	5.37	4.87	3.36	2.18	1.43	1.11	0.84	324.77	Winnipeg	BASF
3559	Winkler	MB	190.80	5.57	5.05	3.48	2.26	1.48	1.15	0.87	356.73	Winnipeg	BASF
3560	Winnipeg	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3561	Abbey	SK	312.53	31.25	25.75	17.53	11.31	7.36	5.74	4.36	1730.54	Winnipeg	BASF
3562	Aberdeen	SK	273.27	27.33	22.19	15.08	9.72	6.31	4.93	3.75	1478.98	Winnipeg	BASF
3563	Abernethy	SK	233.20	17.48	13.27	8.92	5.72	3.70	2.89	2.21	848.40	Winnipeg	BASF
3564	Alameda	SK	233.20	19.42	15.03	10.13	6.51	4.21	3.29	2.51	972.56	Winnipeg	BASF
3565	Albertville	SK	324.36	32.44	26.83	18.27	11.79	7.67	5.98	4.54	1806.33	Winnipeg	BASF
3566	Antler	SK	233.20	18.91	14.57	9.82	6.30	4.08	3.19	2.43	940.07	Winnipeg	BASF
3567	Arborfield	SK	281.43	28.14	22.93	15.59	10.05	6.53	5.10	3.87	1531.30	Winnipeg	BASF
3568	Archerwill	SK	243.23	24.32	19.47	13.20	8.50	5.51	4.30	3.28	1286.58	Winnipeg	BASF
3569	Assiniboia	SK	245.60	24.56	19.69	13.35	8.59	5.58	4.35	3.31	1301.74	Winnipeg	BASF
3570	Avonlea	SK	233.20	20.33	15.86	10.71	6.88	4.46	3.48	2.65	1030.99	Winnipeg	BASF
3571	Aylsham	SK	301.52	30.15	24.75	16.84	10.87	7.06	5.51	4.19	1660.00	Winnipeg	BASF
3572	Balcarres	SK	233.20	17.81	13.57	9.13	5.85	3.79	2.96	2.26	869.63	Winnipeg	BASF
3573	Balgonie	SK	233.20	17.05	12.88	8.65	5.54	3.58	2.80	2.14	820.79	Winnipeg	BASF
3574	Bankend	SK	233.20	20.70	16.19	10.93	7.03	4.55	3.55	2.71	1054.34	Winnipeg	BASF
3575	Battleford	SK	344.49	34.45	28.65	19.53	12.61	8.20	6.40	4.86	1935.26	Winnipeg	BASF
3576	Beechy	SK	295.63	29.56	24.22	16.47	10.63	6.91	5.39	4.09	1622.25	Winnipeg	BASF
3577	Bengough	SK	233.20	23.12	18.38	12.45	8.01	5.19	4.06	3.09	1209.34	Winnipeg	BASF
3578	Biggar	SK	305.41	30.54	25.11	17.08	11.02	7.17	5.59	4.25	1684.93	Winnipeg	BASF
3579	Birch Hills	SK	289.88	28.99	23.70	16.11	10.39	6.75	5.27	4.00	1585.44	Winnipeg	BASF
3580	Bjorkdale	SK	277.53	27.75	22.58	15.34	9.89	6.43	5.01	3.81	1506.31	Winnipeg	BASF
3581	Blaine Lake	SK	300.11	30.01	24.63	16.75	10.81	7.03	5.48	4.16	1650.96	Winnipeg	BASF
2587	Fairview	AB	496.48	49.65	42.36	28.98	18.75	12.22	9.53	7.22	2831.35	Saskatoon	BASF
2588	Falher	AB	428.05	42.81	36.16	24.70	15.97	10.40	8.11	6.15	2403.71	Saskatoon	BASF
2589	Foremost	AB	268.68	26.87	21.71	14.74	9.50	6.17	4.81	3.66	1407.65	Saskatoon	BASF
2590	Forestburg	AB	239.03	20.00	15.49	10.44	6.71	4.34	3.39	2.59	978.07	Saskatoon	BASF
2591	Fort MacLeod	AB	239.03	23.72	18.87	12.77	8.22	5.33	4.16	3.17	1211.12	Saskatoon	BASF
2592	Fort Saskatchewan	AB	239.03	16.88	12.66	8.49	5.44	3.51	2.75	2.10	783.15	Saskatoon	BASF
2593	Galahad	AB	239.03	20.23	15.70	10.59	6.80	4.40	3.44	2.62	992.90	Saskatoon	BASF
2594	Girouxville	AB	434.04	43.40	36.70	25.07	16.22	10.56	8.24	6.24	2441.13	Saskatoon	BASF
2595	Gleichen	AB	239.03	18.81	14.41	9.70	6.22	4.03	3.15	2.40	903.91	Saskatoon	BASF
2596	Glendon	AB	239.03	21.10	16.48	11.13	7.15	4.63	3.62	2.76	1046.92	Saskatoon	BASF
2597	Grande Prairie	AB	441.74	44.17	37.40	25.56	16.53	10.76	8.39	6.36	2489.24	Saskatoon	BASF
2598	Grassy Lake	AB	258.12	25.81	20.76	14.08	9.07	5.89	4.59	3.50	1341.63	Saskatoon	BASF
2599	Grimshaw	AB	470.82	47.08	40.03	27.37	17.71	11.54	9.00	6.82	2670.99	Saskatoon	BASF
2600	Guy	AB	414.80	41.48	34.96	23.87	15.43	10.05	7.84	5.94	2320.85	Saskatoon	BASF
2601	Hairy Hill	AB	239.03	17.59	13.30	8.94	5.73	3.70	2.89	2.21	827.64	Saskatoon	BASF
2602	Halkirk	AB	239.03	19.59	15.12	10.19	6.54	4.23	3.31	2.52	952.61	Saskatoon	BASF
2603	Hanna	AB	239.03	19.81	15.32	10.33	6.63	4.29	3.35	2.56	966.76	Saskatoon	BASF
2604	High Level	AB	612.80	61.28	52.90	36.25	23.48	15.31	11.93	9.04	3558.35	Saskatoon	BASF
2605	High Prairie	AB	386.57	38.66	32.40	22.11	14.29	9.30	7.25	5.50	2144.45	Saskatoon	BASF
2606	High River	AB	239.03	20.33	15.79	10.66	6.84	4.43	3.46	2.64	999.25	Saskatoon	BASF
2607	Hines Creek	AB	505.03	50.50	43.13	29.51	19.10	12.45	9.70	7.35	2884.81	Saskatoon	BASF
2608	Hussar	AB	239.03	18.54	14.16	9.53	6.11	3.95	3.09	2.36	886.96	Saskatoon	BASF
2609	Hythe	AB	474.24	47.42	40.34	27.59	17.85	11.63	9.07	6.87	2692.37	Saskatoon	BASF
2610	Innisfail	AB	239.03	22.71	17.94	12.14	7.81	5.06	3.95	3.01	1147.56	Saskatoon	BASF
2611	Innisfree	AB	239.03	16.37	12.20	8.18	5.23	3.38	2.64	2.02	751.37	Saskatoon	BASF
2612	Irma	AB	239.03	18.19	13.85	9.32	5.97	3.86	3.02	2.30	865.38	Saskatoon	BASF
2613	Iron Springs	AB	260.76	26.08	21.00	14.24	9.18	5.96	4.65	3.54	1358.14	Saskatoon	BASF
2614	Killam	AB	239.03	19.52	15.06	10.15	6.51	4.22	3.29	2.51	948.41	Saskatoon	BASF
2615	Kirriemuir	AB	239.03	18.04	13.71	9.22	5.91	3.82	2.99	2.28	855.94	Saskatoon	BASF
2616	Kitscoty	AB	239.03	17.70	13.41	9.01	5.77	3.73	2.92	2.23	834.73	Saskatoon	BASF
2617	La Glace	AB	462.26	46.23	39.26	26.84	17.36	11.31	8.82	6.69	2617.53	Saskatoon	BASF
2618	Lac La Biche	AB	239.26	23.93	19.05	12.90	8.30	5.39	4.20	3.20	1223.75	Saskatoon	BASF
2619	Lacombe	AB	239.03	21.59	16.93	11.44	7.35	4.76	3.72	2.84	1077.65	Saskatoon	BASF
2620	Lacrete	AB	560.20	56.02	48.13	32.96	21.34	13.91	10.85	8.22	3229.60	Saskatoon	BASF
2621	Lamont	AB	239.03	16.74	12.54	8.41	5.38	3.48	2.72	2.08	774.67	Saskatoon	BASF
2622	Lavoy	AB	239.03	16.37	12.20	8.18	5.23	3.38	2.64	2.02	751.37	Saskatoon	BASF
2623	Leduc	AB	239.03	17.76	13.46	9.05	5.80	3.75	2.93	2.24	838.23	Saskatoon	BASF
2624	Legal	AB	239.03	18.50	14.13	9.51	6.10	3.95	3.08	2.35	884.85	Saskatoon	BASF
2625	Lethbridge	AB	255.48	25.55	20.52	13.91	8.96	5.82	4.54	3.45	1325.13	Saskatoon	BASF
2626	Linden	AB	239.03	18.23	13.89	9.34	5.99	3.87	3.03	2.31	867.90	Saskatoon	BASF
2627	Lloydminster	AB	239.03	17.63	13.34	8.96	5.74	3.71	2.90	2.22	830.01	Saskatoon	BASF
2628	Lomond	AB	239.03	21.25	16.62	11.23	7.21	4.67	3.65	2.78	1056.46	Saskatoon	BASF
2629	Lougheed	AB	239.03	20.64	16.07	10.85	6.97	4.51	3.53	2.69	1018.63	Saskatoon	BASF
2630	Magrath	AB	270.19	27.02	21.85	14.83	9.56	6.21	4.84	3.68	1417.08	Saskatoon	BASF
2631	Mallaig	AB	239.03	19.22	14.78	9.96	6.39	4.13	3.23	2.46	929.34	Saskatoon	BASF
2632	Manning	AB	510.16	51.02	43.60	29.83	19.31	12.58	9.81	7.43	2916.88	Saskatoon	BASF
2633	Marwayne	AB	239.03	18.53	14.16	9.53	6.11	3.95	3.09	2.36	886.59	Saskatoon	BASF
2634	Mayerthorpe	AB	239.03	22.85	18.07	12.23	7.86	5.10	3.98	3.03	1156.46	Saskatoon	BASF
2635	McLennan	AB	406.67	40.67	34.22	23.36	15.10	9.83	7.67	5.82	2270.07	Saskatoon	BASF
2636	Medicine Hat	AB	239.03	23.59	18.74	12.69	8.16	5.30	4.13	3.15	1202.53	Saskatoon	BASF
2637	Milk River	AB	281.89	28.19	22.91	15.56	10.03	6.52	5.09	3.87	1490.17	Saskatoon	BASF
2638	Milo	AB	239.03	20.94	16.35	11.04	7.09	4.59	3.59	2.73	1037.39	Saskatoon	BASF
2639	Morinville	AB	239.03	17.62	13.34	8.96	5.74	3.71	2.90	2.22	829.76	Saskatoon	BASF
2640	Mossleigh	AB	239.03	19.89	15.39	10.38	6.66	4.31	3.37	2.57	971.71	Saskatoon	BASF
2641	Mundare	AB	239.03	16.44	12.26	8.22	5.26	3.40	2.65	2.03	755.61	Saskatoon	BASF
2642	Myrnam	AB	239.03	17.35	13.09	8.79	5.63	3.64	2.84	2.17	812.81	Saskatoon	BASF
2643	Nampa	AB	443.45	44.34	37.55	25.66	16.60	10.81	8.43	6.39	2499.93	Saskatoon	BASF
2644	Nanton	AB	239.03	21.55	16.90	11.42	7.34	4.76	3.71	2.83	1075.53	Saskatoon	BASF
2645	Neerlandia	AB	239.03	22.61	17.85	12.08	7.77	5.04	3.93	2.99	1141.33	Saskatoon	BASF
2646	New Dayton	AB	262.65	26.26	21.17	14.36	9.25	6.01	4.69	3.57	1369.92	Saskatoon	BASF
2647	New Norway	AB	239.03	18.98	14.56	9.81	6.29	4.07	3.18	2.43	914.51	Saskatoon	BASF
2648	Nisku	AB	239.03	17.32	13.06	8.77	5.62	3.63	2.84	2.17	810.69	Saskatoon	BASF
2649	Nobleford	AB	239.03	23.49	18.65	12.63	8.12	5.27	4.11	3.13	1196.29	Saskatoon	BASF
2650	Okotoks	AB	242.66	24.27	19.36	13.11	8.44	5.48	4.27	3.25	1245.02	Saskatoon	BASF
2651	Olds	AB	239.03	22.88	18.10	12.24	7.88	5.11	3.99	3.04	1158.15	Saskatoon	BASF
2652	Onoway	AB	239.03	18.98	14.56	9.81	6.29	4.07	3.18	2.43	914.51	Saskatoon	BASF
2653	Oyen	AB	239.03	19.32	14.88	10.02	6.43	4.16	3.25	2.48	936.11	Saskatoon	BASF
2654	Paradise Valley	AB	239.03	18.91	14.50	9.76	6.26	4.05	3.17	2.42	910.17	Saskatoon	BASF
2655	Peers	AB	239.03	23.83	18.96	12.84	8.26	5.36	4.18	3.18	1217.48	Saskatoon	BASF
2656	Penhold	AB	239.03	22.57	17.82	12.05	7.75	5.03	3.92	2.99	1139.09	Saskatoon	BASF
2657	Picture Butte	AB	256.23	25.62	20.59	13.96	8.99	5.84	4.56	3.47	1329.84	Saskatoon	BASF
2658	Pincher Creek	AB	280.38	28.04	22.77	15.47	9.97	6.48	5.06	3.84	1480.74	Saskatoon	BASF
2659	Ponoka	AB	239.03	20.77	16.19	10.93	7.02	4.55	3.55	2.71	1026.80	Saskatoon	BASF
2660	Provost	AB	239.03	19.63	15.15	10.21	6.55	4.24	3.31	2.53	954.97	Saskatoon	BASF
2661	Raymond	AB	266.42	26.64	21.51	14.60	9.41	6.11	4.77	3.62	1393.50	Saskatoon	BASF
2662	Red Deer	AB	239.03	22.71	17.94	12.14	7.81	5.06	3.95	3.01	1147.56	Saskatoon	BASF
2663	Rimbey	AB	239.03	22.27	17.54	11.86	7.63	4.94	3.86	2.94	1120.02	Saskatoon	BASF
2664	Rivercourse	AB	239.03	19.10	14.67	9.88	6.34	4.10	3.20	2.45	921.96	Saskatoon	BASF
2665	Rocky Mountain House	AB	278.87	27.89	22.64	15.38	9.91	6.44	5.02	3.82	1471.31	Saskatoon	BASF
2666	Rocky View	AB	239.03	22.91	18.13	12.27	7.89	5.12	3.99	3.04	1094.60	Saskatoon	BASF
2667	Rolling Hills	AB	250.58	25.06	20.07	13.61	8.76	5.69	4.44	3.38	1294.48	Saskatoon	BASF
2668	Rosalind	AB	239.03	19.15	14.72	9.91	6.36	4.12	3.22	2.45	925.10	Saskatoon	BASF
2669	Rosebud	AB	239.03	18.27	13.92	9.36	6.00	3.88	3.03	2.32	870.01	Saskatoon	BASF
2670	Rosedale	AB	239.03	18.61	14.23	9.57	6.14	3.97	3.10	2.37	891.20	Saskatoon	BASF
2671	Rycroft	AB	473.81	47.38	40.30	27.56	17.83	11.62	9.06	6.87	2689.70	Saskatoon	BASF
2672	Ryley	AB	239.03	17.01	12.78	8.58	5.49	3.55	2.77	2.12	791.62	Saskatoon	BASF
2673	Sedgewick	AB	239.03	20.87	16.28	10.99	7.06	4.57	3.57	2.72	1032.77	Saskatoon	BASF
2674	Sexsmith	AB	447.72	44.77	37.94	25.93	16.77	10.92	8.52	6.46	2526.66	Saskatoon	BASF
2675	Silver Valley	AB	499.04	49.90	42.59	29.14	18.86	12.29	9.58	7.26	2847.39	Saskatoon	BASF
2676	Slave Lake	AB	292.07	29.21	23.83	16.20	10.45	6.79	5.30	4.03	1553.83	Saskatoon	BASF
2677	Smoky Lake	AB	239.03	18.50	14.13	9.51	6.10	3.95	3.08	2.35	884.85	Saskatoon	BASF
2678	Spirit River	AB	478.09	47.81	40.69	27.83	18.00	11.73	9.15	6.93	2716.42	Saskatoon	BASF
2679	Spruce Grove	AB	239.03	17.55	13.27	8.92	5.71	3.69	2.89	2.21	825.52	Saskatoon	BASF
2680	Spruce View	AB	239.03	23.66	18.80	12.73	8.19	5.31	4.15	3.16	1206.88	Saskatoon	BASF
2681	St Albert	AB	239.03	16.81	12.60	8.45	5.41	3.50	2.73	2.09	778.91	Saskatoon	BASF
2682	St Isidore	AB	452.00	45.20	38.33	26.20	16.94	11.04	8.61	6.52	2553.38	Saskatoon	BASF
2683	St Paul	AB	239.03	20.30	15.77	10.64	6.83	4.42	3.45	2.63	997.41	Saskatoon	BASF
2684	Standard	AB	239.03	18.40	14.04	9.45	6.06	3.92	3.06	2.34	878.49	Saskatoon	BASF
2685	Stettler	AB	239.03	18.47	14.10	9.49	6.09	3.94	3.08	2.35	882.73	Saskatoon	BASF
2686	Stirling	AB	264.16	26.42	21.30	14.46	9.31	6.05	4.72	3.59	1379.36	Saskatoon	BASF
2687	Stony Plain	AB	239.03	17.83	13.52	9.09	5.82	3.77	2.94	2.25	842.47	Saskatoon	BASF
2688	Strathmore	AB	239.03	18.37	14.01	9.43	6.04	3.91	3.05	2.33	876.37	Saskatoon	BASF
2689	Strome	AB	239.03	18.94	14.53	9.79	6.28	4.06	3.17	2.42	912.39	Saskatoon	BASF
2690	Sturgeon County	AB	236.57	18.02	13.82	9.31	5.97	3.86	3.02	2.30	858.88	Saskatoon	BASF
2691	Sturgeon Valley	AB	236.57	17.19	13.07	8.79	5.63	3.64	2.85	2.17	807.46	Saskatoon	BASF
2692	Sunnybrook	AB	239.03	19.62	15.15	10.21	6.55	4.24	3.31	2.53	954.76	Saskatoon	BASF
2693	Sylvan Lake	AB	239.03	23.15	18.34	12.41	7.99	5.18	4.04	3.08	1175.10	Saskatoon	BASF
2694	Taber	AB	258.50	25.85	20.79	14.10	9.08	5.90	4.60	3.50	1343.99	Saskatoon	BASF
2695	Thorhild	AB	239.03	18.50	14.13	9.51	6.10	3.95	3.08	2.35	884.85	Saskatoon	BASF
2696	Three Hills	AB	239.03	18.64	14.26	9.60	6.15	3.98	3.11	2.37	893.32	Saskatoon	BASF
2697	Tofield	AB	239.03	17.01	12.78	8.58	5.49	3.55	2.77	2.12	791.62	Saskatoon	BASF
2698	Torrington	AB	239.03	19.01	14.59	9.83	6.31	4.08	3.19	2.43	916.63	Saskatoon	BASF
2699	Trochu	AB	239.03	19.18	14.75	9.93	6.37	4.13	3.22	2.46	927.22	Saskatoon	BASF
2700	Turin	AB	245.30	24.53	19.60	13.28	8.55	5.55	4.33	3.29	1261.47	Saskatoon	BASF
2701	Two Hills	AB	239.03	17.55	13.27	8.92	5.71	3.69	2.89	2.21	825.52	Saskatoon	BASF
2702	Valleyview	AB	384.01	38.40	32.17	21.95	14.18	9.23	7.20	5.46	2128.41	Saskatoon	BASF
2703	Vauxhall	AB	251.33	25.13	20.14	13.65	8.79	5.71	4.45	3.39	1299.19	Saskatoon	BASF
2704	Vegreville	AB	239.03	16.33	12.17	8.16	5.22	3.37	2.63	2.01	749.25	Saskatoon	BASF
2705	Vermilion	AB	239.03	16.37	12.20	8.18	5.23	3.38	2.64	2.02	751.37	Saskatoon	BASF
2706	Veteran	AB	239.03	19.59	15.12	10.19	6.54	4.23	3.31	2.52	952.61	Saskatoon	BASF
2707	Viking	AB	239.03	17.96	13.64	9.17	5.88	3.80	2.97	2.27	850.95	Saskatoon	BASF
2708	Vulcan	AB	239.03	21.45	16.81	11.35	7.30	4.73	3.69	2.81	1069.17	Saskatoon	BASF
2709	Wainwright	AB	239.03	18.61	14.23	9.58	6.14	3.97	3.10	2.37	891.31	Saskatoon	BASF
2710	Wanham	AB	455.85	45.59	38.68	26.44	17.10	11.14	8.69	6.58	2577.44	Saskatoon	BASF
2711	Warburg	AB	239.03	20.03	15.52	10.46	6.72	4.35	3.40	2.59	980.19	Saskatoon	BASF
2712	Warner	AB	272.83	27.28	22.09	15.00	9.67	6.28	4.90	3.73	1433.58	Saskatoon	BASF
2713	Waskatenau	AB	239.03	18.46	14.09	9.48	6.08	3.93	3.07	2.35	882.01	Saskatoon	BASF
2714	Westlock	AB	239.03	19.79	15.30	10.32	6.62	4.29	3.35	2.55	965.36	Saskatoon	BASF
2715	Wetaskiwin	AB	239.03	19.28	14.84	10.00	6.42	4.15	3.24	2.48	933.58	Saskatoon	BASF
2716	Whitecourt	AB	244.36	24.44	19.51	13.22	8.51	5.52	4.31	3.28	1255.61	Saskatoon	BASF
2717	Winfield	AB	239.03	21.32	16.68	11.27	7.24	4.69	3.66	2.79	1060.70	Saskatoon	BASF
2718	Dawson Creek	BC	513.15	51.32	43.87	30.02	19.43	12.66	9.87	7.48	2935.59	Saskatoon	BASF
2719	Delta	BC	765.47	76.55	66.74	45.79	29.68	19.36	15.09	11.42	4512.54	Saskatoon	BASF
2720	Fort St. John	BC	555.92	55.59	47.75	32.69	21.17	13.80	10.76	8.15	3202.87	Saskatoon	BASF
2721	Grindrod	BC	547.79	54.78	47.01	32.18	20.84	13.58	10.59	8.02	3152.09	Saskatoon	BASF
2722	Kamloops	BC	579.01	57.90	49.84	34.13	22.10	14.41	11.24	8.51	3347.20	Saskatoon	BASF
2723	Kelowna	BC	600.82	60.08	51.81	35.50	22.99	14.99	11.69	8.85	3483.51	Saskatoon	BASF
2724	Keremeos	BC	662.40	66.24	57.40	39.35	25.49	16.63	12.96	9.81	3868.40	Saskatoon	BASF
2725	Naramata	BC	621.35	62.13	53.68	36.78	23.82	15.53	12.11	9.17	3611.81	Saskatoon	BASF
2726	Oliver	BC	657.27	65.73	56.93	39.03	25.28	16.49	12.86	9.73	3836.32	Saskatoon	BASF
2727	Penticton	BC	637.17	63.72	55.11	37.77	24.47	15.96	12.44	9.42	3710.70	Saskatoon	BASF
2728	Prince George	BC	593.98	59.40	51.19	35.07	22.71	14.81	11.55	8.74	3440.75	Saskatoon	BASF
2729	Rolla	BC	517.86	51.79	44.30	30.31	19.62	12.79	9.97	7.55	2964.99	Saskatoon	BASF
2730	Vernon	BC	576.87	57.69	49.64	34.00	22.02	14.35	11.19	8.48	3333.84	Saskatoon	BASF
2731	Altamont	MB	239.03	23.13	18.32	12.40	7.98	5.17	4.04	3.08	1173.85	Saskatoon	BASF
2732	Altona	MB	242.15	24.22	19.31	13.08	8.42	5.46	4.26	3.25	1241.83	Saskatoon	BASF
2733	Angusville	MB	239.03	22.49	17.75	12.00	7.72	5.00	3.91	2.98	1134.15	Saskatoon	BASF
2734	Arborg	MB	239.03	22.99	18.20	12.32	7.92	5.14	4.01	3.06	1165.51	Saskatoon	BASF
2735	Arnaud	MB	241.51	24.15	19.25	13.04	8.39	5.45	4.25	3.24	1237.83	Saskatoon	BASF
2736	Baldur	MB	239.03	23.78	18.91	12.81	8.24	5.35	4.17	3.18	1214.53	Saskatoon	BASF
2737	Beausejour	MB	239.03	23.38	18.56	12.56	8.08	5.24	4.09	3.12	1189.85	Saskatoon	BASF
2738	Benito	MB	239.03	23.32	18.50	12.52	8.06	5.23	4.08	3.11	1186.02	Saskatoon	BASF
2739	Binscarth	MB	239.03	22.49	17.75	12.00	7.72	5.00	3.91	2.98	1134.15	Saskatoon	BASF
2740	Birch River	MB	267.17	26.72	21.58	14.64	9.44	6.13	4.78	3.64	1398.22	Saskatoon	BASF
2741	Birtle	MB	239.03	23.47	18.64	12.62	8.12	5.27	4.11	3.13	1195.45	Saskatoon	BASF
2742	Boissevain	MB	281.89	28.19	22.91	15.56	10.03	6.52	5.09	3.87	1490.17	Saskatoon	BASF
2743	Brandon	MB	247.18	24.72	19.77	13.40	8.62	5.60	4.37	3.32	1201.19	Saskatoon	BASF
2744	Brunkild	MB	239.03	22.46	17.72	11.98	7.70	5.00	3.90	2.97	1131.87	Saskatoon	BASF
2745	Carberry	MB	239.03	21.53	16.88	11.40	7.33	4.75	3.71	2.83	1073.90	Saskatoon	BASF
2746	Carman	MB	239.03	22.33	17.60	11.90	7.65	4.96	3.87	2.95	1123.88	Saskatoon	BASF
2747	Cartwright	MB	280.38	28.04	22.77	15.47	9.97	6.48	5.06	3.84	1480.74	Saskatoon	BASF
2748	Crystal City	MB	246.94	24.69	19.74	13.38	8.61	5.59	4.36	3.32	1271.73	Saskatoon	BASF
2749	Cypress River	MB	239.03	22.30	17.57	11.88	7.64	4.95	3.87	2.95	1121.88	Saskatoon	BASF
2750	Darlingford	MB	239.03	23.80	18.93	12.82	8.25	5.35	4.18	3.18	1215.84	Saskatoon	BASF
2751	Dauphin	MB	246.43	24.64	19.70	13.35	8.59	5.58	4.35	3.31	1268.54	Saskatoon	BASF
2752	Deloraine	MB	283.40	28.34	23.05	15.66	10.10	6.56	5.12	3.89	1499.60	Saskatoon	BASF
2753	Domain	MB	239.03	22.10	17.40	11.76	7.56	4.90	3.83	2.92	1109.88	Saskatoon	BASF
2754	Dominion City	MB	245.35	24.54	19.60	13.28	8.55	5.55	4.33	3.30	1261.82	Saskatoon	BASF
2755	Dufrost	MB	239.03	23.77	18.90	12.80	8.24	5.34	4.17	3.18	1213.84	Saskatoon	BASF
2756	Dugald	MB	239.03	21.75	17.08	11.54	7.42	4.81	3.75	2.86	1087.89	Saskatoon	BASF
2757	Dunrea	MB	274.72	27.47	22.26	15.12	9.74	6.33	4.94	3.75	1445.37	Saskatoon	BASF
2758	Elgin	MB	268.31	26.83	21.68	14.72	9.48	6.16	4.81	3.65	1405.29	Saskatoon	BASF
2759	Elie	MB	239.03	20.92	16.32	11.02	7.08	4.59	3.58	2.73	1035.91	Saskatoon	BASF
2760	Elkhorn	MB	239.03	23.51	18.67	12.64	8.13	5.28	4.12	3.14	1197.81	Saskatoon	BASF
2761	Elm Creek	MB	239.03	21.72	17.05	11.52	7.41	4.80	3.75	2.86	1085.89	Saskatoon	BASF
2762	Emerson	MB	251.43	25.14	20.15	13.66	8.80	5.71	4.46	3.39	1299.80	Saskatoon	BASF
2763	Fannystelle	MB	239.03	21.56	16.90	11.42	7.34	4.76	3.71	2.83	1075.90	Saskatoon	BASF
2764	Fisher Branch	MB	239.03	23.62	18.77	12.71	8.18	5.30	4.14	3.15	1204.32	Saskatoon	BASF
2765	Fork River	MB	267.17	26.72	21.58	14.64	9.44	6.13	4.78	3.64	1398.22	Saskatoon	BASF
2766	Forrest	MB	244.92	24.49	19.56	13.25	8.53	5.54	4.32	3.29	1259.11	Saskatoon	BASF
2767	Foxwarren	MB	239.03	23.10	18.30	12.38	7.96	5.17	4.03	3.07	1171.88	Saskatoon	BASF
2768	Franklin	MB	239.03	23.78	18.91	12.81	8.24	5.35	4.17	3.18	1214.32	Saskatoon	BASF
2769	Gilbert Plains	MB	239.64	23.96	19.08	12.92	8.32	5.40	4.21	3.21	1226.10	Saskatoon	BASF
2770	Gimli	MB	244.39	24.44	19.51	13.22	8.51	5.52	4.31	3.28	1255.82	Saskatoon	BASF
2771	Gladstone	MB	239.03	20.86	16.27	10.98	7.06	4.57	3.57	2.72	1031.91	Saskatoon	BASF
2772	Glenboro	MB	262.65	26.26	21.17	14.36	9.25	6.01	4.69	3.57	1369.92	Saskatoon	BASF
2773	Glossop (Newdale)	MB	239.03	23.62	18.77	12.71	8.18	5.31	4.14	3.15	1204.89	Saskatoon	BASF
2774	Goodlands	MB	288.68	28.87	23.53	15.99	10.31	6.70	5.23	3.97	1532.61	Saskatoon	BASF
2775	Grandview	MB	239.03	23.25	18.43	12.48	8.03	5.21	4.06	3.09	1181.31	Saskatoon	BASF
2776	Gretna	MB	245.03	24.50	19.57	13.26	8.54	5.54	4.32	3.29	1259.82	Saskatoon	BASF
2777	Griswold	MB	249.82	24.98	20.01	13.56	8.73	5.67	4.42	3.37	1289.76	Saskatoon	BASF
2778	Grosse Isle	MB	239.03	21.82	17.14	11.58	7.44	4.83	3.77	2.87	1091.89	Saskatoon	BASF
2779	Gunton	MB	239.03	22.74	17.98	12.16	7.82	5.07	3.96	3.02	1149.86	Saskatoon	BASF
2780	Hamiota	MB	245.30	24.53	19.60	13.28	8.55	5.55	4.33	3.29	1261.47	Saskatoon	BASF
2781	Hargrave	MB	241.90	24.19	19.29	13.07	8.41	5.46	4.26	3.24	1240.25	Saskatoon	BASF
2782	Hartney	MB	266.80	26.68	21.54	14.62	9.42	6.12	4.77	3.63	1395.86	Saskatoon	BASF
2783	High Bluff	MB	239.03	21.34	16.70	11.28	7.25	4.70	3.67	2.80	1061.90	Saskatoon	BASF
2784	Holland	MB	239.03	22.14	17.43	11.78	7.57	4.91	3.83	2.92	1111.88	Saskatoon	BASF
2785	Homewood	MB	239.03	22.30	17.57	11.88	7.64	4.95	3.87	2.95	1121.88	Saskatoon	BASF
2786	Inglis	MB	239.03	22.72	17.95	12.15	7.81	5.06	3.95	3.01	1148.30	Saskatoon	BASF
2787	Kane	MB	239.03	23.10	18.30	12.38	7.96	5.17	4.03	3.07	1171.86	Saskatoon	BASF
2788	Kemnay	MB	246.80	24.68	19.73	13.37	8.61	5.59	4.36	3.32	1270.90	Saskatoon	BASF
2789	Kenton	MB	251.33	25.13	20.14	13.65	8.79	5.71	4.45	3.39	1299.19	Saskatoon	BASF
2790	Kenville	MB	243.41	24.34	19.42	13.16	8.47	5.50	4.29	3.27	1249.68	Saskatoon	BASF
2791	Killarney	MB	284.90	28.49	23.18	15.75	10.16	6.60	5.15	3.91	1509.03	Saskatoon	BASF
2792	Landmark	MB	239.03	22.49	17.74	12.00	7.72	5.00	3.91	2.98	1133.87	Saskatoon	BASF
2793	Laurier	MB	247.94	24.79	19.83	13.44	8.65	5.62	4.38	3.34	1277.97	Saskatoon	BASF
2794	Letellier	MB	244.71	24.47	19.54	13.24	8.52	5.53	4.32	3.29	1257.82	Saskatoon	BASF
2795	Lowe Farm	MB	239.03	23.03	18.24	12.34	7.94	5.15	4.02	3.06	1167.86	Saskatoon	BASF
2796	Lundar	MB	239.03	21.75	17.08	11.54	7.42	4.81	3.75	2.86	1087.89	Saskatoon	BASF
2797	MacGregor	MB	239.03	21.18	16.56	11.18	7.19	4.66	3.64	2.77	1051.91	Saskatoon	BASF
2798	Manitou	MB	239.03	23.70	18.85	12.76	8.21	5.33	4.16	3.17	1209.84	Saskatoon	BASF
2799	Mariapolis	MB	239.09	23.91	19.03	12.89	8.30	5.38	4.20	3.20	1222.70	Saskatoon	BASF
2800	Marquette	MB	239.03	21.37	16.73	11.30	7.26	4.71	3.67	2.80	1063.90	Saskatoon	BASF
2801	Mather	MB	280.38	28.04	22.77	15.47	9.97	6.48	5.06	3.84	1480.74	Saskatoon	BASF
2802	McCreary	MB	246.80	24.68	19.73	13.37	8.61	5.59	4.36	3.32	1270.90	Saskatoon	BASF
2803	Meadows	MB	239.03	21.43	16.79	11.34	7.29	4.72	3.69	2.81	1067.90	Saskatoon	BASF
2804	Medora	MB	278.87	27.89	22.64	15.38	9.91	6.44	5.02	3.82	1471.31	Saskatoon	BASF
2805	Melita	MB	277.74	27.77	22.54	15.31	9.87	6.41	5.00	3.80	1464.23	Saskatoon	BASF
2806	Miami	MB	239.03	23.03	18.24	12.34	7.94	5.15	4.02	3.06	1167.86	Saskatoon	BASF
2807	Miniota	MB	244.54	24.45	19.53	13.23	8.52	5.53	4.31	3.28	1256.75	Saskatoon	BASF
2808	Minitonas	MB	257.74	25.77	20.72	14.06	9.05	5.88	4.59	3.49	1339.27	Saskatoon	BASF
2809	Minnedosa	MB	239.03	23.66	18.81	12.74	8.19	5.32	4.15	3.16	1207.24	Saskatoon	BASF
2810	Minto	MB	272.08	27.21	22.02	14.95	9.64	6.26	4.88	3.71	1428.87	Saskatoon	BASF
2811	Morden	MB	239.03	23.86	18.99	12.86	8.28	5.37	4.19	3.19	1219.84	Saskatoon	BASF
2812	Morris	MB	239.03	23.42	18.59	12.58	8.09	5.25	4.10	3.12	1191.85	Saskatoon	BASF
2813	Neepawa	MB	239.03	20.89	16.30	11.00	7.07	4.58	3.58	2.73	1033.91	Saskatoon	BASF
2814	Nesbitt	MB	265.29	26.53	21.41	14.53	9.36	6.08	4.74	3.61	1386.43	Saskatoon	BASF
2815	Newdale	MB	239.03	23.66	18.81	12.74	8.19	5.32	4.15	3.16	1207.24	Saskatoon	BASF
2816	Ninga	MB	287.92	28.79	23.46	15.94	10.28	6.68	5.21	3.96	1527.89	Saskatoon	BASF
2817	Niverville	MB	239.03	22.39	17.66	11.94	7.68	4.98	3.89	2.96	1127.87	Saskatoon	BASF
2818	Notre Dame de Lourdes	MB	239.03	22.68	17.92	12.12	7.80	5.05	3.95	3.01	1145.87	Saskatoon	BASF
2819	Oak Bluff	MB	239.03	21.40	16.76	11.32	7.28	4.71	3.68	2.81	1065.90	Saskatoon	BASF
2820	Oak River	MB	246.05	24.60	19.66	13.32	8.58	5.57	4.34	3.31	1266.19	Saskatoon	BASF
2821	Oakbank	MB	239.03	21.69	17.02	11.50	7.39	4.79	3.74	2.85	1083.89	Saskatoon	BASF
2822	Oakville	MB	239.03	20.98	16.38	11.06	7.11	4.60	3.60	2.74	1039.91	Saskatoon	BASF
2823	Petersfield	MB	239.03	23.65	18.80	12.73	8.19	5.31	4.15	3.16	1206.36	Saskatoon	BASF
2824	Pierson	MB	280.38	28.04	22.77	15.47	9.97	6.48	5.06	3.84	1480.74	Saskatoon	BASF
2825	Pilot Mound	MB	243.99	24.40	19.48	13.20	8.49	5.51	4.30	3.27	1253.34	Saskatoon	BASF
2826	Pine Falls	MB	258.15	25.81	20.76	14.08	9.07	5.89	4.60	3.50	1341.78	Saskatoon	BASF
2827	Plum Coulee	MB	240.23	24.02	19.14	12.96	8.34	5.41	4.22	3.22	1229.83	Saskatoon	BASF
2828	Plumas	MB	239.03	21.53	16.88	11.40	7.33	4.75	3.71	2.83	1073.90	Saskatoon	BASF
2829	Portage La Prairie	MB	239.03	20.86	16.27	10.98	7.06	4.57	3.57	2.72	1031.91	Saskatoon	BASF
2830	Rathwell	MB	239.03	22.10	17.40	11.76	7.56	4.90	3.83	2.92	1109.88	Saskatoon	BASF
2831	Reston	MB	264.91	26.49	21.37	14.50	9.34	6.07	4.74	3.60	1384.07	Saskatoon	BASF
2832	River Hills	MB	250.47	25.05	20.06	13.60	8.76	5.68	4.44	3.38	1293.80	Saskatoon	BASF
2833	Rivers	MB	245.30	24.53	19.60	13.28	8.55	5.55	4.33	3.29	1261.47	Saskatoon	BASF
2834	Roblin	MB	239.03	21.02	16.42	11.08	7.12	4.61	3.60	2.75	1042.20	Saskatoon	BASF
2835	Roland	MB	239.03	23.03	18.24	12.34	7.94	5.15	4.02	3.06	1167.86	Saskatoon	BASF
2836	Rosenort	MB	239.03	23.22	18.41	12.46	8.02	5.20	4.06	3.09	1179.85	Saskatoon	BASF
2837	Rossburn	MB	239.03	23.40	18.57	12.57	8.09	5.25	4.09	3.12	1190.74	Saskatoon	BASF
2838	Rosser	MB	239.03	21.56	16.90	11.42	7.34	4.76	3.71	2.83	1075.90	Saskatoon	BASF
2839	Russell	MB	239.03	21.47	16.83	11.37	7.31	4.73	3.70	2.82	1070.50	Saskatoon	BASF
2840	Selkirk	MB	239.03	22.46	17.72	11.98	7.70	5.00	3.90	2.97	1131.87	Saskatoon	BASF
2841	Shoal Lake	MB	239.03	23.74	18.88	12.78	8.23	5.34	4.17	3.17	1211.96	Saskatoon	BASF
2842	Sifton	MB	258.12	25.81	20.76	14.08	9.07	5.89	4.59	3.50	1341.63	Saskatoon	BASF
2843	Snowflake	MB	251.51	25.15	20.16	13.67	8.80	5.71	4.46	3.39	1300.32	Saskatoon	BASF
2844	Somerset	MB	239.03	23.06	18.27	12.36	7.95	5.16	4.03	3.07	1169.86	Saskatoon	BASF
2845	Souris	MB	257.37	25.74	20.69	14.03	9.04	5.87	4.58	3.48	1336.92	Saskatoon	BASF
2846	St Claude	MB	239.03	21.75	17.08	11.54	7.42	4.81	3.75	2.86	1087.89	Saskatoon	BASF
2847	St Jean Baptiste	MB	239.03	23.86	18.99	12.86	8.28	5.37	4.19	3.19	1219.84	Saskatoon	BASF
2848	St Joseph	MB	246.31	24.63	19.69	13.34	8.59	5.57	4.35	3.31	1267.82	Saskatoon	BASF
2849	St Leon	MB	239.03	23.06	18.27	12.36	7.95	5.16	4.03	3.07	1169.86	Saskatoon	BASF
2850	Starbuck	MB	239.03	21.56	16.90	11.42	7.34	4.76	3.71	2.83	1075.90	Saskatoon	BASF
2851	Ste Agathe	MB	239.03	22.26	17.54	11.86	7.63	4.94	3.86	2.94	1119.88	Saskatoon	BASF
2852	Ste Anne	MB	239.03	22.97	18.18	12.30	7.91	5.13	4.01	3.05	1163.86	Saskatoon	BASF
2853	Ste Rose du Lac	MB	246.80	24.68	19.73	13.37	8.61	5.59	4.36	3.32	1270.90	Saskatoon	BASF
2854	Steinbach	MB	239.03	23.58	18.73	12.68	8.16	5.29	4.13	3.15	1201.84	Saskatoon	BASF
2855	Stonewall	MB	239.03	21.94	17.25	11.66	7.50	4.86	3.79	2.89	1099.89	Saskatoon	BASF
2856	Strathclair	MB	239.03	23.74	18.88	12.78	8.23	5.34	4.17	3.17	1211.96	Saskatoon	BASF
2857	Swan Lake	MB	239.03	23.32	18.50	12.52	8.06	5.22	4.08	3.11	1185.94	Saskatoon	BASF
2858	Swan River	MB	250.20	25.02	20.04	13.58	8.75	5.68	4.43	3.37	1292.12	Saskatoon	BASF
2859	Teulon	MB	239.03	23.52	18.68	12.64	8.14	5.28	4.12	3.14	1198.19	Saskatoon	BASF
2860	The Pas	MB	319.99	32.00	26.36	17.95	11.58	7.53	5.87	4.46	1728.30	Saskatoon	BASF
2861	Treherne	MB	239.03	22.14	17.43	11.78	7.57	4.91	3.83	2.92	1111.88	Saskatoon	BASF
2862	Turtle Mountain	MB	286.04	28.60	23.29	15.82	10.20	6.63	5.17	3.93	1516.10	Saskatoon	BASF
2863	Virden	MB	247.94	24.79	19.83	13.44	8.65	5.62	4.38	3.34	1277.97	Saskatoon	BASF
2864	Warren	MB	239.03	21.69	17.02	11.50	7.39	4.79	3.74	2.85	1083.89	Saskatoon	BASF
2865	Waskada	MB	286.41	28.64	23.32	15.85	10.22	6.64	5.18	3.94	1518.46	Saskatoon	BASF
2866	Wawanesa	MB	264.91	26.49	21.37	14.50	9.34	6.07	4.74	3.60	1384.07	Saskatoon	BASF
2867	Wellwood	MB	239.03	21.30	16.67	11.26	7.24	4.69	3.66	2.79	1059.90	Saskatoon	BASF
2868	Westbourne	MB	239.03	20.89	16.30	11.00	7.07	4.58	3.58	2.73	1033.91	Saskatoon	BASF
2869	Winkler	MB	239.03	23.80	18.93	12.82	8.25	5.35	4.18	3.18	1215.84	Saskatoon	BASF
2870	Winnipeg	MB	239.03	19.63	15.15	10.21	6.56	4.24	3.31	2.53	900.97	Saskatoon	BASF
2871	Abbey	SK	195.57	16.59	15.04	10.37	6.74	4.41	3.43	2.59	1036.98	Saskatoon	BASF
2872	Aberdeen	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2873	Abernethy	SK	195.57	9.87	8.94	6.17	4.01	2.62	2.04	1.54	616.81	Saskatoon	BASF
2874	Alameda	SK	195.57	19.31	17.50	12.07	7.84	5.13	4.00	3.02	1206.73	Saskatoon	BASF
2875	Albertville	SK	195.57	7.87	7.14	4.92	3.20	2.09	1.63	1.23	492.10	Saskatoon	BASF
2876	Antler	SK	210.05	21.01	19.04	13.13	8.53	5.58	4.35	3.28	1312.83	Saskatoon	BASF
2877	Arborfield	SK	195.57	12.82	11.62	8.01	5.21	3.41	2.65	2.00	801.21	Saskatoon	BASF
2878	Archerwill	SK	195.57	11.23	10.18	7.02	4.56	2.98	2.33	1.76	702.18	Saskatoon	BASF
2879	Assiniboia	SK	195.57	11.11	10.07	6.94	4.51	2.95	2.30	1.74	694.45	Saskatoon	BASF
2880	Avonlea	SK	195.57	8.25	7.48	5.16	3.35	2.19	1.71	1.29	515.65	Saskatoon	BASF
2881	Aylsham	SK	195.57	12.82	11.62	8.01	5.21	3.41	2.65	2.00	801.21	Saskatoon	BASF
2882	Balcarres	SK	195.57	9.31	8.43	5.82	3.78	2.47	1.93	1.45	581.71	Saskatoon	BASF
2883	Balgonie	SK	195.57	6.90	6.25	4.31	2.80	1.83	1.43	1.08	431.01	Saskatoon	BASF
2884	Bankend	SK	195.57	8.61	7.81	5.38	3.50	2.29	1.78	1.35	538.36	Saskatoon	BASF
2885	Battleford	SK	195.57	6.47	5.86	4.04	2.63	1.72	1.34	1.01	404.18	Saskatoon	BASF
2886	Beechy	SK	195.57	8.01	7.26	5.01	3.25	2.13	1.66	1.25	500.53	Saskatoon	BASF
2887	Bengough	SK	195.57	11.26	10.20	7.04	4.57	2.99	2.33	1.76	703.51	Saskatoon	BASF
2888	Biggar	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Saskatoon	BASF
2890	Birch Hills	SK	195.57	6.73	6.10	4.20	2.73	1.79	1.39	1.05	420.43	Saskatoon	BASF
2891	Bjorkdale	SK	195.57	12.06	10.93	7.54	4.90	3.20	2.50	1.89	754.05	Saskatoon	BASF
2892	Blaine Lake	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2893	Bracken	SK	197.60	19.76	17.91	12.35	8.03	5.25	4.09	3.09	1235.02	Saskatoon	BASF
2894	Bredenbury	SK	195.57	14.06	12.75	8.79	5.71	3.74	2.91	2.20	879.01	Saskatoon	BASF
2895	Briercrest	SK	195.57	7.89	7.15	4.93	3.20	2.10	1.63	1.23	492.95	Saskatoon	BASF
2896	Broadview	SK	195.57	12.02	10.89	7.51	4.88	3.19	2.49	1.88	750.99	Saskatoon	BASF
2897	Broderick	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2898	Brooksby	SK	195.57	10.56	9.57	6.60	4.29	2.80	2.18	1.65	659.74	Saskatoon	BASF
2899	Bruno	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2900	Buchanan	SK	195.57	13.42	12.16	8.39	5.45	3.57	2.78	2.10	838.93	Saskatoon	BASF
2901	Cabri	SK	195.57	15.54	14.08	9.71	6.31	4.13	3.22	2.43	970.96	Saskatoon	BASF
2902	Canora	SK	195.57	14.40	13.05	9.00	5.85	3.83	2.98	2.25	900.23	Saskatoon	BASF
2903	Canwood	SK	195.57	7.33	6.64	4.58	2.98	1.95	1.52	1.14	457.85	Saskatoon	BASF
2904	Carievale	SK	222.88	22.29	20.20	13.93	9.05	5.92	4.61	3.48	1392.99	Saskatoon	BASF
2905	Carlyle	SK	195.57	15.25	13.82	9.53	6.20	4.05	3.16	2.38	953.30	Saskatoon	BASF
2906	Carnduff	SK	211.94	21.19	19.21	13.25	8.61	5.63	4.39	3.31	1324.62	Saskatoon	BASF
2907	Carrot River	SK	195.57	13.88	12.57	8.67	5.64	3.69	2.87	2.17	867.22	Saskatoon	BASF
2908	Central Butte	SK	195.57	7.74	7.01	4.84	3.14	2.06	1.60	1.21	483.67	Saskatoon	BASF
2909	Ceylon	SK	195.57	10.43	9.45	6.52	4.24	2.77	2.16	1.63	651.90	Saskatoon	BASF
2910	Choiceland	SK	195.57	11.84	10.73	7.40	4.81	3.14	2.45	1.85	739.91	Saskatoon	BASF
2911	Churchbridge	SK	195.57	14.59	13.22	9.12	5.93	3.88	3.02	2.28	912.02	Saskatoon	BASF
2912	Clavet	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2913	Codette	SK	195.57	12.59	11.41	7.87	5.12	3.35	2.61	1.97	787.06	Saskatoon	BASF
2914	Colgate	SK	195.57	12.02	10.89	7.51	4.88	3.19	2.49	1.88	751.36	Saskatoon	BASF
2915	Colonsay	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2916	Congress	SK	195.57	10.50	9.52	6.57	4.27	2.79	2.17	1.64	656.51	Saskatoon	BASF
2917	Consul	SK	225.90	22.59	20.47	14.12	9.18	6.00	4.68	3.53	1411.85	Saskatoon	BASF
2918	Corman Park	Sk	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Saskatoon	BASF
2919	Corning	SK	195.57	12.94	11.73	8.09	5.26	3.44	2.68	2.02	808.79	Saskatoon	BASF
2920	Coronach	SK	195.57	14.55	13.19	9.10	5.91	3.87	3.01	2.27	909.66	Saskatoon	BASF
2921	Craik	SK	195.57	5.87	5.32	3.67	2.39	1.56	1.22	0.92	367.02	Saskatoon	BASF
2922	Creelman	SK	195.57	10.66	9.66	6.66	4.33	2.83	2.21	1.67	666.35	Saskatoon	BASF
2923	Crooked River	SK	195.57	11.23	10.18	7.02	4.56	2.98	2.33	1.76	702.18	Saskatoon	BASF
2924	Cudworth	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2925	Cupar	SK	195.57	7.82	7.09	4.89	3.18	2.08	1.62	1.22	488.82	Saskatoon	BASF
2926	Cut knife	SK	195.57	8.68	7.87	5.43	3.53	2.31	1.80	1.36	511.97	Saskatoon	BASF
2927	Davidson	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2928	Debden	SK	195.57	8.38	7.60	5.24	3.41	2.23	1.73	1.31	523.91	Saskatoon	BASF
2929	Delisle	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Saskatoon	BASF
2930	Delmas	SK	195.57	7.66	6.94	4.78	3.11	2.03	1.58	1.20	478.49	Saskatoon	BASF
2931	Denzil	SK	195.57	11.54	10.46	7.21	4.69	3.06	2.39	1.80	721.04	Saskatoon	BASF
2932	Dinsmore	SK	195.57	6.27	5.68	3.92	2.55	1.67	1.30	0.98	391.79	Saskatoon	BASF
2933	Domremy	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2934	Drake	SK	195.57	6.14	5.56	3.84	2.49	1.63	1.27	0.96	383.53	Saskatoon	BASF
2935	Duperow	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2936	Eastend	SK	195.57	19.08	17.29	11.93	7.75	5.07	3.95	2.98	1192.59	Saskatoon	BASF
3582	Bracken	SK	333.25	33.33	27.63	18.82	12.16	7.91	6.17	4.68	1863.28	Winnipeg	BASF
2937	Eatonia	SK	195.57	12.14	11.00	7.59	4.93	3.22	2.51	1.90	758.77	Saskatoon	BASF
2938	Ebenezer	SK	195.57	13.54	12.27	8.46	5.50	3.60	2.80	2.12	846.00	Saskatoon	BASF
2939	Edam	SK	195.57	10.10	9.16	6.31	4.10	2.68	2.09	1.58	631.45	Saskatoon	BASF
2940	Edenwold	SK	195.57	7.62	6.91	4.76	3.10	2.02	1.58	1.19	476.43	Saskatoon	BASF
2941	Elfros	SK	195.57	8.68	7.87	5.42	3.53	2.31	1.80	1.36	542.49	Saskatoon	BASF
2942	Elrose	SK	195.57	7.00	6.34	4.37	2.84	1.86	1.45	1.09	437.21	Saskatoon	BASF
2943	Estevan	SK	195.57	14.18	12.85	8.86	5.76	3.77	2.93	2.22	886.26	Saskatoon	BASF
2944	Eston	SK	195.57	10.33	9.36	6.46	4.20	2.74	2.14	1.61	609.06	Saskatoon	BASF
2945	Eyebrow	SK	195.57	7.30	6.62	4.56	2.97	1.94	1.51	1.14	456.26	Saskatoon	BASF
2946	Fairlight	SK	195.57	18.48	16.75	11.55	7.51	4.91	3.82	2.89	1154.86	Saskatoon	BASF
2947	Fielding	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Saskatoon	BASF
2948	Fillmore	SK	195.57	9.93	9.00	6.21	4.04	2.64	2.06	1.55	620.93	Saskatoon	BASF
2949	Foam Lake	SK	195.57	9.31	8.43	5.82	3.78	2.47	1.93	1.45	581.71	Saskatoon	BASF
2950	Fox Valley	SK	195.57	16.59	15.04	10.37	6.74	4.41	3.43	2.59	1036.98	Saskatoon	BASF
2951	Francis	SK	195.57	8.38	7.60	5.24	3.41	2.23	1.73	1.31	523.91	Saskatoon	BASF
2952	Frontier	SK	204.77	20.48	18.56	12.80	8.32	5.44	4.24	3.20	1279.82	Saskatoon	BASF
2953	Gerald	SK	195.57	16.44	14.90	10.28	6.68	4.37	3.40	2.57	1027.55	Saskatoon	BASF
2954	Glaslyn	SK	195.57	10.33	9.36	6.46	4.20	2.74	2.14	1.61	645.60	Saskatoon	BASF
2955	Glenavon	SK	195.57	10.53	9.54	6.58	4.28	2.80	2.18	1.65	658.09	Saskatoon	BASF
2956	Goodeve	SK	195.57	10.57	9.58	6.61	4.29	2.81	2.19	1.65	660.72	Saskatoon	BASF
2957	Govan	SK	195.57	6.67	6.04	4.17	2.71	1.77	1.38	1.04	416.56	Saskatoon	BASF
2958	Grand Coulee	SK	195.57	7.79	7.06	4.87	3.16	2.07	1.61	1.22	486.75	Saskatoon	BASF
2959	Gravelbourg	SK	195.57	11.55	10.47	7.22	4.69	3.07	2.39	1.80	721.85	Saskatoon	BASF
2960	Gray	SK	195.57	7.52	6.82	4.70	3.06	2.00	1.56	1.18	470.24	Saskatoon	BASF
2961	Grenfell	SK	195.57	10.99	9.96	6.87	4.47	2.92	2.27	1.72	686.99	Saskatoon	BASF
2962	Griffin	SK	195.57	11.65	10.56	7.28	4.73	3.10	2.41	1.82	728.28	Saskatoon	BASF
2963	Gronlid	SK	195.57	10.18	9.22	6.36	4.14	2.70	2.11	1.59	636.17	Saskatoon	BASF
2964	Gull Lake	SK	195.57	15.08	13.67	9.43	6.13	4.01	3.12	2.36	942.67	Saskatoon	BASF
2965	Hafford	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Saskatoon	BASF
2966	Hague	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2967	Hamlin	SK	195.57	6.73	6.10	4.21	2.73	1.79	1.39	1.05	420.69	Saskatoon	BASF
2968	Hanley	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2969	Hazenmore	SK	195.57	14.97	13.57	9.36	6.08	3.98	3.10	2.34	935.60	Saskatoon	BASF
2970	Hazlet	SK	195.57	15.50	14.04	9.69	6.30	4.12	3.21	2.42	968.60	Saskatoon	BASF
2971	Hepburn	SK	195.57	9.83	6.25	4.07	2.56	1.63	1.28	0.99	336.82	Saskatoon	BASF
2972	Herbert	SK	195.57	10.10	9.15	6.31	4.10	2.68	2.09	1.58	631.26	Saskatoon	BASF
2973	Hodgeville	SK	195.57	11.99	10.87	7.49	4.87	3.18	2.48	1.87	749.34	Saskatoon	BASF
2974	Hoey	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2975	Hudson Bay	SK	195.57	15.76	14.28	9.85	6.40	4.19	3.26	2.46	985.11	Saskatoon	BASF
2976	Humboldt	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Saskatoon	BASF
2977	Imperial	SK	195.57	6.53	5.92	4.08	2.65	1.74	1.35	1.02	408.31	Saskatoon	BASF
2978	Indian Head	SK	195.57	8.71	7.90	5.45	3.54	2.31	1.80	1.36	544.55	Saskatoon	BASF
2979	Invermay	SK	195.57	12.82	11.62	8.01	5.21	3.41	2.65	2.00	801.21	Saskatoon	BASF
2980	Ituna	SK	195.57	9.27	8.40	5.80	3.77	2.46	1.92	1.45	579.65	Saskatoon	BASF
2981	Kamsack	SK	195.57	15.95	14.45	9.97	6.48	4.24	3.30	2.49	996.90	Saskatoon	BASF
2982	Kelso	SK	195.57	19.01	17.22	11.88	7.72	5.05	3.93	2.97	1187.87	Saskatoon	BASF
2983	Kelvington	SK	195.57	12.93	11.72	8.08	5.25	3.44	2.68	2.02	808.28	Saskatoon	BASF
2984	Kerrobert	SK	195.57	8.21	7.44	5.13	3.34	2.18	1.70	1.28	513.18	Saskatoon	BASF
2985	Kindersley	SK	195.57	10.03	9.09	6.27	4.07	2.66	2.08	1.57	591.26	Saskatoon	BASF
2986	Kinistino	SK	195.57	7.66	6.94	4.78	3.11	2.03	1.58	1.20	478.49	Saskatoon	BASF
2987	Kipling	SK	195.57	13.04	11.82	8.15	5.30	3.46	2.70	2.04	814.98	Saskatoon	BASF
2988	Kisbey	SK	195.57	12.81	11.61	8.01	5.20	3.40	2.65	2.00	800.53	Saskatoon	BASF
2989	Kronau	SK	195.57	6.83	6.19	4.27	2.77	1.81	1.41	1.07	426.89	Saskatoon	BASF
2990	Krydor	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
2991	Kyle	SK	195.57	9.95	9.02	6.22	4.04	2.64	2.06	1.56	586.81	Saskatoon	BASF
2992	Lafleche	SK	195.57	13.80	12.51	8.63	5.61	3.67	2.86	2.16	862.51	Saskatoon	BASF
2993	Lajord	SK	195.57	7.33	6.64	4.58	2.98	1.95	1.52	1.14	457.85	Saskatoon	BASF
2994	Lake Alma	SK	195.57	13.04	11.82	8.15	5.30	3.46	2.70	2.04	814.98	Saskatoon	BASF
2995	Lake Lenore	SK	195.57	6.33	5.74	3.96	2.57	1.68	1.31	0.99	395.92	Saskatoon	BASF
2996	Lampman	SK	195.57	14.08	12.76	8.80	5.72	3.74	2.91	2.20	879.93	Saskatoon	BASF
2997	Landis	SK	195.57	5.81	5.26	3.63	2.36	1.54	1.20	0.91	362.89	Saskatoon	BASF
2998	Langbank	SK	195.57	16.52	14.97	10.32	6.71	4.39	3.42	2.58	1032.26	Saskatoon	BASF
2999	Langenburg	SK	195.57	15.31	13.87	9.57	6.22	4.07	3.17	2.39	956.82	Saskatoon	BASF
3000	Langham	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3001	Lanigan	SK	195.57	5.61	5.08	3.51	2.28	1.49	1.16	0.88	350.50	Saskatoon	BASF
3002	Lashburn	SK	195.57	12.22	11.07	7.63	4.96	3.24	2.53	1.91	763.48	Saskatoon	BASF
3003	Leader	SK	195.57	14.18	12.85	8.86	5.76	3.77	2.93	2.22	835.93	Saskatoon	BASF
3004	Leask	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3005	Lemberg	SK	195.57	10.56	9.57	6.60	4.29	2.81	2.19	1.65	660.16	Saskatoon	BASF
3006	Leoville	SK	195.57	10.18	9.22	6.36	4.14	2.70	2.11	1.59	636.17	Saskatoon	BASF
3007	Leross	SK	195.57	8.71	7.90	5.45	3.54	2.31	1.80	1.36	544.55	Saskatoon	BASF
3008	Leroy	SK	195.57	8.15	7.39	5.09	3.31	2.17	1.69	1.27	509.46	Saskatoon	BASF
3009	Lestock	SK	195.57	8.48	7.69	5.30	3.45	2.25	1.76	1.33	530.10	Saskatoon	BASF
3010	Lewvan	SK	195.57	8.65	7.84	5.40	3.51	2.30	1.79	1.35	540.43	Saskatoon	BASF
3011	Liberty	SK	195.57	6.57	5.95	4.10	2.67	1.74	1.36	1.03	410.37	Saskatoon	BASF
3012	Limerick	SK	195.57	11.75	10.65	7.34	4.77	3.12	2.43	1.84	734.50	Saskatoon	BASF
3013	Lintlaw	SK	195.57	13.91	12.61	8.70	5.65	3.70	2.88	2.17	869.58	Saskatoon	BASF
3014	Lipton	SK	195.57	8.61	7.81	5.38	3.50	2.29	1.78	1.35	538.36	Saskatoon	BASF
3015	Lloydminsters	SK	195.57	12.93	11.72	8.08	5.25	3.44	2.68	2.02	762.54	Saskatoon	BASF
3016	Loreburn	SK	195.57	5.41	4.90	3.38	2.20	1.44	1.12	0.85	338.12	Saskatoon	BASF
3017	Lucky Lake	SK	195.57	6.79	6.16	4.25	2.76	1.80	1.41	1.06	400.61	Saskatoon	BASF
3018	Lumsden	SK	195.57	5.84	5.29	3.65	2.37	1.55	1.21	0.91	364.96	Saskatoon	BASF
3019	Luseland	SK	195.57	10.33	9.36	6.46	4.20	2.74	2.14	1.61	609.06	Saskatoon	BASF
3020	Macklin	SK	195.57	14.03	12.71	8.77	5.70	3.73	2.90	2.19	876.65	Saskatoon	BASF
3021	Macoun	SK	195.57	13.03	11.81	8.15	5.29	3.46	2.70	2.04	814.59	Saskatoon	BASF
3022	Maidstone	SK	195.57	11.16	10.11	6.97	4.53	2.96	2.31	1.74	697.47	Saskatoon	BASF
3023	Major	SK	195.57	10.78	9.77	6.74	4.38	2.86	2.23	1.68	673.89	Saskatoon	BASF
3024	Mankota	SK	195.57	16.06	14.56	10.04	6.53	4.27	3.32	2.51	1003.97	Saskatoon	BASF
3025	Maple Creek	SK	195.57	19.01	17.22	11.88	7.72	5.05	3.93	2.97	1187.87	Saskatoon	BASF
3026	Marengo	SK	195.57	12.14	11.00	7.59	4.93	3.22	2.51	1.90	758.77	Saskatoon	BASF
3027	Marsden	SK	195.57	12.29	11.14	7.68	4.99	3.26	2.54	1.92	768.20	Saskatoon	BASF
3028	Marshall	SK	195.57	12.82	11.62	8.01	5.21	3.41	2.65	2.00	801.21	Saskatoon	BASF
3029	Maryfield	SK	195.57	19.04	17.26	11.90	7.74	5.06	3.94	2.98	1190.23	Saskatoon	BASF
3030	Maymont	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3031	McLean	SK	195.57	7.56	6.85	4.72	3.07	2.01	1.56	1.18	472.30	Saskatoon	BASF
3032	Meadow Lake	SK	195.57	14.63	13.26	9.14	5.94	3.89	3.03	2.29	914.38	Saskatoon	BASF
3033	Meath Park	SK	195.57	7.99	7.24	4.99	3.24	2.12	1.65	1.25	499.14	Saskatoon	BASF
3034	Medstead	SK	195.57	11.54	10.46	7.21	4.69	3.06	2.39	1.80	721.04	Saskatoon	BASF
3035	Melfort	SK	195.57	7.66	6.94	4.78	3.11	2.03	1.58	1.20	478.49	Saskatoon	BASF
3036	Melville	SK	195.57	10.83	9.81	6.77	4.40	2.88	2.24	1.69	676.67	Saskatoon	BASF
3037	Meota	SK	195.57	7.72	7.00	4.83	3.14	2.05	1.60	1.21	482.62	Saskatoon	BASF
3038	Mervin	SK	195.57	10.93	9.91	6.83	4.44	2.90	2.26	1.71	644.64	Saskatoon	BASF
3039	Midale	SK	195.57	12.18	11.04	7.61	4.95	3.24	2.52	1.90	761.31	Saskatoon	BASF
3040	Middle Lake	SK	195.57	6.53	5.92	4.08	2.65	1.74	1.35	1.02	408.31	Saskatoon	BASF
3041	Milden	SK	195.57	5.54	5.02	3.46	2.25	1.47	1.15	0.87	346.38	Saskatoon	BASF
3042	Milestone	SK	195.57	8.15	7.39	5.09	3.31	2.17	1.69	1.27	509.46	Saskatoon	BASF
3043	Montmartre	SK	195.57	9.60	8.70	6.00	3.90	2.55	1.99	1.50	600.29	Saskatoon	BASF
3044	Moose Jaw	SK	195.57	6.63	6.01	4.14	2.69	1.76	1.37	1.04	414.50	Saskatoon	BASF
3045	Moosomin	SK	195.57	17.01	15.41	10.63	6.91	4.52	3.52	2.66	1062.91	Saskatoon	BASF
3046	Morse	SK	195.57	9.57	8.67	5.98	3.89	2.54	1.98	1.50	598.23	Saskatoon	BASF
3047	Mossbank	SK	195.57	9.44	8.55	5.90	3.83	2.51	1.95	1.47	589.97	Saskatoon	BASF
3048	Naicam	SK	195.57	7.99	7.24	4.99	3.24	2.12	1.65	1.25	470.88	Saskatoon	BASF
3049	Neilburg	SK	195.57	11.69	10.59	7.30	4.75	3.10	2.42	1.83	730.48	Saskatoon	BASF
3050	Neville	SK	195.57	14.33	12.98	8.96	5.82	3.81	2.97	2.24	895.52	Saskatoon	BASF
3051	Nipawin	SK	195.57	13.05	11.82	8.15	5.30	3.47	2.70	2.04	815.35	Saskatoon	BASF
3052	Nokomis	SK	195.57	6.79	6.16	4.25	2.76	1.80	1.41	1.06	424.65	Saskatoon	BASF
3053	Norquay	SK	195.57	16.74	15.17	10.46	6.80	4.45	3.46	2.62	1046.41	Saskatoon	BASF
3054	North Battleford	SK	195.57	6.33	5.74	3.96	2.57	1.68	1.31	0.99	373.51	Saskatoon	BASF
3055	Odessa	SK	195.57	8.48	7.69	5.30	3.45	2.25	1.76	1.33	530.10	Saskatoon	BASF
3056	Ogema	SK	195.57	10.66	9.66	6.66	4.33	2.83	2.21	1.67	666.35	Saskatoon	BASF
3057	Osler	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3058	Oungre	SK	195.57	12.94	11.73	8.09	5.26	3.44	2.68	2.02	808.79	Saskatoon	BASF
3059	Outlook	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Saskatoon	BASF
3060	Oxbow	SK	199.11	19.91	18.04	12.44	8.09	5.29	4.12	3.11	1244.46	Saskatoon	BASF
3061	Pangman	SK	195.57	9.80	8.88	6.13	3.98	2.60	2.03	1.53	612.68	Saskatoon	BASF
3062	Paradise Hill	SK	195.57	14.10	12.78	8.81	5.73	3.75	2.92	2.20	881.37	Saskatoon	BASF
3063	Parkside	SK	195.57	5.81	5.26	3.63	2.36	1.54	1.20	0.91	362.89	Saskatoon	BASF
3064	Paynton	SK	195.57	9.95	9.02	6.22	4.04	2.64	2.06	1.56	622.02	Saskatoon	BASF
3065	Peesane	SK	195.57	11.57	10.49	7.23	4.70	3.07	2.40	1.81	723.40	Saskatoon	BASF
3066	Pelly	SK	195.57	17.35	15.72	10.84	7.05	4.61	3.59	2.71	1084.13	Saskatoon	BASF
3067	Pense	SK	195.57	6.70	6.07	4.19	2.72	1.78	1.39	1.05	418.63	Saskatoon	BASF
3068	Perdue	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3069	Pilot Butte	SK	195.57	7.73	7.00	4.83	3.14	2.05	1.60	1.21	482.92	Saskatoon	BASF
3070	Plenty	SK	195.57	8.38	7.60	5.24	3.41	2.23	1.73	1.31	494.25	Saskatoon	BASF
3071	Ponteix	SK	195.57	15.87	14.39	9.92	6.45	4.22	3.29	2.48	992.18	Saskatoon	BASF
3072	Porcupine Plain	SK	195.57	13.57	12.30	8.48	5.51	3.61	2.81	2.12	848.36	Saskatoon	BASF
3073	Prairie River	SK	195.57	13.80	12.51	8.63	5.61	3.67	2.86	2.16	862.51	Saskatoon	BASF
3074	Prince Albert	SK	195.57	6.20	5.62	3.88	2.52	1.65	1.28	0.97	365.72	Saskatoon	BASF
3075	Quill Lake	Sk	195.57	7.46	6.76	4.66	3.03	1.98	1.54	1.17	466.11	Saskatoon	BASF
3076	Rabbit Lake	SK	195.57	10.63	9.63	6.64	4.32	2.82	2.20	1.66	664.46	Saskatoon	BASF
3077	Radisson	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3078	Radville	SK	195.57	11.39	10.32	7.12	4.63	3.03	2.36	1.78	711.77	Saskatoon	BASF
3079	Rama	SK	195.57	13.39	12.13	8.37	5.44	3.56	2.77	2.09	836.57	Saskatoon	BASF
3080	Raymore	SK	195.57	6.93	6.28	4.33	2.82	1.84	1.43	1.08	433.08	Saskatoon	BASF
3081	Redvers	SK	201.00	20.10	18.22	12.56	8.17	5.34	4.16	3.14	1256.24	Saskatoon	BASF
3082	Reed Lake	SK	195.57	10.10	9.15	6.31	4.10	2.68	2.09	1.58	631.26	Saskatoon	BASF
3083	Regina	SK	195.57	5.82	5.28	3.64	2.37	1.55	1.21	0.91	343.37	Saskatoon	BASF
3084	Rhein	SK	195.57	14.29	12.95	8.93	5.81	3.80	2.96	2.23	893.16	Saskatoon	BASF
3085	Riceton	SK	195.57	7.89	7.15	4.93	3.20	2.10	1.63	1.23	492.95	Saskatoon	BASF
3086	Richardson	SK	195.57	6.24	5.65	3.90	2.53	1.66	1.29	0.97	389.73	Saskatoon	BASF
3087	Ridgedale	SK	195.57	11.76	10.66	7.35	4.78	3.12	2.43	1.84	735.19	Saskatoon	BASF
3088	Rocanville	SK	195.57	16.97	15.38	10.61	6.89	4.51	3.51	2.65	1060.55	Saskatoon	BASF
3089	Rockhaven	SK	195.57	8.68	7.87	5.43	3.53	2.31	1.80	1.36	542.69	Saskatoon	BASF
3090	Rose Valley	SK	195.57	12.67	11.48	7.92	5.15	3.37	2.62	1.98	791.78	Saskatoon	BASF
3091	Rosetown	SK	195.57	5.48	4.96	3.42	2.22	1.45	1.13	0.86	322.88	Saskatoon	BASF
3092	Rosthern	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3093	Rouleau	SK	195.57	7.62	6.91	4.76	3.10	2.02	1.58	1.19	476.43	Saskatoon	BASF
3094	Rowatt	SK	195.57	6.33	5.74	3.96	2.57	1.68	1.31	0.99	395.92	Saskatoon	BASF
3095	Saskatoon	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	312.63	Saskatoon	BASF
3096	Sceptre	Sk	195.57	15.16	13.74	9.47	6.16	4.03	3.14	2.37	947.38	Saskatoon	BASF
3097	Sedley	SK	195.57	7.85	7.12	4.91	3.19	2.09	1.63	1.23	490.88	Saskatoon	BASF
3098	Shamrock	SK	195.57	10.36	9.39	6.48	4.21	2.75	2.14	1.62	647.77	Saskatoon	BASF
3099	Shaunavon	SK	195.57	17.53	15.89	10.96	7.12	4.66	3.63	2.74	1095.92	Saskatoon	BASF
3100	Shellbrook	SK	195.57	6.33	5.74	3.96	2.57	1.68	1.31	0.99	373.51	Saskatoon	BASF
3101	Simpson	SK	195.57	6.33	5.74	3.96	2.57	1.68	1.31	0.99	395.92	Saskatoon	BASF
3102	Sintaluta	SK	195.57	9.44	8.55	5.90	3.83	2.51	1.95	1.47	589.97	Saskatoon	BASF
3103	Southey	SK	195.57	6.96	6.31	4.35	2.83	1.85	1.44	1.09	435.14	Saskatoon	BASF
3104	Spalding	SK	195.57	7.59	6.88	4.74	3.08	2.02	1.57	1.19	474.37	Saskatoon	BASF
3105	Speers	SK	195.57	5.54	5.02	3.46	2.25	1.47	1.15	0.87	346.38	Saskatoon	BASF
3106	Spiritwood	SK	195.57	7.81	7.07	4.88	3.17	2.07	1.62	1.22	487.88	Saskatoon	BASF
3107	St Brieux	SK	195.57	7.39	6.70	4.62	3.00	1.96	1.53	1.15	461.98	Saskatoon	BASF
3108	St. Walburg	SK	195.57	12.97	11.75	8.11	5.27	3.45	2.68	2.03	810.64	Saskatoon	BASF
3109	Star City	SK	195.57	8.38	7.60	5.24	3.41	2.23	1.73	1.31	523.91	Saskatoon	BASF
3110	Stewart Valley	SK	195.57	11.69	10.59	7.30	4.75	3.10	2.42	1.83	730.48	Saskatoon	BASF
3111	Stockholm	SK	195.57	15.01	13.60	9.38	6.10	3.99	3.11	2.34	937.95	Saskatoon	BASF
3112	Stoughton	SK	195.57	11.55	10.47	7.22	4.69	3.07	2.39	1.81	722.09	Saskatoon	BASF
3113	Strasbourg	SK	195.57	6.70	6.07	4.19	2.72	1.78	1.39	1.05	418.63	Saskatoon	BASF
3114	Strongfield	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3115	Sturgis	SK	195.57	15.31	13.87	9.57	6.22	4.07	3.17	2.39	956.82	Saskatoon	BASF
3116	Swift Current	SK	195.57	12.67	11.48	7.92	5.15	3.37	2.62	1.98	791.78	Saskatoon	BASF
3117	Theodore	SK	195.57	12.22	11.07	7.63	4.96	3.24	2.53	1.91	763.48	Saskatoon	BASF
3118	Tisdale	SK	195.57	10.33	9.36	6.46	4.20	2.74	2.14	1.61	609.06	Saskatoon	BASF
3119	Tompkins	SK	195.57	16.21	14.69	10.13	6.59	4.31	3.36	2.53	1013.40	Saskatoon	BASF
3120	Torquay	SK	195.57	13.51	12.24	8.44	5.49	3.59	2.80	2.11	844.10	Saskatoon	BASF
3121	Tribune	SK	195.57	12.56	11.38	7.85	5.10	3.34	2.60	1.96	785.08	Saskatoon	BASF
3122	Tugaske	SK	195.57	7.30	6.62	4.56	2.97	1.94	1.51	1.14	456.26	Saskatoon	BASF
3123	Turtleford	SK	195.57	11.31	10.25	7.07	4.59	3.00	2.34	1.77	706.90	Saskatoon	BASF
3124	Tuxford	SK	195.57	6.60	5.98	4.12	2.68	1.75	1.37	1.03	412.44	Saskatoon	BASF
3125	Unity	SK	195.57	11.16	10.11	6.97	4.53	2.96	2.31	1.74	657.99	Saskatoon	BASF
3126	Valparaiso	SK	195.57	9.88	8.95	6.17	4.01	2.62	2.04	1.54	617.31	Saskatoon	BASF
3127	Vanscoy	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3128	Vibank	SK	195.57	7.99	7.24	4.99	3.24	2.12	1.65	1.25	499.14	Saskatoon	BASF
3129	Viscount	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3130	Wadena	SK	195.57	10.90	9.87	6.81	4.43	2.89	2.25	1.70	680.96	Saskatoon	BASF
3131	Wakaw	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3132	Waldheim	SK	195.57	5.30	4.81	3.31	2.15	1.41	1.10	0.83	331.38	Saskatoon	BASF
3133	Waldron	SK	195.57	11.92	10.80	7.45	4.84	3.17	2.47	1.86	745.03	Saskatoon	BASF
3134	Wapella	Sk	195.57	14.16	12.83	8.85	5.75	3.76	2.93	2.21	885.17	Saskatoon	BASF
3135	Watrous	SK	195.57	5.34	4.84	3.34	2.17	1.42	1.11	0.83	315.08	Saskatoon	BASF
3136	Watson	SK	195.57	6.67	6.04	4.17	2.71	1.77	1.38	1.04	416.56	Saskatoon	BASF
3137	Wawota	SK	195.57	18.18	16.47	11.36	7.38	4.83	3.76	2.84	1136.00	Saskatoon	BASF
3138	Weyburn	SK	195.57	10.36	9.39	6.48	4.21	2.75	2.14	1.62	647.77	Saskatoon	BASF
3139	White City	SK	195.57	6.63	6.01	4.14	2.69	1.76	1.37	1.04	414.50	Saskatoon	BASF
3140	White Star	SK	195.57	6.73	6.10	4.21	2.73	1.79	1.39	1.05	420.69	Saskatoon	BASF
3141	Whitewood	SK	195.57	13.20	11.97	8.25	5.36	3.51	2.73	2.06	825.31	Saskatoon	BASF
3142	Wilcox	Sk	195.57	7.62	6.91	4.76	3.10	2.02	1.58	1.19	476.43	Saskatoon	BASF
3143	Wilkie	SK	195.57	8.75	7.93	5.47	3.55	2.32	1.81	1.37	546.90	Saskatoon	BASF
3144	Wiseton	SK	195.57	6.60	5.98	4.12	2.68	1.75	1.37	1.03	412.44	Saskatoon	BASF
3145	Wolseley	SK	195.57	10.00	9.06	6.25	4.06	2.66	2.07	1.56	625.06	Saskatoon	BASF
3146	Woodrow	SK	195.57	13.88	12.57	8.67	5.64	3.69	2.87	2.17	867.22	Saskatoon	BASF
3147	Wymark	SK	195.57	13.69	12.40	8.55	5.56	3.64	2.83	2.14	855.43	Saskatoon	BASF
3148	Wynyard	SK	195.57	7.95	7.21	4.97	3.23	2.11	1.65	1.24	497.07	Saskatoon	BASF
3149	Yellow Creek	SK	195.57	6.60	5.98	4.12	2.68	1.75	1.37	1.03	412.44	Saskatoon	BASF
3150	Yellow Grass	SK	195.57	9.54	8.64	5.96	3.88	2.53	1.97	1.49	596.16	Saskatoon	BASF
3151	Yorkton	SK	195.57	11.09	10.05	6.93	4.51	2.95	2.30	1.73	693.19	Saskatoon	BASF
3152	Whitestar	SK	195.57	6.74	6.10	4.20	2.74	1.79	1.39	1.05	420.69	Saskatoon	BASF
3153	Calgary	AB	323.23	32.32	29.29	20.20	13.14	8.58	6.40	4.80	2020.18	Teulon	BASF
3154	Edmonton	AB	319.67	31.96	28.97	19.98	12.98	8.50	6.32	4.75	1997.91	Teulon	BASF
3155	Rocky View	AB	323.23	32.32	29.29	20.20	13.14	8.58	6.40	4.80	2020.18	Teulon	BASF
3156	Arborg	MB	228.16	8.15	7.39	5.09	3.31	2.16	1.61	1.21	509.35	Teulon	BASF
3157	Baldur	MB	228.17	11.58	10.50	7.24	4.70	3.07	2.29	1.72	723.88	Teulon	BASF
3158	Beausejour	MB	228.16	6.72	6.10	4.20	2.74	1.78	1.33	0.99	420.48	Teulon	BASF
3159	Brandon	MB	228.17	12.36	11.20	7.73	5.02	3.28	2.44	1.84	772.88	Teulon	BASF
3160	Brunkild	MB	228.17	6.73	6.10	4.20	2.74	1.78	1.34	1.00	420.48	Teulon	BASF
3161	Carman	MB	228.16	6.72	6.10	4.20	2.74	1.78	1.33	0.99	420.48	Teulon	BASF
3162	Crystal City	MB	228.17	11.44	10.37	7.15	4.65	3.04	2.26	1.69	714.97	Teulon	BASF
3163	Darlingford	MB	228.16	9.29	8.42	5.80	3.77	2.47	1.83	1.38	580.53	Teulon	BASF
3164	Dauphin	MB	228.17	17.21	15.60	10.76	7.00	4.57	3.41	2.55	1075.80	Teulon	BASF
3165	Domain	MB	228.17	6.73	6.10	4.20	2.73	1.79	1.33	1.00	420.48	Teulon	BASF
3166	Douglas	MB	228.17	11.36	10.30	7.11	4.62	3.02	2.25	1.68	710.52	Teulon	BASF
3167	Elva	MB	228.17	18.29	16.57	11.43	7.43	4.86	3.62	2.72	1142.62	Teulon	BASF
3168	Gilbert Plains	MB	228.16	17.97	16.29	11.23	7.30	4.78	3.56	2.67	1123.25	Teulon	BASF
3169	Gladstone	MB	228.16	9.43	8.55	5.89	3.83	2.50	1.87	1.40	589.43	Teulon	BASF
3170	Grandview	MB	228.16	17.97	16.29	11.23	7.30	4.78	3.56	2.67	1123.25	Teulon	BASF
3171	Hamiota	MB	228.17	15.29	13.85	9.55	6.21	4.06	3.02	2.27	955.52	Teulon	BASF
3172	Inglis	MB	228.16	17.62	15.97	11.01	7.15	4.68	3.48	2.61	1101.00	Teulon	BASF
3173	Melita	MB	228.17	18.26	16.55	11.41	7.42	4.85	3.61	2.71	1141.04	Teulon	BASF
3174	Miami	MB	228.16	8.08	7.32	5.05	3.28	2.14	1.60	1.20	504.90	Teulon	BASF
3175	Miniota	MB	228.17	16.85	15.28	10.54	6.84	4.48	3.34	2.50	1053.52	Teulon	BASF
3176	Minnedosa	MB	228.17	12.36	11.20	7.73	5.02	3.28	2.44	1.84	772.88	Teulon	BASF
3177	Morden	MB	228.17	8.44	7.65	5.28	3.43	2.24	1.67	1.25	527.88	Teulon	BASF
3178	Morris	MB	228.16	6.72	6.10	4.20	2.74	1.78	1.33	0.99	420.48	Teulon	BASF
3179	Ninga	MB	228.17	16.19	14.67	10.12	6.58	4.30	3.20	2.40	1012.03	Teulon	BASF
3180	Notre Dame de Lourdes	MB	228.17	8.66	7.84	5.41	3.52	2.30	1.72	1.28	541.24	Teulon	BASF
3181	Rosser	MB	228.17	6.73	6.10	4.20	2.74	1.78	1.34	1.00	420.48	Teulon	BASF
3182	Shoal Lake	MB	228.17	15.15	13.72	9.46	6.15	4.02	3.00	2.25	946.61	Teulon	BASF
3183	Swan Lake	MB	228.16	9.93	9.00	6.20	4.04	2.63	1.97	1.48	620.57	Teulon	BASF
3184	Westbourne	MB	228.17	8.16	7.40	5.10	3.31	2.17	1.62	1.21	510.06	Teulon	BASF
3185	Winkler	MB	228.16	8.36	7.57	5.23	3.39	2.22	1.65	1.24	522.70	Teulon	BASF
3186	Winnipeg	MB	228.17	6.73	6.10	4.20	2.74	1.78	1.34	1.00	312.63	Teulon	BASF
3187	Canora	SK	228.16	19.22	17.41	12.01	7.81	5.10	3.80	2.85	1201.09	Teulon	BASF
3188	Davidson	SK	228.16	21.35	19.35	13.35	8.67	5.67	4.22	3.17	1334.55	Teulon	BASF
3189	Estevan	SK	228.16	18.33	16.60	11.46	7.44	4.87	3.63	2.72	1145.49	Teulon	BASF
3190	Fillmore	SK	228.16	16.20	14.68	10.12	6.58	4.31	3.21	2.40	1012.03	Teulon	BASF
3191	Foam Lake	SK	228.16	19.25	17.45	12.03	7.82	5.11	3.81	2.86	1203.32	Teulon	BASF
3192	Grenfell	SK	228.17	15.66	14.19	9.79	6.36	4.16	3.10	2.32	978.67	Teulon	BASF
3193	Lampman	SK	228.17	17.58	15.93	10.99	7.14	4.67	3.48	2.61	1098.78	Teulon	BASF
3194	Langenburg	SK	228.17	16.44	14.90	10.28	6.68	4.37	3.25	2.44	1027.60	Teulon	BASF
3195	Lipton	SK	228.16	17.36	15.73	10.85	7.05	4.61	3.43	2.58	1085.43	Teulon	BASF
3196	Lumsden	SK	228.16	17.09	15.48	10.68	6.94	4.54	3.38	2.53	1067.64	Teulon	BASF
3197	Melfort	SK	233.46	23.35	21.16	14.59	9.48	6.20	4.62	3.47	1459.11	Teulon	BASF
3198	Moose Jaw	SK	228.16	18.83	17.06	11.77	7.65	5.00	3.73	2.80	1176.63	Teulon	BASF
3199	Regina	SK	228.17	15.68	14.21	9.80	6.37	4.16	3.11	2.33	882.30	Teulon	BASF
3200	Saskatoon	SK	228.17	20.24	18.34	12.65	8.22	5.38	4.01	3.01	1265.12	Teulon	BASF
3201	Southey	SK	228.17	18.21	16.50	11.39	7.40	4.83	3.61	2.71	1138.16	Teulon	BASF
3202	Swift Current	SK	264.42	26.44	23.96	16.52	10.74	7.02	5.24	3.93	1652.62	Teulon	BASF
3203	Weyburn	SK	228.16	16.87	15.28	10.55	6.86	4.48	3.34	2.50	1054.29	Teulon	BASF
3204	Wilcox	SK	228.16	18.04	16.35	11.27	7.33	4.80	3.57	2.68	1127.69	Teulon	BASF
3205	Yorkton	SK	228.16	17.05	15.45	10.65	6.93	4.53	3.37	2.53	1065.42	Teulon	BASF
3206	Acadia Valley	AB	365.65	36.57	30.57	20.85	13.47	8.77	6.84	5.19	2070.85	Winnipeg	BASF
3207	Airdrie	AB	352.67	35.27	29.39	20.04	12.94	8.42	6.57	4.99	1987.67	Winnipeg	BASF
3208	Alix	AB	365.30	36.53	30.54	20.83	13.46	8.76	6.83	5.18	2068.60	Winnipeg	BASF
3209	Alliance	AB	390.92	39.09	32.86	22.43	14.50	9.44	7.36	5.58	2232.71	Winnipeg	BASF
3210	Amisk	AB	363.72	36.37	30.39	20.73	13.39	8.72	6.80	5.16	2058.44	Winnipeg	BASF
3211	Andrew	AB	352.67	35.27	29.39	20.04	12.94	8.42	6.57	4.99	1987.67	Winnipeg	BASF
3212	Athabasca	AB	397.01	39.70	33.41	22.81	14.75	9.60	7.49	5.68	2271.69	Winnipeg	BASF
3213	Balzac	AB	348.46	34.85	29.01	19.78	12.77	8.31	6.48	4.92	1960.69	Winnipeg	BASF
3214	Barons	AB	366.94	36.69	30.68	20.93	13.52	8.80	6.86	5.21	2079.08	Winnipeg	BASF
3215	Barrhead	AB	396.29	39.63	33.34	22.76	14.72	9.58	7.47	5.67	2267.11	Winnipeg	BASF
3216	Bashaw	AB	379.34	37.93	31.81	21.71	14.03	9.13	7.12	5.40	2158.53	Winnipeg	BASF
3217	Bassano	AB	341.44	34.14	28.37	19.34	12.49	8.12	6.34	4.81	1915.73	Winnipeg	BASF
3218	Bay Tree	AB	766.41	76.64	66.88	45.90	29.75	19.41	15.13	11.45	4638.16	Winnipeg	BASF
3219	Beaverlodge	AB	657.09	65.71	56.98	39.07	25.31	16.51	12.87	9.74	3937.89	Winnipeg	BASF
3220	Beiseker	AB	358.29	35.83	29.90	20.39	13.17	8.57	6.69	5.07	2023.64	Winnipeg	BASF
3221	Benalto	AB	413.03	41.30	34.86	23.81	15.40	10.03	7.82	5.93	2374.34	Winnipeg	BASF
3222	Bentley	AB	403.20	40.32	33.97	23.20	15.00	9.76	7.62	5.78	2311.39	Winnipeg	BASF
3223	Blackfalds	AB	398.99	39.90	33.59	22.93	14.83	9.65	7.53	5.71	2284.42	Winnipeg	BASF
3224	Blackie	AB	351.97	35.20	29.33	19.99	12.92	8.40	6.56	4.97	1983.18	Winnipeg	BASF
3225	Bonnyville	AB	375.48	37.55	31.46	21.46	13.87	9.03	7.04	5.34	2133.80	Winnipeg	BASF
3226	Bow Island	AB	366.36	36.64	30.63	20.89	13.50	8.79	6.85	5.20	2075.35	Winnipeg	BASF
3227	Boyle	AB	387.34	38.73	32.53	22.21	14.35	9.34	7.29	5.53	2209.78	Winnipeg	BASF
3228	Brooks	AB	342.49	34.25	28.47	19.40	12.53	8.15	6.36	4.83	1922.48	Winnipeg	BASF
3229	Burdett	AB	362.50	36.25	30.28	20.65	13.34	8.68	6.77	5.14	2050.62	Winnipeg	BASF
3230	Calgary	AB	271.19	27.12	22.01	14.95	9.63	6.26	4.88	3.71	1382.73	Winnipeg	BASF
3231	Calmar	AB	358.99	35.90	29.96	20.43	13.20	8.59	6.70	5.08	2028.14	Winnipeg	BASF
3232	Camrose	AB	357.58	35.76	29.84	20.35	13.14	8.55	6.67	5.06	2019.14	Winnipeg	BASF
3233	Carbon	AB	367.76	36.78	30.76	20.98	13.56	8.82	6.88	5.22	2084.34	Winnipeg	BASF
3234	Cardston	AB	386.74	38.67	32.48	22.17	14.33	9.33	7.27	5.52	2205.93	Winnipeg	BASF
3235	Carseland	AB	350.92	35.09	29.23	19.93	12.87	8.38	6.53	4.96	1976.43	Winnipeg	BASF
3236	Carstairs	AB	367.41	36.74	30.73	20.96	13.54	8.81	6.87	5.22	2082.09	Winnipeg	BASF
3237	Castor	AB	357.23	35.72	29.80	20.32	13.13	8.54	6.66	5.06	2016.90	Winnipeg	BASF
3238	Clandonald	AB	356.66	35.67	29.75	20.29	13.11	8.53	6.65	5.05	2013.25	Winnipeg	BASF
3239	Claresholm	AB	360.39	36.04	30.09	20.52	13.26	8.63	6.73	5.11	2037.13	Winnipeg	BASF
3240	Clyde	AB	369.87	36.99	30.95	21.11	13.64	8.88	6.93	5.25	2097.83	Winnipeg	BASF
3241	Coaldale	AB	366.58	36.66	30.65	20.91	13.51	8.79	6.86	5.20	2076.79	Winnipeg	BASF
3242	Cochrane	AB	356.18	35.62	29.71	20.26	13.09	8.51	6.64	5.04	2010.15	Winnipeg	BASF
3243	Consort	AB	371.23	37.12	31.07	21.20	13.70	8.91	6.95	5.28	2106.59	Winnipeg	BASF
3244	Coronation	AB	362.29	36.23	30.26	20.64	13.33	8.68	6.77	5.14	2049.27	Winnipeg	BASF
3245	Cremona	AB	373.37	37.34	31.27	21.33	13.79	8.97	7.00	5.31	2120.31	Winnipeg	BASF
3246	Crossfield	AB	359.69	35.97	30.03	20.48	13.23	8.61	6.71	5.10	2032.63	Winnipeg	BASF
3247	Cypress County	AB	341.79	34.18	28.40	19.36	12.50	8.13	6.34	4.82	1917.98	Winnipeg	BASF
3248	Czar	AB	369.80	36.98	30.94	21.11	13.64	8.88	6.92	5.25	2097.42	Winnipeg	BASF
3249	Daysland	AB	362.50	36.25	30.28	20.65	13.34	8.68	6.77	5.14	2050.62	Winnipeg	BASF
3250	Debolt	AB	607.03	60.70	52.44	35.94	23.28	15.18	11.83	8.96	3617.15	Winnipeg	BASF
3251	Delburne	AB	397.59	39.76	33.46	22.85	14.77	9.61	7.50	5.69	2275.43	Winnipeg	BASF
3252	Delia	AB	378.99	37.90	31.78	21.68	14.01	9.12	7.11	5.40	2156.28	Winnipeg	BASF
3253	Dewberry	AB	350.92	35.09	29.23	19.93	12.87	8.38	6.53	4.96	1976.43	Winnipeg	BASF
3254	Dickson	AB	406.01	40.60	34.22	23.37	15.11	9.84	7.67	5.82	2329.38	Winnipeg	BASF
3255	Didsbury	AB	353.37	35.34	29.45	20.08	12.97	8.44	6.58	5.00	1992.17	Winnipeg	BASF
3256	Drayton Valley	AB	400.04	40.00	33.68	23.00	14.87	9.68	7.55	5.73	2291.16	Winnipeg	BASF
3257	Drumheller	AB	361.79	36.18	30.22	20.61	13.31	8.66	6.76	5.13	2046.12	Winnipeg	BASF
3258	Dunmore	AB	341.44	34.14	28.37	19.34	12.49	8.12	6.34	4.81	1915.73	Winnipeg	BASF
3259	Eaglesham	AB	647.50	64.75	56.11	38.47	24.92	16.25	12.67	9.59	3876.41	Winnipeg	BASF
3260	Eckville	AB	417.94	41.79	35.31	24.12	15.60	10.16	7.92	6.01	2405.81	Winnipeg	BASF
3261	Edberg	AB	369.16	36.92	30.88	21.07	13.61	8.86	6.91	5.24	2093.33	Winnipeg	BASF
3262	Edgerton	AB	356.20	35.62	29.71	20.26	13.09	8.52	6.64	5.04	2010.29	Winnipeg	BASF
3263	Edmonton	AB	269.49	26.95	21.85	14.84	9.56	6.21	4.85	3.69	1372.48	Winnipeg	BASF
3264	Enchant	AB	371.97	37.20	31.14	21.24	13.73	8.93	6.97	5.29	2111.32	Winnipeg	BASF
3265	Ervick	AB	357.23	35.72	29.80	20.32	13.13	8.54	6.66	5.06	2016.90	Winnipeg	BASF
3266	Evansburg	AB	383.55	38.36	32.19	21.97	14.20	9.24	7.21	5.47	2185.50	Winnipeg	BASF
3267	Fairview	AB	688.80	68.88	59.85	41.05	26.60	17.35	13.53	10.24	4141.02	Winnipeg	BASF
3268	Falher	AB	621.63	62.16	53.76	36.85	23.87	15.57	12.14	9.19	3710.70	Winnipeg	BASF
3269	Foremost	AB	379.11	37.91	31.79	21.69	14.02	9.12	7.12	5.40	2157.04	Winnipeg	BASF
3270	Forestburg	AB	375.83	37.58	31.49	21.49	13.88	9.04	7.05	5.35	2136.04	Winnipeg	BASF
3271	Fort MacLeod	AB	362.50	36.25	30.28	20.65	13.34	8.68	6.77	5.14	2050.62	Winnipeg	BASF
3272	Fort Saskatchewan	AB	343.20	34.32	28.53	19.45	12.56	8.17	6.37	4.84	1926.97	Winnipeg	BASF
3273	Galahad	AB	377.94	37.79	31.68	21.62	13.97	9.09	7.09	5.38	2149.53	Winnipeg	BASF
3274	Girouxville	AB	627.47	62.75	54.29	37.21	24.11	15.72	12.26	9.28	3748.12	Winnipeg	BASF
3275	Gleichen	AB	342.14	34.21	28.44	19.38	12.52	8.14	6.35	4.82	1920.23	Winnipeg	BASF
3276	Glendon	AB	370.22	37.02	30.98	21.14	13.66	8.89	6.93	5.26	2100.08	Winnipeg	BASF
3277	Grande Prairie	AB	635.40	63.54	55.01	37.71	24.43	15.93	12.42	9.40	3798.90	Winnipeg	BASF
3278	Grassy Lake	AB	362.50	36.25	30.28	20.65	13.34	8.68	6.77	5.14	2050.62	Winnipeg	BASF
3279	Grimshaw	AB	663.77	66.38	57.58	39.48	25.58	16.69	13.01	9.85	3980.65	Winnipeg	BASF
3280	Guy	AB	608.70	60.87	52.59	36.04	23.35	15.22	11.87	8.99	3627.85	Winnipeg	BASF
3281	Hairy Hill	AB	350.92	35.09	29.23	19.93	12.87	8.38	6.53	4.96	1976.43	Winnipeg	BASF
3282	Halkirk	AB	362.39	36.24	30.27	20.65	13.34	8.68	6.77	5.14	2049.95	Winnipeg	BASF
3283	Hanna	AB	377.94	37.79	31.68	21.62	13.97	9.09	7.09	5.38	2149.53	Winnipeg	BASF
3284	High Level	AB	801.87	80.19	70.10	48.11	31.19	20.35	15.87	12.00	4865.35	Winnipeg	BASF
3285	High Prairie	AB	581.16	58.12	50.10	34.32	22.23	14.49	11.30	8.56	3451.44	Winnipeg	BASF
3286	High River	AB	354.07	35.41	29.52	20.13	13.00	8.46	6.60	5.01	1996.66	Winnipeg	BASF
3287	Hines Creek	AB	697.15	69.71	60.61	41.57	26.94	17.57	13.70	10.37	4194.48	Winnipeg	BASF
3288	Hussar	AB	342.84	34.28	28.50	19.42	12.54	8.16	6.37	4.83	1924.73	Winnipeg	BASF
3289	Hythe	AB	667.11	66.71	57.89	39.69	25.72	16.77	13.08	9.90	4002.04	Winnipeg	BASF
3290	Innisfail	AB	391.97	39.20	32.95	22.49	14.54	9.47	7.38	5.60	2239.46	Winnipeg	BASF
3291	Innisfree	AB	337.93	33.79	28.05	19.12	12.35	8.03	6.26	4.76	1893.25	Winnipeg	BASF
3292	Irma	AB	343.55	34.35	28.56	19.47	12.57	8.18	6.38	4.84	1929.22	Winnipeg	BASF
3293	Iron Springs	AB	364.95	36.50	30.50	20.81	13.44	8.75	6.82	5.18	2066.35	Winnipeg	BASF
3294	Killam	AB	370.57	37.06	31.01	21.16	13.67	8.90	6.94	5.27	2102.32	Winnipeg	BASF
3295	Kirriemuir	AB	371.34	37.13	31.08	21.21	13.70	8.92	6.96	5.28	2107.29	Winnipeg	BASF
3296	Kitscoty	AB	338.63	33.86	28.12	19.16	12.37	8.05	6.28	4.77	1897.75	Winnipeg	BASF
3297	La Glace	AB	655.01	65.50	56.79	38.93	25.23	16.45	12.83	9.71	3924.52	Winnipeg	BASF
3298	Lac La Biche	AB	403.57	40.36	34.00	23.22	15.01	9.77	7.62	5.78	2313.74	Winnipeg	BASF
3299	Lacombe	AB	391.97	39.20	32.95	22.49	14.54	9.47	7.38	5.60	2239.46	Winnipeg	BASF
3300	LaCrete	AB	750.97	75.10	65.49	44.93	29.12	19.00	14.81	11.21	4539.27	Winnipeg	BASF
3301	Lamont	AB	341.79	34.18	28.40	19.36	12.50	8.13	6.34	4.82	1917.98	Winnipeg	BASF
3302	Lavoy	AB	338.28	33.83	28.09	19.14	12.36	8.04	6.27	4.76	1895.50	Winnipeg	BASF
3303	Leduc	AB	352.67	35.27	29.39	20.04	12.94	8.42	6.57	4.99	1987.67	Winnipeg	BASF
3304	Legal	AB	360.39	36.04	30.09	20.52	13.26	8.63	6.73	5.11	2037.13	Winnipeg	BASF
3305	Lethbridge	AB	360.04	36.00	30.06	20.50	13.24	8.62	6.72	5.10	2034.88	Winnipeg	BASF
3306	Linden	AB	368.46	36.85	30.82	21.03	13.59	8.84	6.90	5.23	2088.83	Winnipeg	BASF
3307	Lloydminster	AB	337.93	33.79	28.05	19.12	12.35	8.03	6.26	4.76	1893.25	Winnipeg	BASF
3308	Lomond	AB	356.88	35.69	29.77	20.30	13.12	8.53	6.66	5.05	2014.65	Winnipeg	BASF
3309	Lougheed	AB	366.01	36.60	30.60	20.87	13.49	8.78	6.85	5.19	2073.10	Winnipeg	BASF
3310	Magrath	AB	373.73	37.37	31.30	21.35	13.80	8.98	7.01	5.31	2122.56	Winnipeg	BASF
3311	Mallaig	AB	367.76	36.78	30.76	20.98	13.56	8.82	6.88	5.22	2084.34	Winnipeg	BASF
3312	Manning	AB	702.15	70.22	61.06	41.88	27.14	17.70	13.80	10.45	4226.55	Winnipeg	BASF
3313	Marwayne	AB	346.71	34.67	28.85	19.67	12.70	8.26	6.45	4.89	1949.45	Winnipeg	BASF
3314	Mayerthorpe	AB	408.46	40.85	34.45	23.53	15.21	9.90	7.72	5.86	2345.07	Winnipeg	BASF
3315	McLennan	AB	607.03	60.70	52.44	35.94	23.28	15.18	11.83	8.96	3617.15	Winnipeg	BASF
3316	Medicine Hat	AB	341.79	34.18	28.40	19.36	12.50	8.13	6.34	4.82	1917.98	Winnipeg	BASF
3317	Milk River	AB	391.28	39.13	32.89	22.45	14.51	9.45	7.37	5.59	2235.00	Winnipeg	BASF
3318	Milo	AB	357.93	35.79	29.87	20.37	13.16	8.56	6.68	5.07	2021.39	Winnipeg	BASF
3319	Morinville	AB	351.27	35.13	29.26	19.95	12.89	8.38	6.54	4.96	1978.68	Winnipeg	BASF
3320	Mossleigh	AB	349.51	34.95	29.10	19.84	12.82	8.34	6.50	4.94	1967.44	Winnipeg	BASF
3321	Mundare	AB	338.63	33.86	28.12	19.16	12.37	8.05	6.28	4.77	1897.75	Winnipeg	BASF
3322	Myrnam	AB	348.46	34.85	29.01	19.78	12.77	8.31	6.48	4.92	1960.69	Winnipeg	BASF
3323	Nampa	AB	637.07	63.71	55.16	37.81	24.50	15.98	12.46	9.43	3809.59	Winnipeg	BASF
3324	Nanton	AB	365.65	36.57	30.57	20.85	13.47	8.77	6.84	5.19	2070.85	Winnipeg	BASF
3325	Neerlandia	AB	406.31	40.63	34.25	23.39	15.12	9.85	7.68	5.82	2331.31	Winnipeg	BASF
3326	New Dayton	AB	373.73	37.37	31.30	21.35	13.80	8.98	7.01	5.31	2122.56	Winnipeg	BASF
3327	New Norway	AB	365.30	36.53	30.54	20.83	13.46	8.76	6.83	5.18	2068.60	Winnipeg	BASF
3328	Nisku	AB	347.76	34.78	28.95	19.73	12.74	8.29	6.47	4.91	1956.20	Winnipeg	BASF
3329	Nobleford	AB	359.69	35.97	30.03	20.48	13.23	8.61	6.71	5.10	2032.63	Winnipeg	BASF
3330	Okotoks	AB	358.64	35.86	29.93	20.41	13.19	8.58	6.69	5.08	2025.89	Winnipeg	BASF
3331	Olds	AB	381.45	38.14	32.00	21.84	14.11	9.19	7.17	5.44	2172.01	Winnipeg	BASF
3332	Onoway	AB	364.60	36.46	30.47	20.78	13.43	8.74	6.82	5.17	2064.11	Winnipeg	BASF
3333	Oyen	AB	366.58	36.66	30.65	20.91	13.51	8.79	6.86	5.20	2076.79	Winnipeg	BASF
3334	Paradise Valley	AB	356.20	35.62	29.71	20.26	13.09	8.52	6.64	5.04	2010.29	Winnipeg	BASF
3335	Peers	AB	415.13	41.51	35.05	23.94	15.48	10.08	7.86	5.96	2387.83	Winnipeg	BASF
3336	Penhold	AB	396.89	39.69	33.40	22.80	14.74	9.60	7.48	5.68	2270.93	Winnipeg	BASF
3337	Picture Butte	AB	361.09	36.11	30.15	20.56	13.29	8.65	6.74	5.12	2041.63	Winnipeg	BASF
3338	Pincher Creek	AB	390.20	39.02	32.79	22.38	14.47	9.42	7.35	5.57	2228.13	Winnipeg	BASF
3339	Ponoka	AB	383.55	38.36	32.19	21.97	14.20	9.24	7.21	5.47	2185.50	Winnipeg	BASF
3340	Provost	AB	368.37	36.84	30.81	21.02	13.58	8.84	6.89	5.23	2088.25	Winnipeg	BASF
3341	Raymond	AB	376.71	37.67	31.57	21.54	13.92	9.06	7.07	5.36	2141.70	Winnipeg	BASF
3342	Red Deer	AB	403.55	40.36	34.00	23.22	15.01	9.77	7.62	5.78	2313.64	Winnipeg	BASF
3343	Rimbey	AB	398.99	39.90	33.59	22.93	14.83	9.65	7.53	5.71	2284.42	Winnipeg	BASF
3344	Rivercourse	AB	357.74	35.77	29.85	20.36	13.15	8.56	6.67	5.06	2020.13	Winnipeg	BASF
3345	Rocky Mountain House	AB	441.16	44.12	37.41	25.57	16.54	10.77	8.40	6.37	2554.59	Winnipeg	BASF
3346	Rocky View	AB	348.81	34.88	29.04	19.80	12.79	8.32	6.49	4.93	1962.94	Winnipeg	BASF
3347	Rolling Hills	AB	355.48	35.55	29.64	20.21	13.06	8.50	6.63	5.03	2005.66	Winnipeg	BASF
3348	Rosalind	AB	366.71	36.67	30.66	20.92	13.51	8.79	6.86	5.21	2077.59	Winnipeg	BASF
3349	Rosebud	AB	357.58	35.76	29.84	20.35	13.14	8.55	6.67	5.06	2019.14	Winnipeg	BASF
3350	Rosedale	AB	361.79	36.18	30.22	20.61	13.31	8.66	6.76	5.13	2046.12	Winnipeg	BASF
3351	Rycroft	AB	666.27	66.63	57.81	39.64	25.68	16.75	13.06	9.89	3996.69	Winnipeg	BASF
3352	Ryley	AB	344.60	34.46	28.66	19.53	12.62	8.21	6.40	4.86	1935.97	Winnipeg	BASF
3353	Scandia	AB	360.07	36.37	30.36	20.06	13.04	8.52	6.64	5.01	2035.06	Winnipeg	BASF
3354	Sedgewick	AB	368.11	36.81	30.79	21.00	13.57	8.83	6.89	5.23	2086.59	Winnipeg	BASF
3355	Sexsmith	AB	641.24	64.12	55.54	38.07	24.67	16.09	12.54	9.49	3836.32	Winnipeg	BASF
3356	Silver Valley	AB	689.22	68.92	59.89	41.07	26.62	17.36	13.53	10.24	4143.69	Winnipeg	BASF
3357	Slave Lake	AB	453.70	45.37	38.55	26.35	17.05	11.11	8.66	6.56	2634.87	Winnipeg	BASF
3358	Smoky Lake	AB	360.04	36.00	30.06	20.50	13.24	8.62	6.72	5.10	2034.88	Winnipeg	BASF
3359	Spirit River	AB	670.45	67.04	58.19	39.90	25.85	16.86	13.15	9.95	4023.42	Winnipeg	BASF
3360	Spruce Grove	AB	350.21	35.02	29.17	19.88	12.84	8.36	6.52	4.95	1971.93	Winnipeg	BASF
3361	Spruce View	AB	405.31	40.53	34.16	23.33	15.08	9.82	7.66	5.81	2324.88	Winnipeg	BASF
3362	St Albert	AB	342.84	34.28	28.50	19.42	12.54	8.16	6.37	4.83	1924.73	Winnipeg	BASF
3363	St Isidore	AB	645.41	64.54	55.92	38.33	24.84	16.20	12.63	9.56	3863.05	Winnipeg	BASF
3364	St Paul	AB	363.20	36.32	30.34	20.70	13.37	8.70	6.79	5.15	2055.11	Winnipeg	BASF
3365	Standard	AB	348.11	34.81	28.98	19.75	12.76	8.30	6.48	4.91	1958.45	Winnipeg	BASF
3366	Stettler	AB	359.69	35.97	30.03	20.48	13.23	8.61	6.71	5.10	2032.63	Winnipeg	BASF
3367	Stirling	AB	368.11	36.81	30.79	21.00	13.57	8.83	6.89	5.23	2086.59	Winnipeg	BASF
3368	Stony Plain	AB	353.02	35.30	29.42	20.06	12.96	8.43	6.58	4.99	1989.92	Winnipeg	BASF
3369	Strathmore	AB	341.79	34.18	28.40	19.36	12.50	8.13	6.34	4.82	1917.98	Winnipeg	BASF
3370	Strome	AB	364.95	36.50	30.50	20.81	13.44	8.75	6.82	5.18	2066.35	Winnipeg	BASF
3371	Sturgeon Valley	AB	372.32	37.23	31.17	21.27	13.74	8.94	6.98	5.29	2113.56	Winnipeg	BASF
3372	Sunnybrook	AB	371.62	37.16	31.11	21.22	13.71	8.93	6.96	5.28	2109.07	Winnipeg	BASF
3373	Sylvan Lake	AB	408.12	40.81	34.42	23.50	15.20	9.89	7.72	5.85	2342.87	Winnipeg	BASF
3374	Taber	AB	362.85	36.28	30.31	20.67	13.36	8.69	6.78	5.14	2052.87	Winnipeg	BASF
3375	Thorhild	AB	360.39	36.04	30.09	20.52	13.26	8.63	6.73	5.11	2037.13	Winnipeg	BASF
3376	Three Hills	AB	374.78	37.48	31.39	21.42	13.84	9.01	7.03	5.33	2129.30	Winnipeg	BASF
3377	Tofield	AB	344.60	34.46	28.66	19.53	12.62	8.21	6.40	4.86	1935.97	Winnipeg	BASF
3378	Torrington	AB	378.99	37.90	31.78	21.68	14.01	9.12	7.11	5.40	2156.28	Winnipeg	BASF
3379	Trochu	AB	380.39	38.04	31.90	21.77	14.07	9.16	7.14	5.42	2165.27	Winnipeg	BASF
3380	Turin	AB	361.09	36.11	30.15	20.56	13.29	8.65	6.74	5.12	2041.63	Winnipeg	BASF
3381	Two Hills	AB	350.21	35.02	29.17	19.88	12.84	8.36	6.52	4.95	1971.93	Winnipeg	BASF
3382	Valleyview	AB	578.66	57.87	49.87	34.16	22.12	14.42	11.25	8.52	3435.40	Winnipeg	BASF
3383	Vauxhall	AB	356.18	35.62	29.71	20.26	13.09	8.51	6.64	5.04	2010.15	Winnipeg	BASF
3384	Vegreville	AB	337.93	33.79	28.05	19.12	12.35	8.03	6.26	4.76	1893.25	Winnipeg	BASF
3385	Vermilion	AB	338.28	33.83	28.09	19.14	12.36	8.04	6.27	4.76	1895.50	Winnipeg	BASF
3386	Veteran	AB	362.39	36.24	30.27	20.65	13.34	8.68	6.77	5.14	2049.95	Winnipeg	BASF
3387	Viking	AB	354.43	35.44	29.55	20.15	13.02	8.47	6.61	5.01	1998.91	Winnipeg	BASF
3388	Vulcan	AB	356.88	35.69	29.77	20.30	13.12	8.53	6.66	5.05	2014.65	Winnipeg	BASF
3389	Wainwright	AB	353.34	35.33	29.45	20.08	12.97	8.44	6.58	5.00	1991.94	Winnipeg	BASF
3390	Wanham	AB	648.75	64.88	56.22	38.54	24.97	16.29	12.70	9.61	3884.43	Winnipeg	BASF
3391	Warburg	AB	375.83	37.58	31.49	21.49	13.88	9.04	7.05	5.35	2136.04	Winnipeg	BASF
3392	Warner	AB	376.18	37.62	31.52	21.51	13.90	9.05	7.06	5.35	2138.29	Winnipeg	BASF
3393	Waskatenau	AB	363.00	36.30	30.33	20.68	13.36	8.70	6.78	5.15	2053.85	Winnipeg	BASF
3394	Westlock	AB	373.37	37.34	31.27	21.33	13.79	8.97	7.00	5.31	2120.31	Winnipeg	BASF
3395	Wetaskiwin	AB	368.11	36.81	30.79	21.00	13.57	8.83	6.89	5.23	2086.59	Winnipeg	BASF
3396	Whitecourt	AB	421.80	42.18	35.66	24.36	15.75	10.26	8.00	6.07	2430.54	Winnipeg	BASF
3397	Winfield	AB	389.52	38.95	32.73	21.69	14.10	9.22	7.18	5.42	2223.72	Winnipeg	BASF
3398	Dawson Creek	BC	704.66	70.47	61.29	41.39	26.90	17.59	13.71	10.35	4242.59	Winnipeg	BASF
3399	Delta	BC	907.42	90.74	79.66	54.06	35.14	22.98	17.90	13.52	5541.56	Winnipeg	BASF
3400	Fort St. John	BC	746.38	74.64	65.07	44.00	28.60	18.70	14.57	11.00	4509.87	Winnipeg	BASF
3401	Grindrod	BC	665.44	66.54	57.73	38.94	25.31	16.55	12.89	9.73	3991.34	Winnipeg	BASF
3402	Kamloops	BC	725.52	72.55	63.18	42.69	27.75	18.15	14.14	10.67	4376.23	Winnipeg	BASF
3403	Kelowna	BC	717.17	71.72	62.42	42.17	27.41	17.92	13.96	10.54	4322.77	Winnipeg	BASF
3404	Keremeos	BC	777.67	77.77	67.91	45.95	29.87	19.53	15.22	11.49	4710.33	Winnipeg	BASF
3405	Naramata	BC	738.03	73.80	64.31	43.48	28.26	18.48	14.40	10.87	4456.41	Winnipeg	BASF
3406	Oliver	BC	772.25	77.22	67.41	45.62	29.65	19.39	15.10	11.40	4675.58	Winnipeg	BASF
3407	Penticton	BC	753.05	75.31	65.68	44.42	28.87	18.88	14.71	11.10	4552.63	Winnipeg	BASF
3408	Prince George	BC	783.51	78.35	68.44	46.32	30.11	19.69	15.34	11.58	4747.74	Winnipeg	BASF
3409	Rolla	BC	709.66	70.97	61.74	41.70	27.11	17.72	13.81	10.43	4274.66	Winnipeg	BASF
3410	Vernon	BC	693.81	69.38	60.31	40.71	26.46	17.30	13.48	10.18	4173.09	Winnipeg	BASF
3411	Altamont	MB	190.80	6.09	5.52	3.80	2.47	1.62	1.26	0.95	365.84	Winnipeg	BASF
3412	Altona	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3413	Angusville	MB	190.80	13.15	11.91	8.22	5.34	3.49	2.72	2.05	842.18	Winnipeg	BASF
3414	Arborg	MB	190.80	5.47	4.96	3.42	2.22	1.45	1.13	0.85	330.65	Winnipeg	BASF
3415	Arnaud	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3416	Austin	MB	190.80	5.89	5.34	3.68	2.39	1.57	1.22	0.92	377.50	Winnipeg	BASF
3417	Baldur	MB	190.80	8.65	7.84	5.40	3.51	2.30	1.79	1.35	553.95	Winnipeg	BASF
3418	Basswood	MB	190.80	10.10	9.16	6.31	4.10	2.68	2.09	1.58	647.20	Winnipeg	BASF
3419	Beausejour	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3420	Benito	MB	190.80	17.31	15.69	10.82	7.03	4.60	3.58	2.71	1109.21	Winnipeg	BASF
3421	Binscarth	MB	190.80	13.25	12.00	8.28	5.38	3.52	2.74	2.07	848.53	Winnipeg	BASF
3422	Birch River	MB	203.58	20.36	18.45	12.72	8.27	5.41	4.21	3.18	1304.19	Winnipeg	BASF
3423	Birtle	MB	190.80	13.31	12.06	8.32	5.41	3.54	2.75	2.08	852.77	Winnipeg	BASF
3424	Boissevain	MB	190.80	12.42	11.25	7.76	5.04	3.30	2.57	1.94	795.55	Winnipeg	BASF
3425	Brandon	MB	190.80	9.20	8.34	5.75	3.74	2.44	1.90	1.44	556.07	Winnipeg	BASF
3426	Brunkild	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3427	Bruxelles	MB	190.80	6.87	6.22	4.29	2.79	1.82	1.42	1.07	439.84	Winnipeg	BASF
3428	Carberry	MB	190.80	7.45	6.75	4.66	3.03	1.98	1.54	1.16	477.24	Winnipeg	BASF
3429	Carman	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3430	Cartwright	MB	190.80	9.90	8.98	6.19	4.02	2.63	2.05	1.55	634.48	Winnipeg	BASF
3431	Crystal City	MB	190.80	8.51	7.72	5.32	3.46	2.26	1.76	1.33	545.47	Winnipeg	BASF
3432	Cypress River	MB	190.80	6.93	6.28	4.33	2.82	1.84	1.43	1.08	443.99	Winnipeg	BASF
3433	Darlingford	MB	190.80	6.41	5.81	4.01	2.60	1.70	1.33	1.00	410.75	Winnipeg	BASF
3434	Dauphin	MB	190.80	13.87	12.57	8.67	5.64	3.69	2.87	2.17	838.49	Winnipeg	BASF
3435	Deloraine	MB	190.80	14.01	12.69	8.75	5.69	3.72	2.90	2.19	846.49	Winnipeg	BASF
3436	Dencross	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3437	Domain	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3438	Dominion City	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3439	Douglas	MB	190.80	8.29	7.52	5.18	3.37	2.20	1.72	1.30	531.26	Winnipeg	BASF
3440	Dufrost	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3441	Dugald	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3442	Dunrea	MB	190.80	11.23	10.17	7.02	4.56	2.98	2.32	1.75	719.26	Winnipeg	BASF
3443	Elgin	MB	190.80	12.09	10.95	7.55	4.91	3.21	2.50	1.89	730.53	Winnipeg	BASF
3444	Elie	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3445	Elkhorn	MB	190.80	12.48	11.31	7.80	5.07	3.32	2.58	1.95	799.79	Winnipeg	BASF
3446	Elm Creek	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3447	Elva	MB	190.80	15.30	13.87	9.56	6.22	4.06	3.17	2.39	1012.79	Winnipeg	BASF
3448	Emerson	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3449	Fannystelle	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3450	Fisher Branch	MB	190.80	6.93	6.28	4.33	2.81	1.84	1.43	1.08	443.74	Winnipeg	BASF
3451	Fork River	MB	190.80	15.59	14.13	9.75	6.34	4.14	3.23	2.44	999.01	Winnipeg	BASF
3452	Forrest	MB	190.80	9.33	8.46	5.83	3.79	2.48	1.93	1.46	597.75	Winnipeg	BASF
3453	Foxwarren	MB	190.80	14.26	12.92	8.91	5.79	3.79	2.95	2.23	913.42	Winnipeg	BASF
3454	Franklin	MB	190.80	8.68	7.87	5.43	3.53	2.31	1.80	1.36	556.19	Winnipeg	BASF
3455	Gilbert Plains	MB	190.80	14.60	13.23	9.13	5.93	3.88	3.02	2.28	882.47	Winnipeg	BASF
3456	Gimli	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3457	Gladstone	MB	190.80	6.54	5.93	4.09	2.66	1.74	1.35	1.02	395.34	Winnipeg	BASF
3458	Glenboro	MB	190.80	9.01	8.16	5.63	3.66	2.39	1.86	1.41	576.97	Winnipeg	BASF
3459	Glossop (Newdale)	MB	190.80	11.75	10.65	7.34	4.77	3.12	2.43	1.84	752.85	Winnipeg	BASF
3460	Goodlands	MB	190.80	14.47	13.11	9.04	5.88	3.84	2.99	2.26	926.95	Winnipeg	BASF
3461	Grandview	MB	190.80	14.60	13.23	9.13	5.93	3.88	3.02	2.28	935.43	Winnipeg	BASF
3462	Gretna	MB	190.80	5.37	4.87	3.36	2.18	1.43	1.11	0.84	344.26	Winnipeg	BASF
3463	Griswold	MB	190.80	10.82	9.81	6.76	4.40	2.87	2.24	1.69	693.33	Winnipeg	BASF
3464	Grosse Isle	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3465	Gunton	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3466	Hamiota	MB	190.80	11.86	10.75	7.41	4.82	3.15	2.45	1.85	759.81	Winnipeg	BASF
3467	Hargrave	MB	190.80	12.22	11.07	7.64	4.96	3.25	2.53	1.91	782.67	Winnipeg	BASF
3468	Hartney	MB	190.80	12.55	11.37	7.84	5.10	3.33	2.60	1.96	804.03	Winnipeg	BASF
3469	High Bluff	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3470	Holland	MB	190.80	6.22	5.63	3.89	2.53	1.65	1.29	0.97	398.28	Winnipeg	BASF
3471	Homewood	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3472	Ile Des Chenes	MB	190.80	9.59	6.10	3.32	2.16	1.41	1.10	0.83	336.82	Winnipeg	BASF
3473	Inglis	MB	190.80	15.40	13.96	9.63	6.26	4.09	3.19	2.41	986.82	Winnipeg	BASF
3474	Kane	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3475	Kemnay	MB	190.80	9.66	8.75	6.03	3.92	2.56	2.00	1.51	618.53	Winnipeg	BASF
3476	Kenton	MB	190.80	12.12	10.98	7.57	4.92	3.22	2.51	1.89	776.44	Winnipeg	BASF
3477	Kenville	MB	190.80	17.89	16.22	11.18	7.27	4.75	3.70	2.80	1146.28	Winnipeg	BASF
3478	Killarney	MB	190.80	11.89	10.77	7.43	4.83	3.16	2.46	1.86	718.54	Winnipeg	BASF
3479	Landmark	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3480	Laurier	MB	190.80	12.25	11.10	7.66	4.98	3.25	2.54	1.91	784.97	Winnipeg	BASF
3481	Letellier	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3482	Lowe Farm	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3483	Lundar	MB	190.80	5.57	5.05	3.48	2.26	1.48	1.15	0.87	356.73	Winnipeg	BASF
3484	MacGregor	MB	190.80	5.37	4.87	3.36	2.18	1.43	1.11	0.84	344.26	Winnipeg	BASF
3485	Manitou	MB	190.80	6.87	6.22	4.29	2.79	1.82	1.42	1.07	439.84	Winnipeg	BASF
3486	Mariapolis	MB	190.80	7.72	7.00	4.83	3.14	2.05	1.60	1.21	494.61	Winnipeg	BASF
3487	Marquette/Meadows	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3488	Mather	MB	190.80	10.18	9.22	6.36	4.13	2.70	2.11	1.59	651.93	Winnipeg	BASF
3489	McCreary	MB	190.80	11.54	10.46	7.21	4.69	3.06	2.39	1.80	739.09	Winnipeg	BASF
3490	Meadows	MB	190.80	9.59	6.10	3.32	2.16	1.41	1.10	0.83	336.82	Winnipeg	BASF
3491	Medora	MB	190.80	15.40	13.96	9.63	6.26	4.09	3.19	2.41	986.82	Winnipeg	BASF
3492	Melita	MB	190.80	14.87	13.47	9.29	6.04	3.95	3.08	2.32	898.47	Winnipeg	BASF
3493	Miami	MB	190.80	5.31	4.81	3.32	2.16	1.41	1.10	0.83	340.10	Winnipeg	BASF
3494	Miniota	MB	190.80	13.29	12.04	8.30	5.40	3.53	2.75	2.08	851.24	Winnipeg	BASF
3495	Minitonas	MB	190.80	18.17	16.47	11.36	7.38	4.83	3.76	2.84	1164.31	Winnipeg	BASF
3496	Minnedosa	MB	190.80	9.20	8.34	5.75	3.74	2.44	1.90	1.44	589.44	Winnipeg	BASF
3497	Minto	MB	190.80	11.56	10.47	7.22	4.70	3.07	2.39	1.81	740.45	Winnipeg	BASF
3498	Mollard	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3499	Morden	MB	190.80	5.63	5.11	3.52	2.29	1.50	1.17	0.88	360.88	Winnipeg	BASF
3500	Morris	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3501	Neepawa	MB	190.80	8.03	7.28	5.02	3.26	2.13	1.66	1.26	485.51	Winnipeg	BASF
3502	Nesbitt	MB	190.80	10.76	9.75	6.72	4.37	2.86	2.23	1.68	689.17	Winnipeg	BASF
3503	Newdale	MB	190.80	10.43	9.46	6.52	4.24	2.77	2.16	1.63	668.39	Winnipeg	BASF
3504	Ninga	MB	190.80	13.97	12.66	8.73	5.68	3.71	2.89	2.18	895.07	Winnipeg	BASF
3505	Niverville	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3506	Notre Dame De Lourdes	MB	190.80	5.83	5.28	3.64	2.37	1.55	1.21	0.91	373.35	Winnipeg	BASF
3507	Oak Bluff	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3508	Oak River	MB	190.80	11.41	10.34	7.13	4.63	3.03	2.36	1.78	730.73	Winnipeg	BASF
3509	Oakbank	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3510	Oakner	MB	190.80	13.26	12.01	8.28	5.39	3.52	2.74	2.07	849.19	Winnipeg	BASF
3511	Oakville	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3512	Petersfield	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3513	Pierson	MB	190.80	15.53	14.07	9.71	6.31	4.12	3.21	2.43	994.77	Winnipeg	BASF
3514	Pilot Mound	MB	190.80	8.25	7.48	5.16	3.35	2.19	1.71	1.29	528.52	Winnipeg	BASF
3515	Pine Falls	MB	190.80	5.37	4.87	3.36	2.18	1.43	1.11	0.84	344.26	Winnipeg	BASF
3516	Plum Coulee	MB	190.80	5.31	4.81	3.32	2.16	1.41	1.10	0.83	340.10	Winnipeg	BASF
3517	Plumas	MB	190.80	7.58	6.87	4.74	3.08	2.01	1.57	1.18	485.55	Winnipeg	BASF
3518	Portage La Prairie	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3519	Rathwell	MB	190.80	5.24	4.75	3.28	2.13	1.39	1.09	0.82	335.95	Winnipeg	BASF
3520	Reston	MB	190.80	13.74	12.45	8.59	5.58	3.65	2.84	2.15	880.32	Winnipeg	BASF
3521	River Hills	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3522	Rivers	MB	190.80	10.50	9.51	6.56	4.26	2.79	2.17	1.64	672.55	Winnipeg	BASF
3523	Roblin	MB	190.80	14.37	13.02	8.98	5.84	3.82	2.97	2.25	920.59	Winnipeg	BASF
3524	Roland	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3525	Rosenort	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3526	Rossburn	MB	190.80	12.90	11.69	8.06	5.24	3.43	2.67	2.02	826.30	Winnipeg	BASF
3527	Rosser	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3528	Russell	MB	190.80	13.21	11.97	8.26	5.37	3.51	2.73	2.06	846.42	Winnipeg	BASF
3529	Selkirk	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3530	Shoal Lake	MB	190.80	11.73	10.63	7.33	4.77	3.12	2.43	1.83	708.96	Winnipeg	BASF
3531	Sifton	MB	190.80	16.26	14.74	10.16	6.61	4.32	3.37	2.54	1041.88	Winnipeg	BASF
3532	Snowflake	MB	190.80	8.45	7.66	5.28	3.43	2.24	1.75	1.32	541.23	Winnipeg	BASF
3533	Somerset	MB	190.80	6.61	5.99	4.13	2.68	1.75	1.37	1.03	399.26	Winnipeg	BASF
3534	Souris	MB	190.80	10.89	9.87	6.80	4.42	2.89	2.25	1.70	697.48	Winnipeg	BASF
3535	Springfield (P&H Winnipeg)	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3536	St Claude	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	312.63	Winnipeg	BASF
3537	St Jean Baptiste	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3538	St Joseph	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3539	St Leon	MB	190.80	6.35	5.75	3.97	2.58	1.69	1.31	0.99	406.59	Winnipeg	BASF
3540	Starbuck	MB	190.80	5.17	4.69	3.23	2.10	1.37	1.07	0.81	331.38	Winnipeg	BASF
3583	Bredenbury	SK	233.20	17.91	13.66	9.19	5.89	3.81	2.98	2.27	876.00	Winnipeg	BASF
3584	Briercrest	SK	233.20	20.93	16.40	11.08	7.12	4.61	3.60	2.75	1069.21	Winnipeg	BASF
3585	Broadview	SK	233.20	17.05	12.88	8.65	5.54	3.58	2.80	2.14	820.79	Winnipeg	BASF
3586	Broderick	SK	280.40	28.04	22.84	15.52	10.01	6.50	5.07	3.86	1524.66	Winnipeg	BASF
3587	Brooksby	SK	279.07	27.91	22.72	15.44	9.95	6.47	5.05	3.84	1516.14	Winnipeg	BASF
3588	Bruno	SK	254.04	25.40	20.45	13.87	8.94	5.80	4.53	3.44	1355.84	Winnipeg	BASF
3589	Buchanan	SK	233.20	21.18	16.62	11.23	7.22	4.68	3.65	2.78	1085.17	Winnipeg	BASF
3590	Cabri	SK	301.04	30.10	24.71	16.81	10.85	7.05	5.50	4.18	1656.90	Winnipeg	BASF
3591	Canora	SK	233.20	20.67	16.16	10.92	7.01	4.55	3.55	2.71	1052.69	Winnipeg	BASF
3592	Canwood	SK	329.28	32.93	27.27	18.58	11.99	7.80	6.09	4.62	1837.80	Winnipeg	BASF
3593	Carievale	SK	233.20	20.60	16.10	10.87	6.99	4.53	3.54	2.69	1048.36	Winnipeg	BASF
3594	Carlyle	SK	233.20	17.55	13.33	8.97	5.75	3.72	2.90	2.22	852.64	Winnipeg	BASF
3595	Carnduff	SK	233.20	19.69	15.28	10.30	6.62	4.28	3.35	2.55	989.88	Winnipeg	BASF
3596	Carrot River	SK	291.57	29.16	23.85	16.22	10.46	6.80	5.31	4.03	1596.27	Winnipeg	BASF
3597	Central Butte	SK	241.88	24.19	19.35	13.11	8.44	5.48	4.28	3.25	1277.92	Winnipeg	BASF
3598	Ceylon	SK	233.20	21.59	17.00	11.49	7.39	4.79	3.74	2.85	1111.67	Winnipeg	BASF
3599	Choiceland	SK	292.16	29.22	23.91	16.26	10.49	6.81	5.32	4.04	1600.00	Winnipeg	BASF
3600	Churchbridge	SK	233.20	18.07	13.80	9.29	5.96	3.85	3.01	2.30	885.93	Winnipeg	BASF
3601	Clavet	SK	263.32	26.33	21.29	14.45	9.31	6.05	4.72	3.59	1415.29	Winnipeg	BASF
3602	Codette	SK	280.89	28.09	22.88	15.55	10.03	6.52	5.08	3.86	1527.81	Winnipeg	BASF
3603	Colgate	SK	233.20	19.86	15.43	10.41	6.69	4.33	3.38	2.58	1000.71	Winnipeg	BASF
3604	Colonsay	SK	248.74	24.87	19.97	13.54	8.72	5.66	4.42	3.36	1321.87	Winnipeg	BASF
3605	Congress	SK	240.19	24.02	19.20	13.01	8.37	5.43	4.24	3.23	1267.09	Winnipeg	BASF
3606	Consul	SK	383.16	38.32	32.15	21.94	14.18	9.23	7.20	5.46	2182.99	Winnipeg	BASF
3607	Corman Park	SK	263.65	26.37	21.32	14.47	9.33	6.06	4.73	3.59	1337.17	Winnipeg	BASF
3608	Corning	SK	233.20	19.34	14.96	10.08	6.47	4.19	3.27	2.50	967.29	Winnipeg	BASF
3609	Coronach	SK	261.82	26.18	21.16	14.36	9.25	6.01	4.69	3.57	1405.69	Winnipeg	BASF
3610	Craik	SK	233.20	21.86	17.24	11.66	7.50	4.86	3.79	2.89	1128.66	Winnipeg	BASF
3611	Creelman	SK	233.20	17.38	13.18	8.86	5.68	3.67	2.87	2.19	842.03	Winnipeg	BASF
3612	Crooked River	SK	268.25	26.82	21.74	14.76	9.51	6.18	4.82	3.67	1446.84	Winnipeg	BASF
3613	Cudworth	SK	270.61	27.06	21.95	14.91	9.61	6.24	4.87	3.70	1462.00	Winnipeg	BASF
3614	Cupar	SK	233.20	19.04	14.69	9.90	6.35	4.11	3.21	2.45	948.19	Winnipeg	BASF
3615	Cut knife	SK	332.82	33.28	27.59	18.80	12.14	7.89	6.16	4.68	1860.48	Winnipeg	BASF
3616	Davidson	SK	233.20	23.05	18.32	12.40	7.98	5.18	4.04	3.08	1205.09	Winnipeg	BASF
3617	Debden	SK	363.11	36.31	30.34	20.69	13.37	8.70	6.79	5.15	2054.53	Winnipeg	BASF
3618	Delisle	SK	282.88	28.29	23.07	15.68	10.11	6.57	5.13	3.90	1540.55	Winnipeg	BASF
3619	Delmas	SK	322.32	32.23	26.64	18.14	11.71	7.62	5.94	4.51	1793.21	Winnipeg	BASF
3620	Denzil	SK	364.54	36.45	30.47	20.78	13.43	8.74	6.82	5.17	2063.71	Winnipeg	BASF
3621	Dinsmore	SK	278.90	27.89	22.70	15.43	9.95	6.46	5.04	3.83	1515.08	Winnipeg	BASF
3622	Domremy	SK	284.53	28.45	23.22	15.78	10.18	6.61	5.16	3.92	1551.17	Winnipeg	BASF
3623	Drake	SK	233.20	22.29	17.63	11.93	7.67	4.97	3.88	2.96	1156.26	Winnipeg	BASF
3624	Duperow	SK	302.76	30.28	24.87	16.92	10.92	7.10	5.54	4.21	1667.94	Winnipeg	BASF
3625	Eastend	SK	349.50	34.95	29.10	19.84	12.82	8.34	6.50	4.94	1967.37	Winnipeg	BASF
3626	Eatonia	SK	347.17	34.72	28.89	19.69	12.72	8.28	6.46	4.90	1952.45	Winnipeg	BASF
3627	Ebenezer	SK	233.20	19.46	15.06	10.16	6.52	4.22	3.30	2.52	974.73	Winnipeg	BASF
3628	Edam	SK	335.24	33.52	27.81	18.95	12.24	7.96	6.21	4.71	1876.02	Winnipeg	BASF
3629	Edenwold	SK	233.20	17.78	13.54	9.11	5.84	3.78	2.95	2.25	867.50	Winnipeg	BASF
3649	Gray	SK	233.20	17.68	13.45	9.05	5.80	3.75	2.93	2.24	861.13	Winnipeg	BASF
3650	Grenfell	SK	233.20	17.05	12.88	8.65	5.54	3.58	2.80	2.14	820.79	Winnipeg	BASF
3651	Griffin	SK	233.20	18.21	13.93	9.38	6.02	3.89	3.04	2.32	895.11	Winnipeg	BASF
3652	Gronlid	SK	272.93	27.29	22.16	15.05	9.70	6.30	4.92	3.74	1476.86	Winnipeg	BASF
3653	Gull Lake	SK	292.16	29.22	23.91	16.26	10.49	6.81	5.32	4.04	1600.00	Winnipeg	BASF
3654	Hafford	SK	328.73	32.87	27.22	18.54	11.97	7.79	6.07	4.61	1834.33	Winnipeg	BASF
3655	Hague	SK	285.53	28.55	23.31	15.84	10.22	6.64	5.18	3.94	1557.54	Winnipeg	BASF
3656	Hamlin	SK	326.96	32.70	27.06	18.43	11.90	7.74	6.04	4.58	1822.94	Winnipeg	BASF
3657	Hanley	SK	252.39	25.24	20.30	13.77	8.87	5.76	4.49	3.42	1345.22	Winnipeg	BASF
3658	Hazenmore	SK	288.19	28.82	23.55	16.01	10.32	6.71	5.24	3.98	1574.61	Winnipeg	BASF
3659	Hazlet	SK	300.70	30.07	24.68	16.79	10.83	7.04	5.49	4.17	1654.74	Winnipeg	BASF
3660	Herbert	SK	252.39	25.24	20.30	13.77	8.87	5.76	4.49	3.42	1345.22	Winnipeg	BASF
3661	Hodgeville	SK	257.03	25.70	20.72	14.06	9.06	5.88	4.59	3.49	1374.95	Winnipeg	BASF
3662	Hoey	SK	287.85	28.78	23.52	15.99	10.31	6.70	5.23	3.97	1572.40	Winnipeg	BASF
3663	Hudson Bay	SK	285.05	28.51	23.26	15.81	10.20	6.63	5.17	3.93	1554.48	Winnipeg	BASF
3664	Humboldt	SK	242.77	24.28	19.43	13.17	8.48	5.50	4.30	3.27	1283.65	Winnipeg	BASF
3665	Imperial	SK	233.20	22.82	18.11	12.26	7.89	5.12	3.99	3.04	1190.23	Winnipeg	BASF
3666	Indian Head	SK	233.20	17.12	12.94	8.70	5.57	3.60	2.81	2.15	825.04	Winnipeg	BASF
3667	Invermay	SK	233.20	21.56	16.97	11.47	7.38	4.78	3.73	2.84	1109.55	Winnipeg	BASF
3668	Ituna	SK	233.20	18.84	14.51	9.77	6.27	4.06	3.17	2.42	935.45	Winnipeg	BASF
3669	Kamsack	SK	233.20	20.77	16.26	10.98	7.06	4.57	3.57	2.72	1059.19	Winnipeg	BASF
3670	Kelso	SK	233.20	17.91	13.66	9.19	5.89	3.81	2.98	2.27	876.00	Winnipeg	BASF
3671	Kelvington	SK	233.20	22.92	18.20	12.32	7.93	5.14	4.01	3.06	1196.60	Winnipeg	BASF
3672	Kerrobert	SK	344.31	34.43	28.63	19.52	12.60	8.20	6.40	4.86	1934.11	Winnipeg	BASF
3673	Kindersley	SK	334.91	33.49	27.78	18.93	12.22	7.95	6.20	4.71	1873.89	Winnipeg	BASF
3674	Kinistino	SK	280.76	28.08	22.87	15.54	10.02	6.51	5.08	3.86	1526.97	Winnipeg	BASF
3675	Kipling	SK	233.20	17.58	13.36	8.99	5.76	3.72	2.91	2.22	854.77	Winnipeg	BASF
3676	Kisbey	SK	233.20	17.42	13.21	8.88	5.69	3.68	2.88	2.20	844.15	Winnipeg	BASF
3677	Kronau	SK	233.20	17.91	13.66	9.19	5.89	3.81	2.98	2.27	876.00	Winnipeg	BASF
3678	Krydor	SK	306.74	30.67	25.23	17.17	11.08	7.20	5.62	4.27	1693.42	Winnipeg	BASF
3679	Kyle	SK	303.07	30.31	24.89	16.94	10.93	7.10	5.54	4.21	1669.90	Winnipeg	BASF
3680	Lafleche	SK	259.12	25.91	20.91	14.19	9.14	5.94	4.63	3.52	1388.36	Winnipeg	BASF
3681	Lajord	SK	233.20	18.38	14.08	9.48	6.08	3.94	3.07	2.35	905.72	Winnipeg	BASF
3682	Lake Alma	SK	233.20	20.96	16.43	11.10	7.13	4.62	3.61	2.75	1071.33	Winnipeg	BASF
3683	Lake Lenore	SK	250.40	25.04	20.12	13.65	8.79	5.71	4.45	3.39	1332.48	Winnipeg	BASF
3684	Lampman	SK	233.20	19.12	14.75	9.94	6.38	4.13	3.23	2.46	953.07	Winnipeg	BASF
3685	Landis	SK	319.33	31.93	26.37	17.95	11.59	7.54	5.88	4.46	1774.10	Winnipeg	BASF
3686	Langbank	SK	233.20	18.64	14.33	9.65	6.19	4.01	3.13	2.39	922.75	Winnipeg	BASF
3687	Langenburg	SK	233.20	18.04	13.77	9.27	5.94	3.84	3.00	2.29	883.77	Winnipeg	BASF
3688	Langham	SK	280.89	28.09	22.88	15.55	10.03	6.52	5.08	3.86	1527.81	Winnipeg	BASF
3689	Lanigan	SK	233.20	22.36	17.69	11.97	7.70	4.99	3.90	2.97	1160.50	Winnipeg	BASF
3690	Lashburn	SK	321.98	32.20	26.61	18.12	11.70	7.61	5.93	4.51	1791.09	Winnipeg	BASF
3691	Leader	SK	337.55	33.75	28.02	19.09	12.33	8.02	6.26	4.75	1890.79	Winnipeg	BASF
3692	Leask	SK	310.72	31.07	25.59	17.42	11.24	7.31	5.70	4.33	1718.90	Winnipeg	BASF
3693	Lemberg	SK	233.20	17.48	13.27	8.92	5.72	3.70	2.89	2.21	848.40	Winnipeg	BASF
3694	Leoville	SK	351.15	35.11	29.25	19.94	12.88	8.38	6.54	4.96	1977.93	Winnipeg	BASF
3695	Leross	SK	233.20	19.41	15.02	10.13	6.50	4.21	3.29	2.51	971.54	Winnipeg	BASF
3696	Leroy	SK	233.20	22.45	17.78	12.03	7.74	5.02	3.92	2.98	1166.87	Winnipeg	BASF
3697	Lestock	SK	233.20	19.70	15.29	10.31	6.62	4.29	3.35	2.55	990.65	Winnipeg	BASF
3698	Lewvan	SK	233.20	17.98	13.72	9.23	5.92	3.83	2.99	2.28	880.24	Winnipeg	BASF
3699	Liberty	SK	233.20	21.86	17.24	11.66	7.50	4.86	3.79	2.89	1128.66	Winnipeg	BASF
3700	Limerick	SK	252.36	25.24	20.30	13.77	8.87	5.76	4.49	3.42	1345.05	Winnipeg	BASF
3701	Lintlaw	SK	246.02	24.60	19.73	13.37	8.61	5.59	4.36	3.32	1304.46	Winnipeg	BASF
3702	Lipton	SK	233.20	18.64	14.32	9.65	6.19	4.01	3.13	2.39	922.71	Winnipeg	BASF
3703	Lloydminsters	SK	322.32	32.23	26.64	18.14	11.71	7.62	5.94	4.51	1793.21	Winnipeg	BASF
3704	Loreburn	SK	249.07	24.91	20.00	13.56	8.74	5.67	4.43	3.37	1323.99	Winnipeg	BASF
3705	Lucky Lake	SK	283.12	28.31	23.09	15.69	10.12	6.57	5.13	3.90	1542.12	Winnipeg	BASF
3706	Lumsden	SK	233.20	18.38	14.08	9.48	6.08	3.94	3.07	2.35	905.72	Winnipeg	BASF
3707	Luseland	SK	348.03	34.80	28.97	19.75	12.76	8.30	6.47	4.91	1957.93	Winnipeg	BASF
3708	Macklin	SK	352.76	35.28	29.40	20.04	12.95	8.42	6.57	4.99	1988.25	Winnipeg	BASF
3709	Macoun	SK	233.20	19.83	15.40	10.39	6.67	4.32	3.37	2.57	998.55	Winnipeg	BASF
3710	Maidstone	SK	321.98	32.20	26.61	18.12	11.70	7.61	5.93	4.51	1791.09	Winnipeg	BASF
3711	Major	SK	347.50	34.75	28.92	19.72	12.73	8.28	6.46	4.91	1954.57	Winnipeg	BASF
3712	Mankota	SK	297.66	29.77	24.40	16.60	10.71	6.96	5.43	4.13	1635.25	Winnipeg	BASF
3713	Maple Creek	SK	326.62	32.66	27.03	18.41	11.89	7.73	6.03	4.58	1820.81	Winnipeg	BASF
3714	Marengo	SK	342.53	34.25	28.47	19.40	12.53	8.15	6.36	4.83	1922.73	Winnipeg	BASF
3715	Marsden	SK	334.51	33.45	27.74	18.90	12.21	7.94	6.19	4.70	1871.30	Winnipeg	BASF
3716	Marshall	SK	343.77	34.38	28.58	19.48	12.58	8.19	6.39	4.85	1930.67	Winnipeg	BASF
3717	Maryfield	SK	233.20	17.48	13.27	8.92	5.72	3.70	2.89	2.21	848.40	Winnipeg	BASF
3718	Maymont	SK	305.41	30.54	25.11	17.08	11.02	7.17	5.59	4.25	1684.93	Winnipeg	BASF
3719	McLean	SK	233.20	17.09	12.91	8.68	5.56	3.59	2.81	2.14	822.92	Winnipeg	BASF
3720	Meadow Lake	SK	370.68	37.07	31.02	21.16	13.68	8.90	6.94	5.27	2103.03	Winnipeg	BASF
3721	Meath Park	SK	342.70	34.27	28.49	19.42	12.54	8.16	6.36	4.83	1923.79	Winnipeg	BASF
3722	Medstead	SK	357.16	35.72	29.80	20.32	13.13	8.54	6.66	5.06	2016.40	Winnipeg	BASF
3723	Melfort	SK	264.32	26.43	21.38	14.52	9.35	6.07	4.74	3.61	1421.66	Winnipeg	BASF
3724	Melville	SK	233.20	17.81	13.57	9.13	5.85	3.79	2.96	2.26	869.63	Winnipeg	BASF
3725	Meota	SK	336.57	33.66	27.93	19.03	12.29	7.99	6.24	4.73	1884.51	Winnipeg	BASF
3726	Mervin	SK	340.93	34.09	28.33	19.30	12.47	8.11	6.33	4.80	1912.45	Winnipeg	BASF
3727	Midale	SK	233.20	19.54	15.14	10.21	6.55	4.24	3.31	2.53	980.03	Winnipeg	BASF
3728	Middle Lake	SK	258.02	25.80	20.81	14.12	9.10	5.91	4.61	3.51	1381.31	Winnipeg	BASF
3729	Milden	SK	280.89	28.09	22.88	15.55	10.03	6.52	5.08	3.86	1527.81	Winnipeg	BASF
3730	Milestone	SK	233.20	19.34	14.96	10.08	6.47	4.19	3.27	2.50	967.29	Winnipeg	BASF
3731	Montmartre	SK	233.20	17.72	13.48	9.07	5.81	3.76	2.94	2.24	863.26	Winnipeg	BASF
3732	Moose Jaw	SK	233.20	20.00	15.56	10.50	6.74	4.37	3.41	2.60	1009.76	Winnipeg	BASF
3733	Moosomin	SK	233.20	17.05	12.88	8.65	5.54	3.58	2.80	2.14	820.79	Winnipeg	BASF
3734	Morse	SK	247.08	24.71	19.82	13.44	8.65	5.62	4.38	3.34	1311.25	Winnipeg	BASF
3735	Mossbank	SK	233.20	22.79	18.08	12.24	7.87	5.11	3.99	3.04	1188.11	Winnipeg	BASF
3736	Naicam	SK	241.78	24.18	19.34	13.11	8.44	5.48	4.27	3.25	1277.28	Winnipeg	BASF
3737	Neilburg	SK	334.51	33.45	27.74	18.90	12.21	7.94	6.19	4.70	1871.30	Winnipeg	BASF
3738	Neville	SK	286.52	28.65	23.40	15.90	10.26	6.66	5.20	3.95	1563.91	Winnipeg	BASF
3739	Nipawin	SK	289.54	28.95	23.67	16.09	10.38	6.74	5.26	4.00	1583.27	Winnipeg	BASF
3740	Nokomis	SK	233.20	22.63	17.94	12.14	7.81	5.07	3.95	3.01	1178.30	Winnipeg	BASF
3741	Norquay	SK	233.20	21.82	17.21	11.64	7.48	4.85	3.79	2.89	1126.53	Winnipeg	BASF
3742	North Battleford	SK	322.32	32.23	26.64	18.14	11.71	7.62	5.94	4.51	1793.21	Winnipeg	BASF
3743	Odessa	SK	233.20	17.91	13.66	9.19	5.89	3.81	2.98	2.27	876.00	Winnipeg	BASF
3744	Ogema	SK	233.20	21.86	17.24	11.66	7.50	4.86	3.79	2.89	1128.66	Winnipeg	BASF
3745	Osler	SK	279.23	27.92	22.73	15.45	9.96	6.47	5.05	3.84	1517.20	Winnipeg	BASF
3746	Oungre	SK	233.20	19.87	15.44	10.42	6.69	4.33	3.38	2.58	1001.27	Winnipeg	BASF
3747	Outlook	SK	267.63	26.76	21.68	14.72	9.49	6.16	4.81	3.66	1442.89	Winnipeg	BASF
3748	Oxbow	SK	233.20	19.69	15.28	10.30	6.62	4.28	3.35	2.55	989.88	Winnipeg	BASF
3749	Pangman	SK	233.20	21.00	16.46	11.12	7.15	4.63	3.62	2.76	1073.45	Winnipeg	BASF
3750	Paradise Hill	SK	343.30	34.33	28.54	19.45	12.56	8.17	6.38	4.84	1927.61	Winnipeg	BASF
3751	Parkside	SK	319.66	31.97	26.40	17.98	11.60	7.55	5.89	4.47	1776.23	Winnipeg	BASF
3752	Pasqua	SK	235.42	19.63	15.31	10.34	6.64	4.30	3.36	2.56	976.54	Winnipeg	BASF
3753	Paynton	SK	344.49	34.45	28.65	19.53	12.61	8.20	6.40	4.86	1935.26	Winnipeg	BASF
3754	Peesane	SK	233.20	14.89	10.92	7.30	4.67	3.01	2.35	1.80	682.36	Winnipeg	BASF
3755	Pelly	SK	233.20	22.13	17.48	11.83	7.61	4.93	3.85	2.93	1145.81	Winnipeg	BASF
3756	Pense	SK	233.20	18.61	14.29	9.63	6.18	4.00	3.12	2.38	920.58	Winnipeg	BASF
3757	Perdue	SK	292.82	29.28	23.97	16.30	10.51	6.83	5.33	4.05	1604.25	Winnipeg	BASF
3758	Pilot Butte 	SK	233.20	17.05	12.88	8.65	5.54	3.58	2.80	2.14	820.79	Winnipeg	BASF
3759	Plenty	SK	329.94	32.99	27.33	18.62	12.02	7.82	6.10	4.63	1842.05	Winnipeg	BASF
3760	Ponteix	SK	298.33	29.83	24.47	16.64	10.74	6.98	5.45	4.14	1639.58	Winnipeg	BASF
3761	Porcupine Plain	SK	259.80	25.98	20.97	14.23	9.17	5.95	4.65	3.53	1392.70	Winnipeg	BASF
3762	Prairie River	SK	279.40	27.94	22.75	15.46	9.97	6.48	5.05	3.84	1518.30	Winnipeg	BASF
3763	Prince Albert	SK	303.76	30.38	24.96	16.98	10.96	7.12	5.56	4.22	1674.31	Winnipeg	BASF
3764	Quill Lake	Sk	233.20	22.55	17.87	12.09	7.78	5.04	3.94	3.00	1173.24	Winnipeg	BASF
3765	Rabbit Lake	SK	359.52	35.95	30.01	20.47	13.22	8.60	6.71	5.09	2031.56	Winnipeg	BASF
3766	Radisson	SK	294.81	29.48	24.15	16.42	10.59	6.88	5.37	4.08	1616.99	Winnipeg	BASF
3767	Radville	SK	233.20	19.80	15.38	10.37	6.66	4.31	3.37	2.57	997.02	Winnipeg	BASF
3768	Rama	SK	233.20	21.89	17.27	11.68	7.51	4.87	3.80	2.90	1130.65	Winnipeg	BASF
3769	Raymore	SK	233.20	19.87	15.44	10.42	6.69	4.33	3.38	2.58	1001.27	Winnipeg	BASF
3770	Redvers	SK	233.20	18.54	14.23	9.59	6.15	3.98	3.11	2.37	916.34	Winnipeg	BASF
3771	Regina	SK	233.20	16.26	12.17	8.16	5.22	3.37	2.64	2.02	726.73	Winnipeg	BASF
3772	Rhein	SK	233.20	20.13	15.67	10.58	6.80	4.40	3.44	2.62	1018.04	Winnipeg	BASF
3773	Riceton	SK	233.20	19.07	14.72	9.92	6.37	4.12	3.22	2.46	950.31	Winnipeg	BASF
3774	Richardson	SK	233.20	17.32	13.12	8.82	5.65	3.65	2.85	2.18	837.78	Winnipeg	BASF
3775	Ridgedale	SK	277.71	27.77	22.60	15.35	9.90	6.43	5.02	3.81	1507.47	Winnipeg	BASF
3776	Rocanville	SK	233.20	18.08	13.81	9.30	5.96	3.86	3.01	2.30	886.61	Winnipeg	BASF
3777	Rockhaven	SK	338.90	33.89	28.14	19.18	12.38	8.06	6.28	4.77	1899.46	Winnipeg	BASF
3778	Rose Valley	SK	236.13	23.61	18.83	12.75	8.21	5.33	4.16	3.16	1241.10	Winnipeg	BASF
3779	Rosetown	SK	300.77	30.08	24.69	16.79	10.84	7.04	5.50	4.17	1655.21	Winnipeg	BASF
3780	Rosthern	SK	293.48	29.35	24.03	16.34	10.54	6.85	5.34	4.06	1608.50	Winnipeg	BASF
3781	Rouleau	SK	233.20	19.94	15.50	10.46	6.72	4.35	3.40	2.59	1005.51	Winnipeg	BASF
3782	Rowatt	SK	233.20	17.48	13.27	8.92	5.72	3.70	2.89	2.21	848.40	Winnipeg	BASF
3783	Saskatoon	SK	266.31	26.63	21.56	14.64	9.44	6.13	4.78	3.64	1353.21	Winnipeg	BASF
3784	Sceptre	Sk	328.76	32.88	27.22	18.54	11.97	7.79	6.07	4.61	1834.49	Winnipeg	BASF
3785	Sedley	SK	233.20	18.18	13.90	9.36	6.00	3.88	3.03	2.32	892.98	Winnipeg	BASF
3786	Shamrock	SK	240.45	24.05	19.22	13.03	8.39	5.44	4.25	3.23	1268.79	Winnipeg	BASF
3787	Shaunavon	SK	319.29	31.93	26.37	17.95	11.59	7.54	5.88	4.46	1773.85	Winnipeg	BASF
3788	Shellbrook	SK	319.66	31.97	26.40	17.98	11.60	7.55	5.89	4.47	1776.23	Winnipeg	BASF
3789	Simpson	SK	233.83	23.38	18.62	12.61	8.12	5.26	4.11	3.13	1226.32	Winnipeg	BASF
3790	Sintaluta	SK	233.20	17.09	12.91	8.68	5.56	3.59	2.81	2.14	822.92	Winnipeg	BASF
3791	Southey	SK	233.20	19.41	15.02	10.13	6.50	4.21	3.29	2.51	971.54	Winnipeg	BASF
3792	Spalding	SK	252.83	25.28	20.34	13.80	8.89	5.77	4.50	3.43	1348.04	Winnipeg	BASF
3793	Speers	SK	316.68	31.67	26.13	17.79	11.48	7.47	5.82	4.42	1757.12	Winnipeg	BASF
3794	Spiritwood	SK	343.63	34.36	28.57	19.47	12.58	8.18	6.38	4.84	1929.78	Winnipeg	BASF
3795	St Brieux	SK	261.00	26.10	21.08	14.31	9.22	5.99	4.67	3.55	1400.42	Winnipeg	BASF
3796	St. Walburg	SK	360.24	36.02	30.08	20.51	13.25	8.62	6.73	5.10	2036.18	Winnipeg	BASF
3797	Star City	SK	280.40	28.04	22.84	15.52	10.01	6.50	5.07	3.86	1524.66	Winnipeg	BASF
3798	Stewart Valley	SK	287.52	28.75	23.49	15.97	10.30	6.69	5.22	3.97	1570.28	Winnipeg	BASF
3799	Stockholm	SK	233.20	18.10	13.84	9.31	5.97	3.86	3.02	2.30	888.10	Winnipeg	BASF
3800	Stoughton	SK	233.20	17.52	13.30	8.94	5.73	3.71	2.90	2.21	850.52	Winnipeg	BASF
3801	Strasbourg	SK	233.20	20.33	15.86	10.71	6.88	4.46	3.48	2.65	1030.99	Winnipeg	BASF
3802	Strongfield	SK	253.38	25.34	20.39	13.83	8.91	5.78	4.51	3.43	1351.59	Winnipeg	BASF
3803	Sturgis	SK	233.20	22.36	17.70	11.97	7.70	4.99	3.90	2.97	1160.97	Winnipeg	BASF
3804	Swift Current	SK	270.95	27.09	21.98	14.93	9.62	6.25	4.88	3.71	1464.12	Winnipeg	BASF
3805	Theodore	SK	233.20	20.06	15.61	10.54	6.77	4.38	3.42	2.61	1013.71	Winnipeg	BASF
3806	Tisdale	SK	260.34	26.03	21.02	14.27	9.19	5.97	4.66	3.54	1396.18	Winnipeg	BASF
3807	Tompkins	SK	322.29	32.23	26.64	18.14	11.71	7.61	5.94	4.51	1793.04	Winnipeg	BASF
3808	Torquay	SK	233.20	20.27	15.80	10.66	6.85	4.44	3.47	2.64	1026.70	Winnipeg	BASF
3809	Tribune	SK	233.20	20.47	15.98	10.79	6.93	4.49	3.51	2.67	1039.69	Winnipeg	BASF
3810	Tugaske	SK	236.81	23.68	18.89	12.80	8.24	5.34	4.17	3.18	1245.43	Winnipeg	BASF
3811	Turtleford	SK	340.93	34.09	28.33	19.30	12.47	8.11	6.33	4.80	1912.45	Winnipeg	BASF
3812	Tuxford	SK	233.20	20.80	16.28	11.00	7.07	4.58	3.58	2.72	1060.71	Winnipeg	BASF
3813	Unity	SK	345.32	34.53	28.72	19.58	12.65	8.23	6.42	4.87	1940.60	Winnipeg	BASF
3814	Valparaiso	SK	279.68	27.97	22.78	15.48	9.98	6.48	5.06	3.85	1520.08	Winnipeg	BASF
3815	Vanscoy	SK	297.58	29.76	24.40	16.60	10.71	6.96	5.43	4.13	1634.77	Winnipeg	BASF
3816	Vibank	SK	233.20	17.68	13.45	9.05	5.80	3.75	2.93	2.24	861.13	Winnipeg	BASF
3817	Viscount	SK	242.11	24.21	19.37	13.13	8.45	5.49	4.28	3.26	1279.40	Winnipeg	BASF
3818	Wadena	SK	233.20	21.69	17.09	11.55	7.43	4.82	3.76	2.86	1118.04	Winnipeg	BASF
3819	Wakaw	SK	277.91	27.79	22.61	15.37	9.91	6.44	5.02	3.82	1508.71	Winnipeg	BASF
3820	Waldheim	SK	290.83	29.08	23.79	16.17	10.43	6.78	5.29	4.02	1591.51	Winnipeg	BASF
3821	Waldron	SK	233.20	18.20	13.93	9.37	6.01	3.89	3.04	2.32	894.60	Winnipeg	BASF
3822	Wapella	Sk	233.20	17.09	12.91	8.68	5.56	3.59	2.81	2.14	822.92	Winnipeg	BASF
3823	Watrous	SK	237.47	23.75	18.95	12.84	8.26	5.36	4.19	3.19	1249.68	Winnipeg	BASF
3824	Watson	SK	233.20	22.85	18.14	12.28	7.90	5.12	4.00	3.05	1192.35	Winnipeg	BASF
3825	Wawota	SK	233.20	17.81	13.57	9.13	5.85	3.79	2.96	2.26	869.63	Winnipeg	BASF
3826	Weyburn	SK	233.20	18.18	13.90	9.36	6.00	3.88	3.03	2.32	892.98	Winnipeg	BASF
3827	White City	SK	233.20	17.09	12.91	8.68	5.56	3.59	2.81	2.14	822.92	Winnipeg	BASF
3828	White Star	SK	329.09	32.91	27.25	18.56	11.99	7.80	6.08	4.62	1836.62	Winnipeg	BASF
3829	Whitewood	SK	233.20	17.05	12.88	8.65	5.54	3.58	2.80	2.14	820.79	Winnipeg	BASF
3830	Wilcox	Sk	233.20	19.27	14.90	10.04	6.45	4.17	3.26	2.49	963.05	Winnipeg	BASF
3831	Wilkie	SK	350.06	35.01	29.15	19.88	12.84	8.35	6.52	4.94	1970.92	Winnipeg	BASF
3832	Wiseton	SK	285.20	28.52	23.28	15.82	10.20	6.63	5.17	3.93	1555.42	Winnipeg	BASF
3833	Wolseley	SK	233.20	17.05	12.88	8.65	5.54	3.58	2.80	2.14	820.79	Winnipeg	BASF
3834	Woodrow	SK	263.85	26.39	21.34	14.49	9.34	6.06	4.73	3.60	1418.68	Winnipeg	BASF
3835	Wymark	SK	280.89	28.09	22.88	15.55	10.03	6.52	5.08	3.86	1527.81	Winnipeg	BASF
3836	Wynyard	SK	233.20	21.06	16.52	11.16	7.17	4.65	3.63	2.77	1077.70	Winnipeg	BASF
3837	Yellow Creek 	SK	277.24	27.72	22.55	15.32	9.88	6.42	5.01	3.81	1504.46	Winnipeg	BASF
3838	Yellow Grass	SK	233.20	18.31	14.02	9.44	6.06	3.92	3.06	2.34	901.48	Winnipeg	BASF
3839	Yorkton	SK	233.20	18.34	14.05	9.46	6.07	3.93	3.07	2.34	903.60	Winnipeg	BASF
\.


--
-- Data for Name: shipment_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipment_orders (shipment_order_id, shipment_id, order_id, stop_sequence, estimated_arrival_time, actual_arrival_time, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: shipments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipments (shipment_id, shipment_date, origin_warehouse_id, truck_id, trailer_id, driver_id, status, total_distance_km, estimated_start_time, actual_start_time, estimated_completion_time, actual_completion_time, total_weight_kg, total_volume_cubic_m, total_revenue, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: vehicle_availability; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehicle_availability (availability_id, vehicle_id, date, is_available, reason, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehicles (vehicle_id, samsara_id, type, license_plate, make, model, year, max_weight_kg, volume_capacity_cubic_m, has_refrigeration, has_heating, has_tdg_capacity, home_warehouse_id, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: warehouses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.warehouses (warehouse_id, name, address, city, province, postal_code, latitude, longitude, loading_capacity, storage_capacity, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Name: api_logs_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.api_logs_log_id_seq', 1, false);


--
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customers_customer_id_seq', 1, false);


--
-- Name: driver_availability_availability_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.driver_availability_availability_id_seq', 1, false);


--
-- Name: drivers_driver_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.drivers_driver_id_seq', 1, false);


--
-- Name: manufacturers_manufacturer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.manufacturers_manufacturer_id_seq', 1, false);


--
-- Name: optimization_logs_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.optimization_logs_log_id_seq', 1, false);


--
-- Name: order_headers_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_headers_order_id_seq', 1, false);


--
-- Name: order_line_items_line_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_line_items_line_item_id_seq', 1, false);


--
-- Name: rate_tables_rate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rate_tables_rate_id_seq', 3839, true);


--
-- Name: shipment_orders_shipment_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.shipment_orders_shipment_order_id_seq', 1, false);


--
-- Name: shipments_shipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.shipments_shipment_id_seq', 1, false);


--
-- Name: vehicle_availability_availability_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vehicle_availability_availability_id_seq', 1, false);


--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vehicles_vehicle_id_seq', 1, false);


--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.warehouses_warehouse_id_seq', 1, false);


--
-- Name: api_logs api_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_logs
    ADD CONSTRAINT api_logs_pkey PRIMARY KEY (log_id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: driver_availability driver_availability_driver_id_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_availability
    ADD CONSTRAINT driver_availability_driver_id_date_key UNIQUE (driver_id, date);


--
-- Name: driver_availability driver_availability_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_availability
    ADD CONSTRAINT driver_availability_pkey PRIMARY KEY (availability_id);


--
-- Name: drivers drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (driver_id);


--
-- Name: manufacturers manufacturers_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manufacturers
    ADD CONSTRAINT manufacturers_name_key UNIQUE (name);


--
-- Name: manufacturers manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (manufacturer_id);


--
-- Name: optimization_logs optimization_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.optimization_logs
    ADD CONSTRAINT optimization_logs_pkey PRIMARY KEY (log_id);


--
-- Name: order_headers order_headers_document_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_headers
    ADD CONSTRAINT order_headers_document_id_key UNIQUE (document_id);


--
-- Name: order_headers order_headers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_headers
    ADD CONSTRAINT order_headers_pkey PRIMARY KEY (order_id);


--
-- Name: order_line_items order_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_items
    ADD CONSTRAINT order_line_items_pkey PRIMARY KEY (line_item_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: rate_tables rate_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rate_tables
    ADD CONSTRAINT rate_tables_pkey PRIMARY KEY (rate_id);


--
-- Name: shipment_orders shipment_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipment_orders
    ADD CONSTRAINT shipment_orders_pkey PRIMARY KEY (shipment_order_id);


--
-- Name: shipments shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (shipment_id);


--
-- Name: rate_tables unique_rate; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rate_tables
    ADD CONSTRAINT unique_rate UNIQUE (customer_name, origin_warehouse_id, destination_city);


--
-- Name: vehicle_availability vehicle_availability_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_availability
    ADD CONSTRAINT vehicle_availability_pkey PRIMARY KEY (availability_id);


--
-- Name: vehicle_availability vehicle_availability_vehicle_id_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_availability
    ADD CONSTRAINT vehicle_availability_vehicle_id_date_key UNIQUE (vehicle_id, date);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (warehouse_id);


--
-- Name: idx_driver_availability_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_driver_availability_date ON public.driver_availability USING btree (date);


--
-- Name: idx_order_headers_customer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_headers_customer ON public.order_headers USING btree (customer_id);


--
-- Name: idx_order_headers_dates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_headers_dates ON public.order_headers USING btree (requested_shipment_date, requested_delivery_date);


--
-- Name: idx_order_headers_manufacturer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_headers_manufacturer ON public.order_headers USING btree (manufacturer_id);


--
-- Name: idx_order_headers_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_headers_status ON public.order_headers USING btree (status);


--
-- Name: idx_order_line_items_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_line_items_order ON public.order_line_items USING btree (order_id);


--
-- Name: idx_shipment_orders_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shipment_orders_order ON public.shipment_orders USING btree (order_id);


--
-- Name: idx_shipment_orders_shipment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shipment_orders_shipment ON public.shipment_orders USING btree (shipment_id);


--
-- Name: idx_shipments_dates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shipments_dates ON public.shipments USING btree (shipment_date);


--
-- Name: idx_shipments_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shipments_status ON public.shipments USING btree (status);


--
-- Name: idx_shipments_warehouse; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shipments_warehouse ON public.shipments USING btree (origin_warehouse_id);


--
-- Name: idx_vehicle_availability_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehicle_availability_date ON public.vehicle_availability USING btree (date);


--
-- Name: driver_availability driver_availability_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.driver_availability
    ADD CONSTRAINT driver_availability_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(driver_id);


--
-- Name: drivers drivers_home_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_home_warehouse_id_fkey FOREIGN KEY (home_warehouse_id) REFERENCES public.warehouses(warehouse_id);


--
-- Name: order_headers order_headers_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_headers
    ADD CONSTRAINT order_headers_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- Name: order_headers order_headers_manufacturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_headers
    ADD CONSTRAINT order_headers_manufacturer_id_fkey FOREIGN KEY (manufacturer_id) REFERENCES public.manufacturers(manufacturer_id);


--
-- Name: order_line_items order_line_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_items
    ADD CONSTRAINT order_line_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.order_headers(order_id);


--
-- Name: order_line_items order_line_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_items
    ADD CONSTRAINT order_line_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: products products_manufacturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_manufacturer_id_fkey FOREIGN KEY (manufacturer_id) REFERENCES public.manufacturers(manufacturer_id);


--
-- Name: shipment_orders shipment_orders_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipment_orders
    ADD CONSTRAINT shipment_orders_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.order_headers(order_id);


--
-- Name: shipment_orders shipment_orders_shipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipment_orders
    ADD CONSTRAINT shipment_orders_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES public.shipments(shipment_id);


--
-- Name: shipments shipments_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(driver_id);


--
-- Name: shipments shipments_origin_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_origin_warehouse_id_fkey FOREIGN KEY (origin_warehouse_id) REFERENCES public.warehouses(warehouse_id);


--
-- Name: shipments shipments_trailer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_trailer_id_fkey FOREIGN KEY (trailer_id) REFERENCES public.vehicles(vehicle_id);


--
-- Name: shipments shipments_truck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_truck_id_fkey FOREIGN KEY (truck_id) REFERENCES public.vehicles(vehicle_id);


--
-- Name: vehicle_availability vehicle_availability_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_availability
    ADD CONSTRAINT vehicle_availability_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id);


--
-- Name: vehicles vehicles_home_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_home_warehouse_id_fkey FOREIGN KEY (home_warehouse_id) REFERENCES public.warehouses(warehouse_id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

