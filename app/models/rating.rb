class Rating < ApplicationRecord
  belongs_to :menu_item

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5, message: "must be between 1 and 5" }
  validates :comment, length: { maximum: 500 }, allow_blank: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :positive, -> { where("rating >= 4") }
  scope :negative, -> { where("rating <= 2") }

  # Class methods
  def self.average_rating_for(menu_item)
    where(menu_item: menu_item).average(:rating)&.round(1) || 0
  end

  def self.rating_count_for(menu_item)
    where(menu_item: menu_item).count
  end

  def self.rating_distribution_for(menu_item)
    where(menu_item: menu_item).group(:rating).count
  end
end
