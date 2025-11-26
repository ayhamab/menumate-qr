# Multi-Brand Menu Support for Virtual Restaurants

This document describes the multi-brand menu support feature that allows restaurants to operate multiple virtual restaurant brands from the same kitchen.

## Overview

The multi-brand feature enables ghost kitchens, cloud kitchens, and virtual restaurant concepts to manage multiple distinct restaurant brands from a single physical location. Each brand can have its own menu, branding, QR codes, and promotions while sharing the same kitchen, ingredients, and management system.

## Features

### 1. Brand Management
- **Multiple Brands**: Create unlimited virtual restaurant brands per restaurant
- **Brand-Specific Menus**: Each brand has its own menu items
- **Custom Branding**: Brand colors, logos, and descriptions
- **Active/Inactive Status**: Control brand visibility
- **Display Ordering**: Organize brands in preferred order

### 2. Menu Item Assignment
- **Brand-Specific Items**: Assign menu items to specific brands
- **Shared Items**: Menu items without a brand appear in main restaurant menu
- **Easy Assignment**: Select brand when creating/editing menu items
- **Brand Filtering**: Filter menu items by brand in management interface

### 3. Brand-Specific QR Codes
- **Unique QR Codes**: Each brand has its own QR code
- **Brand Menu URLs**: Direct links to brand-specific menus
- **QR Code Downloads**: PNG and SVG formats available
- **Automatic Generation**: QR codes generated on demand

### 4. Public Brand Menus
- **Brand Menu Pages**: Public-facing menus for each brand
- **Brand Theming**: Custom colors and branding applied
- **Language Support**: Multi-language menu support per brand
- **Promotions**: Brand-specific promotions and discounts

### 5. Shared Resources
- **Same Kitchen**: All brands share the same physical location
- **Shared Ingredients**: Ingredients tracked across all brands
- **Unified Management**: Manage all brands from one dashboard
- **Cross-Brand Analytics**: Track performance across brands

## Usage

### Creating a Brand

1. Navigate to restaurant dashboard
2. Click "Virtual Brands" in Quick Actions
3. Click "New Brand"
4. Fill in brand details:
   - Name (required)
   - Description (optional)
   - Brand Color (hex code, optional)
   - Logo URL (optional)
   - Display Order
   - Active Status
5. Click "Create Brand"

### Assigning Menu Items to Brands

1. When creating/editing a menu item
2. Select a brand from the "Virtual Brand" dropdown
3. Leave blank for main restaurant menu
4. Save the menu item

### Viewing Brand Menus

1. Navigate to brand detail page
2. View brand-specific menu items
3. Access brand QR code
4. View brand statistics

### Public Brand Menu

- URL format: `/brands/:id/menu`
- Brand-specific theming
- Language toggle support
- Seasonal menu filtering
- Promotion display

## Data Model

### Brand Model
- `restaurant_id`: Parent restaurant
- `name`: Brand name
- `description`: Brand description
- `logo_url`: Logo image URL
- `brand_color`: Hex color code
- `active`: Active status
- `display_order`: Display ordering

### Menu Item Association
- `brand_id`: Optional brand assignment
- `null` = Main restaurant menu
- `present` = Brand-specific menu

### QR Code Association
- `brand_id`: Optional brand assignment
- Brand-specific QR codes link to brand menus
- Restaurant QR codes link to main menu

## Benefits

### For Ghost Kitchens
- **Multiple Concepts**: Operate pizza, burger, and taco brands from one kitchen
- **Separate Menus**: Each brand has distinct menu offerings
- **Independent Branding**: Different logos, colors, and styles
- **Targeted Marketing**: Brand-specific promotions and campaigns

### For Cloud Kitchens
- **Virtual Restaurants**: Launch new concepts without physical locations
- **Menu Flexibility**: Test different menu concepts easily
- **Shared Resources**: Efficient use of kitchen space and ingredients
- **Scalability**: Add new brands as needed

### For Restaurant Chains
- **Concept Testing**: Test new concepts before full rollout
- **Market Segmentation**: Different brands for different markets
- **Menu Variations**: Regional or demographic-specific menus
- **Brand Portfolio**: Manage multiple concepts from one system

## Example Use Cases

### Example 1: Ghost Kitchen
**Restaurant**: "Downtown Kitchen"
- **Brand 1**: "Pizza Express" - Italian pizzas
- **Brand 2**: "Burger House" - Gourmet burgers
- **Brand 3**: "Taco Fiesta" - Mexican cuisine

All three brands operate from the same kitchen but have separate menus, QR codes, and customer-facing identities.

### Example 2: Cloud Kitchen
**Restaurant**: "Cloud Kitchen Hub"
- **Brand 1**: "Healthy Bowls" - Health-focused meals
- **Brand 2**: "Comfort Food Co" - Classic comfort foods
- **Brand 3**: "Vegan Delight" - Plant-based options

Each brand targets different customer segments while sharing kitchen infrastructure.

## Technical Details

### Routes
- `/restaurants/:restaurant_id/brands` - Brand management
- `/brands/:id/menu` - Public brand menu
- `/restaurants/:restaurant_id/brands/:id/qr_code_png` - QR code PNG
- `/restaurants/:restaurant_id/brands/:id/qr_code_svg` - QR code SVG

### Controllers
- `BrandsController` - Brand CRUD operations
- `BrandsController#menu` - Public brand menu display
- `MenuItemsController` - Updated to support brand assignment

### Models
- `Brand` - Brand model with restaurant association
- `MenuItem` - Updated with optional brand association
- `QrCode` - Updated with optional brand association
- `Promotion` - Updated with optional brand association

## Best Practices

1. **Clear Brand Identity**: Use distinct names, colors, and descriptions
2. **Menu Differentiation**: Ensure brands have unique menu offerings
3. **Consistent Branding**: Apply brand colors consistently
4. **Active Management**: Keep inactive brands hidden
5. **Display Ordering**: Organize brands by priority or popularity

## Future Enhancements

- Brand-specific analytics
- Cross-brand menu item sharing
- Brand templates
- Bulk brand operations
- Brand performance comparison

