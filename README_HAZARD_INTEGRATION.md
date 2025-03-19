# Hazard Information Integration

This document explains the changes made to integrate hazard information into the dispatch dashboard.

## Overview

The system now displays hazard information for products in orders. This is important for safety and compliance when transporting hazardous materials.

## Changes Made

### 1. Backend API Endpoints

New controllers and routes have been added to access customer, product, and hazard information:

- `/api/customers` - Access customer data
- `/api/products` - Access product data
- `/api/hazards` - Access hazard data

These endpoints allow the frontend to retrieve detailed information about customers, products, and hazards.

### 2. Order Model Enhancement

The order model has been enhanced to include product and hazard information when retrieving orders:

- `getOrderWithShipmentDetails` now includes product and hazard information
- New `getOrdersWithProductInfo` function that joins orders with products and hazards

This ensures that when orders are retrieved, they include all relevant product and hazard information.

### 3. Frontend Components

A new `HazardWarning` component has been created to display hazard information:

- Shows hazard code with a warning icon
- Displays detailed hazard descriptions in a tooltip on hover
- Uses a yellow background to highlight hazardous materials

### 4. Orders Page Update

The Orders page has been updated to display hazard information:

- Added a new "Hazard" column to the orders table
- Displays hazard warnings for products with hazard codes
- Shows "None" for products without hazard codes

## How It Works

1. When the Orders page loads, it fetches orders from the backend
2. The backend joins orders with products and hazards
3. The frontend displays hazard warnings for products with hazard codes

## Benefits

- Improved safety awareness for dispatchers and drivers
- Better compliance with transportation regulations
- Clear visual indication of hazardous materials

## Next Steps

- Add filtering by hazard type
- Enhance the order creation form to select products and show hazard warnings
- Add detailed hazard information to the order details page
