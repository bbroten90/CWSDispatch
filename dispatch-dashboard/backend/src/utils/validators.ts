// src/utils/validators.ts
import Joi from 'joi';

// Order validation schema
const orderSchema = Joi.object({
  order_number: Joi.string().required(),
  customer_id: Joi.string().uuid().required(),
  pickup_address: Joi.string().required(),
  pickup_city: Joi.string().required(),
  pickup_province: Joi.string().length(2).required(),
  pickup_postal_code: Joi.string().pattern(/^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$/).required(),
  pickup_date: Joi.date().iso().required(),
  delivery_address: Joi.string().required(),
  delivery_city: Joi.string().required(),
  delivery_province: Joi.string().length(2).required(),
  delivery_postal_code: Joi.string().pattern(/^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$/).required(),
  delivery_date: Joi.date().iso().min(Joi.ref('pickup_date')).required(),
  total_weight: Joi.number().positive().required(),
  total_volume: Joi.number().positive().required(),
  special_instructions: Joi.string().allow('', null)
});

// Order update validation schema (all fields optional)
const orderUpdateSchema = Joi.object({
  status: Joi.string().valid('pending', 'assigned', 'in_transit', 'delivered', 'cancelled'),
  pickup_date: Joi.date().iso(),
  delivery_date: Joi.date().iso(),
  special_instructions: Joi.string().allow('', null)
});

// Shipment validation schema
const shipmentSchema = Joi.object({
  order_id: Joi.string().uuid().required(),
  vehicle_id: Joi.string().uuid().required(),
  driver_id: Joi.string().uuid().required(),
  planned_departure: Joi.date().iso().required(),
  planned_arrival: Joi.date().iso().min(Joi.ref('planned_departure')).required(),
  actual_departure: Joi.date().iso().allow(null),
  actual_arrival: Joi.date().iso().allow(null),
  status: Joi.string().valid('planned', 'in_transit', 'completed', 'cancelled').required(),
  notes: Joi.string().allow('', null)
});

// Driver validation schema
const driverSchema = Joi.object({
  first_name: Joi.string().required(),
  last_name: Joi.string().required(),
  email: Joi.string().email().required(),
  phone: Joi.string().pattern(/^\d{10}$/).required(),
  license_number: Joi.string().required(),
  license_expiry: Joi.date().iso().required(),
  status: Joi.string().valid('active', 'inactive', 'on_leave').required(),
  notes: Joi.string().allow('', null)
});

// Vehicle validation schema
const vehicleSchema = Joi.object({
  vehicle_number: Joi.string().required(),
  type: Joi.string().required(),
  make: Joi.string().required(),
  model: Joi.string().required(),
  year: Joi.number().integer().min(1900).max(new Date().getFullYear() + 1).required(),
  vin: Joi.string().length(17).required(),
  plate_number: Joi.string().required(),
  capacity_weight: Joi.number().positive().required(),
  capacity_volume: Joi.number().positive().required(),
  status: Joi.string().valid('active', 'maintenance', 'out_of_service').required(),
  notes: Joi.string().allow('', null)
});

// Rate validation schema
const rateSchema = Joi.object({
  origin_region: Joi.string().pattern(/^[A-Za-z]\d[A-Za-z]$/).required(), // First 3 characters of postal code (FSA)
  destination_region: Joi.string().pattern(/^[A-Za-z]\d[A-Za-z]$/).required(), // First 3 characters of postal code (FSA)
  rate_per_mile: Joi.number().positive().required(),
  rate_per_pound: Joi.number().positive().required(),
  base_rate: Joi.number().min(0).required(),
  effective_date: Joi.date().iso().required(),
  expiration_date: Joi.date().iso().min(Joi.ref('effective_date')),
  is_active: Joi.boolean().required()
});

// Generic validation function
const validate = (schema: Joi.ObjectSchema, data: any) => {
  const { error } = schema.validate(data, { abortEarly: false });
  
  if (error) {
    const message = error.details.map(detail => detail.message).join('; ');
    return { valid: false, message };
  }
  
  return { valid: true };
};

// Exported validation functions
export const validateOrder = (data: any) => validate(orderSchema, data);
export const validateOrderUpdate = (data: any) => validate(orderUpdateSchema, data);
export const validateShipment = (data: any) => validate(shipmentSchema, data);
export const validateDriver = (data: any) => validate(driverSchema, data);
export const validateVehicle = (data: any) => validate(vehicleSchema, data);
export const validateRate = (data: any) => validate(rateSchema, data);
