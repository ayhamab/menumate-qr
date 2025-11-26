class Recipe < ApplicationRecord
  belongs_to :restaurant
  belongs_to :menu_item, optional: true
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :base_servings, presence: true, numericality: { greater_than: 0 }
  validates :prep_time, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :cook_time, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :by_restaurant, ->(restaurant) { where(restaurant: restaurant) if restaurant.present? }
  scope :with_menu_item, -> { where.not(menu_item_id: nil) }
  scope :standalone, -> { where(menu_item_id: nil) }

  # Instance methods
  def total_time
    (prep_time || 0) + (cook_time || 0)
  end

  def total_time_display
    return "N/A" if total_time.zero?
    hours = total_time / 60
    minutes = total_time % 60
    if hours > 0
      "#{hours}h #{minutes}m"
    else
      "#{minutes}m"
    end
  end

  # Scale recipe to different serving size
  def scale_to_servings(target_servings)
    return self if target_servings == base_servings
    
    scale_factor = target_servings.to_f / base_servings.to_f
    scaled_recipe = self.dup
    scaled_recipe.base_servings = target_servings
    
    scaled_recipe.recipe_ingredients = recipe_ingredients.map do |ri|
      scaled_ri = ri.dup
      scaled_ri.quantity = scale_quantity(ri.quantity.to_s, scale_factor)
      scaled_ri
    end
    
    scaled_recipe
  end

  # Get scaled ingredients for a specific serving size
  def ingredients_for_servings(servings)
    return recipe_ingredients.map { |ri| {
      ingredient: ri.ingredient,
      quantity: ri.quantity,
      unit: ri.unit,
      preparation_method: ri.preparation_method,
      notes: ri.notes
    }} if servings == base_servings
    
    scale_factor = servings.to_f / base_servings.to_f
    recipe_ingredients.map do |ri|
      {
        ingredient: ri.ingredient,
        quantity: scale_quantity(ri.quantity.to_s, scale_factor),
        unit: ri.unit,
        preparation_method: ri.preparation_method,
        notes: ri.notes
      }
    end
  end

  # Calculate total cost for a recipe (if ingredient costs are available)
  def total_cost(servings: base_servings)
    scale_factor = servings.to_f / base_servings.to_f
    recipe_ingredients.sum do |ri|
      ingredient_cost = ri.ingredient.respond_to?(:cost_per_unit) ? ri.ingredient.cost_per_unit : 0
      quantity_value = parse_quantity(ri.quantity)
      (quantity_value * scale_factor * ingredient_cost) rescue 0
    end
  end

  # Get all allergens from recipe ingredients
  def allergens
    ingredients.where.not(allergen_type: [nil, 'none']).distinct.pluck(:allergen_type)
  end

  def has_allergens?
    allergens.any?
  end

  # Get preparation areas used
  def preparation_areas
    ingredients.where.not(preparation_area: [nil, '']).distinct.pluck(:preparation_area)
  end

  private

  # Scale a quantity string (e.g., "2 cups" -> "4 cups" for 2x scale)
  def scale_quantity(quantity_string, scale_factor)
    return quantity_string if quantity_string.blank?
    
    # Try to parse quantity
    parsed = parse_quantity(quantity_string)
    return quantity_string if parsed.nil?
    
    scaled_value = (parsed * scale_factor).round(2)
    
    # Extract unit if present
    unit = extract_unit(quantity_string)
    
    # Format result
    if unit.present?
      "#{scaled_value} #{unit}"
    else
      scaled_value.to_s
    end
  end

  # Parse quantity from string (e.g., "2 cups" -> 2.0)
  def parse_quantity(quantity_string)
    return nil if quantity_string.blank?
    
    # Try to extract number
    match = quantity_string.to_s.match(/^([\d.]+)/)
    return nil unless match
    
    match[1].to_f
  rescue
    nil
  end

  # Extract unit from quantity string (e.g., "2 cups" -> "cups")
  def extract_unit(quantity_string)
    return nil if quantity_string.blank?
    
    # Remove number and common separators
    unit = quantity_string.to_s.gsub(/^[\d.\s]+/, '').strip
    unit.present? ? unit : nil
  end
end

