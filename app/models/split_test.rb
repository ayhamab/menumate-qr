class SplitTest < ApplicationRecord
  belongs_to :restaurant
  belongs_to :menu_item, optional: true # Optional for placement tests
  has_many :split_test_variants, dependent: :destroy
  has_many :split_test_results, dependent: :destroy

  # Test types: description, placement, image, price
  validates :test_type, inclusion: { in: %w[description placement image price] }
  validates :name, presence: true, length: { maximum: 255 }
  validates :status, inclusion: { in: %w[draft active paused completed] }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :by_type, ->(type) { where(test_type: type) if type.present? }

  # Instance methods
  def active?
    status == 'active'
  end

  def completed?
    status == 'completed'
  end

  def paused?
    status == 'paused'
  end

  def draft?
    status == 'draft'
  end

  # Get the winning variant based on conversion rate
  def winning_variant
    return nil unless completed? || active?
    
    variants_with_stats = split_test_variants.map do |variant|
      stats = variant.statistics
      {
        variant: variant,
        conversion_rate: stats[:conversion_rate],
        impressions: stats[:impressions],
        clicks: stats[:clicks]
      }
    end
    
    # Sort by conversion rate (descending), then by clicks if tied
    sorted = variants_with_stats.sort_by { |v| [-v[:conversion_rate], -v[:clicks]] }
    sorted.first&.dig(:variant)
  end

  # Get statistics for the test
  def statistics
    total_impressions = split_test_results.where(event_type: 'impression').count
    total_clicks = split_test_results.where(event_type: 'click').count
    total_orders = split_test_results.where(event_type: 'order').count
    
    {
      total_impressions: total_impressions,
      total_clicks: total_clicks,
      total_orders: total_orders,
      overall_conversion_rate: total_impressions > 0 ? (total_clicks.to_f / total_impressions * 100).round(2) : 0,
      order_conversion_rate: total_clicks > 0 ? (total_orders.to_f / total_clicks * 100).round(2) : 0
    }
  end

  # Check if test has enough data to determine a winner
  def has_statistical_significance?(confidence_level: 0.95)
    return false unless split_test_variants.count >= 2
    
    variants = split_test_variants.includes(:split_test_results).to_a
    return false if variants.any? { |v| v.statistics[:impressions] < 100 } # Minimum sample size
    
    # Simple statistical significance check (Z-test approximation)
    rates = variants.map { |v| v.statistics[:conversion_rate] }
    return false if rates.uniq.count < 2 # All variants have same rate
    
    # Calculate if difference is significant
    # This is a simplified check - in production, use proper statistical tests
    max_rate = rates.max
    min_rate = rates.min
    difference = max_rate - min_rate
    
    # Consider significant if difference is > 5% and we have enough data
    difference > 5.0 && variants.all? { |v| v.statistics[:impressions] >= 100 }
  end

  # Auto-complete test if winner is clear
  def check_and_complete
    return unless active?
    return unless has_statistical_significance?
    
    winner = winning_variant
    return unless winner
    
    # Update status
    update(status: 'completed', completed_at: Time.current, winner_variant_id: winner.id)
    
    # Optionally apply winner to menu item
    apply_winner if auto_apply_winner?
  end

  # Apply winning variant to the actual menu item
  def apply_winner
    return unless completed? && winner_variant_id.present?
    
    winner = split_test_variants.find(winner_variant_id)
    return unless winner && menu_item.present?
    
    case test_type
    when 'description'
      menu_item.update(description: winner.description)
    when 'placement'
      # Update position if applicable
      menu_item.update(position: winner.position) if winner.position.present?
    when 'image'
      # Update image if applicable
      menu_item.image.attach(winner.image.blob) if winner.image.attached? && menu_item.image.attached?
    when 'price'
      menu_item.update(price: winner.price) if winner.price.present?
    end
  end

  def auto_apply_winner?
    auto_apply_winner == true
  end
end

