class MenuConsistencyReport < ApplicationRecord
  belongs_to :corporate_account
  belongs_to :menu_template, optional: true
  belongs_to :generated_by, class_name: 'User', optional: true

  # Serialize report_data as JSON
  serialize :report_data, coder: JSON

  # Validations
  validates :report_type, inclusion: {
    in: %w[full location_comparison item_analysis override_summary]
  }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(report_type: type) if type.present? }
  scope :by_template, ->(template) { where(menu_template: template) if template.present? }

  # Instance methods
  def generate!
    case report_type
    when 'full'
      generate_full_report
    when 'location_comparison'
      generate_location_comparison
    when 'item_analysis'
      generate_item_analysis
    when 'override_summary'
      generate_override_summary
    end
    
    save
  end

  private

  def generate_full_report
    locations = corporate_account.restaurants.includes(:locations).flat_map(&:locations)
    template = menu_template || corporate_account.menu_templates.active.latest.first
    
    return unless template
    
    data = {
      template_name: template.name,
      template_version: template.version,
      total_locations: locations.count,
      locations_analyzed: locations.count,
      consistency_score: template.consistency_report(locations)[:consistency_score],
      sync_status: {
        synced: template.menu_syncs.where(status: 'completed', location: locations).count,
        pending: template.menu_syncs.where(status: 'pending', location: locations).count,
        failed: template.menu_syncs.where(status: 'failed', location: locations).count
      },
      overrides: {
        total: LocationMenuOverride.where(menu_template: template, location: locations).count,
        approved: LocationMenuOverride.where(menu_template: template, location: locations, status: 'approved').count,
        pending: LocationMenuOverride.where(menu_template: template, location: locations, status: 'pending').count
      },
      location_details: locations.map do |location|
        {
          location_id: location.id,
          location_name: location.name,
          menu_items_count: location.restaurant.menu_items.where(location: location).count,
          template_items_count: template.menu_template_items.count,
          sync_status: template.menu_syncs.where(location: location).recent.first&.status || 'never',
          overrides_count: LocationMenuOverride.where(location: location, menu_template: template).count
        }
      end
    }
    
    update(report_data: data, generated_at: Time.current)
  end

  def generate_location_comparison
    locations = corporate_account.restaurants.includes(:locations).flat_map(&:locations)
    template = menu_template || corporate_account.menu_templates.active.latest.first
    
    return unless template
    
    comparison = locations.map do |location|
      location_items = location.restaurant.menu_items.where(location: location)
      template_items = template.menu_template_items.active
      
      {
        location_id: location.id,
        location_name: location.name,
        items_match: calculate_items_match(template_items, location_items),
        price_variance: calculate_price_variance(template_items, location_items),
        missing_items: find_missing_items(template_items, location_items),
        extra_items: find_extra_items(template_items, location_items)
      }
    end
    
    update(report_data: { comparison: comparison }, generated_at: Time.current)
  end

  def generate_item_analysis
    template = menu_template || corporate_account.menu_templates.active.latest.first
    return unless template
    
    locations = corporate_account.restaurants.includes(:locations).flat_map(&:locations)
    
    analysis = template.menu_template_items.active.map do |template_item|
      location_items = locations.map do |location|
        location.restaurant.menu_items.find_by(
          name: template_item.name,
          location: location
        )
      end.compact
      
      {
        template_item_id: template_item.id,
        name: template_item.name,
        category: template_item.category,
        template_price: template_item.price,
        locations_with_item: location_items.count,
        locations_without_item: locations.count - location_items.count,
        price_variance: calculate_item_price_variance(template_item, location_items),
        overrides_count: LocationMenuOverride.where(menu_template_item: template_item).count
      }
    end
    
    update(report_data: { analysis: analysis }, generated_at: Time.current)
  end

  def generate_override_summary
    template = menu_template || corporate_account.menu_templates.active.latest.first
    return unless template
    
    locations = corporate_account.restaurants.includes(:locations).flat_map(&:locations)
    overrides = LocationMenuOverride.where(menu_template: template, location: locations)
    
    summary = {
      total_overrides: overrides.count,
      by_status: {
        pending: overrides.pending.count,
        approved: overrides.approved.count,
        rejected: overrides.rejected.count
      },
      by_action: {
        exclude: overrides.where(action: 'exclude').count,
        modify_price: overrides.where(action: 'modify_price').count,
        modify_description: overrides.where(action: 'modify_description').count,
        add_custom: overrides.where(action: 'add_custom').count
      },
      by_location: locations.map do |location|
        location_overrides = overrides.where(location: location)
        {
          location_id: location.id,
          location_name: location.name,
          total: location_overrides.count,
          pending: location_overrides.pending.count,
          approved: location_overrides.approved.count
        }
      end
    }
    
    update(report_data: summary, generated_at: Time.current)
  end

  def calculate_items_match(template_items, location_items)
    template_names = template_items.pluck(:name).to_set
    location_names = location_items.pluck(:name).to_set
    
    matching = (template_names & location_names).count
    total = template_names.count
    
    total > 0 ? (matching.to_f / total * 100).round(2) : 0
  end

  def calculate_price_variance(template_items, location_items)
    variances = []
    
    template_items.each do |template_item|
      location_item = location_items.find_by(name: template_item.name)
      next unless location_item
      
      variance = ((location_item.price - template_item.price) / template_item.price * 100).round(2)
      variances << variance
    end
    
    return nil if variances.empty?
    
    {
      min: variances.min,
      max: variances.max,
      avg: (variances.sum / variances.count).round(2)
    }
  end

  def find_missing_items(template_items, location_items)
    template_names = template_items.pluck(:name).to_set
    location_names = location_items.pluck(:name).to_set
    
    (template_names - location_names).to_a
  end

  def find_extra_items(template_items, location_items)
    template_names = template_items.pluck(:name).to_set
    location_names = location_items.pluck(:name).to_set
    
    (location_names - template_names).to_a
  end

  def calculate_item_price_variance(template_item, location_items)
    return nil if location_items.empty?
    
    prices = location_items.map(&:price)
    variances = prices.map { |p| ((p - template_item.price) / template_item.price * 100).round(2) }
    
    {
      min: variances.min,
      max: variances.max,
      avg: (variances.sum / variances.count).round(2),
      locations: location_items.map { |item| { location_id: item.location_id, price: item.price } }
    }
  end
end

