class Promotion < ApplicationRecord
  belongs_to :restaurant
  belongs_to :brand, optional: true # Brand-specific promotions (for virtual restaurants)
  has_many :menu_item_promotions, dependent: :destroy
  has_many :menu_items, through: :menu_item_promotions

  # Validations
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :discount_type, presence: true, inclusion: { in: %w[percentage fixed_amount special] }
  validates :discount_value, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: -> { discount_type != 'special' }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date
  validate :dates_not_in_past, on: :create

  # Scopes
  scope :active, -> { where(active: true) }
  scope :current, -> { where('start_date <= ? AND end_date >= ?', Time.current, Time.current) }
  scope :upcoming, -> { where('start_date > ?', Time.current) }
  scope :expired, -> { where('end_date < ?', Time.current) }
  scope :for_restaurant, ->(restaurant_id) { where(restaurant_id: restaurant_id) }

  # Class methods
  def self.discount_types
    {
      'percentage' => 'Percentage Off',
      'fixed_amount' => 'Fixed Amount Off',
      'special' => 'Special Offer'
    }
  end

  def self.badge_colors
    {
      'red' => 'Red',
      'orange' => 'Orange',
      'yellow' => 'Yellow',
      'green' => 'Green',
      'blue' => 'Blue',
      'purple' => 'Purple',
      'pink' => 'Pink'
    }
  end

  # Instance methods
  def current?
    active? && start_date <= Time.current && end_date >= Time.current
  end

  def upcoming?
    active? && start_date > Time.current
  end

  def expired?
    end_date < Time.current
  end

  def applies_to_all_items?
    menu_items.empty?
  end

  def applies_to_item?(menu_item)
    applies_to_all_items? || menu_items.include?(menu_item)
  end

  def discount_display
    case discount_type
    when 'percentage'
      "#{discount_value.to_i}% OFF"
    when 'fixed_amount'
      "$#{discount_value.to_f} OFF"
    when 'special'
      title
    else
      'Special Offer'
    end
  end

  def calculate_discounted_price(original_price)
    return original_price unless current?
    
    case discount_type
    when 'percentage'
      original_price * (1 - discount_value / 100.0)
    when 'fixed_amount'
      [original_price - discount_value, 0].max
    else
      original_price
    end
  end

  private

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?
    
    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def dates_not_in_past
    return unless start_date.present?
    
    if start_date < Time.current.beginning_of_day
      errors.add(:start_date, "cannot be in the past")
    end
  end
end
