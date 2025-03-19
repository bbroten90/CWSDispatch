// src/components/ProductSelector.tsx
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  Button, 
  Card, 
  CardContent, 
  CardHeader, 
  CardTitle,
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
  DialogClose,
  Input
} from './ui';
import { Plus, Trash2, Search, AlertTriangle, Package, Scale, Info, Truck } from 'lucide-react';
import SearchableSelect from './SearchableSelect';
import HazardWarning from './HazardWarning';

interface Product {
  product_id: string;
  name: string;
  description: string;
  weight_lbs: number; // Changed from weight_kg to weight_lbs
  requires_heating: boolean;
  requires_refrigeration: boolean;
  hazard_code?: string;
  hazard_description1?: string;
  hazard_description2?: string;
  hazard_description3?: string;
  quantity_on_hand?: number;
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

interface ProductSelectorProps {
  warehouseId: string;
  products: OrderProduct[];
  onProductsChange: (products: OrderProduct[]) => void;
}

const ProductSelector: React.FC<ProductSelectorProps> = ({ 
  warehouseId, 
  products, 
  onProductsChange 
}) => {
  const [allProducts, setAllProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedProductId, setSelectedProductId] = useState<string>('');
  const [quantity, setQuantity] = useState<number>(1);
  const [showDialog, setShowDialog] = useState(false);
  
  // Load all products
  useEffect(() => {
    const fetchProducts = async () => {
      try {
        setLoading(true);
        const response = await axios.get('/api/products', {
          headers: {
            'x-internal-request': 'true'
          }
        });
        if (response.data.success && response.data.data) {
          setAllProducts(response.data.data);
        }
      } catch (error) {
        console.error('Error fetching products:', error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchProducts();
  }, []);
  
  // Get product details by ID
  const getProductById = (productId: string): Product | undefined => {
    return allProducts.find(p => p.product_id === productId);
  };
  
  // Add product to order
  const handleAddProduct = () => {
    if (!selectedProductId || quantity <= 0) return;
    
    const product = getProductById(selectedProductId);
    if (!product) return;
    
    // No need to convert weight - it's already in lbs
    const newOrderProduct: OrderProduct = {
      product_id: product.product_id,
      name: product.name,
      description: product.description || '',
      weight_lbs: product.weight_lbs, // Use weight_lbs directly
      requires_heating: product.requires_heating,
      requires_refrigeration: product.requires_refrigeration,
      hazard_code: product.hazard_code,
      hazard_description1: product.hazard_description1,
      hazard_description2: product.hazard_description2,
      hazard_description3: product.hazard_description3,
      quantity: quantity,
      quantity_on_hand: product.quantity_on_hand
    };
    
    // Check if product already exists in the list
    const existingIndex = products.findIndex(p => p.product_id === product.product_id);
    
    if (existingIndex >= 0) {
      // Update quantity if product already exists
      const updatedProducts = [...products];
      updatedProducts[existingIndex].quantity += quantity;
      onProductsChange(updatedProducts);
    } else {
      // Add new product
      onProductsChange([...products, newOrderProduct]);
    }
    
    // Reset form
    setSelectedProductId('');
    setQuantity(1);
    setShowDialog(false);
  };
  
  // Remove product from order
  const handleRemoveProduct = (productId: string) => {
    const updatedProducts = products.filter(p => p.product_id !== productId);
    onProductsChange(updatedProducts);
  };
  
  // Calculate total weight
  const totalWeight = products.reduce((sum, product) => {
    return sum + (product.weight_lbs * product.quantity);
  }, 0);
  
  return (
    <div>
      <Card className="shadow-sm border border-gray-200">
        <CardHeader className="pb-2 bg-gray-50 border-b">
          <CardTitle className="text-lg flex items-center justify-between">
            <div className="flex items-center">
              <Package className="h-5 w-5 mr-2 text-blue-600" />
              <span>Products</span>
            </div>
            <Dialog open={showDialog} onOpenChange={setShowDialog}>
              <DialogTrigger asChild>
                <Button className="bg-blue-600 hover:bg-blue-700 text-white px-2 py-1 text-sm flex items-center">
                  <Plus className="h-4 w-4 mr-2" />
                  Add Product
                </Button>
              </DialogTrigger>
              <DialogContent className="sm:max-w-[600px]">
                <DialogHeader className="border-b pb-3">
                  <DialogTitle className="flex items-center text-xl">
                    <Package className="h-5 w-5 mr-2 text-blue-600" />
                    Add Product to Order
                  </DialogTitle>
                </DialogHeader>
                
                <div className="grid gap-5 py-4">
                  <div className="bg-blue-50 p-4 rounded-md border border-blue-100">
                    <label className="text-sm font-medium mb-2 block text-blue-800">Select Product</label>
                    <SearchableSelect
                      options={allProducts.map(product => ({
                        value: product.product_id,
                        label: `${product.product_id} - ${product.name}`,
                        searchText: product.description
                      }))}
                      value={selectedProductId}
                      onValueChange={setSelectedProductId}
                      placeholder="Search by product ID or description"
                      required
                    />
                  </div>
                  
                  {selectedProductId && (
                    <div className="border rounded-md p-4 bg-gray-50 shadow-sm">
                      <h4 className="font-medium mb-3 text-gray-700 border-b pb-2 flex items-center">
                        <Info className="h-4 w-4 mr-2 text-blue-600" />
                        Product Details
                      </h4>
                      {(() => {
                        const product = getProductById(selectedProductId);
                        if (!product) return null;
                        
                        return (
                          <div className="space-y-3 text-sm">
                            <div className="grid grid-cols-2 gap-4">
                              <div>
                                <p className="mb-2">
                                  <span className="font-medium text-gray-700">Product ID:</span>{' '}
                                  <span className="bg-gray-100 px-2 py-1 rounded">{product.product_id}</span>
                                </p>
                                <p className="mb-2">
                                  <span className="font-medium text-gray-700">Name:</span>{' '}
                                  {product.name}
                                </p>
                                <p className="mb-2">
                                  <span className="font-medium text-gray-700">Description:</span>{' '}
                                  {product.description || 'No description available'}
                                </p>
                              </div>
                              <div>
                                <p className="mb-2 flex items-center">
                                  <Scale className="h-4 w-4 mr-1 text-gray-600" />
                                  <span className="font-medium text-gray-700">Weight:</span>{' '}
                                  <span className="ml-1 font-semibold">{product.weight_lbs.toFixed(2)} lbs</span>
                                </p>
                                <p className="mb-2">
                                  <span className="font-medium text-gray-700">Quantity on Hand:</span>{' '}
                                  <span className="font-semibold">
                                    {product.quantity_on_hand !== undefined 
                                      ? product.quantity_on_hand 
                                      : 'Unknown'}
                                  </span>
                                </p>
                                
                                {(product.requires_heating || product.requires_refrigeration) && (
                                  <div className="mt-3 p-2 bg-amber-50 rounded border border-amber-200">
                                    <p className="font-medium text-amber-800 mb-1">Special Handling:</p>
                                    {product.requires_heating && (
                                      <p className="text-orange-600 flex items-center text-sm">
                                        <AlertTriangle className="h-4 w-4 mr-1" />
                                        Requires Heating
                                      </p>
                                    )}
                                    {product.requires_refrigeration && (
                                      <p className="text-blue-600 flex items-center text-sm">
                                        <AlertTriangle className="h-4 w-4 mr-1" />
                                        Requires Refrigeration
                                      </p>
                                    )}
                                  </div>
                                )}
                              </div>
                            </div>
                            
                            {product.hazard_code && (
                              <div className="mt-2 p-3 bg-red-50 rounded border border-red-200">
                                <p className="font-medium text-red-800 mb-1">Hazard Information:</p>
                                <HazardWarning
                                  hazardCode={product.hazard_code}
                                  hazardDescription1={product.hazard_description1}
                                  hazardDescription2={product.hazard_description2}
                                  hazardDescription3={product.hazard_description3}
                                />
                              </div>
                            )}
                          </div>
                        );
                      })()}
                    </div>
                  )}
                  
                  <div className="bg-green-50 p-4 rounded-md border border-green-100">
                    <label className="text-sm font-medium mb-2 block text-green-800">Quantity to Add</label>
                    <div className="flex items-center">
                      <Input
                        type="number"
                        value={quantity}
                        onChange={(e) => setQuantity(parseInt(e.target.value) || 0)}
                        min="1"
                        required
                        className="w-32 mr-3"
                      />
                      <span className="text-sm text-gray-600">
                        {selectedProductId && getProductById(selectedProductId)?.quantity_on_hand !== undefined && (
                          <>Available: {getProductById(selectedProductId)?.quantity_on_hand}</>
                        )}
                      </span>
                    </div>
                  </div>
                </div>
                
                <DialogFooter className="border-t pt-3">
                  <DialogClose asChild>
                    <Button variant="outlined" className="mr-2">Cancel</Button>
                  </DialogClose>
                  <Button 
                    onClick={handleAddProduct} 
                    disabled={!selectedProductId || quantity <= 0}
                    className="bg-green-600 hover:bg-green-700"
                  >
                    <Plus className="h-4 w-4 mr-2" />
                    Add to Order
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          {products.length === 0 ? (
            <div className="text-center py-8 text-gray-500 bg-gray-50 rounded-b-lg">
              <Package className="h-12 w-12 mx-auto mb-3 text-gray-300" />
              <p>No products added to this order yet</p>
              <Button 
                className="bg-blue-600 hover:bg-blue-700 text-white px-2 py-1 text-sm flex items-center mt-3 inline-flex"
                onClick={() => setShowDialog(true)}
              >
                <Plus className="h-4 w-4 mr-2" />
                Add Product
              </Button>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full border-collapse">
                <thead>
                  <tr className="bg-gray-50 border-b">
                    <th className="text-left p-3 text-gray-600 font-medium">Product ID</th>
                    <th className="text-left p-3 text-gray-600 font-medium">Description</th>
                    <th className="text-left p-3 text-gray-600 font-medium">Hazard</th>
                    <th className="text-right p-3 text-gray-600 font-medium">Weight (lbs)</th>
                    <th className="text-right p-3 text-gray-600 font-medium">Quantity</th>
                    <th className="text-right p-3 text-gray-600 font-medium">Total Weight</th>
                    <th className="p-3"></th>
                  </tr>
                </thead>
                <tbody>
                  {products.map((product) => (
                    <tr key={product.product_id} className="border-b hover:bg-gray-50">
                      <td className="p-3 font-mono text-sm">{product.product_id}</td>
                      <td className="p-3">
                        <div>
                          <div className="font-medium">{product.name}</div>
                          <div className="text-sm text-gray-500">{product.description}</div>
                          <div className="flex flex-wrap gap-1 mt-1">
                            {product.requires_heating && (
                              <span className="text-orange-600 text-xs bg-orange-50 px-2 py-0.5 rounded-full border border-orange-200">
                                Heating
                              </span>
                            )}
                            {product.requires_refrigeration && (
                              <span className="text-blue-600 text-xs bg-blue-50 px-2 py-0.5 rounded-full border border-blue-200">
                                Refrigeration
                              </span>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="p-3">
                        {product.hazard_code ? (
                          <HazardWarning
                            hazardCode={product.hazard_code}
                            hazardDescription1={product.hazard_description1}
                            hazardDescription2={product.hazard_description2}
                            hazardDescription3={product.hazard_description3}
                          />
                        ) : (
                          <span className="text-gray-400 text-xs">None</span>
                        )}
                      </td>
                      <td className="p-3 text-right font-mono">{product.weight_lbs.toFixed(2)}</td>
                      <td className="p-3 text-right font-mono">{product.quantity}</td>
                      <td className="p-3 text-right font-mono font-medium">{(product.weight_lbs * product.quantity).toFixed(2)}</td>
                      <td className="p-3">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => handleRemoveProduct(product.product_id)}
                          className="hover:bg-red-50 hover:text-red-600"
                        >
                          <Trash2 className="h-4 w-4 text-red-500" />
                        </Button>
                      </td>
                    </tr>
                  ))}
                  <tr className="bg-gray-50 font-medium">
                    <td colSpan={5} className="p-3 text-right">
                      Total Weight:
                    </td>
                    <td className="p-3 text-right font-mono text-blue-700">
                      {totalWeight.toFixed(2)} lbs
                    </td>
                    <td></td>
                  </tr>
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default ProductSelector;
