// src/components/ShipmentMap.tsx
import React, { useEffect, useRef, useState } from 'react';
import { Loader } from '@googlemaps/js-api-loader';

interface Location {
  lat: number;
  lng: number;
  name: string;
  type: 'warehouse' | 'customer' | 'vehicle';
  info?: string;
}

interface RouteInfo {
  origin: Location;
  stops: Location[];
  destination: Location;
}

interface ShipmentMapProps {
  routes: RouteInfo[];
  vehicles?: { id: string; lat: number; lng: number; info: string }[];
  center?: { lat: number; lng: number };
  zoom?: number;
}

const ShipmentMap: React.FC<ShipmentMapProps> = ({
  routes,
  vehicles = [],
  center = { lat: 52.9399, lng: -106.4509 }, // Default center at Saskatchewan
  zoom = 6
}) => {
  const mapRef = useRef<HTMLDivElement>(null);
  const googleMapRef = useRef<google.maps.Map | null>(null);
  const [mapLoaded, setMapLoaded] = useState(false);

  // Load Google Maps API
  useEffect(() => {
    const apiKey = process.env.REACT_APP_GOOGLE_MAPS_API_KEY || '';
    
    const loader = new Loader({
      apiKey,
      version: 'weekly',
      libraries: ['places', 'routes']
    });

    loader.load().then(() => {
      setMapLoaded(true);
    }).catch(err => {
      console.error('Error loading Google Maps API:', err);
    });
  }, []);

  // Initialize map when API is loaded and div is available
  useEffect(() => {
    if (!mapLoaded || !mapRef.current) return;

    const mapOptions: google.maps.MapOptions = {
      center,
      zoom,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      mapTypeControl: true,
      streetViewControl: false,
      fullscreenControl: true,
      styles: [
        {
          featureType: 'poi',
          elementType: 'labels',
          stylers: [{ visibility: 'off' }]
        }
      ]
    };

    googleMapRef.current = new google.maps.Map(mapRef.current, mapOptions);
  }, [mapLoaded, center, zoom]);

  // Render routes when map is ready and routes data changes
  useEffect(() => {
    if (!mapLoaded || !googleMapRef.current) return;

    const map = googleMapRef.current;
    const directionsService = new google.maps.DirectionsService();
    const directionsRenderers: google.maps.DirectionsRenderer[] = [];
    const infoWindows: google.maps.InfoWindow[] = [];
    const markers: google.maps.Marker[] = [];

    // Clear previous routes and markers
    directionsRenderers.forEach(renderer => renderer.setMap(null));
    infoWindows.forEach(window => window.close());
    markers.forEach(marker => marker.setMap(null));

    // Create a bounds object to fit all markers
    const bounds = new google.maps.LatLngBounds();

    // Add warehouse markers with a different icon
    routes.forEach((route, routeIndex) => {
      // Use different colors for each route
      const routeColors = ['#4285F4', '#DB4437', '#F4B400', '#0F9D58', '#AB47BC'];
      const routeColor = routeColors[routeIndex % routeColors.length];

      // Add warehouse marker
      const warehouseMarker = new google.maps.Marker({
        position: { lat: route.origin.lat, lng: route.origin.lng },
        map,
        title: route.origin.name,
        icon: {
          path: google.maps.SymbolPath.CIRCLE,
          scale: 10,
          fillColor: '#4285F4',
          fillOpacity: 1,
          strokeWeight: 2,
          strokeColor: '#FFFFFF'
        },
        zIndex: 10
      });
      
      markers.push(warehouseMarker);
      bounds.extend(warehouseMarker.getPosition()!);

      const warehouseInfo = new google.maps.InfoWindow({
        content: `<div><strong>${route.origin.name}</strong><p>Warehouse</p></div>`
      });
      
      warehouseMarker.addListener('click', () => {
        infoWindows.forEach(window => window.close());
        warehouseInfo.open(map, warehouseMarker);
      });
      
      infoWindows.push(warehouseInfo);

      // Add customer location markers
      route.stops.forEach((stop, index) => {
        const customerMarker = new google.maps.Marker({
          position: { lat: stop.lat, lng: stop.lng },
          map,
          title: stop.name,
          label: {
            text: (index + 1).toString(),
            color: 'white'
          },
          icon: {
            path: google.maps.SymbolPath.CIRCLE,
            scale: 8,
            fillColor: routeColor,
            fillOpacity: 1,
            strokeWeight: 2,
            strokeColor: '#FFFFFF'
          },
          zIndex: 5
        });
        
        markers.push(customerMarker);
        bounds.extend(customerMarker.getPosition()!);

        const customerInfo = new google.maps.InfoWindow({
          content: `<div><strong>${stop.name}</strong><p>Stop #${index + 1}</p><p>${stop.info || ''}</p></div>`
        });
        
        customerMarker.addListener('click', () => {
          infoWindows.forEach(window => window.close());
          customerInfo.open(map, customerMarker);
        });
        
        infoWindows.push(customerInfo);
      });

      // Create waypoints for the route
      const waypoints = route.stops.map(stop => ({
        location: new google.maps.LatLng(stop.lat, stop.lng),
        stopover: true
      }));

      // Request directions from Google
      directionsService.route({
        origin: new google.maps.LatLng(route.origin.lat, route.origin.lng),
        destination: new google.maps.LatLng(route.stops[route.stops.length - 1].lat, route.stops[route.stops.length - 1].lng),
        waypoints: waypoints.slice(0, -1), // All but the last stop, which is the destination
        optimizeWaypoints: false, // We're assuming the order is already optimized
        travelMode: google.maps.TravelMode.DRIVING
      }, (result, status) => {
        if (status === google.maps.DirectionsStatus.OK && result) {
          const directionsRenderer = new google.maps.DirectionsRenderer({
            map,
            directions: result,
            suppressMarkers: true, // We're adding our own markers
            polylineOptions: {
              strokeColor: routeColor,
              strokeWeight: 5,
              strokeOpacity: 0.7
            }
          });
          
          directionsRenderers.push(directionsRenderer);
        } else {
          console.error(`Error getting directions for route ${routeIndex}:`, status);
        }
      });
    });

    // Add vehicle location markers
    vehicles.forEach(vehicle => {
      const vehicleMarker = new google.maps.Marker({
        position: { lat: vehicle.lat, lng: vehicle.lng },
        map,
        title: `Vehicle ${vehicle.id}`,
        icon: {
          path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW,
          scale: 6,
          fillColor: '#000000',
          fillOpacity: 1,
          strokeWeight: 2,
          strokeColor: '#FFFFFF',
          rotation: 0 // You can calculate this based on heading if available
        },
        zIndex: 15
      });
      
      markers.push(vehicleMarker);
      bounds.extend(vehicleMarker.getPosition()!);

      const vehicleInfo = new google.maps.InfoWindow({
        content: `<div><strong>Vehicle ${vehicle.id}</strong><p>${vehicle.info}</p></div>`
      });
      
      vehicleMarker.addListener('click', () => {
        infoWindows.forEach(window => window.close());
        vehicleInfo.open(map, vehicleMarker);
      });
      
      infoWindows.push(vehicleInfo);
    });

    // Fit the map to show all markers
    if (markers.length > 0) {
      map.fitBounds(bounds);
      
      // Adjust zoom if too close
      const listener = google.maps.event.addListener(map, 'idle', () => {
        if (map.getZoom()! > 16) {
          map.setZoom(16);
        }
        google.maps.event.removeListener(listener);
      });
    }

    // Clean up function
    return () => {
      directionsRenderers.forEach(renderer => renderer.setMap(null));
      infoWindows.forEach(window => window.close());
      markers.forEach(marker => marker.setMap(null));
    };
  }, [routes, vehicles, mapLoaded]);

  return (
    <div className="w-full h-full">
      <div ref={mapRef} style={{ width: '100%', height: '100%', minHeight: '400px' }} />
    </div>
  );
};

