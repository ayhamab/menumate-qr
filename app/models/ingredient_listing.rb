class IngredientListing < ApplicationRecord
  belongs_to :supplier
  has_many :ingredient_listing_categories, dependent: :destroy
  has_many :categories, through: :ingredient_listing_categories
  has_one_attached :image
  has_many :supplier_contacts, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :price_per_unit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :unit, length: { maximum: 50 }, allow_blank: true
  validates :minimum_order_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, inclusion: { in: %w[draft active paused sold_out] }

  # Serialize dietary_info and certifications as JSON
  serialize :dietary_info, coder: JSON
  serialize :certifications, coder: JSON

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(category) {
    joins(:categories).where(categories: { name: category }) if category.present?
  }
  scope :organic, -> { where("certifications LIKE ?", "%organic%") }
  scope :local, -> { where(local: true) }
  scope :in_stock, -> { where.not(status: 'sold_out') }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def active?
    status == 'active'
  end

  def featured?
    featured == true
  end

  def organic?
    certifications&.include?('organic') || false
  end

  def has_dietary_info?
    dietary_info.present? && dietary_info.any?
  end

  def price_display
    return "Contact for pricing" unless price_per_unit.present?
    "$#{price_per_unit.round(2)}/#{unit || 'unit'}"
  end

  def minimum_order_display
    return nil unless minimum_order_quantity.present?
    "Min. order: #{minimum_order_quantity} #{unit || 'units'}"
  end

  def availability_status
    case status
    when 'active'
      'In Stock'
    when 'sold_out'
      'Sold Out'
    when 'paused'
      'Temporarily Unavailable'
    else
      'Not Available'
    end
  end
end

