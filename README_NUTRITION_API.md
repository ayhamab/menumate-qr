# Nutrition API Integration

This document describes the nutrition API integration for MenuMate QR using Edamam's Nutrition Analysis API.

## Overview

The nutrition API integration automatically calculates and displays detailed nutritional information for menu items, including calories, macronutrients (protein, carbs, fat), and micronutrients (fiber, sugar, sodium, cholesterol).

## Features

### 1. Automatic Nutrition Calculation
- **API Integration**: Uses Edamam Nutrition Analysis API
- **Ingredient-Based**: Calculates nutrition from menu item ingredients
- **Natural Language**: Can process menu item names and descriptions
- **Comprehensive Data**: Provides detailed nutritional breakdown

### 2. Nutrition Display
- **Menu Item Pages**: Full nutrition facts display
- **Public Menus**: Calorie and macro badges on menu cards
- **Summary Cards**: Quick nutrition overview
- **Detailed View**: Complete nutrition breakdown

### 3. Data Management
- **Automatic Updates**: Fetch latest nutrition data from API
- **Manual Override**: Edit nutrition values if needed
- **Last Updated**: Track when nutrition was last calculated
- **API Provider**: Track which API was used

## Setup

### 1. Get Edamam API Credentials

1. Sign up at [Edamam Developer Portal](https://developer.edamam.com/)
2. Create a new application
3. Get your `APP_ID` and `APP_KEY`
4. Add to your `.env` file:

```bash
EDAMAM_APP_ID=your_app_id_here
EDAMAM_APP_KEY=your_app_key_here
```

### 2. API Limits

- **Free Tier**: Limited requests per day
- **Paid Plans**: Higher limits available
- **Rate Limiting**: Be mindful of API rate limits

## Usage

### Calculating Nutrition

1. Navigate to a menu item's detail page
2. Click "Calculate Nutrition" button
3. System fetches nutrition data from Edamam API
4. Review and save the calculated values

### How It Works

1. **Query Building**: System builds query from:
   - Menu item ingredients (if available)
   - Menu item name and description
   - Ingredient quantities (if specified)

2. **API Request**: Sends request to Edamam API with:
   - Natural language description
   - Ingredient list
   - Quantities (if available)

3. **Data Extraction**: Extracts nutrition values:
   - Calories
   - Protein (grams)
   - Carbohydrates (grams)
   - Fat (grams)
   - Fiber (grams)
   - Sugar (grams)
   - Sodium (milligrams)
   - Cholesterol (milligrams)

4. **Storage**: Saves nutrition data to menu item

## Nutrition Fields

### Macronutrients
- **Calories**: Total energy (kcal)
- **Protein**: Protein content (grams)
- **Carbohydrates**: Total carbs (grams)
- **Fat**: Total fat (grams)

### Micronutrients
- **Fiber**: Dietary fiber (grams)
- **Sugar**: Total sugars (grams)
- **Sodium**: Sodium content (milligrams)
- **Cholesterol**: Cholesterol content (milligrams)

## Display Locations

### 1. Menu Item Detail Page
- Full nutrition facts panel
- Color-coded nutrition cards
- Last updated timestamp
- Calculate/Recalculate button

### 2. Public Menu Cards
- Calorie badge
- Macro summary (P/C/F)
- Quick nutrition overview

### 3. Menu Item List
- Nutrition indicators
- Calorie display

## API Service

The `NutritionApiService` handles:
- API authentication
- Query building
- Request handling
- Response parsing
- Error handling

### Methods

- `fetch_nutrition`: Fetches nutrition using ingredient-based query
- `fetch_nutrition_natural_language`: Uses natural language processing

## Best Practices

1. **Add Ingredients First**: More accurate results with detailed ingredients
2. **Include Quantities**: Specify ingredient quantities for better accuracy
3. **Review Results**: Always review calculated values before saving
4. **Update Regularly**: Recalculate if menu items change
5. **Monitor API Usage**: Track API calls to stay within limits

## Error Handling

The system handles:
- Missing API credentials
- API timeouts
- Invalid responses
- Network errors
- Rate limiting

Errors are displayed to users with helpful messages.

## Alternative APIs

The system is designed to support multiple nutrition APIs:
- Edamam (current)
- Nutritionix
- USDA FoodData Central
- FatSecret Platform API

To switch APIs, update the `NutritionApiService` class.

## Example

### Menu Item: "Grilled Chicken Salad"

**Ingredients:**
- 200g chicken breast
- 100g mixed greens
- 50g tomatoes
- 30g olive oil

**Calculated Nutrition:**
- Calories: 450
- Protein: 45g
- Carbs: 8g
- Fat: 28g
- Fiber: 3g
- Sugar: 4g
- Sodium: 320mg
- Cholesterol: 120mg

## Integration Points

- **Menu Items**: Stores nutrition data
- **Ingredients**: Used to build nutrition queries
- **Public Menus**: Displays nutrition to customers
- **Analytics**: Can track nutrition trends