export default ShipmentMap;

// Usage Example Component
// src/components/ShipmentRouteViewer.tsx
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import ShipmentMap from './ShipmentMap';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui';

interface ShipmentRouteViewerProps {
  shipmentId: number;
}

const ShipmentRouteViewer: React.FC<ShipmentRouteViewerProps> = ({ shipmentId }) => {
  const [routeData, setRouteData] = useState<any>(null);
  const [vehicleLocations, setVehicleLocations] = useState<any[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    const fetchRouteData = async () => {
      setLoading(true);
      try {
        // Fetch shipment route data
        const { data } = await axios.get(`/api/shipments/${shipmentId}/route`);
        setRouteData(data);
        
        // If the shipment has assigned vehicles, fetch their current locations
        if (data.truckId) {
          const vehicleRes = await axios.get(`/api/vehicles/${data.truckId}/location`);
          if (vehicleRes.data) {
            setVehicleLocations([{
              id: data.truckId,
              lat: vehicleRes.data.latitude,
              lng: vehicleRes.data.longitude,
              info: `${vehicleRes.data.status} - Last updated: ${new Date(vehicleRes.data.timestamp).toLocaleTimeString()}`
            }]);
          }
        }
        
        setError(null);
      } catch (err) {
        console.error('Error fetching route data:', err);
        setError('Unable to load route data. Please try again later.');
      } finally {
        setLoading(false);
      }
    };
    
    fetchRouteData();
    
    // Refresh vehicle locations every 2 minutes
    const intervalId = setInterval(() => {
      if (routeData?.truckId) {
        axios.get(`/api/vehicles/${routeData.truckId}/location`)
          .then(res => {
            if (res.data) {
              setVehicleLocations([{
                id: routeData.truckId,
                lat: res.data.latitude,
                lng: res.data.longitude,
                info: `${res.data.status} - Last updated: ${new Date(res.data.timestamp).toLocaleTimeString()}`
              }]);
            }
          })
          .catch(err => console.error('Error updating vehicle location:', err));
      }
    }, 120000);
    
    return () => clearInterval(intervalId);
  }, [shipmentId]);
  
  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Shipment Route</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
          </div>
        </CardContent>
      </Card>
    );
  }
  
  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Shipment Route</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-red-500">{error}</div>
        </CardContent>
      </Card>
    );
  }
  
  if (!routeData) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Shipment Route</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-gray-500">No route data available for this shipment.</div>
        </CardContent>
      </Card>
    );
  }
  
  // Transform the route data to the format expected by ShipmentMap
  const mapRoutes = [{
    origin: {
      lat: routeData.warehouse.latitude,
      lng: routeData.warehouse.longitude,
      name: routeData.warehouse.name,
      type: 'warehouse'
    },
    stops: routeData.stops.map((stop: any) => ({
      lat: stop.latitude,
      lng: stop.longitude,
      name: stop.customerName,
      type: 'customer',
      info: `Order: ${stop.orderNumber}<br>Weight: ${stop.weight.toLocaleString()} kg`
    })),
    destination: routeData.stops[routeData.stops.length - 1] 
      ? {
          lat: routeData.stops[routeData.stops.length - 1].latitude,
          lng: routeData.stops[routeData.stops.length - 1].longitude,
          name: routeData.stops[routeData.stops.length - 1].customerName,
          type: 'customer'
        }
      : {
          lat: routeData.warehouse.latitude,
          lng: routeData.warehouse.longitude,
          name: routeData.warehouse.name,
          type: 'warehouse'
        }
  }];
  
  return (
    <Card>
      <CardHeader>
        <CardTitle>Shipment Route - {routeData.shipmentNumber}</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-96">
          <ShipmentMap routes={mapRoutes} vehicles={vehicleLocations} />
        </div>
        <div className="mt-4">
          <h3 className="font-medium mb-2">Route Summary</h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-sm text-gray-500">Origin</p>
              <p>{routeData.warehouse.name}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Destination</p>
              <p>{routeData.stops[routeData.stops.length - 1]?.customerName || routeData.warehouse.name}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Total Distance</p>
              <p>{routeData.totalDistance.toFixed(1)} km</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Estimated Travel Time</p>
              <p>{Math.floor(routeData.estimatedTravelTime / 60)} hr {routeData.estimatedTravelTime % 60} min</p>
            </div>
          </div>
          
          <h3 className="font-medium mt-4 mb-2">Stops ({routeData.stops.length})</h3>
          <ul className="space-y-2">
            {routeData.stops.map((stop: any, index: number) => (
              <li key={index} className="border rounded p-2 flex justify-between items-center">
                <div>
                  <div className="font-medium">{index + 1}. {stop.customerName}</div>
                  <div className="text-sm text-gray-500">{stop.address}</div>
                </div>
                <div className="text-right">
                  <div className="text-sm">{stop.estimatedArrival}</div>
                  <div className="text-sm text-gray-500">{stop.orderNumber}</div>
                </div>
              </li>
            ))}
          </ul>
        </div>
      </CardContent>
    </Card>
  );
};

export default ShipmentRouteViewer;