// src/pages/DispatchDashboard.tsx
import React, { useState, useEffect } from 'react';
import { format } from 'date-fns';
import axios from 'axios';
import { 
  Card, CardContent, CardHeader, CardTitle,
  Tabs, TabsContent, TabsList, TabsTrigger,
  Button,
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui';
import { 
  MapPin, Truck, Package, DollarSign, 
  Calendar, RefreshCw, Filter, MoreVertical,
  ChevronRight, AlertTriangle
} from 'lucide-react';

// Types for our data models
interface Order {
  orderId: number;
  documentId: string;
  manufacturerName: string;
  poNumber: string;
  orderDate: string;
  requestedShipmentDate: string;
  requestedDeliveryDate: string;
  customerName: string;
  city: string;
  province: string;
  totalWeight: number;
  specialRequirements?: string;
  status: string;
  estimatedRevenue: number;
}

interface Vehicle {
  vehicleId: number;
  type: 'TRUCK' | 'TRAILER';
  licensePlate: string;
  maxWeightKg: number;
  hasRefrigeration: boolean;
  hasHeating: boolean;
  hasTdgCapacity: boolean;
}

interface Shipment {
  shipmentId: number;
  shipmentDate: string;
  warehouseName: string;
  truckId?: number;
  trailerId?: number;
  driverName?: string;
  status: string;
  totalOrders: number;
  totalWeightKg: number;
  totalRevenue: number;
  estimatedStartTime?: string;
  estimatedCompletionTime?: string;
}

// Component for the Dispatch Dashboard
const DispatchDashboard: React.FC = () => {
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [orders, setOrders] = useState<Order[]>([]);
  const [shipments, setShipments] = useState<Shipment[]>([]);
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [optimizing, setOptimizing] = useState<boolean>(false);
  
  useEffect(() => {
    // Load data when the component mounts or the selected date changes
    loadDashboardData();
  }, [selectedDate]);
  
  const loadDashboardData = async () => {
    setLoading(true);
    try {
      const formattedDate = format(selectedDate, 'yyyy-MM-dd');
      
      // Fetch data from our API endpoints
      const [ordersRes, shipmentsRes, vehiclesRes] = await Promise.all([
        axios.get(`/api/orders?date=${formattedDate}`),
        axios.get(`/api/shipments?date=${formattedDate}`),
        axios.get(`/api/vehicles/available?date=${formattedDate}`)
      ]);
      
      setOrders(ordersRes.data);
      setShipments(shipmentsRes.data);
      setVehicles(vehiclesRes.data);
    } catch (error) {
      console.error('Error loading dashboard data:', error);
      // Handle error state here
    } finally {
      setLoading(false);
    }
  };
  
  const handleDateChange = (date: Date) => {
    setSelectedDate(date);
  };
  
  const handleOptimizeClick = async () => {
    setOptimizing(true);
    try {
      const formattedDate = format(selectedDate, 'yyyy-MM-dd');
      await axios.post(`/api/optimize?date=${formattedDate}`);
      // Reload data after optimization
      await loadDashboardData();
    } catch (error) {
      console.error('Error optimizing loads:', error);
      // Handle error state here
    } finally {
      setOptimizing(false);
    }
  };
  
  // Helper function to format currency
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-CA', {
      style: 'currency',
      currency: 'CAD'
    }).format(amount);
  };
  
  // Helper function to get status color
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'RECEIVED':
        return 'bg-blue-100 text-blue-800';
      case 'SCHEDULED':
        return 'bg-purple-100 text-purple-800';
      case 'LOADED':
        return 'bg-orange-100 text-orange-800';
      case 'IN_TRANSIT':
        return 'bg-amber-100 text-amber-800';
      case 'DELIVERED':
        return 'bg-green-100 text-green-800';
      case 'CANCELLED':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };
  
  return (
    <div className="container mx-auto p-4">
      <header className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Dispatch Dashboard</h1>
          <p className="text-gray-500">
            {format(selectedDate, 'EEEE, MMMM d, yyyy')}
          </p>
        </div>
        
        <div className="flex items-center space-x-4">
          <div className="flex items-center space-x-2">
            <input
              type="date"
              value={format(selectedDate, 'yyyy-MM-dd')}
              onChange={(e) => handleDateChange(new Date(e.target.value))}
              className="border rounded p-2"
            />
            <Button variant="outline" size="sm" onClick={loadDashboardData}>
              <RefreshCw className="h-4 w-4 mr-2" />
              Refresh
            </Button>
          </div>
          
          <Button 
            onClick={handleOptimizeClick} 
            disabled={optimizing}
            className="bg-primary"
          >
            {optimizing ? 'Optimizing...' : 'Optimize Loads'}
          </Button>
        </div>
      </header>
      
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Pending Orders</p>
                <h2 className="text-3xl font-bold">{orders.filter(o => o.status === 'RECEIVED').length}</h2>
              </div>
              <Package className="h-8 w-8 text-primary" />
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Scheduled Shipments</p>
                <h2 className="text-3xl font-bold">{shipments.length}</h2>
              </div>
              <Truck className="h-8 w-8 text-primary" />
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Available Vehicles</p>
                <h2 className="text-3xl font-bold">{vehicles.length}</h2>
              </div>
              <MapPin className="h-8 w-8 text-primary" />
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Total Revenue</p>
                <h2 className="text-3xl font-bold">
                  {formatCurrency(shipments.reduce((sum, s) => sum + s.totalRevenue, 0))}
                </h2>
              </div>
              <DollarSign className="h-8 w-8 text-primary" />
            </div>
          </CardContent>
        </Card>
      </div>
      
      {/* Main Content Tabs */}
      <Tabs defaultValue="shipments" className="w-full">
        <TabsList className="mb-4">
          <TabsTrigger value="shipments">Shipments</TabsTrigger>
          <TabsTrigger value="orders">Orders</TabsTrigger>
          <TabsTrigger value="vehicles">Vehicles</TabsTrigger>
        </TabsList>
        
        {/* Shipments Tab */}
        <TabsContent value="shipments">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle>Scheduled Shipments</CardTitle>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="flex justify-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
                </div>
              ) : shipments.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  <Truck className="mx-auto h-12 w-12 mb-4 text-gray-400" />
                  <p>No shipments scheduled for this date.</p>
                  <Button variant="outline" className="mt-4" onClick={handleOptimizeClick}>
                    Optimize Loads Now
                  </Button>
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>PO Number</TableHead>
                      <TableHead>Manufacturer</TableHead>
                      <TableHead>Customer</TableHead>
                      <TableHead>Location</TableHead>
                      <TableHead>Delivery Date</TableHead>
                      <TableHead>Weight (kg)</TableHead>
                      <TableHead>Revenue</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Special Reqs</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {orders.map((order) => (
                      <TableRow key={order.orderId}>
                        <TableCell className="font-medium">{order.poNumber}</TableCell>
                        <TableCell>{order.manufacturerName}</TableCell>
                        <TableCell>{order.customerName}</TableCell>
                        <TableCell>{order.city}, {order.province}</TableCell>
                        <TableCell>{format(new Date(order.requestedDeliveryDate), 'MMM d')}</TableCell>
                        <TableCell>{order.totalWeight.toLocaleString()}</TableCell>
                        <TableCell>{formatCurrency(order.estimatedRevenue)}</TableCell>
                        <TableCell>
                          <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(order.status)}`}>
                            {order.status}
                          </span>
                        </TableCell>
                        <TableCell>
                          {order.specialRequirements && (
                            <span className="flex items-center">
                              <AlertTriangle className="h-4 w-4 text-amber-500 mr-1" />
                              {order.specialRequirements}
                            </span>
                          )}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>ID</TableHead>
                      <TableHead>Origin</TableHead>
                      <TableHead>Vehicle</TableHead>
                      <TableHead>Driver</TableHead>
                      <TableHead>Orders</TableHead>
                      <TableHead>Weight (kg)</TableHead>
                      <TableHead>Revenue</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {shipments.map((shipment) => (
                      <TableRow key={shipment.shipmentId}>
                        <TableCell className="font-medium">CWS-{String(shipment.shipmentId).padStart(8, '0')}</TableCell>
                        <TableCell>{shipment.warehouseName}</TableCell>
                        <TableCell>{shipment.truckId ? `Truck ${shipment.truckId}` : 'N/A'}</TableCell>
                        <TableCell>{shipment.driverName || 'Not assigned'}</TableCell>
                        <TableCell>{shipment.totalOrders}</TableCell>
                        <TableCell>{shipment.totalWeightKg.toLocaleString()}</TableCell>
                        <TableCell>{formatCurrency(shipment.totalRevenue)}</TableCell>
                        <TableCell>
                          <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(shipment.status)}`}>
                            {shipment.status}
                          </span>
                        </TableCell>
                        <TableCell>
                          <Button variant="ghost" size="sm">
                            <ChevronRight className="h-4 w-4" />
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>
        
        {/* Vehicles Tab */}
        <TabsContent value="vehicles">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle>Available Vehicles</CardTitle>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="flex justify-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
                </div>
              ) : vehicles.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  <Truck className="mx-auto h-12 w-12 mb-4 text-gray-400" />
                  <p>No available vehicles found for this date.</p>
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>ID</TableHead>
                      <TableHead>Type</TableHead>
                      <TableHead>License Plate</TableHead>
                      <TableHead>Capacity (kg)</TableHead>
                      <TableHead>Features</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {vehicles.map((vehicle) => (
                      <TableRow key={vehicle.vehicleId}>
                        <TableCell className="font-medium">{vehicle.vehicleId}</TableCell>
                        <TableCell>{vehicle.type}</TableCell>
                        <TableCell>{vehicle.licensePlate}</TableCell>
                        <TableCell>{vehicle.maxWeightKg.toLocaleString()}</TableCell>
                        <TableCell>
                          <div className="flex space-x-1">
                            {vehicle.hasRefrigeration && (
                              <span className="px-2 py-1 rounded-full text-xs bg-blue-100 text-blue-800">
                                Refrigerated
                              </span>
                            )}
                            {vehicle.hasHeating && (
                              <span className="px-2 py-1 rounded-full text-xs bg-orange-100 text-orange-800">
                                Heated
                              </span>
                            )}
                            {vehicle.hasTdgCapacity && (
                              <span className="px-2 py-1 rounded-full text-xs bg-red-100 text-red-800">
                                TDG
                              </span>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>
                          <span className="px-2 py-1 rounded-full text-xs bg-green-100 text-green-800">
                            Available
                          </span>
                        </TableCell>
                        <TableCell>
                          <Button variant="ghost" size="sm">
                            <MoreVertical className="h-4 w-4" />
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>
        
        {/* Orders Tab */}
        <TabsContent value="orders">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle>Orders</CardTitle>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="flex justify-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
                </div>
              ) : orders.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  <Package className="mx-auto h-12 w-12 mb-4 text-gray-400" />
                  <p>No orders found for this date.</p>
                </div>
              ) : (
                <Table>