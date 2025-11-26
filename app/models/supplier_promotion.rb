class SupplierPromotion < ApplicationRecord
  belongs_to :supplier
  has_many :supplier_promotion_targets, dependent: :destroy
  has_many :target_restaurants, through: :supplier_promotion_targets, source: :restaurant

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :promotion_type, inclusion: {
    in: %w[discount bulk_deal seasonal_special new_product featured_ingredient]
  }
  validates :status, inclusion: { in: %w[draft active paused expired] }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  # Scopes
  scope :active, -> {
    where(status: 'active')
      .where('start_date <= ?', Date.current)
      .where('end_date >= ?', Date.current)
  }
  scope :current, -> { active }
  scope :upcoming, -> {
    where(status: 'active')
      .where('start_date > ?', Date.current)
  }
  scope :by_type, ->(type) { where(promotion_type: type) if type.present? }
  scope :featured, -> { where(featured: true) }

  # Instance methods
  def active?
    status == 'active' &&
      start_date <= Date.current &&
      end_date >= Date.current
  end

  def expired?
    end_date < Date.current || status == 'expired'
  end

  def upcoming?
    status == 'active' && start_date > Date.current
  end

  def applies_to_restaurant?(restaurant)
    return true if target_restaurants.empty? # No targets = applies to all
    target_restaurants.include?(restaurant)
  end

  private

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?
    errors.add(:end_date, "must be after start date") if end_date < start_date
  end
end

