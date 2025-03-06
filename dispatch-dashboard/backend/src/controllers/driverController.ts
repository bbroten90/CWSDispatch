// src/controllers/driverController.ts
import { Request, Response } from 'express';
import { 
  createDriver, 
  getDrivers, 
  getDriverById, 
  updateDriver, 
  deleteDriver,
  getDriverWithAssignmentStatus,
  getDriversWithExpiringLicenses,
  getDriverShipmentHistory,
  getDriverPerformanceMetrics,
  DriverFilters
} from '../models/driverModel';
import { ApiError } from '../middleware/errorHandler';
import { validateDriver } from '../utils/validators';

// Get all drivers
export const getAllDrivers = async (req: Request, res: Response) => {
  const filters: DriverFilters = {};
  
  // Extract and validate query parameters
  if (req.query.status) filters.status = req.query.status as string;
  if (req.query.license_expiring_soon === 'true') filters.license_expiring_soon = true;
  if (req.query.available === 'true') filters.available = true;
  
  const drivers = await getDrivers(filters);
  
  res.status(200).json({
    status: 'success',
    results: drivers.length,
    data: {
      drivers,
    },
  });
};

// Get a single driver
export const getDriver = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  const driver = await getDriverById(id);
  
  if (!driver) {
    throw new ApiError('Driver not found', 404);
  }
  
  res.status(200).json({
    status: 'success',
    data: {
      driver,
    },
  });
};

// Get driver with assignment details
export const getDriverDetails = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  const driverDetails = await getDriverWithAssignmentStatus(id);
  
  if (!driverDetails) {
    throw new ApiError('Driver not found', 404);
  }
  
  res.status(200).json({
    status: 'success',
    data: {
      driver: driverDetails,
    },
  });
};

// Create a new driver
export const createNewDriver = async (req: Request, res: Response) => {
  // Validate driver data
  const validation = validateDriver(req.body);
  if (!validation.valid) {
    throw new ApiError(validation.message || 'Invalid driver data', 400);
  }
  
  // Check for duplicate email
  const existingDrivers = await getDrivers({ status: 'all' });
  const emailExists = existingDrivers.some(d => d.email === req.body.email);
  if (emailExists) {
    throw new ApiError('A driver with this email already exists', 400);
  }
  
  const newDriver = await createDriver(req.body);
  
  res.status(201).json({
    status: 'success',
    data: {
      driver: newDriver,
    },
  });
};

// Update a driver
export const updateExistingDriver = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  // Check if driver exists
  const existingDriver = await getDriverById(id);
  if (!existingDriver) {
    throw new ApiError('Driver not found', 404);
  }
  
  // Check for duplicate email if email is being updated
  if (req.body.email && req.body.email !== existingDriver.email) {
    const existingDrivers = await getDrivers({ status: 'all' });
    const emailExists = existingDrivers.some(d => d.email === req.body.email);
    if (emailExists) {
      throw new ApiError('A driver with this email already exists', 400);
    }
  }
  
  const updatedDriver = await updateDriver(id, req.body);
  
  res.status(200).json({
    status: 'success',
    data: {
      driver: updatedDriver,
    },
  });
};

// Delete a driver
export const deleteExistingDriver = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  // Check if driver exists
  const existingDriver = await getDriverById(id);
  if (!existingDriver) {
    throw new ApiError('Driver not found', 404);
  }
  
  // Check if driver is assigned to any active shipments
  const driverDetails = await getDriverWithAssignmentStatus(id);
  if (driverDetails.current_shipment_id) {
    throw new ApiError('Cannot delete driver that is assigned to an active shipment', 400);
  }
  
  await deleteDriver(id);
  
  res.status(204).json({
    status: 'success',
    data: null,
  });
};

// Get drivers with expiring licenses
export const getDriverLicenseExpirations = async (req: Request, res: Response) => {
  const days = req.query.days ? parseInt(req.query.days as string) : 30;
  
  if (isNaN(days) || days < 1 || days > 90) {
    throw new ApiError('Days parameter must be a number between 1 and 90', 400);
  }
  
  const drivers = await getDriversWithExpiringLicenses(days);
  
  res.status(200).json({
    status: 'success',
    results: drivers.length,
    data: {
      drivers,
    },
  });
};

// Get driver shipment history
export const getDriverHistory = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  // Check if driver exists
  const existingDriver = await getDriverById(id);
  if (!existingDriver) {
    throw new ApiError('Driver not found', 404);
  }
  
  const limit = req.query.limit ? parseInt(req.query.limit as string) : 10;
  
  if (isNaN(limit) || limit < 1 || limit > 100) {
    throw new ApiError('Limit parameter must be a number between 1 and 100', 400);
  }
  
  const history = await getDriverShipmentHistory(id, limit);
  
  res.status(200).json({
    status: 'success',
    results: history.length,
    data: {
      history,
    },
  });
};

// Get driver performance metrics
export const getDriverMetrics = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  // Check if driver exists
  const existingDriver = await getDriverById(id);
  if (!existingDriver) {
    throw new ApiError('Driver not found', 404);
  }
  
  // Parse date parameters
  let startDate: Date | undefined;
  let endDate: Date | undefined;
  
  if (req.query.startDate) {
    startDate = new Date(req.query.startDate as string);
    if (isNaN(startDate.getTime())) {
      throw new ApiError('Invalid start date format', 400);
    }
  }
  
  if (req.query.endDate) {
    endDate = new Date(req.query.endDate as string);
    if (isNaN(endDate.getTime())) {
      throw new ApiError('Invalid end date format', 400);
    }
  }
  
  const metrics = await getDriverPerformanceMetrics(id, startDate, endDate);
  
  res.status(200).json({
    status: 'success',
    data: {
      metrics,
      driver: {
        id: existingDriver.id,
        name: `${existingDriver.first_name} ${existingDriver.last_name}`,
      },
      period: {
        startDate: startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
        endDate: endDate || new Date(),
      }
    },
  });
};
