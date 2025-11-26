# Ingredient Tracking & Cross-Contamination Warnings

This document describes the detailed ingredient tracking system with cross-contamination warnings for MenuMate QR.

## Overview

The ingredient tracking system allows restaurants to:
- Track detailed ingredients for each menu item
- Automatically detect allergens from ingredients
- Identify cross-contamination risks between menu items
- Warn customers about potential allergen exposure

## Features

### 1. Ingredient Management
- **Ingredient Database**: Centralized ingredient library with allergen information
- **Preparation Areas**: Track where ingredients are prepared (grill, fryer, oven, etc.)
- **Quantity & Method**: Record quantity and preparation method for each ingredient
- **Auto-complete**: Search existing ingredients or create new ones

### 2. Automatic Allergen Detection
- Ingredients are tagged with allergen types
- Menu items automatically inherit allergens from their ingredients
- Manual allergen tags are merged with ingredient-based allergens
- Ensures comprehensive allergen coverage

### 3. Cross-Contamination Detection
The system automatically detects cross-contamination risks by checking:
- **Shared Allergens**: Items that share allergenic ingredients
- **Shared Preparation Areas**: Items prepared in the same area (e.g., same fryer)

### 4. Customer Warnings
- **Allergen Warnings**: Prominent display of allergens in menu items
- **Cross-Contamination Warnings**: Alerts when items may have cross-contamination risks
- **Detailed Information**: Expandable details showing which items share allergens/areas

## Usage

### Adding Ingredients to Menu Items

1. Navigate to a menu item's detail page
2. Click "Ingredients" button
3. Fill in the ingredient form:
   - **Ingredient Name**: Type to search existing or create new
   - **Allergen Type**: Select if ingredient contains allergens
   - **Preparation Area**: Where the ingredient is prepared
   - **Quantity**: Amount used (optional)
   - **Preparation Method**: How it's prepared (optional)
   - **Notes**: Additional information (optional)
4. Click "Add Ingredient"

### Viewing Cross-Contamination Warnings

1. On the ingredients page, warnings appear at the top if risks are detected
2. On public menus, warnings appear on menu item cards
3. Click "View Details" to see which items share allergens or preparation areas

## Technical Details

### Models

#### Ingredient
- `name`: Ingredient name (unique)
- `allergen_type`: Type of allergen (nuts, peanuts, shellfish, etc.)
- `preparation_area`: Where ingredient is prepared
- `notes`: Additional notes

#### MenuItemIngredient
- Join table linking menu items to ingredients
- `quantity`: Amount used
- `preparation_method`: How ingredient is prepared

### Methods

#### MenuItem
- `ingredient_allergens`: Returns list of allergens from ingredients
- `preparation_areas`: Returns list of preparation areas used
- `cross_contamination_risks(other_item)`: Checks risks with another item
- `cross_contamination_warnings(menu_items)`: Gets all warnings for item
- `has_cross_contamination_risk?`: Boolean check for any risks

### Allergen Types
- Tree Nuts
- Peanuts
- Shellfish
- Fish
- Eggs
- Milk/Dairy
- Soy
- Wheat/Gluten
- Sesame
- Sulfites

### Preparation Areas
- Grill
- Fryer
- Oven
- Stovetop
- Prep Station
- Salad Station
- Dessert Station
- Beverage Station
- Other

## Safety Features

1. **Automatic Allergen Detection**: Ingredients automatically update menu item allergens
2. **Comprehensive Tracking**: Every ingredient is tracked with allergen and preparation info
3. **Real-time Warnings**: Cross-contamination warnings appear immediately
4. **Customer Transparency**: Clear warnings help customers make informed decisions

## Best Practices

1. **Be Thorough**: Add all ingredients, even small amounts
2. **Update Regularly**: Keep ingredient lists current
3. **Check Warnings**: Review cross-contamination warnings regularly
4. **Train Staff**: Ensure kitchen staff understand preparation areas
5. **Verify Accuracy**: Double-check allergen information

## Example Scenarios

### Scenario 1: Shared Fryer
- Item A: French Fries (prepared in fryer)
- Item B: Fried Chicken (prepared in same fryer)
- **Warning**: Both items prepared in fryer - potential cross-contamination

### Scenario 2: Shared Allergen
- Item A: Contains peanuts (peanut sauce)
- Item B: Contains peanuts (peanut butter)
- **Warning**: Both items contain peanuts

### Scenario 3: Multiple Risks
- Item A: Contains nuts, prepared on grill
- Item B: Contains nuts, prepared on grill
- **Warning**: Both items contain nuts AND share preparation area

## Integration

The ingredient tracking system integrates with:
- **Allergen System**: Automatically updates menu item allergens
- **Public Menus**: Displays warnings to customers
- **Menu Item Management**: Easy access from menu item pages
- **Analytics**: Can track ingredient usage across menu

