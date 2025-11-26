# AI Menu Analysis Setup

This document describes how to set up AI-powered menu item analysis for dietary tagging and description improvements.

## Overview

The AI analysis feature uses OpenAI's GPT models to analyze menu items and suggest:
- Better dietary tags (vegan, gluten-free, etc.)
- Allergen detection
- Improved, appetizing descriptions

## Setup

### 1. Install Dependencies

The `ruby-openai` gem has been added to the Gemfile. Install it:

```bash
bundle install
```

### 2. Get OpenAI API Key

1. Sign up for an OpenAI account at https://platform.openai.com
2. Navigate to API Keys section
3. Create a new API key
4. Copy the key (it starts with `sk-`)

### 3. Configure Environment Variable

Add your OpenAI API key to your environment:

**For development (.env or config/application.yml):**
```bash
OPENAI_API_KEY=sk-your-api-key-here
```

**For production:**
Set the `OPENAI_API_KEY` environment variable in your hosting platform.

### 4. Usage

Once configured, restaurant owners can:

1. Navigate to any menu item
2. Click "AI Analysis" button
3. Review AI suggestions for:
   - Dietary tags
   - Allergens
   - Improved description
4. Apply suggestions with one click

## Features

- **Smart Tagging**: Automatically suggests appropriate dietary tags based on item name and description
- **Allergen Detection**: Identifies common allergens (nuts, dairy, gluten, etc.)
- **Description Enhancement**: Generates appetizing, detailed descriptions
- **Confidence Levels**: Shows high/medium/low confidence for suggestions
- **Reasoning**: Explains why suggestions were made

## API Costs

The system uses OpenAI's `gpt-4o-mini` model for cost efficiency:
- Approximately $0.15 per 1M input tokens
- Approximately $0.60 per 1M output tokens
- Typical analysis costs: $0.001-0.005 per menu item

## Model Configuration

The AI analyzer is configured with:
- Model: `gpt-4o-mini` (cost-effective, fast)
- Temperature: 0.3 (consistent results)
- Max tokens: 500 (sufficient for suggestions)

To use a different model, edit `app/services/menu_item_ai_analyzer.rb`:
```ruby
model: "gpt-4o", # or "gpt-3.5-turbo" for even lower costs
```

## Error Handling

The system gracefully handles:
- Missing API key
- API rate limits
- Network errors
- Invalid responses

Users will see helpful error messages if analysis fails.

## Privacy

- Menu item data is sent to OpenAI for analysis
- No customer data is shared
- API calls are made server-side (secure)
- Consider OpenAI's data usage policy for production

