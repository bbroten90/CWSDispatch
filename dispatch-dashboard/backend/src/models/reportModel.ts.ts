// src/models/reportModel.ts
import { query } from '../config/database';

// Delivery performance report
export const getDeliveryPerformance = async (
  startDate: Date,
  endDate: Date,
  customerId?: string
) => {
  let queryText = `
    SELECT 
      COUNT(*) as total_deliveries,
      SUM(CASE WHEN s.status = 'completed' THEN 1 ELSE 0 END) as completed_deliveries,
      SUM(CASE WHEN s.actual_arrival <= s.planned_arrival THEN 1 ELSE 0 END) as on_time_deliveries,
      ROUND(
        SUM(CASE WHEN s.actual_arrival <= s.planned_arrival THEN 1 ELSE 0 END)::numeric / 
        NULLIF(COUNT(*)::numeric, 0) * 100, 
        2
      ) as on_time_percentage,
      ROUND(
        AVG(
          EXTRACT(EPOCH FROM (s.actual_arrival - s.actual_departure))/3600
        )::numeric,
        2
      ) as avg_delivery_time_hours
    FROM shipments s
    JOIN orders o ON s.order_id = o.id
    WHERE 
      s.status = 'completed' 
      AND s.actual_departure >= $1 
      AND s.actual_arrival <= $2
  `;
  
  const queryParams: any[] = [startDate, endDate];
  
  if (customerId) {
    queryText += ` AND o.customer_id = $3`;
    queryParams.push(customerId);
  }
  
  const result = await query(queryText, queryParams);
  return result.rows[0];
};

// Vehicle utilization report
export const getVehicleUtilization = async (
  startDate: Date,
  endDate: Date,
  vehicleId?: string
) => {
  let queryText = `
    SELECT 
      v.id as vehicle_id,
      v.vehicle_number,
      COUNT(s.id) as total_shipments,
      SUM(EXTRACT(EPOCH FROM (s.actual_arrival - s.actual_departure))/3600) as total_hours_in_transit,
      ROUND(AVG(o.total_weight / v.capacity_weight * 100), 2) as avg_weight_utilization,
      ROUND(AVG(o.total_volume / v.capacity_volume * 100), 2) as avg_volume_utilization,
      SUM(o.total_weight) as total_weight_delivered,
      SUM(o.total_volume) as total_volume_delivered
    FROM vehicles v
    LEFT JOIN shipments s ON v.id = s.vehicle_id AND s.status = 'completed' 
      AND s.actual_departure >= $1 AND s.actual_arrival <= $2
    LEFT JOIN orders o ON s.order_id = o.id
  `;
  
  const queryParams: any[] = [startDate, endDate];
  
  if (vehicleId) {
    queryText += ` WHERE v.id = $3`;
    queryParams.push(vehicleId);
  }
  
  queryText += `
    GROUP BY v.id, v.vehicle_number
    ORDER BY total_shipments DESC
  `;
  
  const result = await query(queryText, queryParams);
  return result.rows;
};

// Driver performance report
export const getDriverPerformance = async (
  startDate: Date,
  endDate: Date,
  driverId?: string
) => {
  let queryText = `
    SELECT 
      d.id as driver_id,
      d.first_name,
      d.last_name,
      COUNT(s.id) as total_shipments,
      SUM(CASE WHEN s.actual_arrival <= s.planned_arrival THEN 1 ELSE 0 END) as on_time_deliveries,
      ROUND(
        SUM(CASE WHEN s.actual_arrival <= s.planned_arrival THEN 1 ELSE 0 END)::numeric / 
        NULLIF(COUNT(s.id)::numeric, 0) * 100, 
        2
      ) as on_time_percentage,
      ROUND(AVG(EXTRACT(EPOCH FROM (s.actual_arrival - s.actual_departure))/3600), 2) as avg_delivery_time_hours,
      COUNT(DISTINCT o.customer_id) as unique_customers_served
    FROM drivers d
    LEFT JOIN shipments s ON d.id = s.driver_id AND s.status = 'completed' 
      AND s.actual_departure >= $1 AND s.actual_arrival <= $2
    LEFT JOIN orders o ON s.order_id = o.id
  `;
  
  const queryParams: any[] = [startDate, endDate];
  
  if (driverId) {
    queryText += ` WHERE d.id = $3`;
    queryParams.push(driverId);
  }
  
  queryText += `
    GROUP BY d.id, d.first_name, d.last_name
    ORDER BY total_shipments DESC
  `;
  
  const result = await query(queryText, queryParams);
  return result.rows;
};

// Revenue report by region
export const getRevenueByRegion = async (
  startDate: Date,
  endDate: Date
) => {
  const queryText = `
    SELECT 
      SUBSTRING(o.delivery_postal_code, 1, 3) as region,
      COUNT(o.id) as total_orders,
      SUM(r.base_rate + (r.rate_per_mile * COALESCE(s.distance_miles, 0)) + (r.rate_per_pound * o.total_weight)) as total_revenue,
      ROUND(
        AVG(r.base_rate + (r.rate_per_mile * COALESCE(s.distance_miles, 0)) + (r.rate_per_pound * o.total_weight)),
        2
      ) as avg_order_value
    FROM orders o
    JOIN shipments s ON o.id = s.order_id
    JOIN rates r ON SUBSTRING(o.pickup_postal_code, 1, 3) = r.origin_region 
                  AND SUBSTRING(o.delivery_postal_code, 1, 3) = r.destination_region
    WHERE 
      s.status = 'completed' 
      AND s.actual_departure >= $1 
      AND s.actual_arrival <= $2
      AND r.effective_date <= s.actual_departure
      AND (r.expiration_date IS NULL OR r.expiration_date >= s.actual_departure)
    GROUP BY SUBSTRING(o.delivery_postal_code, 1, 3)
    ORDER BY total_revenue DESC
  `;
  
  const result = await query(queryText, [startDate, endDate]);
  return result.rows;
};

// Monthly trend report
export const getMonthlyTrends = async (
  startDate: Date,
  endDate: Date
) => {
  const queryText = `
    SELECT 
      TO_CHAR(DATE_TRUNC('month', s.actual_departure), 'YYYY-MM') as month,
      COUNT(o.id) as total_orders,
      SUM(o.total_weight) as total_weight,
      SUM(o.total_volume) as total_volume,
      ROUND(
        SUM(CASE WHEN s.actual_arrival <= s.planned_arrival THEN 1 ELSE 0 END)::numeric / 
        NULLIF(COUNT(*)::numeric, 0) * 100, 
        2
      ) as on_time_percentage,
      ROUND(
        AVG(EXTRACT(EPOCH FROM (s.actual_arrival - s.actual_departure))/3600),
        2
      ) as avg_delivery_time_hours,
      SUM(r.base_rate + (r.rate_per_mile * COALESCE(s.distance_miles, 0)) + (r.rate_per_pound * o.total_weight)) as total_revenue
    FROM orders o
    JOIN shipments s ON o.id = s.order_id
    JOIN rates r ON SUBSTRING(o.pickup_postal_code, 1, 3) = r.origin_region 
                  AND SUBSTRING(o.delivery_postal_code, 1, 3) = r.destination_region
    WHERE 
      s.status = 'completed' 
      AND s.actual_departure >= $1 
      AND s.actual_arrival <= $2
      AND r.effective_date <= s.actual_departure
      AND (r.expiration_date IS NULL OR r.expiration_date >= s.actual_departure)
    GROUP BY DATE_TRUNC('month', s.actual_departure)
    ORDER BY month
  `;
  
  const result = await query(queryText, [startDate, endDate]);
  return result.rows;
};
  