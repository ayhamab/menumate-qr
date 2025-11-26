class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient

  # Validations
  validates :quantity, presence: true
  validates :ingredient_id, uniqueness: { scope: :recipe_id, message: "is already in this recipe" }

  # Scopes
  scope :ordered, -> { order(:position, :created_at) }

  # Instance methods
  def quantity_display
    return quantity unless unit.present?
    "#{quantity} #{unit}"
  end

  def full_display
    parts = [quantity_display, ingredient.name]
    parts << preparation_method if preparation_method.present?
    parts.join(" ")
  end

  # Get scaled quantity for different serving size
  def scaled_quantity(target_servings)
    return quantity if target_servings == recipe.base_servings
    
    scale_factor = target_servings.to_f / recipe.base_servings.to_f
    # Parse and scale quantity
    parsed = recipe.send(:parse_quantity, quantity.to_s)
    return quantity if parsed.nil?
    
    scaled_value = (parsed * scale_factor).round(2)
    unit = recipe.send(:extract_unit, quantity.to_s)
    
    if unit.present?
      "#{scaled_value} #{unit}"
    else
      scaled_value.to_s
    end
  end
end

