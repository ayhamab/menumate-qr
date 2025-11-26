class SupplierReview < ApplicationRecord
  belongs_to :supplier
  belongs_to :restaurant

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 1000 }, allow_blank: true
  validates :restaurant_id, uniqueness: {
    scope: :supplier_id,
    message: "has already reviewed this supplier"
  }

  # Scopes
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }
  scope :by_rating, ->(rating) { where(rating: rating) if rating.present? }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def approved?
    approved == true
  end
end

