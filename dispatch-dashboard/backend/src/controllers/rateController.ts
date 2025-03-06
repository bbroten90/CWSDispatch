// src/controllers/rateController.ts
import { Request, Response } from 'express';
import { 
  createRate, 
  getRates, 
  getRateById, 
  updateRate, 
  deleteRate,
  findApplicableRate,
  calculateShippingCost,
  RateFilters
} from '../models/rateModel';
import { ApiError } from '../middleware/errorHandler';
import { validateRate } from '../utils/validators';

// Get all rates
export const getAllRates = async (req: Request, res: Response) => {
  const filters: RateFilters = {};
  
  // Extract and validate query parameters
  if (req.query.origin_region) filters.origin_region = req.query.origin_region as string;
  if (req.query.destination_region) filters.destination_region = req.query.destination_region as string;
  if (req.query.is_active === 'true') filters.is_active = true;
  if (req.query.is_active === 'false') filters.is_active = false;
  if (req.query.effective_after) filters.effective_after = new Date(req.query.effective_after as string);
  if (req.query.expiring_before) filters.expiring_before = new Date(req.query.expiring_before as string);
  
  const rates = await getRates(filters);
  
  res.status(200).json({
    status: 'success',
    results: rates.length,
    data: {
      rates,
    },
  });
};

// Get a single rate
export const getRate = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  const rate = await getRateById(id);
  
  if (!rate) {
    throw new ApiError('Rate not found', 404);
  }
  
  res.status(200).json({
    status: 'success',
    data: {
      rate,
    },
  });
};

// Create a new rate
export const createNewRate = async (req: Request, res: Response) => {
  // Validate rate data
  const validation = validateRate(req.body);
  if (!validation.valid) {
    throw new ApiError(validation.message || 'Invalid rate data', 400);
  }
  
  // Normalize postal code regions to uppercase
  if (req.body.origin_region) {
    req.body.origin_region = req.body.origin_region.toUpperCase();
  }
  if (req.body.destination_region) {
    req.body.destination_region = req.body.destination_region.toUpperCase();
  }
  
  const newRate = await createRate(req.body);
  
  res.status(201).json({
    status: 'success',
    data: {
      rate: newRate,
    },
  });
};

// Update a rate
export const updateExistingRate = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  // Check if rate exists
  const existingRate = await getRateById(id);
  if (!existingRate) {
    throw new ApiError('Rate not found', 404);
  }
  
  // Don't allow changing the origin or destination regions, or effective date
  if (req.body.origin_region || req.body.destination_region || req.body.effective_date) {
    throw new ApiError('Cannot change origin_region, destination_region, or effective_date. Create a new rate instead.', 400);
  }
  
  const updatedRate = await updateRate(id, req.body);
  
  res.status(200).json({
    status: 'success',
    data: {
      rate: updatedRate,
    },
  });
};

// Delete a rate
export const deleteExistingRate = async (req: Request, res: Response) => {
  const { id } = req.params;
  
  // Check if rate exists
  const existingRate = await getRateById(id);
  if (!existingRate) {
    throw new ApiError('Rate not found', 404);
  }
  
  await deleteRate(id);
  
  res.status(204).json({
    status: 'success',
    data: null,
  });
};

// Get applicable rate
export const getApplicableRate = async (req: Request, res: Response) => {
  const { origin, destination } = req.query;
  
  if (!origin || !destination) {
    throw new ApiError('Both origin and destination postal codes are required', 400);
  }
  
  // Validate postal code format
  const postalCodeRegex = /^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$/;
  if (!postalCodeRegex.test(origin as string) || !postalCodeRegex.test(destination as string)) {
    throw new ApiError('Invalid postal code format. Use Canadian postal code format (e.g., A1A 1A1)', 400);
  }
  
  // Use specified date or current date
  const dateStr = req.query.date as string;
  let date: Date;
  
  if (dateStr) {
    date = new Date(dateStr);
    if (isNaN(date.getTime())) {
      throw new ApiError('Invalid date format', 400);
    }
  } else {
    date = new Date();
  }
  
  const rate = await findApplicableRate(origin as string, destination as string, date);
  
  if (!rate) {
    throw new ApiError('No applicable rate found for the given origin, destination, and date', 404);
  }
  
  res.status(200).json({
    status: 'success',
    data: {
      rate,
    },
  });
};

// Calculate shipping cost
export const calculateCost = async (req: Request, res: Response) => {
  const { origin, destination, weight, distance } = req.body;
  
  if (!origin || !destination || !weight || !distance) {
    throw new ApiError('Origin, destination, weight, and distance are required', 400);
  }
  
  // Validate postal code format
  const postalCodeRegex = /^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$/;
  if (!postalCodeRegex.test(origin) || !postalCodeRegex.test(destination)) {
    throw new ApiError('Invalid postal code format. Use Canadian postal code format (e.g., A1A 1A1)', 400);
  }
  
  // Validate weight and distance
  if (isNaN(parseFloat(weight)) || parseFloat(weight) <= 0) {
    throw new ApiError('Weight must be a positive number', 400);
  }
  
  if (isNaN(parseFloat(distance)) || parseFloat(distance) <= 0) {
    throw new ApiError('Distance must be a positive number', 400);
  }
  
  // Use specified date or current date
  const dateStr = req.body.date;
  let date: Date;
  
  if (dateStr) {
    date = new Date(dateStr);
    if (isNaN(date.getTime())) {
      throw new ApiError('Invalid date format', 400);
    }
  } else {
    date = new Date();
  }
  
  const { cost, rate } = await calculateShippingCost(
    origin, 
    destination, 
    parseFloat(weight), 
    parseFloat(distance), 
    date
  );
  
  if (!rate) {
    throw new ApiError('No applicable rate found for the given origin, destination, and date', 404);
  }
  
  res.status(200).json({
    status: 'success',
    data: {
      cost,
      rate,
      details: {
        base_rate: rate.base_rate,
        distance_cost: rate.rate_per_mile * parseFloat(distance),
        weight_cost: rate.rate_per_pound * parseFloat(weight),
        origin,
        destination,
        weight: parseFloat(weight),
        distance: parseFloat(distance),
      }
    },
  });
};