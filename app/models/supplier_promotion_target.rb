class SupplierPromotionTarget < ApplicationRecord
  belongs_to :supplier_promotion
  belongs_to :restaurant

  validates :restaurant_id, uniqueness: {
    scope: :supplier_promotion_id,
    message: "is already a target for this promotion"
  }
end

