class MenuItemAnalytics < ApplicationRecord
  belongs_to :menu_item
  belongs_to :restaurant

  # Validations
  validates :date, presence: true, uniqueness: { scope: :menu_item_id }
  validates :views, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :clicks, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :orders, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :revenue, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :recent, -> { order(date: :desc) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :by_menu_item, ->(menu_item) { where(menu_item: menu_item) if menu_item.present? }

  # Class methods
  def self.track_view(menu_item, request = nil)
    today = Date.current
    analytics = find_or_initialize_by(menu_item: menu_item, date: today, restaurant: menu_item.restaurant)
    analytics.views = (analytics.views || 0) + 1
    analytics.save
  end

  def self.track_click(menu_item, request = nil)
    today = Date.current
    analytics = find_or_initialize_by(menu_item: menu_item, date: today, restaurant: menu_item.restaurant)
    analytics.clicks = (analytics.clicks || 0) + 1
    analytics.save
  end

  def self.track_order(menu_item, revenue: nil, request: nil)
    today = Date.current
    analytics = find_or_initialize_by(menu_item: menu_item, date: today, restaurant: menu_item.restaurant)
    analytics.orders = (analytics.orders || 0) + 1
    analytics.revenue = (analytics.revenue || 0) + (revenue || menu_item.price || 0)
    analytics.save
  end

  # Instance methods
  def conversion_rate
    return 0 if views.nil? || views.zero?
    ((clicks || 0).to_f / views * 100).round(2)
  end

  def order_rate
    return 0 if clicks.nil? || clicks.zero?
    ((orders || 0).to_f / clicks * 100).round(2)
  end

  def average_order_value
    return 0 if orders.nil? || orders.zero?
    ((revenue || 0).to_f / orders).round(2)
  end
end

