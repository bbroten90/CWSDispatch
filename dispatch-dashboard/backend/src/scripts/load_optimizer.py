# load_optimizer.py
# Load optimization using Google OR-Tools for dispatch dashboard

import os
import json
import time
import logging
from datetime import datetime, timedelta
import psycopg2
from psycopg2.extras import RealDictCursor
from ortools.constraint_solver import routing_enums_pb2
from ortools.constraint_solver import pywrapcp

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Database connection
def get_db_connection():
    """Create a connection to the PostgreSQL database."""
    conn = psycopg2.connect(
        host=os.environ.get('DB_HOST'),
        database=os.environ.get('DB_NAME'),
        user=os.environ.get('DB_USER'),
        password=os.environ.get('DB_PASSWORD')
    )
    return conn

def log_optimization(optimization_type, input_params, output_result, execution_time, success, error_msg=None):
    """Log optimization results to the database."""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute(
            """
            INSERT INTO optimization_logs 
            (optimization_type, input_parameters, output_result, execution_time_ms, success, error_message, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (
                optimization_type,
                json.dumps(input_params),
                json.dumps(output_result) if output_result else None,
                execution_time,
                success,
                error_msg,
                datetime.now()
            )
        )
        conn.commit()
    except Exception as e:
        logger.error(f"Error logging optimization: {e}")
        conn.rollback()
    finally:
        cursor.close()
        conn.close()

def get_unassigned_orders(cutoff_date=None):
    """Get all unassigned orders up to a cutoff date."""
    if cutoff_date is None:
        # Default to today at 3:00 PM
        cutoff_date = datetime.now().replace(hour=15, minute=0, second=0, microsecond=0)
    
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        cursor.execute(
            """
            SELECT 
                oh.order_id, 
                oh.document_id,
                oh.manufacturer_id,
                m.name as manufacturer_name,
                oh.order_date,
                oh.po_number,
                oh.requested_shipment_date,
                oh.requested_delivery_date,
                oh.customer_id,
                c.company_name as customer_name,
                c.city as customer_city,
                c.province as customer_province,
                c.latitude as customer_lat,
                c.longitude as customer_lng,
                oh.special_requirements,
                oh.total_quantity,
                oh.total_weight_kg,
                oh.estimated_revenue
            FROM 
                order_headers oh
            JOIN
                customers c ON oh.customer_id = c.customer_id
            JOIN
                manufacturers m ON oh.manufacturer_id = m.manufacturer_id
            WHERE 
                oh.status = 'RECEIVED'
                AND oh.requested_shipment_date <= %s
                AND NOT EXISTS (
                    SELECT 1 FROM shipment_orders so WHERE so.order_id = oh.order_id
                )
            ORDER BY
                oh.requested_delivery_date ASC,
                oh.estimated_revenue DESC
            """,
            (cutoff_date,)
        )
        
        orders = cursor.fetchall()
        
        # For each order, get its line items
        for order in orders:
            cursor.execute(
                """
                SELECT 
                    li.line_item_id,
                    li.product_id,
                    p.name as product_name,
                    li.quantity,
                    li.weight_kg,
                    p.volume_cubic_m * li.quantity as volume_cubic_m,
                    p.requires_refrigeration,
                    p.requires_heating,
                    p.is_dangerous_good,
                    p.tdg_number
                FROM 
                    order_line_items li
                JOIN
                    products p ON li.product_id = p.product_id
                WHERE 
                    li.order_id = %s
                """,
                (order['order_id'],)
            )
            order['line_items'] = cursor.fetchall()
        
        return orders
    finally:
        cursor.close()
        conn.close()

def get_available_vehicles(date):
    """Get available vehicles for a specific date."""
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        cursor.execute(
            """
            SELECT 
                v.vehicle_id,
                v.type,
                v.license_plate,
                v.max_weight_kg,
                v.volume_capacity_cubic_m,
                v.has_refrigeration,
                v.has_heating,
                v.has_tdg_capacity,
                v.home_warehouse_id,
                w.name as warehouse_name,
                w.city as warehouse_city,
                w.province as warehouse_province,
                w.latitude as warehouse_lat,
                w.longitude as warehouse_lng
            FROM 
                vehicles v
            JOIN
                warehouses w ON v.home_warehouse_id = w.warehouse_id
            LEFT JOIN
                vehicle_availability va ON v.vehicle_id = va.vehicle_id AND va.date = %s
            WHERE 
                v.is_active = true
                AND (va.is_available IS NULL OR va.is_available = true)
            ORDER BY
                v.type, v.max_weight_kg DESC
            """,
            (date,)
        )
        
        return cursor.fetchall()
    finally:
        cursor.close()
        conn.close()

def get_available_drivers(date):
    """Get available drivers for a specific date."""
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        cursor.execute(
            """
            SELECT 
                d.driver_id,
                d.first_name,
                d.last_name,
                d.home_warehouse_id,
                w.name as warehouse_name
            FROM 
                drivers d
            JOIN
                warehouses w ON d.home_warehouse_id = w.warehouse_id
            LEFT JOIN
                driver_availability da ON d.driver_id = da.driver_id AND da.date = %s
            WHERE 
                d.is_active = true
                AND (da.is_available IS NULL OR da.is_available = true)
            """,
            (date,)
        )
        
        return cursor.fetchall()
    finally:
        cursor.close()
        conn.close()

def optimize_loads(date=None, cutoff_time=15):
    """
    Optimize loads for the given date using Google OR-Tools.
    
    Args:
        date: The date to optimize loads for (defaults to today)
        cutoff_time: The cutoff hour (24-hour format, defaults to 15 for 3:00 PM)
    
    Returns:
        A list of optimized shipments, each containing orders, vehicle, and route information
    """
    start_time = time.time()
    
    if date is None:
        date = datetime.now().date()
    
    cutoff_datetime = datetime.combine(date, datetime.min.time().replace(hour=cutoff_time))
    
    try:
        # Get unassigned orders
        orders = get_unassigned_orders(cutoff_datetime)
        if not orders:
            logger.info(f"No unassigned orders found for {date}")
            return []
        
        # Get available vehicles
        vehicles = get_available_vehicles(date)
        if not vehicles:
            logger.warning(f"No available vehicles found for {date}")
            return []
        
        # Get available drivers
        drivers = get_available_drivers(date)
        if not drivers:
            logger.warning(f"No available drivers found for {date}")
            return []
        
        # Group vehicles by warehouse
        vehicles_by_warehouse = {}
        for vehicle in vehicles:
            warehouse_id = vehicle['home_warehouse_id']
            if warehouse_id not in vehicles_by_warehouse:
                vehicles_by_warehouse[warehouse_id] = []
            vehicles_by_warehouse[warehouse_id].append(vehicle)
        
        # Group orders by warehouse and special requirements
        orders_by_warehouse = {}
        for order in orders:
            # Determine warehouse based on manufacturer and shipping preferences
            # This logic would need to be customized based on your business rules
            # For now, we'll assume the order needs to be shipped from the first warehouse
            warehouse_id = list(vehicles_by_warehouse.keys())[0]
            
            if warehouse_id not in orders_by_warehouse:
                orders_by_warehouse[warehouse_id] = []
            
            # Add warehouse_id to the order for reference
            order['warehouse_id'] = warehouse_id
            orders_by_warehouse[warehouse_id].append(order)
        
        # Create optimized shipments for each warehouse
        optimized_shipments = []
        for warehouse_id, warehouse_orders in orders_by_warehouse.items():
            if not warehouse_orders:
                continue
                
            warehouse_vehicles = vehicles_by_warehouse.get(warehouse_id, [])
            if not warehouse_vehicles:
                logger.warning(f"No vehicles available for warehouse {warehouse_id}")
                continue
            
            # Filter drivers for this warehouse
            warehouse_drivers = [d for d in drivers if d['home_warehouse_id'] == warehouse_id]
            if not warehouse_drivers:
                logger.warning(f"No drivers available for warehouse {warehouse_id}")
                continue
            
            # Create distance matrix for this warehouse's orders
            distance_matrix = create_distance_matrix(warehouse_id, warehouse_orders)
            
            # Sort orders by priority (revenue per kg)
            warehouse_orders.sort(key=lambda x: x['estimated_revenue'] / x['total_weight_kg'] if x['total_weight_kg'] > 0 else 0, reverse=True)
            
            # First pass: bin packing to assign orders to vehicles based on weight and volume
            vehicle_assignments = bin_packing_assignment(warehouse_vehicles, warehouse_orders)
            
            # Second pass: For each vehicle with assigned orders, optimize the delivery route
            shipments = []
            for vehicle_id, assigned_orders in vehicle_assignments.items():
                if not assigned_orders:
                    continue
                    
                vehicle = next((v for v in warehouse_vehicles if v['vehicle_id'] == vehicle_id), None)
                if not vehicle:
                    continue
                
                # Optimize the route for this vehicle
                optimized_route = optimize_vehicle_route(vehicle, assigned_orders, distance_matrix)
                
                # Assign a driver
                assigned_driver = warehouse_drivers[0] if warehouse_drivers else None
                if assigned_driver:
                    warehouse_drivers.remove(assigned_driver)
                
                shipment = {
                    'vehicle': vehicle,
                    'driver': assigned_driver,
                    'orders': optimized_route['orders'],
                    'route': optimized_route['route'],
                    'total_distance': optimized_route['total_distance'],
                    'total_weight': sum(order['total_weight_kg'] for order in assigned_orders),
                    'total_revenue': sum(order['estimated_revenue'] for order in assigned_orders if order['estimated_revenue']),
                    'warehouse_id': warehouse_id
                }
                
                shipments.append(shipment)
            
            optimized_shipments.extend(shipments)
        
        execution_time = int((time.time() - start_time) * 1000)  # ms
        
        # Log the optimization results
        log_optimization(
            'LOADING_ROUTING',
            {
                'date': date.isoformat(),
                'cutoff_time': cutoff_time,
                'order_count': len(orders),
                'vehicle_count': len(vehicles)
            },
            {
                'shipment_count': len(optimized_shipments),
                'total_orders_assigned': sum(len(s['orders']) for s in optimized_shipments),
                'total_revenue': sum(s['total_revenue'] for s in optimized_shipments)
            },
            execution_time,
            True
        )
        
        return optimized_shipments
        
    except Exception as e:
        execution_time = int((time.time() - start_time) * 1000)  # ms
        logger.error(f"Error in optimize_loads: {e}")
        
        # Log the error
        log_optimization(
            'LOADING_ROUTING',
            {
                'date': date.isoformat(),
                'cutoff_time': cutoff_time
            },
            None,
            execution_time,
            False,
            str(e)
        )
        
        return []

def create_distance_matrix(warehouse_id, orders):
    """
    Create a distance matrix between warehouse and all delivery locations.
    
    In a real implementation, this would use the Google Maps Distance Matrix API.
    For simplicity, we're creating a mock matrix with Euclidean distances.
    """
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        # Get warehouse coordinates
        cursor.execute(
            "SELECT latitude, longitude FROM warehouses WHERE warehouse_id = %s",
            (warehouse_id,)
        )
        warehouse = cursor.fetchone()
        
        if not warehouse or warehouse['latitude'] is None:
            # Mock data if coordinates not available
            return mock_distance_matrix(len(orders) + 1)
        
        # Create list of all locations (warehouse + customer locations)
        locations = [(warehouse['latitude'], warehouse['longitude'])]
        
        for order in orders:
            if order.get('customer_lat') and order.get('customer_lng'):
                locations.append((order['customer_lat'], order['customer_lng']))
            else:
                # If no coordinates, add a placeholder
                locations.append((0, 0))
        
        # Calculate distances between all points (Euclidean distance for simplicity)
        # In production, use Google Maps Distance Matrix API
        distance_matrix = []
        for i, (lat1, lng1) in enumerate(locations):
            row = []
            for j, (lat2, lng2) in enumerate(locations):
                if i == j:
                    row.append(0)  # Distance to self is 0
                else:
                    # Simple Euclidean distance (not accurate for real-world routing)
                    # This would be replaced by actual road distances from Google Maps
                    dist = ((lat1 - lat2) ** 2 + (lng1 - lng2) ** 2) ** 0.5
                    # Convert to approximate kilometers (very rough estimate)
                    dist_km = dist * 111  # 1 degree is roughly 111 km
                    row.append(int(dist_km * 1000))  # Convert to meters for OR-Tools
            
            distance_matrix.append(row)
        
        return distance_matrix
    finally:
        cursor.close()
        conn.close()

def mock_distance_matrix(size):
    """Create a mock distance matrix for testing."""
    import random
    matrix = []
    for i in range(size):
        row = []
        for j in range(size):
            if i == j:
                row.append(0)
            else:
                # Random distance between 5 and 50 km (in meters)
                row.append(random.randint(5000, 50000))
        matrix.append(row)
    return matrix

def bin_packing_assignment(vehicles, orders):
    """
    Assign orders to vehicles using a bin packing algorithm.
    
    This is a simplified version that considers weight and special requirements.
    A more advanced version would use Google OR-Tools' constraint programming.
    """
    # Sort vehicles by capacity (largest first)
    sorted_vehicles = sorted(vehicles, key=lambda v: v['max_weight_kg'], reverse=True)
    
    # Sort orders by special requirements first, then by weight (largest first)
    def order_sort_key(order):
        special_req_score = 0
        if order.get('special_requirements'):
            if 'Heated' in order['special_requirements']:
                special_req_score += 10
            if 'Refrige' in order['special_requirements']:
                special_req_score += 20
            if 'TDG' in order['special_requirements']:
                special_req_score += 30
        return (special_req_score, order['total_weight_kg'])
    
    sorted_orders = sorted(orders, key=order_sort_key, reverse=True)
    
    vehicle_assignments = {v['vehicle_id']: [] for v in vehicles}
    vehicle_remaining_capacity = {v['vehicle_id']: v['max_weight_kg'] for v in vehicles}
    
    # Assign orders with special requirements first to appropriate vehicles
    for order in sorted_orders:
        special_reqs = order.get('special_requirements', '')
        needs_refrigeration = 'Refrige' in special_reqs
        needs_heating = 'Heated' in special_reqs
        needs_tdg = 'TDG' in special_reqs
        
        # Find suitable vehicle
        assigned = False
        for vehicle in sorted_vehicles:
            vehicle_id = vehicle['vehicle_id']
            
            # Check if vehicle can handle special requirements
            can_handle = True
            if needs_refrigeration and not vehicle.get('has_refrigeration'):
                can_handle = False
            if needs_heating and not vehicle.get('has_heating'):
                can_handle = False
            if needs_tdg and not vehicle.get('has_tdg_capacity'):
                can_handle = False
            
            # Check if vehicle has capacity
            if can_handle and vehicle_remaining_capacity[vehicle_id] >= order['total_weight_kg']:
                vehicle_assignments[vehicle_id].append(order)
                vehicle_remaining_capacity[vehicle_id] -= order['total_weight_kg']
                assigned = True
                break
        
        if not assigned:
            logger.warning(f"Could not assign order {order['order_id']} to any vehicle")
    
    return vehicle_assignments

def optimize_vehicle_route(vehicle, orders, distance_matrix):
    """
    Optimize delivery route for a vehicle using OR-Tools.
    
    Args:
        vehicle: Vehicle information
        orders: List of orders assigned to this vehicle
        distance_matrix: Matrix of distances between all points
        
    Returns:
        Dictionary with optimized route information
    """
    if not orders:
        return {'orders': [], 'route': [], 'total_distance': 0}
    
    # Create routing model
    manager = pywrapcp.RoutingIndexManager(len(distance_matrix), 1, 0)
    routing = pywrapcp.RoutingModel(manager)
    
    def distance_callback(from_index, to_index):
        from_node = manager.IndexToNode(from_index)
        to_node = manager.IndexToNode(to_index)
        return distance_matrix[from_node][to_node]
    
    transit_callback_index = routing.RegisterTransitCallback(distance_callback)
    routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)
    
    # Add distance dimension
    dimension_name = 'Distance'
    routing.AddDimension(
        transit_callback_index,
        0,  # no slack
        3000000,  # vehicle maximum travel distance in meters (3000 km)
        True,  # start cumul to zero
        dimension_name
    )
    distance_dimension = routing.GetDimensionOrDie(dimension_name)
    distance_dimension.SetGlobalSpanCostCoefficient(100)
    
    # Set search parameters
    search_parameters = pywrapcp.DefaultRoutingSearchParameters()
    search_parameters.first_solution_strategy = (
        routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC
    )
    search_parameters.time_limit.seconds = 5  # 5 second time limit
    
    # Solve the problem
    solution = routing.SolveWithParameters(search_parameters)
    
    if solution:
        # Extract the route
        route = []
        ordered_orders = []
        index = routing.Start(0)
        route_distance = 0
        
        while not routing.IsEnd(index):
            node_index = manager.IndexToNode(index)
            route.append(node_index)
            
            previous_index = index
            index = solution.Value(routing.NextVar(index))
            route_distance += routing.GetArcCostForVehicle(previous_index, index, 0)
            
            # Skip the depot (node 0)
            if node_index > 0:
                # Node indices in the route are 1-based relative to the orders list
                ordered_orders.append(orders[node_index - 1])
        
        # Add the final return to depot
        route.append(manager.IndexToNode(index))
        
        return {
            'orders': ordered_orders,
            'route': route,
            'total_distance': route_distance / 1000.0  # Convert to kilometers
        }
    else:
        logger.warning(f"No solution found for vehicle {vehicle['vehicle_id']}")
        return {
            'orders': orders,
            'route': list(range(len(orders) + 1)),  # Simple route: depot -> all orders in sequence -> depot
            'total_distance': 0
        }

def save_optimized_shipments(shipments, date):
    """Save optimized shipments to the database."""
    if not shipments:
        return
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        conn.autocommit = False
        
        for shipment in shipments:
            # Create shipment record
            cursor.execute(
                """
                INSERT INTO shipments
                (shipment_date, origin_warehouse_id, truck_id, trailer_id, driver_id, 
                 status, total_distance_km, total_weight_kg, total_revenue, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING shipment_id
                """,
                (
                    date,
                    shipment['warehouse_id'],
                    shipment['vehicle']['vehicle_id'] if shipment['vehicle']['type'] == 'TRUCK' else None,
                    shipment['vehicle']['vehicle_id'] if shipment['vehicle']['type'] == 'TRAILER' else None,
                    shipment['driver']['driver_id'] if shipment.get('driver') else None,
                    'PLANNED',
                    shipment['total_distance'],
                    shipment['total_weight'],
                    shipment['total_revenue'],
                    datetime.now(),
                    datetime.now()
                )
            )
            
            shipment_id = cursor.fetchone()[0]
            
            # Add shipment orders
            for i, order in enumerate(shipment['orders']):
                cursor.execute(
                    """
                    INSERT INTO shipment_orders
                    (shipment_id, order_id, stop_sequence, status, created_at, updated_at)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    (
                        shipment_id,
                        order['order_id'],
                        i + 1,  # 1-based stop sequence
                        'PLANNED',
                        datetime.now(),
                        datetime.now()
                    )
                )
                
                # Update order status to SCHEDULED
                cursor.execute(
                    """
                    UPDATE order_headers
                    SET status = 'SCHEDULED', updated_at = %s
                    WHERE order_id = %s
                    """,
                    (datetime.now(), order['order_id'])
                )
        
        conn.commit()
        logger.info(f"Saved {len(shipments)} shipments to database")
    except Exception as e:
        conn.rollback()
        logger.error(f"Error saving shipments: {e}")
        raise
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    # Run optimization for today
    today = datetime.now().date()
    
    logger.info(f"Starting load optimization for {today}")
    shipments = optimize_loads(today)
    
    if shipments:
        logger.info(f"Generated {len(shipments)} optimized shipments")
        save_optimized_shipments(shipments, today)
    else:
        logger.info("No shipments generated")
