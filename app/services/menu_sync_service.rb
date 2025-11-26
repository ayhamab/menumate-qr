class MenuSyncService
  attr_reader :menu_sync

  def initialize(menu_sync)
    @menu_sync = menu_sync
  end

  def execute
    menu_sync.execute!
  rescue => e
    Rails.logger.error "Menu sync failed: #{e.message}"
    raise
  end

  def self.sync_template_to_all_locations(template, sync_type: 'full')
    locations = template.corporate_account.restaurants.includes(:locations).flat_map(&:locations)
    
    syncs = []
    locations.each do |location|
      sync = MenuSync.create(
        menu_template: template,
        location: location,
        status: 'pending',
        sync_type: sync_type
      )
      
      service = new(sync)
      service.execute
      
      syncs << sync
    end
    
    syncs
  end

  def self.sync_template_to_selected_locations(template, location_ids, sync_type: 'full')
    locations = Location.where(id: location_ids, restaurant: template.corporate_account.restaurants)
    
    syncs = []
    locations.each do |location|
      sync = MenuSync.create(
        menu_template: template,
        location: location,
        status: 'pending',
        sync_type: sync_type
      )
      
      service = new(sync)
      service.execute
      
      syncs << sync
    end
    
    syncs
  end
end

