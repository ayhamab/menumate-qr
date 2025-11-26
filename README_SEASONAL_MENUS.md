# Seasonal Menu System

This document describes the seasonal menu scheduling system for MenuMate QR.

## Overview

The seasonal menu system allows restaurants to automatically show or hide menu items based on:
- Date ranges (start and end dates)
- Time ranges (specific times of day)
- Recurring patterns (yearly, monthly, weekly, daily)

## Features

### 1. Schedule Management
- Create schedules for individual menu items
- Set start and end dates
- Optional time-based availability (e.g., breakfast items only available 6 AM - 11 AM)
- Recurring patterns for seasonal items

### 2. Automatic Visibility
- Menu items are automatically shown/hidden based on active schedules
- Real-time checking when menus are displayed
- No manual intervention required

### 3. Recurring Patterns
- **Yearly**: Same date each year (e.g., Christmas specials)
- **Monthly**: Same day of month each month
- **Weekly**: Same day of week each week
- **Daily**: Every day within the date range

## Usage

### Creating a Seasonal Schedule

1. Navigate to your restaurant's menu items page
2. Click "Seasonal Schedules"
3. Click "New Schedule"
4. Fill in:
   - Schedule name (e.g., "Summer Menu", "Holiday Specials")
   - Menu item to schedule
   - Start and end dates
   - Optional: Start and end times
   - Optional: Recurring pattern
5. Save the schedule

### How It Works

- When a menu is displayed, the system checks if each menu item has an active seasonal schedule
- Items with active schedules are shown
- Items with inactive or no schedules are hidden
- The check happens in real-time, so changes are immediate

### Example Use Cases

1. **Summer Menu**: Show ice cream items only from June 1 - August 31
2. **Breakfast Items**: Show breakfast items only from 6 AM - 11 AM daily
3. **Holiday Specials**: Show special items from December 1 - January 5, recurring yearly
4. **Weekend Specials**: Show special items every Saturday and Sunday

## Technical Details

### Models
- `SeasonalMenuSchedule`: Stores schedule information
- `MenuItem`: Has many seasonal schedules

### Methods
- `MenuItem#seasonally_available?`: Checks if item should be visible
- `SeasonalMenuSchedule#active_at_time?`: Checks if schedule is active at a given time
- `SeasonalMenuSchedule#matches_recurring_pattern?`: Validates recurring patterns

### Background Jobs
- `SeasonalMenuUpdateJob`: Can be scheduled to run periodically (optional)
- Menu visibility is checked in real-time, so background jobs are optional

## Scheduling Background Jobs

To run automatic checks (optional), you can set up a cron job or use a scheduler:

```ruby
# In config/schedule.rb (if using whenever gem)
every 1.hour do
  runner "SeasonalMenuUpdateJob.perform_later"
end
```

Or use Rails' built-in job scheduling with Solid Queue (already configured).

## API

The seasonal menu system is automatically respected in:
- Public menu display (`/restaurants/:id/menu`)
- Menu items index (owner view shows all items, but indicates seasonal status)
- API responses (items are filtered based on availability)

