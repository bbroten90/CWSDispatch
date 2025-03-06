// src/controllers/shipmentController.ts
import { Request, Response } from 'express';
import { 
  createShipment, 
  getShipments, 
  getShipmentById, 
  updateShipment, 
  deleteShipment,
  getShipmentWithDetails,
  getDriverActiveShipments,
  getWeekShipments,
  ShipmentFilters
} from '../models/shipmentModel';
import { getVehicleById } from '../models/vehicleModel';
import { getDriverById } from '../models/driverModel';
import { getOrderById } from '../models/orderModel';
import { ApiError } from '../middleware/errorHandler';
import { validateShipment } from '../utils/validators';

// Get all shipments
export const getAllShipments = async (req: Request, res: Response) => {
  const filters: ShipmentFilters = {};
  
  // Extract and validate query parameters
  if (req.query.status) filters.status = req.query.status as string;
  if (req.query.driver_id) filters.driver_id = req.query.driver_id as string;
  if (req.query.vehicle_id) filters.vehicle_id = req.query.vehicle_id as string;
  if (req.query.start_date) filters.start_date = new Date(req.query.start_date as string);
  if (req.query.end_date) filters.end_date = new Date(req.query.end_date as string);
  
  const shipments = await getShipments(filters);
  
  res.status(200).json({
    status: 'success',
    results: shipments.length,
    data: {
      shipments,
    },
  });
};

// Get a single shipment
export const getShipment = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  const shipment = await getShipmentById(id);
  
  if (!shipment) {
    throw new ApiError('Shipment not found', 404);
  }
  
  res.status(200).json({
    status: 'success',
    data: {
      shipment,
    },
  });
};

// Get shipment with details
export const getShipmentDetails = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  const shipmentDetails = await getShipmentWithDetails(id);
  
  if (!shipmentDetails) {
    throw new ApiError('Shipment not found', 404);
  }
  
  res.status(200).json({
    status: 'success',
    data: {
      shipment: shipmentDetails,
    },
  });
};

// Create a new shipment
export const createNewShipment = async (req: Request, res: Response) => {
  // Validate shipment data
  const validation = validateShipment(req.body);
  if (!validation.valid) {
    throw new ApiError(validation.message || 'Invalid shipment data', 400);
  }
  
  // Check if order exists and is in 'pending' status
  const order = await getOrderById(req.body.order_id);
  if (!order) {
    throw new ApiError('Order not found', 404);
  }
  if (order.status !== 'pending') {
    throw new ApiError('Order is already assigned or completed', 400);
  }
  
  // Check if vehicle exists and is active
  const vehicle = await getVehicleById(req.body.vehicle_id);
  if (!vehicle) {
    throw new ApiError('Vehicle not found', 404);
  }
  if (vehicle.status !== 'active') {
    throw new ApiError('Vehicle is not active', 400);
  }
  
  // Check if driver exists and is active
  const driver = await getDriverById(req.body.driver_id);
  if (!driver) {
    throw new ApiError('Driver not found', 404);
  }
  if (driver.status !== 'active') {
    throw new ApiError('Driver is not active', 400);
  }
  
  const newShipment = await createShipment(req.body);
  
  res.status(201).json({
    status: 'success',
    data: {
      shipment: newShipment,
    },
  });
};

// Update a shipment
export const updateExistingShipment = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  // Check if shipment exists
  const existingShipment = await getShipmentById(id);
  if (!existingShipment) {
    throw new ApiError('Shipment not found', 404);
  }
  
  // If changing status to 'in_transit', ensure actual_departure is provided
  if (req.body.status === 'in_transit' && !req.body.actual_departure && !existingShipment.actual_departure) {
    req.body.actual_departure = new Date();
  }
  
  // If changing status to 'completed', ensure actual_arrival is provided
  if (req.body.status === 'completed' && !req.body.actual_arrival && !existingShipment.actual_arrival) {
    req.body.actual_arrival = new Date();
  }
  
  // If changing vehicle or driver, verify they exist and are active
  if (req.body.vehicle_id) {
    const vehicle = await getVehicleById(req.body.vehicle_id);
    if (!vehicle) {
      throw new ApiError('Vehicle not found', 404);
    }
    if (vehicle.status !== 'active') {
      throw new ApiError('Vehicle is not active', 400);
    }
  }
  
  if (req.body.driver_id) {
    const driver = await getDriverById(req.body.driver_id);
    if (!driver) {
      throw new ApiError('Driver not found', 404);
    }
    if (driver.status !== 'active') {
      throw new ApiError('Driver is not active', 400);
    }
  }
  
  const updatedShipment = await updateShipment(id, req.body);
  
  res.status(200).json({
    status: 'success',
    data: {
      shipment: updatedShipment,
    },
  });
};

// Delete a shipment
export const deleteExistingShipment = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  // Check if shipment exists
  const existingShipment = await getShipmentById(id);
  if (!existingShipment) {
    throw new ApiError('Shipment not found', 404);
  }
  
  // Don't allow deleting completed shipments
  if (existingShipment.status === 'completed') {
    throw new ApiError('Cannot delete completed shipments', 400);
  }
  
  await deleteShipment(id);
  
  res.status(204).json({
    status: 'success',
    data: null,
  });
};

// Get driver's active shipments
export const getDriverShipments = async (req: Request, res: Response) => {
  const { driverId } = req.params;
  
  // Check if driver exists
  const driver = await getDriverById(driverId);
  if (!driver) {
    throw new ApiError('Driver not found', 404);
  }
  
  const shipments = await getDriverActiveShipments(driverId);
  
  res.status(200).json({
    status: 'success',
    results: shipments.length,
    data: {
      shipments,
    },
  });
};

// Get this week's shipment schedule
export const getWeekSchedule = async (req: Request, res: Response) => {
  const shipments = await getWeekShipments();
  
  res.status(200).json({
    status: 'success',
    results: shipments.length,
    data: {
      shipments,
    },
  });
};

// Update shipment status endpoint
export const updateShipmentStatus = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { status } = req.body;
  
  if (!status || !['planned', 'in_transit', 'completed', 'cancelled'].includes(status)) {
    throw new ApiError('Invalid status value', 400);
  }
  
  // Check if shipment exists
  const existingShipment = await getShipmentById(id);
  if (!existingShipment) {
    throw new ApiError('Shipment not found', 404);
  }
  
  const updateData: any = { status };
  
  // Automatically set timestamps based on status changes
  if (status === 'in_transit' && !existingShipment.actual_departure) {
    updateData.actual_departure = new Date();
  }
  
  if (status === 'completed' && !existingShipment.actual_arrival) {
    updateData.actual_arrival = new Date();
  }
  
  const updatedShipment = await updateShipment(id, updateData);
  
  res.status(200).json({
    status: 'success',
    data: {
      shipment: updatedShipment,
    },
  });
};
