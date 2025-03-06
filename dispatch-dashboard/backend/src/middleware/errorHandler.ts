// src/middleware/errorHandler.ts
import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

interface AppError extends Error {
  statusCode?: number;
  code?: string;
}

export const errorHandler = (
  err: AppError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const statusCode = err.statusCode || 500;
  
  // Log the error
  logger.error({
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    statusCode,
    requestId: req.headers['x-request-id'],
  });

  // Custom error handling for database errors
  if (err.code === '23505') { // Unique violation in PostgreSQL
    return res.status(409).json({
      status: 'error',
      message: 'A record with this information already exists.',
    });
  }
  
  if (err.code === '23503') { // Foreign key violation
    return res.status(400).json({
      status: 'error',
      message: 'Invalid reference to a related record.',
    });
  }

  // Default error response
  res.status(statusCode).json({
    status: 'error',
    message: statusCode === 500 
      ? 'An unexpected error occurred' 
      : err.message,
    ...(process.env.NODE_ENV === 'development' && { 
      stack: err.stack 
    }),
  });
};

// Custom error class for API errors
export class ApiError extends Error {
  statusCode: number;
  
  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.name = 'ApiError';
  }
}
