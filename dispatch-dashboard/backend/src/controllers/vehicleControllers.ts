// src/controllers/vehicleController.ts
import { Request, Response } from 'express';
import { 
  createVehicle, 
  getVehicles, 
  getVehicleById, 
  updateVehicle, 
  deleteVehicle,
  getVehicleWithAssignmentStatus,
  getVehicleTypeStats,
  getVehiclesDueForMaintenance,
  VehicleFilters
} from '../models/vehicleModel';
import { ApiError } from '../middleware/errorHandler';
import { validateVehicle } from '../utils/validators';

// Get all vehicles
export const getAllVehicles = async (req: Request, res: Response) => {
  const filters: VehicleFilters = {};
  
  // Extract and validate query parameters
  if (req.query.status === 'active') filters.is_active = true;
  else if (req.query.status === 'inactive') filters.is_active = false;
  if (req.query.type) filters.type = req.query.type as string;
  if (req.query.available === 'true') filters.available = true;
  
  const vehicles = await getVehicles(filters);
  
  res.status(200).json({
    status: 'success',
    results: vehicles.length,
    data: {
      vehicles,
    },
  });
};

// Get a single vehicle
export const getVehicle = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  const vehicle = await getVehicleById(id);
  
  if (!vehicle) {
    throw new ApiError('Vehicle not found', 404);
  }
  
  res.status(200).json({
    status: 'success',
    data: {
      vehicle,
    },
  });
};

// Get vehicle with assignment status
export const getVehicleDetails = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  const vehicleDetails = await getVehicleWithAssignmentStatus(id);
  
  if (!vehicleDetails) {
    throw new ApiError('Vehicle not found', 404);
  }
  
  res.status(200).json({
    status: 'success',
    data: {
      vehicleDetails,
    },
  });
};

// Create a new vehicle
export const createNewVehicle = async (req: Request, res: Response) => {
  // Validate vehicle data
  const validation = validateVehicle(req.body);
  if (!validation.valid) {
    throw new ApiError(validation.message || 'Invalid vehicle data', 400);
  }
  
  const newVehicle = await createVehicle(req.body);
  
  res.status(201).json({
    status: 'success',
    data: {
      vehicle: newVehicle,
    },
  });
};

// Update a vehicle
export const updateExistingVehicle = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  // Check if vehicle exists
  const existingVehicle = await getVehicleById(id);
  if (!existingVehicle) {
    throw new ApiError('Vehicle not found', 404);
  }
  
  // Validate the VIN if it's being updated
  if (req.body.vin && req.body.vin !== existingVehicle.vin) {
    throw new ApiError('VIN cannot be changed', 400);
  }
  
  const updatedVehicle = await updateVehicle(id, req.body);
  
  res.status(200).json({
    status: 'success',
    data: {
      vehicle: updatedVehicle,
    },
  });
};

// Delete a vehicle
export const deleteExistingVehicle = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  // Check if vehicle exists
  const existingVehicle = await getVehicleById(id);
  if (!existingVehicle) {
    throw new ApiError('Vehicle not found', 404);
  }
  
  // Check if vehicle is assigned to any active shipments
  const vehicleDetails = await getVehicleWithAssignmentStatus(id);
  if (vehicleDetails.current_shipment_id) {
    throw new ApiError('Cannot delete vehicle that is assigned to an active shipment', 400);
  }
  
  await deleteVehicle(id);
  
  res.status(204).json({
    status: 'success',
    data: null,
  });
};

// Get vehicle type statistics
export const getVehicleStats = async (req: Request, res: Response) => {
  const stats = await getVehicleTypeStats();
  
  res.status(200).json({
    status: 'success',
    results: stats.length,
    data: {
      stats,
    },
  });
};

// Get vehicles due for maintenance
export const getMaintenanceDue = async (req: Request, res: Response) => {
  const days = req.query.days ? parseInt(req.query.days as string) : 7;
  
  if (isNaN(days) || days < 1 || days > 90) {
    throw new ApiError('Days parameter must be a number between 1 and 90', 400);
  }
  
  const vehicles = await getVehiclesDueForMaintenance(days);
  
  res.status(200).json({
    status: 'success',
    results: vehicles.length,
    data: {
      vehicles,
    },
  });
};
