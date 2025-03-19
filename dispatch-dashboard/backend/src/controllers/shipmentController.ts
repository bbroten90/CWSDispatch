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
  if (req.query.driver_id) filters.driver_id = parseInt(req.query.driver_id as string, 10);
  if (req.query.truck_id) filters.truck_id = parseInt(req.query.truck_id as string, 10);
  if (req.query.trailer_id) filters.trailer_id = parseInt(req.query.trailer_id as string, 10);
  if (req.query.origin_warehouse_id) filters.origin_warehouse_id = parseInt(req.query.origin_warehouse_id as string, 10);
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
  
  const shipment = await getShipmentById(parseInt(id, 10));
  
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
  
  const shipmentDetails = await getShipmentWithDetails(parseInt(id, 10));
  
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
  
  // Check if truck exists and is active
  const truck = await getVehicleById(req.body.truck_id);
  if (!truck) {
    throw new ApiError('Truck not found', 404);
  }
  if (truck.status !== 'active') {
    throw new ApiError('Truck is not active', 400);
  }
  
  // Check if trailer exists and is active (if provided)
  if (req.body.trailer_id) {
    const trailer = await getVehicleById(req.body.trailer_id);
    if (!trailer) {
      throw new ApiError('Trailer not found', 404);
    }
    if (trailer.status !== 'active') {
      throw new ApiError('Trailer is not active', 400);
    }
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
  const existingShipment = await getShipmentById(parseInt(id, 10));
  if (!existingShipment) {
    throw new ApiError('Shipment not found', 404);
  }
  
  // If changing status to 'IN_TRANSIT', ensure actual_start_time is provided
  if (req.body.status === 'IN_TRANSIT' && !req.body.actual_start_time && !existingShipment.actual_start_time) {
    req.body.actual_start_time = new Date();
  }
  
  // If changing status to 'DELIVERED', ensure actual_completion_time is provided
  if (req.body.status === 'DELIVERED' && !req.body.actual_completion_time && !existingShipment.actual_completion_time) {
    req.body.actual_completion_time = new Date();
  }
  
  // If changing truck or trailer, verify they exist and are active
  if (req.body.truck_id) {
    const truck = await getVehicleById(req.body.truck_id);
    if (!truck) {
      throw new ApiError('Truck not found', 404);
    }
    if (truck.status !== 'active') {
      throw new ApiError('Truck is not active', 400);
    }
  }
  
  if (req.body.trailer_id) {
    const trailer = await getVehicleById(req.body.trailer_id);
    if (!trailer) {
      throw new ApiError('Trailer not found', 404);
    }
    if (trailer.status !== 'active') {
      throw new ApiError('Trailer is not active', 400);
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
  
  const updatedShipment = await updateShipment(parseInt(id, 10), req.body);
  
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
  const existingShipment = await getShipmentById(parseInt(id, 10));
  if (!existingShipment) {
    throw new ApiError('Shipment not found', 404);
  }
  
  // Don't allow deleting completed shipments
  if (existingShipment.status === 'DELIVERED') {
    throw new ApiError('Cannot delete completed shipments', 400);
  }
  
  await deleteShipment(parseInt(id, 10));
  
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
  
  const shipments = await getDriverActiveShipments(parseInt(driverId, 10));
  
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
  
  if (!status || !['PLANNED', 'LOADING', 'LOADED', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED'].includes(status)) {
    throw new ApiError('Invalid status value', 400);
  }
  
  // Check if shipment exists
  const existingShipment = await getShipmentById(parseInt(id, 10));
  if (!existingShipment) {
    throw new ApiError('Shipment not found', 404);
  }
  
  const updateData: any = { status };
  
  // Automatically set timestamps based on status changes
  if (status === 'IN_TRANSIT' && !existingShipment.actual_start_time) {
    updateData.actual_start_time = new Date();
  }
  
  if (status === 'DELIVERED' && !existingShipment.actual_completion_time) {
    updateData.actual_completion_time = new Date();
  }
  
  const updatedShipment = await updateShipment(parseInt(id, 10), updateData);
  
  res.status(200).json({
    status: 'success',
    data: {
      shipment: updatedShipment,
    },
  });
};
