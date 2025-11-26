class SplitTestVariant < ApplicationRecord
  belongs_to :split_test
  has_many :split_test_results, dependent: :destroy
  has_one_attached :image # For image tests

  validates :name, presence: true, length: { maximum: 255 }
  validates :weight, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :description, presence: true, if: -> { split_test&.test_type == 'description' }
  validates :position, presence: true, if: -> { split_test&.test_type == 'placement' }
  validates :price, presence: true, numericality: { greater_than: 0 }, if: -> { split_test&.test_type == 'price' }

  # Scopes
  scope :active, -> { joins(:split_test).where(split_tests: { status: 'active' }) }
  scope :by_weight, -> { order(weight: :desc) }

  # Instance methods
  def is_control?
    is_control == true
  end

  # Get statistics for this variant
  def statistics
    impressions = split_test_results.where(event_type: 'impression').count
    clicks = split_test_results.where(event_type: 'click').count
    orders = split_test_results.where(event_type: 'order').count
    
    conversion_rate = impressions > 0 ? (clicks.to_f / impressions * 100).round(2) : 0
    order_rate = clicks > 0 ? (orders.to_f / clicks * 100).round(2) : 0
    
    {
      impressions: impressions,
      clicks: clicks,
      orders: orders,
      conversion_rate: conversion_rate,
      order_rate: order_rate,
      revenue: orders * (price || split_test.menu_item&.price || 0)
    }
  end

  # Get percentage of traffic this variant should receive
  def traffic_percentage
    total_weight = split_test.split_test_variants.sum(:weight)
    return 0 if total_weight.zero?
    (weight.to_f / total_weight * 100).round(2)
  end

  # Check if this is the winning variant
  def is_winner?
    split_test.completed? && split_test.winner_variant_id == id
  end
end

