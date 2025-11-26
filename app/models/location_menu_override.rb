class LocationMenuOverride < ApplicationRecord
  belongs_to :menu_template
  belongs_to :menu_template_item, optional: true
  belongs_to :location
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :approved_by, class_name: 'User', optional: true

  # Validations
  validates :action, inclusion: {
    in: %w[exclude modify_price modify_description add_custom]
  }
  validates :status, inclusion: {
    in: %w[pending approved rejected]
  }

  # Serialize override_attributes as JSON
  serialize :override_attributes, coder: JSON

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :by_location, ->(location) { where(location: location) if location.present? }
  scope :by_template, ->(template) { where(menu_template: template) if template.present? }

  # Instance methods
  def pending?
    status == 'pending'
  end

  def approved?
    status == 'approved'
  end

  def rejected?
    status == 'rejected'
  end

  def approve!(user)
    update(
      status: 'approved',
      approved_by: user,
      approved_at: Time.current
    )
  end

  def reject!(user, reason = nil)
    update(
      status: 'rejected',
      approved_by: user,
      approved_at: Time.current,
      rejection_reason: reason
    )
  end

  def apply_to_menu_item(menu_item)
    case action
    when 'exclude'
      menu_item.update(active: false)
    when 'modify_price'
      menu_item.update(price: override_attributes['price']) if override_attributes['price']
    when 'modify_description'
      menu_item.update(description: override_attributes['description']) if override_attributes['description']
    when 'add_custom'
      # Create a new menu item based on override
      menu_item.restaurant.menu_items.create(
        name: override_attributes['name'],
        description: override_attributes['description'],
        price: override_attributes['price'],
        category: override_attributes['category'],
        location: location,
        active: true
      )
    end
  end
end

