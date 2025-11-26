# Menu Analytics Data API

This document describes the API for food brands to access dietary trend data from MenuMate QR.

## Overview

MenuMate QR aggregates dietary information from restaurant menus across the platform and provides analytics data to food brands. This data helps brands understand consumer dietary preferences and trends.

## Authentication

All API requests require an API key in the `X-API-Key` header:

```
X-API-Key: your_api_key_here
```

Or as a query parameter:

```
?api_key=your_api_key_here
```

## Subscription Tiers

### Basic - $299/month
- Monthly trend reports
- Basic dietary tag analytics
- Email support
- CSV data export
- 1,000 API calls/month

### Premium - $999/month
- Weekly trend reports
- Advanced analytics dashboard
- Regional breakdowns
- API access
- Priority support
- JSON/CSV data export
- Custom date ranges
- 10,000 API calls/month

### Enterprise - $2,999/month
- Real-time analytics
- Full API access
- Custom reports
- Dedicated account manager
- White-label reports
- Unlimited data export
- Historical data access
- Unlimited API calls

## API Endpoints

### GET /api/v1/dietary_trends

Get dietary trend data.

**Query Parameters:**
- `start_date` (optional): Start date (YYYY-MM-DD), default: 30 days ago
- `end_date` (optional): End date (YYYY-MM-DD), default: today
- `region` (optional): Filter by region (city, state, or country)
- `dietary_tag` (optional): Filter by specific dietary tag

**Example Request:**
```bash
curl -H "X-API-Key: your_api_key" \
  "https://menumateqr.com/api/v1/dietary_trends?start_date=2024-01-01&end_date=2024-01-31&region=New York"
```

**Example Response:**
```json
{
  "data": [
    {
      "id": 1,
      "dietary_tag": "vegan",
      "trend_percentage": 15.5,
      "sample_size": 1000,
      "growth_rate": 5.2,
      "region": "New York",
      "category": null,
      "trend_date": "2024-01-31",
      "metadata": {
        "item_count": 155,
        "total_items": 1000
      },
      "created_at": "2024-01-31T12:00:00Z"
    }
  ],
  "meta": {
    "total": 1,
    "start_date": "2024-01-01",
    "end_date": "2024-01-31",
    "region": "New York",
    "dietary_tag": null
  }
}
```

### GET /api/v1/dietary_trends/:id

Get a specific dietary trend by ID.

**Example Request:**
```bash
curl -H "X-API-Key: your_api_key" \
  "https://menumateqr.com/api/v1/dietary_trends/1"
```

### GET /api/v1/dietary_trends/summary

Get a summary of top trends and growth leaders.

**Query Parameters:**
- `start_date` (optional): Start date (YYYY-MM-DD)
- `end_date` (optional): End date (YYYY-MM-DD)
- `region` (optional): Filter by region

**Example Request:**
```bash
curl -H "X-API-Key: your_api_key" \
  "https://menumateqr.com/api/v1/dietary_trends/summary"
```

**Example Response:**
```json
{
  "data": {
    "top_trends": [
      {
        "id": 1,
        "dietary_tag": "vegan",
        "trend_percentage": 15.5,
        "sample_size": 1000,
        "growth_rate": 5.2,
        "region": null,
        "trend_date": "2024-01-31"
      }
    ],
    "growth_leaders": [
      {
        "id": 2,
        "dietary_tag": "gluten-free",
        "trend_percentage": 12.3,
        "sample_size": 1000,
        "growth_rate": 8.7,
        "region": null,
        "trend_date": "2024-01-31"
      }
    ],
    "period": {
      "start_date": "2024-01-01",
      "end_date": "2024-01-31",
      "region": null
    }
  }
}
```

### GET /api/v1/dietary_trends/export

Export dietary trend data in CSV or JSON format.

**Query Parameters:**
- `start_date` (optional): Start date (YYYY-MM-DD)
- `end_date` (optional): End date (YYYY-MM-DD)
- `region` (optional): Filter by region
- `format` (optional): Export format (`csv` or `json`), default: `json`

**Example Request (CSV):**
```bash
curl -H "X-API-Key: your_api_key" \
  "https://menumateqr.com/api/v1/dietary_trends/export?format=csv&start_date=2024-01-01&end_date=2024-01-31" \
  -o trends.csv
```

**Example Request (JSON):**
```bash
curl -H "X-API-Key: your_api_key" \
  "https://menumateqr.com/api/v1/dietary_trends/export?format=json&start_date=2024-01-01&end_date=2024-01-31"
```

## Dietary Tags

Common dietary tags tracked:
- vegan
- vegetarian
- gluten-free
- dairy-free
- nut-free
- halal
- kosher
- low-carb
- keto
- paleo
- organic
- spicy

## Rate Limiting

API calls are limited based on subscription tier:
- Basic: 1,000 calls/month
- Premium: 10,000 calls/month
- Enterprise: Unlimited

Rate limit headers are included in responses:
- `X-RateLimit-Limit`: Monthly limit
- `X-RateLimit-Remaining`: Remaining calls this month
- `X-RateLimit-Reset`: Reset date (first of next month)

## Error Responses

### 401 Unauthorized
```json
{
  "error": "Invalid API key"
}
```

### 429 Too Many Requests
```json
{
  "error": "API rate limit exceeded"
}
```

### 400 Bad Request
```json
{
  "error": "Invalid format. Use csv or json"
}
```

## Data Privacy

- All data is aggregated and anonymized
- No individual restaurant or menu item data is exposed
- Regional data is aggregated by city/state/country
- Sample sizes ensure statistical significance

## Support

For API support, contact:
- Email: api@menumateqr.com
- Documentation: https://menumateqr.com/api/docs

