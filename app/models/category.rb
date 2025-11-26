class Category < ApplicationRecord
  has_many :ingredient_listing_categories, dependent: :destroy
  has_many :ingredient_listings, through: :ingredient_listing_categories

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  # Instance methods
  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?
    self.slug = name.parameterize
  end
end

