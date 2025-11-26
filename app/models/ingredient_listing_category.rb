class IngredientListingCategory < ApplicationRecord
  belongs_to :ingredient_listing
  belongs_to :category

  validates :ingredient_listing_id, uniqueness: {
    scope: :category_id,
    message: "already has this category"
  }
end

