class QrCode < ApplicationRecord
  belongs_to :restaurant
  belongs_to :brand, optional: true # Brand-specific QR codes (for virtual restaurants)

  validates :token, presence: true, uniqueness: true

  # Scopes
  scope :for_brand, ->(brand) { where(brand: brand) if brand.present? }
  scope :for_restaurant, ->(restaurant) { where(brand: nil, restaurant: restaurant) }
end

