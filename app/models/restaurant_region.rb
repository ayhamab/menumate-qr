class RestaurantRegion < ApplicationRecord
  belongs_to :restaurant
  belongs_to :region

  validates :restaurant_id, uniqueness: {
    scope: :region_id,
    message: "is already registered in this region"
  }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_region, ->(region) { where(region: region) if region.present? }

  # Instance methods
  def active?
    active == true
  end

  def compliance_status
    # Check all menu items for compliance in this region
    menu_items = restaurant.menu_items
    region_laws = region.mandatory_laws
    
    total_items = menu_items.count
    return { compliant: true, percentage: 100, issues: 0 } if total_items.zero?
    
    compliant_items = 0
    issues = 0
    
    menu_items.each do |item|
      compliance = region.check_menu_item_compliance(item)
      if compliance[:compliant]
        compliant_items += 1
      else
        issues += compliance[:violations].count
      end
    end
    
    {
      compliant: issues.zero?,
      percentage: ((compliant_items.to_f / total_items) * 100).round(2),
      issues: issues,
      compliant_items: compliant_items,
      total_items: total_items
    }
  end
end

