// src/services/api.ts
import axios from 'axios';

// Create axios instance with base URL
const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:3001/api',
  headers: {
    'Content-Type': 'application/json',
    'x-internal-request': 'true'
  }
});

// Warehouse API
export const getWarehouses = async () => {
  const response = await api.get('/warehouses');
  return response.data;
};

// Customer API
export const getCustomers = async () => {
  const response = await api.get('/customers');
  return response.data;
};

// Order API
export const getOrders = async (filters = {}) => {
  const response = await api.get('/orders', { params: filters });
  return response.data;
};

export const getOrderById = async (id) => {
  const response = await api.get(`/orders/${id}`);
  return response.data;
};

export const createOrder = async (orderData) => {
  const response = await api.post('/orders', orderData);
  return response.data;
};

export const updateOrderStatus = async (id, status) => {
  const response = await api.patch(`/orders/${id}`, { status });
  return response.data;
};

// Vehicle API
export const getVehicles = async (filters = {}) => {
  const response = await api.get('/vehicles', { params: filters });
  return response.data;
};

// Shipment API
export const getShipments = async (filters = {}) => {
  const response = await api.get('/shipments', { params: filters });
  return response.data;
};

export const getShipmentById = async (id) => {
  const response = await api.get(`/shipments/${id}`);
  return response.data;
};

export const getShipmentDetails = async (id) => {
  const response = await api.get(`/shipments/${id}/details`);
  return response.data;
};

export const createShipment = async (shipmentData) => {
  const response = await api.post('/shipments', shipmentData);
  return response.data;
};

export const updateShipmentStatus = async (id, status) => {
  const response = await api.patch(`/shipments/${id}/status`, { status });
  return response.data;
};

export const optimizeLoads = async (warehouseId, date) => {
  const response = await api.post('/shipments/optimize', { warehouseId, date });
  return response.data;
};

export default api;
