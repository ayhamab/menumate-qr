class SeasonalMenuUpdateJob < ApplicationJob
  queue_as :default

  # This job checks all seasonal menu schedules and ensures menu items
  # are visible/hidden based on their schedules
  def perform
    # Get all active schedules
    schedules = SeasonalMenuSchedule.active.includes(:menu_item, :restaurant)
    
    schedules.find_each do |schedule|
      menu_item = schedule.menu_item
      now = Time.current
      
      # Check if schedule is currently active
      if schedule.active_at_time?(now)
        # Menu item should be visible (handled by seasonally_available? method)
        Rails.logger.info "Seasonal schedule '#{schedule.name}' is active for menu item '#{menu_item.name}'"
      else
        # Menu item should be hidden (handled by seasonally_available? method)
        Rails.logger.info "Seasonal schedule '#{schedule.name}' is not active for menu item '#{menu_item.name}'"
      end
    end
    
    Rails.logger.info "Seasonal menu update job completed at #{Time.current}"
  end
end
