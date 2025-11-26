class MenuSync < ApplicationRecord
  belongs_to :menu_template
  belongs_to :location
  belongs_to :initiated_by, class_name: 'User', optional: true

  # Validations
  validates :status, inclusion: {
    in: %w[pending in_progress completed failed cancelled]
  }
  validates :sync_type, inclusion: {
    in: %w[full incremental selective]
  }

  # Serialize sync_details as JSON
  serialize :sync_details, coder: JSON

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_location, ->(location) { where(location: location) if location.present? }
  scope :by_template, ->(template) { where(menu_template: template) if template.present? }

  # Instance methods
  def pending?
    status == 'pending'
  end

  def in_progress?
    status == 'in_progress'
  end

  def completed?
    status == 'completed'
  end

  def failed?
    status == 'failed'
  end

  def execute!
    update(status: 'in_progress', started_at: Time.current)
    
    begin
      case sync_type
      when 'full'
        sync_full_menu
      when 'incremental'
        sync_incremental
      when 'selective'
        sync_selective
      end
      
      update(
        status: 'completed',
        completed_at: Time.current,
        sync_details: {
          items_synced: sync_details&.dig('items_synced') || 0,
          items_created: sync_details&.dig('items_created') || 0,
          items_updated: sync_details&.dig('items_updated') || 0,
          items_skipped: sync_details&.dig('items_skipped') || 0
        }
      )
    rescue => e
      update(
        status: 'failed',
        completed_at: Time.current,
        error_message: e.message
      )
      raise
    end
  end

  private

  def sync_full_menu
    items_synced = 0
    items_created = 0
    items_updated = 0
    items_skipped = 0
    
    menu_template.menu_template_items.active.each do |template_item|
      # Check for location-specific overrides
      override = template_item.override_for_location(location)
      
      if override && override.action == 'exclude'
        items_skipped += 1
        next
      end
      
      override_attrs = override ? override.override_attributes : {}
      result = template_item.sync_to_location(location, override_attrs)
      
      if result.persisted?
        if result.previously_new_record?
          items_created += 1
        else
          items_updated += 1
        end
        items_synced += 1
      end
    end
    
    update(sync_details: {
      items_synced: items_synced,
      items_created: items_created,
      items_updated: items_updated,
      items_skipped: items_skipped
    })
  end

  def sync_incremental
    # Only sync items that have changed since last sync
    last_sync = MenuSync.where(
      menu_template: menu_template,
      location: location,
      status: 'completed'
    ).where.not(id: id).recent.first
    
    if last_sync
      changed_items = menu_template.menu_template_items.where(
        'updated_at > ?', last_sync.completed_at
      )
    else
      changed_items = menu_template.menu_template_items.active
    end
    
    items_synced = 0
    items_created = 0
    items_updated = 0
    
    changed_items.each do |template_item|
      override = template_item.override_for_location(location)
      next if override && override.action == 'exclude'
      
      override_attrs = override ? override.override_attributes : {}
      result = template_item.sync_to_location(location, override_attrs)
      
      if result&.persisted?
        items_created += 1 if result.previously_new_record?
        items_updated += 1 unless result.previously_new_record?
        items_synced += 1
      end
    end
    
    update(sync_details: {
      items_synced: items_synced,
      items_created: items_created,
      items_updated: items_updated
    })
  end

  def sync_selective
    # Sync only selected items (stored in sync_details)
    item_ids = sync_details&.dig('item_ids') || []
    return if item_ids.empty?
    
    items_synced = 0
    items_created = 0
    items_updated = 0
    
    menu_template.menu_template_items.where(id: item_ids).each do |template_item|
      override = template_item.override_for_location(location)
      next if override && override.action == 'exclude'
      
      override_attrs = override ? override.override_attributes : {}
      result = template_item.sync_to_location(location, override_attrs)
      
      if result&.persisted?
        items_created += 1 if result.previously_new_record?
        items_updated += 1 unless result.previously_new_record?
        items_synced += 1
      end
    end
    
    update(sync_details: {
      items_synced: items_synced,
      items_created: items_created,
      items_updated: items_updated
    })
  end
end

