class MenuTemplateItem < ApplicationRecord
  belongs_to :menu_template
  has_many :location_menu_overrides, dependent: :destroy

  # Serialize dietary_tags and allergens as JSON
  serialize :dietary_tags, coder: JSON
  serialize :allergens, coder: JSON
  serialize :name_translations, coder: JSON
  serialize :description_translations, coder: JSON

  # Validations
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, length: { maximum: 50 }, allow_blank: true

  # Scopes
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:display_order, :name) }

  # Instance methods
  def active?
    active == true
  end

  def sync_to_location(location, override_attributes = {})
    restaurant = location.restaurant
    
    # Check if menu item already exists
    existing_item = restaurant.menu_items.find_by(
      name: name,
      location: location
    )
    
    attributes = {
      name: name,
      description: description,
      price: price,
      category: category,
      dietary_tags: dietary_tags,
      allergens: allergens,
      active: active,
      location: location,
      restaurant: restaurant
    }.merge(override_attributes)
    
    if existing_item
      existing_item.update(attributes)
      existing_item
    else
      restaurant.menu_items.create!(attributes)
    end
  end

  def has_overrides_for_location?(location)
    location_menu_overrides.where(location: location).any?
  end

  def override_for_location(location)
    location_menu_overrides.find_by(location: location)
  end
end

