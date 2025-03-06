// src/routes/reportRoutes.ts
import { Router } from 'express';
import { 
  deliveryPerformanceReport,
  vehicleUtilizationReport,
  driverPerformanceReport,
  revenueByRegionReport,
  monthlyTrendsReport,
  dashboardSummary
} from '../controllers/reportController';

const router = Router();

// Dashboard summary - multiple reports for dashboard
router.get('/dashboard', dashboardSummary);

// Individual reports
router.get('/delivery-performance', deliveryPerformanceReport);
router.get('/vehicle-utilization', vehicleUtilizationReport);
router.get('/driver-performance', driverPerformanceReport);
router.get('/revenue-by-region', revenueByRegionReport);
router.get('/monthly-trends', monthlyTrendsReport);

export default router;
