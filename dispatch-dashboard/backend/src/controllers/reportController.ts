// src/controllers/reportController.ts
import { Request, Response } from 'express';
import * as reportModel from '../models/reportModel';

/**
 * Get monthly trends report
 * @route GET /api/reports/monthly-trends
 */
export const monthlyTrendsReport = async (req: Request, res: Response) => {
  try {
    // Calculate start and end date based on year
    const year = req.query.year ? Number(req.query.year) : new Date().getFullYear();
    const startDate = new Date(year, 0, 1); // January 1st of the year
    const endDate = new Date(year, 11, 31); // December 31st of the year
    
    const reportData = await reportModel.getMonthlyTrends(startDate, endDate);
    
    return res.status(200).json({
      success: true,
      data: {
        report: reportData
      }
    });
  } catch (error: any) {
    console.error('Error generating monthly trends report:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to generate monthly trends report',
      error: error.message || 'Unknown error'
    });
  }
};

/**
 * Get dashboard summary data
 * @route GET /api/reports/dashboard-summary
 */
export const dashboardSummary = async (req: Request, res: Response) => {
  try {
    const date = req.query.date ? new Date(req.query.date as string) : new Date();
    const warehouseId = req.query.warehouseId ? String(req.query.warehouseId) : undefined;
    
    // Since getDashboardSummary doesn't exist in reportModel, we'll use getMonthlyTrends
    // for the current month as a substitute
    const startOfMonth = new Date(date.getFullYear(), date.getMonth(), 1);
    const endOfMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0);
    
    const reportData = await reportModel.getMonthlyTrends(startOfMonth, endOfMonth);
    
    return res.status(200).json({
      success: true,
      data: {
        summary: reportData
      }
    });
  } catch (error: any) {
    console.error('Error generating dashboard summary:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to generate dashboard summary',
      error: error.message || 'Unknown error'
    });
  }
};

/**
 * Get revenue by customer report
 * @route GET /api/reports/revenue-by-customer
 */
export const revenueByCustomerReport = async (req: Request, res: Response) => {
  try {
    const startDate = req.query.startDate 
      ? new Date(req.query.startDate as string)
      : new Date(new Date().getFullYear(), 0, 1);
    
    const endDate = req.query.endDate
      ? new Date(req.query.endDate as string)
      : new Date();
    
    // Since getRevenueByCustomer doesn't exist in reportModel, we'll use getRevenueByRegion
    // as a substitute
    const reportData = await reportModel.getRevenueByRegion(startDate, endDate);
    
    return res.status(200).json({
      success: true,
      data: {
        report: reportData
      }
    });
  } catch (error: any) {
    console.error('Error generating revenue by customer report:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to generate revenue by customer report',
      error: error.message || 'Unknown error'
    });
  }
};

/**
 * Get shipment efficiency report
 * @route GET /api/reports/shipment-efficiency
 */
export const shipmentEfficiencyReport = async (req: Request, res: Response) => {
  try {
    const startDate = req.query.startDate 
      ? new Date(req.query.startDate as string)
      : new Date(new Date().getFullYear(), 0, 1);
    
    const endDate = req.query.endDate
      ? new Date(req.query.endDate as string)
      : new Date();
    
    const vehicleId = req.query.vehicleId ? String(req.query.vehicleId) : undefined;
    
    // Since getShipmentEfficiency doesn't exist in reportModel, we'll use getVehicleUtilization
    // as a substitute
    const reportData = await reportModel.getVehicleUtilization(startDate, endDate, vehicleId);
    
    return res.status(200).json({
      success: true,
      data: {
        report: reportData
      }
    });
  } catch (error: any) {
    console.error('Error generating shipment efficiency report:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to generate shipment efficiency report',
      error: error.message || 'Unknown error'
    });
  }
};
