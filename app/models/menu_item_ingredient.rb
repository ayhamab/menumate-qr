class MenuItemIngredient < ApplicationRecord
  belongs_to :menu_item
  belongs_to :ingredient

  # Validations
  validates :menu_item_id, uniqueness: { scope: :ingredient_id, message: "This ingredient is already added to this menu item" }
  validates :quantity, length: { maximum: 50 }, allow_blank: true
  validates :preparation_method, length: { maximum: 100 }, allow_blank: true

  # Scopes
  scope :with_allergen, ->(allergen) { joins(:ingredient).where(ingredients: { allergen_type: allergen }) }
  scope :by_preparation_area, ->(area) { joins(:ingredient).where(ingredients: { preparation_area: area }) }
end
