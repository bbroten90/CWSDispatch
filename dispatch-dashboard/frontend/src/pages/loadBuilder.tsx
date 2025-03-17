// src/pages/LoadBuilder.tsx
import React, { useState, useEffect } from 'react';
import { format } from 'date-fns';
import axios from 'axios';
import { 
  Card, CardContent, CardHeader, CardTitle,
  Button, Input, Label,
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
  Alert, AlertTitle, AlertDescription
} from '../components/ui';
import { Truck, Package, ChevronRight, Plus, Save, RefreshCw } from 'lucide-react';

const LoadBuilder = () => {
  // Define interfaces for our data types
  interface Warehouse {
    warehouse_id: string;
    name: string;
  }

  interface Vehicle {
    id: string;
    vehicle_number: string;
    make: string;
    model: string;
    capacity_weight: number;
    capacity_pallets: number;
  }

  interface Order {
    id: string;
    order_number: string;
    delivery_city: string;
    delivery_province: string;
    total_weight: number;
    pallets: number;
  }

  const [warehouses, setWarehouses] = useState<Warehouse[]>([]);
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [pendingOrders, setPendingOrders] = useState<Order[]>([]);
  const [selectedOrders, setSelectedOrders] = useState<Order[]>([]);
  const [selectedWarehouse, setSelectedWarehouse] = useState<string>('');
  const [selectedVehicle, setSelectedVehicle] = useState<string>('');
  const [selectedDate, setSelectedDate] = useState<string>(format(new Date(), 'yyyy-MM-dd'));
  const [loading, setLoading] = useState<boolean>(true);
  const [saving, setSaving] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string>('');
  
  // Load initial data
  useEffect(() => {
    const fetchInitialData = async () => {
      try {
        const warehousesRes = await axios.get('/api/warehouses');
        setWarehouses(warehousesRes.data);
        
        if (warehousesRes.data.length > 0) {
          setSelectedWarehouse(warehousesRes.data[0].warehouse_id);
        }
      } catch (error) {
        console.error('Error fetching initial data:', error);
        setError('Failed to load warehouses. Please refresh the page.');
      } finally {
        setLoading(false);
      }
    };
    
    fetchInitialData();
  }, []);
  
  // Load vehicles and orders when warehouse or date changes
  useEffect(() => {
    if (selectedWarehouse && selectedDate) {
      loadWarehouseData();
    }
  }, [selectedWarehouse, selectedDate]);
  
  const loadWarehouseData = async () => {
    setLoading(true);
    try {
      const [vehiclesRes, ordersRes] = await Promise.all([
        axios.get(`/api/vehicles?warehouse_id=${selectedWarehouse}&status=active`),
        axios.get(`/api/orders?warehouse_id=${selectedWarehouse}&pickup_date=${selectedDate}&status=pending`)
      ]);
      
      setVehicles(vehiclesRes.data.data.vehicles);
      setPendingOrders(ordersRes.data.data.orders);
      
      // Clear selected vehicle and orders when warehouse changes
      setSelectedVehicle('');
      setSelectedOrders([]);
      setError(null);
    } catch (error) {
      console.error('Error loading warehouse data:', error);
      setError('Failed to load vehicles or orders. Please try again.');
    } finally {
      setLoading(false);
    }
  };
  
  const handleAddOrder = (order: Order) => {
    // Calculate if adding this order would exceed vehicle capacity
    if (!selectedVehicle) {
      setError('Please select a vehicle first');
      return;
    }
    
    const vehicle = vehicles.find(v => v.id === selectedVehicle);
    if (!vehicle) {
      setError('Selected vehicle not found');
      return;
    }
    
    const currentWeight = selectedOrders.reduce((sum, o) => sum + o.total_weight, 0);
    const currentPallets = selectedOrders.reduce((sum, o) => sum + o.pallets, 0);
    
    if (currentWeight + order.total_weight > vehicle.capacity_weight) {
      setError('Adding this order would exceed vehicle weight capacity');
      return;
    }
    
    if (currentPallets + order.pallets > vehicle.capacity_pallets) {
      setError('Adding this order would exceed vehicle pallet capacity');
      return;
    }
    
    // Add order to selected orders
    setSelectedOrders([...selectedOrders, order]);
    
    // Remove from pending orders
    setPendingOrders(pendingOrders.filter(o => o.id !== order.id));
    
    setError(null);
  };
  
  const handleRemoveOrder = (order: Order) => {
    // Remove from selected orders
    setSelectedOrders(selectedOrders.filter(o => o.id !== order.id));
    
    // Add back to pending orders
    setPendingOrders([...pendingOrders, order]);
    
    setError(null);
  };
  
  const handleSaveShipment = async () => {
    if (!selectedVehicle || selectedOrders.length === 0) {
      setError('Please select a vehicle and at least one order');
      return;
    }
    
    setSaving(true);
    try {
      // Create shipment
      const shipmentData = {
        origin_warehouse_id: selectedWarehouse,
        vehicle_id: selectedVehicle,
        planned_date: selectedDate,
        orders: selectedOrders.map(order => order.id)
      };
      
      const response = await axios.post('/api/shipments', shipmentData);
      
      // Clear selected orders
      setSelectedOrders([]);
      
      // Show success message
      setSuccessMessage(`Shipment ${response.data.data.shipment.shipment_number} created successfully`);
      
      // Clear success message after 3 seconds
      setTimeout(() => {
        setSuccessMessage('');
      }, 3000);
      
      setError(null);
    } catch (error) {
      console.error('Error creating shipment:', error);
      setError('Failed to create shipment. Please try again.');
    } finally {
      setSaving(false);
    }
  };
  
  // Calculate totals for the current load
  const currentWeight = selectedOrders.reduce((sum, order) => sum + order.total_weight, 0);
  const currentPallets = selectedOrders.reduce((sum, order) => sum + order.pallets, 0);
  const selectedVehicleInfo = selectedVehicle ? vehicles.find(v => v.id === selectedVehicle) : null;
  
  // Calculate percentage of capacity used
  const weightPercentage = selectedVehicleInfo ? (currentWeight / selectedVehicleInfo.capacity_weight) * 100 : 0;
  const palletPercentage = selectedVehicleInfo ? (currentPallets / selectedVehicleInfo.capacity_pallets) * 100 : 0;
  
  return (
    <div className="container mx-auto p-4">
      <header className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Load Builder</h1>
          <p className="text-gray-500">Create and optimize shipments</p>
        </div>
        
        <div className="flex items-center space-x-4">
          <Button variant="outlined" onClick={loadWarehouseData}>
            <RefreshCw className="h-4 w-4 mr-2" />
            Refresh Data
          </Button>
        </div>
      </header>
      
      {error && (
        <div className="mb-4 p-4 border border-red-200 bg-red-50 rounded text-red-800">
          <h4 className="font-semibold">Error</h4>
          <p>{error}</p>
        </div>
      )}
      
      {successMessage && (
        <div className="mb-4 p-4 border border-green-200 bg-green-50 rounded text-green-800">
          <h4 className="font-semibold">Success</h4>
          <p>{successMessage}</p>
        </div>
      )}
      
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-4 mb-6">
        <div>
          <Label htmlFor="warehouse">Warehouse</Label>
          <Select
            value={selectedWarehouse}
            onValueChange={setSelectedWarehouse}
            disabled={loading}
          >
            <SelectTrigger>
              <SelectValue placeholder="Select Warehouse" />
            </SelectTrigger>
            <SelectContent>
              {warehouses.map((warehouse) => (
                <SelectItem key={warehouse.warehouse_id} value={warehouse.warehouse_id}>
                  {warehouse.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        
        <div>
          <Label htmlFor="date">Date</Label>
          <Input
            type="date"
            value={selectedDate}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSelectedDate(e.target.value)}
            disabled={loading}
          />
        </div>
        
        <div>
          <Label htmlFor="vehicle">Vehicle</Label>
          <Select
            value={selectedVehicle}
            onValueChange={setSelectedVehicle}
            disabled={loading || vehicles.length === 0}
          >
            <SelectTrigger>
              <SelectValue placeholder="Select Vehicle" />
            </SelectTrigger>
            <SelectContent>
              {vehicles.map((vehicle) => (
                <SelectItem key={vehicle.id} value={vehicle.id}>
                  {vehicle.vehicle_number} ({vehicle.make} {vehicle.model})
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        
        <div className="flex items-end">
          <Button 
            className="w-full" 
            onClick={handleSaveShipment}
            disabled={saving || !selectedVehicle || selectedOrders.length === 0}
          >
            <Save className="h-4 w-4 mr-2" />
            Save Shipment
          </Button>
        </div>
      </div>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Available Orders */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="flex items-center">
              <Package className="h-5 w-5 mr-2" />
              Available Orders ({pendingOrders.length})
            </CardTitle>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="flex justify-center py-8">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
              </div>
            ) : pendingOrders.length === 0 ? (
              <div className="text-center py-8 text-gray-500">
                <p>No pending orders available</p>
              </div>
            ) : (
              <div className="overflow-y-auto max-h-[500px]">
                <table className="w-full">
                  <thead className="bg-gray-50 sticky top-0">
                    <tr>
                      <th className="text-left p-2">Order #</th>
                      <th className="text-left p-2">Destination</th>
                      <th className="text-right p-2">Weight</th>
                      <th className="text-right p-2">Pallets</th>
                      <th className="p-2"></th>
                    </tr>
                  </thead>
                  <tbody>
                    {pendingOrders.map((order) => (
                      <tr key={order.id} className="border-b hover:bg-gray-50">
                        <td className="p-2">{order.order_number}</td>
                        <td className="p-2">{order.delivery_city}, {order.delivery_province}</td>
                        <td className="p-2 text-right">{order.total_weight.toLocaleString()}</td>
                        <td className="p-2 text-right">{order.pallets}</td>
                        <td className="p-2 text-right">
                          <Button 
                            className="p-1" 
                            variant="ghost"
                            onClick={() => handleAddOrder(order)}
                            disabled={!selectedVehicle}
                          >
                            <Plus className="h-4 w-4" />
                          </Button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </CardContent>
        </Card>
        
        {/* Current Load */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="flex items-center">
              <Truck className="h-5 w-5 mr-2" />
              Current Load ({selectedOrders.length})
            </CardTitle>
          </CardHeader>
          <CardContent>
            {!selectedVehicle ? (
              <div className="text-center py-8 text-gray-500">
                <p>Please select a vehicle first</p>
              </div>
            ) : (
              <>
                <div className="grid grid-cols-2 gap-4 mb-4">
                  <div>
                    <p className="text-sm text-gray-500">Weight Capacity</p>
                    <div className="flex items-center justify-between">
                      <div className="w-full bg-gray-200 rounded-full h-2.5 mr-2">
                        <div 
                          className={`h-2.5 rounded-full ${weightPercentage > 90 ? 'bg-red-500' : 'bg-blue-500'}`}
                          style={{ width: `${Math.min(weightPercentage, 100)}%` }}
                        ></div>
                      </div>
                      <p className="text-sm whitespace-nowrap">
                        {currentWeight.toLocaleString()} / {selectedVehicleInfo?.capacity_weight.toLocaleString() || 0} lbs
                      </p>
                    </div>
                  </div>
                  
                  <div>
                    <p className="text-sm text-gray-500">Pallet Capacity</p>
                    <div className="flex items-center justify-between">
                      <div className="w-full bg-gray-200 rounded-full h-2.5 mr-2">
                        <div 
                          className={`h-2.5 rounded-full ${palletPercentage > 90 ? 'bg-red-500' : 'bg-blue-500'}`}
                          style={{ width: `${Math.min(palletPercentage, 100)}%` }}
                        ></div>
                      </div>
                      <p className="text-sm whitespace-nowrap">
                        {currentPallets} / {selectedVehicleInfo?.capacity_pallets || 0}
                      </p>
                    </div>
                  </div>
                </div>
                
                {selectedOrders.length === 0 ? (
                  <div className="text-center py-8 text-gray-500">
                    <p>No orders added to this load yet</p>
                  </div>
                ) : (
                  <div className="overflow-y-auto max-h-[400px]">
                    <table className="w-full">
                      <thead className="bg-gray-50 sticky top-0">
                        <tr>
                          <th className="text-left p-2">Order #</th>
                          <th className="text-left p-2">Destination</th>
                          <th className="text-right p-2">Weight</th>
                          <th className="text-right p-2">Pallets</th>
                          <th className="p-2"></th>
                        </tr>
                      </thead>
                      <tbody>
                        {selectedOrders.map((order, index) => (
                          <tr key={order.id} className="border-b hover:bg-gray-50">
                            <td className="p-2">{order.order_number}</td>
                            <td className="p-2">{order.delivery_city}, {order.delivery_province}</td>
                            <td className="p-2 text-right">{order.total_weight.toLocaleString()}</td>
                            <td className="p-2 text-right">{order.pallets}</td>
                            <td className="p-2 text-right">
                              <Button 
                                className="p-1" 
                                variant="ghost"
                                onClick={() => handleRemoveOrder(order)}
                              >
                                <span className="text-red-500">×</span>
                              </Button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default LoadBuilder;
