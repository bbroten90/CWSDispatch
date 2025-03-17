// src/routes/reportRoutes.ts
import { Router, Request, Response, NextFunction } from 'express';
import {
  dashboardSummary,
  revenueByCustomerReport,
  shipmentEfficiencyReport,
  monthlyTrendsReport
} from '../controllers/reportController';

const router = Router();

// Wrapper function to handle async controller functions with proper typing
const asyncHandler = (
  fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
) => (req: Request, res: Response, next: NextFunction): void => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Dashboard summary endpoint
router.get('/dashboard-summary', asyncHandler(dashboardSummary));

// Monthly trends report endpoint
router.get('/monthly-trends', asyncHandler(monthlyTrendsReport));

// Revenue by customer report endpoint
router.get('/revenue-by-customer', asyncHandler(revenueByCustomerReport));

// Shipment efficiency report endpoint
router.get('/shipment-efficiency', asyncHandler(shipmentEfficiencyReport));

export default router;
