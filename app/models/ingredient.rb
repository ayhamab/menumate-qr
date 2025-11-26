class Ingredient < ApplicationRecord
  has_many :menu_item_ingredients, dependent: :destroy
  has_many :menu_items, through: :menu_item_ingredients
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
  validates :allergen_type, inclusion: { 
    in: ['none', 'nuts', 'peanuts', 'shellfish', 'fish', 'eggs', 'milk', 'soy', 'wheat', 'sesame', 'sulfites'],
    allow_blank: true
  }
  validates :preparation_area, length: { maximum: 50 }, allow_blank: true

  # Scopes
  scope :with_allergen, ->(allergen) { where(allergen_type: allergen) if allergen.present? }
  scope :by_preparation_area, ->(area) { where(preparation_area: area) if area.present? }
  scope :allergenic, -> { where.not(allergen_type: [nil, 'none']) }

  # Class methods
  def self.preparation_areas
    ['grill', 'fryer', 'oven', 'stovetop', 'prep_station', 'salad_station', 'dessert_station', 'beverage_station', 'other']
  end

  def self.allergen_types
    MenuItem.common_allergens.keys + ['none']
  end

  # Instance methods
  def has_allergen?
    allergen_type.present? && allergen_type != 'none'
  end

  def allergen_display_name
    return 'No Allergens' unless has_allergen?
    MenuItem.common_allergens[allergen_type] || allergen_type.humanize
  end

  def preparation_area_display
    return 'General' unless preparation_area.present?
    preparation_area.humanize.gsub('_', ' ')
  end
end
