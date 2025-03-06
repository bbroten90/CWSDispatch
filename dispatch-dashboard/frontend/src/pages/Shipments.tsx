// src/pages/Shipments.tsx
import React, { useState, useEffect } from 'react';
import { format } from 'date-fns';
import axios from 'axios';
import { 
  Card, CardContent, CardHeader, CardTitle,
  Button, Input,
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
  Tabs, TabsContent, TabsList, TabsTrigger,
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger,
  DialogFooter, DialogClose
} from '@/components/ui';
import { Truck, Filter, Download, RefreshCw, Eye, MapPin } from 'lucide-react';

const Shipments = () => {
  const [shipments, setShipments] = useState([]);
  const [warehouses, setWarehouses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedShipment, setSelectedShipment] = useState(null);
  const [showDetailsDialog, setShowDetailsDialog] = useState(false);
  
  // Filter states
  const [selectedWarehouse, setSelectedWarehouse] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('');
  const [dateRange, setDateRange] = useState({
    startDate: format(new Date(), 'yyyy-MM-dd'),
    endDate: format(new Date(new Date().setDate(new Date().getDate() + 7)), 'yyyy-MM-dd')
  });
  
  useEffect(() => {
    // Load initial data
    const fetchInitialData = async () => {
      try {
        const warehousesRes = await axios.get('/api/warehouses');
        setWarehouses(warehousesRes.data);
        
        if (warehousesRes.data.length > 0) {
          setSelectedWarehouse(warehousesRes.data[0].warehouse_id);
        }
        
        // Load shipments with default filters
        loadShipments();
      } catch (error) {
        console.error('Error fetching initial data:', error);
      }
    };
    
    fetchInitialData();
  }, []);
  
  const loadShipments = async () => {
    setLoading(true);
    try {
      const filters = {
        origin_warehouse_id: selectedWarehouse,
        status: selectedStatus,
        start_date: dateRange.startDate,
        end_date: dateRange.endDate
      };
      
      // Remove empty filters
      Object.keys(filters).forEach(key => {
        if (!filters[key]) delete filters[key];
      });
      
      const response = await axios.get('/api/shipments', { params: filters });
      setShipments(response.data.data.shipments);
    } catch (error) {
      console.error('Error loading shipments:', error);
    } finally {
      setLoading(false);
    }
  };
  
  // Apply filters when they change
  useEffect(() => {
    if (warehouses.length > 0) {
      loadShipments();
    }
  }, [selectedWarehouse, selectedStatus, dateRange]);
  
  const getShipmentDetails = async (shipmentId) => {
    try {
      const response = await axios.get(`/api/shipments/${shipmentId}/details`);
      setSelectedShipment(response.data.data.shipment);
      setShowDetailsDialog(true);
    } catch (error) {
      console.error('Error loading shipment details:', error);
    }
  };
  
  // Export shipments to CSV
  const exportShipmentsCSV = () => {
    // Convert shipments to CSV
    const headers = ['Shipment #', 'Origin', 'Vehicle', 'Date', 'Status', 'Orders', 'Weight (lbs)', 'Pallets', 'Revenue'];
    
    const csvRows = [
      headers.join(','),
      ...shipments.map(shipment => [
        shipment.shipment_number,
        shipment.warehouse_name || '',
        shipment.vehicle_number || '',
        format(new Date(shipment.planned_date), 'yyyy-MM-dd'),
        shipment.status,
        shipment.order_count || 0,
        shipment.total_weight,
        shipment.total_pallets,
        shipment.total_revenue
      ].join(','))
    ];
    
    const csvContent = csvRows.join('\n');
    
    // Create a blob and download
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `shipments_export_${format(new Date(), 'yyyyMMdd')}.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };
  
  // Helper function to format currency
  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-CA', {
      style: 'currency',
      currency: 'CAD'
    }).format(amount);
  };
  
  return (
    <div className="container mx-auto p-4">
      <header className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Shipments</h1>
          <p className="text-gray-500">View and manage all shipments</p>
        </div>
        
        <div className="flex items-center space-x-2">
          <Button onClick={loadShipments} variant="outline">
            <RefreshCw className="h-4 w-4 mr-2" />
            Refresh
          </Button>
          
          <Button onClick={exportShipmentsCSV} variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Export
          </Button>
        </div>
      </header>
      
      {/* Filters */}
      <Card className="mb-6">
        <CardHeader className="pb-2">
          <CardTitle className="text-lg flex items-center">
            <Filter className="h-4 w-4 mr-2" />
            Filters
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="text-sm font-medium">Warehouse</label>
              <Select
                value={selectedWarehouse}
                onValueChange={setSelectedWarehouse}
              >
                <SelectTrigger>
                  <SelectValue placeholder="All Warehouses" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">All Warehouses</SelectItem>
                  {warehouses.map((warehouse) => (
                    <SelectItem key={warehouse.warehouse_id} value={warehouse.warehouse_id}>
                      {warehouse.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            
            <div>
              <label className="text-sm font-medium">Status</label>
              <Select
                value={selectedStatus}
                onValueChange={setSelectedStatus}
              >
                // src/pages/Shipments.tsx (continuing)
                <SelectTrigger>
                  <SelectValue placeholder="All Statuses" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">All Statuses</SelectItem>
                  <SelectItem value="planned">Planned</SelectItem>
                  <SelectItem value="in_transit">In Transit</SelectItem>
                  <SelectItem value="completed">Completed</SelectItem>
                  <SelectItem value="cancelled">Cancelled</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div className="grid grid-cols-2 gap-2">
              <div>
                <label className="text-sm font-medium">Start Date</label>
                <Input
                  type="date"
                  value={dateRange.startDate}
                  onChange={(e) => setDateRange(prev => ({ ...prev, startDate: e.target.value }))}
                />
              </div>
              
              <div>
                <label className="text-sm font-medium">End Date</label>
                <Input
                  type="date"
                  value={dateRange.endDate}
                  onChange={(e) => setDateRange(prev => ({ ...prev, endDate: e.target.value }))}
                />
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
      
      {/* Shipment Tabs */}
      <Tabs defaultValue="all">
        <TabsList className="mb-4">
          <TabsTrigger value="all">All Shipments</TabsTrigger>
          <TabsTrigger value="planned">Planned</TabsTrigger>
          <TabsTrigger value="in_transit">In Transit</TabsTrigger>
          <TabsTrigger value="completed">Completed</TabsTrigger>
        </TabsList>
        
        <TabsContent value="all">
          <ShipmentsTable 
            shipments={shipments} 
            loading={loading} 
            onViewDetails={getShipmentDetails}
            formatCurrency={formatCurrency}
          />
        </TabsContent>
        
        <TabsContent value="planned">
          <ShipmentsTable 
            shipments={shipments.filter(s => s.status === 'planned')} 
            loading={loading} 
            onViewDetails={getShipmentDetails}
            formatCurrency={formatCurrency}
          />
        </TabsContent>
        
        <TabsContent value="in_transit">
          <ShipmentsTable 
            shipments={shipments.filter(s => s.status === 'in_transit')} 
            loading={loading} 
            onViewDetails={getShipmentDetails}
            formatCurrency={formatCurrency}
          />
        </TabsContent>
        
        <TabsContent value="completed">
          <ShipmentsTable 
            shipments={shipments.filter(s => s.status === 'completed')} 
            loading={loading} 
            onViewDetails={getShipmentDetails}
            formatCurrency={formatCurrency}
          />
        </TabsContent>
      </Tabs>
      
      {/* Shipment Details Dialog */}
      <Dialog open={showDetailsDialog} onOpenChange={setShowDetailsDialog}>
        <DialogContent className="sm:max-w-[700px]">
          <DialogHeader>
            <DialogTitle>Shipment Details</DialogTitle>
          </DialogHeader>
          
          {selectedShipment && (
            <div className="grid gap-4 py-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="text-sm font-medium text-gray-500">Shipment Number</p>
                  <p className="font-semibold">{selectedShipment.shipment_number}</p>
                </div>
                
                <div>
                  <p className="text-sm font-medium text-gray-500">Status</p>
                  <p className="font-semibold capitalize">{selectedShipment.status}</p>
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="text-sm font-medium text-gray-500">Origin Warehouse</p>
                  <p className="font-semibold">{selectedShipment.warehouse_name}</p>
                </div>
                
                <div>
                  <p className="text-sm font-medium text-gray-500">Vehicle</p>
                  <p className="font-semibold">{selectedShipment.vehicle_number || 'Not assigned'}</p>
                </div>
              </div>
              
              <div className="grid grid-cols-3 gap-4">
                <div>
                  <p className="text-sm font-medium text-gray-500">Total Weight</p>
                  <p className="font-semibold">{selectedShipment.total_weight.toLocaleString()} lbs</p>
                </div>
                
                <div>
                  <p className="text-sm font-medium text-gray-500">Total Pallets</p>
                  <p className="font-semibold">{selectedShipment.total_pallets}</p>
                </div>
                
                <div>
                  <p className="text-sm font-medium text-gray-500">Revenue</p>
                  <p className="font-semibold">{formatCurrency(selectedShipment.total_revenue)}</p>
                </div>
              </div>
              
              <div>
                <p className="text-sm font-medium text-gray-500 mb-2">Orders in Shipment</p>
                {selectedShipment.orders && selectedShipment.orders.length > 0 ? (
                  <div className="overflow-y-auto max-h-[300px] border rounded">
                    <table className="w-full">
                      <thead className="bg-gray-50 sticky top-0">
                        <tr>
                          <th className="text-left p-2">Seq</th>
                          <th className="text-left p-2">Order #</th>
                          <th className="text-left p-2">Customer</th>
                          <th className="text-left p-2">Destination</th>
                          <th className="text-right p-2">Weight</th>
                          <th className="text-right p-2">Pallets</th>
                        </tr>
                      </thead>
                      <tbody>
                        {selectedShipment.orders.map((order, index) => (
                          <tr key={order.id} className="border-t">
                            <td className="p-2">{order.stop_sequence || index + 1}</td>
                            <td className="p-2">{order.order_number}</td>
                            <td className="p-2">{order.customer_name}</td>
                            <td className="p-2">{order.delivery_city}, {order.delivery_province}</td>
                            <td className="p-2 text-right">{order.total_weight.toLocaleString()}</td>
                            <td className="p-2 text-right">{order.pallets}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                ) : (
                  <p className="text-gray-500">No orders assigned to this shipment</p>
                )}
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
};

// Shipments Table Component
const ShipmentsTable = ({ shipments, loading, onViewDetails, formatCurrency }) => {
  const getStatusColor = (status) => {
    switch (status) {
      case 'planned': return 'bg-blue-100 text-blue-800';
      case 'in_transit': return 'bg-purple-100 text-purple-800';
      case 'completed': return 'bg-green-100 text-green-800';
      case 'cancelled': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };
  
  return (
    <Card>
      <CardContent className="p-0">
        {loading ? (
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
          </div>
        ) : shipments.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            <Truck className="mx-auto h-12 w-12 mb-4 text-gray-400" />
            <p>No shipments found matching the selected filters</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50 border-b">
                  <th className="text-left p-3">Shipment #</th>
                  <th className="text-left p-3">Origin</th>
                  <th className="text-left p-3">Vehicle</th>
                  <th className="text-left p-3">Date</th>
                  <th className="text-center p-3">Status</th>
                  <th className="text-right p-3">Orders</th>
                  <th className="text-right p-3">Weight (lbs)</th>
                  <th className="text-right p-3">Pallets</th>
                  <th className="text-right p-3">Revenue</th>
                  <th className="text-center p-3">Actions</th>
                </tr>
              </thead>
              <tbody>
                {shipments.map((shipment) => (
                  <tr key={shipment.id} className="border-b hover:bg-gray-50">
                    <td className="p-3">{shipment.shipment_number}</td>
                    <td className="p-3">{shipment.warehouse_name || 'Unknown'}</td>
                    <td className="p-3">{shipment.vehicle_number || 'Not assigned'}</td>
                    <td className="p-3">{format(new Date(shipment.planned_date), 'MMM d, yyyy')}</td>
                    <td className="p-3 text-center">
                      <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(shipment.status)}`}>
                        {shipment.status}
                      </span>
                    </td>
                    <td className="p-3 text-right">{shipment.order_count || 0}</td>
                    <td className="p-3 text-right">{shipment.total_weight.toLocaleString()}</td>
                    <td className="p-3 text-right">{shipment.total_pallets}</td>
                    <td className="p-3 text-right">{formatCurrency(shipment.total_revenue)}</td>
                    <td className="p-3 text-center">
                      <Button 
                        size="sm" 
                        variant="ghost" 
                        onClick={() => onViewDetails(shipment.id)}
                        title="View Details"
                      >
                        <Eye className="h-4 w-4" />
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
  );
};

export default Shipments;