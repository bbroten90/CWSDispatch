// src/app.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import 'express-async-errors';
import dotenv from 'dotenv';
import { errorHandler } from './middleware/errorHandler';
// Import the TypeScript version of the routes index file
import apiRoutes from './routes/index';

dotenv.config();

const app = express();

// Configure server to handle large headers and payloads
const serverConfig = {
  // Increase JSON payload size limit
  jsonLimit: '50mb',
  // Increase URL-encoded payload size limit
  urlEncodedLimit: '50mb',
  // Configure CORS with appropriate settings
  corsOptions: {
    // Allow all origins in development
    origin: true,
    // Allow credentials
    credentials: true,
    // Increase max age for preflight requests
    maxAge: 86400,
    // Allow specific headers
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'X-Requested-With',
      'Accept',
      'Origin',
      'x-internal-request'
    ],
    // Limit header size
    exposedHeaders: ['Content-Length', 'X-Content-Type-Options']
  }
};

// Middleware
app.use(helmet({
  // Disable content security policy in development
  contentSecurityPolicy: false
})); 

// Apply CORS with custom configuration
app.use(cors(serverConfig.corsOptions));

// Configure JSON parser with increased limits
app.use(express.json({ 
  limit: serverConfig.jsonLimit,
  // More permissive parsing
  strict: false
}));

// Configure URL-encoded parser with increased limits
app.use(express.urlencoded({ 
  extended: true, 
  limit: serverConfig.urlEncodedLimit,
  // Increase parameter limit
  parameterLimit: 5000
}));

// Custom middleware to handle large headers and clean up cookies
app.use((req, res, next) => {
  // Set response headers for better connection handling
  res.setHeader('Connection', 'keep-alive');
  res.setHeader('Keep-Alive', 'timeout=120');
  
  // Clean up cookies to reduce header size
  if (req.headers && req.headers.cookie) {
    try {
      // Split cookies and filter out analytics and tracking cookies
      const cookies = req.headers.cookie.split(';');
      const essentialCookies = cookies.filter(cookie => {
        const trimmedCookie = cookie.trim();
        // Filter out common analytics and tracking cookies
        return !trimmedCookie.startsWith('_ga') && 
               !trimmedCookie.startsWith('_gid') && 
               !trimmedCookie.startsWith('_gat') &&
               !trimmedCookie.startsWith('__utm');
      });
      
      // Replace cookie header with filtered cookies
      if (essentialCookies.length < cookies.length) {
        req.headers.cookie = essentialCookies.join(';');
      }
    } catch (error) {
      console.error('Error processing cookies:', error);
      // Continue even if cookie processing fails
    }
  }
  
  // Set custom header size limits
  res.setHeader('X-Content-Type-Options', 'nosniff');
  
  next();
});

// API Routes
app.use('/api', apiRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Error handling middleware
// @ts-ignore - Ignore type error for error handler middleware
app.use(errorHandler);

export default app;
