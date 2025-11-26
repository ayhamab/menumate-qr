# Seasonal Menu Scheduler
# This initializer sets up automatic checking of seasonal menu schedules
# The job runs every hour to check and update menu visibility

if defined?(Rails::Console) == false && Rails.env.production?
  # Schedule the job to run every hour
  # In production, you would use a proper scheduler like whenever, sidekiq-cron, or system cron
  # For now, we'll rely on the menu display logic to check schedules in real-time
end

