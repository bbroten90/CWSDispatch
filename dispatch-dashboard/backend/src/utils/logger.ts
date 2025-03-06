// src/utils/logger.ts
import winston from 'winston';

// Define logger configuration
const logConfiguration = {
  transports: [
    new winston.transports.Console({
      level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.timestamp(),
        winston.format.printf(({ timestamp, level, message, ...meta }) => {
          return `[${timestamp}] ${level}: ${message} ${
            Object.keys(meta).length ? JSON.stringify(meta, null, 2) : ''
          }`;
        })
      ),
    }),
    // Add file transport for production
    ...(process.env.NODE_ENV === 'production'
      ? [
          new winston.transports.File({
            filename: 'logs/error.log',
            level: 'error',
            format: winston.format.combine(
              winston.format.timestamp(),
              winston.format.json()
            ),
            maxsize: 5242880, // 5MB
            maxFiles: 5,
          }),
          new winston.transports.File({
            filename: 'logs/combined.log',
            format: winston.format.combine(
              winston.format.timestamp(),
              winston.format.json()
            ),
            maxsize: 5242880, // 5MB
            maxFiles: 5,
          }),
        ]
      : []),
  ],
};

// Create the logger
export const logger = winston.createLogger(logConfiguration);

// Setup function to ensure log directory exists in production
export const setupLogger = () => {
  if (process.env.NODE_ENV === 'production') {
    const fs = require('fs');
    const path = require('path');
    const logDir = 'logs';
    
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir);
    }
  }
  
  // Log that the logger has been initialized
  logger.info('Logger initialized');
};
