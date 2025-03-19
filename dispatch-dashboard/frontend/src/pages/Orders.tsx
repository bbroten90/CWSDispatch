// src/pages/Orders.tsx
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
} from '../components/ui';
import { 
  Package, 
  Search, 
  Plus, 
  Filter, 
  Download, 
  RefreshCw, 
  Truck, 
  Building, 
  User, 
  MapPin, 
  Calendar, 
  ClipboardList,
  Factory
} from 'lucide-react';
import HazardWarning from '../components/HazardWarning';
import SearchableSelect from '../components/SearchableSelect';
import ProductSelector from '../components/ProductSelector';

// Orders Table Component
interface OrdersTableProps {
  orders: Array<{
    id: number;
    order_number: string;
    customer_name: string;
    warehouse_name: string;
    delivery_city: string;
    delivery_province: string;
    pickup_date: string;
    delivery_date: string;
    total_weight: number;
    pallets: number;
    status: string;
    line_items?: Array<{
      product_id?: string;
      product_name?: string;
      quantity?: number;
      weight_lbs?: number;
      hazard_code?: string;
      hazard_description1?: string;
      hazard_description2?: string;
      hazard_description3?: string;
    }>;
  }>;
  loading: boolean;
}

const OrdersTable = ({ orders, loading }: OrdersTableProps) => {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-amber-100 text-amber-800';
      case 'assigned': return 'bg-blue-100 text-blue-800';
      case 'in_transit': return 'bg-purple-100 text-purple-800';
      case 'delivered': return 'bg-green-100 text-green-800';
      case 'cancelled': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };
  
  return (
    <Card className="shadow-sm border border-gray-200">
      <CardContent className="p-0">
        {loading ? (
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        ) : orders.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            <Package className="mx-auto h-12 w-12 mb-4 text-gray-300" />
            <p>No orders found matching the selected filters</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50 border-b">
                  <th className="text-left p-3 text-gray-600 font-medium">Order #</th>
                  <th className="text-left p-3 text-gray-600 font-medium">Customer</th>
                  <th className="text-left p-3 text-gray-600 font-medium">Warehouse</th>
                  <th className="text-left p-3 text-gray-600 font-medium">Delivery Location</th>
                  <th className="text-left p-3 text-gray-600 font-medium">Pickup Date</th>
                  <th className="text-left p-3 text-gray-600 font-medium">Delivery Date</th>
                  <th className="text-right p-3 text-gray-600 font-medium">Weight (lbs)</th>
                  <th className="text-right p-3 text-gray-600 font-medium">Pallets</th>
                  <th className="text-center p-3 text-gray-600 font-medium">Status</th>
                  <th className="text-center p-3 text-gray-600 font-medium">Hazard</th>
                </tr>
              </thead>
              <tbody>
                {orders.map((order) => (
                  <tr key={order.id} className="border-b hover:bg-gray-50">
                    <td className="p-3 font-medium">{order.order_number}</td>
                    <td className="p-3">{order.customer_name || "Unknown"}</td>
                    <td className="p-3">{order.warehouse_name || "Unknown"}</td>
                    <td className="p-3">{order.delivery_city}, {order.delivery_province}</td>
                    <td className="p-3">{format(new Date(order.pickup_date), 'MMM d, yyyy')}</td>
                    <td className="p-3">{format(new Date(order.delivery_date), 'MMM d, yyyy')}</td>
                    <td className="p-3 text-right font-mono">{order.total_weight.toLocaleString()}</td>
                    <td className="p-3 text-right font-mono">{order.pallets}</td>
                    <td className="p-3">
                      <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(order.status)}`}>
                        {order.status}
                      </span>
                    </td>
                    <td className="p-3 text-center">
                      {order.line_items && order.line_items.some(item => item.hazard_code) ? (
                        <div className="flex flex-col gap-1 items-center">
                          {order.line_items
                            .filter(item => item.hazard_code)
                            .map((item, index) => (
                              <HazardWarning
                                key={index}
                                hazardCode={item.hazard_code || ''}
                                hazardDescription1={item.hazard_description1}
                                hazardDescription2={item.hazard_description2}
                                hazardDescription3={item.hazard_description3}
                              />
                            ))}
                        </div>
                      ) : (
                        <span className="text-gray-400 text-xs">None</span>
                      )}
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

const Orders = () => {
  interface Order {
    id: number;
    order_number: string;
    customer_name: string;
    warehouse_name: string;
    delivery_city: string;
    delivery_province: string;
    pickup_date: string;
    delivery_date: string;
    total_weight: number;
    pallets: number;
    status: string;
    line_items?: Array<{
      product_id?: string;
      product_name?: string;
      quantity?: number;
      weight_lbs?: number;
      hazard_code?: string;
      hazard_description1?: string;
      hazard_description2?: string;
      hazard_description3?: string;
    }>;
  }

  interface Warehouse {
    warehouse_id: string;
    name: string;
  }

  interface Customer {
    customer_id: string;
    company_name: string;
    address?: string;
    city?: string;
    province?: string;
    postal_code?: string;
    contact_name?: string;
    contact_phone?: string;
    contact_email?: string;
  }

  interface Manufacturer {
    manufacturer_id: string;
    name: string;
  }

  interface FilterParams {
    [key: string]: string;
  }

  interface OrderProduct {
    product_id: string;
    name: string;
    description: string;
    weight_lbs: number;
    requires_heating: boolean;
    requires_refrigeration: boolean;
    hazard_code?: string;
    hazard_description1?: string;
    hazard_description2?: string;
    hazard_description3?: string;
    quantity: number;
    quantity_on_hand?: number;
  }

  const [orders, setOrders] = useState<Order[]>([]);
  const [warehouses, setWarehouses] = useState<Warehouse[]>([]);
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [manufacturers, setManufacturers] = useState<Manufacturer[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Filter states
  const [selectedWarehouse, setSelectedWarehouse] = useState('');
  const [selectedCustomer, setSelectedCustomer] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('');
  const [dateRange, setDateRange] = useState({
    startDate: format(new Date(), 'yyyy-MM-dd'),
    endDate: format(new Date(new Date().setDate(new Date().getDate() + 7)), 'yyyy-MM-dd')
  });
  
  // New order form
  const [showNewOrderDialog, setShowNewOrderDialog] = useState(false);
  const [newOrderForm, setNewOrderForm] = useState({
    order_number: '',
    po_number: '',
    customer_id: '',
    pickup_warehouse_id: '',
    manufacturer_id: '',
    delivery_address: '',
    delivery_city: '',
    delivery_province: '',
    delivery_postal_code: '',
    pickup_date: format(new Date(), 'yyyy-MM-dd'),
    delivery_date: format(new Date(new Date().setDate(new Date().getDate() + 1)), 'yyyy-MM-dd'),
    total_weight: 0,
    pallets: 0,
    special_instructions: '',
    line_items: []
  });
  
  // Order products
  const [orderProducts, setOrderProducts] = useState<OrderProduct[]>([]);
  
  useEffect(() => {
    // Load initial data
    const fetchInitialData = async () => {
      try {
        const [warehousesRes, customersRes, manufacturersRes] = await Promise.all([
          axios.get('/api/warehouses', { headers: { 'x-internal-request': 'true' } }),
          axios.get('/api/customers', { headers: { 'x-internal-request': 'true' } }),
          axios.get('/api/manufacturers', { headers: { 'x-internal-request': 'true' } })
        ]);
        
        if (warehousesRes.data.success && warehousesRes.data.data) {
          setWarehouses(warehousesRes.data.data);
        } else {
          setWarehouses([]);
        }
        
        if (customersRes.data.success && customersRes.data.data) {
          setCustomers(customersRes.data.data);
        } else {
          setCustomers([]);
        }
        
        if (manufacturersRes.data.success && manufacturersRes.data.data) {
          setManufacturers(manufacturersRes.data.data);
        } else {
          setManufacturers([]);
        }
        
        if (warehousesRes.data.success && warehousesRes.data.data && warehousesRes.data.data.length > 0) {
          setSelectedWarehouse(warehousesRes.data.data[0].warehouse_id);
          setNewOrderForm(prev => ({
            ...prev,
            pickup_warehouse_id: warehousesRes.data.data[0].warehouse_id
          }));
        }
        
        if (customersRes.data.success && customersRes.data.data && customersRes.data.data.length > 0) {
          setNewOrderForm(prev => ({
            ...prev,
            customer_id: customersRes.data.data[0].customer_id
          }));
        }
        
        if (manufacturersRes.data.success && manufacturersRes.data.data && manufacturersRes.data.data.length > 0) {
          setNewOrderForm(prev => ({
            ...prev,
            manufacturer_id: manufacturersRes.data.data[0].manufacturer_id
          }));
        }
        
        // Load orders with default filters
        loadOrders();
      } catch (error) {
        console.error('Error fetching initial data:', error);
      }
    };
    
    fetchInitialData();
  }, []);
  
  const loadOrders = async () => {
    setLoading(true);
    try {
      const filters: FilterParams = {
        warehouse_id: selectedWarehouse,
        customer_id: selectedCustomer,
        status: selectedStatus,
        start_date: dateRange.startDate,
        end_date: dateRange.endDate
      };
      
      // Remove empty filters
      Object.keys(filters).forEach(key => {
        if (!filters[key as keyof FilterParams]) {
          delete filters[key as keyof FilterParams];
        }
      });
      
      const response = await axios.get('/api/orders', { 
        params: filters,
        headers: { 'x-internal-request': 'true' }
      });
      if (response.data.success && response.data.data && response.data.data.orders) {
        setOrders(response.data.data.orders);
      } else {
        setOrders([]);
      }
    } catch (error) {
      console.error('Error loading orders:', error);
    } finally {
      setLoading(false);
    }
  };
  
  // Apply filters when they change
  useEffect(() => {
    if (warehouses.length > 0) {
      loadOrders();
    }
  }, [selectedWarehouse, selectedCustomer, selectedStatus, dateRange]);
  
  // Update total weight when products change
  useEffect(() => {
    const totalWeight = orderProducts.reduce((sum, product) => {
      return sum + (product.weight_lbs * product.quantity);
    }, 0);
    
    setNewOrderForm(prev => ({
      ...prev,
      total_weight: totalWeight,
      pallets: orderProducts.length > 0 ? Math.ceil(orderProducts.reduce((sum, p) => sum + p.quantity, 0) / 10) : 0
    }));
  }, [orderProducts]);
  
  const handleNewOrderSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    
    try {
      // Find the selected warehouse name
      const selectedWarehouse = warehouses.find(w => w.warehouse_id === newOrderForm.pickup_warehouse_id);
      const warehouseName = selectedWarehouse ? selectedWarehouse.name : '';
      
      // Find the selected manufacturer name
      const selectedManufacturer = manufacturers.find(m => m.manufacturer_id === newOrderForm.manufacturer_id);
      const manufacturerName = selectedManufacturer ? selectedManufacturer.name : '';
      
      // Find the selected customer
      const selectedCustomer = customers.find(c => c.customer_id === newOrderForm.customer_id);
      
      // Convert weight from lbs to kg for the API
      const totalWeightKg = newOrderForm.total_weight * 0.453592; // Convert lbs to kg
      
      // Calculate total quantity
      const totalQuantity = orderProducts.reduce((sum, product) => sum + product.quantity, 0);
      
      // Transform the order data to match the expected API format
      const orderData = {
        orderHeader: {
          documentId: newOrderForm.order_number, // Use order_number as documentId
          manufacturer: manufacturerName,
          orderDate: new Date().toISOString().split('T')[0], // Today's date
          poNumber: newOrderForm.po_number,
          shipmentDate: newOrderForm.pickup_date,
          deliveryDate: newOrderForm.delivery_date
        },
        shipment: {
          shipFrom: warehouseName,
          shipTo: {
            companyName: selectedCustomer?.company_name || 'Unknown',
            city: newOrderForm.delivery_city,
            province: newOrderForm.delivery_province
          },
          specialRequirements: newOrderForm.special_instructions
        },
        lineItems: orderProducts.map(product => ({
          productId: product.product_id,
          productName: product.name,
          quantity: product.quantity,
          weightKg: product.weight_lbs * 0.453592 // Convert lbs to kg
        })),
        totals: {
          totalQuantity: totalQuantity,
          totalWeightKg: totalWeightKg
        }
      };
      
      await axios.post('/api/orders', orderData, {
        headers: {
          'x-internal-request': 'true'
        }
      });
      
      // Close dialog and reset form
      setShowNewOrderDialog(false);
      
      // Reload orders
      loadOrders();
      
      // Reset form
      setNewOrderForm({
        order_number: '',
        po_number: '',
        customer_id: newOrderForm.customer_id,
        pickup_warehouse_id: newOrderForm.pickup_warehouse_id,
        manufacturer_id: newOrderForm.manufacturer_id,
        delivery_address: '',
        delivery_city: '',
        delivery_province: '',
        delivery_postal_code: '',
        pickup_date: format(new Date(), 'yyyy-MM-dd'),
        delivery_date: format(new Date(new Date().setDate(new Date().getDate() + 1)), 'yyyy-MM-dd'),
        total_weight: 0,
        pallets: 0,
        special_instructions: '',
        line_items: []
      });
      
      // Reset products
      setOrderProducts([]);
    } catch (error: unknown) {
      console.error('Error creating order:', error);
      const errorMessage = error instanceof Error 
        ? error.message 
        : 'Unknown error occurred';
      alert('Error creating order: ' + errorMessage);
    }
  };
  
  const handleFormChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setNewOrderForm(prev => ({
      ...prev,
      [name]: name === 'total_weight' || name === 'pallets' ? parseFloat(value) : value
    }));
  };
  
  const handleSelectChange = async (name: string, value: string) => {
    // Update form with the selected value
    setNewOrderForm(prev => ({
      ...prev,
      [name]: value
    }));
    
    // If customer is selected, fetch customer details and auto-fill address
    if (name === 'customer_id' && value) {
      try {
        const response = await axios.get(`/api/customers/${value}`, {
          headers: { 'x-internal-request': 'true' }
        });
        if (response.data.success && response.data.data) {
          const customer = response.data.data;
          setNewOrderForm(prev => ({
            ...prev,
            delivery_address: customer.address || '',
            delivery_city: customer.city || '',
            delivery_province: customer.province || '',
            delivery_postal_code: customer.postal_code || ''
          }));
        }
      } catch (error) {
        console.error('Error fetching customer details:', error);
      }
    }
  };
  
  // Export orders to CSV
  const exportOrdersCSV = () => {
    // Convert orders to CSV
    const headers = ['Order #', 'Customer', 'Warehouse', 'Delivery City', 'Province', 'Pickup Date', 'Delivery Date', 'Weight', 'Pallets', 'Status'];
    
    const csvRows = [
      headers.join(','),
      ...orders.map(order => [
        order.order_number,
        order.customer_name || '',
        order.warehouse_name || '',
        order.delivery_city,
        order.delivery_province,
        format(new Date(order.pickup_date), 'yyyy-MM-dd'),
        format(new Date(order.delivery_date), 'yyyy-MM-dd'),
        order.total_weight,
        order.pallets,
        order.status
      ].join(','))
    ];
    
    const csvContent = csvRows.join('\n');
    
    // Create a blob and download
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `orders_export_${format(new Date(), 'yyyyMMdd')}.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };
  
  // Section header component for the form
  const SectionHeader = ({ icon, title }: { icon: React.ReactNode, title: string }) => (
    <div className="flex items-center border-b border-gray-200 pb-2 mb-4">
      <div className="mr-2 text-blue-600">{icon}</div>
      <h3 className="text-lg font-medium text-gray-700">{title}</h3>
    </div>
  );
  
  return (
    <div className="container mx-auto p-4">
      <header className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Orders</h1>
          <p className="text-gray-500">Manage and track all orders</p>
        </div>
        
        <div className="flex items-center space-x-2">
          <Button onClick={loadOrders} variant="outlined" className="border-gray-300">
            <RefreshCw className="h-4 w-4 mr-2" />
            Refresh
          </Button>
          
          <Button onClick={exportOrdersCSV} variant="outlined" className="border-gray-300">
            <Download className="h-4 w-4 mr-2" />
            Export
          </Button>
          
          <Dialog open={showNewOrderDialog} onOpenChange={setShowNewOrderDialog}>
            <div 
              onClick={() => setShowNewOrderDialog(true)}
              className="rounded-md font-medium transition-colors bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 flex items-center cursor-pointer"
            >
              <Plus className="h-4 w-4 mr-2" />
              New Order
            </div>
            
            <DialogContent className="sm:max-w-[750px]">
              <DialogHeader className="border-b pb-3">
                <DialogTitle className="text-xl flex items-center">
                  <ClipboardList className="h-5 w-5 mr-2 text-blue-600" />
                  Create New Order
                </DialogTitle>
              </DialogHeader>
              
              <form onSubmit={handleNewOrderSubmit} className="overflow-y-auto max-h-[75vh]">
                <div className="grid gap-6 py-4">
                  {/* Order Information */}
                  <div className="bg-gray-50 p-4 rounded-lg border border-gray-200 shadow-sm">
                    <SectionHeader icon={<ClipboardList className="h-5 w-5" />} title="Order Information" />
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                          <label className="text-sm font-medium mb-1 block text-gray-700">Order Number</label>
                          <Input 
                            name="order_number"
                            value={newOrderForm.order_number}
                            onChange={handleFormChange}
                            required
                            className="border-gray-300"
                          />
                        </div>
                        <div>
                          <label className="text-sm font-medium mb-1 block text-gray-700">PO Number</label>
                          <Input 
                            name="po_number"
                            value={newOrderForm.po_number}
                            onChange={handleFormChange}
                            required
                            className="border-gray-300"
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  {/* Customer & Warehouse */}
                  <div className="bg-blue-50 p-4 rounded-lg border border-blue-100 shadow-sm">
                    <SectionHeader icon={<Building className="h-5 w-5" />} title="Customer & Warehouse" />
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <label className="text-sm font-medium mb-1 block text-gray-700">Customer</label>
                        <SearchableSelect
                          options={customers.map(customer => ({
                            value: String(customer.customer_id),
                            label: customer.company_name,
                            searchText: String(customer.customer_id)
                          }))}
                          value={newOrderForm.customer_id}
                          onValueChange={(value: string) => handleSelectChange('customer_id', value)}
                          placeholder="Select Customer"
                          required
                          showOptionValue={true}
                        />
                      </div>
                      
                      <div>
                        <label className="text-sm font-medium mb-1 block text-gray-700">Pickup Warehouse</label>
                        <Select
                          value={newOrderForm.pickup_warehouse_id}
                          onValueChange={(value: string) => handleSelectChange('pickup_warehouse_id', value)}
                          required
                        >
                          <SelectTrigger className="border-gray-300">
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
                        <label className="text-sm font-medium mb-1 block text-gray-700">Manufacturer</label>
                        <Select
                          value={newOrderForm.manufacturer_id}
                          onValueChange={(value: string) => handleSelectChange('manufacturer_id', value)}
                          required
                        >
                          <SelectTrigger className="border-gray-300">
                            <SelectValue placeholder="Select Manufacturer" />
                          </SelectTrigger>
                          <SelectContent>
                            {manufacturers.map((manufacturer) => (
                              <SelectItem key={manufacturer.manufacturer_id} value={manufacturer.manufacturer_id}>
                                {manufacturer.name}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                    </div>
                  </div>
                  
                  {/* Delivery Address */}
                  <div className="bg-green-50 p-4 rounded-lg border border-green-100 shadow-sm">
                    <SectionHeader icon={<MapPin className="h-5 w-5" />} title="Delivery Address" />
                    <div>
                      <label className="text-sm font-medium mb-1 block text-gray-700">Delivery Address</label>
                      <Input 
                        name="delivery_address"
                        value={newOrderForm.delivery_address}
                        onChange={handleFormChange}
                        required
                        className="border-gray-300 mb-3"
                      />
                    </div>
                    
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <div>
                        <label className="text-sm font-medium mb-1 block text-gray-700">City</label>
                        <Input 
                          name="delivery_city"
                          value={newOrderForm.delivery_city}
                          onChange={handleFormChange}
                          required
                          className="border-gray-300"
                        />
                      </div>
                      
                      <div>
                        <label className="text-sm font-medium mb-1 block text-gray-700">Province</label>
                        <Input 
                          name="delivery_province"
                          value={newOrderForm.delivery_province}
                          onChange={handleFormChange}
                          maxLength={2}
                          required
                          className="border-gray-300"
                        />
                      </div>
                      
                      <div>
                        <label className="text-sm font-medium mb-1 block text-gray-700">Postal Code</label>
                        <Input 
                          name="delivery_postal_code"
                          value={newOrderForm.delivery_postal_code}
                          onChange={handleFormChange}
                          required
                          className="border-gray-300"
                        />
                      </div>
                    </div>
                  </div>
                  
                  {/* Schedule */}
                  <div className="bg-purple-50 p-4 rounded-lg border border-purple-100 shadow-sm">
                    <SectionHeader icon={<Calendar className="h-5 w-5" />} title="Schedule" />
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <label className="text-sm font-medium mb-1 block text-gray-700">Pickup Date</label>
                        <Input 
                          type="date"
                          name="pickup_date"
                          value={newOrderForm.pickup_date}
                          onChange={handleFormChange}
                          required
                          className="border-gray-300"
                        />
                      </div>
                      
                      <div>
                        <label className="text-sm font-medium mb-1 block text-gray-700">Delivery Date</label>
                        <Input 
                          type="date"
                          name="delivery_date"
                          value={newOrderForm.delivery_date}
                          onChange={handleFormChange}
                          required
                          className="border-gray-300"
                        />
                      </div>
                    </div>
                  </div>
                  
                  {/* Products */}
                  <div className="bg-white p-4 rounded-lg border border-gray-200 shadow-sm">
                    <ProductSelector
                      warehouseId={newOrderForm.pickup_warehouse_id}
                      products={orderProducts}
                      onProductsChange={setOrderProducts}
                    />
                  </div>
                  
                  {/* Weight & Pallets */}
                  <div className="bg-amber-50 p-4 rounded-lg border border-amber-100 shadow-sm">
                    <SectionHeader icon={<Truck className="h-5 w-5" />} title="Shipping Details" />
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <label className="text-sm font-medium mb-1 block text-gray-700">Weight (lbs)</label>
                        <Input 
                          type="number"
                          name="total_weight"
                          value={newOrderForm.total_weight}
                          onChange={handleFormChange}
                          min="0"
                          step="0.1"
                          required
                          disabled={orderProducts.length > 0}
                          className="border-gray-300"
                        />
                        {orderProducts.length > 0 && (
                          <p className="text-xs text-gray-500 mt-1">
                            Auto-calculated from products
                          </p>
                        )}
                      </div>
                      
                      <div>
                        <label className="text-sm font-medium mb-1 block text-gray-700">Pallets</label>
                        <Input 
                          type="number"
                          name="pallets"
                          value={newOrderForm.pallets}
                          onChange={handleFormChange}
                          min="0"
                          step="1"
                          required
                          disabled={orderProducts.length > 0}
                          className="border-gray-300"
                        />
                        {orderProducts.length > 0 && (
                          <p className="text-xs text-gray-500 mt-1">
                            Auto-calculated from products
                          </p>
                        )}
                      </div>
                    </div>
                  </div>
                  
                  {/* Special Instructions */}
                  <div className="bg-gray-50 p-4 rounded-lg border border-gray-200 shadow-sm">
                    <SectionHeader icon={<ClipboardList className="h-5 w-5" />} title="Additional Information" />
                    <div>
                      <label className="text-sm font-medium mb-1 block text-gray-700">Special Instructions</label>
                      <Input 
                        name="special_instructions"
                        value={newOrderForm.special_instructions}
                        onChange={handleFormChange}
                        className="border-gray-300"
                      />
                    </div>
                  </div>
                </div>
                
                <DialogFooter className="border-t pt-4 mt-2">
                  <DialogClose asChild>
                    <Button type="button" variant="outlined" className="border-gray-300 mr-2">Cancel</Button>
                  </DialogClose>
                  <Button type="submit" className="bg-green-600 hover:bg-green-700">
                    Create Order
                  </Button>
                </DialogFooter>
              </form>
            </DialogContent>
          </Dialog>
        </div>
      </header>
      
      {/* Filters */}
      <Card className="mb-6 shadow-sm border border-gray-200">
        <CardHeader className="pb-2 bg-gray-50 border-b">
          <CardTitle className="text-lg flex items-center">
            <Filter className="h-4 w-4 mr-2 text-blue-600" />
            Filters
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="text-sm font-medium mb-1 block text-gray-700">Warehouse</label>
              <Select
                value={selectedWarehouse}
                onValueChange={setSelectedWarehouse}
              >
                <SelectTrigger className="border-gray-300">
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
              <label className="text-sm font-medium mb-1 block text-gray-700">Customer</label>
              <Select
                value={selectedCustomer}
                onValueChange={setSelectedCustomer}
              >
                <SelectTrigger className="border-gray-300">
                  <SelectValue placeholder="All Customers" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">All Customers</SelectItem>
                  {customers.map((customer) => (
                    <SelectItem key={customer.customer_id} value={customer.customer_id}>
                      {customer.company_name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            
            <div>
              <label className="text-sm font-medium mb-1 block text-gray-700">Status</label>
              <Select
                value={selectedStatus}
                onValueChange={setSelectedStatus}
              >
                <SelectTrigger className="border-gray-300">
                  <SelectValue placeholder="All Statuses" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">All Statuses</SelectItem>
                  <SelectItem value="pending">Pending</SelectItem>
                  <SelectItem value="assigned">Assigned</SelectItem>
                  <SelectItem value="in_transit">In Transit</SelectItem>
                  <SelectItem value="delivered">Delivered</SelectItem>
                  <SelectItem value="cancelled">Cancelled</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div className="grid grid-cols-2 gap-2">
              <div>
                <label className="text-sm font-medium mb-1 block text-gray-700">Start Date</label>
                <Input
                  type="date"
                  value={dateRange.startDate}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setDateRange(prev => ({ ...prev, startDate: e.target.value }))}
                  className="border-gray-300"
                />
              </div>
              
              <div>
                <label className="text-sm font-medium mb-1 block text-gray-700">End Date</label>
                <Input
                  type="date"
                  value={dateRange.endDate}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setDateRange(prev => ({ ...prev, endDate: e.target.value }))}
                  className="border-gray-300"
                />
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
      
      {/* Order Tabs */}
      <Tabs defaultValue="all">
        <TabsList className="mb-4 bg-white border border-gray-200 rounded-md p-1">
          <TabsTrigger value="all" className="data-[state=active]:bg-blue-50 data-[state=active]:text-blue-700">All Orders</TabsTrigger>
          <TabsTrigger value="pending" className="data-[state=active]:bg-amber-50 data-[state=active]:text-amber-700">Pending</TabsTrigger>
          <TabsTrigger value="assigned" className="data-[state=active]:bg-blue-50 data-[state=active]:text-blue-700">Assigned</TabsTrigger>
          <TabsTrigger value="in_transit" className="data-[state=active]:bg-purple-50 data-[state=active]:text-purple-700">In Transit</TabsTrigger>
          <TabsTrigger value="delivered" className="data-[state=active]:bg-green-50 data-[state=active]:text-green-700">Delivered</TabsTrigger>
        </TabsList>
        
        <TabsContent value="all">
          <OrdersTable orders={orders} loading={loading} />
        </TabsContent>
        
        <TabsContent value="pending">
          <OrdersTable orders={orders.filter(o => o.status === 'pending')} loading={loading} />
        </TabsContent>
        
        <TabsContent value="assigned">
          <OrdersTable orders={orders.filter(o => o.status === 'assigned')} loading={loading} />
        </TabsContent>
        
        <TabsContent value="in_transit">
          <OrdersTable orders={orders.filter(o => o.status === 'in_transit')} loading={loading} />
        </TabsContent>
        
        <TabsContent value="delivered">
          <OrdersTable orders={orders.filter(o => o.status === 'delivered')} loading={loading} />
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default Orders;
